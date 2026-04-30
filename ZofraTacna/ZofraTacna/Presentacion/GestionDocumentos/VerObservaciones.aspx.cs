using System;
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
            litSidebarNav.Text = BuildNav();

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

        private string BuildNav()
        {
            string svgHome = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgCargar = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            return "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                   "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                   "<a href='MisDocumentos.aspx' class='nav-item active'>" + svgMisDocs + "Mis Documentos</a>";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear(); Session.Abandon(); Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
