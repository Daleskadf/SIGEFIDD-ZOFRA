using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Text;
using System.Collections.Generic;

namespace ZofraTacna.Presentacion
{
    public class BandejaData : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            try
            {
                // Validar sesión
                if (context.Session == null || context.Session["LoginUsuario"] == null)
                {
                    context.Response.StatusCode = 401;
                    context.Response.ContentType = "application/json";
                    context.Response.Write("{\"ok\":false,\"error\":\"No autorizado\"}");
                    return;
                }

                string rol = context.Session["RolCodigo"]?.ToString() ?? "";
                string login = context.Session["LoginUsuario"]?.ToString() ?? "";

                if (rol != "ADM" && rol != "REV" && rol != "FIR")
                {
                    context.Response.StatusCode = 403;
                    context.Response.ContentType = "application/json";
                    context.Response.Write("{\"ok\":false,\"error\":\"Rol no permitido\"}");
                    return;
                }

                // Obtener datos de documentos para generar hash
                var docs = ObtenerResumenDocumentos(rol, login);
                string hash = GenerarHash(docs);

                context.Response.ContentType = "application/json";
                context.Response.Write("{\"ok\":true,\"hash\":\"" + hash + "\",\"count\":" + docs.Count + "}");
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.ContentType = "application/json";
                context.Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\"", "") + "\"}");
            }
        }

        private List<string> ObtenerResumenDocumentos(string rol, string login)
        {
            var lista = new List<string>();
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            using (var cn = new SqlConnection(conn))
            {
                cn.Open();

                string filtroRol = "";
                if (rol == "REV" || rol == "FIR")
                {
                    filtroRol = @" AND EXISTS (
                                        SELECT 1
                                        FROM DocumentoParticipante dpf
                                        INNER JOIN Maestro mtf ON dpf.IdTipoParticipante = mtf.IdMaestro
                                        WHERE dpf.IdDocumento = d.IdDocumento
                                          AND dpf.LoginUsuario = @login
                                          AND mtf.Codigo = @tipoRol
                                   )";
                }

                string sql = @"SELECT d.IdDocumento, me.Codigo AS EstadoCodigo
                               FROM Documento d
                               JOIN Maestro me ON d.IdEstadoDocumento = me.IdMaestro
                               WHERE d.Activo = 1 AND me.Codigo IN ('REG','REV','PEN','FPAR','OBS')
                               " + filtroRol + @"
                               ORDER BY d.FechaCreacion DESC";

                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (rol == "REV" || rol == "FIR")
                    {
                        cmd.Parameters.AddWithValue("@login", login);
                        cmd.Parameters.AddWithValue("@tipoRol", rol);
                    }

                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int idDoc = Convert.ToInt32(dr["IdDocumento"]);
                            string estado = dr["EstadoCodigo"].ToString();
                            lista.Add(idDoc + "|" + estado);
                        }
                    }
                }
            }

            return lista;
        }

        private string GenerarHash(List<string> docs)
        {
            StringBuilder sb = new StringBuilder();
            foreach (var doc in docs)
                sb.Append(doc).Append(";");

            // Generar un hash simple basado en el contenido
            string contenido = sb.ToString();
            int hash = contenido.GetHashCode();
            return hash.ToString("X");
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
