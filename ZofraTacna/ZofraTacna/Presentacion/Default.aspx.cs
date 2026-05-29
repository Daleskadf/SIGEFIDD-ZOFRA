using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna
{
    public partial class Default : Page
    {
        private const int MaxTituloDocDashboard = 72;
        private const int MaxDetalleActividad = 220;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null)
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            if (!IsPostBack)
                CargarDashboard();
        }

        private void CargarDashboard()
        {
            string login = Session["LoginUsuario"].ToString();
            string rol = Session["RolNombre"].ToString();
            string rolCod = Session["RolCodigo"].ToString();

            string iniciales = login.Length >= 2
                ? login.Substring(0, 2).ToUpper()
                : login.ToUpper();

            litAvatar.Text = iniciales;
            litNombre.Text = login;
            litRol.Text = ZofraTacna.Helpers.RolSwitcherHelper.GenerarBadgeRolOSwitcher(Context, Session["RolCodigo"]?.ToString() ?? "", Session["RolNombre"]?.ToString() ?? "");
            litBienvenido.Text = login;

            pnlHerramientas.Visible = (rolCod == "ADM");

            CargarEstadisticas();

            var repo = new RepositorioDocumentos();
            litDocumentosRecientes.Text = RenderDocumentosRecientes(repo.ObtenerDocumentosRecientesDashboard(8));
            litActividadSistema.Text = RenderActividadSistema(repo.ObtenerActividadHistorialDashboard(12));
        }

        private string RenderDocumentosRecientes(List<DashboardDocReciente> docs)
        {
            if (docs == null || docs.Count == 0)
                return "<p style=\"font-size:13px;color:#999;padding:8px 0;\">No hay documentos registrados.</p>";

            var sb = new StringBuilder();
            string urlBase = ResolveUrl("~/Presentacion/BandejaTrabajo/VerDocumento.aspx?id=");
            string svgIcon = "<svg viewBox=\"0 0 24 24\"><path d=\"M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6z\"/></svg>";

            foreach (DashboardDocReciente d in docs)
            {
                string titulo = !string.IsNullOrWhiteSpace(d.Asunto) ? d.Asunto.Trim() : d.CodigoDocumento;
                if (titulo.Length > MaxTituloDocDashboard)
                    titulo = titulo.Substring(0, MaxTituloDocDashboard) + "\u2026";

                string meta = RelativizarFechaEs(d.FechaReferencia) + " \u00b7 Reg.: " + (d.LoginRegistrador ?? "");
                string badgeClass = CssBadgeEstadoDoc(d.EstadoCod);
                string estadoTxt = string.IsNullOrWhiteSpace(d.EstadoDesc) ? d.EstadoCod : d.EstadoDesc;
                string jsUrl = HttpUtility.JavaScriptStringEncode(urlBase + d.IdDocumento);

                sb.Append("<div class=\"doc-item\" style=\"cursor:pointer\" onclick=\"window.location.href=").Append(jsUrl).Append("\">");
                sb.Append("<div class=\"doc-icon\">").Append(svgIcon).Append("</div>");
                sb.Append("<div><div class=\"doc-name\">").Append(HttpUtility.HtmlEncode(titulo)).Append("</div>");
                sb.Append("<div class=\"doc-meta\">").Append(HttpUtility.HtmlEncode(meta)).Append("</div></div>");
                sb.Append("<span class=\"").Append(badgeClass).Append("\">").Append(HttpUtility.HtmlEncode(estadoTxt)).Append("</span>");
                sb.Append("</div>");
            }

            return sb.ToString();
        }

        private string RenderActividadSistema(List<DashboardActividadItem> items)
        {
            if (items == null || items.Count == 0)
                return "<p style=\"font-size:13px;color:#999;padding:8px 0;\">No hay movimientos recientes en el historial.</p>";

            var sb = new StringBuilder();

            foreach (DashboardActividadItem it in items)
            {
                string color = ColorDotActividad(it.EstadoCod);
                string texto = ConstruirTextoActividad(it);
                if (texto.Length > MaxDetalleActividad)
                    texto = texto.Substring(0, MaxDetalleActividad) + "\u2026";

                string tiempo = it.FechaCambio != DateTime.MinValue
                    ? RelativizarFechaEs(it.FechaCambio)
                    : "\u2014";

                sb.Append("<div class=\"act-item\">");
                sb.Append("<div class=\"act-dot\" style=\"background:").Append(color).Append(";\"></div>");
                sb.Append("<div><div class=\"act-text\">").Append(HttpUtility.HtmlEncode(texto)).Append("</div>");
                sb.Append("<div class=\"act-time\">").Append(HttpUtility.HtmlEncode(tiempo));
                if (!string.IsNullOrWhiteSpace(it.EstadoDesc))
                    sb.Append(" \u00b7 ").Append(HttpUtility.HtmlEncode(it.EstadoDesc));
                sb.Append("</div></div></div>");
            }

            return sb.ToString();
        }

        private static string ConstruirTextoActividad(DashboardActividadItem it)
        {
            if (!string.IsNullOrWhiteSpace(it.DetalleAccion))
                return it.DetalleAccion.Trim();

            string login = it.LoginUsuarioAccion ?? "";
            string est = it.EstadoDesc ?? it.EstadoCod ?? "";
            string doc = it.CodigoDocumento;
            if (!string.IsNullOrWhiteSpace(doc))
                return login + ": tr\u00e1mite " + doc + " \u2192 " + est;
            return login + ": actualizaci\u00f3n de estado \u2192 " + est;
        }

        private static string CssBadgeEstadoDoc(string cod)
        {
            if (string.IsNullOrEmpty(cod)) return "doc-status status-rev";
            string c = cod.Trim().ToUpperInvariant();
            if (c == "FCOM") return "doc-status status-comp";
            if (c == "PEN" || c == "FPAR" || c == "OBS") return "doc-status status-pend";
            return "doc-status status-rev";
        }

        private static string ColorDotActividad(string cod)
        {
            if (string.IsNullOrEmpty(cod)) return "#3b5bdb";
            string c = cod.Trim().ToUpperInvariant();
            if (c == "FCOM") return "#2e7d32";
            if (c == "OBS") return "#c0392b";
            if (c == "PEN" || c == "FPAR") return "#f59f00";
            if (c == "REV" || c == "REG") return "#3b5bdb";
            return "#6c757d";
        }

        private static string RelativizarFechaEs(DateTime fecha)
        {
            if (fecha == DateTime.MinValue) return "\u2014";
            DateTime ahora = DateTime.Now;
            double min = (ahora - fecha).TotalMinutes;
            if (min < 1.5) return "Hace un momento";
            if (min < 60) return "Hace " + (int)Math.Floor(min) + " min";
            double h = (ahora - fecha).TotalHours;
            if (h < 24) return "Hace " + (int)Math.Floor(h) + " h";
            double d = (ahora - fecha).TotalDays;
            if (d < 7) return "Hace " + (int)Math.Floor(d) + " d\u00edas";
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
            return fecha.ToString("g", pe);
        }

        private void CargarEstadisticas()
        {
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                litTotal.Text = ContarQuery(conn, "SELECT COUNT(*) FROM Documento WHERE Activo=1");
                litPendientes.Text = ContarQuery(conn,
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE m.Codigo IN ('PEN','FPAR') AND d.Activo=1");
                litCompletados.Text = ContarQuery(conn,
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE m.Codigo='FCOM' AND d.Activo=1");
                litUsuarios.Text = ContarQuery(conn, "SELECT COUNT(*) FROM UsuarioSistema WHERE Activo=1");

                badgeBandeja.InnerText = ContarQuery(conn,
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')");
            }
        }

        private string ContarQuery(SqlConnection conn, string sql)
        {
            using (var cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar().ToString();
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
