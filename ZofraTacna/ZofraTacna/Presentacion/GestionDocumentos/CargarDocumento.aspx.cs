using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.LogicaNegocio;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public class FirmanteItem
    {
        public int Orden { get; set; }
        public string Login { get; set; }
        public string Tipo { get; set; }
    }

    public partial class CargarDocumento : Page
    {
        private readonly ModuloGestionDocumental _modulo = new ModuloGestionDocumental();

        private List<FirmanteItem> Firmantes
        {
            get
            {
                if (Session["FirmantesTemp"] == null)
                    Session["FirmantesTemp"] = new List<FirmanteItem>();
                return (List<FirmanteItem>)Session["FirmantesTemp"];
            }
        }

        #region Page Events

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null)
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            string rol = Session["RolCodigo"].ToString();
            if (rol != "ADM" && rol != "REG")
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarDatosUsuario();
                CargarCombos();
                CargarEmpleadosEnListBoxOculto();  // Cargar empleados para búsqueda local
            }
        }

        /// <summary>
        /// Carga todos los empleados disponibles en el ListBox oculto
        /// para que JavaScript pueda filtrar localmente sin postback
        /// </summary>
        private void CargarEmpleadosEnListBoxOculto()
        {
            lstBuscador.Items.Clear();
            var empleados = _modulo.ObtenerEmpleadosDisponibles();
            
            foreach (var emp in empleados)
            {
                // Formato: "Login - Nombre (Area)" as text, login as value
                string texto = $"{emp.LoginUsuario} - {emp.NombreCompleto}";
                lstBuscador.Items.Add(new ListItem(texto, emp.LoginUsuario));
            }
        }

        #endregion

        #region Search Methods

        // DEPRECATED: Ya no se usa AutoPostBack
        // El filtrado ahora se hace con JavaScript en el cliente sin postback
        /*
        protected void txtBuscador_TextChanged(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtBuscador.Text.Trim()))
            {
                lstBuscador.Items.Clear();
                lstBuscador.Visible = false;
                return;
            }

            FiltrarEmpleados(txtBuscador.Text);
            lstBuscador.Visible = lstBuscador.Items.Count > 0;
        }
        */

        protected void lstBuscador_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Este método ya no se llama desde el cliente (sin AutoPostBack)
            // Se mantiene por compatibilidad pero no se usa
        }

        private void FiltrarEmpleados(string termino)
        {
            termino = termino.ToLower().Trim();

            var empleados = _modulo.ObtenerEmpleadosDisponibles();

            lstBuscador.Items.Clear();

            foreach (var emp in empleados)
            {
                if (emp.LoginUsuario.ToLower().Contains(termino) || 
                    emp.NombreCompleto.ToLower().Contains(termino))
                {
                    string texto = emp.NombreCompleto + " (" + emp.LoginUsuario + ")";
                    lstBuscador.Items.Add(new ListItem(texto, emp.LoginUsuario));
                }
            }

            // Máximo 20 resultados
            while (lstBuscador.Items.Count > 20)
            {
                lstBuscador.Items.RemoveAt(lstBuscador.Items.Count - 1);
            }
        }

        #endregion

        #region Load Data

        private void CargarDatosUsuario()
        {
            string login = Session["LoginUsuario"].ToString();
            string rol = Session["RolCodigo"].ToString();

            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text = Session["RolNombre"].ToString();
            litSidebarNav.Text = BuildNav(rol);
        }

        private void CargarCombos()
        {
            // Categor�as
            var categorias = _modulo.ObtenerCategorias();
            ddlCategoria.Items.Clear();
            ddlCategoria.Items.Add(new ListItem("Seleccionar...", ""));
            foreach (var cat in categorias)
            {
                string[] partes = cat.Split('|');
                ddlCategoria.Items.Add(new ListItem(partes[1], partes[0]));
            }

            // Unidades Org�nicas
            var unidades = _modulo.ObtenerUnidadesOrganicas();
            ddlArea.Items.Clear();
            ddlArea.Items.Add(new ListItem("Seleccionar...", ""));
            foreach (var unidad in unidades)
            {
                string[] partes = unidad.Split('|');
                ddlArea.Items.Add(new ListItem(partes[1], partes[0]));
            }
        }

        #endregion

        #region Button Events

        protected void btnCargar_Click(object sender, EventArgs e)
        {
            try
            {
                string codigoDocCompleto = (txtCodigoDocumentoCompleto.Text ?? "").Trim();
                if (string.IsNullOrWhiteSpace(codigoDocCompleto))
                {
                    MostrarMsg("Ingrese el código completo del documento.", false);
                    return;
                }

                // Validar ASUNTO
                if (string.IsNullOrWhiteSpace(txtAsunto.Text))
                {
                    MostrarMsg("El asunto es requerido.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(ddlCategoria.SelectedValue))
                {
                    MostrarMsg("Debe seleccionar una categor�a.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(ddlArea.SelectedValue))
                {
                    MostrarMsg("Debe seleccionar el área (unidad orgánica).", false);
                    return;
                }

                if (!filePDF.HasFile || filePDF.PostedFile == null)
                {
                    MostrarMsg("Debe adjuntar un archivo PDF.", false);
                    return;
                }

                if (Path.GetExtension(filePDF.FileName).ToLower() != ".pdf")
                {
                    MostrarMsg("Solo se permiten archivos PDF.", false);
                    return;
                }

                if (filePDF.PostedFile.ContentLength > 15 * 1024 * 1024)
                {
                    MostrarMsg("El archivo supera los 15MB.", false);
                    return;
                }

                // Obtener participantes desde JSON
                string jsonParticipantes = hfParticipantes.Value;
                if (string.IsNullOrWhiteSpace(jsonParticipantes))
                {
                    MostrarMsg("Debe asignar al menos un revisor o firmante.", false);
                    return;
                }

                var js = new System.Web.Script.Serialization.JavaScriptSerializer();
                var participantesJson = js.Deserialize<List<dynamic>>(jsonParticipantes);

                if (participantesJson == null || participantesJson.Count == 0)
                {
                    MostrarMsg("Debe asignar al menos un revisor o firmante.", false);
                    return;
                }

                // Leer PDF
                byte[] pdfBytes;
                using (BinaryReader br = new BinaryReader(filePDF.PostedFile.InputStream))
                    pdfBytes = br.ReadBytes(filePDF.PostedFile.ContentLength);

                if (pdfBytes.Length == 0)
                {
                    MostrarMsg("El PDF est� vac�o.", false);
                    return;
                }

                // Parsear plazos
                int horasRev = int.TryParse(txtPlazoRevision.Text.Trim(), out int hr) ? hr : 24;
                int horasFirma = int.TryParse(txtPlazoFirma.Text.Trim(), out int hf) ? hf : 48;

                // Convertir participantes JSON a lista de objetos
                var participantes = new List<RegistrarParticipanteItem>();

                foreach (var p in participantesJson)
                {
                    string login = p["login"] ?? "";
                    string tipo = p["tipo"] ?? "REV";
                    int orden = p.ContainsKey("orden") ? (p["orden"] ?? 0) : 0;

                    participantes.Add(new RegistrarParticipanteItem
                    {
                        Orden = orden,
                        Login = login,
                        Tipo = tipo
                    });
                }

                // Un solo campo → NumeroDocumento vacío hace que negocio use CodigoDocumento tal cual en BD
                var request = new RegistrarDocumentoRequest
                {
                    CodigoDocumento = codigoDocCompleto,
                    NumeroDocumento = null,
                    AnoDocumento = 0,
                    Asunto = txtAsunto.Text.Trim(),
                    Descripcion = txtDescripcion.Text.Trim(),
                    IdTipoDocumento = int.Parse(ddlCategoria.SelectedValue),
                    IDUnidadOrganica = int.Parse(ddlArea.SelectedValue),
                    Prioridad = ddlPrioridad.SelectedValue,
                    HorasRevision = horasRev,
                    HorasFirma = horasFirma,
                    ContenidoPDF = pdfBytes,
                    NombreArchivoPDF = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Path.GetFileName(filePDF.FileName),
                    Participantes = participantes
                };

                // Registrar en l�gica de negocio
                string loginUsuario = Session["LoginUsuario"].ToString();
                int idDocumento = _modulo.RegistrarDocumentoConParticipantes(request, loginUsuario);
                if (idDocumento > 0)
                {
                    _modulo.NotificarRevisores(idDocumento);
                }

                // Limpiar
                txtCodigoDocumentoCompleto.Text = "";
                txtAsunto.Text = "";
                txtDescripcion.Text = "";
                txtPlazoRevision.Text = "24";
                txtPlazoFirma.Text = "48";
                txtBuscador.Text = "";
                hfParticipantes.Value = "";
                Session.Remove("FirmantesTemp");

                MostrarMsg("Documento registrado y participantes asignados correctamente.", true);
            }
            catch (ArgumentException ex)
            {
                MostrarMsg("ERROR: " + ex.Message, false);
            }
            catch (FormatException)
            {
                MostrarMsg("Verifique los campos numéricos (año, plazos, área y categoría).", false);
            }
            catch (Exception ex)
            {
                MostrarMsg("ERROR: " + ex.Message + " | " + (ex.InnerException?.Message ?? ""), false);
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Presentacion/GestionDocumentos/MisDocumentos.aspx");
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }

        #endregion

        #region Utilities

        private string BuildNav(string rol)
        {
            string svgHome = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgCargar = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgRoles = "<svg viewBox='0 0 24 24'><path d='M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z'/></svg>";
            string svgFirm = "<svg viewBox='0 0 24 24'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>";
            string svgEstado = "<svg viewBox='0 0 24 24'><path d='M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z'/></svg>";

            if (rol == "REG")
            {
                return
                    "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='CargarDocumento.aspx' class='nav-item active'>" + svgCargar + "Cargar Documento</a>" +
                    "<a href='MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>";
            }

            return
                "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                "<a href='../BandejaTrabajo/BandejaTrabajo.aspx' class='nav-item'>" + svgBandeja + "Bandeja de Trabajo</a>" +
                "<a href='CargarDocumento.aspx' class='nav-item active'>" + svgCargar + "Cargar Documento</a>" +
                "<a href='MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>" +
                "<a href='../GestionRoles/GestionRoles.aspx' class='nav-item'>" + svgRoles + "Gesti&oacute;n de Roles</a>" +
                "<a href='../VisualizarFirmantes/VisualizarFirmantes.aspx' class='nav-item'>" + svgFirm + "Visualizar Firmantes</a>" +
                "<a href='#' class='nav-item'>" + svgEstado + "Estado del Sistema</a>";
        }

        private void MostrarMsg(string msg, bool ok)
        {
            lblMensaje.Text = msg;
            lblMensaje.CssClass = ok ? "alert-ok" : "alert-err";
            lblMensaje.Visible = true;

            // Éxito: mostrar modal de éxito y redirigir a MisDocumentos
            if (ok && msg.IndexOf("registrado", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                string url = ResolveUrl("~/Presentacion/GestionDocumentos/MisDocumentos.aspx");
                string script = "mostrarModalExitoCarga('" + url + "');";
                ClientScript.RegisterStartupScript(GetType(), "modalExitoCarga", script, true);
            }
        }

        #endregion
    }
}
