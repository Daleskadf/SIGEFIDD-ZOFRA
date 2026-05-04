using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ZofraTacna.Presentacion
{
    public partial class GestionarParticipantes : Page
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

            if (!IsPostBack)
            {
                hfDocId.Value = idDoc.ToString();
                CargarInfoDocumento(idDoc);
                CargarDropdowns(idDoc);
            }
            else
            {
                idDoc = int.Parse(hfDocId.Value);
            }

            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"]?.ToString() ?? "";

            CargarRevisores(idDoc);
            CargarFirmantes(idDoc);
        }

        // ============================================================
        // CARGA INICIAL
        // ============================================================
        private void CargarInfoDocumento(int idDoc)
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
                        if (dr.Read())
                        {
                            litAsunto.Text  = System.Web.HttpUtility.HtmlEncode(dr["Asunto"].ToString());
                            litCodigo.Text  = System.Web.HttpUtility.HtmlEncode(dr["CodigoDocumento"].ToString());
                            string est      = dr["EstadoCod"].ToString();
                            string css      = (est == "PEN" || est == "FPAR") ? "badge badge-firma" : "badge badge-estado";
                            litEstadoBadge.Text = string.Format("<span class='{0}'>{1}</span>", css,
                                System.Web.HttpUtility.HtmlEncode(dr["Estado"].ToString()));
                        }
                        else
                        {
                            Response.Redirect("BandejaTrabajo.aspx");
                        }
                    }
                }
            }
        }

        private void CargarDropdowns(int idDoc)
        {
            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                CargarDropdownTipo(cn, idDoc, "REV", ddlRevisor);
                CargarDropdownTipo(cn, idDoc, "FIR", ddlFirmante);
            }
        }

        private void CargarDropdownTipo(SqlConnection cn, int idDoc, string tipo, DropDownList ddl)
        {
            string sql = @"SELECT u.LoginUsuario
                           FROM UsuarioSistema u
                           JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                           WHERE u.Activo = 1 AND m.Codigo = @tipo
                             AND u.LoginUsuario NOT IN (
                                 SELECT dp.LoginUsuario
                                 FROM DocumentoParticipante dp
                                 JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                 WHERE dp.IdDocumento = @id AND mt.Codigo = @tipo)
                           ORDER BY u.LoginUsuario";

            ddl.Items.Clear();
            ddl.Items.Add(new ListItem("-- Seleccionar --", ""));
            using (var cmd = new SqlCommand(sql, cn))
            {
                cmd.Parameters.AddWithValue("@tipo", tipo);
                cmd.Parameters.AddWithValue("@id", idDoc);
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        ddl.Items.Add(new ListItem(dr["LoginUsuario"].ToString(), dr["LoginUsuario"].ToString()));
                }
            }
        }

        // ============================================================
        // CARGAR LISTAS
        // ============================================================
        private void CargarRevisores(int idDoc)
        {
            string sql = @"SELECT dp.IdParticipante, dp.LoginUsuario,
                                  ISNULL(mr.Codigo, 'PEN') AS EstadoCod
                           FROM DocumentoParticipante dp
                           JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           LEFT JOIN Maestro mr ON dp.EstadoParticipante = mr.IdMaestro
                           WHERE dp.IdDocumento = @id AND mt.Codigo = 'REV'
                           ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";

            var lista = new List<object>();
            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string est = dr["EstadoCod"].ToString().ToUpper();
                            string css = est == "OBS" ? "est-obs" : (est == "FIR" || est == "REG") ? "est-ok" : "";
                            lista.Add(new {
                                IdParticipante = Convert.ToInt32(dr["IdParticipante"]),
                                Login          = dr["LoginUsuario"].ToString(),
                                EstadoCss      = css
                            });
                        }
                    }
                }
            }

            pnlRevisoresVacio.Visible  = lista.Count == 0;
            rptRevisores.DataSource    = lista;
            rptRevisores.DataBind();
        }

        private void CargarFirmantes(int idDoc)
        {
            string sql = @"SELECT dp.IdParticipante, dp.LoginUsuario, dp.OrdenSecuencial
                           FROM DocumentoParticipante dp
                           JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           WHERE dp.IdDocumento = @id AND mt.Codigo = 'FIR'
                           ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";

            var lista = new List<object>();
            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new {
                                IdParticipante = Convert.ToInt32(dr["IdParticipante"]),
                                Login          = dr["LoginUsuario"].ToString(),
                                Orden          = dr["OrdenSecuencial"] == DBNull.Value ? 0 : Convert.ToInt32(dr["OrdenSecuencial"])
                            });
                        }
                    }
                }
            }

            // Calcular si puede subir/bajar
            var conFlags = new List<object>();
            for (int i = 0; i < lista.Count; i++)
            {
                dynamic item = lista[i];
                conFlags.Add(new {
                    IdParticipante = (int)item.IdParticipante,
                    Login          = (string)item.Login,
                    Orden          = (int)item.Orden,
                    PuedeSubir     = i > 0,
                    PuedeBajar     = i < lista.Count - 1
                });
            }

            pnlFirmantesVacio.Visible  = conFlags.Count == 0;
            rptFirmantes.DataSource    = conFlags;
            rptFirmantes.DataBind();
        }

        // ============================================================
        // EVENTOS — REVISORES
        // ============================================================
        protected void btnAgregarRevisor_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string login = ddlRevisor.SelectedValue;
            if (string.IsNullOrEmpty(login)) { MostrarMsg("Seleccione un revisor.", false); return; }

            string sql = @"INSERT INTO DocumentoParticipante
                               (IdDocumento, LoginUsuario, IdTipoParticipante, OrdenSecuencial,
                                EstadoParticipante, FechaAsignacion, Activo)
                           VALUES (
                               @idDoc, @login,
                               (SELECT IdMaestro FROM Maestro WHERE Codigo='REV' AND Tipo='TIPO_PARTICIPANTE'),
                               ISNULL((SELECT MAX(dp2.OrdenSecuencial)
                                       FROM DocumentoParticipante dp2
                                       JOIN Maestro mt2 ON dp2.IdTipoParticipante=mt2.IdMaestro
                                       WHERE dp2.IdDocumento=@idDoc AND mt2.Codigo='REV'), 0) + 1,
                               (SELECT IdMaestro FROM Maestro WHERE Codigo='PEN' AND Tipo='ESTADO_PARTICIPANTE'),
                               GETDATE(), 1)";

            try
            {
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd.Parameters.AddWithValue("@login", login);
                        cmd.ExecuteNonQuery();
                    }
                }
                CargarDropdowns(idDoc);
                MostrarMsg("Revisor agregado correctamente.", true);
            }
            catch (Exception ex) { MostrarMsg("Error al agregar revisor: " + ex.Message, false); }
        }

        protected void rptRevisores_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            int idPart = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Eliminar")
            {
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand("DELETE FROM DocumentoParticipante WHERE IdParticipante=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idPart);
                        cmd.ExecuteNonQuery();
                    }
                }
                CargarDropdowns(idDoc);
                MostrarMsg("Revisor eliminado.", true);
            }
        }

        // ============================================================
        // EVENTOS — FIRMANTES
        // ============================================================
        protected void btnAgregarFirmante_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string login = ddlFirmante.SelectedValue;
            if (string.IsNullOrEmpty(login)) { MostrarMsg("Seleccione un firmante.", false); return; }

            string sql = @"INSERT INTO DocumentoParticipante
                               (IdDocumento, LoginUsuario, IdTipoParticipante, OrdenSecuencial,
                                EstadoParticipante, FechaAsignacion, Activo)
                           VALUES (
                               @idDoc, @login,
                               (SELECT IdMaestro FROM Maestro WHERE Codigo='FIR' AND Tipo='TIPO_PARTICIPANTE'),
                               ISNULL((SELECT MAX(dp2.OrdenSecuencial)
                                       FROM DocumentoParticipante dp2
                                       JOIN Maestro mt2 ON dp2.IdTipoParticipante=mt2.IdMaestro
                                       WHERE dp2.IdDocumento=@idDoc AND mt2.Codigo='FIR'), 0) + 1,
                               (SELECT IdMaestro FROM Maestro WHERE Codigo='PEN' AND Tipo='ESTADO_PARTICIPANTE'),
                               GETDATE(), 1)";

            try
            {
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd.Parameters.AddWithValue("@login", login);
                        cmd.ExecuteNonQuery();
                    }
                }
                CargarDropdowns(idDoc);
                MostrarMsg("Firmante agregado correctamente.", true);
            }
            catch (Exception ex) { MostrarMsg("Error al agregar firmante: " + ex.Message, false); }
        }

        protected void rptFirmantes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            int idPart = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Eliminar")
            {
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand("DELETE FROM DocumentoParticipante WHERE IdParticipante=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idPart);
                        cmd.ExecuteNonQuery();
                    }
                }
                RenumerarFirmantes(idDoc);
                CargarDropdowns(idDoc);
                MostrarMsg("Firmante eliminado.", true);
            }
            else if (e.CommandName == "Subir" || e.CommandName == "Bajar")
            {
                IntercambiarOrden(idDoc, idPart, e.CommandName == "Subir");
                MostrarMsg("Orden actualizado.", true);
            }
        }

        private void IntercambiarOrden(int idDoc, int idPart, bool subir)
        {
            // Obtener orden actual y el vecino
            string sqlVecino = subir
                ? @"SELECT TOP 1 IdParticipante, OrdenSecuencial
                    FROM DocumentoParticipante dp
                    JOIN Maestro mt ON dp.IdTipoParticipante=mt.IdMaestro
                    WHERE dp.IdDocumento=@idDoc AND mt.Codigo='FIR'
                      AND dp.OrdenSecuencial < (SELECT OrdenSecuencial FROM DocumentoParticipante WHERE IdParticipante=@id)
                    ORDER BY dp.OrdenSecuencial DESC"
                : @"SELECT TOP 1 IdParticipante, OrdenSecuencial
                    FROM DocumentoParticipante dp
                    JOIN Maestro mt ON dp.IdTipoParticipante=mt.IdMaestro
                    WHERE dp.IdDocumento=@idDoc AND mt.Codigo='FIR'
                      AND dp.OrdenSecuencial > (SELECT OrdenSecuencial FROM DocumentoParticipante WHERE IdParticipante=@id)
                    ORDER BY dp.OrdenSecuencial ASC";

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                int ordenActual, vecinoId, ordenVecino;

                using (var cmd = new SqlCommand("SELECT OrdenSecuencial FROM DocumentoParticipante WHERE IdParticipante=@id", cn))
                {
                    cmd.Parameters.AddWithValue("@id", idPart);
                    ordenActual = Convert.ToInt32(cmd.ExecuteScalar());
                }

                using (var cmd = new SqlCommand(sqlVecino, cn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDoc);
                    cmd.Parameters.AddWithValue("@id", idPart);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return;
                        vecinoId    = Convert.ToInt32(dr["IdParticipante"]);
                        ordenVecino = Convert.ToInt32(dr["OrdenSecuencial"]);
                    }
                }

                using (var tr = cn.BeginTransaction())
                {
                    using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET OrdenSecuencial=@o WHERE IdParticipante=@id", cn, tr))
                    {
                        cmd.Parameters.AddWithValue("@o", ordenVecino);
                        cmd.Parameters.AddWithValue("@id", idPart);
                        cmd.ExecuteNonQuery();
                    }
                    using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET OrdenSecuencial=@o WHERE IdParticipante=@id", cn, tr))
                    {
                        cmd.Parameters.AddWithValue("@o", ordenActual);
                        cmd.Parameters.AddWithValue("@id", vecinoId);
                        cmd.ExecuteNonQuery();
                    }
                    tr.Commit();
                }
            }
        }

        private void RenumerarFirmantes(int idDoc)
        {
            // Tras eliminar un firmante, renumerar el orden secuencialmente
            string sqlSelect = @"SELECT IdParticipante FROM DocumentoParticipante dp
                                 JOIN Maestro mt ON dp.IdTipoParticipante=mt.IdMaestro
                                 WHERE dp.IdDocumento=@id AND mt.Codigo='FIR'
                                 ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                var ids = new List<int>();
                using (var cmd = new SqlCommand(sqlSelect, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read()) ids.Add(Convert.ToInt32(dr["IdParticipante"]));
                }
                using (var tr = cn.BeginTransaction())
                {
                    for (int i = 0; i < ids.Count; i++)
                    {
                        using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET OrdenSecuencial=@o WHERE IdParticipante=@id", cn, tr))
                        {
                            cmd.Parameters.AddWithValue("@o", i + 1);
                            cmd.Parameters.AddWithValue("@id", ids[i]);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    tr.Commit();
                }
            }
        }

        // ============================================================
        // UTILIDADES
        // ============================================================
        private void MostrarMsg(string msg, bool ok)
        {
            lblMsg.Text     = msg;
            lblMsg.CssClass = ok ? "alert alert-ok" : "alert alert-err";
            lblMsg.Visible  = true;
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
