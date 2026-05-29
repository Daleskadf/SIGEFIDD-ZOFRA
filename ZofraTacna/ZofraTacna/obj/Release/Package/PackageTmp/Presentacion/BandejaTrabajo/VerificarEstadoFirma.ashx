<%@ WebHandler Language="C#" Class="ZofraTacna.Presentacion.VerificarEstadoFirma" %>
using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

namespace ZofraTacna.Presentacion
{
    public class VerificarEstadoFirma : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            // 1. Validar sesión (con fallback por token si la sesión expiró en Azure)
            string login = context.Session["LoginUsuario"] as string;
            if (string.IsNullOrEmpty(login))
            {
                string tk = context.Request.QueryString["token"];
                if (!string.IsNullOrEmpty(tk))
                {
                    try
                    {
                        string b64 = tk.Replace("-", "+").Replace("_", "/");
                        int p = b64.Length % 4;
                        if (p == 2) b64 += "=="; else if (p == 3) b64 += "=";
                        string decoded = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(b64));
                        string[] parts = decoded.Split('|');
                        if (parts.Length >= 2) login = parts[1];
                    }
                    catch { }
                }
            }
            if (string.IsNullOrEmpty(login))
            {
                context.Response.Write("{\"status\":\"error\", \"mensaje\":\"Sesion expirada\"}");
                return;
            }

            // 2. Obtener idDoc
            if (!int.TryParse(context.Request.QueryString["idDoc"], out int idDoc))
            {
                context.Response.Write("{\"status\":\"error\", \"mensaje\":\"Falta idDoc\"}");
                return;
            }

            // 3. Consultar la BD para ver si el documento ya tiene FechaFirma para este usuario
            bool firmado = false;
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string sql = @"SELECT TOP 1 fd.FechaFirma 
                                   FROM FirmaDetalle fd
                                   INNER JOIN DocumentoParticipante dp ON fd.IdParticipante = dp.IdParticipante
                                   WHERE dp.IdDocumento = @idDoc 
                                     AND dp.LoginUsuario = @login";
                                     
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd.Parameters.AddWithValue("@login", login);
                        
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            firmado = true; // Ya tiene fecha de firma
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"status\":\"error\", \"mensaje\":\"" + ex.Message.Replace("\"", "'") + "\"}");
                return;
            }

            if (firmado)
            {
                context.Response.Write("{\"status\":\"firmado\"}");
            }
            else
            {
                context.Response.Write("{\"status\":\"pendiente\"}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}

