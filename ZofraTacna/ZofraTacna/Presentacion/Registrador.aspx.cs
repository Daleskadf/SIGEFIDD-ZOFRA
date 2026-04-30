using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ZofraTacna
{
    public partial class Registrador : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null || Session["RolCodigo"].ToString() != "REG")
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
                litCargados.Text    = Contar(conn, "SELECT COUNT(*) FROM Documento WHERE LoginUsuarioRegistrador=@u AND Activo=1", login);
                litEnProceso.Text   = Contar(conn,
                    @"SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro
                      WHERE d.LoginUsuarioRegistrador=@u AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS') AND d.Activo=1", login);
                litCompletados.Text = Contar(conn,
                    @"SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro
                      WHERE d.LoginUsuarioRegistrador=@u AND m.Codigo='FCOM' AND d.Activo=1", login);

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
                JOIN Maestro   me ON d.IdEstadoDocumento = me.IdMaestro
                WHERE d.LoginUsuarioRegistrador = @u
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
                            Asunto      = dr["Asunto"].ToString(),
                            EstadoDesc  = dr["EstadoDesc"].ToString(),
                            FechaLimite = Convert.ToDateTime(dr["FechaLimite"]).ToString("dd/MM/yyyy, HH:mm"),
                            HorasVencido = horas,
                            NivelCss    = horas > 100 ? "critico" : "urgente",
                            NivelLabel  = horas > 100 ? "Critico" : "Urgente"
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
