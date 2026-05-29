using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class VerDocumento : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "REV" && rol != "FIR" && rol != "ADM") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }

            int idDoc;
            if (!int.TryParse(Request.QueryString["id"], out idDoc) || idDoc <= 0)
            {
                Response.Redirect("BandejaTrabajo.aspx");
                return;
            }

            CargarVista(idDoc, rol);
        }

        private void CargarVista(int idDoc, string rol)
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text = ZofraTacna.Helpers.RolSwitcherHelper.GenerarBadgeRolOSwitcher(Context, Session["RolCodigo"]?.ToString() ?? "", Session["RolNombre"]?.ToString() ?? "");

            ViewState["IdDoc"] = idDoc;

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                int badge = GetBadgeCount(cn);
                litSidebarNav.Text = BuildNav(rol, badge);

            }

            var repo = new RepositorioDocumentos();
            Documento doc = repo.ObtenerDocumentoPorId(idDoc);
            if (doc == null) { Response.Redirect("BandejaTrabajo.aspx"); return; }

            string tipoDesc = repo.ObtenerDescripcionTipoDocumento(doc.IdTipoDocumento);
            string estadoDesc = ObtenerEstadoDocumento(idDoc, connStr);

            litSubtituloDoc.Text = "<span class='doc-code'>" + HttpUtility.HtmlEncode(doc.CodigoDocumento) +
                                   "</span> " + HttpUtility.HtmlEncode(doc.Asunto);

            int idAdj; string nombrePdf; int tamBytes;
            bool hayPdf = repo.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombrePdf, out tamBytes);
            litNombreArchivoTitulo.Text = HttpUtility.HtmlEncode(hayPdf && !string.IsNullOrEmpty(nombrePdf) ? nombrePdf : "(sin archivo)");
            ifrPdf.Visible = hayPdf;
            pnlSinPdf.Visible = !hayPdf;
            if (hayPdf) ifrPdf.Attributes["src"] = ResolveUrl("~/Presentacion/BandejaTrabajo/ServirPdf.ashx?idDoc=" + idDoc);

            litDetallesDoc.Text = ConstruirDetallesHtml(doc, tipoDesc, estadoDesc, tamBytes, hayPdf);
            litLineaTiempo.Text = ConstruirLineaTiempoHtml(repo.ObtenerLineaTiempoDocumento(idDoc));
        }

        private static string ObtenerEstadoDocumento(int idDoc, string connStr)
        {
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(@"SELECT m.Descripcion FROM Documento d INNER JOIN Maestro m ON d.IdEstadoDocumento = m.IdMaestro WHERE d.IdDocumento = @id", cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? o.ToString() : "-";
                }
            }
        }

        private static string ConstruirDetallesHtml(Documento doc, string tipoDesc, string estadoDesc, int tamBytes, bool hayPdf)
        {
            var sb = new StringBuilder();
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
            string txtRev = TextoPlazo(doc.FechaLimiteRevision);
            string txtFir = TextoPlazo(doc.FechaLimiteAprobacion);
            string clsRev = txtRev.IndexOf("fuera", StringComparison.OrdinalIgnoreCase) >= 0 ? "tiempo-vencido" : "tiempo-ok";
            string clsFir = txtFir.IndexOf("fuera", StringComparison.OrdinalIgnoreCase) >= 0 ? "tiempo-vencido" : "tiempo-ok";
            Row(sb, "Nombre / asunto", doc.Asunto);
            Row(sb, "Codigo del documento", doc.CodigoDocumento, true);
            Row(sb, "Tipo de documento", tipoDesc);
            Row(sb, "Estado actual", estadoDesc);
            Row(sb, "Prioridad", string.IsNullOrEmpty(doc.Prioridad) ? "-" : doc.Prioridad);
            Row(sb, "Registrado por", doc.LoginUsuarioRegistrador);
            Row(sb, "Fecha de registro", doc.FechaCreacion.ToString("g", pe));
            Row(sb, "Limite max. revision", doc.FechaLimiteRevision.ToString("g", pe) + " <span class=\"" + clsRev + "\">(" + HttpUtility.HtmlEncode(txtRev) + ")</span>", false, true);
            Row(sb, "Limite max. aprobacion / firma", doc.FechaLimiteAprobacion.ToString("g", pe) + " <span class=\"" + clsFir + "\">(" + HttpUtility.HtmlEncode(txtFir) + ")</span>", false, true);
            Row(sb, "Peso del archivo PDF", hayPdf ? FormatearTamano(tamBytes) : "—");
            return sb.ToString();
        }

        private static void Row(StringBuilder sb, string label, string value, bool mono = false, bool rawVal = false)
        {
            string cls = mono ? "val mono" : "val";
            sb.Append("<div class=\"det-row\"><span class=\"lbl\">").Append(HttpUtility.HtmlEncode(label)).Append("</span><span class=\"").Append(cls).Append("\">");
            if (rawVal) sb.Append(value ?? ""); else sb.Append(HttpUtility.HtmlEncode(value ?? ""));
            sb.Append("</span></div>");
        }

        private static string TextoPlazo(DateTime limite)
        {
            double h = (limite - DateTime.Now).TotalHours;
            return h >= 0 ? string.Format(CultureInfo.InvariantCulture, "{0} h restantes", Math.Ceiling(h))
                          : string.Format(CultureInfo.InvariantCulture, "{0} h fuera de limite", Math.Ceiling(Math.Abs(h)));
        }

        private static string FormatearTamano(int bytes)
        {
            if (bytes < 1024) return bytes + " B";
            if (bytes < 1048576) return (bytes / 1024.0).ToString("0.##", CultureInfo.InvariantCulture) + " KB";
            return (bytes / 1048576.0).ToString("0.##", CultureInfo.InvariantCulture) + " MB";
        }

        private static string ConstruirLineaTiempoHtml(System.Collections.Generic.List<LineaTiempoEvento> eventos)
        {
            if (eventos == null || eventos.Count == 0) return "<p style=\"color:#aaa;font-size:12px\">No hay eventos registrados.</p>";
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
            var sb = new StringBuilder();
            foreach (LineaTiempoEvento ev in eventos)
            {
                string css = string.IsNullOrEmpty(ev.TipoCss) ? "" : ev.TipoCss;
                sb.Append("<div class=\"tl-item ").Append(css).Append("\"><div class=\"tl-dot\"></div>");
                sb.Append("<div class=\"tl-time\">").Append(HttpUtility.HtmlEncode(ev.Fecha.ToString("g", pe))).Append("</div>");
                sb.Append("<div class=\"tl-title\">").Append(HttpUtility.HtmlEncode(ev.Titulo ?? "")).Append("</div>");
                sb.Append("<div class=\"tl-detail\">").Append(HttpUtility.HtmlEncode(ev.Detalle ?? "")).Append("</div></div>");
            }
            return sb.ToString();
        }

        private static int GetBadgeCount(SqlConnection cn)
        {
            using (var cmd = new SqlCommand("SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')", cn))
                return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private static string BuildNav(string rol, int badge)
        {
            string svgHome = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgHist = "<svg viewBox='0 0 24 24'><path d='M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z'/></svg>";
            string svgCarga = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string badgeHtml = "<span class='nav-badge'>" + badge + "</span>";
            
            if (rol == "FIR")
                return "<a href='../Firmante.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                       "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                       "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            else if (rol == "REV")
                return "<a href='../Revisor.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                       "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                       "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            else if (rol == "REG")
                return "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                       "<a href='../GestionDocumentos/CargarDocumento.aspx' class='nav-item'>" + svgCarga + "Cargar Documento</a>" +
                       "<a href='../GestionDocumentos/MisDocumentos.aspx' class='nav-item'>" + svgDocs + "Mis Documentos</a>";
            else
                return "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                       "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
