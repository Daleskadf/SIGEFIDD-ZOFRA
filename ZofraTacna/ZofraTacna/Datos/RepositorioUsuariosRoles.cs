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
                string sql = "SELECT LoginUsuario, NombreCompleto, Email FROM dbo.FIR_VW_EmpleadosActivos ORDER BY LoginUsuario";
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
                string sql = "SELECT COUNT(*) FROM dbo.FIR_VW_EmpleadosActivos WHERE LoginUsuario = @login";
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

        #region Obtener empleados con informaci�n completa

        /// <summary>
        /// Obtiene todos los empleados activos de la vista VW_EmpleadosActivos
        /// con informaci�n si ya est�n en UsuarioSistema.
        /// </summary>
        public List<ZofraTacna.Models.EmpleadoDTO> ObtenerEmpleadosConEstado()
        {
            var lista = new List<ZofraTacna.Models.EmpleadoDTO>();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"
                    SELECT 
                        v.LoginUsuario,
                        v.NombreCompleto,
                        ISNULL(v.Email, v.LoginUsuario + '@zofratacna.com.pe') AS Email,
                        CASE WHEN u.IdUsuario IS NOT NULL THEN 1 ELSE 0 END AS EnSistema
                    FROM dbo.FIR_VW_EmpleadosActivos v
                    LEFT JOIN UsuarioSistema u ON v.LoginUsuario = u.LoginUsuario AND u.Activo = 1
                    ORDER BY v.NombreCompleto";

                using (var cmd = new SqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string login = dr.IsDBNull(0) ? "" : dr.GetString(0);
                        string nombreCompleto = dr.IsDBNull(1) ? login : dr.GetString(1);
                        string email = dr.IsDBNull(2) ? login + "@zofratacna.com.pe" : dr.GetString(2);
                        int enSistemaInt = dr.IsDBNull(3) ? 0 : dr.GetInt32(3);
                        bool enSistema = enSistemaInt == 1;

                        lista.Add(new ZofraTacna.Models.EmpleadoDTO
                        {
                            IDEmpleado = 0,
                            LoginUsuario = login,
                            Nombre = "",
                            Apellido = "",
                            NombreCompleto = nombreCompleto,
                            Email = email,
                            EnSistema = enSistema
                        });
                    }
                }
            }
            return lista;
        }

        #endregion

        #region Gesti�n de UsuarioSistema

        /// <summary>
        /// Obtiene el IdMaestro del rol "Revisor" (ROL_SISTEMA.REV).
        /// </summary>
        public int ObtenerIdRolRevisor()
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "SELECT IdMaestro FROM Maestro WHERE Tipo='ROL_SISTEMA' AND Codigo='REV'";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    object result = cmd.ExecuteScalar();
                    return result != null ? (int)result : 0;
                }
            }
        }

        /// <summary>
        /// Obtiene el IdMaestro del rol "Firmante" (ROL_SISTEMA.FIR).
        /// </summary>
        public int ObtenerIdRolFirmante()
        {
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = "SELECT IdMaestro FROM Maestro WHERE Tipo='ROL_SISTEMA' AND Codigo='FIR'";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    object result = cmd.ExecuteScalar();
                    return result != null ? (int)result : 0;
                }
            }
        }

        /// <summary>
        /// Agrega un usuario a UsuarioSistema si no existe, asign�ndole un rol espec�fico.
        /// Soporta: "REV" (Revisor) o "FIR" (Firmante)
        /// </summary>
        public bool AgregarUsuarioSistemaConRol(string loginUsuario, string codigoRol)
        {
            try
            {
                // Validar que existe en administracion
                if (!ExisteEnEmpleadosActivos(loginUsuario))
                    return false;

                // Verificar si ya existe
                if (YaTieneRolAsignado(loginUsuario))
                    return true; // Ya existe, no es error

                int idRol = 0;
                if (codigoRol == "REV")
                    idRol = ObtenerIdRolRevisor();
                else if (codigoRol == "FIR")
                    idRol = ObtenerIdRolFirmante();
                else
                    return false;

                if (idRol == 0)
                    return false;

                using (var conn = new SqlConnection(_conn))
                {
                    conn.Open();
                    string sql = @"INSERT INTO UsuarioSistema 
                        (LoginUsuario, Password, IdRolSistema, Activo, IDUsuarioCreador, FechaCreacion)
                        VALUES (@login, NULL, @idRol, 1, 'SISTEMA', GETDATE())";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@login", loginUsuario);
                        cmd.Parameters.AddWithValue("@idRol", idRol);
                        return cmd.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Agrega un usuario a UsuarioSistema si no existe, asign�ndole el rol de Revisor.
        /// </summary>
        public bool AgregarUsuarioSistemaComoRevisor(string loginUsuario)
        {
            return AgregarUsuarioSistemaConRol(loginUsuario, "REV");
        }

        #endregion

        #region Actualizaci�n

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

