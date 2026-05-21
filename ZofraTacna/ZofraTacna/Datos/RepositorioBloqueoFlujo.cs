using System;
using System.Configuration;
using System.Data.SqlClient;

namespace ZofraTacna.Datos
{
    public class RepositorioBloqueoFlujo
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
        private const int MinutosExpiracion = 2;

        public bool ExisteBloqueoActivo(int idDocumento, string tipoBloqueo, string tokenIgnorar)
        {
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                if (!ExisteTablaBloqueo(cn)) return false;
                LimpiarExpirados(cn);
                string sql = @"SELECT COUNT(1)
                               FROM FIR_DocumentoBloqueoEdicion
                               WHERE IdDocumento = @id
                                 AND TipoBloqueo = @tipo
                                 AND Activo = 1
                                 AND FechaUltimaActividad >= DATEADD(MINUTE, -@minExp, GETDATE())
                                 AND (@tokenIgnorar = '' OR TokenSesion <> @tokenIgnorar)";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@tipo", tipoBloqueo ?? "");
                    cmd.Parameters.AddWithValue("@minExp", MinutosExpiracion);
                    cmd.Parameters.AddWithValue("@tokenIgnorar", tokenIgnorar ?? "");
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        public void RegistrarOTocarBloqueo(int idDocumento, string tipoBloqueo, string loginUsuario, string tokenSesion)
        {
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                if (!ExisteTablaBloqueo(cn)) return;
                LimpiarExpirados(cn);
                string sql = @"IF EXISTS(
                                   SELECT 1 FROM FIR_DocumentoBloqueoEdicion
                                   WHERE IdDocumento = @id AND TipoBloqueo = @tipo AND TokenSesion = @token
                               )
                               BEGIN
                                   UPDATE FIR_DocumentoBloqueoEdicion
                                   SET FechaUltimaActividad = GETDATE(),
                                       Activo = 1
                                   WHERE IdDocumento = @id AND TipoBloqueo = @tipo AND TokenSesion = @token;
                               END
                               ELSE
                               BEGIN
                                   INSERT INTO FIR_DocumentoBloqueoEdicion
                                   (IdDocumento, TipoBloqueo, LoginUsuario, TokenSesion, FechaInicio, FechaUltimaActividad, Activo)
                                   VALUES
                                   (@id, @tipo, @login, @token, GETDATE(), GETDATE(), 1);
                               END";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@tipo", tipoBloqueo ?? "");
                    cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    cmd.Parameters.AddWithValue("@token", tokenSesion ?? "");
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void LiberarBloqueo(int idDocumento, string tipoBloqueo, string tokenSesion)
        {
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                if (!ExisteTablaBloqueo(cn)) return;
                string sql = @"UPDATE FIR_DocumentoBloqueoEdicion
                               SET Activo = 0
                               WHERE IdDocumento = @id
                                 AND TipoBloqueo = @tipo
                                 AND (@token = '' OR TokenSesion = @token)";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@tipo", tipoBloqueo ?? "");
                    cmd.Parameters.AddWithValue("@token", tokenSesion ?? "");
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void LiberarBloqueosUsuario(string loginUsuario, string tipoBloqueo)
        {
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                if (!ExisteTablaBloqueo(cn)) return;
                string sql = @"UPDATE FIR_DocumentoBloqueoEdicion
                               SET Activo = 0
                               WHERE LoginUsuario = @login
                                 AND TipoBloqueo = @tipo
                                 AND Activo = 1";
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    cmd.Parameters.AddWithValue("@tipo", tipoBloqueo ?? "");
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private static void LimpiarExpirados(SqlConnection cn)
        {
            string sql = @"UPDATE FIR_DocumentoBloqueoEdicion
                           SET Activo = 0
                           WHERE Activo = 1
                             AND FechaUltimaActividad < DATEADD(MINUTE, -" + MinutosExpiracion + @", GETDATE())";
            using (var cmd = new SqlCommand(sql, cn))
                cmd.ExecuteNonQuery();
        }

        private static bool ExisteTablaBloqueo(SqlConnection cn)
        {
            using (var cmd = new SqlCommand("SELECT OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U')", cn))
            {
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value;
            }
        }
    }
}
