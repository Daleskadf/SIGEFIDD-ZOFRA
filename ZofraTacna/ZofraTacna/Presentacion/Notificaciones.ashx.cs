using System.Collections.Generic;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    /// <summary>JSON para campana de notificaciones y polling de toasts (HistorialDocumento).</summary>
    public class NotificacionesHandler : IHttpHandler, IRequiresSessionState
    {
        private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = 500000 };

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

            string login = context.Session["LoginUsuario"].ToString();
            string rol = context.Session["RolCodigo"] != null ? context.Session["RolCodigo"].ToString() : "";
            string mode = (context.Request["mode"] ?? "").Trim().ToLowerInvariant();
            var repo = new RepositorioNotificacionesApp();

            if (mode == "init")
            {
                int cursor = repo.ObtenerCursorMaxId(login, rol);
                var items = repo.ListarRecientes(login, rol, 40);
                context.Response.Write(Json.Serialize(new
                {
                    ok = true,
                    cursor,
                    items = MapList(items)
                }));
                return;
            }

            if (mode == "list")
            {
                var items = repo.ListarRecientes(login, rol, 50);
                int maxCursor = repo.ObtenerCursorMaxId(login, rol);
                context.Response.Write(Json.Serialize(new { ok = true, items = MapList(items), maxCursor }));
                return;
            }

            if (mode == "poll")
            {
                int since = 0;
                int.TryParse(context.Request["since"], out since);
                int ackBell = 0;
                int.TryParse(context.Request["ackBell"], out ackBell);

                var news = repo.ListarDesdeId(login, rol, since, 25);
                int nextSince = since;
                foreach (var n in news)
                    if (n.IdHistorial > nextSince)
                        nextSince = n.IdHistorial;
                int unreadBell = repo.ContarNuevas(login, rol, ackBell);
                context.Response.Write(Json.Serialize(new
                {
                    ok = true,
                    news = MapList(news),
                    nextSince,
                    unreadBell
                }));
                return;
            }

            context.Response.Write(Json.Serialize(new { ok = false, error = "unknown_mode" }));
        }

        private static List<object> MapList(List<NotificacionHistorialDto> items)
        {
            var list = new List<object>();
            foreach (var n in items)
            {
                System.DateTime localFecha = ConvertirAPeruTime(n.FechaCambio);
                list.Add(new
                {
                    n.IdHistorial,
                    n.IdDocumento,
                    n.CodigoDocumento,
                    n.Asunto,
                    n.LoginUsuarioAccion,
                    n.DetalleAccion,
                    fecha = localFecha.ToString("yyyy-MM-ddTHH:mm:ss"),
                    fechaTxt = localFecha.ToString("dd/MM/yyyy HH:mm"),
                    n.ToastText
                });
            }
            return list;
        }

        public bool IsReusable => false;

        private static System.DateTime ConvertirAPeruTime(System.DateTime utcDateTime)
        {
            if (utcDateTime == System.DateTime.MinValue || utcDateTime == System.DateTime.MaxValue)
                return utcDateTime;
            try
            {
                System.TimeZoneInfo zone = System.TimeZoneInfo.FindSystemTimeZoneById("SA Pacific Standard Time");
                System.DateTime utc = System.DateTime.SpecifyKind(utcDateTime, System.DateTimeKind.Utc);
                return System.TimeZoneInfo.ConvertTimeFromUtc(utc, zone);
            }
            catch
            {
                // Fallback: Peru is UTC - 5
                return utcDateTime.AddHours(-5);
            }
        }
    }
}
