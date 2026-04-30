using System.Configuration;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using ZofraTacna.ServiciosExternos;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloAutenticacion
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
        private readonly ConectorSAS _conectorSAS = new ConectorSAS();

        #region Lectura

        /// <summary>
        /// Obtiene SOLO los usuarios que ya tienen rol asignado en UsuarioSistema.
        /// Estos son los que aparecen en el Login.
        /// </summary>
        public List<UsuarioDto> ObtenerUsuariosDelSistema()
        {
            var lista = new List<UsuarioDto>();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"SELECT u.IdUsuario, u.LoginUsuario, m.Codigo AS RolCodigo, m.Descripcion AS RolNombre, u.Activo
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               WHERE u.Activo = 1
                               ORDER BY u.LoginUsuario";
                using (var cmd = new SqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new UsuarioDto
                        {
                            IdUsuario = (int)dr["IdUsuario"],
                            LoginUsuario = dr["LoginUsuario"].ToString(),
                            RolCodigo = dr["RolCodigo"].ToString(),
                            RolNombre = dr["RolNombre"].ToString(),
                            Activo = (bool)dr["Activo"]
                        });
                    }
                }
            }
            return lista;
        }

        /// <summary>
        /// Autentica un usuario verificando que exista en UsuarioSistema y esté activo.
        /// En modo simulación (Password = NULL), solo valida el login.
        /// </summary>
        public UsuarioSesion Autenticar(string login, string password = null)
        {
            if (string.IsNullOrWhiteSpace(login))
                return null;

            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"SELECT u.LoginUsuario, m.Codigo AS RolCodigo, m.Descripcion AS RolNombre
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               WHERE u.LoginUsuario = @login AND u.Activo = 1";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@login", login);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                            return new UsuarioSesion
                            {
                                LoginUsuario = dr["LoginUsuario"].ToString(),
                                RolCodigo = dr["RolCodigo"].ToString(),
                                RolNombre = dr["RolNombre"].ToString()
                            };
                    }
                }
            }
            return null;
        }

        #endregion

        #region Validaciones para Registro/Asignación de Rol

        /// <summary>
        /// Valida si un LoginUsuario puede ser registrado con un rol en el sistema.
        /// Retorna null si es válido, o un mensaje de error si hay problemas.
        /// 
        /// Validaciones:
        /// 1. El usuario existe en BD administracion (VW_EmpleadosActivos)
        /// 2. El usuario NO tiene rol asignado ya en UsuarioSistema
        /// </summary>
        public string ValidarRegistroUsuario(string loginUsuario)
        {
            if (string.IsNullOrWhiteSpace(loginUsuario))
                return "El login de usuario es requerido.";

            // Validación 1: Verificar si existe en BD institucional (VW_EmpleadosActivos)
            if (!_conectorSAS.ValidarEmpleadoActivo(loginUsuario))
                return "El usuario no existe en el registro institucional.";

            // Validación 2: Verificar si ya tiene rol asignado
            if (!_conectorSAS.ValidarNoTieneRolAsignado(loginUsuario))
                return "El usuario ya tiene un rol asignado.";

            // Todas las validaciones pasaron
            return null;
        }

        #endregion
    }

    public class UsuarioSesion
    {
        public string LoginUsuario { get; set; }
        public string RolCodigo { get; set; }
        public string RolNombre { get; set; }
    }

    public class UsuarioDto
    {
        public int IdUsuario { get; set; }
        public string LoginUsuario { get; set; }
        public string RolCodigo { get; set; }
        public string RolNombre { get; set; }
        public bool Activo { get; set; }
    }
}
