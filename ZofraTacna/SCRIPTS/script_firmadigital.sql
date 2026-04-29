-- ============================================================
-- DESCRIPCION : Script completo de creacion e inicializacion
--               de la base de datos FirmaDigital para el
--               sistema SIGEFIDD-ZOFRA (Zona Franca de Tacna)
-- Servidor    : (localdb)\sovargas
-- BD          : FirmaDigital  (referencia cruzada: administracion)
-- Estandar    : ET-003 Rev.4 ZOFRATACNA
-- Mantenimientos:
-- SN-001-2025 AngelVargas, 20/04/2026
-- ============================================================

-- ============================================================
-- 0. CONFIGURACION
-- ============================================================
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ============================================================
-- 1. BASE DE DATOS FirmaDigital
-- ============================================================
USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FirmaDigital')
BEGIN
    CREATE DATABASE FirmaDigital
    PRINT 'Base de datos FirmaDigital creada.';
END
ELSE
    PRINT 'Base de datos FirmaDigital ya existe. Continuando...';
GO

USE FirmaDigital;
GO

-- ============================================================
-- 2. TABLAS
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Maestro  (catalogo central de todos los codigos/estados)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.Maestro', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Maestro (
        IdMaestro   INT           IDENTITY(1,1)  NOT NULL,
        Tipo        VARCHAR(50)                  NOT NULL,
        Codigo      VARCHAR(20)                  NOT NULL,
        Descripcion VARCHAR(150)                 NOT NULL,
        Orden       INT                          NOT NULL CONSTRAINT df_Maestro_Orden      DEFAULT 0,
        Activo      BIT                          NOT NULL CONSTRAINT df_Maestro_Activo     DEFAULT 1,
        -- Auditoria ET-003
        IDUsuarioCreador     VARCHAR(15)         NULL,
        FechaCreacion        SMALLDATETIME       NOT NULL CONSTRAINT df_Maestro_FechaCrea  DEFAULT GETDATE(),
        IDUsuarioModificador VARCHAR(15)         NULL,
        FechaModificacion    SMALLDATETIME       NULL,
        CONSTRAINT pk_Maestro PRIMARY KEY CLUSTERED (IdMaestro),
        CONSTRAINT uq_Maestro_TipoCodigo UNIQUE (Tipo, Codigo)
    );
    PRINT 'Tabla Maestro creada.';
END
ELSE
    PRINT 'Tabla Maestro ya existe.';
GO

-- ------------------------------------------------------------
-- 2.3 Documento
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.Documento', 'U') IS NULL
BEGIN
	CREATE TABLE dbo.Documento (
		IdDocumento             INT IDENTITY(1,1) NOT NULL,
		CodigoDocumento         VARCHAR(50) NOT NULL,
		Asunto                  VARCHAR(300) NOT NULL,
		IdTipoDocumento         INT NOT NULL,
		AreaResponsable         VARCHAR(200) NOT NULL,
		AreaCategoria           VARCHAR(150) NULL,
		LoginUsuarioRegistrador VARCHAR(50) NOT NULL,
		IdEstadoDocumento       INT NOT NULL,
		IdArchivoPrincipal      INT NULL,
		NumeroRevisionActual    INT NOT NULL DEFAULT 1,
		Prioridad               VARCHAR(10) NOT NULL 
			CONSTRAINT df_Documento_Prioridad DEFAULT 'MEDIA',
		FechaCreacion           DATETIME NOT NULL 
			CONSTRAINT df_Documento_FechaCrea DEFAULT GETDATE(),
		FechaLimiteRevision     DATETIME NULL,
		FechaLimiteAprobacion   DATETIME NULL,
		Activo                  BIT NOT NULL 
			CONSTRAINT df_Documento_Activo DEFAULT 1,

		-- 🔥 NUEVO CAMPO
		TieneArchivo BIT NOT NULL 
			CONSTRAINT df_Documento_TieneArchivo DEFAULT 0,
		-- Auditoria ET-003
		IDUsuarioCreador        VARCHAR(15) NULL,
		IDUsuarioModificador    VARCHAR(15) NULL,
		FechaModificacion       SMALLDATETIME NULL,

		CONSTRAINT pk_Documento PRIMARY KEY CLUSTERED (IdDocumento),
		CONSTRAINT uq_Documento_Codigo UNIQUE (CodigoDocumento),
		CONSTRAINT fk_Documento_TipoDoc FOREIGN KEY (IdTipoDocumento) REFERENCES dbo.Maestro(IdMaestro),
		CONSTRAINT fk_Documento_EstadoDoc FOREIGN KEY (IdEstadoDocumento) REFERENCES dbo.Maestro(IdMaestro),
		CONSTRAINT ch_Documento_Prioridad CHECK (Prioridad IN ('ALTA','MEDIA','BAJA'))
	);
    PRINT 'Tabla Documento creada.';
END
ELSE
    PRINT 'Tabla Documento ya existe — columnas verificadas/agregadas.';
GO

-- ------------------------------------------------------------
-- 2.4 DocumentoParticipante
--     Un documento puede tener varios revisores y firmantes
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.DocumentoParticipante', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocumentoParticipante (
        IdParticipante      INT           IDENTITY(1,1)  NOT NULL,
        IdDocumento         INT                          NOT NULL,
        LoginUsuario        VARCHAR(50)                  NOT NULL,
        CorreoInstitucional VARCHAR(150)                 NULL,
        OrdenSecuencial     INT                          NOT NULL CONSTRAINT df_DocParticipante_Orden DEFAULT 1,
        IdTipoParticipante  INT                          NOT NULL,  -- REV o FIR desde Maestro
        EstadoParticipante  INT                          NOT NULL,
        FechaAsignacion     DATETIME                     NOT NULL CONSTRAINT df_DocParticipante_Fecha DEFAULT GETDATE(),
        -- Auditoria ET-003
        IDUsuarioCreador    VARCHAR(15)                  NULL,
        FechaCreacion       SMALLDATETIME                NOT NULL CONSTRAINT df_DocParticipante_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_DocumentoParticipante         PRIMARY KEY CLUSTERED (IdParticipante),
        CONSTRAINT fk_DocParticipante_Documento     FOREIGN KEY (IdDocumento)        REFERENCES dbo.Documento(IdDocumento),
        CONSTRAINT fk_DocParticipante_TipoPartic    FOREIGN KEY (IdTipoParticipante) REFERENCES dbo.Maestro(IdMaestro),
		CONSTRAINT fk_DocParticipante_Estado        FOREIGN KEY (EstadoParticipante) REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT uq_DocParticipante UNIQUE (IdDocumento, LoginUsuario)
  );
    PRINT 'Tabla DocumentoParticipante creada.';
END
ELSE
    PRINT 'Tabla DocumentoParticipante ya existe.';
GO

-- ------------------------------------------------------------
-- 2.5 RevisionDetalle
--     Observaciones y conformidades de cada revisor
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.RevisionDetalle', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RevisionDetalle (
        IdRevision     INT           IDENTITY(1,1)  NOT NULL,
        IdParticipante INT                          NOT NULL,
        Comentario     VARCHAR(1000)                NOT NULL,
		NumeroRevision INT                          NOT NULL,
        EsObservacion  BIT                          NOT NULL CONSTRAINT df_RevisionDetalle_EsObs DEFAULT 0,
        FechaRevision  DATETIME                     NOT NULL CONSTRAINT df_RevisionDetalle_Fecha DEFAULT GETDATE(),
        -- Auditoria ET-003
        IDUsuarioCreador    VARCHAR(15)             NULL,
        FechaCreacion       SMALLDATETIME           NOT NULL CONSTRAINT df_RevisionDetalle_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_RevisionDetalle               PRIMARY KEY CLUSTERED (IdRevision),
        CONSTRAINT fk_RevisionDetalle_Participante  FOREIGN KEY (IdParticipante) REFERENCES dbo.DocumentoParticipante(IdParticipante)
    );
    PRINT 'Tabla RevisionDetalle creada.';
END
ELSE
    PRINT 'Tabla RevisionDetalle ya existe.';
GO

-- ------------------------------------------------------------
-- 2.6 FirmaDetalle
--     Registro de cada firma digital aplicada
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.FirmaDetalle', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FirmaDetalle (
        IdFirma          INT           IDENTITY(1,1)  NOT NULL,
        IdParticipante   INT                          NOT NULL,
        IdEstadoFirma    INT                          NOT NULL,  -- ESTADO_FIRMA desde Maestro
        FirmaDigitalHash VARCHAR(500)                 NULL,      -- Hash/token del componente de firma
        FechaFirma       DATETIME                     NULL,
        -- Auditoria ET-003
        IDUsuarioCreador    VARCHAR(15)               NULL,
        FechaCreacion       SMALLDATETIME             NOT NULL CONSTRAINT df_FirmaDetalle_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_FirmaDetalle               PRIMARY KEY CLUSTERED (IdFirma),
        CONSTRAINT fk_FirmaDetalle_Participante  FOREIGN KEY (IdParticipante) REFERENCES dbo.DocumentoParticipante(IdParticipante),
        CONSTRAINT fk_FirmaDetalle_EstadoFirma   FOREIGN KEY (IdEstadoFirma)  REFERENCES dbo.Maestro(IdMaestro)
    );
    PRINT 'Tabla FirmaDetalle creada.';
END
ELSE
    PRINT 'Tabla FirmaDetalle ya existe.';
GO

-- ------------------------------------------------------------
-- 2.7 HistorialDocumento
--     Trazabilidad de todos los cambios de estado
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.HistorialDocumento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HistorialDocumento (
        IdHistorial        INT           IDENTITY(1,1)  NOT NULL,
        IdDocumento        INT                          NOT NULL,
        IdEstadoAnterior   INT                          NULL,      -- NULL = primer registro
        IdEstadoNuevo      INT                          NOT NULL,
        LoginUsuarioAccion VARCHAR(50)                  NOT NULL,
        DetalleAccion      VARCHAR(1000)                NULL,
        FechaCambio        DATETIME                     NOT NULL CONSTRAINT df_HistorialDoc_Fecha DEFAULT GETDATE(),
        -- Auditoria ET-003
        IDUsuarioCreador   VARCHAR(15)                  NULL,
        FechaCreacion      SMALLDATETIME                NOT NULL CONSTRAINT df_HistorialDoc_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_HistorialDocumento              PRIMARY KEY CLUSTERED (IdHistorial),
        CONSTRAINT fk_HistorialDoc_Documento          FOREIGN KEY (IdDocumento)      REFERENCES dbo.Documento(IdDocumento),
        CONSTRAINT fk_HistorialDoc_EstadoAnterior     FOREIGN KEY (IdEstadoAnterior) REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT fk_HistorialDoc_EstadoNuevo        FOREIGN KEY (IdEstadoNuevo)    REFERENCES dbo.Maestro(IdMaestro)
    );
    PRINT 'Tabla HistorialDocumento creada.';
END
ELSE
    PRINT 'Tabla HistorialDocumento ya existe.';
GO

-- ------------------------------------------------------------
-- 2.8 LogErrorSistema
--     Registro de errores de la aplicacion
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.LogErrorSistema', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LogErrorSistema (
        IdLog             INT           IDENTITY(1,1)  NOT NULL,
        Capa              VARCHAR(50)                  NULL,       -- Presentacion, Negocio, Datos, etc.
        MensajeError      VARCHAR(2000)                NOT NULL,
        DetalleStacktrace VARCHAR(MAX)                 NULL,
        LoginUsuario      VARCHAR(50)                  NULL,
        FechaError        DATETIME                     NOT NULL CONSTRAINT df_LogError_Fecha DEFAULT GETDATE(),
        CONSTRAINT pk_LogErrorSistema PRIMARY KEY CLUSTERED (IdLog)
    );
    PRINT 'Tabla LogErrorSistema creada.';
END
ELSE
    PRINT 'Tabla LogErrorSistema ya existe.';
GO

-- ============================================================
-- 3. DATOS DE CATALOGO (tabla Maestro)
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Roles del Sistema  (Tipo = 'ROL_SISTEMA')
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('ROL_SISTEMA', 'ADM', 'Administrador', 1, 'SISTEMA'),
    ('ROL_SISTEMA', 'REG', 'Registrador',   2, 'SISTEMA'),
    ('ROL_SISTEMA', 'REV', 'Revisor',       3, 'SISTEMA'),
    ('ROL_SISTEMA', 'FIR', 'Firmante',      4, 'SISTEMA');
    PRINT 'Datos ROL_SISTEMA insertados.';
END
ELSE
    PRINT 'ROL_SISTEMA ya tiene datos.';
GO

-- ------------------------------------------------------------
-- 3.2 Estados del Documento  (Tipo = 'ESTADO_DOC')
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_DOC')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('ESTADO_DOC', 'REG',  'Registrado',           1, 'SISTEMA'),
    ('ESTADO_DOC', 'REV',  'En Revision',           2, 'SISTEMA'),
    ('ESTADO_DOC', 'OBS',  'Observado',             3, 'SISTEMA'),
    ('ESTADO_DOC', 'PEN',  'Pendiente de Firma',    4, 'SISTEMA'),
    ('ESTADO_DOC', 'FPAR', 'Firma Parcial',         5, 'SISTEMA'),
    ('ESTADO_DOC', 'FCOM', 'Firmado Completo',      6, 'SISTEMA');
    PRINT 'Datos ESTADO_DOC insertados.';
END
ELSE
    PRINT 'ESTADO_DOC ya tiene datos.';
GO

-- ------------------------------------------------------------
-- 3.3 Tipos de Documento  (Tipo = 'TIPO_DOC')
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'TIPO_DOC')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('TIPO_DOC', 'MEM', 'Memorando',         1, 'SISTEMA'),
    ('TIPO_DOC', 'OFI', 'Oficio',            2, 'SISTEMA'),
    ('TIPO_DOC', 'RES', 'Resolucion',        3, 'SISTEMA'),
    ('TIPO_DOC', 'INF', 'Informe',           4, 'SISTEMA'),
    ('TIPO_DOC', 'ACT', 'Acta',              5, 'SISTEMA'),
    ('TIPO_DOC', 'CON', 'Contrato',          6, 'SISTEMA'),
    ('TIPO_DOC', 'DIR', 'Directiva',         7, 'SISTEMA'),
    ('TIPO_DOC', 'CIR', 'Circular',          8, 'SISTEMA'),
    ('TIPO_DOC', 'PLA', 'Plan',              9, 'SISTEMA'),
    ('TIPO_DOC', 'PRO', 'Procedimiento',    10, 'SISTEMA');
    PRINT 'Datos TIPO_DOC insertados.';
END
ELSE
    PRINT 'TIPO_DOC ya tiene datos.';
GO

-- ------------------------------------------------------------
-- 3.4 Estados de Firma  (Tipo = 'ESTADO_FIRMA')
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_FIRMA')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('ESTADO_FIRMA', 'PEN',  'Pendiente de Firma', 1, 'SISTEMA'),
    ('ESTADO_FIRMA', 'FIR',  'Firmado',            2, 'SISTEMA'),
    ('ESTADO_FIRMA', 'FCOM', 'Firma Completa',     3, 'SISTEMA');
    PRINT 'Datos ESTADO_FIRMA insertados.';
END
ELSE
    PRINT 'ESTADO_FIRMA ya tiene datos.';
GO

-- Estados del Participante
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_PARTICIPANTE')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('ESTADO_PARTICIPANTE', 'PEN', 'Pendiente', 1, 'SISTEMA'),
    ('ESTADO_PARTICIPANTE', 'REV', 'En Revision', 2, 'SISTEMA'),
    ('ESTADO_PARTICIPANTE', 'OBS', 'Observado', 3, 'SISTEMA'),
    ('ESTADO_PARTICIPANTE', 'FIR', 'Firmado', 4, 'SISTEMA');
END

-- ------------------------------------------------------------
-- 3.5 Tipos de Participante  (Tipo = 'TIPO_PARTICIPANTE')
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'TIPO_PARTICIPANTE')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden, IDUsuarioCreador) VALUES
    ('TIPO_PARTICIPANTE', 'REV', 'Revisor',  1, 'SISTEMA'),
    ('TIPO_PARTICIPANTE', 'FIR', 'Firmante', 2, 'SISTEMA');
    PRINT 'Datos TIPO_PARTICIPANTE insertados.';
END
ELSE
    PRINT 'TIPO_PARTICIPANTE ya tiene datos.';
GO


-- ============================================================
-- 7. VOLVER A FirmaDigital — VERIFICACION FINAL
-- ============================================================
USE FirmaDigital;
GO

PRINT '=== VERIFICACION DE TABLAS ===';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

PRINT '=== VERIFICACION DE CATALOGO MAESTRO ===';
SELECT Tipo, Codigo, Descripcion, Orden, Activo
FROM dbo.Maestro
ORDER BY Tipo, Orden;

PRINT '=== SCRIPT COMPLETADO EXITOSAMENTE ===';
GO

-- ============================================================
-- VISTAS
-- ============================================================
-- ============================================================
-- 5. VISTA: FD_VW_EmpleadosActivos
--    Cruza UsuarioSistema con administracion.dbo.Empleado
--    Usada por: RepositorioUsuariosRoles.ObtenerEmpleadosActivos()
-- ============================================================
IF OBJECT_ID('dbo.VW_EmpleadosActivos', 'V') IS NOT NULL
    DROP VIEW dbo.VW_EmpleadosActivos;
GO

CREATE VIEW dbo.VW_EmpleadosActivos AS
SELECT
    e.IDEmpleado,
    e.CodigoPersonal,
    e.Apellido,
    e.Nombre,
    e.Apellido + ', ' + e.Nombre AS NombreCompleto,
    e.LoginUsuario,
    ISNULL(e.Email, e.LoginUsuario + '@zofratacna.com.pe') AS Email,
    e.IDUnidadOrganica,
    e.IDCargo,
    e.IDSede,
    e.IdRol
FROM administracion.dbo.Empleado e
WHERE e.ActivoAsist = 1;
GO


-- ============================================================
-- PROCEDIMIENTOS
-- ============================================================
CREATE PROCEDURE sp_InsertarParticipante
(
    @IdDocumento INT,
    @LoginUsuario VARCHAR(50),
    @IdTipoParticipante INT
)
AS
BEGIN
    DECLARE @Estado INT;

    -- 1. Obtener el estado PEN
    SELECT @Estado = IdMaestro
    FROM Maestro
    WHERE Tipo = 'ESTADO_PARTICIPANTE'
    AND Codigo = 'PEN';

    -- 2. VALIDACIÓN (AQUÍ VA 👇)
    IF @Estado IS NULL
    BEGIN
        RAISERROR('No existe estado PEN en Maestro', 16, 1);
        RETURN;
    END

    -- 3. INSERT
    INSERT INTO DocumentoParticipante (
        IdDocumento,
        LoginUsuario,
        IdTipoParticipante,
        EstadoParticipante
    )
    VALUES (
        @IdDocumento,
        @LoginUsuario,
        @IdTipoParticipante,
        @Estado
    );
END