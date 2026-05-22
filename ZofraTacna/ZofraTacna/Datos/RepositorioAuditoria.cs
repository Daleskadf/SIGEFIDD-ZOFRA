using System;
using System.Configuration;
using System.Data;
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

        /// <summary>
        /// Obtiene toda la auditoría consolidada de un documento.
        /// Retorna un DataSet con las siguientes tablas:
        /// - Table[0] (Documento): Datos del Documento
        /// - Table[1] (Historial): Línea de tiempo de estados (HistorialDocumento)
        /// - Table[2] (Marcadores): Marcadores de Observación en PDF (FIR_DocumentoObsMarcador)
        /// - Table[3] (ObservacionesSubsanadas): Historial de Observaciones Subsanadas (DocumentoObservacionHistorial)
        /// - Table[4] (Firmas): Firmas Digitales con Hashes (FirmaDetalle)
        /// </summary>
        public DataSet ObtenerAuditoriaCompletaDocumento(int idDocumento)
        {
            var ds = new DataSet();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();

                // 1. Datos del Documento
                string sqlDoc = @"
                    SELECT d.IdDocumento, d.CodigoDocumento, d.Asunto, d.FechaCreacion, d.LoginUsuarioRegistrador,
                           mEst.Descripcion AS EstadoActual, mTipo.Descripcion AS TipoDocumento,
                           d.Activo
                    FROM dbo.Documento d
                    LEFT JOIN dbo.Maestro mEst ON d.IdEstadoDocumento = mEst.IdMaestro
                    LEFT JOIN dbo.Maestro mTipo ON d.IdTipoDocumento = mTipo.IdMaestro
                    WHERE d.IdDocumento = @idDoc";

                using (var cmd = new SqlCommand(sqlDoc, conn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds, "Documento");
                }

                // 2. Línea de tiempo (HistorialDocumento)
                string sqlHist = @"
                    SELECT h.IdHistorial, h.FechaCambio, h.LoginUsuarioAccion, h.DetalleAccion,
                           mAnt.Descripcion AS EstadoAnterior, mNue.Descripcion AS EstadoNuevo
                    FROM dbo.HistorialDocumento h
                    LEFT JOIN dbo.Maestro mAnt ON h.IdEstadoAnterior = mAnt.IdMaestro
                    LEFT JOIN dbo.Maestro mNue ON h.IdEstadoNuevo = mNue.IdMaestro
                    WHERE h.IdDocumento = @idDoc
                    ORDER BY h.FechaCambio ASC, h.IdHistorial ASC";

                using (var cmd = new SqlCommand(sqlHist, conn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds, "Historial");
                }

                // 3. Marcadores PDF
                string sqlMarcadores = @"
                    SELECT m.IdMarcador, m.LoginUsuario, m.Pagina, m.PosX, m.PosY, m.TextoSeleccionado, m.Comentario, m.FechaCreacion
                    FROM dbo.FIR_DocumentoObsMarcador m
                    WHERE m.IdDocumento = @idDoc AND m.EsBorrador = 0
                    ORDER BY m.FechaCreacion DESC, m.Pagina ASC";

                using (var cmd = new SqlCommand(sqlMarcadores, conn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds, "Marcadores");
                }

                // 4. Observaciones Subsanadas
                string sqlObsHist = @"
                    SELECT oh.IdHistorialObs, oh.LoginRevisor, oh.Comentario, oh.FechaObservacion, oh.FechaLevantamiento, oh.LoginLevantamiento
                    FROM dbo.DocumentoObservacionHistorial oh
                    WHERE oh.IdDocumento = @idDoc
                    ORDER BY oh.FechaLevantamiento DESC";

                using (var cmd = new SqlCommand(sqlObsHist, conn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds, "ObservacionesSubsanadas");
                }

                // 5. Firmas Digitales
                string sqlFirmas = @"
                    SELECT fd.IdFirma, dp.LoginUsuario, mEst.Descripcion AS EstadoFirma, fd.FirmaDigitalHash, fd.FechaFirma
                    FROM dbo.FirmaDetalle fd
                    INNER JOIN dbo.DocumentoParticipante dp ON fd.IdParticipante = dp.IdParticipante
                    LEFT JOIN dbo.Maestro mEst ON fd.IdEstadoFirma = mEst.IdMaestro
                    WHERE dp.IdDocumento = @idDoc AND fd.FechaFirma IS NOT NULL
                    ORDER BY fd.FechaFirma ASC";

                using (var cmd = new SqlCommand(sqlFirmas, conn))
                {
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    var da = new SqlDataAdapter(cmd);
                    da.Fill(ds, "Firmas");
                }
            }
            return ds;
        }

        /// <summary>
        /// Obtiene la actividad consolidada de los usuarios (Creación, Firmas, Observaciones, Cambios de Estado, etc.)
        /// </summary>
        public DataTable ObtenerAuditoriaActividadUsuarios(string loginUsuario, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var dt = new DataTable();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();

                string sqlBase = @"
                    SELECT * FROM (
                        -- Creación de documentos
                        SELECT d.FechaCreacion AS Fecha, d.LoginUsuarioRegistrador AS Usuario, 'CREACIÓN DE DOCUMENTO' AS TipoAccion,
                               'Se creó el documento con asunto: ""' + d.Asunto + '""' AS Detalle, 
                               d.IdDocumento, d.CodigoDocumento
                        FROM dbo.Documento d
                        WHERE d.Activo = 1

                        UNION ALL

                        -- Cambios de estado
                        SELECT h.FechaCambio AS Fecha, h.LoginUsuarioAccion AS Usuario, 'CAMBIO DE ESTADO' AS TipoAccion,
                               'Transición: ' + ISNULL(mAnt.Descripcion, 'Inicio') + ' ➔ ' + mNue.Descripcion + 
                               CASE WHEN ISNULL(h.DetalleAccion, '') <> '' THEN ' (Motivo: ' + h.DetalleAccion + ')' ELSE '' END AS Detalle,
                               h.IdDocumento, d.CodigoDocumento
                        FROM dbo.HistorialDocumento h
                        INNER JOIN dbo.Documento d ON h.IdDocumento = d.IdDocumento
                        LEFT JOIN dbo.Maestro mAnt ON h.IdEstadoAnterior = mAnt.IdMaestro
                        INNER JOIN dbo.Maestro mNue ON h.IdEstadoNuevo = mNue.IdMaestro
                        WHERE d.Activo = 1

                        UNION ALL

                        -- Firmas
                        SELECT fd.FechaFirma AS Fecha, dp.LoginUsuario AS Usuario, 'FIRMA DIGITAL' AS TipoAccion,
                               'Documento firmado digitalmente. Hash: ' + ISNULL(fd.FirmaDigitalHash, 'N/A') AS Detalle,
                               dp.IdDocumento, d.CodigoDocumento
                        FROM dbo.FirmaDetalle fd
                        INNER JOIN dbo.DocumentoParticipante dp ON fd.IdParticipante = dp.IdParticipante
                        INNER JOIN dbo.Documento d ON dp.IdDocumento = d.IdDocumento
                        WHERE d.Activo = 1 AND fd.FechaFirma IS NOT NULL

                        UNION ALL

                        -- Observaciones en PDF (Marcadores)
                        SELECT m.FechaCreacion AS Fecha, m.LoginUsuario AS Usuario, 'OBSERVACIÓN EN PDF' AS TipoAccion,
                               'Marcador en Pág. ' + CAST(m.Pagina AS VARCHAR) + ': ' + m.Comentario AS Detalle,
                               m.IdDocumento, d.CodigoDocumento
                        FROM dbo.FIR_DocumentoObsMarcador m
                        INNER JOIN dbo.Documento d ON m.IdDocumento = d.IdDocumento
                        WHERE m.EsBorrador = 0 AND d.Activo = 1

                        UNION ALL

                        -- Levantamiento de observaciones
                        SELECT oh.FechaLevantamiento AS Fecha, oh.LoginLevantamiento AS Usuario, 'SUBSANACIÓN DE OBS' AS TipoAccion,
                               'Subsanó observación de ' + oh.LoginRevisor + ': ""' + oh.Comentario + '""' AS Detalle,
                               oh.IdDocumento, d.CodigoDocumento
                        FROM dbo.DocumentoObservacionHistorial oh
                        INNER JOIN dbo.Documento d ON oh.IdDocumento = d.IdDocumento
                        WHERE d.Activo = 1
                    ) AS Actividad
                    WHERE 1=1";

                if (!string.IsNullOrEmpty(loginUsuario))
                {
                    sqlBase += " AND Usuario = @login";
                }
                if (fechaInicio.HasValue)
                {
                    sqlBase += " AND Fecha >= @inicio";
                }
                if (fechaFin.HasValue)
                {
                    sqlBase += " AND Fecha < @fin";
                }

                sqlBase += " ORDER BY Fecha DESC";

                using (var cmd = new SqlCommand(sqlBase, conn))
                {
                    if (!string.IsNullOrEmpty(loginUsuario))
                    {
                        cmd.Parameters.AddWithValue("@login", loginUsuario);
                    }
                    if (fechaInicio.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@inicio", fechaInicio.Value.Date);
                    }
                    if (fechaFin.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@fin", fechaFin.Value.Date.AddDays(1));
                    }

                    var da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        /// <summary>
        /// Obtiene todos los documentos en el sistema para listarlos en el buscador de auditoría.
        /// </summary>
        public DataTable ObtenerDocumentosParaAuditoria(string busqueda, DateTime? fechaInicio, DateTime? fechaFin)
        {
            var dt = new DataTable();
            using (var conn = new SqlConnection(_conn))
            {
                conn.Open();
                string sql = @"
                    SELECT d.IdDocumento, d.CodigoDocumento, d.Asunto, d.FechaCreacion, d.LoginUsuarioRegistrador,
                           mEst.Descripcion AS EstadoActual, mTipo.Descripcion AS TipoDocumento
                    FROM dbo.Documento d
                    LEFT JOIN dbo.Maestro mEst ON d.IdEstadoDocumento = mEst.IdMaestro
                    LEFT JOIN dbo.Maestro mTipo ON d.IdTipoDocumento = mTipo.IdMaestro
                    WHERE d.Activo = 1";

                if (!string.IsNullOrEmpty(busqueda))
                {
                    sql += " AND (d.CodigoDocumento LIKE @busqueda OR d.Asunto LIKE @busqueda OR d.LoginUsuarioRegistrador LIKE @busqueda)";
                }
                if (fechaInicio.HasValue)
                {
                    sql += " AND d.FechaCreacion >= @inicio";
                }
                if (fechaFin.HasValue)
                {
                    sql += " AND d.FechaCreacion < @fin";
                }
                sql += " ORDER BY d.FechaCreacion DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(busqueda))
                    {
                        cmd.Parameters.AddWithValue("@busqueda", "%" + busqueda + "%");
                    }
                    if (fechaInicio.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@inicio", fechaInicio.Value.Date);
                    }
                    if (fechaFin.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@fin", fechaFin.Value.Date.AddDays(1));
                    }

                    var da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }
    }
}
