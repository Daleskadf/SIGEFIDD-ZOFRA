using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public partial class GestionAuditoria : Page
    {
        private readonly RepositorioAuditoria _repoAuditoria = new RepositorioAuditoria();
        private readonly RepositorioUsuariosRoles _repoUsuarios = new RepositorioUsuariosRoles();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Validar sesión y rol Administrador (ADM)
            if (Session["LoginUsuario"] == null || Session["RolCodigo"] == null ||
                Session["RolCodigo"].ToString().ToUpper() != "ADM")
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarUsuariosDropdown();
                CargarDocumentos();
                CargarActividadUsuarios();
            }

            CargarDatosCabeceraYSidebar();
        }

        // ============================================================
        // CARGA DE CONFIGURACIÓN Y CABECERAS
        // ============================================================
        private void CargarDatosCabeceraYSidebar()
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"] != null ? Session["RolNombre"].ToString() : "Administrador";

            // Obtener Badge de notificaciones (Documentos pendientes en el flujo)
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            string sqlBadge = @"SELECT COUNT(*) FROM Documento d
                                JOIN Maestro me ON d.IdEstadoDocumento=me.IdMaestro
                                WHERE d.Activo=1 AND me.Codigo IN ('REG','REV','PEN','FPAR','OBS')";

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sqlBadge, cn))
                {
                    litBadge.Text = cmd.ExecuteScalar().ToString();
                }
            }
        }

        private void CargarUsuariosDropdown()
        {
            try
            {
                var usuarios = _repoUsuarios.ObtenerTodos();
                ddlUsuariosActividad.Items.Clear();
                ddlUsuariosActividad.Items.Add(new ListItem("-- Todos los Usuarios --", ""));
                foreach (var u in usuarios)
                {
                    if (u.Activo)
                    {
                        ddlUsuariosActividad.Items.Add(new ListItem(u.LoginUsuario + " (" + u.Rol + ")", u.LoginUsuario));
                    }
                }
            }
            catch (Exception ex)
            {
                // Registrar error silencioso
                _repoAuditoria.InsertarLogError("Presentacion.GestionAuditoria", "Error al cargar dropdown de usuarios: " + ex.Message, ex.StackTrace, Session["LoginUsuario"]?.ToString());
            }
        }

        // ============================================================
        // PESTAÑA 1: AUDITORÍA DE DOCUMENTOS
        // ============================================================
        private void CargarDocumentos()
        {
            try
            {
                string busqueda = txtBusquedaDoc.Text.Trim();
                DateTime? inicio = null;
                DateTime? fin = null;

                if (!string.IsNullOrEmpty(txtFechaInicioDoc.Text))
                    inicio = Convert.ToDateTime(txtFechaInicioDoc.Text);

                if (!string.IsNullOrEmpty(txtFechaFinDoc.Text))
                    fin = Convert.ToDateTime(txtFechaFinDoc.Text);

                DataTable dt = _repoAuditoria.ObtenerDocumentosParaAuditoria(busqueda, inicio, fin);
                gvDocumentos.DataSource = dt;
                gvDocumentos.DataBind();
            }
            catch (Exception ex)
            {
                _repoAuditoria.InsertarLogError("Presentacion.GestionAuditoria", "Error al listar documentos: " + ex.Message, ex.StackTrace, Session["LoginUsuario"]?.ToString());
            }
        }

        protected void btnBuscarDoc_Click(object sender, EventArgs e)
        {
            CargarDocumentos();
        }

        protected void btnClearDoc_Click(object sender, EventArgs e)
        {
            txtBusquedaDoc.Text = "";
            txtFechaInicioDoc.Text = "";
            txtFechaFinDoc.Text = "";
            CargarDocumentos();
        }

        protected void gvDocumentos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "VerAuditoria")
            {
                int idDocumento = Convert.ToInt32(e.CommandArgument);
                CargarDetalleAuditoriaDocumento(idDocumento);
            }
        }

        private void CargarDetalleAuditoriaDocumento(int idDocumento)
        {
            try
            {
                DataSet ds = _repoAuditoria.ObtenerAuditoriaCompletaDocumento(idDocumento);
                
                if (ds == null || ds.Tables.Count < 5 || ds.Tables["Documento"].Rows.Count == 0)
                {
                    return;
                }

                // 1. Ficha Técnica / Datos del Documento
                DataRow drDoc = ds.Tables["Documento"].Rows[0];
                lblDetCodigo.Text = drDoc["CodigoDocumento"].ToString();
                lblDetAsunto.Text = drDoc["Asunto"].ToString();
                lblDetTipo.Text = drDoc["TipoDocumento"].ToString();
                lblDetRegistrador.Text = drDoc["LoginUsuarioRegistrador"].ToString();
                lblDetFechaCrea.Text = Convert.ToDateTime(drDoc["FechaCreacion"]).ToString("dd/MM/yyyy HH:mm:ss");
                lblDetEstado.Text = drDoc["EstadoActual"].ToString();

                // 2. Timeline de Operaciones
                DataTable dtHistorial = ds.Tables["Historial"];
                rptTimeline.DataSource = dtHistorial;
                rptTimeline.DataBind();
                pnlTimelineEmpty.Visible = dtHistorial.Rows.Count == 0;

                // 3. Firmas Digitales
                DataTable dtFirmas = ds.Tables["Firmas"];
                gvDetFirmas.DataSource = dtFirmas;
                gvDetFirmas.DataBind();

                // 4. Marcadores PDF
                DataTable dtMarcadores = ds.Tables["Marcadores"];
                gvDetMarcadores.DataSource = dtMarcadores;
                gvDetMarcadores.DataBind();

                // 5. Observaciones Subsanadas
                DataTable dtSubsanadas = ds.Tables["ObservacionesSubsanadas"];
                gvDetSubsanadas.DataSource = dtSubsanadas;
                gvDetSubsanadas.DataBind();

                // Mostrar Detalle y ocultar listado
                pnlListadoDocumentos.Visible = false;
                pnlDetalleDocumento.Visible = true;
            }
            catch (Exception ex)
            {
                _repoAuditoria.InsertarLogError("Presentacion.GestionAuditoria", "Error al cargar detalle de auditoría: " + ex.Message, ex.StackTrace, Session["LoginUsuario"]?.ToString());
            }
        }

        protected void lnkVolverListado_Click(object sender, EventArgs e)
        {
            pnlDetalleDocumento.Visible = false;
            pnlListadoDocumentos.Visible = true;
            CargarDocumentos();
        }

        // Helpers de formato para la UI
        protected string GetTimelineColor(string estado)
        {
            if (string.IsNullOrEmpty(estado)) return "blue";
            string est = estado.ToUpper();
            if (est.Contains("CREAD") || est.Contains("REGISTR")) return "blue";
            if (est.Contains("OBSERV") || est.Contains("CORREC")) return "red";
            if (est.Contains("REVIS")) return "yellow";
            if (est.Contains("FIRM") || est.Contains("APROB") || est.Contains("FINALIZ")) return "green";
            return "blue";
        }

        // ============================================================
        // PESTAÑA 2: ACTIVIDAD DE USUARIOS
        // ============================================================
        private void CargarActividadUsuarios()
        {
            try
            {
                string login = ddlUsuariosActividad.SelectedValue;
                DateTime? inicio = null;
                DateTime? fin = null;

                if (!string.IsNullOrEmpty(txtFechaInicioUsr.Text))
                    inicio = Convert.ToDateTime(txtFechaInicioUsr.Text);

                if (!string.IsNullOrEmpty(txtFechaFinUsr.Text))
                    fin = Convert.ToDateTime(txtFechaFinUsr.Text);

                DataTable dt = _repoAuditoria.ObtenerAuditoriaActividadUsuarios(login, inicio, fin);
                gvActividadUsuarios.DataSource = dt;
                gvActividadUsuarios.DataBind();
            }
            catch (Exception ex)
            {
                _repoAuditoria.InsertarLogError("Presentacion.GestionAuditoria", "Error al consultar actividad: " + ex.Message, ex.StackTrace, Session["LoginUsuario"]?.ToString());
            }
        }

        protected void btnBuscarUsr_Click(object sender, EventArgs e)
        {
            CargarActividadUsuarios();
        }

        protected void btnClearUsr_Click(object sender, EventArgs e)
        {
            ddlUsuariosActividad.SelectedIndex = 0;
            txtFechaInicioUsr.Text = "";
            txtFechaFinUsr.Text = "";
            CargarActividadUsuarios();
        }

        protected string GetAccionBadge(object accionObj)
        {
            string accion = Convert.ToString(accionObj);
            if (string.IsNullOrEmpty(accion)) return "badge-info";
            string act = accion.ToUpper();
            if (act.Contains("CREACIÓN") || act.Contains("CREADO")) return "badge-info";
            if (act.Contains("ESTADO") || act.Contains("CAMBIO")) return "badge-warning";
            if (act.Contains("FIRMA")) return "badge-success";
            if (act.Contains("OBSERVACIÓN") || act.Contains("PDF")) return "badge-danger";
            if (act.Contains("SUBSANACIÓN") || act.Contains("LEVANT")) return "badge-success";
            return "badge-info";
        }

        protected string GetUserInitials(object usernameObj)
        {
            string username = Convert.ToString(usernameObj);
            if (string.IsNullOrEmpty(username)) return "??";
            string u = username.Trim();
            if (u.Length >= 2) return u.Substring(0, 2).ToUpper();
            return u.ToUpper();
        }

        // ============================================================
        // CONTROL DE TABS
        // ============================================================
        protected void btnTabDoc_Click(object sender, EventArgs e)
        {
            SwitchTab("documentos");
        }

        protected void btnTabUser_Click(object sender, EventArgs e)
        {
            SwitchTab("usuarios");
        }

        private void SwitchTab(string activeTab)
        {
            hfActiveTab.Value = activeTab;

            if (activeTab == "documentos")
            {
                btnTabDoc.CssClass = "tab-btn active";
                btnTabUser.CssClass = "tab-btn";
                pnlTabDocumentos.Visible = true;
                pnlTabUsuarios.Visible = false;
                
                // Reset a listado de documentos por defecto
                pnlDetalleDocumento.Visible = false;
                pnlListadoDocumentos.Visible = true;
                CargarDocumentos();
            }
            else
            {
                btnTabDoc.CssClass = "tab-btn";
                btnTabUser.CssClass = "tab-btn active";
                pnlTabDocumentos.Visible = false;
                pnlTabUsuarios.Visible = true;
                
                CargarActividadUsuarios();
            }
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
