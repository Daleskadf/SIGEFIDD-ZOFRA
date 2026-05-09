using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
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
            CargarHistorial(idDoc);
        }

        // ============================================================
        // CARGA INICIAL
        // ============================================================
        private void CargarInfoDocumento(int idDoc)
        {
            string sql = @"SELECT d.Asunto, d.CodigoDocumento, me.Descripcion AS Estado, me.Codigo AS EstadoCod,
                                  d.FechaLimiteRevision, d.FechaLimiteAprobacion, ISNULL(d.Prioridad,'MEDIA') AS Prioridad
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
                            litAsunto.Text  = HttpUtility.HtmlEncode(dr["Asunto"].ToString());
                            litCodigo.Text  = HttpUtility.HtmlEncode(dr["CodigoDocumento"].ToString());
                            string est      = dr["EstadoCod"].ToString();
                            string css      = (est == "PEN" || est == "FPAR") ? "badge badge-firma" : "badge badge-estado";
                            litEstadoBadge.Text = string.Format("<span class='{0}'>{1}</span>", css,
                                HttpUtility.HtmlEncode(dr["Estado"].ToString()));
                            CultureInfo pe  = CultureInfo.GetCultureInfo("es-PE");
                            DateTime fRev   = Convert.ToDateTime(dr["FechaLimiteRevision"]);
                            DateTime fApr   = Convert.ToDateTime(dr["FechaLimiteAprobacion"]);
                            litPlazosActuales.Text = "<p style='font-size:11px;color:#555;background:#f0f7ff;border-radius:6px;padding:8px 10px;margin-bottom:10px'>" +
                                "<strong>Actual rev.:</strong> " + HttpUtility.HtmlEncode(fRev.ToString("g", pe)) +
                                "&nbsp;&nbsp;<strong>Actual apr.:</strong> " + HttpUtility.HtmlEncode(fApr.ToString("g", pe)) + "</p>";
                            txtNuevaFechaRevision.Text   = fRev.ToString("yyyy-MM-ddTHH:mm");
                            txtNuevaFechaAprobacion.Text = fApr.ToString("yyyy-MM-ddTHH:mm");
                            txtEditAsunto.Text = dr["Asunto"].ToString();
                            string prior = dr["Prioridad"].ToString().ToUpper();
                            ddlEditPrioridad.SelectedValue = (prior == "ALTA" || prior == "MEDIA" || prior == "BAJA") ? prior : "MEDIA";
                        }
                        else
                        {
                            Response.Redirect("BandejaTrabajo.aspx");
                        }
                    }
                }
            }
        }

        private void CargarHistorial(int idDoc)
        {
            string sql = @"SELECT h.FechaCambio, h.DetalleAccion, h.LoginUsuarioAccion,
                                  ma.Descripcion AS EstAnterior, mn.Descripcion AS EstNuevo
                           FROM HistorialDocumento h
                           JOIN Maestro ma ON h.IdEstadoAnterior = ma.IdMaestro
                           JOIN Maestro mn ON h.IdEstadoNuevo    = mn.IdMaestro
                           WHERE h.IdDocumento = @id
                           ORDER BY h.FechaCambio DESC";

            var sb = new System.Text.StringBuilder();
            CultureInfo pe = CultureInfo.GetCultureInfo("es-PE");
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
                            string fecha   = Convert.ToDateTime(dr["FechaCambio"]).ToString("g", pe);
                            string detalle = HttpUtility.HtmlEncode(dr["DetalleAccion"].ToString());
                            string login   = HttpUtility.HtmlEncode(dr["LoginUsuarioAccion"].ToString());
                            string estAnt  = HttpUtility.HtmlEncode(dr["EstAnterior"].ToString());
                            string estNuev = HttpUtility.HtmlEncode(dr["EstNuevo"].ToString());
                            sb.Append("<div style='position:relative;padding-left:26px;padding-bottom:14px;font-size:12px'>");
                            sb.Append("<div style='position:absolute;left:5px;top:3px;width:12px;height:12px;border-radius:50%;background:#1a2a4a;border:2px solid #fff;box-shadow:0 0 0 1px #dde1f0'></div>");
                            sb.AppendFormat("<div style='color:#888;font-size:11px;margin-bottom:3px'>{0} &mdash; <strong>{1}</strong></div>", fecha, login);
                            sb.AppendFormat("<div style='color:#333;font-weight:600;margin-bottom:2px'>{0}</div>", detalle);
                            sb.AppendFormat("<div style='color:#aaa;font-size:11px'>{0} &rarr; {1}</div>", estAnt, estNuev);
                            sb.Append("</div>");
                        }
                    }
                }
            }
            litHistorial.Text = sb.Length > 0 ? sb.ToString() : "<p style='color:#bbb;font-size:12px;text-align:center;padding:16px'>Sin eventos registrados.</p>";
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
                ReiniciarFlujo(idDoc, "revisor agregado: " + login);
                CargarDropdowns(idDoc);
                CargarRevisores(idDoc);
                CargarFirmantes(idDoc);
                CargarHistorial(idDoc);
                MostrarMsg("Revisor agregado. El flujo fue reiniciado.", true);
            }
            catch (Exception ex) { MostrarMsg("Error al agregar revisor: " + ex.Message, false); }
        }

        protected void rptRevisores_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);

            if (e.CommandName == "Eliminar")
            {
                int idPart = Convert.ToInt32(e.CommandArgument);
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    using (var cmd = new SqlCommand("DELETE FROM DocumentoParticipante WHERE IdParticipante=@id", cn))
                    {
                        cmd.Parameters.AddWithValue("@id", idPart);
                        cmd.ExecuteNonQuery();
                    }
                }
                pnlReasignar.Visible = false;
                ReiniciarFlujo(idDoc, "revisor eliminado");
                CargarDropdowns(idDoc);
                CargarRevisores(idDoc);
                CargarFirmantes(idDoc);
                CargarHistorial(idDoc);
                MostrarMsg("Revisor eliminado. El flujo fue reiniciado.", true);
            }
            else if (e.CommandName == "Reasignar")
            {
                string[] partes = e.CommandArgument.ToString().Split('|');
                hfReasignarId.Value    = partes[0];
                litReasignarLogin.Text = System.Web.HttpUtility.HtmlEncode(partes[1]);

                ddlReasignarNuevo.Items.Clear();
                ddlReasignarNuevo.Items.Add(new ListItem("-- Seleccionar nuevo revisor --", ""));
                using (var cn = new SqlConnection(ConnStr))
                {
                    cn.Open();
                    string sql = @"SELECT u.LoginUsuario FROM UsuarioSistema u
                                   JOIN Maestro m ON u.IdRolSistema=m.IdMaestro
                                   WHERE u.Activo=1 AND m.Codigo='REV'
                                     AND u.LoginUsuario != @actual
                                     AND u.LoginUsuario NOT IN (
                                         SELECT dp.LoginUsuario FROM DocumentoParticipante dp
                                         JOIN Maestro mt ON dp.IdTipoParticipante=mt.IdMaestro
                                         WHERE dp.IdDocumento=@idDoc AND mt.Codigo='REV' AND dp.Activo=1)
                                   ORDER BY u.LoginUsuario";
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@actual", partes[1]);
                        cmd.Parameters.AddWithValue("@idDoc",  idDoc);
                        using (var dr = cmd.ExecuteReader())
                            while (dr.Read())
                                ddlReasignarNuevo.Items.Add(new ListItem(dr["LoginUsuario"].ToString(), dr["LoginUsuario"].ToString()));
                    }
                }
                pnlReasignar.Visible = true;
            }
        }

        protected void btnConfirmarReasignacion_Click(object sender, EventArgs e)
        {
            int idDoc  = int.Parse(hfDocId.Value);
            int idPart = int.Parse(hfReasignarId.Value);
            string nuevo = ddlReasignarNuevo.SelectedValue;
            if (string.IsNullOrEmpty(nuevo)) { MostrarMsg("Seleccione el nuevo revisor.", false); return; }

            string loginAdm = Session["LoginUsuario"].ToString();
            string anterior = litReasignarLogin.Text;

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        int idEstadoPen;
                        using (var cmd = new SqlCommand("SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_PARTICIPANTE' AND Codigo='PEN'", cn, tx))
                            idEstadoPen = Convert.ToInt32(cmd.ExecuteScalar());

                        using (var cmd = new SqlCommand(@"UPDATE DocumentoParticipante
                                                          SET LoginUsuario=@nuevo, EstadoParticipante=@est, FechaAsignacion=GETDATE()
                                                          WHERE IdParticipante=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@nuevo", nuevo);
                            cmd.Parameters.AddWithValue("@est",   idEstadoPen);
                            cmd.Parameters.AddWithValue("@id",    idPart);
                            cmd.ExecuteNonQuery();
                        }

                        int idEstadoDoc;
                        using (var cmd = new SqlCommand("SELECT IdEstadoDocumento FROM Documento WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            idEstadoDoc = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                                                          (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                                                          VALUES (@idDoc,@est,@est,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idDoc", idDoc);
                            cmd.Parameters.AddWithValue("@est",   idEstadoDoc);
                            cmd.Parameters.AddWithValue("@login", loginAdm);
                            cmd.Parameters.AddWithValue("@det",   "ADM reasignó revisor: " + anterior + " → " + nuevo);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                        ReiniciarFlujo(idDoc, "revisor reasignado: " + anterior + " → " + nuevo);
                        pnlReasignar.Visible = false;
                        CargarDropdowns(idDoc);
                        CargarRevisores(idDoc);
                        CargarFirmantes(idDoc);
                        CargarHistorial(idDoc);
                        MostrarMsg("Revisor reasignado: " + anterior + " → " + nuevo + ". El flujo fue reiniciado.", true);
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        protected void btnCancelarReasignacion_Click(object sender, EventArgs e)
        {
            pnlReasignar.Visible = false;
            hfReasignarId.Value  = "";
        }

        // ============================================================
        // EVENTOS — FIRMANTES
        // ============================================================
        protected void btnAgregarFirmante_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string login = ddlFirmante.SelectedValue;
            if (string.IsNullOrEmpty(login)) { MostrarMsg("Seleccione un firmante.", false); return; }

            // Los firmantes se agregan DOS VECES en la BD:
            // 1. Como REV (Orden=0) para que puedan revisar en fase REV
            // 2. Como FIR (Orden=secuencial) para que puedan firmar en fase PEN/FPAR

            using (var cn = new SqlConnection(ConnStr))
            {
                try
                {
                    cn.Open();
                    using (var tx = cn.BeginTransaction())
                    {
                        try
                        {
                            // PRIMERA INSERCIÓN: Como REVISOR (Orden=0)
                            string sqlRev = @"INSERT INTO DocumentoParticipante
                                           (IdDocumento, LoginUsuario, IdTipoParticipante, OrdenSecuencial,
                                            EstadoParticipante, FechaAsignacion, Activo)
                                       VALUES (
                                           @idDoc, @login,
                                           (SELECT IdMaestro FROM Maestro WHERE Codigo='REV' AND Tipo='TIPO_PARTICIPANTE'),
                                           0,
                                           (SELECT IdMaestro FROM Maestro WHERE Codigo='PEN' AND Tipo='ESTADO_PARTICIPANTE'),
                                           GETDATE(), 1)";

                            using (var cmd = new SqlCommand(sqlRev, cn, tx))
                            {
                                cmd.Parameters.AddWithValue("@idDoc", idDoc);
                                cmd.Parameters.AddWithValue("@login", login);
                                cmd.ExecuteNonQuery();
                            }

                            // SEGUNDA INSERCIÓN: Como FIRMANTE (Orden=secuencial)
                            string sqlFir = @"INSERT INTO DocumentoParticipante
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

                            using (var cmd = new SqlCommand(sqlFir, cn, tx))
                            {
                                cmd.Parameters.AddWithValue("@idDoc", idDoc);
                                cmd.Parameters.AddWithValue("@login", login);
                                cmd.ExecuteNonQuery();
                            }

                            tx.Commit();
                            ReiniciarFlujo(idDoc, "firmante agregado: " + login);
                            CargarDropdowns(idDoc);
                            CargarRevisores(idDoc);
                            CargarFirmantes(idDoc);
                            CargarHistorial(idDoc);
                            MostrarMsg("Firmante agregado. El flujo fue reiniciado.", true);
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
                catch (Exception ex) { MostrarMsg("Error al agregar firmante: " + ex.Message, false); }
            }
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
                ReiniciarFlujo(idDoc, "firmante eliminado");
                CargarDropdowns(idDoc);
                CargarRevisores(idDoc);
                CargarFirmantes(idDoc);
                CargarHistorial(idDoc);
                MostrarMsg("Firmante eliminado. El flujo fue reiniciado.", true);
            }
            else if (e.CommandName == "Subir" || e.CommandName == "Bajar")
            {
                IntercambiarOrden(idDoc, idPart, e.CommandName == "Subir");
                ReiniciarFlujo(idDoc, "orden de firmantes modificado");
                CargarRevisores(idDoc);
                CargarFirmantes(idDoc);
                CargarHistorial(idDoc);
                MostrarMsg("Orden actualizado. El flujo fue reiniciado.", true);
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

        protected void btnGuardarMetadatos_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string asunto = txtEditAsunto.Text.Trim();
            if (string.IsNullOrEmpty(asunto)) { MostrarMsg("El asunto no puede estar vacío.", false); return; }

            string prioridad  = ddlEditPrioridad.SelectedValue;
            string loginAdm   = Session["LoginUsuario"].ToString();

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        string asuntoAnterior;
                        using (var cmd = new SqlCommand("SELECT Asunto FROM Documento WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            asuntoAnterior = cmd.ExecuteScalar().ToString();
                        }

                        using (var cmd = new SqlCommand("UPDATE Documento SET Asunto=@asunto, Prioridad=@prior WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@asunto", asunto);
                            cmd.Parameters.AddWithValue("@prior",  prioridad);
                            cmd.Parameters.AddWithValue("@id",     idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        int idEstado;
                        using (var cmd = new SqlCommand("SELECT IdEstadoDocumento FROM Documento WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            idEstado = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                            (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                            VALUES (@id,@est,@est,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id",    idDoc);
                            cmd.Parameters.AddWithValue("@est",   idEstado);
                            cmd.Parameters.AddWithValue("@login", loginAdm);
                            cmd.Parameters.AddWithValue("@det",   string.Format("ADM editó metadatos. Asunto: '{0}' → '{1}'. Prioridad: {2}", asuntoAnterior, asunto, prioridad));
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

            CargarHistorial(idDoc);
            MostrarMsg("Metadatos actualizados correctamente.", true);
        }

        // ============================================================
        // REINICIO DE FLUJO
        // ============================================================
        private void ReiniciarFlujo(int idDoc, string motivo)
        {
            string loginAdm = Session["LoginUsuario"].ToString();
            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        int idEstadoRev, idEstadoActual, idEstadoPen;
                        using (var cmd = new SqlCommand(@"SELECT
                            (SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_DOC' AND Codigo='REV'),
                            d.IdEstadoDocumento,
                            (SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_PARTICIPANTE' AND Codigo='PEN')
                            FROM Documento d WHERE d.IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            using (var dr = cmd.ExecuteReader())
                            {
                                dr.Read();
                                idEstadoRev    = Convert.ToInt32(dr[0]);
                                idEstadoActual = Convert.ToInt32(dr[1]);
                                idEstadoPen    = Convert.ToInt32(dr[2]);
                            }
                        }

                        using (var cmd = new SqlCommand("UPDATE Documento SET IdEstadoDocumento=@rev WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@rev", idEstadoRev);
                            cmd.Parameters.AddWithValue("@id",  idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET EstadoParticipante=@pen, Activo=1 WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@pen", idEstadoPen);
                            cmd.Parameters.AddWithValue("@id",  idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                            (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                            VALUES (@id,@ant,@nuevo,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id",    idDoc);
                            cmd.Parameters.AddWithValue("@ant",   idEstadoActual);
                            cmd.Parameters.AddWithValue("@nuevo", idEstadoRev);
                            cmd.Parameters.AddWithValue("@login", loginAdm);
                            cmd.Parameters.AddWithValue("@det",   "ADM reinició el flujo: " + motivo);
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

        protected void btnAmpliarPlazo_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);

            string motivo = txtMotivoAmpliacion.Text.Trim();
            if (string.IsNullOrEmpty(motivo)) { MostrarMsg("Debe ingresar el motivo de la ampliación.", false); return; }

            DateTime nuevaRev, nuevaApr;
            if (!DateTime.TryParse(txtNuevaFechaRevision.Text, out nuevaRev) || nuevaRev <= DateTime.Now)
            { MostrarMsg("La fecha límite de revisión debe ser una fecha futura válida.", false); return; }
            if (!DateTime.TryParse(txtNuevaFechaAprobacion.Text, out nuevaApr) || nuevaApr <= nuevaRev)
            { MostrarMsg("La fecha límite de aprobación debe ser posterior a la de revisión.", false); return; }

            string loginAdm = Session["LoginUsuario"].ToString();
            CultureInfo pe  = CultureInfo.GetCultureInfo("es-PE");

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        DateTime anteriorRev, anteriorApr;
                        int idEstadoActual;
                        using (var cmd = new SqlCommand("SELECT FechaLimiteRevision, FechaLimiteAprobacion, IdEstadoDocumento FROM Documento WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            using (var dr = cmd.ExecuteReader())
                            {
                                dr.Read();
                                anteriorRev   = Convert.ToDateTime(dr[0]);
                                anteriorApr   = Convert.ToDateTime(dr[1]);
                                idEstadoActual = Convert.ToInt32(dr[2]);
                            }
                        }

                        using (var cmd = new SqlCommand("UPDATE Documento SET FechaLimiteRevision=@rev, FechaLimiteAprobacion=@apr WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@rev", nuevaRev);
                            cmd.Parameters.AddWithValue("@apr", nuevaApr);
                            cmd.Parameters.AddWithValue("@id",  idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        string detalle = string.Format("ADM amplió plazo. Rev: {0} → {1}. Apr: {2} → {3}. Motivo: {4}",
                            anteriorRev.ToString("g", pe), nuevaRev.ToString("g", pe),
                            anteriorApr.ToString("g", pe), nuevaApr.ToString("g", pe), motivo);

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                            (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                            VALUES (@id,@est,@est,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id",    idDoc);
                            cmd.Parameters.AddWithValue("@est",   idEstadoActual);
                            cmd.Parameters.AddWithValue("@login", loginAdm);
                            cmd.Parameters.AddWithValue("@det",   detalle);
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

            Response.Redirect(Request.Url.PathAndQuery);
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
