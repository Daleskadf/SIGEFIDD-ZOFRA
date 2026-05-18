using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class EmitirRevision : Page
    {
        private readonly RepositorioBloqueoFlujo _repoBloqueo = new RepositorioBloqueoFlujo();
        private int IdDocumentoActual
        {
            get { return ViewState["IdDocumentoActual"] != null ? Convert.ToInt32(ViewState["IdDocumentoActual"]) : 0; }
            set { ViewState["IdDocumentoActual"] = value; }
        }
        protected string LockToken
        {
            get { return (ViewState["LockToken"] as string) ?? ""; }
        }
        protected bool ModoBloqueado
        {
            get { return ViewState["ModoBloqueado"] != null && (bool)ViewState["ModoBloqueado"]; }
            set { ViewState["ModoBloqueado"] = value; }
        }
        protected string MensajeBloqueo
        {
            get { return (ViewState["MensajeBloqueo"] as string) ?? ""; }
            set { ViewState["MensajeBloqueo"] = value; }
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

        /// <summary>Vista dividida con dos PDFs (solo tras pulsar Comparar documento).</summary>
        private bool ModoComparacionActivo
        {
            get { return ViewState["ModoCmpAct"] != null && (bool)ViewState["ModoCmpAct"]; }
            set { ViewState["ModoCmpAct"] = value; }
        }

        /// <summary>IdAdjunto para panel izquierdo; 0 = PDF vigente (sin idAdj en el handler).</summary>
        private int CmpAdjIzq
        {
            get { return ViewState["CmpAdjIzq"] != null ? Convert.ToInt32(ViewState["CmpAdjIzq"], CultureInfo.InvariantCulture) : 0; }
            set { ViewState["CmpAdjIzq"] = value; }
        }

        /// <summary>IdAdjunto para panel derecho; 0 = vigente.</summary>
        private int CmpAdjDer
        {
            get { return ViewState["CmpAdjDer"] != null ? Convert.ToInt32(ViewState["CmpAdjDer"], CultureInfo.InvariantCulture) : 0; }
            set { ViewState["CmpAdjDer"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "REV" && rol != "ADM") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }

            int idDoc;
            if (!int.TryParse(Request.QueryString["id"], out idDoc) || idDoc <= 0)
            {
                Response.Redirect("BandejaTrabajo.aspx");
                return;
            }

            if (!IsPostBack)
                ViewState["LockToken"] = Guid.NewGuid().ToString("N");

            IdDocumentoActual = idDoc;
            string login = Session["LoginUsuario"].ToString();
            if (_repoBloqueo.ExisteBloqueoActivo(idDoc, "REG_EDIT", ""))
            {
                ModoBloqueado = true;
                MensajeBloqueo = "El registador se encuentra editando el documento";
                return;
            }
            if (_repoBloqueo.ExisteBloqueoActivo(idDoc, "ADM_EDIT", ""))
            {
                ModoBloqueado = true;
                MensajeBloqueo = "El administrador se encuentra modificando el documento";
                return;
            }

            ModoBloqueado = false;
            MensajeBloqueo = "";
            _repoBloqueo.RegistrarOTocarBloqueo(idDoc, "REV_EDIT", login, LockToken);
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            if (ModoBloqueado || Session["LoginUsuario"] == null) return;
            int idDoc = IdDocumentoActual;
            if (idDoc <= 0) return;
            string rol = Session["RolCodigo"] != null ? Session["RolCodigo"].ToString() : "";
            CargarVista(idDoc, rol);
        }

        protected void btnCompararDocumento_Click(object sender, EventArgs e)
        {
            ModoComparacionActivo = true;
            var repo = new RepositorioDocumentos();
            List<AdjuntoArchivadoInfo> arch = repo.ObtenerAdjuntosArchivados(IdDocumentoActual);
            if (arch != null && arch.Count > 0)
            {
                CmpAdjIzq = arch[0].IdAdjunto;
                CmpAdjDer = 0;
            }
            else
            {
                CmpAdjIzq = 0;
                CmpAdjDer = 0;
                ModoComparacionActivo = false;
            }
        }

        protected void btnCerrarComparacion_Click(object sender, EventArgs e)
        {
            ModoComparacionActivo = false;
        }

        protected void ddlPdfCompareIzq_SelectedIndexChanged(object sender, EventArgs e)
        {
            int v;
            int.TryParse(ddlPdfCompareIzq.SelectedValue, NumberStyles.Integer, CultureInfo.InvariantCulture, out v);
            CmpAdjIzq = v < 0 ? 0 : v;
        }

        protected void ddlPdfCompareDer_SelectedIndexChanged(object sender, EventArgs e)
        {
            int v;
            int.TryParse(ddlPdfCompareDer.SelectedValue, NumberStyles.Integer, CultureInfo.InvariantCulture, out v);
            CmpAdjDer = v < 0 ? 0 : v;
        }

        protected void btnEmitirConformidad_Click(object sender, EventArgs e)
        {
            GuardarDecisionRevision(false);
        }

        protected void btnEmitirObservacion_Click(object sender, EventArgs e)
        {
            GuardarDecisionRevision(true);
        }

        private void GuardarDecisionRevision(bool esObservacion)
        {
            int idDoc = IdDocumentoActual > 0 ? IdDocumentoActual : 0;
            if (idDoc <= 0) { Response.Redirect("BandejaTrabajo.aspx"); return; }

            string login = Session["LoginUsuario"] != null ? Session["LoginUsuario"].ToString() : "";
            string rol = Session["RolCodigo"] != null ? Session["RolCodigo"].ToString() : "";

            var repo = new RepositorioDocumentos();
            string mensaje;
            string comentario = esObservacion
                ? (txtObservaciones.Text ?? "").Trim()
                : "Revisor emitio conformidad desde visor.";
            if (esObservacion)
            {
                if (repo.ExisteTablaDocumentoObservacionMarcador())
                {
                    int borradores = repo.ContarMarcadoresBorrador(idDoc, login);
                    if (borradores == 0 && string.IsNullOrWhiteSpace(comentario))
                    {
                        pnlMensajeOk.Visible = false;
                        litMensajeError.Text = "Debe colocar al menos un marcador en el PDF o escribir un comentario general.";
                        pnlMensajeError.Visible = true;
                        return;
                    }
                    repo.PublicarMarcadoresBorrador(idDoc, login);
                    string resumenMarcadores = repo.ConstruirResumenMarcadoresPublicados(idDoc, login);
                    if (!string.IsNullOrWhiteSpace(resumenMarcadores))
                    {
                        comentario = string.IsNullOrWhiteSpace(comentario)
                            ? resumenMarcadores
                            : resumenMarcadores + Environment.NewLine + Environment.NewLine + comentario.Trim();
                    }
                }
                else if (string.IsNullOrWhiteSpace(comentario))
                {
                    pnlMensajeOk.Visible = false;
                    litMensajeError.Text = "Debe ingresar una observacion para continuar.";
                    pnlMensajeError.Visible = true;
                    return;
                }
            }

            bool ok = repo.RegistrarDecisionRevision(idDoc, login, comentario, esObservacion, out mensaje);
            pnlMensajeOk.Visible = false;
            pnlMensajeError.Visible = false;
            if (ok)
            {
                _repoBloqueo.LiberarBloqueo(idDoc, "REV_EDIT", LockToken);
                litMensajeOk.Text = HttpUtility.HtmlEncode(mensaje);
                pnlMensajeOk.Visible = true;
                if (!esObservacion)
                {
                    Response.Redirect("BandejaTrabajo.aspx");
                    return;
                }
                Response.Redirect("BandejaTrabajo.aspx");
                return;
            }
            else
            {
                litMensajeError.Text = HttpUtility.HtmlEncode(mensaje);
                pnlMensajeError.Visible = true;
            }
        }

        private void CargarVista(int idDoc, string rol)
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text = Session["RolNombre"] != null ? Session["RolNombre"].ToString() : "";

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                int badge = GetBadgeCount(cn);
                litSidebarNav.Text = BuildNav(rol, badge);
            }

            var repo = new RepositorioDocumentos();
            Documento doc = repo.ObtenerDocumentoPorId(idDoc);
            if (doc == null)
            {
                Response.Redirect("BandejaTrabajo.aspx");
                return;
            }

            string tipoDesc = repo.ObtenerDescripcionTipoDocumento(doc.IdTipoDocumento);
            string estadoDesc = ObtenerEstadoDocumento(idDoc, connStr);

            litSubtituloDoc.Text = "<span class='doc-code'>" + HttpUtility.HtmlEncode(doc.CodigoDocumento) +
                                   "</span> " + HttpUtility.HtmlEncode(doc.Asunto);

            int idAdj;
            string nombrePdf;
            int tamBytes;
            bool hayPdf = repo.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombrePdf, out tamBytes);
            List<AdjuntoArchivadoInfo> archivados = repo.ObtenerAdjuntosArchivados(idDoc);
            bool puedeComparar = hayPdf && archivados != null && archivados.Count > 0;
            if (!puedeComparar)
                ModoComparacionActivo = false;
            bool modoComparar = puedeComparar && ModoComparacionActivo;

            if (modoComparar && archivados != null)
            {
                var idsValidos = new HashSet<int> { 0 };
                foreach (AdjuntoArchivadoInfo a in archivados)
                    idsValidos.Add(a.IdAdjunto);
                if (!idsValidos.Contains(CmpAdjIzq)) CmpAdjIzq = archivados.Count > 0 ? archivados[0].IdAdjunto : 0;
                if (!idsValidos.Contains(CmpAdjDer)) CmpAdjDer = 0;
            }
            else if (!modoComparar)
            {
                CmpAdjIzq = 0;
                CmpAdjDer = 0;
            }

            divEmitShell.Attributes["class"] = modoComparar ? "emitir-wrap emitir-wrap--compare" : "emitir-wrap";
            divContentArea.Attributes["class"] = modoComparar ? "content content--compare-pdf" : "content";

            string nombreMostrar = hayPdf && !string.IsNullOrEmpty(nombrePdf) ? nombrePdf : "(sin archivo)";
            litNombreArchivoTitulo.Text = modoComparar
                ? HttpUtility.HtmlEncode("Comparaci\u00F3n de versiones")
                : HttpUtility.HtmlEncode(nombreMostrar);

            btnCompararDocumento.Visible = puedeComparar && !modoComparar;
            btnCerrarComparacion.Visible = modoComparar;
            pnlBannerComparacion.Visible = modoComparar;
            pnlVistaPdfComparar.Visible = modoComparar;
            pnlVistaPdfSimple.Visible = !modoComparar;

            string basePdf = ResolveUrl("~/Presentacion/BandejaTrabajo/ServirPdf.ashx?idDoc=" + idDoc);

            if (modoComparar)
            {
                UsarVisorMarcadoresPdf = false;
                PdfUrlVisorJs = "";
                CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
                LlenarComboVersiones(ddlPdfCompareIzq, archivados, nombrePdf, pe);
                LlenarComboVersiones(ddlPdfCompareDer, archivados, nombrePdf, pe);
                SeleccionarValorCombo(ddlPdfCompareIzq, CmpAdjIzq);
                SeleccionarValorCombo(ddlPdfCompareDer, CmpAdjDer);

                string urlIzq = CmpAdjIzq > 0 ? basePdf + "&idAdj=" + CmpAdjIzq : basePdf;
                string urlDer = CmpAdjDer > 0 ? basePdf + "&idAdj=" + CmpAdjDer : basePdf;
                lnkPdfIzqNuevaPestana.NavigateUrl = urlIzq;
                lnkPdfDerNuevaPestana.NavigateUrl = urlDer;
                ifrPdfAnterior.Visible = true;
                    ifrPdfAnterior.Attributes["src"] = urlIzq;
                ifrPdfActualCompare.Visible = true;
                    ifrPdfActualCompare.Attributes["src"] = urlDer;
                ifrPdf.Visible = false;
                pnlSinPdf.Visible = false;
                pnlVistaPdfComparar.CssClass = "pdf-compare-grid";
            }
            else if (hayPdf)
            {
                lnkPdfIzqNuevaPestana.NavigateUrl = "";
                lnkPdfDerNuevaPestana.NavigateUrl = "";
                UsarVisorMarcadoresPdf = repo.ExisteTablaDocumentoObservacionMarcador();
                PdfUrlVisorJs = UsarVisorMarcadoresPdf ? basePdf : "";
                if (UsarVisorMarcadoresPdf)
                {
                    ifrPdf.Visible = false;
                    ifrPdf.Attributes["src"] = "";
                }
                else
                {
                    ifrPdf.Visible = true;
                    ifrPdf.Attributes["src"] = basePdf;
                }
                pnlSinPdf.Visible = false;
            }
            else
            {
                lnkPdfIzqNuevaPestana.NavigateUrl = "";
                lnkPdfDerNuevaPestana.NavigateUrl = "";
                UsarVisorMarcadoresPdf = false;
                PdfUrlVisorJs = "";
                ifrPdf.Visible = false;
                pnlSinPdf.Visible = true;
            }

            litDetallesDoc.Text = ConstruirDetallesHtml(doc, tipoDesc, estadoDesc, tamBytes, hayPdf, modoComparar);
            litLineaTiempo.Text = ConstruirLineaTiempoHtml(repo.ObtenerLineaTiempoDocumento(idDoc));
        }

        private static string ObtenerEstadoDocumento(int idDoc, string connStr)
        {
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(
                           @"SELECT m.Descripcion FROM Documento d
                             INNER JOIN Maestro m ON d.IdEstadoDocumento = m.IdMaestro
                             WHERE d.IdDocumento = @id", cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? o.ToString() : "-";
                }
            }
        }

        private static string ConstruirDetallesHtml(Documento doc, string tipoDesc, string estadoDesc, int tamBytes, bool hayPdf, bool gridDosColumnas)
        {
            var sb = new StringBuilder();
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");

            string pri = string.IsNullOrEmpty(doc.Prioridad) ? "-" : doc.Prioridad;
            DateTime maxRev = doc.FechaLimiteRevision;
            DateTime maxFir = doc.FechaLimiteAprobacion;
            string txtRev = TextoPlazo(maxRev);
            string txtFir = TextoPlazo(maxFir);
            string clsRev = txtRev.IndexOf("fuera", StringComparison.OrdinalIgnoreCase) >= 0 ? "tiempo-vencido" : "tiempo-ok";
            string clsFir = txtFir.IndexOf("fuera", StringComparison.OrdinalIgnoreCase) >= 0 ? "tiempo-vencido" : "tiempo-ok";
            string peso = hayPdf ? FormatearTamano(tamBytes) : "—";

            sb.Append(gridDosColumnas
                ? "<div class=\"det-grid det-grid--2col\">"
                : "<div class=\"det-grid\">");
            Row(sb, "Nombre / asunto", doc.Asunto, false, false, true);
            Row(sb, "C\u00F3digo del documento", doc.CodigoDocumento, true);
            Row(sb, "Tipo de documento", tipoDesc);
            Row(sb, "Estado actual", estadoDesc);
            Row(sb, "Prioridad", pri);
            Row(sb, "Registrado por", doc.LoginUsuarioRegistrador);
            Row(sb, "Fecha de registro", doc.FechaCreacion.ToString("g", pe));
            Row(sb, "L\u00EDmite m\u00E1x. revisi\u00F3n", maxRev.ToString("g", pe) + " <span class=\"" + clsRev + "\">(" + HttpUtility.HtmlEncode(txtRev) + ")</span>", false, true, true);
            Row(sb, "L\u00EDmite m\u00E1x. aprobaci\u00F3n / firma", maxFir.ToString("g", pe) + " <span class=\"" + clsFir + "\">(" + HttpUtility.HtmlEncode(txtFir) + ")</span>", false, true, true);
            Row(sb, "Peso del archivo PDF", peso, false, false, true);
            sb.Append("</div>");
            return sb.ToString();
        }

        private static void Row(StringBuilder sb, string label, string value, bool mono = false, bool rawVal = false, bool spanFull = false)
        {
            string cls = mono ? "val mono" : "val";
            string rowClass = spanFull ? "det-row det-row--full" : "det-row";
            sb.Append("<div class=\"").Append(rowClass).Append("\"><span class=\"lbl\">").Append(HttpUtility.HtmlEncode(label)).Append("</span><span class=\"").Append(cls).Append("\">");
            if (rawVal) sb.Append(value ?? "");
            else sb.Append(HttpUtility.HtmlEncode(value ?? ""));
            sb.Append("</span></div>");
        }

        private static string TextoPlazo(DateTime limite)
        {
            TimeSpan ts = limite - DateTime.Now;
            double h = ts.TotalHours;
            if (h >= 0)
                return string.Format(CultureInfo.InvariantCulture, "{0} h restantes", Math.Ceiling(h));
            return string.Format(CultureInfo.InvariantCulture, "{0} h fuera de l\u00EDmite", Math.Ceiling(Math.Abs(h)));
        }

        private static string FormatearTamano(int bytes)
        {
            if (bytes < 1024) return bytes + " B";
            if (bytes < 1048576) return (bytes / 1024.0).ToString("0.##", CultureInfo.InvariantCulture) + " KB";
            return (bytes / 1048576.0).ToString("0.##", CultureInfo.InvariantCulture) + " MB";
        }

        private static void LlenarComboVersiones(DropDownList ddl, List<AdjuntoArchivadoInfo> archivados, string nombrePdfVigente, CultureInfo pe)
        {
            ddl.Items.Clear();
            string vig = string.IsNullOrEmpty(nombrePdfVigente) ? "documento.pdf" : nombrePdfVigente;
            ddl.Items.Add(new ListItem("Vigente (actual) — " + vig, "0"));
            if (archivados == null) return;
            foreach (AdjuntoArchivadoInfo a in archivados)
            {
                string fecha = a.FechaSuperacion.HasValue ? a.FechaSuperacion.Value.ToString("g", pe) : a.FechaCreacion.ToString("g", pe);
                string nom = string.IsNullOrEmpty(a.NombreArchivo) ? "archivo.pdf" : a.NombreArchivo;
                ddl.Items.Add(new ListItem(
                    "Archivado (" + fecha + ") — " + nom,
                    a.IdAdjunto.ToString(CultureInfo.InvariantCulture)));
            }
        }

        private static void SeleccionarValorCombo(DropDownList ddl, int idAdjunto)
        {
            string val = idAdjunto.ToString(CultureInfo.InvariantCulture);
            ListItem it = ddl.Items.FindByValue(val);
            if (it != null)
            {
                ddl.ClearSelection();
                it.Selected = true;
            }
            else if (ddl.Items.Count > 0)
                ddl.SelectedIndex = 0;
        }

        private static string ConstruirLineaTiempoHtml(System.Collections.Generic.List<LineaTiempoEvento> eventos)
        {
            if (eventos == null || eventos.Count == 0)
                return "<p style=\"color:#aaa;font-size:12px\">No hay eventos registrados.</p>";

            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
            var sb = new StringBuilder();
            foreach (LineaTiempoEvento ev in eventos)
            {
                string css = string.IsNullOrEmpty(ev.TipoCss) ? "" : ev.TipoCss;
                sb.Append("<div class=\"tl-item ").Append(css).Append("\">");
                sb.Append("<div class=\"tl-dot\"></div>");
                sb.Append("<div class=\"tl-time\">").Append(HttpUtility.HtmlEncode(ev.Fecha.ToString("g", pe))).Append("</div>");
                sb.Append("<div class=\"tl-title\">").Append(HttpUtility.HtmlEncode(ev.Titulo ?? "")).Append("</div>");
                sb.Append("<div class=\"tl-detail\">").Append(HttpUtility.HtmlEncode(ev.Detalle ?? "")).Append("</div>");
                sb.Append("</div>");
            }
            return sb.ToString();
        }

        private static int GetBadgeCount(SqlConnection cn)
        {
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')", cn))
                return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private static string BuildNav(string rol, int badge)
        {
            string svgHome = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgCargar = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgRoles = "<svg viewBox='0 0 24 24'><path d='M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z'/></svg>";
            string svgFirm = "<svg viewBox='0 0 24 24'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>";
            string svgEstado = "<svg viewBox='0 0 24 24'><path d='M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z'/></svg>";
            string svgHist = "<svg viewBox='0 0 24 24'><path d='M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z'/></svg>";

            string badgeHtml = "<span class='nav-badge'>" + badge + "</span>";

            if (rol == "REV")
            {
                return
                    "<a href='../Revisor.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            }
            if (rol == "FIR")
            {
                return
                    "<a href='../Firmante.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            }
            return
                "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                "<a href='../GestionDocumentos/CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                "<a href='../GestionDocumentos/MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>" +
                "<a href='../GestionRoles/GestionRoles.aspx' class='nav-item'>" + svgRoles + "Gesti&oacute;n de Roles</a>" +
                "<a href='../VisualizarFirmantes/VisualizarFirmantes.aspx' class='nav-item'>" + svgFirm + "Visualizar Firmantes</a>" +
                "<a href='#' class='nav-item'>" + svgEstado + "Estado del Sistema</a>";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
