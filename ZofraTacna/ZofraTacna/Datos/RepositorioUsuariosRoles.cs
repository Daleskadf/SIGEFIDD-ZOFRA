using System.Collections.Generic;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace ZofraTacna.Datos
{
    public class RepositorioUsuariosRoles
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

        #region Lectura

        public List<UsuarioDto> ObtenerTodos()
        {
            var lista = new List<UsuarioDto>();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"SELECT u.IdUsuario, u.LoginUsuario, m.Descripcion AS Rol, u.Activo
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               ORDER BY u.IdUsuario";
                using (var cmd = new SqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        lista.Add(new UsuarioDto
                        {
                            IdUsuario    = (int)dr["IdUsuario"],
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            Rol          = dr["Rol"].ToString(),
                            Activo       = (bool)dr["Activo"]
                        });
                }
            }
            return lista;
        }

        public List<EmpleadoSASDto> ObtenerEmpleadosActivos()
        {
            var lista = new List<EmpleadoSASDto>();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "SELECT LoginUsuario, NombreCompleto, Email FROM VW_EmpleadosActivos ORDER BY LoginUsuario";
                using (var cmd = new SqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        lista.Add(new EmpleadoSASDto
                        {
                            LoginUsuario  = dr["LoginUsuario"].ToString(),
                            NombreCompleto = dr["NombreCompleto"].ToString(),
                            Email         = dr["Email"].ToString()
                        });
                }
            }
            return lista;
        }

        #endregion

        #region Validaciones

        /// <summary>
        /// Verifica si un LoginUsuario existe en la vista VW_EmpleadosActivos
        /// (empleados activos en la BD administracion).
        /// </summary>
        public bool ExisteEnEmpleadosActivos(string loginUsuario)
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "SELECT COUNT(*) FROM VW_EmpleadosActivos WHERE LoginUsuario = @login";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }

        /// <summary>
        /// Verifica si un LoginUsuario ya tiene un rol asignado en UsuarioSistema.
        /// </summary>
        public bool YaTieneRolAsignado(string loginUsuario)
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "SELECT COUNT(*) FROM UsuarioSistema WHERE LoginUsuario = @login AND Activo = 1";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }

        #endregion

        #region Actualización

        public bool CambiarEstado(int idUsuario, bool activo)
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "UPDATE UsuarioSistema SET Activo=@activo WHERE IdUsuario=@id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@activo", activo);
                    cmd.Parameters.AddWithValue("@id",     idUsuario);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        #endregion
    }

    public class UsuarioDto
    {
        public int    IdUsuario    { get; set; }
        public string LoginUsuario { get; set; }
        public string Rol          { get; set; }
        public bool   Activo       { get; set; }
    }

    public class EmpleadoSASDto
    {
        public string LoginUsuario   { get; set; }
        public string NombreCompleto { get; set; }
        public string Email          { get; set; }
    }
}

