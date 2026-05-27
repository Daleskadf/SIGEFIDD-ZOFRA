using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class BandejaTrabajo : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            string rol = Session["RolCodigo"].ToString();
            if (rol != "ADM" && rol != "REV" && rol != "FIR") { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }
            if (!IsPostBack) CargarBandeja(rol);
        }

        private void CargarBandeja(string rol)
        {
            string login = Session["LoginUsuario"].ToString();
            litAvatar.Text = login.Length >= 2 ? login.Substring(0, 2).ToUpper() : login.ToUpper();
            litNombre.Text = login;
            litRol.Text    = Session["RolNombre"].ToString();

            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();

                int badge = GetBadgeCount(cn, rol, login);
                litSidebarNav.Text = BuildNav(rol, badge);

                string filtroRol = "";
                if (rol == "REV" || rol == "FIR")
                {
                    filtroRol = @" AND EXISTS (
                                        SELECT 1
                                        FROM DocumentoParticipante dpf
                                        INNER JOIN Maestro mtf ON dpf.IdTipoParticipante = mtf.IdMaestro
                                        WHERE dpf.IdDocumento = d.IdDocumento
                                          AND dpf.LoginUsuario = @login
                                          AND mtf.Codigo = @tipoRol
                                   )";
                }

                string sql = @"SELECT d.IdDocumento, d.Asunto, d.Descripcion, d.AreaCategoria,
                                      d.Prioridad, d.RutaArchivoPDF, d.FechaCreacion,
                                      d.FechaLimiteRevision, d.FechaLimiteAprobacion,
                                      d.LoginUsuarioRegistrador AS Registrador,
                                      ISNULL(mt.Descripcion, 'Documento') AS TipoDocumento,
                                      me.Descripcion AS EstadoDesc, me.Codigo AS EstadoCodigo
                               FROM Documento d
                               JOIN Maestro me ON d.IdEstadoDocumento = me.IdMaestro
                               LEFT JOIN Maestro mt ON d.IdTipoDocumento = mt.IdMaestro
                               WHERE d.Activo = 1 AND me.Codigo IN ('REG','REV','PEN','FPAR','OBS')
                               " + filtroRol + @"
                               ORDER BY d.FechaCreacion DESC";

                var lista = new List<object>();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (rol == "REV" || rol == "FIR")
                    {
                        cmd.Parameters.AddWithValue("@login", login);
                        cmd.Parameters.AddWithValue("@tipoRol", rol);
                    }

                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string pri  = dr["Prioridad"].ToString().ToUpper();
                            string est  = dr["EstadoCodigo"].ToString();
                            string ruta = dr["RutaArchivoPDF"].ToString();
                            DateTime fechaCreacion = Convert.ToDateTime(dr["FechaCreacion"]);
                            int idDocumento = Convert.ToInt32(dr["IdDocumento"]);

                            // Obtener fechas límite de la BD
                            DateTime maxRevision = Convert.ToDateTime(dr["FechaLimiteRevision"]);
                            DateTime maxFirma = Convert.ToDateTime(dr["FechaLimiteAprobacion"]);

                            // Calcular horas restantes
                            TimeSpan tsRevision = maxRevision - DateTime.Now;
                            TimeSpan tsFirma = maxFirma - DateTime.Now;
                            double horasRevision = tsRevision.TotalHours;
                            double horasFirma = tsFirma.TotalHours;

                            // Crear textos de estado
                            string textoRevision = horasRevision >= 0
                                ? string.Format("{0} horas restantes", Math.Ceiling(horasRevision))
                                : string.Format("{0} horas fuera de límites", Math.Ceiling(Math.Abs(horasRevision)));

                            string textoFirma = horasFirma >= 0
                                ? string.Format("{0} horas restantes", Math.Ceiling(horasFirma))
                                : string.Format("{0} horas fuera de límites", Math.Ceiling(Math.Abs(horasFirma)));

                            // Obtener revisores asignados
                            string revisoresHtml = ObtenerRevisoresHtml(idDocumento);
                            bool esConformeRevision = false;
                            bool esObservadoRevision = false;
                            bool puedeEditarRevision = false;
                            bool puedeFirmarDocumento = false;
                            if (rol == "REV")
                            {
                                ObtenerEstadoRevisionUsuario(idDocumento, login, out esConformeRevision, out esObservadoRevision, out puedeEditarRevision);
                                // Los revisores también pueden firmar si el documento está en PEN o FPAR
                                if (est == "PEN" || est == "FPAR")
                                    puedeFirmarDocumento = PuedeFirmarSecuencial(idDocumento, login, est);
                            }

                            lista.Add(new {
                                IdDocumento     = idDocumento,
                                Asunto          = dr["Asunto"].ToString(),
                                Descripcion     = dr["Descripcion"] == DBNull.Value ? "" : dr["Descripcion"].ToString(),
                                AreaCategoria   = dr["AreaCategoria"]?.ToString() ?? "-",
                                Prioridad       = pri,
                                PrioridadCss    = pri == "ALTA" ? "alta" : pri == "BAJA" ? "baja" : "media",
                                EstadoDesc      = dr["EstadoDesc"].ToString(),
                                EstadoCodigo    = est,
                                EstadoBadgeCss  = est == "PEN" || est == "FPAR" ? "badge-firma" : "badge-estado",
                                NombreArchivo   = System.IO.Path.GetFileName(ruta),
                                TipoDocumento   = dr["TipoDocumento"].ToString(),
                                Registrador     = dr["Registrador"].ToString(),
                                FechaCreacionStr = fechaCreacion.ToString("d/M/yyyy"),
                                FechaMaxRevision = maxRevision.ToString("d/M/yyyy HH:mm"),
                                FechaMaxRevisionTexto = textoRevision,
                                FechaMaxFirma = maxFirma.ToString("d/M/yyyy HH:mm"),
                                FechaMaxFirmaTexto = textoFirma,
                                RevisoresHtml = revisoresHtml,
                                FirmantesOrdenHtml = ObtenerFirmantesOrdenHtml(idDocumento),
                                EsConformeRevision = esConformeRevision,
                                EsObservadoRevision = esObservadoRevision,
                                PuedeEditarRevision = puedeEditarRevision,
                                PuedeFirmarDocumento = puedeFirmarDocumento,
                                EsAdministrador = (rol == "ADM")
                            });
                        }
                    }
                }
                pnlEmpty.Visible   = lista.Count == 0;
                rptDocs.DataSource = lista;
                rptDocs.DataBind();
            }
        }

        private int GetBadgeCount(SqlConnection cn, string rol, string login)
        {
            string filtroRol = "";
            if (rol == "REV" || rol == "FIR")
            {
                filtroRol = @" AND EXISTS (
                                    SELECT 1
                                    FROM DocumentoParticipante dpf
                                    INNER JOIN Maestro mtf ON dpf.IdTipoParticipante = mtf.IdMaestro
                                    WHERE dpf.IdDocumento = d.IdDocumento
                                      AND dpf.LoginUsuario = @login
                                      AND mtf.Codigo = @tipoRol
                               )";
            }
            string sql = @"SELECT COUNT(*) FROM Documento d 
                           JOIN Maestro m ON d.IdEstadoDocumento=m.IdMaestro 
                           WHERE d.Activo=1 AND m.Codigo IN ('REG','REV','PEN','FPAR','OBS')" + filtroRol;
            using (var cmd = new SqlCommand(sql, cn))
            {
                if (rol == "REV" || rol == "FIR")
                {
                    cmd.Parameters.AddWithValue("@login", login);
                    cmd.Parameters.AddWithValue("@tipoRol", rol);
                }
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private string BuildNav(string rol, int badge)
        {
            string svgHome    = "<svg viewBox='0 0 24 24'><path d='M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z'/></svg>";
            string svgBandeja = "<svg viewBox='0 0 24 24'><path d='M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z'/></svg>";
            string svgCargar  = "<svg viewBox='0 0 24 24'><path d='M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z'/></svg>";
            string svgMisDocs = "<svg viewBox='0 0 24 24'><path d='M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z'/></svg>";
            string svgRoles   = "<svg viewBox='0 0 24 24'><path d='M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z'/></svg>";
            string svgFirm    = "<svg viewBox='0 0 24 24'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>";
            string svgEstado  = "<svg viewBox='0 0 24 24'><path d='M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z'/></svg>";
            string svgHist    = "<svg viewBox='0 0 24 24'><path d='M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z'/></svg>";

            string badgeHtml = "<span class='nav-badge'>" + badge + "</span>";

            if (rol == "REV")
            {
                return
                    "<a href='../Revisor.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            }
            if (rol == "FIR")
            {
                return
                    "<a href='../Firmante.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                    "<a href='../GestionDocumentos/Historial.aspx' class='nav-item'>" + svgHist + "Historial</a>";
            }
            if (rol == "REG")
            {
                return
                    "<a href='../Registrador.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                    "<a href='../GestionDocumentos/CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                    "<a href='../GestionDocumentos/MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>";
            }
            // ADM
            return
                "<a href='../Default.aspx' class='nav-item'>" + svgHome + "Inicio</a>" +
                "<a href='BandejaTrabajo.aspx' class='nav-item active'>" + svgBandeja + "Bandeja de Trabajo" + badgeHtml + "</a>" +
                "<a href='../GestionDocumentos/CargarDocumento.aspx' class='nav-item'>" + svgCargar + "Cargar Documento</a>" +
                "<a href='../GestionDocumentos/MisDocumentos.aspx' class='nav-item'>" + svgMisDocs + "Mis Documentos</a>" +
                "<a href='../GestionRoles/GestionRoles.aspx' class='nav-item'>" + svgRoles + "Gesti&oacute;n de Roles</a>" +
                "<a href='../VisualizarFirmantes/VisualizarFirmantes.aspx' class='nav-item'>" + svgFirm + "Visualizar Firmantes</a>" +
                "<a href='#' class='nav-item'>" + svgEstado + "Estado del Sistema</a>";
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        { Session.Clear(); Session.Abandon(); Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); }

        private string ObtenerRevisoresHtml(int idDocumento)
        {
            var revisores = new List<string>();
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            string sql = @"SELECT dp.LoginUsuario, ISNULL(me.Codigo,'PEN') AS EstadoCod
                          FROM DocumentoParticipante dp
                          JOIN Maestro m ON dp.IdTipoParticipante = m.IdMaestro
                          LEFT JOIN Maestro me ON dp.EstadoParticipante = me.IdMaestro
                          WHERE dp.IdDocumento = @id AND m.Codigo = 'REV'
                          ORDER BY dp.OrdenSecuencial ASC";
            
            using (var cnTemp = new SqlConnection(conn))
            {
                cnTemp.Open();
                using (var cmd = new SqlCommand(sql, cnTemp))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string login = dr["LoginUsuario"].ToString();
                            string est = dr["EstadoCod"].ToString().ToUpperInvariant();
                            string css = "revisor-item";
                            if (est == "OBS") css += " revisor-obs";
                            else if (est == "REG" || est == "FIR") css += " revisor-ok";
                            revisores.Add("<div class='" + css + "'>" + System.Web.HttpUtility.HtmlEncode(login) + "</div>");
                        }
                    }
                }
            }
            
            if (revisores.Count == 0)
                return "";
            
            return string.Join("", revisores.ToArray());
        }

        private string ObtenerFirmantesOrdenHtml(int idDocumento)
        {
            var firmantes = new List<string>();
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            // Obtener participantes tipo FIR (los que tienen orden de firma)
            string sql = @"
                SELECT fir.LoginUsuario, fir.OrdenSecuencial
                FROM DocumentoParticipante fir
                INNER JOIN Maestro mFir ON fir.IdTipoParticipante = mFir.IdMaestro
                WHERE fir.IdDocumento = @id
                  AND mFir.Codigo = 'FIR'
                ORDER BY fir.OrdenSecuencial ASC, fir.IdParticipante ASC";

            using (var cnTemp = new SqlConnection(conn))
            {
                cnTemp.Open();
                using (var cmd = new SqlCommand(sql, cnTemp))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int orden = dr["OrdenSecuencial"] == DBNull.Value ? 0 : Convert.ToInt32(dr["OrdenSecuencial"]);
                            string login = dr["LoginUsuario"].ToString();
                            string css = "firma-item";
                            string numero = orden > 0 ? orden.ToString() : "-";
                            string html = "<div class='" + css + "'>" +
                                          "<span class='firma-num'>" + numero + "</span>" +
                                          "<span class='firma-login'>" + System.Web.HttpUtility.HtmlEncode(login) + "</span>" +
                                          "</div>";
                            firmantes.Add(html);
                        }
                    }
                }
            }

            if (firmantes.Count == 0)
                return "<span class='firma-empty'>Sin participantes de firma</span>";

            return string.Join("", firmantes.ToArray());
        }

        protected string GenerarBotonesAccion(bool esAdmin, int idDoc, bool puedeEditarRevision, bool esConforme, bool esObservado, string estadoCodigo, bool puedeFirmarDocumento)
        {
            string svgOjo    = "<svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:#1a2a4a'><path d='M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'/></svg>";
            string svgGrupo  = "<svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z'/></svg>";
            string svgEdit   = "<svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>";
            string svgOjoGris = "<svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:currentColor'><path d='M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'/></svg>";

            if (esAdmin)
            {
                string svgDevolver = "<svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z'/></svg>";
                return string.Format(
                    "<button type='button' class='btn-revision' onclick=\"window.location.href='GestionarDocumento.aspx?id={0}'\">{1}Gestionar Documento</button>" +
                    "<button type='button' class='btn-revision' style='background:linear-gradient(90deg,#8b1a1a,#c0392b);border-color:#7d1717' onclick=\"window.location.href='DevolverDocumento.aspx?id={0}'\">{2}Devolver</button>",
                    idDoc, svgGrupo, svgDevolver);
            }

            string rolActual = Session["RolCodigo"] != null ? Session["RolCodigo"].ToString() : "";
            
            // Si es revisor (REV) o firmante (FIR) y el documento está en PEN o FPAR, mostrar botones de firma
            if ((rolActual == "REV" || rolActual == "FIR") && (estadoCodigo == "PEN" || estadoCodigo == "FPAR"))
            {
                string verBtn = string.Format(
                    "<button type='button' class='btn-detalle' onclick=\"window.location.href='VerDocumento.aspx?id={0}'\">{1}Ver</button>",
                    idDoc, svgOjo);
                
                bool puedeFirmar = (rolActual == "FIR") ? PuedeFirmarSecuencial(idDoc, Session["LoginUsuario"].ToString(), estadoCodigo) : puedeFirmarDocumento;
                
                string firmarBtn = puedeFirmar
                    ? string.Format("<button type='button' class='btn-firma' onclick=\"lanzarFirmaPeru({0})\">{1}Firmar Documento</button>", idDoc, svgEdit)
                    : string.Format("<button type='button' class='btn-firma' disabled>{0}Firmar Documento</button>", svgEdit);
                return verBtn + firmarBtn;
            }

            // Lógica para estado REV o FIR cuando el documento está en revisión
            string boton1 = puedeEditarRevision
                ? string.Format("<button class='btn-detalle btn-detalle-activo' type='button' onclick=\"window.location.href='EmitirRevision.aspx?id={0}'\">{1}Editar Revisión</button>", idDoc, svgEdit)
                : string.Format("<button class='btn-detalle' type='button' disabled>{0}Editar Revisión</button>", svgOjoGris);

            string boton2;
            if (esConforme)
                boton2 = "<span class='estado-conforme'>Conforme</span>";
            else if (esObservado)
                boton2 = "<span class='estado-observado'>Observado</span>";
            else
                boton2 = string.Format("<button type='button' class='btn-revision' onclick=\"window.location.href='EmitirRevision.aspx?id={0}'\">{1}Emitir Revisión</button>", idDoc, svgEdit);

            return boton1 + boton2;
        }

        private bool PuedeFirmarSecuencial(int idDocumento, string loginFirmante, string estadoDocumento)
        {
            if (estadoDocumento != "PEN" && estadoDocumento != "FPAR")
                return false;

            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                // Buscar al firmante actual (tipo FIR)
                string sqlActual = @"SELECT TOP (1) dp.IdParticipante, ISNULL(dp.OrdenSecuencial, 0) AS OrdenSecuencial
                                     FROM DocumentoParticipante dp
                                     INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                     WHERE dp.IdDocumento = @id
                                       AND dp.LoginUsuario = @login
                                       AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='FIR'
                                     ORDER BY dp.OrdenSecuencial ASC, dp.IdParticipante ASC";
                int idParticipante = 0;
                int ordenActual = 0;
                using (var cmd = new SqlCommand(sqlActual, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@login", loginFirmante);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return false;
                        idParticipante = Convert.ToInt32(dr["IdParticipante"]);
                        ordenActual = Convert.ToInt32(dr["OrdenSecuencial"]);
                    }
                }

                // Verificar si ya firmó
                string sqlYaFirmo = @"SELECT COUNT(1)
                                      FROM FirmaDetalle fd
                                      INNER JOIN Maestro mf ON fd.IdEstadoFirma = mf.IdMaestro
                                      WHERE fd.IdParticipante = @idp
                                        AND mf.Tipo = 'ESTADO_FIRMA'
                                        AND mf.Codigo = 'FIR'";
                using (var cmd = new SqlCommand(sqlYaFirmo, cn))
                {
                    cmd.Parameters.AddWithValue("@idp", idParticipante);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        return false;
                }

                // Verificar si hay firmantes anteriores sin firmar
                string sqlPendientesAnteriores = @"SELECT COUNT(1)
                                                  FROM DocumentoParticipante dpPrev
                                                  INNER JOIN Maestro mtPrev ON dpPrev.IdTipoParticipante = mtPrev.IdMaestro
                                                  WHERE dpPrev.IdDocumento = @id
                                                    AND mtPrev.Tipo='TIPO_PARTICIPANTE' AND mtPrev.Codigo='FIR'
                                                    AND ISNULL(dpPrev.OrdenSecuencial, 0) < @ordenActual
                                                    AND NOT EXISTS (
                                                        SELECT 1
                                                        FROM FirmaDetalle fd
                                                        INNER JOIN Maestro mf ON fd.IdEstadoFirma = mf.IdMaestro
                                                        WHERE fd.IdParticipante = dpPrev.IdParticipante
                                                          AND mf.Tipo='ESTADO_FIRMA'
                                                          AND mf.Codigo='FIR'
                                                    )";
                using (var cmd = new SqlCommand(sqlPendientesAnteriores, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@ordenActual", ordenActual);
                    return Convert.ToInt32(cmd.ExecuteScalar()) == 0;
                }
            }
        }

        private void ObtenerEstadoRevisionUsuario(int idDocumento, string login, out bool esConforme, out bool esObservado, out bool puedeEditar)
        {
            esConforme = false;
            esObservado = false;
            puedeEditar = false;

            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            string sql = @"SELECT TOP (1) mr.Codigo AS EstadoRevision
                           FROM DocumentoParticipante dp
                           INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           LEFT JOIN Maestro mr ON dp.EstadoParticipante = mr.IdMaestro
                           WHERE dp.IdDocumento=@id AND dp.LoginUsuario=@login
                             AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='REV'
                           ORDER BY dp.IdParticipante ASC";

            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@login", login);
                    object o = cmd.ExecuteScalar();
                    if (o == null || o == DBNull.Value) return;
                    string estado = o.ToString();
                    esConforme = string.Equals(estado, "REG", StringComparison.OrdinalIgnoreCase) ||
                                 string.Equals(estado, "FIR", StringComparison.OrdinalIgnoreCase);
                    esObservado = string.Equals(estado, "OBS", StringComparison.OrdinalIgnoreCase);
                    puedeEditar = esConforme || esObservado;
                }
            }
        }
    }
}
