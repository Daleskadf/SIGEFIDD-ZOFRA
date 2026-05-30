<%@ WebHandler Language="C#" Class="ZofraTacna.Presentacion.VerificarEstadoFirma" %>
using System;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

namespace ZofraTacna.Presentacion
{
    public class VerificarEstadoFirma : IHttpHandler, System.Web.SessionState.IRequiresSessionState
    {
        private static void AsegurarTablaTransacciones(string connStr)
        {
            try
            {
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string sql = @"
                        IF OBJECT_ID('dbo.FirmaEstadoTransaccion', 'U') IS NULL
                        BEGIN
                            CREATE TABLE dbo.FirmaEstadoTransaccion (
                                Token VARCHAR(100) NOT NULL PRIMARY KEY,
                                Estado VARCHAR(50) NOT NULL,
                                MensajeError VARCHAR(1000) NULL,
                                FechaRegistro DATETIME NOT NULL DEFAULT GETDATE()
                            );
                        END";
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        private static void RegistrarEstadoEnBD(string connStr, string token, string estado, string errorMsg)
        {
            AsegurarTablaTransacciones(connStr);
            try
            {
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string sql = @"
                        MERGE dbo.FirmaEstadoTransaccion AS target
                        USING (SELECT @token AS Token) AS source
                        ON (target.Token = source.Token)
                        WHEN MATCHED THEN
                            UPDATE SET Estado = @estado, MensajeError = @errorMsg, FechaRegistro = GETDATE()
                        WHEN NOT MATCHED THEN
                            INSERT (Token, Estado, MensajeError) VALUES (@token, @estado, @errorMsg);";
                            
                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@token", token);
                        cmd.Parameters.AddWithValue("@estado", estado);
                        cmd.Parameters.AddWithValue("@errorMsg", (object)errorMsg ?? DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }

        private static string ObtenerYRemoverEstadoDeBD(string connStr, string token, out string errorMsg)
        {
            errorMsg = null;
            AsegurarTablaTransacciones(connStr);
            try
            {
                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    
                    // 1. Obtener
                    string estado = null;
                    string sqlSelect = "SELECT Estado, MensajeError FROM dbo.FirmaEstadoTransaccion WHERE Token = @token";
                    using (var cmd = new SqlCommand(sqlSelect, cn))
                    {
                        cmd.Parameters.AddWithValue("@token", token);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                estado = reader["Estado"].ToString();
                                errorMsg = reader["MensajeError"] != DBNull.Value ? reader["MensajeError"].ToString() : null;
                            }
                        }
                    }

                    // 2. Si existe, remover
                    if (estado != null)
                    {
                        string sqlDelete = "DELETE FROM dbo.FirmaEstadoTransaccion WHERE Token = @token";
                        using (var cmd = new SqlCommand(sqlDelete, cn))
                        {
                            cmd.Parameters.AddWithValue("@token", token);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // 3. Limpiar registros antiguos (> 5 minutos)
                    string sqlClean = "DELETE FROM dbo.FirmaEstadoTransaccion WHERE FechaRegistro < DATEADD(minute, -5, GETDATE())";
                    using (var cmd = new SqlCommand(sqlClean, cn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    return estado;
                }
            }
            catch
            {
                return null;
            }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            
            string action = context.Request.QueryString["action"];
            string token = context.Request.QueryString["token"];
            string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            if (!string.IsNullOrEmpty(action))
            {
                if (string.IsNullOrEmpty(token))
                {
                    context.Response.Write("{\"status\":\"error\", \"mensaje\":\"Falta token para registrar accion\"}");
                    return;
                }
                
                if (action == "cancel")
                {
                    RegistrarEstadoEnBD(connStr, token, "cancelado", null);
                    context.Response.Write("OK");
                    return;
                }
                else if (action == "error")
                {
                    string errorMsg = context.Request.QueryString["error"] ?? "Error desconocido en el agente.";
                    RegistrarEstadoEnBD(connStr, token, "error", errorMsg);
                    context.Response.Write("OK");
                    return;
                }
            }
            
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
                // Si no esta firmado, ver si el agente registro cancelacion o error en la BD
                string estadoAgente = ObtenerYRemoverEstadoDeBD(connStr, token, out string errorMsg);
                if (estadoAgente == "cancelado")
                {
                    context.Response.Write("{\"status\":\"cancelado\"}");
                }
                else if (estadoAgente == "error")
                {
                    context.Response.Write("{\"status\":\"error\", \"mensaje\":\"" + (errorMsg ?? "Error").Replace("\"", "'") + "\"}");
                }
                else
                {
                    context.Response.Write("{\"status\":\"pendiente\"}");
                }
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
