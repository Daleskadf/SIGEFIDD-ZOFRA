using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class MisDocumentos : Page
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
            if (rol != "ADM" && rol != "REG") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }

            if (!IsPostBack)
            {
                FiltroActivo = "TODOS";
                CargarDatos();
            }
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
            litSidebarNav.Text = BuildNav(rol);

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            var lista = new List<object>();
            DateTime ahora = DateTime.Now;

            // REG solo ve sus propios documentos; ADM ve todos
            string filtroRol = rol == "REG" ? " AND d.LoginUsuarioRegistrador = @login" : "";
            string filtroEst = FiltroActivo == "TODOS" ? "" : " AND me.Codigo = @filtro";

            string sql = @"SELECT d.IdDocumento, d.Asunto, d.AreaCategoria, d.RutaArchivoPDF,
                                  d.FechaCreacion, d.FechaLimiteRevision, d.FechaLimiteAprobacion,
                                  me.Descripcion AS EstadoDesc, me.Codigo AS EstadoCodigo,
                                  CASE WHEN EXISTS (
                                      SELECT 1
                                      FROM DocumentoParticipante dpObs
                                      INNER JOIN Maestro mtObs ON dpObs.IdTipoParticipante = mtObs.IdMaestro
                                      INNER JOIN RevisionDetalle rd ON rd.IdParticipante = dpObs.IdParticipante
                                      WHERE dpObs.IdDocumento = d.IdDocumento
                                        AND mtObs.Tipo='TIPO_PARTICIPANTE' AND mtObs.Codigo='REV'
                                        AND rd.EsObservacion = 1
                                  ) THEN 1 ELSE 0 END AS TieneObservacionRevisor
                           FROM Documento d
                           JOIN Maestro me ON d.IdEstadoDocumento = me.IdMaestro
                           WHERE d.Activo = 1" + filtroRol + filtroEst + @"
                           ORDER BY d.FechaCreacion DESC";

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (rol == "REG") cmd.Parameters.AddWithValue("@login", login);
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
                                case "PEN":
                                case "FPAR": badgeCss = "badge-pen";  break;
                                case "REV":  badgeCss = "badge-rev";  break;
                                case "FCOM": badgeCss = "badge-fcom"; break;
                                case "OBS":  badgeCss = "badge-obs";  break;
                                default:     badgeCss = "badge-reg";  break;
                            }

                            string plazosHtml = BuildPlazos(dr, ahora);

                            lista.Add(new
                            {
                                IdDocumento   = Convert.ToInt32(dr["IdDocumento"]),
                                Asunto        = dr["Asunto"].ToString(),
                                NombreArchivo = Path.GetFileName(ruta),
                                AreaCategoria = dr["AreaCategoria"] == DBNull.Value ? "-" : dr["AreaCategoria"].ToString(),
                                EstadoDesc    = dr["EstadoDesc"].ToString(),
                                EstadoCodigo  = est,
                                BadgeCss      = badgeCss,
                                RevisoresHtml = ObtenerRevisoresEstadoHtml(Convert.ToInt32(dr["IdDocumento"])),
                                PlazosHtml    = plazosHtml,
                                FechaStr      = Convert.ToDateTime(dr["FechaCreacion"]).ToString("d/M/yyyy"),
                                PuedeVerObservaciones = dr["TieneObservacionRevisor"] != DBNull.Value && Convert.ToInt32(dr["TieneObservacionRevisor"]) == 1
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

        private string ObtenerRevisoresEstadoHtml(int idDocumento)
        {
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            string sql = @"SELECT dp.LoginUsuario, ISNULL(me.Codigo,'PEN') AS EstadoCod
                           FROM DocumentoParticipante dp
                           INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           LEFT JOIN Maestro me ON dp.EstadoParticipante = me.IdMaestro
                           WHERE dp.IdDocumento=@id
                             AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='REV'
                           ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";
            var lista = new List<string>();
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string login = dr["LoginUsuario"].ToString();
                            string est = dr["EstadoCod"].ToString().ToUpperInvariant();
                            string css = "rev-pend";
                            string txt = "Pendiente";
                            if (est == "REG" || est == "FIR") { css = "rev-ok"; txt = "Revisado"; }
                            else if (est == "OBS") { css = "rev-obs"; txt = "Observado"; }
                            lista.Add("<span class='rev-item " + css + "'>" +
                                      System.Web.HttpUtility.HtmlEncode(login + ": " + txt) + "</span>");
                        }
                    }
                }
            }
            if (lista.Count == 0) return "<span class='plazo-ok'>Sin revisores</span>";
            return "<div class='revisores-grid'>" + string.Join("", lista.ToArray()) + "</div>";
        }

        private string BuildNav(string rol)
        {
            string svgHome    = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgCargar  = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgRoles   = "<svg viewBox='0 0 24 24'><path d='M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z'/></svg>";
            string svgFirm    = "<svg viewBox='0 0 24 24'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>";
            string svgEstado  = "<svg viewBox='0 0 24 24'><path d='M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z'/></svg>";

            if (rol == "REG")
            {
                return
                    "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                    "<a href='MisDocumentos.aspx' class='nav-item active'>" + svgMisDocs + "Mis Documentos</a>";
            }
            // ADM
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
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
