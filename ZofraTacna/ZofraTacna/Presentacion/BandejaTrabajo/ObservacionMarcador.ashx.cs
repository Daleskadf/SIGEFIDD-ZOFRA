using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.Presentacion
{
    public class ObservacionMarcadorHandler : IHttpHandler, IRequiresSessionState
    {
        private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);

            if (context.Session == null || context.Session["LoginUsuario"] == null)
            {
                context.Response.StatusCode = 401;
                context.Response.Write(Json.Serialize(new { ok = false, error = "no_session" }));
                return;
            }

            string rol = context.Session["RolCodigo"] != null ? context.Session["RolCodigo"].ToString() : "";
            string login = context.Session["LoginUsuario"].ToString();
            string method = (context.Request.HttpMethod ?? "GET").ToUpperInvariant();

            if (method == "GET")
            {
                ProcesarGet(context, rol, login);
                return;
            }

            if (method == "POST")
            {
                if (rol != "REV" && rol != "ADM")
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write(Json.Serialize(new { ok = false, error = "forbidden" }));
                    return;
                }
                ProcesarPost(context, login);
                return;
            }

            if (method == "DELETE")
            {
                if (rol != "REV" && rol != "ADM")
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write(Json.Serialize(new { ok = false, error = "forbidden" }));
                    return;
                }
                ProcesarDelete(context, login);
                return;
            }

            context.Response.Write(Json.Serialize(new { ok = false, error = "method_not_allowed" }));
        }

        private static void ProcesarGet(HttpContext context, string rol, string login)
        {
            if (rol != "REV" && rol != "ADM" && rol != "REG")
            {
                context.Response.StatusCode = 403;
                context.Response.Write(Json.Serialize(new { ok = false, error = "forbidden" }));
                return;
            }

            int idDoc;
            if (!int.TryParse(context.Request["idDoc"], out idDoc) || idDoc <= 0)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "invalid_id" }));
                return;
            }

            var repo = new RepositorioDocumentos();
            if (repo.ObtenerDocumentoPorId(idDoc) == null)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "not_found" }));
                return;
            }

            bool incluirBorrador = (rol == "REV" || rol == "ADM") &&
                                   string.Equals(context.Request["borrador"], "1", StringComparison.Ordinal);
            var lista = repo.ListarMarcadoresObservacion(idDoc, login, incluirBorrador);
            var items = new List<object>();
            foreach (ObservacionMarcadorItem m in lista)
            {
                items.Add(new
                {
                    id = m.IdMarcador,
                    idDocumento = m.IdDocumento,
                    login = m.LoginUsuario,
                    tipo = m.TipoMarcador,
                    pagina = m.Pagina,
                    posX = m.PosX,
                    posY = m.PosY,
                    ancho = m.Ancho,
                    alto = m.Alto,
                    textoSeleccionado = m.TextoSeleccionado,
                    comentario = m.Comentario,
                    esBorrador = m.EsBorrador,
                    fecha = m.FechaCreacion.ToString("o")
                });
            }

            context.Response.Write(Json.Serialize(new
            {
                ok = true,
                tablaDisponible = repo.ExisteTablaDocumentoObservacionMarcador(),
                items
            }));
        }

        private static void ProcesarPost(HttpContext context, string login)
        {
            string body;
            using (var reader = new StreamReader(context.Request.InputStream))
                body = reader.ReadToEnd();

            if (string.IsNullOrWhiteSpace(body))
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "empty_body" }));
                return;
            }

            Dictionary<string, object> data;
            try
            {
                data = Json.Deserialize<Dictionary<string, object>>(body);
            }
            catch
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "invalid_json" }));
                return;
            }

            int idDoc = LeerInt(data, "idDocumento");
            if (idDoc <= 0)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "invalid_id" }));
                return;
            }

            var repo = new RepositorioDocumentos();
            if (repo.ObtenerDocumentoPorId(idDoc) == null)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "not_found" }));
                return;
            }

            var item = new ObservacionMarcadorItem
            {
                IdMarcador = LeerInt(data, "idMarcador"),
                IdDocumento = idDoc,
                LoginUsuario = login,
                TipoMarcador = LeerString(data, "tipo"),
                Pagina = LeerInt(data, "pagina"),
                PosX = LeerDouble(data, "posX"),
                PosY = LeerDouble(data, "posY"),
                Ancho = LeerDoubleNullable(data, "ancho"),
                Alto = LeerDoubleNullable(data, "alto"),
                TextoSeleccionado = LeerString(data, "textoSeleccionado"),
                Comentario = LeerString(data, "comentario")
            };

            string mensaje;
            int id = repo.GuardarMarcadorObservacion(item, out mensaje);
            if (id <= 0)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = mensaje }));
                return;
            }

            context.Response.Write(Json.Serialize(new { ok = true, idMarcador = id }));
        }

        private static void ProcesarDelete(HttpContext context, string login)
        {
            int idMarcador;
            int idDoc;
            if (!int.TryParse(context.Request["idMarcador"], out idMarcador) || idMarcador <= 0 ||
                !int.TryParse(context.Request["idDoc"], out idDoc) || idDoc <= 0)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "invalid_params" }));
                return;
            }

            var repo = new RepositorioDocumentos();
            string mensaje;
            bool ok = repo.EliminarMarcadorBorrador(idMarcador, idDoc, login, out mensaje);
            context.Response.Write(Json.Serialize(new { ok, error = ok ? null : mensaje }));
        }

        private static int LeerInt(Dictionary<string, object> data, string key)
        {
            if (data == null || !data.ContainsKey(key) || data[key] == null) return 0;
            try { return Convert.ToInt32(data[key]); }
            catch { return 0; }
        }

        private static double LeerDouble(Dictionary<string, object> data, string key)
        {
            if (data == null || !data.ContainsKey(key) || data[key] == null) return 0;
            try { return Convert.ToDouble(data[key]); }
            catch { return 0; }
        }

        private static double? LeerDoubleNullable(Dictionary<string, object> data, string key)
        {
            if (data == null || !data.ContainsKey(key) || data[key] == null) return null;
            try { return Convert.ToDouble(data[key]); }
            catch { return null; }
        }

        private static string LeerString(Dictionary<string, object> data, string key)
        {
            if (data == null || !data.ContainsKey(key) || data[key] == null) return "";
            return data[key].ToString();
        }

        public bool IsReusable { get { return false; } }
    }
}
