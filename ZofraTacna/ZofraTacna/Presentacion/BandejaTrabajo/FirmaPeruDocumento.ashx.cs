using System;
using System.IO;
using System.Web;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class FirmaPeruDocumento : IHttpHandler
    {
        public bool IsReusable { get { return false; } }

        private void Log(string mensaje)
        {
            try
            {
                string path = HttpContext.Current.Server.MapPath("~/App_Data/firmaperu_log.txt");
                string dir = Path.GetDirectoryName(path);
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                File.AppendAllText(path, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - [DOC] " + mensaje + Environment.NewLine);
            }
            catch { }
        }

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                Log("=== Inicio solicitud documento ===");
                Log("Método: " + context.Request.HttpMethod);
                Log("URL: " + context.Request.Url);
                Log("QueryString: " + context.Request.QueryString);

                int idDoc = 0;
                string idDocStr = context.Request.QueryString["idDoc"];
                if (string.IsNullOrEmpty(idDocStr) || !int.TryParse(idDocStr, out idDoc))
                {
                    Log("ERROR: idDoc inválido: " + idDocStr);
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: idDoc inválido");
                    return;
                }

                Log("idDoc: " + idDoc);

                RepositorioDocumentos repo = new RepositorioDocumentos();
                int idAdjunto;
                string nombreArchivo;
                int tamanioBytes;

                if (!repo.IntentarAdjuntoPrincipal(idDoc, out idAdjunto, out nombreArchivo, out tamanioBytes))
                {
                    Log("ERROR: No hay adjunto para idDoc=" + idDoc);
                    context.Response.StatusCode = 404;
                    context.Response.Write("ERROR: Documento no encontrado");
                    return;
                }

                Log("idAdjunto: " + idAdjunto);
                Log("nombreArchivo: " + nombreArchivo);
                Log("tamanioBytes: " + tamanioBytes);

                byte[] contenido = repo.ObtenerBytesAdjunto(idAdjunto);
                if (contenido == null || contenido.Length == 0)
                {
                    Log("ERROR: No hay contenido para idAdjunto=" + idAdjunto);
                    context.Response.StatusCode = 404;
                    context.Response.Write("ERROR: Contenido no encontrado");
                    return;
                }

                Log("Tamaño contenido leído: " + contenido.Length + " bytes");

                context.Response.ContentType = "application/pdf";
                context.Response.AddHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");
                context.Response.BinaryWrite(contenido);
                context.Response.Flush();

                Log("=== Fin solicitud documento (éxito) ===");
            }
            catch (Exception ex)
            {
                Log("ERROR: " + ex.Message + " | " + ex.StackTrace);
                context.Response.StatusCode = 500;
                context.Response.Write("ERROR: " + ex.Message);
            }
        }
    }
}
