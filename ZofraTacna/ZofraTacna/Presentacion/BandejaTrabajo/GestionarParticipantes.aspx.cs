using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZofraTacna.Datos;
using ZofraTacna.LogicaNegocio;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public partial class GestionarParticipantes : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
        private readonly ModuloGestionDocumental _modulo = new ModuloGestionDocumental();
        private readonly RepositorioDocumentos _repoDocs = new RepositorioDocumentos();
        private readonly RepositorioBloqueoFlujo _repoBloqueo = new RepositorioBloqueoFlujo();
        protected string GpLockToken
        {
            get { return (ViewState["GpLockToken"] as string) ?? ""; }
        }

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
                ViewState["GpLockToken"] = Guid.NewGuid().ToString("N");
                hfDocId.Value = idDoc.ToString();
                CargarCombosEdit();
                CargarInfoDocumento(idDoc);
                CargarEmpleadosListBox();
                RegistrarBootParticipantesCliente(idDoc);
            }
            else
            {
                idDoc = int.Parse(hfDocId.Value);
            }

            // Registrar/tocar bloqueo ADM_EDIT
            string loginBloqueo = Session["LoginUsuario"].ToString();
            _repoBloqueo.RegistrarOTocarBloqueo(idDoc, "ADM_EDIT", loginBloqueo, GpLockToken);

            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"]?.ToString() ?? "";

            CargarHistorial(idDoc);
        }

        // ============================================================
        // CARGA INICIAL
        // ============================================================
        private void CargarCombosEdit()
        {
            ddlEditCategoria.Items.Clear();
            ddlEditCategoria.Items.Add(new ListItem("Seleccionar...", ""));
            foreach (string cat in _modulo.ObtenerCategorias())
            {
                string[] partes = cat.Split('|');
                if (partes.Length >= 2)
                    ddlEditCategoria.Items.Add(new ListItem(partes[1], partes[0]));
            }

            ddlEditArea.Items.Clear();
            ddlEditArea.Items.Add(new ListItem("Seleccionar...", ""));
            foreach (string u in _modulo.ObtenerUnidadesOrganicas())
            {
                string[] partes = u.Split('|');
                if (partes.Length >= 2)
                    ddlEditArea.Items.Add(new ListItem(partes[1], partes[0]));
            }
        }

        private void CargarInfoDocumento(int idDoc)
        {
            string sql = @"SELECT d.Asunto, d.CodigoDocumento, me.Descripcion AS Estado, me.Codigo AS EstadoCod,
                                  d.FechaLimiteRevision, d.FechaLimiteAprobacion, ISNULL(d.Prioridad,'MEDIA') AS Prioridad,
                                  d.Descripcion, d.IdTipoDocumento, d.AreaResponsable, d.FechaCreacion
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
                            DateTime fRev   = dr["FechaLimiteRevision"] != DBNull.Value ? Convert.ToDateTime(dr["FechaLimiteRevision"]) : DateTime.Now.AddHours(24);
                            DateTime fApr   = dr["FechaLimiteAprobacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaLimiteAprobacion"]) : DateTime.Now.AddHours(48);

                            txtEditCodigo.Text = dr["CodigoDocumento"].ToString();
                            txtEditAsunto.Text = dr["Asunto"].ToString();
                            txtEditDescripcion.Text = dr["Descripcion"] != DBNull.Value ? dr["Descripcion"].ToString() : "";

                            string idTipo = dr["IdTipoDocumento"].ToString();
                            if (ddlEditCategoria.Items.FindByValue(idTipo) != null)
                                ddlEditCategoria.SelectedValue = idTipo;

                            string idArea = dr["AreaResponsable"].ToString();
                            if (ddlEditArea.Items.FindByValue(idArea) != null)
                                ddlEditArea.SelectedValue = idArea;

                            string prior = dr["Prioridad"].ToString().ToUpperInvariant();
                            ddlEditPrioridad.SelectedValue = (prior == "ALTA" || prior == "MEDIA" || prior == "BAJA") ? prior : "MEDIA";

                            DateTime cre = Convert.ToDateTime(dr["FechaCreacion"]);
                            double thRev = (fRev - cre).TotalHours;
                            double thFir = (fApr - cre).TotalHours;
                            int hRev = thRev > 0 ? (int)Math.Ceiling(thRev) : 24;
                            int hFir = thFir > hRev ? (int)Math.Ceiling(thFir) : hRev + 24;
                            txtEditHorasRevision.Text = Math.Max(1, hRev).ToString(CultureInfo.InvariantCulture);
                            txtEditHorasFirma.Text = Math.Max(hRev + 1, hFir).ToString(CultureInfo.InvariantCulture);

                            int idAdj;
                            string nombrePdf;
                            int tam;
                            if (_repoDocs.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombrePdf, out tam))
                            {
                                string peso = tam < 1024 ? tam + " B" : (tam / 1024.0).ToString("0.##", CultureInfo.InvariantCulture) + " KB";
                                if (tam >= 1024 * 1024)
                                    peso = (tam / (1024.0 * 1024.0)).ToString("0.##", CultureInfo.InvariantCulture) + " MB";
                                litPdfVigente.Text = "<p style=\"font-size:12px;color:#2e7d32;background:#e8f5e9;border-radius:8px;padding:10px 12px;margin-bottom:8px\">" +
                                    "<strong>PDF vigente:</strong> " + HttpUtility.HtmlEncode(nombrePdf ?? "") +
                                    " <span style=\"color:#666\">(" + HttpUtility.HtmlEncode(peso) + ")</span></p>";
                            }
                            else
                                litPdfVigente.Text = "<p style=\"font-size:12px;color:#888;background:#f5f5f5;border-radius:8px;padding:10px 12px;margin-bottom:8px\">No hay PDF vigente en el sistema para este tr&aacute;mite.</p>";

                            // Inyectar versiones archivadas al cliente para el popup de restauraci\u00f3n
                            var archivados = _repoDocs.ObtenerAdjuntosArchivados(idDoc);
                            var jsSerializer = new JavaScriptSerializer();
                            var listaVersiones = new List<Dictionary<string, object>>();
                            CultureInfo culturepe = CultureInfo.GetCultureInfo("es-PE");
                            foreach (var a in archivados)
                            {
                                string fechaStr = a.FechaSuperacion.HasValue
                                    ? a.FechaSuperacion.Value.ToString("g", culturepe)
                                    : a.FechaCreacion.ToString("g", culturepe);
                                string nomArch = string.IsNullOrEmpty(a.NombreArchivo) ? "archivo.pdf" : a.NombreArchivo;
                                var item = new Dictionary<string, object>
                                {
                                    { "id", a.IdAdjunto },
                                    { "nombre", nomArch },
                                    { "fecha", fechaStr }
                                };
                                listaVersiones.Add(item);
                            }
                            ClientScript.RegisterClientScriptBlock(GetType(), "gpVersionesArchivadas",
                                "window.__gpVersionesArchivadas = " + jsSerializer.Serialize(listaVersiones) + ";", true);
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

        private void CargarEmpleadosListBox()
        {
            lstBuscadorParticipantes.Items.Clear();
            foreach (var emp in _modulo.ObtenerEmpleadosDisponibles())
            {
                string texto = emp.LoginUsuario + " - " + (emp.NombreCompleto ?? emp.LoginUsuario);
                lstBuscadorParticipantes.Items.Add(new ListItem(texto, emp.LoginUsuario));
            }
        }

        private void RegistrarBootParticipantesCliente(int idDoc)
        {
            var js = new JavaScriptSerializer();
            string json = js.Serialize(ObtenerParticipantesBootObject(idDoc));
            ClientScript.RegisterClientScriptBlock(GetType(), "gpParticipantesBoot",
                "window.__gpParticipantesBoot = " + json + ";", true);
        }

        private Dictionary<string, object> ObtenerParticipantesBootObject(int idDoc)
        {
            var nombres = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            foreach (var emp in _modulo.ObtenerEmpleadosDisponibles())
            {
                if (!string.IsNullOrEmpty(emp.LoginUsuario))
                    nombres[emp.LoginUsuario] = emp.NombreCompleto ?? emp.LoginUsuario;
            }

            var listaRevisores = new List<object>();
            var listaFirmantes = new List<object>();

            const string sqlRev = @"SELECT dp.LoginUsuario
                FROM DocumentoParticipante dp
                INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                WHERE dp.IdDocumento = @id AND mt.Codigo = 'REV'
                GROUP BY dp.LoginUsuario
                ORDER BY MIN(dp.OrdenSecuencial), MIN(dp.IdParticipante)";

            const string sqlFir = @"SELECT dp.LoginUsuario, dp.OrdenSecuencial
                FROM DocumentoParticipante dp
                INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                WHERE dp.IdDocumento = @id AND mt.Codigo = 'FIR'
                ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sqlRev, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string login = dr["LoginUsuario"].ToString();
                            string nom = nombres.ContainsKey(login) ? nombres[login] : login;
                            listaRevisores.Add(new Dictionary<string, object>
                            {
                                { "login", login },
                                { "nombre", nom }
                            });
                        }
                    }
                }

                using (var cmd = new SqlCommand(sqlFir, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDoc);
                    int idx = 0;
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            idx++;
                            string login = dr["LoginUsuario"].ToString();
                            string nom = nombres.ContainsKey(login) ? nombres[login] : login;
                            int ord = dr["OrdenSecuencial"] != DBNull.Value
                                ? Convert.ToInt32(dr["OrdenSecuencial"], CultureInfo.InvariantCulture)
                                : idx;
                            listaFirmantes.Add(new Dictionary<string, object>
                            {
                                { "login", login },
                                { "nombre", nom },
                                { "orden", ord }
                            });
                        }
                    }
                }
            }

            return new Dictionary<string, object>
            {
                { "revisores", listaRevisores },
                { "firmantes", listaFirmantes }
            };
        }

        private static List<RegistrarParticipanteItem> ParseParticipantesDesdeOculto(string json)
        {
            var list = new List<RegistrarParticipanteItem>();
            if (string.IsNullOrWhiteSpace(json))
                return list;

            var js = new JavaScriptSerializer();
            var raw = js.Deserialize<List<Dictionary<string, object>>>(json);
            if (raw == null)
                return list;

            foreach (var p in raw)
            {
                if (p == null || !p.ContainsKey("login") || p["login"] == null)
                    continue;
                string login = Convert.ToString(p["login"], CultureInfo.InvariantCulture).Trim();
                if (string.IsNullOrEmpty(login))
                    continue;

                string tipo = "REV";
                if (p.ContainsKey("tipo") && p["tipo"] != null)
                    tipo = Convert.ToString(p["tipo"], CultureInfo.InvariantCulture);

                int orden = 0;
                if (p.ContainsKey("orden") && p["orden"] != null)
                    int.TryParse(Convert.ToString(p["orden"], CultureInfo.InvariantCulture), NumberStyles.Integer, CultureInfo.InvariantCulture, out orden);

                list.Add(new RegistrarParticipanteItem { Login = login, Tipo = tipo, Orden = orden });
            }

            return list;
        }

        protected void btnGuardarMetadatos_Click(object sender, EventArgs e)
        {
            int idDoc = int.Parse(hfDocId.Value);
            string codigo = (txtEditCodigo.Text ?? "").Trim();
            string asunto = (txtEditAsunto.Text ?? "").Trim();
            string descripcion = (txtEditDescripcion.Text ?? "").Trim();
            string loginAdm = Session["LoginUsuario"].ToString();

            if (string.IsNullOrEmpty(codigo)) { MostrarMsg("El código del documento es obligatorio.", false); return; }
            if (codigo.Length > 50) { MostrarMsg("El código no puede superar 50 caracteres.", false); return; }
            if (string.IsNullOrEmpty(asunto)) { MostrarMsg("El asunto no puede estar vacío.", false); return; }
            if (string.IsNullOrWhiteSpace(ddlEditCategoria.SelectedValue))
            { MostrarMsg("Seleccione una categoría de documento.", false); return; }
            if (string.IsNullOrWhiteSpace(ddlEditArea.SelectedValue))
            { MostrarMsg("Seleccione el área (unidad orgánica).", false); return; }

            int horasRev, horasFirma;
            if (!int.TryParse((txtEditHorasRevision.Text ?? "").Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out horasRev) || horasRev < 1)
            { MostrarMsg("Plazo de revisión: ingrese un número entero de horas mayor o igual a 1.", false); return; }
            if (!int.TryParse((txtEditHorasFirma.Text ?? "").Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out horasFirma) || horasFirma < horasRev)
            { MostrarMsg("El plazo de firma (horas) debe ser mayor o igual al plazo de revisión.", false); return; }

            var participantes = ParseParticipantesDesdeOculto(hfParticipantes.Value);
            if (participantes.Count == 0)
            {
                MostrarMsg("Debe asignar al menos un revisor o firmante.", false);
                return;
            }

            int idTipo = int.Parse(ddlEditCategoria.SelectedValue, CultureInfo.InvariantCulture);
            int idArea = int.Parse(ddlEditArea.SelectedValue, CultureInfo.InvariantCulture);
            string prioridad = ddlEditPrioridad.SelectedValue ?? "MEDIA";

            DateTime limRev = DateTime.Now.AddHours(horasRev);
            DateTime limFir = DateTime.Now.AddHours(horasFirma);

            byte[] pdfBytes = null;
            string nombrePdfNuevo = null;
            bool subePdf = filePdfReemplazo.HasFile && filePdfReemplazo.PostedFile != null && filePdfReemplazo.PostedFile.ContentLength > 0;
            if (subePdf)
            {
                if (!string.Equals(Path.GetExtension(filePdfReemplazo.FileName), ".pdf", StringComparison.OrdinalIgnoreCase))
                { MostrarMsg("Solo se permiten archivos PDF.", false); return; }
                if (filePdfReemplazo.PostedFile.ContentLength > 15 * 1024 * 1024)
                { MostrarMsg("El archivo supera los 15 MB.", false); return; }
                using (var br = new BinaryReader(filePdfReemplazo.PostedFile.InputStream))
                    pdfBytes = br.ReadBytes(filePdfReemplazo.PostedFile.ContentLength);
                if (pdfBytes == null || pdfBytes.Length == 0)
                { MostrarMsg("El PDF está vacío.", false); return; }
                nombrePdfNuevo = DateTime.Now.ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture) + "_" + Path.GetFileName(filePdfReemplazo.FileName);
            }

            // Leer el ID de versión restaurada (si aplica)
            int idAdjRestaurado = 0;
            int.TryParse((hfRestoredAdjId.Value ?? "").Trim(), out idAdjRestaurado);

            string codigoAnterior;
            using (var cn0 = new SqlConnection(ConnStr))
            {
                cn0.Open();
                using (var cmd0 = new SqlCommand("SELECT CodigoDocumento FROM Documento WHERE IdDocumento=@id AND Activo=1", cn0))
                {
                    cmd0.Parameters.AddWithValue("@id", idDoc);
                    object o = cmd0.ExecuteScalar();
                    if (o == null || o == DBNull.Value) { Response.Redirect("BandejaTrabajo.aspx"); return; }
                    codigoAnterior = o.ToString();
                }
            }

            if (!string.Equals(codigo, codigoAnterior, StringComparison.OrdinalIgnoreCase))
            {
                using (var cnU = new SqlConnection(ConnStr))
                {
                    cnU.Open();
                    using (var cmdU = new SqlCommand(
                               "SELECT COUNT(*) FROM Documento WHERE Activo=1 AND CodigoDocumento=@c AND IdDocumento<>@id", cnU))
                    {
                        cmdU.Parameters.AddWithValue("@c", codigo);
                        cmdU.Parameters.AddWithValue("@id", idDoc);
                        if (Convert.ToInt32(cmdU.ExecuteScalar()) > 0)
                        {
                            MostrarMsg("Ya existe otro documento activo con ese código.", false);
                            return;
                        }
                    }
                }
            }

            using (var cn = new SqlConnection(ConnStr))
            {
                cn.Open();
                using (var tx = cn.BeginTransaction())
                {
                    try
                    {
                        int idEstado;
                        using (var cmd = new SqlCommand("SELECT IdEstadoDocumento FROM Documento WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            idEstado = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        using (var cmd = new SqlCommand(@"UPDATE Documento SET
                            CodigoDocumento=@cod,
                            Asunto=@asunto,
                            Descripcion=@desc,
                            IdTipoDocumento=@tipo,
                            AreaResponsable=@area,
                            AreaCategoria=@asunto,
                            Prioridad=@prior,
                            FechaLimiteRevision=@limRev,
                            FechaLimiteAprobacion=@limFir,
                            FechaModificacion=GETDATE(),
                            IDUsuarioModificador=@adm
                            WHERE IdDocumento=@id", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@cod", codigo);
                            cmd.Parameters.AddWithValue("@asunto", asunto);
                            cmd.Parameters.AddWithValue("@desc", (object)descripcion ?? "");
                            cmd.Parameters.AddWithValue("@tipo", idTipo);
                            cmd.Parameters.AddWithValue("@area", idArea);
                            cmd.Parameters.AddWithValue("@prior", prioridad);
                            cmd.Parameters.AddWithValue("@limRev", limRev);
                            cmd.Parameters.AddWithValue("@limFir", limFir);
                            cmd.Parameters.AddWithValue("@adm", loginAdm.Length > 15 ? loginAdm.Substring(0, 15) : loginAdm);
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            cmd.ExecuteNonQuery();
                        }

                        string detHist = string.Format(
                            CultureInfo.InvariantCulture,
                            "ADM actualizó datos del documento. Código: {0} → {1}. Categoría/área/plazos/prioridad/asunto actualizados.{2}",
                            codigoAnterior, codigo, subePdf ? " PDF reemplazado." : "");

                        using (var cmd = new SqlCommand(@"INSERT INTO HistorialDocumento
                            (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion,FechaCambio)
                            VALUES (@id,@est,@est,@login,@det,GETDATE())", cn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDoc);
                            cmd.Parameters.AddWithValue("@est", idEstado);
                            cmd.Parameters.AddWithValue("@login", loginAdm);
                            cmd.Parameters.AddWithValue("@det", detHist);
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

            try
            {
                _modulo.CrearUsuariosParticipantes(participantes);
                _repoDocs.ReemplazarParticipantesDesdeLista(idDoc, participantes);
            }
            catch (ArgumentException ex)
            {
                MostrarMsg(ex.Message, false);
                return;
            }
            catch (Exception ex)
            {
                MostrarMsg("Error al guardar participantes: " + ex.Message, false);
                return;
            }

            if (subePdf && pdfBytes != null)
            {
                // Nuevo PDF tiene prioridad: descarta cualquier restauración pendiente
                _repoDocs.ReemplazarPdfConHistorial(idDoc, pdfBytes, nombrePdfNuevo, loginAdm,
                    "Administrador reemplazó PDF desde Gestionar participantes.");
            }
            else if (idAdjRestaurado > 0)
            {
                // No hay PDF nuevo: aplicar restauración de versión archivada
                try
                {
                    _repoDocs.RestaurarVersionArchivada(idDoc, idAdjRestaurado, loginAdm,
                        "Administrador restauró versión anterior desde Gestionar participantes.");
                }
                catch (Exception ex)
                {
                    MostrarMsg("Error al restaurar versión: " + ex.Message, false);
                    return;
                }
            }

            ReiniciarFlujo(idDoc, "actualización de datos del documento / PDF por administrador");

            try { _modulo.NotificarRevisores(idDoc); }
            catch { /* correo opcional */ }

            // Liberar bloqueo ADM_EDIT
            _repoBloqueo.LiberarBloqueo(idDoc, "ADM_EDIT", GpLockToken);

            ClientScript.RegisterStartupScript(GetType(), "guardadoExitoso",
                "window.__gpMostrarExito = true;", true);
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

                        using (var cmd = new SqlCommand("UPDATE DocumentoParticipante SET EstadoParticipante=@pen WHERE IdDocumento=@id", cn, tx))
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

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
        }
    }
}
