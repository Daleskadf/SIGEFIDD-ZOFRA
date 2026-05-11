using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ZofraTacna
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null)
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
            string rolCod = Session["RolCodigo"].ToString();

            string iniciales = login.Length >= 2
                ? login.Substring(0, 2).ToUpper()
                : login.ToUpper();

            litAvatar.Text     = iniciales;
            litNombre.Text     = login;
            litRol.Text        = rol;
            litBienvenido.Text = login;
            litDocUser1.Text   = login;
            litActUser.Text    = login;

            // Herramientas admin solo para Administrador
            pnlHerramientas.Visible = (rolCod == "ADM");

            CargarEstadisticas();
        }

        private void CargarEstadisticas()
        {
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var conn = new SqlConnection(connStr))
            {
                conn.Open();

                litTotal.Text      = ContarQuery(conn, "SELECT COUNT(*) FROM Documento WHERE Activo=1");
                litPendientes.Text = ContarQuery(conn,
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE m.Codigo IN ('PEN','FPAR') AND d.Activo=1");
                litCompletados.Text = ContarQuery(conn,
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE m.Codigo='FCOM' AND d.Activo=1");
                litUsuarios.Text   = ContarQuery(conn, "SELECT COUNT(*) FROM UsuarioSistema WHERE Activo=1");
                
                badgeBandeja.InnerText = ContarQuery(conn, 
                    "SELECT COUNT(*) FROM Documento d JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')");
            }
        }

        private string ContarQuery(SqlConnection conn, string sql)
        {
            using (var cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar().ToString();
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
