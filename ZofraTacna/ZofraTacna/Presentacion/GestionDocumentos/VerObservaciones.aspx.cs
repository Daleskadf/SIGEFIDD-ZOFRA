using System;
using System.Configuration;
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
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "REG" && rol != "ADM") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            int id;
            if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0) { Response.Redirect("MisDocumentos.aspx"); return; }

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
                ifrPdf.Attributes["src"] = ResolveUrl("~/Presentacion/BandejaTrabajo/ServirPdf.ashx?idDoc=" + id);
            }

            var obs = repo.ObtenerObservacionesDocumento(id);
            if (obs.Count == 0) litObservaciones.Text = "<div class='obs-item'>No hay observaciones registradas.</div>";
            else
            {
                var sb = new StringBuilder();
                foreach (string o in obs) sb.Append("<div class='obs-item'>").Append(HttpUtility.HtmlEncode(o)).Append("</div>");
                litObservaciones.Text = sb.ToString();
            }
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
                "<a href='../../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
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
