using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.Datos;
using ZofraTacna.LogicaNegocio;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class EditarDocumento : Page
    {
        private readonly ModuloGestionDocumental _modulo = new ModuloGestionDocumental();
        private readonly RepositorioBloqueoFlujo _repoBloqueo = new RepositorioBloqueoFlujo();
        protected string LockToken => (ViewState["LockToken"] as string) ?? "";

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
                ViewState["LockToken"] = Guid.NewGuid().ToString("N");
                CargarDatosUsuario();
                CargarCombos();
                CargarDocumento();
                RegistrarBloqueoEdicionRegistrador();
            }
            else
            {
                TocarBloqueoEdicionRegistrador();
            }
        }

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
        }

        private void CargarDocumento()
        {
            try
            {
                // Obtener el ID del documento desde QueryString
                string idDocStr = Request.QueryString["id"];
                if (string.IsNullOrEmpty(idDocStr) || !int.TryParse(idDocStr, out int idDocumento))
                {
                    MostrarMsg("Documento no encontrado.", false);
                    return;
                }

                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string sql = @"SELECT CodigoDocumento, Asunto, Descripcion, 
                                          IdTipoDocumento, Prioridad,
                                          FechaLimiteRevision, FechaLimiteAprobacion,
                                          LoginUsuarioRegistrador
                                   FROM Documento 
                                   WHERE IdDocumento = @id AND Activo = 1";

                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idDocumento);
                        using (var dr = cmd.ExecuteReader())
                        {
                            if (!dr.Read())
                            {
                                MostrarMsg("No se encontr� el documento.", false);
                                return;
                            }

                            // Parsear c�digo documento (formato: CODIGO-NUMERO-A�O)
                            string codigoCompleto = dr["CodigoDocumento"].ToString();
                            string[] partes = codigoCompleto.Split('-');

                            txtCodigoDoc.Text = partes.Length > 0 ? partes[0] : "";
                            txtNumeroDoc.Text = partes.Length > 1 ? partes[1] : "";
                            txtAnoDoc.Text = partes.Length > 2 ? partes[2] : DateTime.Now.Year.ToString();

                            txtAsunto.Text = dr["Asunto"].ToString();
                            txtDescripcion.Text = dr["Descripcion"] == DBNull.Value ? "" : dr["Descripcion"].ToString();

                            string idTipo = dr["IdTipoDocumento"].ToString();
                            ddlCategoria.SelectedValue = idTipo;

                            ddlPrioridad.SelectedValue = dr["Prioridad"].ToString();

                            // Calcular horas restantes
                            DateTime limRev = dr["FechaLimiteRevision"] == DBNull.Value ? DateTime.Now.AddHours(24) : (DateTime)dr["FechaLimiteRevision"];
                            DateTime limFirma = dr["FechaLimiteAprobacion"] == DBNull.Value ? DateTime.Now.AddHours(48) : (DateTime)dr["FechaLimiteAprobacion"];

                            int horasRev = (int)Math.Max(0, (limRev - DateTime.Now).TotalHours);
                            int horasFirma = (int)Math.Max(0, (limFirma - DateTime.Now).TotalHours);

                            txtPlazoRevision.Text = horasRev.ToString();
                            txtPlazoFirma.Text = horasFirma.ToString();
                        }
                    }
                }

                // Cargar observaciones en una conexi�n separada
                CargarObservaciones(idDocumento);
            }
            catch (Exception ex)
            {
                MostrarMsg("Error al cargar documento: " + ex.Message, false);
            }
        }

        private void CargarObservaciones(int idDocumento)
        {
            var observaciones = new List<string>();
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                string sql = @"SELECT dp.LoginUsuario, rd.Comentario, rd.FechaRevision
                              FROM RevisionDetalle rd
                              INNER JOIN DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                              WHERE dp.IdDocumento = @id AND rd.EsObservacion = 1
                              ORDER BY rd.FechaRevision DESC";

                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string login = dr["LoginUsuario"].ToString();
                            string comentario = dr["Comentario"] == DBNull.Value ? "" : dr["Comentario"].ToString();
                            DateTime fecha = (DateTime)dr["FechaRevision"];

                            observaciones.Add($"<div class='obs-item'><strong>{fecha:d/M/yyyy HH:mm} - {login}</strong><br/>{comentario}</div>");
                        }
                    }
                }
            }

            if (observaciones.Count == 0)
            {
                litObservaciones.Text = "<p style='color:#999;font-size:13px;'>Sin observaciones.</p>";
            }
            else
            {
                litObservaciones.Text = string.Join("", observaciones);
            }
        }

        protected void btnEnviarCorreccion_Click(object sender, EventArgs e)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(txtCodigoDoc.Text))
                {
                    MostrarMsg("Indique el codigo del documento (letras).", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtNumeroDoc.Text))
                {
                    MostrarMsg("Indique el numero del documento.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtAnoDoc.Text))
                {
                    MostrarMsg("Indique el anio del documento.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(txtAsunto.Text))
                {
                    MostrarMsg("El asunto es obligatorio.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(ddlCategoria.SelectedValue))
                {
                    MostrarMsg("Debe seleccionar una categoria.", false);
                    return;
                }

                if (string.IsNullOrWhiteSpace(ddlPrioridad.SelectedValue))
                {
                    MostrarMsg("Debe seleccionar una prioridad.", false);
                    return;
                }

                string idDocStr = Request.QueryString["id"];
                if (!int.TryParse(idDocStr, out int idDocumento))
                {
                    MostrarMsg("ID de documento invalido.", false);
                    return;
                }

                // Preparar PDF si existe
                byte[] pdfBytes = null;
                string pdfNombre = null;
                if (filePDF.HasFile && filePDF.PostedFile != null)
                {
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

                    using (BinaryReader br = new BinaryReader(filePDF.PostedFile.InputStream))
                        pdfBytes = br.ReadBytes(filePDF.PostedFile.ContentLength);

                    pdfNombre = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Path.GetFileName(filePDF.FileName);
                }

                // Actualizar documento en FirmaDigital
                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    using (var transaction = cn.BeginTransaction())
                    {
                        try
                        {
                            // Obtener estado actual del documento
                            int idEstadoActual = 0;
                            string sqlEstado = "SELECT IdEstadoDocumento FROM Documento WHERE IdDocumento = @id";
                            using (var cmd = new SqlCommand(sqlEstado, cn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@id", idDocumento);
                                object result = cmd.ExecuteScalar();
                                if (result != null && result != DBNull.Value)
                                    idEstadoActual = (int)result;
                            }

                            int idEstadoReg = ObtenerIdMaestro(conn: cn, tx: transaction, tipo: "ESTADO_DOC", codigo: "REG");
                            int idEstadoParticipantePen = ObtenerIdMaestro(conn: cn, tx: transaction, tipo: "ESTADO_PARTICIPANTE", codigo: "PEN");

                            // Actualizar documento
                            string sql = @"UPDATE Documento 
                                           SET Asunto = @asunto,
                                               Descripcion = @desc,
                                               IdTipoDocumento = @tipo,
                                               Prioridad = @pri
                                           WHERE IdDocumento = @id";

                            using (var cmd = new SqlCommand(sql, cn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@asunto", txtAsunto.Text.Trim());
                                cmd.Parameters.AddWithValue("@desc", txtDescripcion.Text.Trim());
                                cmd.Parameters.AddWithValue("@tipo", int.Parse(ddlCategoria.SelectedValue));
                                cmd.Parameters.AddWithValue("@pri", ddlPrioridad.SelectedValue);
                                cmd.Parameters.AddWithValue("@id", idDocumento);
                                cmd.ExecuteNonQuery();
                            }

                            if (idEstadoReg > 0)
                            {
                                using (var cmd = new SqlCommand("UPDATE Documento SET IdEstadoDocumento = @estado WHERE IdDocumento = @id", cn, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@estado", idEstadoReg);
                                    cmd.Parameters.AddWithValue("@id", idDocumento);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            if (idEstadoParticipantePen > 0)
                            {
                                string sqlResetParticipantes = @"UPDATE dp
                                                                 SET dp.EstadoParticipante = @estadoPen
                                                                 FROM DocumentoParticipante dp
                                                                 INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                                                 WHERE dp.IdDocumento = @id
                                                                   AND mt.Tipo = 'TIPO_PARTICIPANTE'
                                                                   AND mt.Codigo = 'REV'";
                                using (var cmd = new SqlCommand(sqlResetParticipantes, cn, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@estadoPen", idEstadoParticipantePen);
                                    cmd.Parameters.AddWithValue("@id", idDocumento);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            string sqlLimpiarRevisiones = @"DELETE rd
                                                            FROM RevisionDetalle rd
                                                            INNER JOIN DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                                                            INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                                            WHERE dp.IdDocumento = @id
                                                              AND mt.Tipo = 'TIPO_PARTICIPANTE'
                                                              AND mt.Codigo = 'REV'";
                            using (var cmd = new SqlCommand(sqlLimpiarRevisiones, cn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@id", idDocumento);
                                cmd.ExecuteNonQuery();
                            }

                            // Registrar en historial que el registrador levant� correcci�n
                            string loginUsuario = Session["LoginUsuario"].ToString();
                            string sqlHistorial = @"INSERT INTO HistorialDocumento 
                                (IdDocumento, IdEstadoAnterior, IdEstadoNuevo, LoginUsuarioAccion, DetalleAccion, FechaCambio)
                                VALUES (@idDoc, @estAnterior, @estNuevo, @login, @detalle, GETDATE())";

                            using (var cmd = new SqlCommand(sqlHistorial, cn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                                cmd.Parameters.AddWithValue("@estAnterior", idEstadoActual);
                                cmd.Parameters.AddWithValue("@estNuevo", idEstadoReg > 0 ? idEstadoReg : idEstadoActual);
                                cmd.Parameters.AddWithValue("@login", loginUsuario);
                                cmd.Parameters.AddWithValue("@detalle", "Registrador envio correccion; se reinicio el flujo de revision.");
                                cmd.ExecuteNonQuery();
                            }

                            // Si hay nuevo PDF, registrar en historial
                            if (pdfBytes != null)
                            {
                                string sqlHistorialPDF = @"INSERT INTO HistorialDocumento 
                                    (IdDocumento, IdEstadoAnterior, IdEstadoNuevo, LoginUsuarioAccion, DetalleAccion, FechaCambio)
                                    VALUES (@idDoc, @estAnterior, @estNuevo, @login, @detalle, GETDATE())";

                                using (var cmd = new SqlCommand(sqlHistorialPDF, cn, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                                    cmd.Parameters.AddWithValue("@estAnterior", idEstadoActual);
                                    cmd.Parameters.AddWithValue("@estNuevo", idEstadoReg > 0 ? idEstadoReg : idEstadoActual);
                                    cmd.Parameters.AddWithValue("@login", loginUsuario);
                                    cmd.Parameters.AddWithValue("@detalle", "Nuevo PDF cargado: " + pdfNombre);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            transaction.Commit();
                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }

                // Actualizar PDF en FirmaDigital_Files (SEPARADO)
                if (pdfBytes != null)
                {
                    string connFilesStr = ConfigurationManager.ConnectionStrings["FirmaDigital_Files"].ConnectionString;
                    using (var cnFiles = new SqlConnection(connFilesStr))
                    {
                        cnFiles.Open();

                        // Eliminar PDF anterior
                        string sqlDelete = "DELETE FROM DocumentoAdjunto WHERE IdDocumento = @id";
                        using (var cmd = new SqlCommand(sqlDelete, cnFiles))
                        {
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        // Insertar nuevo PDF
                        string sqlInsert = @"INSERT INTO DocumentoAdjunto 
                            (IdDocumento, ContenidoPDF, NombreArchivo, TipoMime, TamanioBytes, UsuarioCreacion, FechaCreacion)
                            VALUES (@id, @pdf, @nom, @mime, @size, @user, GETDATE())";

                        using (var cmd = new SqlCommand(sqlInsert, cnFiles))
                        {
                            cmd.CommandTimeout = 120;
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.Parameters.Add("@pdf", System.Data.SqlDbType.VarBinary, -1).Value = pdfBytes;
                            cmd.Parameters.AddWithValue("@nom", pdfNombre);
                            cmd.Parameters.AddWithValue("@mime", "application/pdf");
                            cmd.Parameters.AddWithValue("@size", pdfBytes.Length);
                            cmd.Parameters.AddWithValue("@user", Session["LoginUsuario"].ToString());
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                LiberarBloqueoEdicionRegistrador();

                MostrarMsg("Documento actualizado correctamente. Redirigiendo a Mis documentos...", true);
                ClientScript.RegisterStartupScript(GetType(), "redirectEditDoc",
                    "setTimeout(function(){ window.location = 'MisDocumentos.aspx'; }, 2000);", true);
            }
            catch (Exception ex)
            {
                MostrarMsg("ERROR: " + ex.Message, false);
            }
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }

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
                    "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                    "<a href='MisDocumentos.aspx' class='nav-item active'>" + svgMisDocs + "Mis Documentos</a>";
            }

            int badge = GetBadgeCount();
            return
                "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                "<a href='../BandejaTrabajo/BandejaTrabajo.aspx' class='nav-item'>" + svgBandeja + "Bandeja de Trabajo<span class='nav-badge'>" + badge + "</span></a>" +
                "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                "<a href='MisDocumentos.aspx' class='nav-item active'>" + svgMisDocs + "Mis Documentos</a>" +
                "<a href='../GestionRoles/GestionRoles.aspx' class='nav-item'>" + svgRoles + "Gesti&oacute;n de Roles</a>" +
                "<a href='../VisualizarFirmantes/VisualizarFirmantes.aspx' class='nav-item'>" + svgFirm + "Visualizar Firmantes</a>" +
                "<a href='#' class='nav-item'>" + svgEstado + "Estado del Sistema</a>";
        }

        private int GetBadgeCount()
        {
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')", cn))
                    return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void MostrarMsg(string msg, bool ok)
        {
            lblMensaje.Text = msg;
            lblMensaje.CssClass = ok ? "alert-ok" : "alert-err";
            lblMensaje.Style["display"] = "block";
        }

        private int ObtenerIdMaestro(SqlConnection conn, SqlTransaction tx, string tipo, string codigo)
        {
            const string sql = "SELECT IdMaestro FROM Maestro WHERE Tipo = @tipo AND Codigo = @codigo";
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@tipo", tipo);
                cmd.Parameters.AddWithValue("@codigo", codigo);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
            }
        }

        private void RegistrarBloqueoEdicionRegistrador()
        {
            int idDocumento;
            if (!int.TryParse(Request.QueryString["id"], out idDocumento) || idDocumento <= 0) return;
            if (string.IsNullOrWhiteSpace(LockToken)) return;
            string login = Session["LoginUsuario"] != null ? Session["LoginUsuario"].ToString() : "";
            _repoBloqueo.RegistrarOTocarBloqueo(idDocumento, "REG_EDIT", login, LockToken);
        }

        private void TocarBloqueoEdicionRegistrador()
        {
            RegistrarBloqueoEdicionRegistrador();
        }

        private void LiberarBloqueoEdicionRegistrador()
        {
            int idDocumento;
            if (!int.TryParse(Request.QueryString["id"], out idDocumento) || idDocumento <= 0) return;
            if (string.IsNullOrWhiteSpace(LockToken)) return;
            _repoBloqueo.LiberarBloqueo(idDocumento, "REG_EDIT", LockToken);
        }
    }
}
