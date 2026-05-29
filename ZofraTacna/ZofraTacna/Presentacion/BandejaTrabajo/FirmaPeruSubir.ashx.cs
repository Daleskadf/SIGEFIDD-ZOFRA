using System;
using System.IO;
using System.Web;
using System.Web.SessionState;
using System.Configuration;
using System.Data.SqlClient;
using ZofraTacna.Datos;

namespace ZofraTacna.Presentacion
{
    public class FirmaPeruSubir : IHttpHandler
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.AddHeader("Access-Control-Allow-Origin", "*");
            context.Response.AddHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
            context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");

            try
            {
                string token = context.Request.QueryString["token"];
                if (string.IsNullOrEmpty(token))
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: Token invalido");
                    return;
                }

                string login = "";
                int idDoc = 0;

                try
                {
                    // Intentar decodificar el nuevo token stateless (URL-Safe Base64)
                    string base64 = token.Replace("-", "+").Replace("_", "/");
                    switch (base64.Length % 4)
                    {
                        case 2: base64 += "=="; break;
                        case 3: base64 += "="; break;
                    }
                    string decoded = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64));
                    string[] parts = decoded.Split('|');
                    idDoc = int.Parse(parts[0]);
                    login = parts[1];
                }
                catch
                {
                    // Fallback a lógica antigua
                    string[] tokenParts = token.Split('_');
                    if (tokenParts.Length >= 2) int.TryParse(tokenParts[0], out idDoc);
                    login = FirmaPeruTokenStore.GetLoginForToken(token);
                }

                if (idDoc == 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: Token con formato incorrecto");
                    return;
                }

                if (string.IsNullOrEmpty(login))
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: Login no encontrado para token [" + token + "].");
                    return;
                }

                if (context.Request.Files.Count == 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: No se recibio el archivo");
                    return;
                }

                HttpPostedFile file = context.Request.Files[0];
                if (file == null || file.ContentLength == 0)
                {
                    context.Response.StatusCode = 400;
                    context.Response.Write("ERROR: Archivo vacio");
                    return;
                }

                byte[] fileBytes;
                using (var binaryReader = new BinaryReader(file.InputStream))
                {
                    fileBytes = binaryReader.ReadBytes(file.ContentLength);
                }

                string connStr = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
                int idParticipante = 0;

                using (var cn = new SqlConnection(connStr))
                {
                    cn.Open();
                    string sql = @"SELECT TOP(1) dp.IdParticipante 
                                   FROM DocumentoParticipante dp
                                   INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                   WHERE dp.IdDocumento = @idDoc
                                     AND dp.LoginUsuario = @login
                                     AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='FIR'
                                   ORDER BY dp.OrdenSecuencial ASC";

                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@idDoc", idDoc);
                        cmd.Parameters.AddWithValue("@login", login);
                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            idParticipante = Convert.ToInt32(result);
                    }
                }

                if (idParticipante <= 0)
                {
                    context.Response.StatusCode = 403;
                    context.Response.Write("ERROR: No es un firmante valido");
                    return;
                }

                var repo = new RepositorioDocumentos();
                string hashFirma = Guid.NewGuid().ToString("N");

                int idAdj;
                string nombreOriginal;
                int tamBytes;
                string nuevoNombre = file.FileName;

                if (repo.IntentarAdjuntoPrincipal(idDoc, out idAdj, out nombreOriginal, out tamBytes))
                {
                    if (!string.IsNullOrEmpty(nombreOriginal))
                    {
                        string extension = System.IO.Path.GetExtension(nombreOriginal);
                        string sinExtension = System.IO.Path.GetFileNameWithoutExtension(nombreOriginal);
                        nuevoNombre = sinExtension + "[F]" + extension;
                    }
                }

                repo.ActualizarAdjuntoFirmado(idDoc, fileBytes, nuevoNombre);

                var modulo = new ZofraTacna.LogicaNegocio.ModuloGestionDocumental();
                string mensaje;
                bool ok = modulo.RegistrarFirmaConEstado(idDoc, idParticipante, login, hashFirma, out mensaje);

                if (ok)
                {
                    context.Response.Write("OK");
                }
                else
                {
                    context.Response.StatusCode = 500;
                    context.Response.Write("ERROR: " + mensaje);
                }
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("ERROR: " + ex.Message + " | " + ex.StackTrace);
            }
        }
    }
}
