using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class DevolverDocumento : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null || Session["RolCodigo"]?.ToString() != "ADM")
            {
                Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            int idDoc;
            if (!int.TryParse(Request.QueryString["id"], out idDoc) || idDoc <= 0)
            {
                Response.Redirect("BandejaTrabajo.aspx");
                return;
            }

            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"]?.ToString() ?? "";

            hfDocId.Value = idDoc.ToString();

            if (!IsPostBack)
                CargarInfo(idDoc);
        }

        private void CargarInfo(int idDoc)
        {
            string sql = @"SELECT d.Asunto, d.CodigoDocumento, me.Descripcion AS Estado, me.Codigo AS EstadoCod
                           FROM Documento d
                           JOIN Maestro me ON d.IdEstadoDocumento = me.IdMaestro
                           WHERE d.IdDocumento = @id AND d.Activo = 1";

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) { Response.Redirect("BandejaTrabajo.aspx"); return; }

                        litAsunto.Text = HttpUtility.HtmlEncode(dr["Asunto"].ToString());
                        litCodigo.Text = HttpUtility.HtmlEncode(dr["CodigoDocumento"].ToString());
                        string est = dr["EstadoCod"].ToString();
                        string css = (est == "PEN" || est == "FPAR") ? "badge badge-firma" : "badge badge-estado";
                        litEstadoBadge.Text = string.Format("<span class='{0}'>{1}</span>", css,
                            HttpUtility.HtmlEncode(dr["Estado"].ToString()));

                        bool permitido = (est != "PEN" && est != "APR");
                        pnlFormDevolver.Visible  = permitido;
                        pnlNoPermitido.Visible   = !permitido;
                    }
                }
            }
        }

        protected void btnDevolver_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string motivo = txtMotivo.Text.Trim();

            if (string.IsNullOrEmpty(motivo))
            {
                litMsg.Text = "<div class='alert alert-err'>&#9888; Debe ingresar el motivo de la devoluci&oacute;n.</div>";
                return;
            }

            string login = Session["LoginUsuario"].ToString();

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        int idEstadoAnterior, idEstadoObs;
                        using (var cmd = new SqlCommand("SELECT d.IdEstadoDocumento, m.IdMaestro FROM Documento d, Maestro m WHERE d.IdDocumento=@id AND m.Tipo='ESTADO_DOC' AND m.Codigo='OBS'", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            using (var dr = cmd.ExecuteReader())
                            {
                                dr.Read();
                                idEstadoAnterior = Convert.ToInt32(dr[0]);
                                idEstadoObs      = Convert.ToInt32(dr[1]);
                            }
                        }

                        using (var cmd = new SqlCommand("UPDATE Documento SET IdEstadoDocumento=@nuevo WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@nuevo", idEstadoObs);
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET Activo=0 WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                            (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                            VALUES (@id,@ant,@nuevo,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id",    idDoc);
                            cmd.Parameters.AddWithValue("@ant",   idEstadoAnterior);
                            cmd.Parameters.AddWithValue("@nuevo", idEstadoObs);
                            cmd.Parameters.AddWithValue("@login", login);
                            cmd.Parameters.AddWithValue("@det",   "ADM devolvió al registrador. Motivo: " + motivo);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }

            Response.Redirect("BandejaTrabajo.aspx");
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
