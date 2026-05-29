using System;
using System.Collections.Generic;
using System.Web;
using ZofraTacna.Datos;

namespace ZofraTacna.Helpers
{
    public static class RolSwitcherHelper
    {
        public static string GenerarBadgeRolOSwitcher(HttpContext context, string currentRolCodigo, string currentRolNombre)
        {
            if (context == null || context.Session == null || context.Session["LoginUsuario"] == null)
            {
                return currentRolNombre;
            }

            try
            {
                string login = context.Session["LoginUsuario"].ToString();
                var repo = new RepositorioUsuariosRoles();
                List<RolDto> roles = repo.ObtenerRolesDisponibles(login);

                // If there's 1 or fewer roles, just return the name of the current role
                if (roles == null || roles.Count <= 1)
                {
                    return currentRolNombre;
                }

                // Otherwise, render a styled dropdown switcher
                var sb = new System.Text.StringBuilder();
                sb.Append("<select onchange=\"window.location.href=this.value\" style=\"background:transparent; border:none; color:inherit; font-family:inherit; font-size:inherit; font-weight:inherit; cursor:pointer; outline:none; padding: 0 4px; vertical-align: middle;\">");

                foreach (var r in roles)
                {
                    string relativeUrl = VirtualPathUtility.ToAbsolute("~/Presentacion/InicioSesion/CambiarRol.ashx") + "?rol=" + r.Codigo;
                    string selected = (r.Codigo == currentRolCodigo) ? "selected=\"selected\"" : "";
                    sb.AppendFormat("<option value=\"{0}\" {1}>{2} ▾</option>", relativeUrl, selected, r.Descripcion);
                }

                sb.Append("</select>");
                return sb.ToString();
            }
            catch
            {
                return currentRolNombre;
            }
        }
    }
}
