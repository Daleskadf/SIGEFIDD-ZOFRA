using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloGestionDocumental
    {
        private readonly RepositorioDocumentos _repo = new RepositorioDocumentos();
        private readonly RepositorioUsuariosRoles _repoUsuarios = new RepositorioUsuariosRoles();

        #region Lectura

        public List<Documento> ObtenerDocumentosPorUsuario(string loginUsuario)
        {
            return _repo.ObtenerPorRegistrador(loginUsuario);
        }

        public List<string> ObtenerCategorias()
        {
            var lista = new List<string>();
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                using (var cmd = new SqlCommand("SELECT IdMaestro, Descripcion FROM Maestro WHERE Tipo='TIPO_DOC' AND Activo=1 ORDER BY Orden", cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        lista.Add(dr["IdMaestro"] + "|" + dr["Descripcion"]);
                }
            }
            return lista;
        }

        public List<string> ObtenerUsuariosParaFirmar()
        {
            var lista = new List<string>();
            string conn = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
            using (var cn = new SqlConnection(conn))
            {
                cn.Open();
                string sql = @"SELECT u.LoginUsuario, m.Descripcion AS RolNombre, m.Codigo AS RolCodigo
                               FROM UsuarioSistema u
                               JOIN Maestro m ON u.IdRolSistema = m.IdMaestro
                               WHERE u.Activo=1 AND m.Codigo IN ('FIR','REV')
                               ORDER BY m.Orden, u.LoginUsuario";
                using (var cmd = new SqlCommand(sql, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        lista.Add(dr["LoginUsuario"] + "|" + dr["RolNombre"] + "|" + dr["RolCodigo"]);
                }
            }
            return lista;
        }

        /// <summary>
        /// Obtiene todos los empleados activos para la b�squeda/autocomplete
        /// en la asignaci�n de firmantes.
        /// </summary>
        public List<EmpleadoDTO> ObtenerEmpleadosDisponibles()
        {
            return _repoUsuarios.ObtenerEmpleadosConEstado();
        }

        /// <summary>
        /// Agrega un empleado a UsuarioSistema como Revisor si no existe.
        /// </summary>
        public bool AgregarEmpleadoComoRevisor(string loginUsuario)
        {
            return _repoUsuarios.AgregarUsuarioSistemaComoRevisor(loginUsuario);
        }

        /// <summary>
        /// Obtiene todas las unidades org�nicas de la BD administracion.
        /// Formato: IDUnidadOrganica|Descripcion
        /// </summary>
        public List<string> ObtenerUnidadesOrganicas()
        {
            var lista = new List<string>();

            string connFirma = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            using (var cn = new SqlConnection(connFirma))
            {
                cn.Open();

                string sql = "SELECT IDUnidadOrganica, Descripcion FROM dbo.FIR_VW_UnidadesOrganicas ORDER BY Descripcion";

                using (var cmd = new SqlCommand(sql, cn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(dr["IDUnidadOrganica"].ToString() + "|" + dr["Descripcion"].ToString());
                    }
                }
            }
            return lista;
        }

        #endregion

        #region Registrar Documento

        public int RegistrarDocumentoConParticipantes(RegistrarDocumentoRequest request, string loginUsuario)
        {
            // Código en un solo campo: NumeroDocumento vacío → CodigoDocumento ya es el valor completo para BD.
            // Modo legacy: los tres campos (prefijo, número, año) se componen como antes.
            bool codigoCompletoEnUnCampo = string.IsNullOrWhiteSpace(request.NumeroDocumento);
            if (codigoCompletoEnUnCampo)
            {
                if (string.IsNullOrWhiteSpace(request.CodigoDocumento))
                    throw new ArgumentException("El código del documento es requerido (ej: RS-0001-2026).");
                request.CodigoDocumento = request.CodigoDocumento.Trim();
            }
            else
            {
                if (string.IsNullOrWhiteSpace(request.CodigoDocumento))
                    throw new ArgumentException("El código del documento es requerido (ej: RS, ADMIN).");
                if (request.AnoDocumento < 2000 || request.AnoDocumento > 2100)
                    throw new ArgumentException("El año debe estar entre 2000 y 2100.");
                string codigoCompleto = $"{request.CodigoDocumento.Trim()}-{request.NumeroDocumento.Trim().PadLeft(4, '0')}-{request.AnoDocumento}";
                request.CodigoDocumento = codigoCompleto;
            }

            // Validar ASUNTO
            if (string.IsNullOrWhiteSpace(request.Asunto))
                throw new ArgumentException("El asunto es requerido.");

            // Validar otros campos
            if (request.IdTipoDocumento <= 0)
                throw new ArgumentException("Debe seleccionar una categoría válida.");
            if (request.ContenidoPDF == null || request.ContenidoPDF.Length == 0)
                throw new ArgumentException("El PDF está vacío.");
            if (request.Participantes == null || request.Participantes.Count == 0)
                throw new ArgumentException("Debe agregar al menos un participante.");

            // PASO PREVIO: Crear usuarios en UsuarioSistema si no existen
            CrearUsuariosParticipantes(request.Participantes);

            // Insertar en BD
            return _repo.InsertarDocumentoConParticipantes(request, loginUsuario);
        }

        /// <summary>
        /// Crea usuarios en UsuarioSistema para los participantes si no existen.
        /// Asigna el rol correcto (Revisor o Firmante) seg�n su tipo.
        /// </summary>
        public void CrearUsuariosParticipantes(List<RegistrarParticipanteItem> participantes)
        {
            foreach (var participante in participantes)
            {
                // El tipo viene como "FIR" o "REV"
                string codigoRol = participante.Tipo;
                _repoUsuarios.AgregarUsuarioSistemaConRol(participante.Login, codigoRol);
            }
        }

        public void NotificarRevisores(int idDocumento)
        {
            // Usamos la misma conexi�n de FirmaDigital que ya tienes configurada
            string connString = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;

            using (SqlConnection cn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.FIR_X_NotifAsigRev", cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdDocumento", idDocumento);

                    cn.Open();
                    cmd.ExecuteNonQuery(); // Dispara el procedimiento de SQL que env�a los correos
                }
            }
        }

        #endregion

        #region Actualizar

        public bool ActualizarEstado(int idDocumento, int idEstadoNuevo)
        {
            return _repo.ActualizarEstado(idDocumento, idEstadoNuevo);
        }

        #endregion

        #region Participantes

        public bool RegistrarRevision(int idParticipante, string comentario, bool esObservacion)
        {
            var revision = new RevisionDetalle
            {
                IdParticipante = idParticipante,
                Comentario = comentario,
                EsObservacion = esObservacion
            };
            return _repo.InsertarRevision(revision);
        }

        public bool RegistrarFirma(int idParticipante, string hashFirma)
        {
            var firma = new FirmaDetalle
            {
                IdParticipante = idParticipante,
                FirmaDigitalHash = hashFirma
            };
            return _repo.InsertarFirma(firma);
        }

        /// <summary>
        /// Registra una firma y actualiza automáticamente el estado del documento si es necesario.
        /// Cambia de PEN a FPAR cuando firma el primero, y a FCOM cuando todos firman.
        /// Además, revierte los roles de FIR a REV cuando el documento se completa.
        /// </summary>
        public bool RegistrarFirmaConEstado(int idDocumento, int idParticipante, string loginFirmante, 
            string hashFirma, out string mensaje)
        {
            return _repo.RegistrarFirmaYActualizarEstado(idDocumento, idParticipante, loginFirmante, hashFirma, out mensaje);
        }

        #endregion
    }
}
