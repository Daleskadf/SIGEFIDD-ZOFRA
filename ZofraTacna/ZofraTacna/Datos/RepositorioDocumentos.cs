using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ZofraTacna.Models;

namespace ZofraTacna.Datos
{
    public class RepositorioDocumentos
    {
        private readonly string _connDoc = ConfigurationManager.ConnectionStrings["FirmaDigital"].ConnectionString;
        private readonly string _connFiles = ConfigurationManager.ConnectionStrings["FirmaDigital_Files"].ConnectionString;

        #region Lectura de Documentos

        public List<Documento> ObtenerPorRegistrador(string login)
        {
            var lista = new List<Documento>();
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = "SELECT * FROM Documento WHERE LoginUsuarioRegistrador=@u AND Activo=1 ORDER BY FechaCreacion DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", login);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            lista.Add(MapearDocumento(dr));
                    }
                }
            }
            return lista;
        }

        public Documento ObtenerDocumentoPorId(int idDocumento)
        {
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = "SELECT * FROM Documento WHERE IdDocumento=@id AND Activo=1";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read()) return MapearDocumento(dr);
                    }
                }
            }
            return null;
        }

        /// <summary>Descripcion del tipo de documento (Maestro).</summary>
        public string ObtenerDescripcionTipoDocumento(int idTipoDocumento)
        {
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                           "SELECT Descripcion FROM Maestro WHERE Tipo='TIPO_DOC' AND IdMaestro=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", idTipoDocumento);
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? o.ToString() : "Documento";
                }
            }
        }

        /// <summary>PDF vigente (no eliminado, no archivado) en FirmaDigital_Files.</summary>
        public bool IntentarAdjuntoPrincipal(int idDocumento, out int idAdjunto, out string nombreArchivo, out int tamanioBytes)
        {
            idAdjunto = 0;
            nombreArchivo = null;
            tamanioBytes = 0;
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"SELECT TOP (1) IdAdjunto, NombreArchivo, TamanioBytes
                               FROM DocumentoAdjunto
                               WHERE IdDocumento=@id
                                 AND ISNULL(EsEliminado,0)=0
                                 AND ISNULL(EsSuperado,0)=0
                               ORDER BY IdAdjunto DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return false;
                        idAdjunto = (int)dr["IdAdjunto"];
                        nombreArchivo = dr["NombreArchivo"].ToString();
                        tamanioBytes = Convert.ToInt32(dr["TamanioBytes"]);
                        return true;
                    }
                }
            }
        }

        /// <summary>Ultima version archivada (reemplazada por correccion), para comparar con la vigente.</summary>
        public bool TryObtenerUltimaVersionArchivada(int idDocumento, out AdjuntoArchivadoInfo info)
        {
            info = null;
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"SELECT TOP (1) IdAdjunto, NombreArchivo, FechaSuperacion, MotivoSuperacion, FechaCreacion
                               FROM DocumentoAdjunto
                               WHERE IdDocumento=@id
                                 AND ISNULL(EsEliminado,0)=0
                                 AND ISNULL(EsSuperado,0)=1
                               ORDER BY FechaSuperacion DESC, IdAdjunto DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return false;
                        info = new AdjuntoArchivadoInfo
                        {
                            IdAdjunto = (int)dr["IdAdjunto"],
                            NombreArchivo = dr["NombreArchivo"] != DBNull.Value ? dr["NombreArchivo"].ToString() : "",
                            FechaSuperacion = dr["FechaSuperacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaSuperacion"]) : (DateTime?)null,
                            MotivoSuperacion = dr["MotivoSuperacion"] != DBNull.Value ? dr["MotivoSuperacion"].ToString() : "",
                            FechaCreacion = dr["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaCreacion"]) : DateTime.MinValue
                        };
                        return true;
                    }
                }
            }
        }

        /// <summary>Todas las versiones archivadas (EsSuperado), mas reciente primero.</summary>
        public List<AdjuntoArchivadoInfo> ObtenerAdjuntosArchivados(int idDocumento)
        {
            var lista = new List<AdjuntoArchivadoInfo>();
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"SELECT IdAdjunto, NombreArchivo, FechaSuperacion, MotivoSuperacion, FechaCreacion
                               FROM DocumentoAdjunto
                               WHERE IdDocumento=@id
                                 AND ISNULL(EsEliminado,0)=0
                                 AND ISNULL(EsSuperado,0)=1
                               ORDER BY FechaSuperacion DESC, IdAdjunto DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new AdjuntoArchivadoInfo
                            {
                                IdAdjunto = (int)dr["IdAdjunto"],
                                NombreArchivo = dr["NombreArchivo"] != DBNull.Value ? dr["NombreArchivo"].ToString() : "",
                                FechaSuperacion = dr["FechaSuperacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaSuperacion"]) : (DateTime?)null,
                                MotivoSuperacion = dr["MotivoSuperacion"] != DBNull.Value ? dr["MotivoSuperacion"].ToString() : "",
                                FechaCreacion = dr["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaCreacion"]) : DateTime.MinValue
                            });
                        }
                    }
                }
            }
            return lista;
        }

        /// <summary>TODAS las versiones del documento (vigentes + archivadas), mas reciente primero por IdAdjunto DESC.</summary>
        public List<AdjuntoArchivadoInfo> ObtenerTodasVersiones(int idDocumento)
        {
            var lista = new List<AdjuntoArchivadoInfo>();
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"SELECT IdAdjunto, NombreArchivo, FechaSuperacion, MotivoSuperacion, FechaCreacion,
                                      ISNULL(EsSuperado,0) AS EsSuperado
                               FROM DocumentoAdjunto
                               WHERE IdDocumento=@id
                                 AND ISNULL(EsEliminado,0)=0
                               ORDER BY IdAdjunto DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new AdjuntoArchivadoInfo
                            {
                                IdAdjunto = (int)dr["IdAdjunto"],
                                NombreArchivo = dr["NombreArchivo"] != DBNull.Value ? dr["NombreArchivo"].ToString() : "",
                                FechaSuperacion = dr["FechaSuperacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaSuperacion"]) : (DateTime?)null,
                                MotivoSuperacion = dr["MotivoSuperacion"] != DBNull.Value ? dr["MotivoSuperacion"].ToString() : "",
                                FechaCreacion = dr["FechaCreacion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaCreacion"]) : DateTime.MinValue
                            });
                        }
                    }
                }
            }
            return lista;
        }

        public bool AdjuntoPerteneceADocumento(int idAdjunto, int idDocumento)
        {
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                           @"SELECT 1 FROM DocumentoAdjunto
                             WHERE IdAdjunto=@adj AND IdDocumento=@doc AND ISNULL(EsEliminado,0)=0", conn))
                {
                    cmd.Parameters.AddWithValue("@adj", idAdjunto);
                    cmd.Parameters.AddWithValue("@doc", idDocumento);
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value;
                }
            }
        }

        /// <summary>Archiva adjuntos vigentes e inserta el PDF nuevo (auditoria en la misma tabla).</summary>
        public void ReemplazarPdfConHistorial(int idDocumento, byte[] nuevoPdf, string nombreArchivo, string loginUsuario, string motivoArchivo)
        {
            if (nuevoPdf == null || nuevoPdf.Length == 0) return;
            ArchivarAdjuntosVigentes(idDocumento, loginUsuario ?? "", motivoArchivo ?? "");
            InsertarAdjuntoPDF(idDocumento, nuevoPdf, nombreArchivo, loginUsuario);
        }

        private void ArchivarAdjuntosVigentes(int idDocumento, string loginSuperacion, string motivoSuperacion)
        {
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"UPDATE dbo.DocumentoAdjunto
                               SET EsSuperado = 1,
                                   FechaSuperacion = GETDATE(),
                                   LoginSuperacion = @login,
                                   MotivoSuperacion = @motivo
                               WHERE IdDocumento = @id
                                 AND ISNULL(EsEliminado, 0) = 0
                                 AND ISNULL(EsSuperado, 0) = 0";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.AddWithValue("@login", loginSuperacion ?? "");
                    cmd.Parameters.AddWithValue("@motivo", (object)(motivoSuperacion ?? "") ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Restaura una versión archivada: archiva los adjuntos vigentes actuales y
        /// marca el adjunto archivado indicado como vigente (EsSuperado=0).
        /// </summary>
        public bool RestaurarVersionArchivada(int idDocumento, int idAdjuntoArchivado, string loginUsuario, string motivo)
        {
            if (idAdjuntoArchivado <= 0) return false;
            if (!AdjuntoPerteneceADocumento(idAdjuntoArchivado, idDocumento)) return false;

            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Archivar vigentes actuales
                        string sqlArchivar = @"UPDATE dbo.DocumentoAdjunto
                                               SET EsSuperado = 1,
                                                   FechaSuperacion = GETDATE(),
                                                   LoginSuperacion = @login,
                                                   MotivoSuperacion = @motivo
                                               WHERE IdDocumento = @idDoc
                                                 AND ISNULL(EsEliminado, 0) = 0
                                                 AND ISNULL(EsSuperado, 0) = 0";
                        using (var cmd = new SqlCommand(sqlArchivar, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                            cmd.Parameters.AddWithValue("@login", loginUsuario ?? "");
                            cmd.Parameters.AddWithValue("@motivo", motivo ?? "Archivado por restauración de versión anterior.");
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Restaurar el adjunto archivado seleccionado como vigente
                        string sqlRestaurar = @"UPDATE dbo.DocumentoAdjunto
                                                SET EsSuperado = 0,
                                                    FechaSuperacion = NULL,
                                                    LoginSuperacion = NULL,
                                                    MotivoSuperacion = NULL
                                                WHERE IdAdjunto = @idAdj
                                                  AND IdDocumento = @idDoc
                                                  AND ISNULL(EsEliminado, 0) = 0";
                        using (var cmd = new SqlCommand(sqlRestaurar, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idAdj", idAdjuntoArchivado);
                            cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                        return true;
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        public byte[] ObtenerBytesAdjunto(int idAdjunto)
        {
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                           "SELECT ContenidoPDF FROM DocumentoAdjunto WHERE IdAdjunto=@id AND ISNULL(EsEliminado,0)=0", conn))
                {
                    cmd.Parameters.AddWithValue("@id", idAdjunto);
                    cmd.CommandTimeout = 120;
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? (byte[])o : null;
                }
            }
        }

        public string ObtenerNombreAdjunto(int idAdjunto)
        {
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                using (var cmd = new SqlCommand(
                           "SELECT NombreArchivo FROM DocumentoAdjunto WHERE IdAdjunto=@id AND ISNULL(EsEliminado,0)=0", conn))
                {
                    cmd.Parameters.AddWithValue("@id", idAdjunto);
                    object o = cmd.ExecuteScalar();
                    return o != null && o != DBNull.Value ? o.ToString() : null;
                }
            }
        }

        public List<string> ObtenerObservacionesDocumento(int idDocumento)
        {
            var lista = new List<string>();
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = @"SELECT dp.LoginUsuario, rd.Comentario, rd.FechaRevision
                               FROM RevisionDetalle rd
                               INNER JOIN DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                               INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                               WHERE dp.IdDocumento = @id
                                 AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='REV'
                                 AND rd.EsObservacion = 1
                               ORDER BY rd.FechaRevision DESC, rd.IdRevision DESC";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string login = dr["LoginUsuario"].ToString();
                            string comentario = dr["Comentario"] != DBNull.Value ? dr["Comentario"].ToString() : "";
                            DateTime fecha = dr["FechaRevision"] != DBNull.Value ? Convert.ToDateTime(dr["FechaRevision"]) : DateTime.Now;
                            lista.Add(fecha.ToString("d/M/yyyy HH:mm") + " | " + login + ": " + comentario);
                        }
                    }
                }
            }
            return lista;
        }

        public List<LineaTiempoEvento> ObtenerLineaTiempoDocumento(int idDocumento)
        {
            var eventos = new List<LineaTiempoEvento>();
            Documento doc = ObtenerDocumentoPorId(idDocumento);
            if (doc == null) return eventos;

            string tipoDesc = ObtenerDescripcionTipoDocumento(doc.IdTipoDocumento);
            eventos.Add(new LineaTiempoEvento
            {
                Fecha = doc.FechaCreacion,
                Titulo = "Registro del documento",
                Detalle =
                    doc.LoginUsuarioRegistrador + " registr\u00F3 el documento " + doc.CodigoDocumento + " (" + tipoDesc + "). Asunto: " + doc.Asunto + ".",
                TipoCss = "tl-reg"
            });

            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sqlH = @"SELECT h.FechaCambio, h.LoginUsuarioAccion, h.DetalleAccion, m.Descripcion AS EstadoDesc, m.Codigo AS EstadoCod
                                FROM HistorialDocumento h
                                INNER JOIN Maestro m ON h.IdEstadoNuevo = m.IdMaestro
                                WHERE h.IdDocumento = @id
                                ORDER BY h.FechaCambio ASC";
                using (var cmd = new SqlCommand(sqlH, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            string det = dr["DetalleAccion"] != DBNull.Value
                                ? dr["DetalleAccion"].ToString()
                                : "";
                            eventos.Add(new LineaTiempoEvento
                            {
                                Fecha = (DateTime)dr["FechaCambio"],
                                Titulo = "Estado del tr\u00E1mite: " + dr["EstadoDesc"],
                                Detalle = string.IsNullOrEmpty(det)
                                    ? dr["LoginUsuarioAccion"] + " actualiz\u00F3 el estado (" + dr["EstadoCod"] + ")."
                                    : dr["LoginUsuarioAccion"] + ": " + det,
                                TipoCss = "tl-estado"
                            });
                        }
                    }
                }

                string sqlRev = @"SELECT rd.FechaRevision, rd.Comentario, rd.EsObservacion, dp.LoginUsuario
                                  FROM RevisionDetalle rd
                                  INNER JOIN DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                                  INNER JOIN Maestro mp ON dp.IdTipoParticipante = mp.IdMaestro AND mp.Tipo = 'TIPO_PARTICIPANTE' AND mp.Codigo = 'REV'
                                  WHERE dp.IdDocumento = @id
                                  ORDER BY rd.FechaRevision ASC, rd.IdRevision ASC";
                using (var cmd = new SqlCommand(sqlRev, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            bool obs = Convert.ToBoolean(dr["EsObservacion"]);
                            string com = dr["Comentario"] != DBNull.Value ? dr["Comentario"].ToString().Trim() : "";
                            eventos.Add(new LineaTiempoEvento
                            {
                                Fecha = dr["FechaRevision"] != DBNull.Value
                                    ? (DateTime)dr["FechaRevision"]
                                    : DateTime.MinValue,
                                Titulo = obs ? "Observaci\u00F3n del revisor" : "Revisi\u00F3n favorable",
                                Detalle = dr["LoginUsuario"] + ": " +
                                    (obs ? "Observ\u00F3 el documento." : "Sin observaciones (aprueba revisi\u00F3n).") +
                                    (string.IsNullOrEmpty(com) ? "" : " Comentario: " + com),
                                TipoCss = obs ? "tl-obs" : "tl-aprob"
                            });
                        }
                    }
                }
            }

            FixInvalidRevisionDates(eventos, doc.FechaCreacion);
            eventos.Sort((a, b) => DateTime.Compare(a.Fecha, b.Fecha));
            return eventos;
        }

        private static void FixInvalidRevisionDates(List<LineaTiempoEvento> eventos, DateTime fechaRegistro)
        {
            int sec = 0;
            foreach (LineaTiempoEvento ev in eventos)
            {
                if (ev.TipoCss != "tl-aprob" && ev.TipoCss != "tl-obs") continue;
                if (ev.Fecha > DateTime.MinValue && ev.Fecha.Year >= 1753 && ev.Fecha > fechaRegistro.AddYears(-150))
                    continue;
                ev.Fecha = fechaRegistro.AddSeconds(++sec);
            }
        }

        #endregion

        #region Inserci�n de Documentos

        public int InsertarDocumentoConParticipantes(RegistrarDocumentoRequest request, string loginUsuario)
        {
            int idDocumento = 0;

            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var transaction = conn.BeginTransaction())
                {
                    try
                    {
                        // PASO 1: Obtener estado "REG"
                        int idEstadoReg = ObtenerIdMaestro(conn, transaction, "ESTADO_DOC", "REG");
                        if (idEstadoReg == 0)
                            throw new Exception("No existe estado REG en Maestro.");

                        // PASO 2: Crear el documento
                        // El CodigoDocumento ya viene formado desde ModuloGestionDocumental (ej: RS-0001-2026)
                        string sqlInsert = @"INSERT INTO Documento
                                            (CodigoDocumento,Asunto,Descripcion,IdTipoDocumento,
                                             AreaResponsable,AreaCategoria,LoginUsuarioRegistrador,
                                             IdEstadoDocumento,Prioridad,FechaLimiteRevision,FechaLimiteAprobacion,Activo)
                                            VALUES
                                            (@cod,@asunto,@desc,@tipo,@area,@catdesc,@login,@estado,@pri,@limRev,@limFirma,1);
                                            SELECT SCOPE_IDENTITY();";

                        using (var cmd = new SqlCommand(sqlInsert, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@cod", request.CodigoDocumento);
                            cmd.Parameters.AddWithValue("@asunto", request.Asunto);
                            cmd.Parameters.AddWithValue("@desc", request.Descripcion ?? "");
                            cmd.Parameters.AddWithValue("@tipo", request.IdTipoDocumento);
                            cmd.Parameters.AddWithValue("@area", request.IDUnidadOrganica);
                            cmd.Parameters.AddWithValue("@catdesc", request.Asunto);
                            cmd.Parameters.AddWithValue("@login", loginUsuario);
                            cmd.Parameters.AddWithValue("@estado", idEstadoReg);
                            cmd.Parameters.AddWithValue("@pri", request.Prioridad);
                            cmd.Parameters.AddWithValue("@limRev", DateTime.Now.AddHours(request.HorasRevision));
                            cmd.Parameters.AddWithValue("@limFirma", DateTime.Now.AddHours(request.HorasFirma));
                      

                            object result = cmd.ExecuteScalar();
                            if (result == null || result == DBNull.Value)
                                throw new Exception("No se pudo crear el documento.");
                            idDocumento = Convert.ToInt32(result);
                        }

                        // PASO 3: Obtener IDs de tipos de participantes
                        int idTipoFirmante = ObtenerIdMaestro(conn, transaction, "TIPO_PARTICIPANTE", "FIR");
                        int idTipoRevisor = ObtenerIdMaestro(conn, transaction, "TIPO_PARTICIPANTE", "REV");
                        int idEstadoPen = ObtenerIdMaestro(conn, transaction, "ESTADO_PARTICIPANTE", "PEN");

                        // PASO 4: Insertar participantes (DOS VECES por cada uno)
                        // 1ª entrada: Como REVISOR (Orden=0) para fase REV
                        // 2ª entrada: Como FIRMANTE (Orden=su_posicion) para fase PEN/FPAR (si tiene orden > 0)
                        foreach (var participante in request.Participantes)
                        {
                            // PRIMERA INSERCIÓN: Siempre como REVISOR (Orden = 0)
                            InsertarParticipante(conn, transaction, idDocumento, participante.Login, 
                                0, idTipoRevisor, idEstadoPen);

                            // SEGUNDA INSERCIÓN: Como FIRMANTE si tiene orden de firma (Orden > 0)
                            if (participante.Orden > 0)
                            {
                                InsertarParticipante(conn, transaction, idDocumento, participante.Login, 
                                    participante.Orden, idTipoFirmante, idEstadoPen);
                            }
                        }

                        transaction.Commit();
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }

            // PASO 5: Registrar historial del documento creado
            if (idDocumento > 0)
            {
                using (var connHist = new SqlConnection(_connDoc))
                {
                    connHist.Open();
                    int idEstadoReg = ObtenerIdMaestro(connHist, null, "ESTADO_DOC", "REG");
                    InsertarHistorial(connHist, null, idDocumento, null, idEstadoReg, loginUsuario,
                        "Documento registrado y participantes asignados correctamente.");
                }
            }

            // PASO 6: Guardar PDF en BD de archivos
            if (request.ContenidoPDF != null && request.ContenidoPDF.Length > 0)
            {
                InsertarAdjuntoPDF(idDocumento, request.ContenidoPDF, request.NombreArchivoPDF, loginUsuario);
            }

            return idDocumento;
        }

        private void InsertarParticipante(SqlConnection conn, SqlTransaction transaction, int idDocumento, 
            string loginUsuario, int orden, int idTipo, int idEstado)
        {
            string sql = @"INSERT INTO DocumentoParticipante
                (IdDocumento,LoginUsuario,OrdenSecuencial,IdTipoParticipante,EstadoParticipante)
                VALUES (@idDoc,@login,@orden,@tipo,@estado)";

            using (var cmd = new SqlCommand(sql, conn, transaction))
            {
                cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                cmd.Parameters.AddWithValue("@login", loginUsuario);
                cmd.Parameters.AddWithValue("@orden", orden);
                cmd.Parameters.AddWithValue("@tipo", idTipo);
                cmd.Parameters.AddWithValue("@estado", idEstado);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Elimina detalle de revision/firma y participantes del documento; inserta la lista (misma regla que al registrar).
        /// </summary>
        public void ReemplazarParticipantesDesdeLista(int idDocumento, List<RegistrarParticipanteItem> participantes)
        {
            if (participantes == null || participantes.Count == 0)
                throw new ArgumentException("Debe haber al menos un participante.");

            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var cmd = new SqlCommand(@"
                            DELETE rd FROM dbo.RevisionDetalle rd
                            INNER JOIN dbo.DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                            WHERE dp.IdDocumento = @id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        try
                        {
                            using (var cmd = new SqlCommand(@"
                                DELETE fd FROM dbo.FirmaDetalle fd
                                INNER JOIN dbo.DocumentoParticipante dp ON fd.IdParticipante = dp.IdParticipante
                                WHERE dp.IdDocumento = @id", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@id", idDocumento);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        catch (SqlException)
                        {
                            // FirmaDetalle puede no existir en instalaciones antiguas
                        }

                        using (var cmd = new SqlCommand("DELETE FROM dbo.DocumentoParticipante WHERE IdDocumento=@id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        int idTipoFirmante = ObtenerIdMaestro(conn, tx, "TIPO_PARTICIPANTE", "FIR");
                        int idTipoRevisor = ObtenerIdMaestro(conn, tx, "TIPO_PARTICIPANTE", "REV");
                        int idEstadoPen = ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "PEN");

                        foreach (RegistrarParticipanteItem participante in participantes)
                        {
                            InsertarParticipante(conn, tx, idDocumento, participante.Login, 0, idTipoRevisor, idEstadoPen);
                            if (participante.Orden > 0)
                            {
                                InsertarParticipante(conn, tx, idDocumento, participante.Login,
                                    participante.Orden, idTipoFirmante, idEstadoPen);
                            }
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        private void InsertarAdjuntoPDF(int idDocumento, byte[] contenidoPDF, string nombreArchivo, string loginUsuario)
        {
            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"INSERT INTO DocumentoAdjunto
                    (IdDocumento,ContenidoPDF,NombreArchivo,TipoMime,TamanioBytes,UsuarioCreacion,EsSuperado)
                    VALUES (@id,@pdf,@nom,@mime,@size,@user,0)";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    cmd.Parameters.Add("@pdf", SqlDbType.VarBinary, -1).Value = contenidoPDF;
                    cmd.Parameters.AddWithValue("@nom", nombreArchivo);
                    cmd.Parameters.AddWithValue("@mime", "application/pdf");
                    cmd.Parameters.AddWithValue("@size", contenidoPDF.Length);
                    cmd.Parameters.AddWithValue("@user", loginUsuario);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        #endregion

        #region Actualizaci�n

        public bool ActualizarEstado(int idDocumento, int idEstado)
        {
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = "UPDATE Documento SET IdEstadoDocumento=@estado WHERE IdDocumento=@id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@estado", idEstado);
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        #endregion

        #region Participantes

        public bool InsertarRevision(RevisionDetalle revision)
        {
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = @"INSERT INTO RevisionDetalle (IdParticipante,Comentario,EsObservacion)
                               VALUES (@idp,@com,@obs)";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@idp", revision.IdParticipante);
                    cmd.Parameters.AddWithValue("@com", revision.Comentario);
                    cmd.Parameters.AddWithValue("@obs", revision.EsObservacion);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        /// <summary>
        /// Registra conformidad/observacion de un revisor y actualiza estados del flujo.
        /// Si todos los revisores quedan conformes, el documento pasa a PEN.
        /// </summary>
        public bool RegistrarDecisionRevision(int idDocumento, string loginRevisor, string comentario, bool esObservacion, out string mensaje)
        {
            mensaje = "";
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        int idParticipante;
                        int idEstadoDocAnterior;
                        if (!IntentarParticipanteRevisor(conn, tx, idDocumento, loginRevisor, out idParticipante))
                        {
                            mensaje = "No tienes asignacion de revisor para este documento.";
                            tx.Rollback();
                            return false;
                        }

                        idEstadoDocAnterior = ObtenerEstadoDocumentoActual(conn, tx, idDocumento);
                        if (idEstadoDocAnterior == 0)
                        {
                            mensaje = "No se encontro el estado actual del documento.";
                            tx.Rollback();
                            return false;
                        }

                        int idEstadoParticipanteAnterior = ObtenerEstadoParticipanteActual(conn, tx, idParticipante);
                        UpsertRevisionInterna(conn, tx, idParticipante, comentario, esObservacion);

                        int idEstadoParticipante =
                            ObtenerIdEstadoParticipanteConformeOObservado(conn, tx, esObservacion);
                        ActualizarEstadoParticipante(conn, tx, idParticipante, idEstadoParticipante);

                        int idEstadoDocNuevo = idEstadoDocAnterior;
                        string detalle;
                        bool pasaAFirma = false;

                        if (esObservacion)
                        {
                            idEstadoDocNuevo = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "OBS");
                            detalle = "Revision observada por " + loginRevisor + ".";
                        }
                        else
                        {
                            bool todosConformes = TodosRevisoresConformes(conn, tx, idDocumento);
                            if (todosConformes)
                            {
                                idEstadoDocNuevo = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "PEN");
                                detalle = "Todos los revisores emitieron conformidad. Documento pendiente de firma.";
                                pasaAFirma = true;
                            }
                            else
                            {
                                // Documento queda/permanece en REG hasta completar todas las conformidades.
                                int idEstadoReg = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "REG");
                                idEstadoDocNuevo = idEstadoReg > 0 ? idEstadoReg : idEstadoDocAnterior;
                                detalle = "Conformidad registrada por " + loginRevisor + ". Aun faltan revisores por responder.";
                            }
                        }

                        if (idEstadoDocNuevo > 0 && idEstadoDocNuevo != idEstadoDocAnterior)
                            ActualizarEstadoDocumentoInterno(conn, tx, idDocumento, idEstadoDocNuevo);

                        string detalleCompleto = detalle + " Cambio de revision(participante): " +
                                                 idEstadoParticipanteAnterior + " -> " + idEstadoParticipante + ".";
                        // Historial se registra siempre, incluso si el estado del documento no cambia.
                        InsertarHistorial(conn, tx, idDocumento, idEstadoDocAnterior, idEstadoDocNuevo, loginRevisor, detalleCompleto);
                        tx.Commit();

                        // Notificar por correo si fue observación
                        if (esObservacion)
                        {
                            try
                            {
                                using (var cmdNotif = new SqlCommand("dbo.USP_NotificarObservacionDocumento", conn))
                                {
                                    cmdNotif.CommandType = CommandType.StoredProcedure;
                                    cmdNotif.Parameters.AddWithValue("@IdDocumento", idDocumento);
                                    cmdNotif.Parameters.AddWithValue("@LoginRevisorQueObserva", loginRevisor);
                                    cmdNotif.Parameters.AddWithValue("@ComentarioObservacion", comentario ?? "");
                                    cmdNotif.ExecuteNonQuery();
                                }
                            }
                            catch
                            {
                                // No fallar el flujo principal si la notificación falla
                            }
                        }

                        // Notificar a firmantes cuando el documento pasa a firma (todos conformes)
                        if (pasaAFirma)
                        {
                            try
                            {
                                using (var cmdNotif = new SqlCommand("dbo.USP_NotificarAsignacionFirma", conn))
                                {
                                    cmdNotif.CommandType = CommandType.StoredProcedure;
                                    cmdNotif.Parameters.AddWithValue("@IdDocumento", idDocumento);
                                    cmdNotif.ExecuteNonQuery();
                                }
                            }
                            catch
                            {
                                // No fallar el flujo principal si la notificación falla
                            }
                        }

                        mensaje = esObservacion
                            ? "Observacion registrada correctamente."
                            : "Conformidad registrada correctamente.";
                        return true;
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        mensaje = "No se pudo guardar la revision: " + ex.Message;
                        return false;
                    }
                }
            }
        }

        public bool InsertarFirma(FirmaDetalle firma)
        {
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                string sql = @"INSERT INTO FirmaDetalle (IdParticipante,IdEstadoFirma,FirmaDigitalHash,FechaFirma)
                               VALUES (@idp,
                                 (SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_FIRMA' AND Codigo='FIR'),
                                 @hash, GETDATE())";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@idp", firma.IdParticipante);
                    cmd.Parameters.AddWithValue("@hash", firma.FirmaDigitalHash ?? (object)DBNull.Value);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        /// <summary>
        /// Registra una firma y verifica si todos los revisores han completado su firma.
        /// Si es así, actualiza el estado del documento a FCOM.
        /// Los participantes siempre se mantienen como REV, los permisos se controlan por estado del documento.
        /// </summary>
        public bool RegistrarFirmaYActualizarEstado(int idDocumento, int idParticipante, string loginFirmante, 
            string hashFirma, out string mensaje)
        {
            mensaje = "";
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        // Insertar firma
                        string sqlInsertFirma = @"INSERT INTO FirmaDetalle (IdParticipante,IdEstadoFirma,FirmaDigitalHash,FechaFirma)
                                                  VALUES (@idp,
                                                    (SELECT IdMaestro FROM Maestro WHERE Tipo='ESTADO_FIRMA' AND Codigo='FIR'),
                                                    @hash, GETDATE())";
                        using (var cmd = new SqlCommand(sqlInsertFirma, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idp", idParticipante);
                            cmd.Parameters.AddWithValue("@hash", hashFirma ?? (object)DBNull.Value);
                            if (cmd.ExecuteNonQuery() <= 0)
                            {
                                mensaje = "No se pudo registrar la firma.";
                                tx.Rollback();
                                return false;
                            }
                        }

                        // Contar firmantes que deben firmar (participantes tipo FIR)
                        string sqlContarFirmantes = @"
                            SELECT COUNT(1) FROM DocumentoParticipante dp
                            INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                            WHERE dp.IdDocumento = @idDoc
                              AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='FIR'";
                        
                        // Contar firmas completadas de firmantes
                        string sqlContarFirmas = @"
                            SELECT COUNT(1) FROM FirmaDetalle fd
                            INNER JOIN DocumentoParticipante dp ON fd.IdParticipante = dp.IdParticipante
                            INNER JOIN Maestro mf ON fd.IdEstadoFirma = mf.IdMaestro
                            INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                            WHERE dp.IdDocumento = @idDoc
                              AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='FIR'
                              AND mf.Tipo='ESTADO_FIRMA' AND mf.Codigo='FIR'";

                        int totalFirmantes = 0;
                        int firmasCompletadas = 0;

                        using (var cmd = new SqlCommand(sqlContarFirmantes, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                totalFirmantes = Convert.ToInt32(result);
                        }

                        using (var cmd = new SqlCommand(sqlContarFirmas, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                firmasCompletadas = Convert.ToInt32(result);
                        }

                        // Obtener estado actual del documento
                        int idEstadoActual = ObtenerEstadoDocumentoActual(conn, tx, idDocumento);
                        string estadoActualCodigo = "";
                        using (var cmd = new SqlCommand(
                            "SELECT Codigo FROM Maestro WHERE IdMaestro=@id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idEstadoActual);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                estadoActualCodigo = result.ToString();
                        }

                        // Si es el primer firmante en estado PEN, cambiar a FPAR
                        if (estadoActualCodigo == "PEN")
                        {
                            int idEstadoFpar = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "FPAR");
                            if (idEstadoFpar > 0)
                                ActualizarEstadoDocumentoInterno(conn, tx, idDocumento, idEstadoFpar);

                            InsertarHistorial(conn, tx, idDocumento, idEstadoActual, idEstadoFpar, loginFirmante,
                                "Primer revisor ha firmado el documento. Estado: FPAR (Firma Parcial).");
                        }

                        // Si todos los firmantes han firmado, cambiar estado a FCOM
                        if (totalFirmantes > 0 && firmasCompletadas >= totalFirmantes)
                        {
                            int idEstadoFcom = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "FCOM");
                            if (idEstadoFcom > 0)
                            {
                                ActualizarEstadoDocumentoInterno(conn, tx, idDocumento, idEstadoFcom);

                                InsertarHistorial(conn, tx, idDocumento, idEstadoActual, idEstadoFcom, loginFirmante,
                                    "Todos los firmantes han completado sus firmas. Documento finalizado (FCOM).");
                            }
                        }
                        else if (estadoActualCodigo == "FPAR")
                        {
                            // Actualizar historial de firma parcial
                            InsertarHistorial(conn, tx, idDocumento, idEstadoActual, idEstadoActual, loginFirmante,
                                string.Format("Firmante registró su firma ({0} de {1} completadas).", firmasCompletadas, totalFirmantes));
                        }

                        tx.Commit();
                        mensaje = "Firma registrada correctamente.";
                        return true;
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        mensaje = "Error al registrar la firma: " + ex.Message;
                        return false;
                    }
                }
            }
        }

        public bool ActualizarDocumentoCorregido(
            int idDocumento,
            string codigo,
            string asunto,
            string descripcion,
            int idTipoDocumento,
            string prioridad,
            int horasRevision,
            int horasFirma,
            byte[] nuevoPdf,
            string nuevoNombrePdf,
            string loginUsuario,
            out string mensaje)
        {
            mensaje = "";
            using (var conn = new SqlConnection(_connDoc))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        int idEstadoAnterior = ObtenerEstadoDocumentoActual(conn, tx, idDocumento);
                        int idEstadoReg = ObtenerIdMaestro(conn, tx, "ESTADO_DOC", "REG");
                        int idEstPartPen = ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "PEN");

                        string sqlUpdDoc = @"UPDATE Documento
                                             SET CodigoDocumento=@cod,
                                                 Asunto=@asunto,
                                                 Descripcion=@desc,
                                                 IdTipoDocumento=@tipo,
                                                 Prioridad=@pri,
                                                 FechaLimiteRevision=@limRev,
                                                 FechaLimiteAprobacion=@limFirma,
                                                 FechaCreacion=GETDATE(),
                                                 IdEstadoDocumento=@estado
                                             WHERE IdDocumento=@id";
                        using (var cmd = new SqlCommand(sqlUpdDoc, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@cod", codigo);
                            cmd.Parameters.AddWithValue("@asunto", asunto);
                            cmd.Parameters.AddWithValue("@desc", (object)(descripcion ?? "") ?? DBNull.Value);
                            cmd.Parameters.AddWithValue("@tipo", idTipoDocumento);
                            cmd.Parameters.AddWithValue("@pri", prioridad);
                            cmd.Parameters.AddWithValue("@limRev", DateTime.Now.AddHours(horasRevision));
                            cmd.Parameters.AddWithValue("@limFirma", DateTime.Now.AddHours(horasFirma));
                            cmd.Parameters.AddWithValue("@estado", idEstadoReg);
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        string sqlReset = @"UPDATE dp
                                            SET dp.EstadoParticipante = @pen
                                            FROM DocumentoParticipante dp
                                            INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                            WHERE dp.IdDocumento=@id
                                              AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='REV'";
                        using (var cmd = new SqlCommand(sqlReset, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@pen", idEstPartPen);
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        string sqlDelRev = @"DELETE rd
                                             FROM RevisionDetalle rd
                                             INNER JOIN DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
                                             INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                                             WHERE dp.IdDocumento=@id
                                               AND mt.Tipo='TIPO_PARTICIPANTE' AND mt.Codigo='REV'";
                        using (var cmd = new SqlCommand(sqlDelRev, conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", idDocumento);
                            cmd.ExecuteNonQuery();
                        }

                        InsertarHistorial(conn, tx, idDocumento, idEstadoAnterior, idEstadoReg, loginUsuario,
                            "Correccion enviada. Se reinicio el flujo de revision.");
                        tx.Commit();
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        mensaje = ex.Message;
                        return false;
                    }
                }
            }

            if (nuevoPdf != null && nuevoPdf.Length > 0)
            {
                GuardarOActualizarAdjunto(idDocumento, nuevoPdf, nuevoNombrePdf ?? "documento.pdf", loginUsuario);
            }

            mensaje = "Correccion enviada correctamente.";
            return true;
        }

        #endregion

        #region Utilidades

        private bool IntentarParticipanteRevisor(SqlConnection conn, SqlTransaction tx, int idDocumento, string login, out int idParticipante)
        {
            idParticipante = 0;
            string sql = @"SELECT TOP (1) dp.IdParticipante
                           FROM DocumentoParticipante dp
                           INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           WHERE dp.IdDocumento = @idDoc
                             AND dp.LoginUsuario = @login
                             AND mt.Tipo = 'TIPO_PARTICIPANTE'
                             AND mt.Codigo = 'REV'
                           ORDER BY dp.IdParticipante ASC";
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                cmd.Parameters.AddWithValue("@login", login);
                object o = cmd.ExecuteScalar();
                if (o == null || o == DBNull.Value) return false;
                idParticipante = Convert.ToInt32(o);
                return true;
            }
        }

        private int ObtenerEstadoParticipanteActual(SqlConnection conn, SqlTransaction tx, int idParticipante)
        {
            using (var cmd = new SqlCommand("SELECT EstadoParticipante FROM DocumentoParticipante WHERE IdParticipante=@idp", conn, tx))
            {
                cmd.Parameters.AddWithValue("@idp", idParticipante);
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        private int ObtenerEstadoDocumentoActual(SqlConnection conn, SqlTransaction tx, int idDocumento)
        {
            using (var cmd = new SqlCommand("SELECT IdEstadoDocumento FROM Documento WHERE IdDocumento=@id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@id", idDocumento);
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        private int ObtenerIdEstadoParticipanteConformeOObservado(SqlConnection conn, SqlTransaction tx, bool esObservacion)
        {
            if (esObservacion) return ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "OBS");

            int idReg = ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "REG");
            if (idReg > 0) return idReg;

            // Fallback por compatibilidad si REG no existe en el catalogo.
            return ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "FIR");
        }

        private void UpsertRevisionInterna(SqlConnection conn, SqlTransaction tx, int idParticipante, string comentario, bool esObservacion)
        {
            int idRevision = 0;
            using (var cmdBuscar = new SqlCommand(
                       "SELECT TOP (1) IdRevision FROM RevisionDetalle WHERE IdParticipante=@idp ORDER BY IdRevision DESC",
                       conn, tx))
            {
                cmdBuscar.Parameters.AddWithValue("@idp", idParticipante);
                object o = cmdBuscar.ExecuteScalar();
                if (o != null && o != DBNull.Value) idRevision = Convert.ToInt32(o);
            }

            if (idRevision > 0)
            {
                string sqlUpd = @"UPDATE RevisionDetalle
                                  SET Comentario=@com, EsObservacion=@obs, FechaRevision=GETDATE()
                                  WHERE IdRevision=@idr";
                using (var cmdUpd = new SqlCommand(sqlUpd, conn, tx))
                {
                    cmdUpd.Parameters.AddWithValue("@com", (object)(comentario ?? "") ?? DBNull.Value);
                    cmdUpd.Parameters.AddWithValue("@obs", esObservacion);
                    cmdUpd.Parameters.AddWithValue("@idr", idRevision);
                    cmdUpd.ExecuteNonQuery();
                }
                return;
            }

            string sqlIns = @"INSERT INTO RevisionDetalle (IdParticipante,Comentario,EsObservacion)
                              VALUES (@idp,@com,@obs)";
            using (var cmdIns = new SqlCommand(sqlIns, conn, tx))
            {
                cmdIns.Parameters.AddWithValue("@idp", idParticipante);
                cmdIns.Parameters.AddWithValue("@com", (object)(comentario ?? "") ?? DBNull.Value);
                cmdIns.Parameters.AddWithValue("@obs", esObservacion);
                cmdIns.ExecuteNonQuery();
            }
        }

        private void ActualizarEstadoParticipante(SqlConnection conn, SqlTransaction tx, int idParticipante, int idEstadoParticipante)
        {
            using (var cmd = new SqlCommand(
                       "UPDATE DocumentoParticipante SET EstadoParticipante=@est WHERE IdParticipante=@idp", conn, tx))
            {
                cmd.Parameters.AddWithValue("@est", idEstadoParticipante);
                cmd.Parameters.AddWithValue("@idp", idParticipante);
                cmd.ExecuteNonQuery();
            }
        }

        private bool TodosRevisoresConformes(SqlConnection conn, SqlTransaction tx, int idDocumento)
        {
            int idEstadoConforme = ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "REG");
            if (idEstadoConforme <= 0)
                idEstadoConforme = ObtenerIdMaestro(conn, tx, "ESTADO_PARTICIPANTE", "FIR");
            string sql = @"SELECT COUNT(1)
                           FROM DocumentoParticipante dp
                           INNER JOIN Maestro mt ON dp.IdTipoParticipante = mt.IdMaestro
                           WHERE dp.IdDocumento = @idDoc
                             AND mt.Tipo = 'TIPO_PARTICIPANTE'
                             AND mt.Codigo = 'REV'
                             AND ISNULL(dp.EstadoParticipante,0) <> @estConf";
            using (var cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                cmd.Parameters.AddWithValue("@estConf", idEstadoConforme);
                return Convert.ToInt32(cmd.ExecuteScalar()) == 0;
            }
        }

        private void ActualizarEstadoDocumentoInterno(SqlConnection conn, SqlTransaction tx, int idDocumento, int idEstado)
        {
            using (var cmd = new SqlCommand("UPDATE Documento SET IdEstadoDocumento=@estado WHERE IdDocumento=@id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@estado", idEstado);
                cmd.Parameters.AddWithValue("@id", idDocumento);
                cmd.ExecuteNonQuery();
            }
        }

        private void InsertarHistorial(SqlConnection conn, SqlTransaction tx, int idDocumento, int? idEstadoAnterior, int idEstadoNuevo, string login, string detalle)
        {
            string sql = @"INSERT INTO HistorialDocumento
                           (IdDocumento,IdEstadoAnterior,IdEstadoNuevo,LoginUsuarioAccion,DetalleAccion)
                           VALUES (@doc,@ant,@nue,@login,@detalle)";
            // SqlCommand(sql, conn, tx) lanza ArgumentNullException si tx es null
            SqlCommand cmd = tx != null
                ? new SqlCommand(sql, conn, tx)
                : new SqlCommand(sql, conn);
            using (cmd)
            {
                cmd.Parameters.AddWithValue("@doc", idDocumento);
                cmd.Parameters.AddWithValue("@ant", idEstadoAnterior.HasValue ? (object)idEstadoAnterior.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@nue", idEstadoNuevo);
                cmd.Parameters.AddWithValue("@login", login);
                cmd.Parameters.AddWithValue("@detalle", detalle ?? "");
                cmd.ExecuteNonQuery();
            }
        }

        private void GuardarOActualizarAdjunto(int idDocumento, byte[] pdf, string nombreArchivo, string login)
        {
            ReemplazarPdfConHistorial(idDocumento, pdf, nombreArchivo, login,
                "Reemplazo de PDF al enviar correccion (version anterior archivada para auditoria).");
        }

        private int ObtenerIdMaestro(SqlConnection conn, SqlTransaction transaction, string tipo, string codigo)
        {
            string sql = "SELECT IdMaestro FROM Maestro WHERE Tipo=@tipo AND Codigo=@cod";
            SqlCommand cmd = transaction != null
                ? new SqlCommand(sql, conn, transaction)
                : new SqlCommand(sql, conn);
            using (cmd)
            {
                cmd.Parameters.AddWithValue("@tipo", tipo);
                cmd.Parameters.AddWithValue("@cod", codigo);
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
            }
        }

        private Documento MapearDocumento(SqlDataReader dr)
        {
            return new Documento
            {
                IdDocumento = (int)dr["IdDocumento"],
                CodigoDocumento = dr["CodigoDocumento"].ToString(),
                Asunto = dr["Asunto"].ToString(),
                Descripcion = dr["Descripcion"] != DBNull.Value ? dr["Descripcion"].ToString() : "",
                IdTipoDocumento = (int)dr["IdTipoDocumento"],
                AreaResponsable = dr["AreaResponsable"].ToString(),
                AreaCategoria = dr["AreaCategoria"] != DBNull.Value ? dr["AreaCategoria"].ToString() : "",
                LoginUsuarioRegistrador = dr["LoginUsuarioRegistrador"].ToString(),
                RutaArchivoPDF = dr["RutaArchivoPDF"] != DBNull.Value ? dr["RutaArchivoPDF"].ToString() : "",
                IdEstadoDocumento = (int)dr["IdEstadoDocumento"],
                Prioridad = dr["Prioridad"] != DBNull.Value ? dr["Prioridad"].ToString() : "",
                FechaCreacion = (DateTime)dr["FechaCreacion"],
                FechaLimiteRevision = dr["FechaLimiteRevision"] != DBNull.Value ? (DateTime)dr["FechaLimiteRevision"] : DateTime.MinValue,
                FechaLimiteAprobacion = dr["FechaLimiteAprobacion"] != DBNull.Value ? (DateTime)dr["FechaLimiteAprobacion"] : DateTime.MinValue,
                Activo = (bool)dr["Activo"]
            };
        }

        #endregion

        #region Cambio de Roles

        /// <summary>
        /// Cambia todos los participantes de tipo REV a FIR para un documento específico.
        /// Se invoca cuando todos los revisores emiten conformidad (documento pasa a PEN).
        /// </summary>
        public bool CambiarRevisoresAFirmantes(int idDocumento, SqlConnection conn, SqlTransaction tx)
        {
            try
            {
                int idTipoFir = ObtenerIdMaestro(conn, tx, "TIPO_PARTICIPANTE", "FIR");
                if (idTipoFir <= 0)
                    return false;

                string sql = @"UPDATE DocumentoParticipante
                               SET IdTipoParticipante = @idFir
                               WHERE IdDocumento = @idDoc
                                 AND IdTipoParticipante = (SELECT IdMaestro FROM Maestro WHERE Tipo='TIPO_PARTICIPANTE' AND Codigo='REV')";

                using (var cmd = new SqlCommand(sql, conn, tx))
                {
                    cmd.Parameters.AddWithValue("@idFir", idTipoFir);
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    cmd.ExecuteNonQuery();
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Cambia todos los participantes de tipo FIR de vuelta a REV para un documento específico.
        /// Se invoca cuando todos los firmantes han firmado (documento pasa a FCOM).
        /// </summary>
        public bool CambiarFirmantesARevisores(int idDocumento, SqlConnection conn, SqlTransaction tx)
        {
            try
            {
                int idTipoRev = ObtenerIdMaestro(conn, tx, "TIPO_PARTICIPANTE", "REV");
                if (idTipoRev <= 0)
                    return false;

                string sql = @"UPDATE DocumentoParticipante
                               SET IdTipoParticipante = @idRev
                               WHERE IdDocumento = @idDoc
                                 AND IdTipoParticipante = (SELECT IdMaestro FROM Maestro WHERE Tipo='TIPO_PARTICIPANTE' AND Codigo='FIR')";

                using (var cmd = new SqlCommand(sql, conn, tx))
                {
                    cmd.Parameters.AddWithValue("@idRev", idTipoRev);
                    cmd.Parameters.AddWithValue("@idDoc", idDocumento);
                    cmd.ExecuteNonQuery();
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        #endregion

        #region Métodos para Firma Perú

        public bool ObtenerAdjuntoPrincipal(int idDocumento, out int idAdjunto, out string nombreArchivo, out byte[] contenidoPdf)
        {
            idAdjunto = 0;
            nombreArchivo = null;
            contenidoPdf = null;

            using (var conn = new SqlConnection(_connFiles))
            {
                conn.Open();
                string sql = @"SELECT TOP (1) IdAdjunto, NombreArchivo, ContenidoPDF
                               FROM DocumentoAdjunto
                               WHERE IdDocumento=@id
                                 AND ISNULL(EsEliminado,0)=0
                                 AND ISNULL(EsSuperado,0)=0
                               ORDER BY IdAdjunto DESC";

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", idDocumento);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (!dr.Read()) return false;

                        idAdjunto = (int)dr["IdAdjunto"];
                        nombreArchivo = dr["NombreArchivo"].ToString();
                        contenidoPdf = dr["ContenidoPDF"] != DBNull.Value ? (byte[])dr["ContenidoPDF"] : null;
                        return contenidoPdf != null && contenidoPdf.Length > 0;
                    }
                }
            }
        }

        public void ActualizarAdjuntoFirmado(int idDocumento, byte[] nuevoPdf, string nombreArchivo)
        {
            if (nuevoPdf == null || nuevoPdf.Length == 0) return;

            ArchivarAdjuntosVigentes(idDocumento, "Sistema", "Documento firmado digitalmente con Firma Perú");
            InsertarAdjuntoPDF(idDocumento, nuevoPdf, nombreArchivo, "Sistema");
        }

        #endregion
    }
}
