using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class CambiarRolHandler : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            if (context.Session == null || context.Session["LoginUsuario"] == null)
            {
                context.Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            string requestedRol = (context.Request["rol"] ?? "").Trim().ToUpper();
            if (string.IsNullOrEmpty(requestedRol))
            {
                context.Response.Redirect("~/Presentacion/InicioSesion/Login.aspx");
                return;
            }

            string login = context.Session["LoginUsuario"].ToString();
            var repo = new RepositorioUsuariosRoles();
            List<RolDto> roles = repo.ObtenerRolesDisponibles(login);

            // Find if user is allowed to assume the requested role
            RolDto matchedRol = roles.Find(r => r.Codigo.Equals(requestedRol, StringComparison.OrdinalIgnoreCase));
            if (matchedRol != null)
            {
                // Update session
                context.Session["RolCodigo"] = matchedRol.Codigo;
                context.Session["RolNombre"] = matchedRol.Descripcion;

                // Redirect to active workspace homepage
                switch (matchedRol.Codigo)
                {
                    case "ADM": context.Response.Redirect("~/Presentacion/Default.aspx");     break;
                    case "REG": context.Response.Redirect("~/Presentacion/Registrador.aspx"); break;
                    case "REV": context.Response.Redirect("~/Presentacion/Revisor.aspx");     break;
                    case "FIR": context.Response.Redirect("~/Presentacion/Firmante.aspx");    break;
                    default:    context.Response.Redirect("~/Presentacion/Default.aspx");     break;
                }
            }
            else
            {
                // If they don't have this role, redirect to their current homepage
                string currentRol = context.Session["RolCodigo"]?.ToString() ?? "";
                switch (currentRol)
                {
                    case "ADM": context.Response.Redirect("~/Presentacion/Default.aspx");     break;
                    case "REG": context.Response.Redirect("~/Presentacion/Registrador.aspx"); break;
                    case "REV": context.Response.Redirect("~/Presentacion/Revisor.aspx");     break;
                    case "FIR": context.Response.Redirect("~/Presentacion/Firmante.aspx");    break;
                    default:    context.Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); break;
                }
            }
        }

        public bool IsReusable { get { return false; } }
    }
}
