using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
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
            litRol.Text        = ZofraTacna.Helpers.RolSwitcherHelper.GenerarBadgeRolOSwitcher(Context, Session["RolCodigo"]?.ToString() ?? "", Session["RolNombre"]?.ToString() ?? "");
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

                CargarObservaciones(conn, login);
                CargarAlertas(conn, login);
            }
        }

        private void CargarObservaciones(SqlConnection conn, string login)
        {
            string sql = @"
                SELECT TOP 50
                       h.IdHistorial,
                       h.IdDocumento,
                       d.Asunto,
                       d.CodigoDocumento,
                       h.LoginUsuarioAccion,
                       h.DetalleAccion,
                       h.FechaCambio
                FROM dbo.HistorialDocumento h
                INNER JOIN dbo.Documento d ON d.IdDocumento = h.IdDocumento
                INNER JOIN dbo.Maestro m ON d.IdEstadoDocumento = m.IdMaestro
                WHERE d.LoginUsuarioRegistrador = @login
                  AND d.Activo = 1
                  AND m.Codigo = 'OBS'
                  AND (h.DetalleAccion LIKE '%observad%' OR h.DetalleAccion LIKE '%Observad%')
                ORDER BY h.FechaCambio DESC";

            var observaciones = new List<object>();
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@login", login);
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        DateTime fechaCambio = ConvertirAPeruTime(Convert.ToDateTime(dr["FechaCambio"]));
                        observaciones.Add(new
                        {
                            IdHistorial = Convert.ToInt32(dr["IdHistorial"]),
                            IdDocumento = Convert.ToInt32(dr["IdDocumento"]),
                            Asunto = dr["Asunto"].ToString(),
                            CodigoDocumento = dr["CodigoDocumento"].ToString(),
                            UsuarioRevisor = dr["LoginUsuarioAccion"].ToString(),
                            DetalleAccion = dr["DetalleAccion"].ToString(),
                            FechaObservacion = fechaCambio.ToString("dd/MM/yyyy HH:mm")
                        });
                    }
                }
            }

            litTotalObservaciones.Text = observaciones.Count.ToString();
            pnlSinObservaciones.Visible = observaciones.Count == 0;
            
            // Dividir en primeros 4 y resto
            var obs4 = observaciones.Take(4).ToList();
            var obsResto = observaciones.Skip(4).ToList();
            
            rptObservaciones.DataSource = obs4;
            rptObservaciones.DataBind();
            
            rptObservacionesExtra.DataSource = obsResto;
            rptObservacionesExtra.DataBind();
            
            pnlObsExpandir.Visible = obsResto.Count > 0;
        }

        private void CargarAlertas(SqlConnection conn, string login)
        {
            string sql = @"
                SELECT d.IdDocumento,
                       d.Asunto,
                       me.Descripcion AS EstadoDesc,
                       DATEADD(day, dp.PlazoDias, d.FechaCreacion) AS FechaLimite,
                       DATEDIFF(hour, DATEADD(day, dp.PlazoDias, d.FechaCreacion), GETDATE()) AS HorasVencido
                FROM DocumentoParticipante dp
                JOIN Documento d  ON dp.IdDocumento = d.IdDocumento
                JOIN Maestro   me ON d.IdEstadoDocumento = me.IdMaestro
                WHERE d.LoginUsuarioRegistrador = @u
                  AND DATEADD(day, dp.PlazoDias, d.FechaCreacion) < GETDATE()
                  AND d.Activo = 1
                  AND me.Codigo NOT IN ('FCOM', 'ANU')
                  AND (dp.EstadoParticipante IS NULL OR dp.EstadoParticipante = (SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_PARTICIPANTE' AND Codigo='PEN'))
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
                            IdDocumento = Convert.ToInt32(dr["IdDocumento"]),
                            Asunto = dr["Asunto"].ToString(),
                            EstadoDesc = dr["EstadoDesc"].ToString(),
                            FechaLimite = Convert.ToDateTime(dr["FechaLimite"]).ToString("dd/MM/yyyy, HH:mm"),
                            HorasVencido = horas,
                            NivelCss = horas > 100 ? "critico" : "urgente",
                            NivelLabel = horas > 100 ? "Critico" : "Urgente"
                        });
                    }
                }
            }

            litTotalAlertas.Text = alertas.Count.ToString();
            pnlSinAlertas.Visible = alertas.Count == 0;
            
            // Dividir en primeros 4 y resto
            var alerta4 = alertas.Take(4).ToList();
            var alertaResto = alertas.Skip(4).ToList();
            
            rptAlertas.DataSource = alerta4;
            rptAlertas.DataBind();
            
            rptAlertasExtra.DataSource = alertaResto;
            rptAlertasExtra.DataBind();
            
            pnlPlazoExpandir.Visible = alertaResto.Count > 0;
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

        private static DateTime ConvertirAPeruTime(DateTime utcDateTime)
        {
            if (utcDateTime == DateTime.MinValue || utcDateTime == DateTime.MaxValue)
                return utcDateTime;
            try
            {
                TimeZoneInfo zone = TimeZoneInfo.FindSystemTimeZoneById("SA Pacific Standard Time");
                DateTime utc = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);
                return TimeZoneInfo.ConvertTimeFromUtc(utc, zone);
            }
            catch
            {
                // Fallback: Peru is UTC - 5
                return utcDateTime.AddHours(-5);
            }
        }
    }
}
