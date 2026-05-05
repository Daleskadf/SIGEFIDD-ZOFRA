using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;

namespace ZofraTacna.Datos
{
    public class NotificacionHistorialDto
    {
        public int IdHistorial { get; set; }
        public int IdDocumento { get; set; }
        public string CodigoDocumento { get; set; }
        public string Asunto { get; set; }
        public string LoginUsuarioAccion { get; set; }
        public string DetalleAccion { get; set; }
        public DateTime FechaCambio { get; set; }
        public string ToastText { get; set; }
    }

    /// <summary>
    /// Alertas in-app derivadas de HistorialDocumento.
    /// ADM ve todos los documentos; el resto solo los vinculados (registrador o participante).
    /// </summary>
    public class RepositorioNotificacionesApp
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

        private static string FiltroVisibilidad(bool esAdministrador)
        {
            if (esAdministrador)
                return "1=1";
            return @"(d.LoginUsuarioRegistrador = @login
                OR EXISTS (
                    SELECT 1 FROM dbo.DocumentoParticipante p
                    WHERE p.IdDocumento = d.IdDocumento AND p.LoginUsuario = @login
                ))";
        }

        public int ObtenerCursorMaxId(string loginUsuario, string rolCodigo)
        {
            bool esAdm = string.Equals(rolCodigo, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtro = FiltroVisibilidad(esAdm);
            string sql = $@"
                SELECT ISNULL(MAX(h.IdHistorial), 0)
                FROM dbo.HistorialDocumento h
                INNER JOIN dbo.Documento d ON d.IdDocumento = h.IdDocumento
                WHERE d.Activo = 1 AND {filtro}";

            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (!esAdm)
                        cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
                }
            }
        }

        public int ContarNuevas(string loginUsuario, string rolCodigo, int desdeIdExclusivo)
        {
            bool esAdm = string.Equals(rolCodigo, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtro = FiltroVisibilidad(esAdm);
            string sql = $@"
                SELECT COUNT(*)
                FROM dbo.HistorialDocumento h
                INNER JOIN dbo.Documento d ON d.IdDocumento = h.IdDocumento
                WHERE d.Activo = 1 AND h.IdHistorial > @since AND {filtro}";

            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@since", desdeIdExclusivo);
                    if (!esAdm)
                        cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    return Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
        }

        public List<NotificacionHistorialDto> ListarRecientes(string loginUsuario, string rolCodigo, int maxItems)
        {
            bool esAdm = string.Equals(rolCodigo, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtro = FiltroVisibilidad(esAdm);
            string sql = $@"
                SELECT TOP (@take)
                    h.IdHistorial, h.IdDocumento, d.CodigoDocumento, d.Asunto,
                    h.LoginUsuarioAccion, h.DetalleAccion, h.FechaCambio
                FROM dbo.HistorialDocumento h
                INNER JOIN dbo.Documento d ON d.IdDocumento = h.IdDocumento
                WHERE d.Activo = 1 AND {filtro}
                ORDER BY h.IdHistorial DESC";

            var lista = new List<NotificacionHistorialDto>();
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@take", maxItems);
                    if (!esAdm)
                        cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            lista.Add(Map(dr));
                    }
                }
            }
            return lista;
        }

        public List<NotificacionHistorialDto> ListarDesdeId(string loginUsuario, string rolCodigo, int desdeIdExclusivo, int maxItems)
        {
            bool esAdm = string.Equals(rolCodigo, "ADM", StringComparison.OrdinalIgnoreCase);
            string filtro = FiltroVisibilidad(esAdm);
            string sql = $@"
                SELECT TOP (@take)
                    h.IdHistorial, h.IdDocumento, d.CodigoDocumento, d.Asunto,
                    h.LoginUsuarioAccion, h.DetalleAccion, h.FechaCambio
                FROM dbo.HistorialDocumento h
                INNER JOIN dbo.Documento d ON d.IdDocumento = h.IdDocumento
                WHERE d.Activo = 1 AND h.IdHistorial > @since AND {filtro}
                ORDER BY h.IdHistorial ASC";

            var lista = new List<NotificacionHistorialDto>();
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@since", desdeIdExclusivo);
                    cmd.Parameters.AddWithValue("@take", maxItems);
                    if (!esAdm)
                        cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            lista.Add(Map(dr));
                    }
                }
            }
            return lista;
        }

        private static NotificacionHistorialDto Map(SqlDataReader dr)
        {
            string login = dr["LoginUsuarioAccion"].ToString();
            string cod = dr["CodigoDocumento"].ToString();
            string det = dr["DetalleAccion"] == DBNull.Value ? "" : dr["DetalleAccion"].ToString();
            var sb = new StringBuilder();
            sb.Append(login).Append(" · ").Append(cod);
            if (!string.IsNullOrWhiteSpace(det))
            {
                string corto = det.Length > 140 ? det.Substring(0, 137) + "…" : det;
                sb.Append(" — ").Append(corto);
            }
            return new NotificacionHistorialDto
            {
                IdHistorial = Convert.ToInt32(dr["IdHistorial"]),
                IdDocumento = Convert.ToInt32(dr["IdDocumento"]),
                CodigoDocumento = cod,
                Asunto = dr["Asunto"].ToString(),
                LoginUsuarioAccion = login,
                DetalleAccion = det,
                FechaCambio = Convert.ToDateTime(dr["FechaCambio"]),
                ToastText = sb.ToString()
            };
        }
    }
}
