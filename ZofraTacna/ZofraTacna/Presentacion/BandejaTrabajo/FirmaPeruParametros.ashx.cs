using System;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace ZofraTacna.Presentacion
{
    public class FirmaPeruParametros : IHttpHandler
    {
        public bool IsReusable { get { return false; } }

        private void Log(string mensaje)
        {
            try
            {
                string path = HttpContext.Current.Server.MapPath("~/App_Data/firmaperu_log.txt");
                string dir = Path.GetDirectoryName(path);
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                File.AppendAllText(path, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + mensaje + Environment.NewLine);
            }
            catch { }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.ContentEncoding = Encoding.UTF8;

            try
            {
                Log("=== Inicio de solicitud ===");
                Log("Método: " + context.Request.HttpMethod);
                Log("URL: " + context.Request.Url);
                Log("QueryString: " + context.Request.QueryString);
                Log("Form: " + context.Request.Form);

                string token = context.Request.QueryString["token"];
                int idDoc = 0;
                if (!string.IsNullOrEmpty(token))
                {
                    string[] parts = token.Split('_');
                    if (parts.Length > 0)
                        int.TryParse(parts[0], out idDoc);
                }
                Log("token: " + token + ", idDoc: " + idDoc);

                string baseUrl = context.Request.Url.Scheme + "://" + context.Request.Url.Host + 
                    (context.Request.Url.Port != 80 && context.Request.Url.Port != 443 ? ":" + context.Request.Url.Port : "");
                string appPath = context.Request.ApplicationPath;
                if (appPath.EndsWith("/"))
                    appPath = appPath.Substring(0, appPath.Length - 1);

                string urlDocumento = baseUrl + appPath + "/Presentacion/BandejaTrabajo/FirmaPeruDocumento.ashx?idDoc=" + idDoc;
                string urlSubir = baseUrl + appPath + "/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx?token=" + token;

                Log("urlDocumento: " + urlDocumento);
                Log("urlSubir: " + urlSubir);

                var parametros = new
                {
                    signatureFormat = "PAdES",
                    signatureLevel = "B",
                    signaturePackaging = "enveloped",
                    documentToSign = urlDocumento,
                    certificateFilter = ".*",
                    webTsa = "",
                    userTsa = "",
                    passwordTsa = "",
                    theme = "claro",
                    contactInfo = "Usuario",
                    signatureReason = "Firma digital",
                    visiblePosition = false,
                    signatureStyle = 0,
                    stampPage = 0,
                    stampTextSize = 14,
                    positionx = 20,
                    positiony = 20,
                    uploadDocumentSigned = urlSubir
                };

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                string json = serializer.Serialize(parametros);
                string base64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(json));

                Log("JSON generado: " + json);
                Log("Base64 generado (longitud): " + base64.Length);
                Log("=== Fin de solicitud (éxito) ===");

                context.Response.Write(base64);
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
