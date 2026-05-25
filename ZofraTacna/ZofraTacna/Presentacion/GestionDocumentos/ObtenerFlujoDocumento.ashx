<%@ WebHandler Language="C#" Class="ObtenerFlujoDocumento" %>

using System;
using System.Web;
using System.Data;
using ZofraTacna.Datos;
using System.Web.Script.Serialization;
using System.Collections.Generic;

public class ObtenerFlujoDocumento : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        
        if (context.Session["LoginUsuario"] == null)
        {
            context.Response.Write("{\"error\": \"No autenticado\"}");
            return;
        }

        string idDocStr = context.Request.QueryString["idDoc"];
        if (string.IsNullOrEmpty(idDocStr))
        {
            context.Response.Write("{\"error\": \"ID de documento requerido\"}");
            return;
        }

        int idDoc = int.Parse(idDocStr);
        var repo = new RepositorioAuditoria();
        var ds = repo.ObtenerAuditoriaCompletaDocumento(idDoc);
        
        var lista = new List<object>();
        if (ds != null && ds.Tables.Count > 1)
        {
            DataTable dt = ds.Tables["Historial"];
            foreach (DataRow row in dt.Rows)
            {
                lista.Add(new {
                    FechaCambio = Convert.ToDateTime(row["FechaCambio"]).ToString("dd/MM/yyyy HH:mm:ss"),
                    LoginUsuarioAccion = row["LoginUsuarioAccion"].ToString(),
                    DetalleAccion = row["DetalleAccion"].ToString(),
                    EstadoAnterior = row["EstadoAnterior"].ToString(),
                    EstadoNuevo = row["EstadoNuevo"].ToString(),
                    ColorBadge = GetTimelineColor(row["EstadoNuevo"].ToString())
                });
            }
        }
        
        var js = new JavaScriptSerializer();
        context.Response.Write(js.Serialize(lista));
    }

    private string GetTimelineColor(string estado)
    {
        if (string.IsNullOrEmpty(estado)) return "blue";
        string est = estado.ToUpper();
        if (est.Contains("CREAD") || est.Contains("REGISTR")) return "blue";
        if (est.Contains("OBSERV") || est.Contains("CORREC")) return "red";
        if (est.Contains("REVIS")) return "yellow";
        if (est.Contains("FIRM") || est.Contains("APROB") || est.Contains("FINALIZ")) return "green";
        return "blue";
    }

    public bool IsReusable { get { return false; } }
}
