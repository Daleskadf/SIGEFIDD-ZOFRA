using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ZofraTacna
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] != null)
                RedirectByRole(Session["RolCodigo"].ToString());

            if (!IsPostBack)
                CargarUsuarios();
        }

        private void CargarUsuarios()
        {
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                string sql = @"SELECT u.LoginUsuario, m.Codigo AS RolCodigo, m.Descripcion AS RolNombre
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               WHERE u.Activo = 1
                               ORDER BY u.LoginUsuario";
                using (var cmd = new SqlCommand(sql, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    ddlUsuario.Items.Clear();
                    ddlUsuario.Items.Add(new ListItem("-- Seleccione un usuario --", ""));
                    while (dr.Read())
                    {
                        string login = dr["LoginUsuario"].ToString();
                        string rol   = dr["RolCodigo"].ToString();
                        string nombre = dr["RolNombre"].ToString();
                        var item = new ListItem(login + " (" + nombre + ")", login);
                        item.Attributes["data-rol"]       = rol;
                        item.Attributes["data-rolnombre"] = nombre;
                        ddlUsuario.Items.Add(item);
                    }
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string login = ddlUsuario.SelectedValue;
            if (string.IsNullOrEmpty(login)) return;

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                string sql = @"SELECT u.LoginUsuario, m.Codigo AS RolCodigo, m.Descripcion AS RolNombre
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               WHERE u.LoginUsuario = @login AND u.Activo = 1";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@login", login);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            Session["LoginUsuario"] = dr["LoginUsuario"].ToString();
                            Session["RolCodigo"]    = dr["RolCodigo"].ToString();
                            Session["RolNombre"]    = dr["RolNombre"].ToString();
                            RedirectByRole(dr["RolCodigo"].ToString());
                        }
                    }
                }
            }
        }

        private void RedirectByRole(string rol)
        {
            switch (rol)
            {
                case "ADM": Response.Redirect("~/Presentacion/Default.aspx");     break;
                case "REG": Response.Redirect("~/Presentacion/Registrador.aspx"); break;
                case "REV": Response.Redirect("~/Presentacion/Revisor.aspx");     break;
                case "FIR": Response.Redirect("~/Presentacion/Firmante.aspx");    break;
                default:    Response.Redirect("~/Presentacion/Default.aspx");     break;
            }
        }
    }
}

