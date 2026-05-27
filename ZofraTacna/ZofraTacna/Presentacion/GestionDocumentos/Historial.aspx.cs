using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class Historial : Page
    {
        private string FiltroActivo
        {
            get { return (ViewState["FiltroActivo"] as string) ?? "TODOS"; }
            set { ViewState["FiltroActivo"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "REV" && rol != "ADM" && rol != "FIR") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }

            if (!IsPostBack) { FiltroActivo = "TODOS"; CargarDatos(); }
            ActualizarTabsUI();
        }

        private void ActualizarTabsUI()
        {
            string f = FiltroActivo;
            lbTodos.CssClass      = f == "TODOS" ? "tab-btn tab-active" : "tab-btn";
            lbPendiente.CssClass  = f == "PEN"   ? "tab-btn tab-active" : "tab-btn";
            lbRevision.CssClass   = f == "REV"   ? "tab-btn tab-active" : "tab-btn";
            lbFirma.CssClass      = f == "FPAR"  ? "tab-btn tab-active" : "tab-btn";
            lbCompletado.CssClass = f == "FCOM"  ? "tab-btn tab-active" : "tab-btn";
        }

        protected void lbTodos_Click(object sender, EventArgs e)      { FiltroActivo = "TODOS"; CargarDatos(); ActualizarTabsUI(); }
        protected void lbPendiente_Click(object sender, EventArgs e)  { FiltroActivo = "PEN";   CargarDatos(); ActualizarTabsUI(); }
        protected void lbRevision_Click(object sender, EventArgs e)   { FiltroActivo = "REV";   CargarDatos(); ActualizarTabsUI(); }
        protected void lbFirma_Click(object sender, EventArgs e)      { FiltroActivo = "FPAR";  CargarDatos(); ActualizarTabsUI(); }
        protected void lbCompletado_Click(object sender, EventArgs e) { FiltroActivo = "FCOM";  CargarDatos(); ActualizarTabsUI(); }

        private void CargarDatos()
        {
            string login = Session["LoginUsuario"].ToString();
            string rol   = Session["RolCodigo"].ToString();

            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"] != null ? Session["RolNombre"].ToString() : "";

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            var lista = new List<object>();
            DateTime ahora = DateTime.Now;

            string filtroEst = FiltroActivo == "TODOS" ? "" : " AND me.Codigo = @filtro";
            bool esAdm = string.Equals(rol, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtroVis = esAdm
                ? ""
                : @" AND (d.LoginUsuarioRegistrador = @login
                    OR EXISTS (
                        SELECT 1 FROM dbo.DocumentoParticipante p
                        WHERE p.IdDocumento = d.IdDocumento AND p.LoginUsuario = @login
                    ))";

            string sql = @"SELECT d.CodigoDocumento, d.IdDocumento, d.Asunto, mc.Descripcion AS AreaCategoria, d.RutaArchivoPDF,
                                  d.FechaCreacion, d.FechaLimiteRevision, d.FechaLimiteAprobacion,
                                  me.Descripcion AS EstadoDesc, me.Codigo AS EstadoCodigo
                           FROM Documento d
                           JOIN Maestro me ON d.IdEstadoDocumento = me.IdMaestro
                           LEFT JOIN Maestro mc ON d.IdTipoDocumento = mc.IdMaestro
                           WHERE d.Activo = 1" + filtroEst + filtroVis + @"
                           ORDER BY d.FechaCreacion DESC";

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                int badge = GetBadgeCount(cn, login, rol);
                litSidebarNav.Text = BuildNav(rol, badge);

                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (!esAdm)
                        cmd.Parameters.AddWithValue("@login", login);
                    if (FiltroActivo != "TODOS") cmd.Parameters.AddWithValue("@filtro", FiltroActivo);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string est  = dr["EstadoCodigo"].ToString().ToUpper();
                            string ruta = dr["RutaArchivoPDF"] == DBNull.Value ? "" : dr["RutaArchivoPDF"].ToString();
                            string badgeCss;
                            switch (est)
                            {
                                case "PEN": case "FPAR": badgeCss = "badge-pen";  break;
                                case "REV":              badgeCss = "badge-rev";  break;
                                case "FCOM":             badgeCss = "badge-fcom"; break;
                                case "OBS":              badgeCss = "badge-obs";  break;
                                default:                 badgeCss = "badge-reg";  break;
                            }
                            lista.Add(new
                            {
                                CodigoDocumento = dr["CodigoDocumento"] == DBNull.Value ? "-" : dr["CodigoDocumento"].ToString(),
                                IdDocumento   = Convert.ToInt32(dr["IdDocumento"]),
                                Asunto        = dr["Asunto"].ToString(),
                                NombreArchivo = Path.GetFileName(ruta),
                                AreaCategoria = dr["AreaCategoria"] == DBNull.Value ? "-" : dr["AreaCategoria"].ToString(),
                                EstadoDesc    = dr["EstadoDesc"].ToString(),
                                BadgeCss      = badgeCss,
                                PlazosHtml    = BuildPlazos(dr, ahora),
                                FechaStr      = Convert.ToDateTime(dr["FechaCreacion"]).ToString("d/M/yyyy")
                            });
                        }
                    }
                }
            }

            pnlEmpty.Visible   = lista.Count == 0;
            pnlTable.Visible   = lista.Count > 0;
            rptDocs.DataSource = lista;
            rptDocs.DataBind();
        }

        private string BuildPlazos(SqlDataReader dr, DateTime ahora)
        {
            string html = "";
            if (dr["FechaLimiteRevision"] != DBNull.Value)
            {
                DateTime lim   = Convert.ToDateTime(dr["FechaLimiteRevision"]);
                double   horas = (lim - ahora).TotalHours;
                if (lim < ahora)
                    html += string.Format("<span class='plazo-vencido'>&#9888; Revisi&oacute;n: Vencido ({0:0}h)</span>", Math.Abs(horas));
                else if (horas <= 24)
                    html += string.Format("<span class='plazo-warn'>&#9200; Revisi&oacute;n: {0:0}h restantes</span>", horas);
                else
                    html += string.Format("<span class='plazo-ok'>Revisi&oacute;n: {0:0}h restantes</span>", horas);
            }
            if (dr["FechaLimiteAprobacion"] != DBNull.Value)
            {
                DateTime lim   = Convert.ToDateTime(dr["FechaLimiteAprobacion"]);
                double   horas = (lim - ahora).TotalHours;
                if (!string.IsNullOrEmpty(html)) html += "<br/>";
                if (lim < ahora)
                    html += string.Format("<span class='plazo-vencido'>&#9888; Firma: Vencido ({0:0}h)</span>", Math.Abs(horas));
                else if (horas <= 24)
                    html += string.Format("<span class='plazo-warn'>&#9200; Firma: {0:0}h restantes</span>", horas);
                else
                    html += string.Format("<span class='plazo-ok'>Firma: {0:0}h restantes</span>", horas);
            }
            return string.IsNullOrEmpty(html) ? "<span class='plazo-ok'>-</span>" : html;
        }

        private int GetBadgeCount(SqlConnection cn, string login, string rol)
        {
            bool esAdm = string.Equals(rol, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtroVis = esAdm
                ? ""
                : @" AND (d.LoginUsuarioRegistrador = @login
                    OR EXISTS (
                        SELECT 1 FROM dbo.DocumentoParticipante p
                        WHERE p.IdDocumento = d.IdDocumento AND p.LoginUsuario = @login
                    ))";
            string sql = "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')" + filtroVis;
            using (var cmd = new SqlCommand(sql, cn))
            {
                if (!esAdm)
                    cmd.Parameters.AddWithValue("@login", login);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private string BuildNav(string rol, int badge)
        {
            string svgHome    = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgCarga   = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgHist    = "<svg viewBox='0 0 24 24'><path d='M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z'/></svg>";
            string badgeHtml  = "<span class='nav-badge'>" + badge + "</span>";

            if (rol == "FIR")
                return
                    "<a href='../Firmante.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='../BandejaTrabajo/BandejaTrabajo.aspx' class='nav-item'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='Historial.aspx' class='nav-item active'>" + svgHist + "Historial</a>";
            else if (rol == "REV")
                return
                    "<a href='../Revisor.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='../BandejaTrabajo/BandejaTrabajo.aspx' class='nav-item'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='Historial.aspx' class='nav-item active'>" + svgHist + "Historial</a>";
            else if (rol == "REG")
                return
                    "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCarga + "Cargar Documento</a>" +
                    "<a href='MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>";
            else
                return
                    "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='../BandejaTrabajo/BandejaTrabajo.aspx' class='nav-item'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='Historial.aspx' class='nav-item active'>" + svgHist + "Historial</a>";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        { Session.Clear(); Session.Abandon(); Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); }
    }
}
