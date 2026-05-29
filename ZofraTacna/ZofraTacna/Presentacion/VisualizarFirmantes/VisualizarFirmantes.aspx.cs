using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class VisualizarFirmantes : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null || Session["RolCodigo"] == null ||
                Session["RolCodigo"].ToString() != "ADM")
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }
            if (!IsPostBack) CargarDatos();
        }

        // Helper classes for grouping
        private class FirmanteRow
        {
            public int     IdParticipante     { get; set; }
            public string  LoginUsuario       { get; set; }
            public string  CorreoInstitucional{ get; set; }
            public int     OrdenSecuencial    { get; set; }
            public bool    Firmado            { get; set; }
        }

        private class DocFirmantes
        {
            public int              IdDocumento  { get; set; }
            public string           Asunto       { get; set; }
            public string           EstadoDesc   { get; set; }
            public string           EstadoCodigo { get; set; }
            public List<FirmanteRow> Firmantes   { get; set; }
        }

        private void CargarDatos()
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = ZofraTacna.Helpers.RolSwitcherHelper.GenerarBadgeRolOSwitcher(Context, Session["RolCodigo"]?.ToString() ?? "", Session["RolNombre"]?.ToString() ?? "");

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            string sqlBadge = @"SELECT COUNT(*) FROM Documento d
                                JOIN Maestro me ON d.IdEstadoDocumento=me.IdMaestro
                                WHERE d.Activo=1 AND me.Codigo IN ('REG','REV','PEN','FPAR','OBS')";

            string sql = @"SELECT d.IdDocumento, d.Asunto,
                                  me.Descripcion   AS EstadoDesc,
                                  me.Codigo        AS EstadoCodigo,
                                  dp.IdParticipante,
                                  dp.LoginUsuario,
                                  dp.CorreoInstitucional,
                                  dp.OrdenSecuencial,
                                  fd.FechaFirma,
                                  mf.Codigo        AS FirmaCodigo
                           FROM Documento d
                           JOIN Maestro me         ON d.IdEstadoDocumento    = me.IdMaestro
                           JOIN DocumentoParticipante dp ON dp.IdDocumento   = d.IdDocumento
                           JOIN Maestro mt          ON dp.IdTipoParticipante = mt.IdMaestro
                           LEFT JOIN FirmaDetalle fd ON fd.IdParticipante    = dp.IdParticipante
                           LEFT JOIN Maestro mf     ON fd.IdEstadoFirma      = mf.IdMaestro
                           WHERE mt.Codigo = 'FIR' AND d.Activo = 1
                           ORDER BY d.IdDocumento, dp.OrdenSecuencial";

            // Group by document
            var docDict = new Dictionary<int, DocFirmantes>();
            var docOrder = new List<int>(); // preserve insertion order

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();

                using (var cmd = new SqlCommand(sqlBadge, cn))
                    litBadge.Text = cmd.ExecuteScalar().ToString();

                using (var cmd = new SqlCommand(sql, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        int idDoc = Convert.ToInt32(dr["IdDocumento"]);

                        if (!docDict.ContainsKey(idDoc))
                        {
                            docDict[idDoc] = new DocFirmantes
                            {
                                IdDocumento  = idDoc,
                                Asunto       = dr["Asunto"].ToString(),
                                EstadoDesc   = dr["EstadoDesc"].ToString(),
                                EstadoCodigo = dr["EstadoCodigo"].ToString().ToUpper(),
                                Firmantes    = new List<FirmanteRow>()
                            };
                            docOrder.Add(idDoc);
                        }

                        string firmaCod = dr["FirmaCodigo"] == DBNull.Value ? "" : dr["FirmaCodigo"].ToString().ToUpper();
                        bool firmado = firmaCod == "FCOM" || dr["FechaFirma"] != DBNull.Value;

                        docDict[idDoc].Firmantes.Add(new FirmanteRow
                        {
                            IdParticipante      = Convert.ToInt32(dr["IdParticipante"]),
                            LoginUsuario        = dr["LoginUsuario"].ToString(),
                            CorreoInstitucional = dr["CorreoInstitucional"] == DBNull.Value ? "" : dr["CorreoInstitucional"].ToString(),
                            OrdenSecuencial     = Convert.ToInt32(dr["OrdenSecuencial"]),
                            Firmado             = firmado
                        });
                    }
                }
            }

            if (docOrder.Count == 0)
            {
                pnlEmpty.Visible = true;
                rptDocumentos.Visible = false;
                return;
            }

            // Build view model list for repeater
            var lista = new List<object>();
            foreach (int idDoc in docOrder)
            {
                DocFirmantes doc = docDict[idDoc];
                string est = doc.EstadoCodigo;

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

                int firmados = 0;
                var sbFirmantes = new StringBuilder();
                foreach (FirmanteRow f in doc.Firmantes)
                {
                    if (f.Firmado) firmados++;
                    string correo = string.IsNullOrEmpty(f.CorreoInstitucional)
                        ? f.LoginUsuario + "@zofratacna.com.pe"
                        : f.CorreoInstitucional;

                    if (f.Firmado)
                    {
                        sbFirmantes.AppendFormat(
                            "<div class='firmante-row'>" +
                            "<div class='firmante-num'>{0}</div>" +
                            "<div class='firmante-info'>" +
                            "<div class='firmante-login'>{1}</div>" +
                            "<div class='firmante-email'>{2}</div></div>" +
                            "<span class='firmante-status-ok'>&#9679; Firmado</span></div>",
                            f.OrdenSecuencial,
                            System.Web.HttpUtility.HtmlEncode(f.LoginUsuario),
                            System.Web.HttpUtility.HtmlEncode(correo));
                    }
                    else
                    {
                        sbFirmantes.AppendFormat(
                            "<div class='firmante-row'>" +
                            "<div class='firmante-num'>{0}</div>" +
                            "<div class='firmante-info'>" +
                            "<div class='firmante-login'>{1}</div>" +
                            "<div class='firmante-email'>{2}</div></div>" +
                            "<span class='firmante-status-pen'>&#9675; Pendiente</span></div>",
                            f.OrdenSecuencial,
                            System.Web.HttpUtility.HtmlEncode(f.LoginUsuario),
                            System.Web.HttpUtility.HtmlEncode(correo));
                    }
                }

                int total = doc.Firmantes.Count;
                int pct   = total > 0 ? (int)Math.Round((double)firmados / total * 100) : 0;

                lista.Add(new
                {
                    IdDocumento    = idDoc,
                    Asunto         = doc.Asunto,
                    EstadoDesc     = doc.EstadoDesc,
                    EstadoCodigo   = est,
                    BadgeCss       = badgeCss,
                    FirmantesHtml  = sbFirmantes.ToString(),
                    FirmadosCount  = firmados,
                    TotalCount     = total,
                    PorcentajeStr  = pct
                });
            }

            pnlEmpty.Visible = false;
            rptDocumentos.Visible = true;
            rptDocumentos.DataSource = lista;
            rptDocumentos.DataBind();
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
