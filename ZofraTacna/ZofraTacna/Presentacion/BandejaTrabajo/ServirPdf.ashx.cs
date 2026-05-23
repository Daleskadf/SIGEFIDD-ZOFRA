using System;
using System.IO;
using System.Web;
using System.Web.SessionState;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class ServirPdf : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            HttpResponse rsp = context.Response;
            HttpRequest req = context.Request;

            if (context.Session == null || context.Session["LoginUsuario"] == null)
            {
                rsp.StatusCode = 401;
                return;
            }

            string rol = context.Session["RolCodigo"] != null ? context.Session["RolCodigo"].ToString() : "";
            if (rol != "REV" && rol != "ADM" && rol != "REG")
            {
                rsp.StatusCode = 403;
                return;
            }

            int idDoc;
            if (!int.TryParse(req.QueryString["idDoc"], out idDoc) || idDoc <= 0)
            {
                rsp.StatusCode = 400;
                return;
            }

            int idAdjQuery = 0;
            int.TryParse(req.QueryString["idAdj"], out idAdjQuery);

            var repo = new RepositorioDocumentos();
            if (repo.ObtenerDocumentoPorId(idDoc) == null)
            {
                rsp.StatusCode = 404;
                return;
            }

            int idAdj;
            string nombre;
            int bytes;
            if (idAdjQuery > 0)
            {
                if (!repo.AdjuntoPerteneceADocumento(idAdjQuery, idDoc))
                {
                    rsp.StatusCode = 404;
                    return;
                }
                idAdj = idAdjQuery;
                nombre = repo.ObtenerNombreAdjunto(idAdj) ?? "documento.pdf";
                bytes = 0;
            }
            else if (!repo.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombre, out bytes))
            {
                rsp.StatusCode = 404;
                rsp.ContentType = "text/plain";
                rsp.Write("No hay archivo PDF registrado.");
                return;
            }

            byte[] pdf = repo.ObtenerBytesAdjunto(idAdj);
            if (pdf == null || pdf.Length == 0)
            {
                rsp.StatusCode = 404;
                return;
            }

            string safeName = Path.GetFileName(string.IsNullOrEmpty(nombre) ? "documento.pdf" : nombre);
            rsp.ContentType = "application/pdf";
            rsp.Cache.SetCacheability(HttpCacheability.Private);
            string disp = req.QueryString["descargar"] == "1" ? "attachment" : "inline";
            rsp.AddHeader("Content-Disposition",
                disp + "; filename*=UTF-8''" + Uri.EscapeDataString(safeName));
            rsp.BinaryWrite(pdf);
        }

        public bool IsReusable { get { return false; } }
    }
}
