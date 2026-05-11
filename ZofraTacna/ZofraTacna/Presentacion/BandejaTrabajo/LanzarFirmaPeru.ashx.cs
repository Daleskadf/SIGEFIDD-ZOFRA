using System;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.SessionState;

namespace ZofraTacna.Presentacion
{
    /// <summary>
    /// Handler HTTP que lanza la aplicación de Plataforma Firma Perú (ClickOnce)
    /// desde el servidor local. Solo funciona cuando el servidor web y el usuario
    /// están en la misma máquina (desarrollo / intranet local).
    /// </summary>
    public class LanzarFirmaPeru : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            // Verificar sesión
            if (context.Session["LoginUsuario"] == null)
            {
                context.Response.StatusCode = 401;
                context.Response.Write("{\"ok\":false,\"msg\":\"Sesión no válida.\"}");
                return;
            }

            try
            {
                // Ruta del acceso directo ClickOnce de FirmaPeru (.appref-ms)
                string appDataRoaming = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
                string rutaAppRefMs = Path.Combine(
                    appDataRoaming,
                    @"Microsoft\Windows\Start Menu\Programs\PCM\Plataforma Firma Perú\Plataforma Firma Perú.appref-ms"
                );

                if (!File.Exists(rutaAppRefMs))
                {
                    context.Response.Write("{\"ok\":false,\"msg\":\"No se encontró la aplicación Firma Perú instalada en este equipo. Verifique que esté instalada correctamente.\"}");
                    return;
                }

                // Lanzar la aplicación ClickOnce usando rundll32 dfshim.dll
                var psi = new ProcessStartInfo
                {
                    FileName = rutaAppRefMs,
                    UseShellExecute = true
                };

                Process.Start(psi);

                context.Response.Write("{\"ok\":true,\"msg\":\"La aplicación Firma Perú se está abriendo.\"}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"ok\":false,\"msg\":\"Error al abrir Firma Perú: " +
                    HttpUtility.JavaScriptStringEncode(ex.Message) + "\"}");
            }
        }
    }
}
