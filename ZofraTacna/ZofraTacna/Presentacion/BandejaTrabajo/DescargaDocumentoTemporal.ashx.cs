using System;
using System.IO;
using System.Text;
using System.Web;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class DescargaDocumentoTemporal : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                string token = context.Request.QueryString["token"];
                if (string.IsNullOrEmpty(token))
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("Token faltante");
                    return;
                }

                // 1. Decodificar el Token Stateless (URL-Safe Base64)
                string base64 = token.Replace("-", "+").Replace("_", "/");
                switch (base64.Length % 4)
                {
                    case 2: base64 += "=="; break;
                    case 3: base64 += "="; break;
                }

                string plainToken = Encoding.UTF8.GetString(Convert.FromBase64String(base64));
                string[] parts = plainToken.Split('|');

                if (parts.Length < 3)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("Token inválido");
                    return;
                }

                int idDoc;
                if (!int.TryParse(parts[0], out idDoc) || idDoc <= 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ID de documento inválido");
                    return;
                }

                var repo = new RepositorioDocumentos();
                int idAdj;
                string nombre;
                int bytes;

                if (!repo.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombre, out bytes))
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("No se encontró archivo PDF adjunto");
                    return;
                }

                byte[] pdf = repo.ObtenerBytesAdjunto(idAdj);
                if (pdf == null || pdf.Length == 0)
                {
                    context.Response.StatusCode = 404;
                    context.Response.Write("El archivo está vacío o no existe");
                    return;
                }

                context.Response.ContentType = "application/pdf";
                context.Response.AddHeader("Content-Disposition", "attachment; filename*=UTF-8''" + Uri.EscapeDataString(nombre ?? "documento.pdf"));
                context.Response.BinaryWrite(pdf);
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("Error interno: " + ex.Message);
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
