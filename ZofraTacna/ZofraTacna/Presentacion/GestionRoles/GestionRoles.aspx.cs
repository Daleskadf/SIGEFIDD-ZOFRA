using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.LogicaNegocio;
using ZofraTacna.ServiciosExternos;

namespace ZofraTacna.Presentacion
{
    public partial class GestionRoles : Page
    {
        private readonly ConectorSAS _conectorSAS = new ConectorSAS();
        private readonly ModuloAutenticacion _moduloAuth = new ModuloAutenticacion();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null || Session["RolCodigo"] == null ||
                Session["RolCodigo"].ToString() != "ADM")
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }
            if (!IsPostBack)
            {
                CargarRoles();
                CargarDatos();
            }
        }

        // ============================================================
        // CARGA DE DATOS
        // ============================================================
        private void CargarDatos()
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = ZofraTacna.Helpers.RolSwitcherHelper.GenerarBadgeRolOSwitcher(Context, Session["RolCodigo"]?.ToString() ?? "", Session["RolNombre"]?.ToString() ?? "");

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            var lista = new List<object>();
            int cntRev = 0, cntFir = 0, cntAdm = 0, cntReg = 0;

            // SQL: Obtener SOLO usuarios que YA TIENEN ROL en UsuarioSistema
            string sqlUsuarios = @"SELECT u.IdUsuario, u.LoginUsuario,
                                          ISNULL(e.Email, u.LoginUsuario + '@zofratacna.com.pe') AS Email,
                                          m.Descripcion AS Rol,
                                          m.Codigo      AS RolCodigo,
                                          u.IdRolSistema
                                   FROM UsuarioSistema u
                                   JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                                   LEFT JOIN dbo.FIR_VW_EmpleadosActivos e ON e.LoginUsuario = u.LoginUsuario
                                   WHERE u.Activo = 1
                                   ORDER BY m.Codigo, u.LoginUsuario";

            string sqlCounts = @"SELECT m.Codigo, COUNT(*) AS Total
                                 FROM UsuarioSistema u
                                 JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                                 WHERE u.Activo = 1
                                 GROUP BY m.Codigo";

            string sqlBadge = @"SELECT COUNT(*) FROM Documento d
                                JOIN Maestro me ON d.IdEstadoDocumento=me.IdMaestro
                                WHERE d.Activo=1 AND me.Codigo IN ('REG','REV','PEN','FPAR','OBS')";

            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();

                using (var cmd = new SqlCommand(sqlBadge, cn))
                    litBadge.Text = cmd.ExecuteScalar().ToString();

                using (var cmd = new SqlCommand(sqlCounts, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string cod = dr["Codigo"].ToString().ToUpper();
                        int cnt = Convert.ToInt32(dr["Total"]);
                        if      (cod == "REV") cntRev = cnt;
                        else if (cod == "FIR") cntFir = cnt;
                        else if (cod == "ADM") cntAdm = cnt;
                        else if (cod == "REG") cntReg = cnt;
                    }
                }
                litCntRev.Text = cntRev.ToString();
                litCntFir.Text = cntFir.ToString();
                litCntAdm.Text = cntAdm.ToString();
                litCntReg.Text = cntReg.ToString();

                using (var cmd = new SqlCommand(sqlUsuarios, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string rolCod = dr["RolCodigo"].ToString().ToUpper();
                        string badgeCss;
                        switch (rolCod)
                        {
                            case "REV": badgeCss = "badge-rev"; break;
                            case "FIR": badgeCss = "badge-fir"; break;
                            case "ADM": badgeCss = "badge-adm"; break;
                            default:    badgeCss = "badge-reg"; break;
                        }
                        lista.Add(new
                        {
                            IdUsuario    = Convert.ToInt32(dr["IdUsuario"]),
                            IdRolSistema = Convert.ToInt32(dr["IdRolSistema"]),
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            Email        = dr["Email"].ToString(),
                            Rol          = dr["Rol"].ToString(),
                            RolCodigo    = rolCod,
                            BadgeCss     = badgeCss
                        });
                    }
                }
            }

            pnlEmpty.Visible       = lista.Count == 0;
            pnlTable.Visible       = lista.Count > 0;
            rptUsuarios.DataSource = lista;
            rptUsuarios.DataBind();
        }

        private void CargarRoles()
        {
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(connStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(
                    "SELECT IdMaestro, Descripcion FROM Maestro WHERE Tipo='ROL_SISTEMA' AND Activo=1 ORDER BY Orden", cn))
                using (var dr = cmd.ExecuteReader())
                {
                    ddlRolNuevo.Items.Clear();
                    ddlRolNuevo.Items.Add(new ListItem("-- Seleccionar --", ""));
                    while (dr.Read())
                        ddlRolNuevo.Items.Add(new ListItem(dr["Descripcion"].ToString(), dr["IdMaestro"].ToString()));
                }
            }
        }

        // ============================================================
        // UC-006 — GESTIONAR ROL (Agregar / Editar / Eliminar)
        // ============================================================
        protected void btnAgregarUsuario_Click(object sender, EventArgs e)
        {
            LimpiarFormulario();
            litFormTitulo.Text       = "Asignar Rol a Empleado";
            txtLoginNuevo.ReadOnly   = false;
            pnlFormulario.Visible    = true;
            lblMensajeForm.Visible   = false;
        }

        protected void btnGuardarUsuario_Click(object sender, EventArgs e)
        {
            string loginNuevo = txtLoginNuevo.Text.Trim();
            string rolVal     = ddlRolNuevo.SelectedValue;
            int    idUsuario  = int.Parse(hfIdUsuario.Value);

            if (string.IsNullOrEmpty(loginNuevo) || string.IsNullOrEmpty(rolVal))
            {
                MostrarMsgForm("Complete todos los campos obligatorios.", false);
                return;
            }

            // Alta: empleado en administracion y aún sin fila en UsuarioSistema.
            // Edición: mismo empleado; se cambia solo IdRolSistema (no bloquear por "ya tiene rol").
            bool esAltaNueva = idUsuario == 0;
            string validationError = null;
            try
            {
                validationError = _moduloAuth.ValidarRegistroUsuario(loginNuevo, esAltaNueva);
            }
            catch (Exception ex)
            {
                validationError = "Error en validación de registro: " + ex.Message;
            }

            if (validationError != null)
            {
                MostrarMsgForm(validationError, false);
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            bool success = false;
            string successMsg = "";
            string errorMsg = "";

            using (var cn = new SqlConnection(connStr))
            {
                try
                {
                    cn.Open();
                    if (idUsuario == 0) // AGREGAR
                    {
                        // Use the exact columns present in the schema: LoginUsuario, Password, IdRolSistema, Activo
                        using (var cmd = new SqlCommand(
                            "INSERT INTO UsuarioSistema (LoginUsuario, Password, IdRolSistema, Activo) VALUES (@login, '', @rol, 1)", cn))
                        {
                            cmd.Parameters.AddWithValue("@login", loginNuevo);
                            cmd.Parameters.AddWithValue("@rol",   int.Parse(rolVal));
                            cmd.ExecuteNonQuery();
                        }
                        success = true;
                        successMsg = "✓ Usuario agregado correctamente. Ahora aparecerá en el Login.";
                    }
                    else // EDITAR
                    {
                        // Use only the IdRolSistema column for update to match the schema
                        using (var cmd = new SqlCommand(
                            "UPDATE UsuarioSistema SET IdRolSistema=@rol WHERE IdUsuario=@id", cn))
                        {
                            cmd.Parameters.AddWithValue("@rol", int.Parse(rolVal));
                            cmd.Parameters.AddWithValue("@id",  idUsuario);
                            cmd.ExecuteNonQuery();
                        }
                        success = true;
                        successMsg = "✓ Rol actualizado correctamente.";
                    }
                }
                catch (Exception ex)
                {
                    success = false;
                    errorMsg = "Error en base de datos: " + ex.Message;
                }
            }

            if (success)
            {
                pnlFormulario.Visible  = false;
                lblMensajeForm.Visible = false;
                CargarDatos();

                // Triggers a beautiful client-side success toast
                string jsToast = string.Format("window.zfnNotify && window.zfnNotify.showToast('{0}', 'success');", successMsg.Replace("'", "\\'"));
                ClientScript.RegisterStartupScript(this.GetType(), "saveSuccessToast", jsToast, true);
            }
            else
            {
                // Keep the panel open and display the SQL error clearly in the form
                pnlFormulario.Visible  = true;
                MostrarMsgForm(errorMsg, false);
            }
        }

        protected void rptUsuarios_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idUsuario = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Editar")
            {
                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT LoginUsuario, IdRolSistema FROM UsuarioSistema WHERE IdUsuario=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idUsuario);
                        using (var dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                hfIdUsuario.Value          = idUsuario.ToString();
                                txtLoginNuevo.Text         = dr["LoginUsuario"].ToString();
                                txtLoginNuevo.ReadOnly     = true;
                                ddlRolNuevo.SelectedValue  = dr["IdRolSistema"].ToString();
                                litFormTitulo.Text         = "Editar Rol de Usuario";
                                pnlFormulario.Visible      = true;
                                lblMensajeForm.Visible     = false;
                            }
                        }
                    }
                }
            }
            else if (e.CommandName == "Eliminar")
            {
                string loginSesion = Session["LoginUsuario"].ToString();
                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string loginAEliminar = "";
                    using (var cmd = new SqlCommand(
                        "SELECT LoginUsuario FROM UsuarioSistema WHERE IdUsuario=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idUsuario);
                        loginAEliminar = cmd.ExecuteScalar()?.ToString() ?? "";
                    }
                    if (loginAEliminar == loginSesion)
                        return; // no puede eliminarse a sí mismo

                    using (var cmd = new SqlCommand(
                        "DELETE FROM UsuarioSistema WHERE IdUsuario=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idUsuario);
                        cmd.ExecuteNonQuery();
                    }
                }
                CargarDatos();
            }
        }

        protected void btnCancelarFormulario_Click(object sender, EventArgs e)
        {
            pnlFormulario.Visible  = false;
            lblMensajeForm.Visible = false;
        }

        private void LimpiarFormulario()
        {
            hfIdUsuario.Value     = "0";
            txtLoginNuevo.Text    = "";
            ddlRolNuevo.SelectedIndex = 0;
        }

        private void MostrarMsgForm(string msg, bool ok)
        {
            lblMensajeForm.Text      = msg;
            lblMensajeForm.CssClass  = ok ? "fup-msg-ok" : "fup-msg-err";
            lblMensajeForm.Visible   = true;
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
