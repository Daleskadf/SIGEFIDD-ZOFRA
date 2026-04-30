using System.Configuration;
using System.Data.SqlClient;
using ZofraTacna.Models;

namespace ZofraTacna.Datos
{
    public class RepositorioAuditoria
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

        public void InsertarHistorial(HistorialDocumento h)
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"INSERT INTO HistorialDocumento
                               (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion)
                               VALUES (@doc,@ant,@nue,@login,@detalle)";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@doc",    h.IdDocumento);
                    cmd.Parameters.AddWithValue("@ant",    h.IdEstadoAnterior.HasValue ? (object)h.IdEstadoAnterior.Value : System.DBNull.Value);
                    cmd.Parameters.AddWithValue("@nue",    h.IdEstadoNuevo);
                    cmd.Parameters.AddWithValue("@login",  h.LoginUsuarioAccion);
                    cmd.Parameters.AddWithValue("@detalle",h.DetalleAccion);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void InsertarLogError(string capa, string mensaje, string stackTrace, string login)
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"INSERT INTO LogErrorSistema (Capa,MensajeError,DetalleStacktrace,LoginUsuario)
                               VALUES (@capa,@msg,@stack,@login)";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@capa",  capa ?? (object)System.DBNull.Value);
                    cmd.Parameters.AddWithValue("@msg",   mensaje);
                    cmd.Parameters.AddWithValue("@stack", stackTrace ?? (object)System.DBNull.Value);
                    cmd.Parameters.AddWithValue("@login", login     ?? (object)System.DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
