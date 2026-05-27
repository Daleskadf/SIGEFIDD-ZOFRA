using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class VerObservaciones : Page
    {
        protected bool MostrarPopupBloqueo
        {
            get { return ViewState["MostrarPopupBloqueo"] != null && (bool)ViewState["MostrarPopupBloqueo"]; }
            set { ViewState["MostrarPopupBloqueo"] = value; }
        }
        protected string MensajePopupBloqueo
        {
            get { return (ViewState["MensajePopupBloqueo"] as string) ?? ""; }
            set { ViewState["MensajePopupBloqueo"] = value; }
        }

        protected bool UsarVisorMarcadoresPdf
        {
            get { return ViewState["UsarVisorMarcadoresPdf"] != null && (bool)ViewState["UsarVisorMarcadoresPdf"]; }
            set { ViewState["UsarVisorMarcadoresPdf"] = value; }
        }

        protected string PdfUrlVisorJs
        {
            get { return (ViewState["PdfUrlVisorJs"] as string) ?? ""; }
            set { ViewState["PdfUrlVisorJs"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "REG" && rol != "ADM") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            int id;
            if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0) { Response.Redirect("MisDocumentos.aspx"); return; }
            if (!IsPostBack)
            {
                MostrarPopupBloqueo = false;
                MensajePopupBloqueo = "";
            }

            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text = Session["RolNombre"].ToString();
            litSidebarNav.Text = BuildNav(rol);

            var repo = new RepositorioDocumentos();
            Documento doc = repo.ObtenerDocumentoPorId(id);
            if (doc == null) { Response.Redirect("MisDocumentos.aspx"); return; }

            int idAdj; string nombre; int tam;
            if (repo.IntentarAdjuntoPrincipal(id, out idAdj, out nombre, out tam))
            {
                litNombreArchivo.Text = HttpUtility.HtmlEncode(nombre);
                string pdfUrl = ResolveUrl("~/Presentacion/BandejaTrabajo/ServirPdf.ashx?idDoc=" + id);
                UsarVisorMarcadoresPdf = repo.ExisteTablaDocumentoObservacionMarcador();
                PdfUrlVisorJs = UsarVisorMarcadoresPdf ? pdfUrl : "";
                if (UsarVisorMarcadoresPdf)
                {
                    ifrPdf.Visible = false;
                    ifrPdf.Attributes["src"] = "";
                }
                else
                {
                    ifrPdf.Visible = true;
                    ifrPdf.Attributes["src"] = pdfUrl;
                }
            }
            else
            {
                UsarVisorMarcadoresPdf = false;
                PdfUrlVisorJs = "";
            }

            var pendientes = repo.ObtenerObservacionesPendientesEstructuradas(id);
            var levantadas = repo.ObtenerObservacionesLevantadasHistorial(id);
            litObservaciones.Text = ConstruirHtmlFlujoObservaciones(pendientes, levantadas);
        }

        private static string ConstruirHtmlFlujoObservaciones(List<ObservacionFlujoItem> pendientes, List<ObservacionFlujoItem> levantadas)
        {
            var sb = new StringBuilder();
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");

            if ((pendientes == null || pendientes.Count == 0) && (levantadas == null || levantadas.Count == 0))
            {
                sb.Append("<div style='text-align:center;padding:40px 20px;color:#999'>");
                sb.Append("<svg viewBox='0 0 24 24' style='width:48px;height:48px;fill:#ddd;margin-bottom:12px'><path d='M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm-2-13h4v6h-4z'/></svg>");
                sb.Append("<p style='font-size:13px;margin:0'>No hay observaciones registradas en este documento.</p>");
                sb.Append("</div>");
                return sb.ToString();
            }

            // SECCIÓN: PENDIENTES DE CORRECCIÓN
            sb.Append("<div class='obs-section'><h4>Pendientes de correcci&oacute;n</h4>");
            if (pendientes == null || pendientes.Count == 0)
            {
                sb.Append("<div style='padding:16px;background:#f0f7ff;border-radius:8px;border-left:3px solid #2196f3;font-size:12px;color:#1565c0;line-height:1.5'>");
                sb.Append("✓ Ninguna observaci&oacute;n vigente. Si ya envi&oacute; correcci&oacute;n tras una observaci&oacute;n, consulte la secci&oacute;n siguiente.");
                sb.Append("</div>");
            }
            else
            {
                foreach (ObservacionFlujoItem o in pendientes)
                {
                    sb.Append("<div class='obs-item'>");
                    sb.Append("<span class='badge-estado badge-pend'>Pendiente</span>");
                    
                    // Procesar comentario para separar marcadores y observación general
                    string comentario = o.Comentario ?? "";
                    string[] partes = comentario.Split(new[] { "\n\n" }, StringSplitOptions.None);
                    string comentarioMarcadores = partes[0].Trim();
                    string observacionGeneral = partes.Length > 1 ? partes[1].Trim() : "";
                    
                    var marcadores = System.Text.RegularExpressions.Regex.Matches(comentarioMarcadores, @"\[Marcador\s+\d+\s*-\s*Pag\.\s*\d+\]");
                    
                    if (marcadores.Count > 0)
                    {
                        // Mostrar marcadores separados
                        sb.Append("<div style='margin-top:10px;font-weight:600;color:#333'>Marcadores:</div>");
                        sb.Append("<div style='margin-top:8px;display:flex;flex-direction:column;gap:6px'>");
                        
                        foreach (System.Text.RegularExpressions.Match marcador in marcadores)
                        {
                            int marIdx = comentarioMarcadores.IndexOf(marcador.Value);
                            int nextMarIdx = comentarioMarcadores.IndexOf("[Marcador", marIdx + 1);
                            int endIdx = nextMarIdx > 0 ? nextMarIdx : comentarioMarcadores.Length;
                            
                            string marcadorText = comentarioMarcadores.Substring(marIdx, endIdx - marIdx).Trim();
                            sb.Append("<div style='background:#fff8f0;padding:8px 10px;border-radius:6px;border-left:3px solid #ff9800;font-size:12px;line-height:1.5'>");
                            sb.Append("<div style='font-weight:600;color:#e65100'>").Append(HttpUtility.HtmlEncode(marcador.Value)).Append("</div>");
                            sb.Append("<div style='margin-top:4px;color:#444'>").Append(HttpUtility.HtmlEncode(marcadorText.Replace(marcador.Value, "").Trim())).Append("</div>");
                            sb.Append("</div>");
                        }
                        sb.Append("</div>");
                    }
                    else if (!string.IsNullOrWhiteSpace(comentarioMarcadores))
                    {
                        sb.Append("<div style='margin-top:10px;font-weight:600;color:#333'>Observaci&oacute;n:</div>");
                        sb.Append("<div style='margin-top:6px;font-size:13px;line-height:1.6;color:#444'>").Append(HttpUtility.HtmlEncode(comentarioMarcadores)).Append("</div>");
                    }
                    
                    // Mostrar observación general si existe
                    if (!string.IsNullOrWhiteSpace(observacionGeneral))
                    {
                        sb.Append("<div style='margin-top:12px;padding-top:12px;border-top:2px solid #ffe0b2'>");
                        sb.Append("<div style='font-weight:600;color:#e65100;font-size:11px;text-transform:uppercase;letter-spacing:0.5px'>Observaci&oacute;n General:</div>");
                        sb.Append("<div style='margin-top:6px;font-size:12px;line-height:1.5;color:#444;font-style:italic'>").Append(HttpUtility.HtmlEncode(observacionGeneral)).Append("</div>");
                        sb.Append("</div>");
                    }
                    
                    sb.Append("<div class='obs-meta'>");
                    sb.Append("<svg style='width:12px;height:12px;fill:#999;margin-right:4px;vertical-align:middle' viewBox='0 0 24 24'><path d='M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z'/></svg>");
                    sb.Append(HttpUtility.HtmlEncode(o.FechaObservacion.ToString("dd/MM/yyyy HH:mm", pe)));
                    sb.Append(" &mdash; Revisor: <strong>").Append(HttpUtility.HtmlEncode(o.LoginRevisor ?? "Sin especificar")).Append("</strong>");
                    sb.Append("</div></div>");
                }
            }
            sb.Append("</div>");

            // SECCIÓN: YA SUBSANADAS
            sb.Append("<div class='obs-section'><h4>Ya subsanadas</h4>");
            if (levantadas == null || levantadas.Count == 0)
            {
                sb.Append("<div style='padding:16px;background:#f1f8f5;border-radius:8px;border-left:3px solid #4caf50;font-size:12px;color:#2e7d32;line-height:1.5'>");
                sb.Append("Las observaciones subsanadas aparecer&aacute;n aqu&iacute; despu&eacute;s de que env&iacute;e la correcci&oacute;n y se reinicie el flujo de revisi&oacute;n.");
                sb.Append("</div>");
            }
            else
            {
                foreach (ObservacionFlujoItem o in levantadas)
                {
                    sb.Append("<div class='obs-item obs-levantada'>");
                    sb.Append("<span class='badge-estado badge-ok'>Subsanada</span>");
                    
                    // Procesar comentario para separar marcadores y observación general
                    string comentario = o.Comentario ?? "";
                    string[] partes = comentario.Split(new[] { "\n\n" }, StringSplitOptions.None);
                    string comentarioMarcadores = partes[0].Trim();
                    string observacionGeneral = partes.Length > 1 ? partes[1].Trim() : "";
                    
                    var marcadores = System.Text.RegularExpressions.Regex.Matches(comentarioMarcadores, @"\[Marcador\s+\d+\s*-\s*Pag\.\s*\d+\]");
                    
                    if (marcadores.Count > 0)
                    {
                        // Mostrar marcadores separados
                        sb.Append("<div style='margin-top:10px;font-weight:600;color:#1b5e20'>Marcadores:</div>");
                        sb.Append("<div style='margin-top:8px;display:flex;flex-direction:column;gap:6px'>");
                        
                        foreach (System.Text.RegularExpressions.Match marcador in marcadores)
                        {
                            int marIdx = comentarioMarcadores.IndexOf(marcador.Value);
                            int nextMarIdx = comentarioMarcadores.IndexOf("[Marcador", marIdx + 1);
                            int endIdx = nextMarIdx > 0 ? nextMarIdx : comentarioMarcadores.Length;
                            
                            string marcadorText = comentarioMarcadores.Substring(marIdx, endIdx - marIdx).Trim();
                            sb.Append("<div style='background:#e8f5e9;padding:8px 10px;border-radius:6px;border-left:3px solid #4caf50;font-size:12px;line-height:1.5'>");
                            sb.Append("<div style='font-weight:600;color:#2e7d32'>").Append(HttpUtility.HtmlEncode(marcador.Value)).Append("</div>");
                            sb.Append("<div style='margin-top:4px;color:#333'>").Append(HttpUtility.HtmlEncode(marcadorText.Replace(marcador.Value, "").Trim())).Append("</div>");
                            sb.Append("</div>");
                        }
                        sb.Append("</div>");
                    }
                    else if (!string.IsNullOrWhiteSpace(comentarioMarcadores))
                    {
                        sb.Append("<div style='margin-top:10px;font-weight:600;color:#1b5e20'>Observaci&oacute;n Original:</div>");
                        sb.Append("<div style='margin-top:6px;font-size:13px;line-height:1.6;color:#333'>").Append(HttpUtility.HtmlEncode(comentarioMarcadores)).Append("</div>");
                    }
                    
                    // Mostrar observación general si existe
                    if (!string.IsNullOrWhiteSpace(observacionGeneral))
                    {
                        sb.Append("<div style='margin-top:12px;padding-top:12px;border-top:2px solid #c8e6c9'>");
                        sb.Append("<div style='font-weight:600;color:#2e7d32;font-size:11px;text-transform:uppercase;letter-spacing:0.5px'>Observaci&oacute;n General:</div>");
                        sb.Append("<div style='margin-top:6px;font-size:12px;line-height:1.5;color:#333;font-style:italic'>").Append(HttpUtility.HtmlEncode(observacionGeneral)).Append("</div>");
                        sb.Append("</div>");
                    }
                    
                    sb.Append("<div class='obs-meta' style='border-top:1px solid rgba(46,125,50,.15);margin-top:12px;padding-top:10px'>");
                    sb.Append("<svg style='width:12px;height:12px;fill:#2e7d32;margin-right:4px;vertical-align:middle' viewBox='0 0 24 24'><path d='M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm0-13c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4z'/></svg>");
                    sb.Append("Observada el <strong>").Append(HttpUtility.HtmlEncode(o.FechaObservacion.ToString("dd/MM/yyyy HH:mm", pe))).Append("</strong>");
                    sb.Append(" por <strong>").Append(HttpUtility.HtmlEncode(o.LoginRevisor ?? "Sin especificar")).Append("</strong>");
                    if (o.FechaLevantamiento.HasValue)
                    {
                        sb.Append("<br/><svg style='width:12px;height:12px;fill:#2e7d32;margin-right:4px;margin-top:6px;vertical-align:middle' viewBox='0 0 24 24'><path d='M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z'/></svg>");
                        sb.Append(" Levantada el <strong>").Append(HttpUtility.HtmlEncode(o.FechaLevantamiento.Value.ToString("dd/MM/yyyy HH:mm", pe))).Append("</strong>");
                        sb.Append(" por <strong>").Append(HttpUtility.HtmlEncode(o.LoginLevantamiento ?? "Sin especificar")).Append("</strong>");
                    }
                    sb.Append("</div></div>");
                }
            }
            sb.Append("</div>");

            return sb.ToString();
        }

        protected void btnEditarDocumento_Click(object sender, EventArgs e)
        {
            int id;
            if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0)
            {
                Response.Redirect("MisDocumentos.aspx");
                return;
            }

            var repoBloqueo = new RepositorioBloqueoFlujo();

            // Si el documento está en estado OBS, el registrador tiene prioridad.
            // Liberar cualquier bloqueo REV_EDIT residual (sesiones abandonadas).
            var repo = new RepositorioDocumentos();
            Documento doc = repo.ObtenerDocumentoPorId(id);
            bool esObservado = false;
            if (doc != null)
            {
                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT m.Codigo FROM Documento d INNER JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.IdDocumento=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        object o = cmd.ExecuteScalar();
                        esObservado = o != null && o != DBNull.Value && o.ToString() == "OBS";
                    }
                }
            }

            if (esObservado)
            {
                // En estado OBS, es el turno del registrador: liberar bloqueos de revisores
                repoBloqueo.LiberarBloqueo(id, "REV_EDIT", "");
            }
            else
            {
                // En otros estados, respetar el bloqueo del revisor
                bool bloqueado = repoBloqueo.ExisteBloqueoActivo(id, "REV_EDIT", "");
                if (bloqueado)
                {
                    MostrarPopupBloqueo = true;
                    MensajePopupBloqueo = "Un revisor se encuentra emitiendo su revision sobre este documento.";
                    return;
                }
            }

            // Verificar bloqueo de administrador (siempre debe respetarse)
            if (repoBloqueo.ExisteBloqueoActivo(id, "ADM_EDIT", ""))
            {
                MostrarPopupBloqueo = true;
                MensajePopupBloqueo = "El administrador se encuentra modificando el documento.";
                return;
            }

            Response.Redirect("EditarDocumento.aspx?id=" + id);
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

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear(); Session.Abandon(); Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
