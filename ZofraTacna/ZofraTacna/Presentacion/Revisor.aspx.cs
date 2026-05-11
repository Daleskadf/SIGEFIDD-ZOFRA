using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ZofraTacna
{
    public partial class Revisor : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null || Session["RolCodigo"].ToString() != "REV")
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
            string rol   = Session["RolNombre"].ToString();

            litAvatar.Text     = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text     = login;
            litRol.Text        = rol;
            litBienvenido.Text = login;

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Documentos asignados como Revisor (TipoParticipante codigo REV)
                string sqlBase = @"SELECT COUNT(*) FROM DocumentoParticipante dp
                                   JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                   JOIN Documento d ON dp.IdDocumento = d.IdDocumento
                                   WHERE dp.LoginUsuario = @u AND mt.Codigo = 'REV' AND d.Activo = 1";

                string sqlPendientes = sqlBase + @" AND NOT EXISTS (
                    SELECT 1 FROM RevisionDetalle rd WHERE rd.IdParticipante = dp.IdParticipante)";

                string sqlRevisados = sqlBase + @" AND EXISTS (
                    SELECT 1 FROM RevisionDetalle rd WHERE rd.IdParticipante = dp.IdParticipante)";

                litPendientes.Text = Contar(conn, sqlPendientes, login);
                litRevisados.Text  = Contar(conn, sqlRevisados,  login);
                litTotal.Text      = Contar(conn, sqlBase,       login);

                string sqlBadge = @"SELECT COUNT(*) FROM Documento d 
                                    JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro 
                                    WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')
                                    AND EXISTS (
                                        SELECT 1 FROM DocumentoParticipante dpf
                                        INNER JOIN Maestro mtf ON dpf.IdTipoParticipante = mtf.IdMaestro
                                        WHERE dpf.IdDocumento = d.IdDocumento
                                          AND dpf.LoginUsuario = @u
                                          AND mtf.Codigo = 'REV'
                                    )";
                string badgeStr = Contar(conn, sqlBadge, login);
                litBadgeBandeja.Text = badgeStr;

                CargarAlertas(conn, login);
            }
        }

        private void CargarAlertas(SqlConnection conn, string login)
        {
            string sql = @"
                SELECT d.Asunto,
                       me.Descripcion AS EstadoDesc,
                       DATEADD(day, dp.PlazoDias, d.FechaCreacion) AS FechaLimite,
                       DATEDIFF(hour, DATEADD(day, dp.PlazoDias, d.FechaCreacion), GETDATE()) AS HorasVencido
                FROM DocumentoParticipante dp
                JOIN Documento d  ON dp.IdDocumento = d.IdDocumento
                JOIN Maestro   mt ON dp.IdTipoParticipante = mt.IdMaestro
                JOIN Maestro   me ON d.IdEstadoDocumento   = me.IdMaestro
                WHERE dp.LoginUsuario = @u
                  AND mt.Codigo = 'REV'
                  AND DATEADD(day, dp.PlazoDias, d.FechaCreacion) < GETDATE()
                  AND d.Activo = 1
                ORDER BY HorasVencido DESC";

            var alertas = new List<object>();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@u", login);
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        int horas = Convert.ToInt32(dr["HorasVencido"]);
                        alertas.Add(new
                        {
                            Asunto       = dr["Asunto"].ToString(),
                            EstadoDesc   = dr["EstadoDesc"].ToString(),
                            FechaLimite  = Convert.ToDateTime(dr["FechaLimite"]).ToString("dd/MM/yyyy, HH:mm"),
                            HorasVencido = horas,
                            NivelCss     = horas > 100 ? "critico" : "urgente",
                            NivelLabel   = horas > 100 ? "Critico" : "Urgente"
                        });
                    }
                }
            }

            litTotalAlertas.Text  = alertas.Count.ToString();
            pnlSinAlertas.Visible = alertas.Count == 0;
            rptAlertas.DataSource = alertas;
            rptAlertas.DataBind();
        }

        private string Contar(SqlConnection conn, string sql, string login)
        {
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@u", login);
                return cmd.ExecuteScalar().ToString();
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
