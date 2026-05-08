using System;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class BloqueoFlujoHandler : IHttpHandler, IRequiresSessionState
    {
        private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

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

            int idDocumento;
            if (!int.TryParse(context.Request["idDocumento"], out idDocumento) || idDocumento <= 0)
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "invalid_id" }));
                return;
            }

            string tipo = (context.Request["tipo"] ?? "").Trim();
            string token = (context.Request["token"] ?? "").Trim();
            if (string.IsNullOrWhiteSpace(tipo) || string.IsNullOrWhiteSpace(token))
            {
                context.Response.Write(Json.Serialize(new { ok = false, error = "missing_params" }));
                return;
            }

            string accion = (context.Request["accion"] ?? "").Trim().ToLowerInvariant();
            string login = context.Session["LoginUsuario"].ToString();
            var repo = new RepositorioBloqueoFlujo();

            if (accion == "touch")
            {
                repo.RegistrarOTocarBloqueo(idDocumento, tipo, login, token);
                context.Response.Write(Json.Serialize(new { ok = true }));
                return;
            }

            if (accion == "release")
            {
                repo.LiberarBloqueo(idDocumento, tipo, token);
                context.Response.Write(Json.Serialize(new { ok = true }));
                return;
            }

            context.Response.Write(Json.Serialize(new { ok = false, error = "unknown_action" }));
        }

        public bool IsReusable { get { return false; } }
    }
}
