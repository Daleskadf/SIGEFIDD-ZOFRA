using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using ZofraTacna.Datos;
using ZofraTacna.LogicaNegocio;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class EditarDocumento : Page
    {
        private readonly RepositorioDocumentos _repo = new RepositorioDocumentos();
        private readonly ModuloGestionDocumental _modulo = new ModuloGestionDocumental();

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

            if (!IsPostBack)
            {
                CargarCombos();
                CargarDocumento(id);
            }
        }

        private void CargarCombos()
        {
            var categorias = _modulo.ObtenerCategorias();
            ddlCategoria.Items.Clear();
            foreach (var cat in categorias)
            {
                string[] partes = cat.Split('|');
                ddlCategoria.Items.Add(new System.Web.UI.WebControls.ListItem(partes[1], partes[0]));
            }
        }

        private void CargarDocumento(int id)
        {
            Documento d = _repo.ObtenerDocumentoPorId(id);
            if (d == null) { Response.Redirect("MisDocumentos.aspx"); return; }
            string[] p = (d.CodigoDocumento ?? "").Split('-');
            txtCodigoDoc.Text = p.Length > 0 ? p[0] : "";
            txtNumeroDoc.Text = p.Length > 1 ? p[1] : "";
            txtAnoDoc.Text = p.Length > 2 ? p[2] : DateTime.Now.Year.ToString();
            txtAsunto.Text = d.Asunto;
            txtDescripcion.Text = d.Descripcion;
            if (ddlCategoria.Items.FindByValue(d.IdTipoDocumento.ToString()) != null) ddlCategoria.SelectedValue = d.IdTipoDocumento.ToString();
            if (ddlPrioridad.Items.FindByValue(d.Prioridad) != null) ddlPrioridad.SelectedValue = d.Prioridad;
            txtPlazoRevision.Text = Math.Max(1, (int)Math.Ceiling((d.FechaLimiteRevision - DateTime.Now).TotalHours)).ToString();
            txtPlazoFirma.Text = Math.Max(1, (int)Math.Ceiling((d.FechaLimiteAprobacion - DateTime.Now).TotalHours)).ToString();

            List<string> obs = _repo.ObtenerObservacionesDocumento(id);
            if (obs.Count == 0) litObservaciones.Text = "<div class='obs-item'>No hay observaciones registradas.</div>";
            else
            {
                var html = new System.Text.StringBuilder();
                foreach (string o in obs) html.Append("<div class='obs-item'>").Append(HttpUtility.HtmlEncode(o)).Append("</div>");
                litObservaciones.Text = html.ToString();
            }
        }

        protected void btnEnviarCorreccion_Click(object sender, EventArgs e)
        {
            int id;
            if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0) return;
            int horasRev = 24, horasFirma = 48; int.TryParse(txtPlazoRevision.Text, out horasRev); int.TryParse(txtPlazoFirma.Text, out horasFirma);
            byte[] pdf = null; string nom = null;
            if (filePDF.HasFile)
            {
                if (Path.GetExtension(filePDF.FileName).ToLower() != ".pdf") { Mostrar("Solo PDF", false); return; }
                using (BinaryReader br = new BinaryReader(filePDF.PostedFile.InputStream)) pdf = br.ReadBytes(filePDF.PostedFile.ContentLength);
                nom = DateTime.Now.ToString("yyyyMMddHHmmss") + "_" + Path.GetFileName(filePDF.FileName);
            }
            string cod = (txtCodigoDoc.Text.Trim().ToUpper()) + "-" + txtNumeroDoc.Text.Trim().PadLeft(4,'0') + "-" + txtAnoDoc.Text.Trim();
            string msg;
            bool ok = _repo.ActualizarDocumentoCorregido(id, cod, txtAsunto.Text.Trim(), txtDescripcion.Text.Trim(), int.Parse(ddlCategoria.SelectedValue), ddlPrioridad.SelectedValue, horasRev, horasFirma, pdf, nom, Session["LoginUsuario"].ToString(), out msg);
            Mostrar(msg, ok);
            if (ok) Response.Redirect("MisDocumentos.aspx");
        }

        private string BuildNav()
        {
            string svgHome = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgCargar = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            return "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                   "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                   "<a href='MisDocumentos.aspx' class='nav-item active'>" + svgMisDocs + "Mis Documentos</a>";
        }

        private void Mostrar(string msg, bool ok)
        {
            lblMensaje.Text = msg;
            lblMensaje.CssClass = ok ? "alert-ok" : "alert-err";
            lblMensaje.Visible = true;
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear(); Session.Abandon(); Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
