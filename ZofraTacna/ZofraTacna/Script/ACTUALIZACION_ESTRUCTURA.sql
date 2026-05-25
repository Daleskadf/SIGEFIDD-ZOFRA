-- ============================================================
-- ACTUALIZACION DE ESTRUCTURA DE BD
-- SISTEMA: SIGEFIDD-ZOFRA
-- FECHA: 2026-05-25
-- DESCRIPCION:
--   Agrega 2 nuevas tablas, renombra DocumentoBloqueoEdicion
--   a FIR_DocumentoBloqueoEdicion y crea vista FIR_VW_UnidadesOrganicas
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '============================================================';
PRINT ' ACTUALIZACION ESTRUCTURA SIGEFIDD-ZOFRA';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';
GO

-- ============================================================
-- PARTE 1: BD FirmaDigital - NUEVAS TABLAS
-- ============================================================
USE FirmaDigital;
GO

PRINT '';
PRINT '--- PARTE 1: FirmaDigital - Nuevas Tablas ---';
GO

-- ============================================================
-- 1.1 Tabla: DocumentoObservacionHistorial
--     Registro historico de observaciones en documentos
-- ============================================================
IF OBJECT_ID('dbo.DocumentoObservacionHistorial', 'U') IS NULL
BEGIN
    PRINT 'Creando tabla DocumentoObservacionHistorial...';
    
    CREATE TABLE dbo.DocumentoObservacionHistorial (
        IdHistorialObs       INT          IDENTITY(1,1) NOT NULL,
        IdDocumento          INT                        NOT NULL,
        LoginRevisor         VARCHAR(60)                NOT NULL,
        Comentario           VARCHAR(1000)              NOT NULL,
        FechaObservacion     DATETIME                   NOT NULL,
        FechaLevantamiento   DATETIME                   NOT NULL CONSTRAINT df_DocObsHist_FechaLev DEFAULT GETDATE(),
        LoginLevantamiento   VARCHAR(50)                NOT NULL,
        CONSTRAINT pk_DocumentoObservacionHistorial PRIMARY KEY CLUSTERED (IdHistorialObs),
        CONSTRAINT fk_DocObsHist_Documento FOREIGN KEY (IdDocumento) REFERENCES dbo.Documento(IdDocumento)
    );
    
    CREATE NONCLUSTERED INDEX ix_DocObsHist_Documento
        ON dbo.DocumentoObservacionHistorial (IdDocumento, FechaLevantamiento DESC);
    
    PRINT '✓ Tabla DocumentoObservacionHistorial creada exitosamente.';
END
ELSE
BEGIN
    PRINT '✓ Tabla DocumentoObservacionHistorial ya existe. Continuando...';
END
GO

-- ============================================================
-- 1.2 Tabla: FIR_DocumentoObsMarcador
--     Marcadores de observacion anclados al PDF
-- ============================================================
IF OBJECT_ID('dbo.FIR_DocumentoObsMarcador', 'U') IS NULL
BEGIN
    PRINT 'Creando tabla FIR_DocumentoObsMarcador...';
    
    CREATE TABLE dbo.FIR_DocumentoObsMarcador (
        IdMarcador           INT            IDENTITY(1,1) NOT NULL,
        IdDocumento          INT            NOT NULL,
        LoginUsuario         VARCHAR(15)    NOT NULL,
        TipoMarcador         VARCHAR(12)    NOT NULL CONSTRAINT df_DocObsMar_TipoMarcador DEFAULT 'pin',
        Pagina               INT            NOT NULL,
        PosX                 FLOAT          NOT NULL,
        PosY                 FLOAT          NOT NULL,
        Ancho                FLOAT          NULL,
        Alto                 FLOAT          NULL,
        TextoSeleccionado    NVARCHAR(500)  NULL,
        Comentario           NVARCHAR(1000) NOT NULL,
        EsBorrador           BIT            NOT NULL CONSTRAINT df_DocObsMar_EsBorrador DEFAULT 1,
        IDUsuarioCreador     VARCHAR(15)    NOT NULL CONSTRAINT df_DocObsMar_IDUsuarioCreador DEFAULT '',
        FechaCreacion        SMALLDATETIME  NOT NULL CONSTRAINT df_DocObsMar_FechaCreacion DEFAULT GETDATE(),
        IDUsuarioModificador VARCHAR(15)    NULL,
        FechaModificacion    SMALLDATETIME  NULL,
        CONSTRAINT pk_FIR_DocumentoObsMarcador PRIMARY KEY CLUSTERED (IdMarcador)
    );
    
    CREATE NONCLUSTERED INDEX ix_DocObsMar_IdDocumento
        ON dbo.FIR_DocumentoObsMarcador (IdDocumento, EsBorrador);
    
    PRINT '✓ Tabla FIR_DocumentoObsMarcador creada exitosamente.';
END
ELSE
BEGIN
    PRINT '✓ Tabla FIR_DocumentoObsMarcador ya existe. Continuando...';
END
GO

-- ============================================================
-- 1.3 RENOMBRAR: DocumentoBloqueoEdicion → FIR_DocumentoBloqueoEdicion
-- ============================================================
IF OBJECT_ID('dbo.DocumentoBloqueoEdicion', 'U') IS NOT NULL 
   AND OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NULL
BEGIN
    PRINT 'Renombrando DocumentoBloqueoEdicion a FIR_DocumentoBloqueoEdicion en FirmaDigital...';
    EXEC sp_rename 'dbo.DocumentoBloqueoEdicion', 'FIR_DocumentoBloqueoEdicion';
    PRINT '✓ Tabla renombrada exitosamente.';
END
ELSE IF OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NOT NULL
BEGIN
    PRINT '✓ Tabla FIR_DocumentoBloqueoEdicion ya existe. Continuando...';
END
ELSE IF OBJECT_ID('dbo.DocumentoBloqueoEdicion', 'U') IS NULL 
   AND OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NULL
BEGIN
    PRINT 'ERROR: No existe DocumentoBloqueoEdicion ni FIR_DocumentoBloqueoEdicion en FirmaDigital';
    PRINT 'Creando FIR_DocumentoBloqueoEdicion...';
    
    CREATE TABLE dbo.FIR_DocumentoBloqueoEdicion (
        IdBloqueo             INT IDENTITY(1,1)          NOT NULL,
        IdDocumento           INT                        NOT NULL,
        TipoBloqueo           VARCHAR(20)                NOT NULL,
        LoginUsuario          VARCHAR(60)                NOT NULL,
        TokenSesion           VARCHAR(80)                NOT NULL,
        FechaInicio           SMALLDATETIME              NOT NULL CONSTRAINT df_DocBloq_FechaInicio          DEFAULT GETDATE(),
        FechaUltimaActividad  SMALLDATETIME              NOT NULL CONSTRAINT df_DocBloq_FechaUltimaActividad DEFAULT GETDATE(),
        Activo                BIT                        NOT NULL CONSTRAINT df_DocBloq_Activo      DEFAULT 1,
        CONSTRAINT pk_FIR_DocumentoBloqueoEdicion PRIMARY KEY CLUSTERED (IdBloqueo)
    );

    CREATE INDEX ID_DocBloqEd_DocTipoAct
        ON dbo.FIR_DocumentoBloqueoEdicion (IdDocumento, TipoBloqueo, Activo, FechaUltimaActividad);

    CREATE INDEX ID_DocBloqEd_LogTipoAct
        ON dbo.FIR_DocumentoBloqueoEdicion (LoginUsuario, TipoBloqueo, Activo);
    
    PRINT '✓ Tabla FIR_DocumentoBloqueoEdicion creada exitosamente.';
END
GO

-- ============================================================
-- 1.4 CREAR VISTA: FIR_VW_EmpleadosActivos
-- ============================================================
IF OBJECT_ID('dbo.FIR_VW_EmpleadosActivos', 'V') IS NOT NULL
    DROP VIEW dbo.FIR_VW_EmpleadosActivos;
GO

PRINT 'Creando vista FIR_VW_EmpleadosActivos...';
GO

CREATE VIEW dbo.FIR_VW_EmpleadosActivos AS
    SELECT
        e.IDEmpleado,
        e.CodigoPersonal,
        e.Apellido,
        e.Nombre,
        e.Apellido + ', ' + e.Nombre                           AS NombreCompleto,
        e.LoginUsuario,
        ISNULL(e.Email, e.LoginUsuario + '@zofratacna.com.pe') AS Email,
        e.IDUnidadOrganica,
		uo.Descripcion AS NombreUnidad,
        uo.Abreviatura AS AreaSiglas,
		e.IDCargo,
        e.IDSede,
        e.IdRol
    FROM administracion.dbo.Empleado e
	LEFT JOIN administracion.dbo.UnidadOrganica uo ON e.IDUnidadOrganica = uo.IDUnidadOrganica
    WHERE e.ActivoAsist = 1;
GO

PRINT '✓ Vista FIR_VW_EmpleadosActivos creada exitosamente.';
GO

-- ============================================================
-- 1.5 CREAR VISTA: FIR_VW_UnidadesOrganicas
-- ============================================================
IF OBJECT_ID('dbo.FIR_VW_UnidadesOrganicas', 'V') IS NOT NULL
    DROP VIEW dbo.FIR_VW_UnidadesOrganicas;
GO

PRINT 'Creando vista FIR_VW_UnidadesOrganicas...';
GO

CREATE VIEW dbo.FIR_VW_UnidadesOrganicas AS
SELECT 
    IDUnidadOrganica, 
    Descripcion, 
    Abreviatura
FROM [administracion].[dbo].[UnidadOrganica];
GO

PRINT '✓ Vista FIR_VW_UnidadesOrganicas creada exitosamente.';
GO

-- ============================================================
-- 1.6 CREAR PROCEDIMIENTOS ALMACENADOS
-- ============================================================
PRINT '';
PRINT '--- Creando Procedimientos Almacenados ---';
GO

-- ============================================================
-- PROC 1: FIR_X_NotifAsigRev - Notificación de asignación como revisor
-- ============================================================
IF OBJECT_ID('dbo.FIR_X_NotifAsigRev', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIR_X_NotifAsigRev;
GO

CREATE PROCEDURE dbo.FIR_X_NotifAsigRev
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @TipoDoc VARCHAR(150), 
            @AreaDoc VARCHAR(150), @FechaReg VARCHAR(20);
    DECLARE @EmailDestino VARCHAR(150), @NombreRevisor VARCHAR(250), 
            @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250),
            @DiasPlazo INT;

    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @TipoDoc = m.Descripcion,
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida'),
        @FechaReg = CONVERT(VARCHAR, d.FechaCreacion, 103)
    FROM dbo.Documento d
    INNER JOIN dbo.Maestro m ON d.IdTipoDocumento = m.IdMaestro
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    DECLARE curRevisores CURSOR FOR
    SELECT v.Email, v.NombreCompleto, dp.PlazoDias
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'REV';

    OPEN curRevisores;
    FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @DiasPlazo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">',
            N'<table width="100%"><tr><td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>',
            N'<td style="text-align: center; opacity: 0.8;">Sistema de Firmado Digital</td>',
            N'<td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td></tr></table></div>',
            N'<div style="background-color: #2b6cb0; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">Documento asignado para revisión</div>',
            N'<div style="padding: 30px; color: #444; line-height: 1.5;">',
            N'<p style="margin-top: 0;">Estimado(a),<br><strong style="font-size: 18px; color: #1a202c;">', @NombreRevisor, N'</strong></p>',
            N'<p style="font-size: 14px;">Se le ha asignado un documento para revisión en el Sistema de Firmado Digital de ZOFRATACNA.</p>',
            N'<div style="background-color: #ebf4ff; border-radius: 4px; padding: 20px; margin: 20px 0;">',
            N'<h4 style="color: #2c5282; margin: 0 0 15px 0; font-size: 12px; text-transform: uppercase;">Detalle del documento</h4>',
            N'<table style="width: 100%; font-size: 13px; border-collapse: collapse; color: #2d3748;">',
            N'<tr><td style="color: #4a5568; width: 35%; padding: 4px 0;">Asunto</td><td><strong>', @AsuntoDoc, N'</strong></td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Tipo</td><td>', @TipoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Área responsable</td><td>', @AreaDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Código</td><td>', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Fecha de registro</td><td>', @FechaReg, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Plazo para revisar</td><td><span style="background-color: #bee3f8; color: #2c5282; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Hasta ', CAST(@DiasPlazo AS VARCHAR(10)), N' días</span></td></tr>',
            N'</table></div>',
            N'<div style="text-align: center; margin-top: 30px;">',
            N'<a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 40px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 15px; display: inline-block;">Revisar documento ahora</a>',
            N'</div></div>',
            N'<div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: left; border-top: 1px solid #edf2f7;">',
            N'Mensaje generado automáticamente — ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'Asignación de Revisión - ', @CodigoDoc);
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;
        FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @DiasPlazo;
    END

    CLOSE curRevisores;
    DEALLOCATE curRevisores;
END
GO

PRINT '✓ Procedimiento FIR_X_NotifAsigRev creado.';
GO

-- ============================================================
-- PROC 2: FIR_X_NotifObsDoc - Notificación de observación
-- ============================================================
IF OBJECT_ID('dbo.FIR_X_NotifObsDoc', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIR_X_NotifObsDoc;
GO

CREATE PROCEDURE dbo.FIR_X_NotifObsDoc
    @IdDocumento INT,
    @LoginRevisorQueObserva VARCHAR(50),
    @ComentarioObservacion VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @AreaDoc VARCHAR(150), @NombreObservador VARCHAR(250);
    DECLARE @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250), @EmailDestino VARCHAR(150);

    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida')
    FROM dbo.Documento d
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    SELECT @NombreObservador = NombreCompleto FROM dbo.FIR_VW_EmpleadosActivos WHERE LoginUsuario = @LoginRevisorQueObserva;

    DECLARE curNotificar CURSOR FOR
    SELECT DISTINCT v.Email FROM dbo.Documento d 
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON d.LoginUsuarioRegistrador = v.LoginUsuario WHERE d.IdDocumento = @IdDocumento
    UNION
    SELECT v.Email FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'REV';

    OPEN curNotificar;
    FETCH NEXT FROM curNotificar INTO @EmailDestino;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">',
            N'<table width="100%"><tr><td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>',
            N'<td style="text-align: center; opacity: 0.8;">Gestión de Firma Digital</td>',
            N'<td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td></tr></table></div>',
            N'<div style="background-color: #e53e3e; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">⚠️ DOCUMENTO OBSERVADO</div>',
            N'<div style="padding: 30px; color: #444; line-height: 1.5;">',
            N'<p style="margin-top: 0;">Se informa que el revisor <strong>', @NombreObservador, N'</strong> ha realizado una observación técnica al documento.</p>',
            N'<div style="background-color: #fff5f5; border-left: 4px solid #e53e3e; padding: 15px; margin: 20px 0;">',
            N'<h4 style="color: #c53030; margin: 0 0 5px 0; font-size: 11px; text-transform: uppercase;">Detalle de la observación:</h4>',
            N'<p style="font-style: italic; margin: 0; color: #2d3748;">"', @ComentarioObservacion, N'"</p></div>',
            N'<table style="width: 100%; font-size: 13px; border-collapse: collapse; color: #2d3748; margin-bottom: 20px;">',
            N'<tr><td style="color: #4a5568; width: 35%; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Documento:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;"><strong>', @AsuntoDoc, N'</strong></td></tr>',
            N'<tr><td style="color: #4a5568; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Código:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;">', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Área:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;">', @AreaDoc, N'</td></tr></table>',
            N'<div style="text-align: center; margin-top: 30px;">',
            N'<a href="https://zofratacna.com.pe" style="background-color: #e53e3e; color: white; padding: 12px 35px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 13px; display: inline-block;">Ver Observación en el Sistema</a></div></div>',
            N'<div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: center; border-top: 1px solid #edf2f7;">Este es un mensaje automático generado por SIGEFIDD-ZOFRA. Por favor no responder.</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'OBSERVACIÓN: ', @CodigoDoc, N' - ', @AsuntoDoc);
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;
        FETCH NEXT FROM curNotificar INTO @EmailDestino;
    END

    CLOSE curNotificar;
    DEALLOCATE curNotificar;
END
GO

PRINT '✓ Procedimiento FIR_X_NotifObsDoc creado.';
GO

-- ============================================================
-- PROC 3: FIR_X_NotifDocCorreg - Notificación de corrección
-- ============================================================
IF OBJECT_ID('dbo.FIR_X_NotifDocCorreg', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIR_X_NotifDocCorreg;
GO

CREATE PROCEDURE dbo.FIR_X_NotifDocCorreg
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @NombreRegistrador VARCHAR(250), 
            @FechaCorreccion VARCHAR(20), @RevisionActual INT;
    DECLARE @EmailDestino VARCHAR(150), @NombreRevisor VARCHAR(250), 
            @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250),
            @PlazoTexto VARCHAR(100), @ListaObservaciones NVARCHAR(MAX);

    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @RevisionActual = d.NumeroRevisionActual,
        @NombreRegistrador = v.NombreCompleto,
        @FechaCorreccion = CONVERT(VARCHAR, GETDATE(), 103) 
    FROM dbo.Documento d
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON d.LoginUsuarioRegistrador = v.LoginUsuario
    WHERE d.IdDocumento = @IdDocumento;

    SET @ListaObservaciones = '';
    SELECT @ListaObservaciones = @ListaObservaciones + 
        N'<div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 10px; margin-bottom: 10px; font-size: 13px;">' +
        N'<strong style="color: #cb4335;">' + v.NombreCompleto + N' — ' + CONVERT(VARCHAR, rd.FechaRevision, 103) + N'</strong><br>' +
        N'<span style="color: #555;">' + rd.Comentario + N'</span></div>'
    FROM dbo.RevisionDetalle rd
    INNER JOIN dbo.DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    WHERE dp.IdDocumento = @IdDocumento AND rd.EsObservacion = 1
    AND rd.NumeroRevision = (@RevisionActual - 1);

    DECLARE curRevisores CURSOR FOR
    SELECT v.Email, v.NombreCompleto, 
           CONCAT('Hasta ', CONVERT(VARCHAR, DATEADD(DAY, dp.PlazoDias, GETDATE()), 103), ' (', dp.PlazoDias, ' días)')
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'REV';

    OPEN curRevisores;
    FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @PlazoTexto;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px;"><table width="100%"><tr>',
            N'<td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 14px;">ZOFRATACNA</span></td>',
            N'<td style="text-align: center; font-size: 12px; opacity: 0.8;">Sistema de Firmado Digital</td>',
            N'<td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td></tr></table></div>',
            N'<div style="background-color: #d68910; color: white; padding: 10px 20px; font-weight: bold; font-size: 13px;">Documento corregido — se reinicia la revisión</div>',
            N'<div style="padding: 25px; color: #333;">',
            N'<p style="margin-top: 0; font-size: 13px;">Estimado(a),<br><strong style="font-size: 16px;">', @NombreRevisor, N'</strong></p>',
            N'<p style="font-size: 14px; line-height: 1.5;">El documento que fue marcado como <b>Observado</b> ha sido corregido por el registrador responsable y ha sido enviado nuevamente a revisión.</p>',
            N'<div style="background-color: #fef5e7; border-radius: 4px; padding: 15px; margin: 20px 0;">',
            N'<h4 style="color: #a04000; margin: 0 0 10px 0; font-size: 12px; text-transform: uppercase;">DETALLE DEL DOCUMENTO</h4>',
            N'<table style="width: 100%; font-size: 13px; border-collapse: collapse;">',
            N'<tr><td style="color: #d68910; width: 35%; padding: 3px 0;">Asunto</td><td><b>', @AsuntoDoc, N'</b></td></tr>',
            N'<tr><td style="color: #d68910; padding: 3px 0;">Código</td><td>', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #d68910; padding: 3px 0;">Vuelta de revisión</td><td><span style="background-color: #f8c471; color: #784212; padding: 1px 8px; border-radius: 10px; font-size: 11px;">', CAST(@RevisionActual AS VARCHAR), N'da revisión</span></td></tr>',
            N'<tr><td style="color: #d68910; padding: 3px 0;">Corregido por</td><td>', @NombreRegistrador, N'</td></tr>',
            N'<tr><td style="color: #d68910; padding: 3px 0;">Fecha de corrección</td><td>', @FechaCorreccion, N'</td></tr>',
            N'<tr><td style="color: #d68910; padding: 3px 0;">Nuevo plazo</td><td><span style="background-color: #f5c061; padding: 1px 8px; border-radius: 10px; font-size: 11px;">', @PlazoTexto, N'</span></td></tr></table></div>',
            N'<h4 style="color: #555; font-size: 12px; border-bottom: 1px solid #eee; padding-bottom: 5px;">OBSERVACIONES REGISTRADAS EN LA REVISIÓN ANTERIOR</h4>',
            @ListaObservaciones,
            N'<div style="text-align: center; margin-top: 20px;">',
            N'<a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 14px; display: inline-block;">Revisar documento corregido</a>',
            N'</div></div>',
            N'<div style="background-color: #f9f9f9; padding: 15px 20px; font-size: 10px; color: #999; border-top: 1px solid #eee;">',
            N'Mensaje generado automáticamente — ZOFRATACNA</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'Documento Corregido — ', @CodigoDoc);
        EXEC [dbo].[GEN_X_EnviarMail] @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;
        FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @PlazoTexto;
    END

    CLOSE curRevisores;
    DEALLOCATE curRevisores;
END
GO

PRINT '✓ Procedimiento FIR_X_NotifDocCorreg creado.';
GO

-- ============================================================
-- PROC 4: FIR_X_NotifAsigFirma - Notificación de asignación de firma
-- ============================================================
IF OBJECT_ID('dbo.FIR_X_NotifAsigFirma', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIR_X_NotifAsigFirma;
GO

CREATE PROCEDURE dbo.FIR_X_NotifAsigFirma
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @AreaDoc VARCHAR(150);
    DECLARE @EmailDestino VARCHAR(150), @NombreFirmante VARCHAR(250), @Orden INT;
    DECLARE @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250);

    SELECT 
        @AsuntoDoc = d.Asunto, 
        @CodigoDoc = d.CodigoDocumento, 
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida')
    FROM dbo.Documento d
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    DECLARE curFirmantes CURSOR FOR
    SELECT v.Email, v.NombreCompleto, dp.OrdenSecuencial 
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'FIR'
    ORDER BY dp.OrdenSecuencial;

    OPEN curFirmantes;
    FETCH NEXT FROM curFirmantes INTO @EmailDestino, @NombreFirmante, @Orden;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">',
            N'<table width="100%"><tr><td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>',
            N'<td style="text-align: right; opacity: 0.8;">Módulo de Firma Digital</td></tr></table></div>',
            N'<div style="background-color: #2c5282; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">Asignación de Firma Digital - Orden N° ', @Orden, N'</div>',
            N'<div style="padding: 30px; color: #444; line-height: 1.5;">',
            N'<p style="margin-top: 0;">Estimado(a) <strong>', @NombreFirmante, N'</strong>,</p>',
            N'<p style="font-size: 14px;">Se le informa que el proceso de revisión ha concluido satisfactoriamente. Usted ha sido asignado como <strong>Firmante N° ', @Orden, N'</strong> para el siguiente documento:</p>',
            N'<div style="background-color: #f7fafc; border: 1px solid #edf2f7; border-radius: 6px; padding: 20px; margin: 20px 0;">',
            N'<table style="width: 100%; font-size: 13px; color: #2d3748;">',
            N'<tr><td style="color: #4a5568; width: 35%; padding: 4px 0;">Asunto:</td><td><strong>', @AsuntoDoc, N'</strong></td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Código:</td><td>', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Origen:</td><td>', @AreaDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Su Posición:</td><td><span style="background-color: #bee3f8; color: #2c5282; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Prioridad de Firma ', @Orden, N'</span></td></tr></table></div>',
            N'<div style="text-align: center;"><a href="https://zofratacna.com.pe" style="background-color: #2b6cb0; color: white; padding: 12px 40px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">Ingresar para Firmar</a></div></div>',
            N'<div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: center; border-top: 1px solid #edf2f7;">Este es un mensaje automático de SIGEFIDD-ZOFRA.</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'PENDIENTE DE FIRMA (N° ', @Orden, N'): ', @CodigoDoc);
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;
        FETCH NEXT FROM curFirmantes INTO @EmailDestino, @NombreFirmante, @Orden;
    END

    CLOSE curFirmantes;
    DEALLOCATE curFirmantes;
END
GO

PRINT '✓ Procedimiento FIR_X_NotifAsigFirma creado.';
GO
USE FirmaDigital_Files;
GO

PRINT '';
PRINT '--- PARTE 2: FirmaDigital_Files - Renombrar Tabla ---';
GO

-- ============================================================
-- 2.1 RENOMBRAR: DocumentoBloqueoEdicion → FIR_DocumentoBloqueoEdicion
-- ============================================================
IF OBJECT_ID('dbo.DocumentoBloqueoEdicion', 'U') IS NOT NULL 
   AND OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NULL
BEGIN
    PRINT 'Renombrando DocumentoBloqueoEdicion a FIR_DocumentoBloqueoEdicion en FirmaDigital_Files...';
    EXEC sp_rename 'dbo.DocumentoBloqueoEdicion', 'FIR_DocumentoBloqueoEdicion';
    PRINT '✓ Tabla renombrada exitosamente.';
END
ELSE IF OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NOT NULL
BEGIN
    PRINT '✓ Tabla FIR_DocumentoBloqueoEdicion ya existe en FirmaDigital_Files. Continuando...';
END
ELSE
BEGIN
    PRINT '⚠ Tabla DocumentoBloqueoEdicion no encontrada en FirmaDigital_Files.';
END
GO

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
PRINT '';
PRINT '============================================================';
PRINT ' VERIFICACION FINAL DE ACTUALIZACION';
PRINT '============================================================';
GO

USE FirmaDigital;
GO

PRINT '';
PRINT '--- Tablas en FirmaDigital ---';
SELECT 
    'DocumentoObservacionHistorial' AS [Tabla],
    CASE WHEN OBJECT_ID('dbo.DocumentoObservacionHistorial') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END AS [Estado]
UNION ALL
SELECT 
    'FIR_DocumentoObsMarcador',
    CASE WHEN OBJECT_ID('dbo.FIR_DocumentoObsMarcador') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END
UNION ALL
SELECT 
    'FIR_DocumentoBloqueoEdicion',
    CASE WHEN OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END
UNION ALL
SELECT 
    'FIR_VW_EmpleadosActivos',
    CASE WHEN OBJECT_ID('dbo.FIR_VW_EmpleadosActivos', 'V') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END
UNION ALL
SELECT 
    'FIR_VW_UnidadesOrganicas',
    CASE WHEN OBJECT_ID('dbo.FIR_VW_UnidadesOrganicas', 'V') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END
ORDER BY [Tabla];
GO

USE FirmaDigital_Files;
GO

PRINT '';
PRINT '--- Tablas en FirmaDigital_Files ---';
SELECT 
    'FIR_DocumentoBloqueoEdicion' AS [Tabla],
    CASE WHEN OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion') IS NOT NULL THEN '✓ EXISTE' ELSE '❌ FALTA' END AS [Estado];
GO

PRINT '';
PRINT '============================================================';
PRINT ' ACTUALIZACION COMPLETADA';
PRINT '============================================================';
