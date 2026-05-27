-- ============================================================
-- SISTEMA   : SIGEFIDD-ZOFRA
--             Sistema de Gestion de Firma Digital de Documentos
--             Zona Franca de Tacna
-- ARCHIVO   : Zofra-todojunto.sql
-- DESCRIPCION: Script unificado, completo e idempotente.
--              Crea desde cero las 3 bases de datos necesarias,
--              todas las tablas, catalogos, usuarios, vistas
--              y procedimientos almacenados.
--              Se puede ejecutar N veces sin errores.
-- SERVIDOR  : (localdb)\sovargas  (ajustar si es diferente)
-- ESTANDAR  : ET-003 Rev.4 ZOFRATACNA
-- FECHA     : 2026-04-22
-- AUTOR     : AngelVargas / equipo SIGEFIDD-ZOFRA
-- ============================================================
--
-- ORDEN DE EJECUCION:
--   PARTE 1 -> BD: administracion      (empleados institucionales)
--   PARTE 2 -> BD: FirmaDigital        (core del sistema)
--   PARTE 3 -> BD: FirmaDigital_Files  (repositorio de PDFs)
--
-- INSTRUCCIONES:
--   1. Abrir en SQL Server Management Studio o Azure Data Studio
--   2. Conectarse a (localdb)\sovargas
--   3. Ejecutar TODO el script (F5 o Ejecutar)
--   4. Revisar los PRINT al final para confirmar exito
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '============================================================';
PRINT ' SIGEFIDD-ZOFRA  -  Script de instalacion completa';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';
GO

-- ============================================================
-- PARTE 1: BASE DE DATOS  administracion
--   Emula la BD institucional de ZOFRATACNA.
--   El sistema la consulta via JOIN cross-database para
--   obtener datos de empleados (nombre, email, etc.).
-- ============================================================
PRINT '';
PRINT '--- PARTE 1: administracion ---';
GO

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'administracion')
BEGIN
    CREATE DATABASE administracion;
    PRINT 'BD administracion creada.';
END
ELSE
    PRINT 'BD administracion ya existe. Continuando...';
GO

USE administracion;
GO

-- ------------------------------------------------------------
-- Tabla: dbo.UnidadOrganica  (DEBE crearse ANTES que Empleado
--   porque Empleado tiene FK a esta tabla)
--   Estructura simulada de la BD institucional.
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.UnidadOrganica', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UnidadOrganica (
        IDUnidadOrganica      INT NOT NULL,
        Descripcion           VARCHAR(250) NOT NULL,
        Abreviatura           VARCHAR(20)  NULL,
        CodigoUnidadOrganica  VARCHAR(20)  NULL,
		CONSTRAINT pk_UnidadOrganica PRIMARY KEY CLUSTERED (IDUnidadOrganica)
    );
    PRINT 'Tabla UnidadOrganica creada.';
END
GO
-- INSERTANDO REGISTROS A LA TABLA UNIDADORGANICA
IF NOT EXISTS (SELECT 1 FROM dbo.UnidadOrganica WHERE IDUnidadOrganica = 164)
BEGIN
INSERT INTO dbo.UnidadOrganica (IDUnidadOrganica, Descripcion, Abreviatura, CodigoUnidadOrganica)
VALUES
(164, 'GERENCIA GENERAL', 'GG', '2000'),
(289, 'Área de Fiscalización', 'AFIS', '2200'),
(385, 'Unidad de Relaciones Públicas e Imagen Institucional', 'URPII', '2300'),
(290, 'ORGANO DE CONTROL INSTITUCIONAL', 'OCI', '3000'),
(386, 'Sistema de Actividades de Control y Seguimiento', 'URPII', '3100'),
(387, 'Sistema de Acciones de Control', 'SAC', '3200'),
(363, 'OFICINA DE ASESORIA JURIDICA', 'OAJ', '4000'),
(388, 'Unidad de Asuntos Judiciales', 'UAJ', '4100'),
(389, 'Unidad de Asuntos Administrativos', 'UAA', '4200'),
(296, 'OFICINA DE PLANEAMIENTO Y PRESUPUESTO', 'OPP', '5000'),
(390, 'Sistemas de Gestión', 'SG', '5100'),
(391, 'Sistema de Presupuesto y Proyectos', 'SPYP', '5200'),
(392, 'Sistema de Planes y Programas', 'SPP', '5300'),
(393, 'Sistema de Racionalización', 'SR', '5400'),
(301, 'OFICINA DE ADMINISTRACION Y FINANZAS', 'OAF', '6000'),
(381, 'Área de Gestión del Talento Humano', 'AGTH', '6100'),
(302, 'Área de Contabilidad', 'AC', '6200'),
(303, 'Área de Tesorería', 'AT', '6300'),
(332, 'Área de Logística', 'AL', '6400'),
(394, 'Unidad de Transporte y Mantenimiento', 'UTYM', '6410'),
(395, 'Unidad de Áreas Verdes y Jardinería', 'UAVYJ', '6420'),
(396, 'Unidad de Control Patrimonial', 'UCP', '6500'),
(397, 'Unidad de Archivo Central', 'UAC', '6600'),
(398, 'Unidad de Seguridad y Vigilancia', 'USYV', '6700'),
(399, 'Unidad de Trámite Documentario', 'UTD', '6800'),
(366, 'GERENCIA DE PROMOCION Y DESARROLLO', 'GPD', '7000'),
(367, 'Área de Marketing y Promoción', 'AMP', '7100'),
(368, 'Área de Soluciones al Usuario', 'ASU', '7200'),
(372, 'Área de Desarrollo e Infraestructura', 'ADI', '7300'),
(321, 'GERENCIA DE OPERACIONES', 'GO', '9000'),
(322, 'Sección de Registro de Usuarios', 'SRU', '9100'),
(382, 'Sección Archivo GO', 'SAGO', '9200'),
(336, 'Área de Control Operativo, Zona Comercial y de Franquicia', 'ACOZC', '9300'),
(337, 'Sección de Control Operativo y de Zona Comercial', 'SCOZC', '9310'),
(323, 'Sección Control de Franquicia', 'SCF', '9320'),
(338, 'Área de Técnica Aduanera', 'ATAD', '9400'),
(339, 'Sección de Valoración', 'SVAL', '9410'),
(340, 'Sección de Nomenclatura y Procedimientos', 'SNP', '9420'),
(341, 'Área de Operaciones Aduaneras', 'AOAD', '9500'),
(342, 'Sección de Garita y Balanza', 'SGB', '9510'),
(343, 'Sección de Depósito Franco', 'SDF', '9520'),
(327, 'Área de Actividades Productivas', 'AAP', '9600'),
(328, 'Área de Régimen Simplificado', 'ARS', '9700'),
(345, 'Sección de Registro de Información de Régimen Simplificado', 'SRIRS', '9710'),
(347, 'Sección de Almacén - Régimen Simplificado', 'SARS', '9730'),
(348, 'Sección de Control de Plataforma Régimen Simplificado', 'SCPRS', '9740'),
(383, 'Sección de Clasificación, Codificación y Valoración', 'SCCV', '9750'),
(384, 'Sección de Aforo', 'SA', '9760'),
(376, 'Área de Tecnologías de la Información y Comunicaciones', 'ATI', '9800'),
(377, 'Sección de Desarrollo de Sistemas', 'SDS', '9810'),
(378, 'Sección de Administración de la Información', 'SAI', '9820'),
(379, 'Sección de Soporte', 'SST', '9830');
    PRINT 'Registros de Unidad Organica insertados correctamente.';
END
ELSE
    PRINT 'Registros de Unidad Organica ya existen.';
GO

-- ------------------------------------------------------------
-- Tabla: dbo.Empleado
--   Estructura simulada de la BD institucional.
--   ActivoAsist = 1  ->  empleado activo visible al sistema.
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.Empleado', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Empleado (
        IDEmpleado       INT          IDENTITY(1,1) NOT NULL,
        CodigoPersonal   VARCHAR(20)                NULL,
        Apellido         VARCHAR(100)               NULL,
        Nombre           VARCHAR(100)               NULL,
        LoginUsuario     VARCHAR(50)                NOT NULL,
        Email            VARCHAR(100)               NULL,
        IDUnidadOrganica INT                        NULL,
        IDCargo          INT                        NULL,
        IDSede           INT                        NULL,
        IdRol            INT                        NULL,
        ActivoAsist      BIT                        NOT NULL
            CONSTRAINT df_Empleado_ActivoAsist DEFAULT 1,
        CONSTRAINT pk_Empleado PRIMARY KEY CLUSTERED (IDEmpleado),
        CONSTRAINT uq_Empleado_Login UNIQUE (LoginUsuario),
		CONSTRAINT fk_Empleado_UnidadOrganica FOREIGN KEY (IDUnidadOrganica) 
            REFERENCES dbo.UnidadOrganica(IDUnidadOrganica)
    );
    PRINT 'Tabla administracion.dbo.Empleado creada.';
END
ELSE
    PRINT 'Tabla administracion.dbo.Empleado ya existe.';
GO


-- Seed: 4 empleados (coinciden 1-a-1 con UsuarioSistema en FirmaDigital)
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'arivera')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email)
    VALUES ('001', 'Rivera', 'Augusto', 'arivera', 'arivera@zofratacna.com.pe');

IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'avargas')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email)
    VALUES ('002', 'Vargas Gutierrez', 'Angel', 'avargas', 'avargas@zofratacna.com.pe');

IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'wsalas')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email)
    VALUES ('003', 'Salas', 'Walter', 'wsalas', 'wsalas@zofratacna.com.pe');

IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'dfernandez')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email)
    VALUES ('004', 'Fernandez', 'Daleska', 'dfernandez', 'dfernandez@zofratacna.com.pe');

PRINT 'Empleados de administracion verificados/insertados.';
GO

-- Insertamos 5 nuevos empleados con guard de duplicados
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'rcondori')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email, IDUnidadOrganica, ActivoAsist)
    VALUES ('2024-010', 'Condori Quispe', 'Ricardo', 'rcondori', 'daleskanicolle118@gmail.com', 164, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'cflores')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email, IDUnidadOrganica, ActivoAsist)
    VALUES ('2024-011', 'Flores Tapia', 'Claudia', 'cflores', 'daleskafervilla118@gmail.com', 376, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'rmendoza')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email, IDUnidadOrganica, ActivoAsist)
    VALUES ('2024-012', 'Mendoza Valdivia', 'Roberto', 'rmendoza', 'roberto_m@outlook.com', 301, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'pzeballos')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email, IDUnidadOrganica, ActivoAsist)
    VALUES ('2024-013', 'Zeballos Luna', 'Patricia', 'pzeballos', 'p.zeballos@upt.pe', 363, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE LoginUsuario = 'fvargas')
    INSERT INTO dbo.Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email, IDUnidadOrganica, ActivoAsist)
    VALUES ('2024-014', 'Vargas Machuca', 'Fernando', 'fvargas', 'fernando_vargas@zofra.pe', 332, 1);

PRINT '5 nuevos empleados verificados/insertados.';
GO
-- ============================================================
-- PARTE 2: BASE DE DATOS  FirmaDigital
--   Core del sistema SIGEFIDD-ZOFRA.
--   Contiene toda la logica de documentos, participantes,
--   revisiones, firmas e historial.
-- ============================================================
PRINT '';
PRINT '--- PARTE 2: FirmaDigital ---';
GO

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FirmaDigital')
BEGIN
    CREATE DATABASE FirmaDigital;
    PRINT 'BD FirmaDigital creada.';
END
ELSE
    PRINT 'BD FirmaDigital ya existe. Continuando...';
GO

USE FirmaDigital;
GO

-- ============================================================
-- 2.1  Maestro
--   Catalogo central de todos los codigos y estados.
--   Patron: Tipo + Codigo identifican cada valor unico.
--   Tipos usados: ROL_SISTEMA, ESTADO_DOC, TIPO_DOC,
--                 ESTADO_FIRMA, TIPO_PARTICIPANTE, ESTADO_PARTICIPANTE
-- ============================================================
IF OBJECT_ID('dbo.Maestro', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Maestro (
        IdMaestro            INT          IDENTITY(1,1) NOT NULL,
        Tipo                 VARCHAR(50)                NOT NULL,
        Codigo               VARCHAR(20)                NOT NULL,
        Descripcion          VARCHAR(150)               NOT NULL,
        Orden                INT                        NOT NULL CONSTRAINT df_Maestro_Orden      DEFAULT 0,
        Activo               BIT                        NOT NULL CONSTRAINT df_Maestro_Activo     DEFAULT 1,
        -- Auditoria ET-003
        IDUsuarioCreador     VARCHAR(15)                NULL,
        FechaCreacion        SMALLDATETIME              NOT NULL CONSTRAINT df_Maestro_FechaCrea  DEFAULT GETDATE(),
        IDUsuarioModificador VARCHAR(15)                NULL,
        FechaModificacion    SMALLDATETIME              NULL,
        CONSTRAINT pk_Maestro            PRIMARY KEY CLUSTERED (IdMaestro),
        CONSTRAINT uq_Maestro_TipoCodigo UNIQUE (Tipo, Codigo)
    );
    PRINT 'Tabla Maestro creada.';
END
ELSE
    PRINT 'Tabla Maestro ya existe.';
GO

-- ============================================================
-- 2.2  UsuarioSistema
--   Usuarios habilitados para ingresar al sistema.
--   IdRolSistema -> FK a Maestro (Tipo = ROL_SISTEMA).
-- ============================================================
IF OBJECT_ID('dbo.UsuarioSistema', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuarioSistema (
        IdUsuario            INT          IDENTITY(1,1) NOT NULL,
        LoginUsuario         VARCHAR(50)                NOT NULL,
        Password             VARCHAR(100)               NULL,
        IdRolSistema         INT                        NOT NULL,
        Activo               BIT                        NOT NULL CONSTRAINT df_UsuarioSistema_Activo    DEFAULT 1,
        -- Auditoria ET-003
        IDUsuarioCreador     VARCHAR(15)                NULL,
        FechaCreacion        SMALLDATETIME              NOT NULL CONSTRAINT df_UsuarioSistema_FechaCrea DEFAULT GETDATE(),
        IDUsuarioModificador VARCHAR(15)                NULL,
        FechaModificacion    SMALLDATETIME              NULL,
        CONSTRAINT pk_UsuarioSistema         PRIMARY KEY CLUSTERED (IdUsuario),
        CONSTRAINT uq_UsuarioSistema_Login   UNIQUE (LoginUsuario),
        CONSTRAINT fk_UsuarioSistema_Maestro FOREIGN KEY (IdRolSistema) REFERENCES dbo.Maestro(IdMaestro)
    );
    PRINT 'Tabla UsuarioSistema creada.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.UsuarioSistema') AND name='Password')
        ALTER TABLE dbo.UsuarioSistema ADD Password VARCHAR(100) NULL;
    PRINT 'Tabla UsuarioSistema ya existe - columnas verificadas/agregadas.';
END
GO

-- ============================================================
-- 2.3  Documento
--   Tabla principal del sistema.
--   RutaArchivoPDF_Firmado  -> ruta del PDF con firma aplicada
--   IdArchivoPrincipal      -> FK logico a FirmaDigital_Files
--   NumeroRevisionActual    -> DEFAULT 1 (sin revision aun)
--   TieneArchivo            -> flag; 0 = solo metadatos
--   Prioridad               -> ALTA / MEDIA / BAJA
-- ============================================================
IF OBJECT_ID('dbo.Documento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Documento (
        IdDocumento             INT          IDENTITY(1,1) NOT NULL,
        CodigoDocumento         VARCHAR(50)                NOT NULL,
        Asunto                  VARCHAR(300)               NOT NULL,  -- ampliado de 255
        Descripcion             VARCHAR(500)               NULL,
        IdTipoDocumento         INT                        NOT NULL,
		AreaResponsable         INT                        NOT NULL,
        AreaCategoria           VARCHAR(150)               NULL,
        LoginUsuarioRegistrador VARCHAR(50)                NOT NULL,
        RutaArchivoPDF          VARCHAR(500)               NULL,
        RutaArchivoPDF_Firmado  VARCHAR(500)               NULL,
        IdArchivoPrincipal      INT                        NULL,
        IdEstadoDocumento       INT                        NOT NULL,
        NumeroRevisionActual    INT                        NOT NULL CONSTRAINT df_Documento_NroRev       DEFAULT 1,
        Prioridad               VARCHAR(10)                NOT NULL CONSTRAINT df_Documento_Prioridad    DEFAULT 'MEDIA',
        FechaCreacion           DATETIME                   NOT NULL CONSTRAINT df_Documento_FechaCrea    DEFAULT GETDATE(),
        FechaLimiteRevision     DATETIME                   NULL,
        FechaLimiteAprobacion   DATETIME                   NULL,
        TieneArchivo            BIT                        NOT NULL CONSTRAINT df_Documento_TieneArchivo DEFAULT 0,
        Activo                  BIT                        NOT NULL CONSTRAINT df_Documento_Activo       DEFAULT 1,
        -- Auditoria ET-003
        IDUsuarioCreador        VARCHAR(15)                NULL,
        IDUsuarioModificador    VARCHAR(15)                NULL,
        FechaModificacion       SMALLDATETIME              NULL,
        CONSTRAINT pk_Documento           PRIMARY KEY CLUSTERED (IdDocumento),
        CONSTRAINT uq_Documento_Codigo    UNIQUE (CodigoDocumento),
        CONSTRAINT fk_Documento_TipoDoc   FOREIGN KEY (IdTipoDocumento)   REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT fk_Documento_EstadoDoc FOREIGN KEY (IdEstadoDocumento) REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT ch_Documento_Prioridad CHECK (Prioridad IN ('ALTA','MEDIA','BAJA'))
    );
    PRINT 'Tabla Documento creada.';
END
ELSE
BEGIN
    -- Columnas que pudieron no existir en versiones anteriores
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='Descripcion')
        ALTER TABLE dbo.Documento ADD Descripcion VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='RutaArchivoPDF')
        ALTER TABLE dbo.Documento ADD RutaArchivoPDF VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='RutaArchivoPDF_Firmado')
        ALTER TABLE dbo.Documento ADD RutaArchivoPDF_Firmado VARCHAR(500) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='AreaCategoria')
        ALTER TABLE dbo.Documento ADD AreaCategoria VARCHAR(150) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='Prioridad')
        ALTER TABLE dbo.Documento ADD Prioridad VARCHAR(10) NOT NULL CONSTRAINT df_Documento_Prioridad DEFAULT 'MEDIA';
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='FechaLimiteRevision')
        ALTER TABLE dbo.Documento ADD FechaLimiteRevision DATETIME NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='FechaLimiteAprobacion')
        ALTER TABLE dbo.Documento ADD FechaLimiteAprobacion DATETIME NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='IdArchivoPrincipal')
        ALTER TABLE dbo.Documento ADD IdArchivoPrincipal INT NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='NumeroRevisionActual')
        ALTER TABLE dbo.Documento ADD NumeroRevisionActual INT NOT NULL CONSTRAINT df_Documento_NroRev DEFAULT 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='TieneArchivo')
        ALTER TABLE dbo.Documento ADD TieneArchivo BIT NOT NULL CONSTRAINT df_Documento_TieneArchivo DEFAULT 0;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='IDUsuarioCreador')
        ALTER TABLE dbo.Documento ADD IDUsuarioCreador VARCHAR(15) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='IDUsuarioModificador')
        ALTER TABLE dbo.Documento ADD IDUsuarioModificador VARCHAR(15) NULL;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.Documento') AND name='FechaModificacion')
        ALTER TABLE dbo.Documento ADD FechaModificacion SMALLDATETIME NULL;
    PRINT 'Tabla Documento ya existe - columnas nuevas verificadas/agregadas.';
END
GO

-- ============================================================
-- 2.4  DocumentoParticipante
--   Revisores y firmantes asignados a cada documento.
--   OrdenSecuencial -> orden de firma (proceso secuencial).
--   EstadoParticipante -> FK a Maestro (ESTADO_PARTICIPANTE).
--   UNIQUE(IdDocumento, LoginUsuario): un usuario solo
--   puede participar una vez por documento.
-- ============================================================
IF OBJECT_ID('dbo.DocumentoParticipante', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocumentoParticipante (
        IdParticipante      INT          IDENTITY(1,1) NOT NULL,
        IdDocumento         INT                        NOT NULL,
        LoginUsuario        VARCHAR(50)                NOT NULL,
        CorreoInstitucional VARCHAR(150)               NOT NULL CONSTRAINT df_DocParticipante_Correo DEFAULT '',
        IdTipoParticipante  INT                        NOT NULL,
        IdRolFirmante       INT                        NULL,
        PlazoDias           INT                        NOT NULL CONSTRAINT df_DocParticipante_Plazo  DEFAULT 5,
        OrdenSecuencial     INT                        NULL,
        EstadoParticipante  INT                        NULL,
        FechaAsignacion     DATETIME                   NULL,
        Activo              BIT                        NOT NULL CONSTRAINT df_DocParticipante_Activo DEFAULT 1,
        CONSTRAINT pk_DocumentoParticipante       PRIMARY KEY CLUSTERED (IdParticipante),
        CONSTRAINT fk_DocParticipante_Documento   FOREIGN KEY (IdDocumento)        REFERENCES dbo.Documento(IdDocumento),
        CONSTRAINT fk_DocParticipante_TipoPartic  FOREIGN KEY (IdTipoParticipante) REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT uq_DocParticipante             UNIQUE (IdDocumento, LoginUsuario, IdTipoParticipante)
    );
    PRINT 'Tabla DocumentoParticipante creada.';
END
ELSE
BEGIN
    -- Agregar columnas que pueden no existir en versiones anteriores
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='CorreoInstitucional')
        ALTER TABLE dbo.DocumentoParticipante ADD CorreoInstitucional VARCHAR(150) NOT NULL CONSTRAINT df_DocParticipante_Correo DEFAULT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='IdRolFirmante')
        ALTER TABLE dbo.DocumentoParticipante ADD IdRolFirmante INT NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='PlazoDias')
        ALTER TABLE dbo.DocumentoParticipante ADD PlazoDias INT NOT NULL CONSTRAINT df_DocParticipante_Plazo DEFAULT 5;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='FechaAsignacion')
        ALTER TABLE dbo.DocumentoParticipante ADD FechaAsignacion DATETIME NULL;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='Activo')
        ALTER TABLE dbo.DocumentoParticipante ADD Activo BIT NOT NULL CONSTRAINT df_DocParticipante_Activo DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoParticipante') AND name='EstadoParticipante')
    BEGIN
        ALTER TABLE dbo.DocumentoParticipante ADD EstadoParticipante INT NULL;
        -- Usar EXEC para evitar el error de compilacion de batch al referenciar columna nueva
        EXEC('UPDATE dbo.DocumentoParticipante SET EstadoParticipante = (
                  SELECT TOP 1 IdMaestro FROM dbo.Maestro
                  WHERE Tipo = ''ESTADO_PARTICIPANTE'' AND Codigo = ''PEN'')
              WHERE EstadoParticipante IS NULL');
    END

    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.DocumentoParticipante') AND name = 'uq_DocParticipante')
        ALTER TABLE dbo.DocumentoParticipante
            ADD CONSTRAINT uq_DocParticipante UNIQUE (IdDocumento, LoginUsuario, IdTipoParticipante);

    PRINT 'Tabla DocumentoParticipante ya existe - columnas verificadas/agregadas.';
END
GO

-- ============================================================
-- 2.5  RevisionDetalle
--   Registra comentarios/observaciones de cada revision.
--   NumeroRevision tiene DEFAULT 1 porque el INSERT del C#
--   (RepositorioDocumentos.InsertarRevision) no la incluye
--   en la lista de columnas; el DEFAULT evita el error NOT NULL.
-- ============================================================
IF OBJECT_ID('dbo.RevisionDetalle', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RevisionDetalle (
        IdRevision       INT          IDENTITY(1,1) NOT NULL,
        IdParticipante   INT                        NOT NULL,
        Comentario       VARCHAR(1000)              NOT NULL,
        NumeroRevision   INT                        NOT NULL CONSTRAINT df_RevisionDetalle_NroRev   DEFAULT 1,
        EsObservacion    BIT                        NOT NULL CONSTRAINT df_RevisionDetalle_EsObs    DEFAULT 0,
        FechaRevision    DATETIME                   NOT NULL CONSTRAINT df_RevisionDetalle_Fecha    DEFAULT GETDATE(),
        -- Auditoria ET-003
        IDUsuarioCreador VARCHAR(15)                NULL,
        FechaCreacion    SMALLDATETIME              NOT NULL CONSTRAINT df_RevisionDetalle_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_RevisionDetalle              PRIMARY KEY CLUSTERED (IdRevision),
        CONSTRAINT fk_RevisionDetalle_Participante FOREIGN KEY (IdParticipante)
            REFERENCES dbo.DocumentoParticipante(IdParticipante)
    );
    PRINT 'Tabla RevisionDetalle creada.';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.RevisionDetalle') AND name='NumeroRevision')
        ALTER TABLE dbo.RevisionDetalle
            ADD NumeroRevision INT NOT NULL CONSTRAINT df_RevisionDetalle_NroRev DEFAULT 1;
    PRINT 'Tabla RevisionDetalle ya existe - columnas nuevas verificadas/agregadas.';
END
GO

-- ============================================================
-- 2.6  FirmaDetalle
--   Registro de cada firma digital aplicada al documento.
--   FirmaDigitalHash -> hash/token retornado por el
--   componente de firma (ReFirma / Firma Peru).
-- ============================================================
IF OBJECT_ID('dbo.FirmaDetalle', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FirmaDetalle (
        IdFirma          INT          IDENTITY(1,1) NOT NULL,
        IdParticipante   INT                        NOT NULL,
        IdEstadoFirma    INT                        NOT NULL,
        FirmaDigitalHash VARCHAR(500)               NULL,
        FechaFirma       DATETIME                   NULL,
        -- Auditoria ET-003
        IDUsuarioCreador VARCHAR(15)                NULL,
        FechaCreacion    SMALLDATETIME              NOT NULL CONSTRAINT df_FirmaDetalle_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_FirmaDetalle              PRIMARY KEY CLUSTERED (IdFirma),
        CONSTRAINT fk_FirmaDetalle_Participante FOREIGN KEY (IdParticipante) REFERENCES dbo.DocumentoParticipante(IdParticipante),
        CONSTRAINT fk_FirmaDetalle_EstadoFirma  FOREIGN KEY (IdEstadoFirma)  REFERENCES dbo.Maestro(IdMaestro)
    );
    PRINT 'Tabla FirmaDetalle creada.';
END
ELSE
    PRINT 'Tabla FirmaDetalle ya existe.';
GO

-- ============================================================
-- 2.7  HistorialDocumento
--   Trazabilidad completa de todos los cambios de estado
--   de un documento a lo largo de su ciclo de vida.
--   IdEstadoAnterior = NULL en el primer registro (creacion).
-- ============================================================
IF OBJECT_ID('dbo.HistorialDocumento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HistorialDocumento (
        IdHistorial        INT          IDENTITY(1,1) NOT NULL,
        IdDocumento        INT                        NOT NULL,
        IdEstadoAnterior   INT                        NULL,
        IdEstadoNuevo      INT                        NOT NULL,
        LoginUsuarioAccion VARCHAR(50)                NOT NULL,
        DetalleAccion      VARCHAR(1000)              NULL,
        FechaCambio        DATETIME                   NOT NULL CONSTRAINT df_HistorialDoc_Fecha     DEFAULT GETDATE(),
        -- Auditoria ET-003
        IDUsuarioCreador   VARCHAR(15)                NULL,
        FechaCreacion      SMALLDATETIME              NOT NULL CONSTRAINT df_HistorialDoc_FechaCrea DEFAULT GETDATE(),
        CONSTRAINT pk_HistorialDocumento          PRIMARY KEY CLUSTERED (IdHistorial),
        CONSTRAINT fk_HistorialDoc_Documento      FOREIGN KEY (IdDocumento)      REFERENCES dbo.Documento(IdDocumento),
        CONSTRAINT fk_HistorialDoc_EstadoAnterior FOREIGN KEY (IdEstadoAnterior) REFERENCES dbo.Maestro(IdMaestro),
        CONSTRAINT fk_HistorialDoc_EstadoNuevo    FOREIGN KEY (IdEstadoNuevo)    REFERENCES dbo.Maestro(IdMaestro)
    );
    PRINT 'Tabla HistorialDocumento creada.';
END
ELSE
    PRINT 'Tabla HistorialDocumento ya existe.';
GO

-- ============================================================
-- 2.7.1  DocumentoObservacionHistorial
--   Observaciones del revisor archivadas al enviar correccion
--   (antes de borrar RevisionDetalle). Permite ver subsanadas vs pendientes.
-- ============================================================
IF OBJECT_ID('dbo.DocumentoObservacionHistorial', 'U') IS NULL
BEGIN
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
    PRINT 'Tabla DocumentoObservacionHistorial creada.';
END
ELSE
    PRINT 'Tabla DocumentoObservacionHistorial ya existe.';
GO

-- ============================================================
-- 2.7.2  DocumentoObservacionMarcador
--   Marcadores de observacion anclados al PDF (pagina + coordenadas).
-- ============================================================
-- ============================================================
-- RECREAR TABLA FIR_DocumentoObsMarcador
-- SOLO DESARROLLO
-- ============================================================

CREATE TABLE dbo.FIR_DocumentoObsMarcador (
    IdMarcador           INT            IDENTITY(1,1) NOT NULL,
    IdDocumento          INT            NOT NULL,
    LoginUsuario         VARCHAR(15)    NOT NULL,

    TipoMarcador         VARCHAR(12)    NOT NULL
        CONSTRAINT df_DocObsMar_TipoMarcador DEFAULT 'pin',

    Pagina               INT            NOT NULL,
    PosX                 FLOAT          NOT NULL,
    PosY                 FLOAT          NOT NULL,

    Ancho                FLOAT          NULL,
    Alto                 FLOAT          NULL,

    TextoSeleccionado    NVARCHAR(500)  NULL,
    Comentario           NVARCHAR(1000) NOT NULL,

    EsBorrador           BIT            NOT NULL
        CONSTRAINT df_DocObsMar_EsBorrador DEFAULT 1,

    IDUsuarioCreador     VARCHAR(15)    NOT NULL
        CONSTRAINT df_DocObsMar_IDUsuarioCreador DEFAULT '',

    FechaCreacion        SMALLDATETIME  NOT NULL
        CONSTRAINT df_DocObsMar_FechaCreacion DEFAULT GETDATE(),

    IDUsuarioModificador VARCHAR(15)    NULL,

    FechaModificacion    SMALLDATETIME  NULL,

    CONSTRAINT pk_FIR_DocumentoObsMarcador
        PRIMARY KEY CLUSTERED (IdMarcador)
);
GO

-- ============================================================
-- 2.8  LogErrorSistema
--   Registro de excepciones no controladas de la aplicacion.
--   Capa -> Presentacion | Negocio | Datos | ServiciosExternos
-- ============================================================
IF OBJECT_ID('dbo.LogErrorSistema', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LogErrorSistema (
        IdLog             INT          IDENTITY(1,1) NOT NULL,
        Capa              VARCHAR(50)                NULL,
        MensajeError      VARCHAR(2000)              NOT NULL,
        DetalleStacktrace VARCHAR(MAX)               NULL,
        LoginUsuario      VARCHAR(50)                NULL,
        FechaError        DATETIME                   NOT NULL CONSTRAINT df_LogError_Fecha DEFAULT GETDATE(),
        CONSTRAINT pk_LogErrorSistema PRIMARY KEY CLUSTERED (IdLog)
    );
    PRINT 'Tabla LogErrorSistema creada.';
END
ELSE
    PRINT 'Tabla LogErrorSistema ya existe.';
GO

-- ============================================================
-- 3.  CATALOGO MAESTRO  (datos de configuracion del sistema)
-- ============================================================
PRINT '';
PRINT '--- Insertando catalogos Maestro ---';
GO

-- 3.1  Roles del Sistema
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('ROL_SISTEMA', 'ADM', 'Administrador', 1),
    ('ROL_SISTEMA', 'REG', 'Registrador',   2),
    ('ROL_SISTEMA', 'REV', 'Revisor',       3),
    ('ROL_SISTEMA', 'FIR', 'Firmante',      4);
    PRINT 'ROL_SISTEMA insertado.';
END
ELSE
    PRINT 'ROL_SISTEMA ya tiene datos.';
GO

-- 3.2  Estados del Documento
--   REG  -> recien registrado (inicial)
--   REV  -> en proceso de revision
--   OBS  -> observado por un revisor
--   PEN  -> pendiente de firma (revision completada)
--   FPAR -> firmado parcialmente
--   FCOM -> firmado completamente (estado final)
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_DOC')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('ESTADO_DOC', 'REG',  'Registrado',        1),
    ('ESTADO_DOC', 'REV',  'En Revision',        2),
    ('ESTADO_DOC', 'OBS',  'Observado',          3),
    ('ESTADO_DOC', 'PEN',  'Pendiente de Firma', 4),
    ('ESTADO_DOC', 'FPAR', 'Firma Parcial',      5),
    ('ESTADO_DOC', 'FCOM', 'Firmado Completo',   6);
    PRINT 'ESTADO_DOC insertado.';
END
ELSE
    PRINT 'ESTADO_DOC ya tiene datos.';
GO

-- 3.3  Tipos de Documento
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'TIPO_DOC')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('TIPO_DOC', 'MEM', 'Memorando',      1),
    ('TIPO_DOC', 'OFI', 'Oficio',         2),
    ('TIPO_DOC', 'RES', 'Resolucion',     3),
    ('TIPO_DOC', 'INF', 'Informe',        4),
    ('TIPO_DOC', 'ACT', 'Acta',           5),
    ('TIPO_DOC', 'CON', 'Contrato',       6),
    ('TIPO_DOC', 'DIR', 'Directiva',      7),
    ('TIPO_DOC', 'CIR', 'Circular',       8),
    ('TIPO_DOC', 'PLA', 'Plan',           9),
    ('TIPO_DOC', 'PRO', 'Procedimiento', 10);
    PRINT 'TIPO_DOC insertado.';
END
ELSE
    PRINT 'TIPO_DOC ya tiene datos.';
GO

-- 3.4  Estados de Firma
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_FIRMA')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('ESTADO_FIRMA', 'PEN',  'Pendiente de Firma', 1),
    ('ESTADO_FIRMA', 'FIR',  'Firmado',            2),
    ('ESTADO_FIRMA', 'FCOM', 'Firma Completa',     3),
    ('ESTADO_FIRMA', 'OBS',  'Observado',          4);
    PRINT 'ESTADO_FIRMA insertado.';
END
ELSE
    PRINT 'ESTADO_FIRMA ya tiene datos.';
GO

-- 3.5  Tipos de Participante
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'TIPO_PARTICIPANTE')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('TIPO_PARTICIPANTE', 'REV', 'Revisor',  1),
    ('TIPO_PARTICIPANTE', 'FIR', 'Firmante', 2);
    PRINT 'TIPO_PARTICIPANTE insertado.';
END
ELSE
    PRINT 'TIPO_PARTICIPANTE ya tiene datos.';
GO

-- 3.6  Estados del Participante
--   Refleja el estado individual de cada revisor/firmante
--   dentro de un documento especifico.
IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo = 'ESTADO_PARTICIPANTE')
BEGIN
    INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden) VALUES
    ('ESTADO_PARTICIPANTE', 'PEN', 'Pendiente',          1),
    ('ESTADO_PARTICIPANTE', 'REV', 'En Revision',        2),
    ('ESTADO_PARTICIPANTE', 'OBS', 'Observado',          3),
    ('ESTADO_PARTICIPANTE', 'FIR', 'Firmado',            4),
    ('ESTADO_PARTICIPANTE', 'REG', 'Revisado/Conforme',  5);
    PRINT 'ESTADO_PARTICIPANTE insertado.';
END
ELSE
BEGIN
    -- Agregar REG si falta (versiones anteriores no lo tenian)
    IF NOT EXISTS (SELECT 1 FROM dbo.Maestro WHERE Tipo='ESTADO_PARTICIPANTE' AND Codigo='REG')
        INSERT INTO dbo.Maestro (Tipo, Codigo, Descripcion, Orden)
        VALUES ('ESTADO_PARTICIPANTE', 'REG', 'Revisado/Conforme', 5);
    PRINT 'ESTADO_PARTICIPANTE ya tiene datos (REG verificado).';
END
GO

-- ============================================================
-- 4.  USUARIOS DEL SISTEMA
--   El login se realiza via DropDownList (sin contrasena).
--   Los SELECT usan JOIN a Maestro para obtener el IdMaestro
--   correcto independientemente del orden de insercion.
-- ============================================================
PRINT '';
PRINT '--- Insertando usuarios del sistema ---';
GO

IF NOT EXISTS (SELECT 1 FROM dbo.UsuarioSistema WHERE LoginUsuario = 'arivera')
    INSERT INTO dbo.UsuarioSistema (LoginUsuario, Password, IdRolSistema, Activo)
    SELECT 'arivera', NULL, IdMaestro, 1
    FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA' AND Codigo = 'ADM';

IF NOT EXISTS (SELECT 1 FROM dbo.UsuarioSistema WHERE LoginUsuario = 'avargas')
    INSERT INTO dbo.UsuarioSistema (LoginUsuario, Password, IdRolSistema, Activo)
    SELECT 'avargas', NULL, IdMaestro, 1
    FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA' AND Codigo = 'REG';

IF NOT EXISTS (SELECT 1 FROM dbo.UsuarioSistema WHERE LoginUsuario = 'wsalas')
    INSERT INTO dbo.UsuarioSistema (LoginUsuario, Password, IdRolSistema, Activo)
    SELECT 'wsalas', NULL, IdMaestro, 1
    FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA' AND Codigo = 'REV';

IF NOT EXISTS (SELECT 1 FROM dbo.UsuarioSistema WHERE LoginUsuario = 'dfernandez')
    INSERT INTO dbo.UsuarioSistema (LoginUsuario, Password, IdRolSistema, Activo)
    SELECT 'dfernandez', NULL, IdMaestro, 1
    FROM dbo.Maestro WHERE Tipo = 'ROL_SISTEMA' AND Codigo = 'FIR';

PRINT 'Usuarios del sistema verificados/insertados.';
GO

-- ============================================================
-- 5.  VISTA  VW_EmpleadosActivos
--   JOIN cross-database: FirmaDigital -> administracion.
--   Usada por RepositorioUsuariosRoles.ObtenerEmpleadosActivos()
--   para el DropDownList de la pantalla de Login (simulacion).
-- ============================================================
IF OBJECT_ID('dbo.VW_EmpleadosActivos', 'V') IS NOT NULL
    DROP VIEW dbo.VW_EmpleadosActivos;
IF OBJECT_ID('dbo.FIR_VW_EmpleadosActivos', 'V') IS NOT NULL
    DROP VIEW dbo.FIR_VW_EmpleadosActivos;
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
		uo.Descripcion AS NombreUnidad, -- Jalamos el nombre real del área
        uo.Abreviatura AS AreaSiglas,
		e.IDCargo,
        e.IDSede,
        e.IdRol
    FROM administracion.dbo.Empleado e
	LEFT JOIN administracion.dbo.UnidadOrganica uo ON e.IDUnidadOrganica = uo.IDUnidadOrganica
    WHERE e.ActivoAsist = 1;
GO
PRINT 'Vista FIR_VW_EmpleadosActivos creada/actualizada.';
GO
-- vista para listar unidades organicas 
IF OBJECT_ID('dbo.FIR_VW_UnidadesOrganicas', 'V') IS NOT NULL
    DROP VIEW dbo.FIR_VW_UnidadesOrganicas;
GO

CREATE OR ALTER VIEW dbo.FIR_VW_UnidadesOrganicas AS
SELECT 
    IDUnidadOrganica, 
    Descripcion, 
    Abreviatura
FROM [administracion].[dbo].[UnidadOrganica];
GO


-- ============================================================
-- POCEDIMIENTOS ALMACENADOS
-- 6.  STORED PROCEDURE  sp_InsertarParticipante
--   Inserta un participante (revisor o firmante) en un
--   documento, asignandole automaticamente el estado PEN
--   desde el catalogo Maestro (ESTADO_PARTICIPANTE).
--
--   Parametros:
--     @IdDocumento        -> documento al que se asigna
--     @LoginUsuario       -> login del participante
--     @IdTipoParticipante -> IdMaestro de TIPO_PARTICIPANTE
--                            (REV o FIR)
-- ============================================================
IF OBJECT_ID('dbo.sp_InsertarParticipante', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_InsertarParticipante;
GO

CREATE PROCEDURE dbo.FIR_I_InsertarParticipante
    @IdDocumento        INT,
    @LoginUsuario       VARCHAR(50),
    @IdTipoParticipante INT
AS
BEGIN
    SET NOCOUNT OFF;

    DECLARE @EstadoPen INT;

    SELECT @EstadoPen = IdMaestro
    FROM dbo.Maestro
    WHERE Tipo = 'ESTADO_PARTICIPANTE' AND Codigo = 'PEN';

    IF @EstadoPen IS NULL
    BEGIN
        RAISERROR('No existe estado PEN en ESTADO_PARTICIPANTE dentro de Maestro.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.DocumentoParticipante
        (IdDocumento, LoginUsuario, IdTipoParticipante, EstadoParticipante)
    VALUES
        (@IdDocumento, @LoginUsuario, @IdTipoParticipante, @EstadoPen);
END
GO

PRINT 'Procedimiento FIR_I_InsertarParticipante creado/actualizado.';
GO

-- ============================================================
-- 7.  CONFIGURACION DE DATABASE MAIL (SMTP)
--   Necesario para que GEN_X_EnviarMail y los SP de
--   notificacion puedan enviar correos via SQL Server.
--
--   ANTES DE EJECUTAR:
--     - Cambia @email_address y @username por tu correo Gmail
--     - Cambia @password por la Contrasena de Aplicacion Gmail
--       (Panel Google -> Seguridad -> Verificacion en 2 pasos
--        -> Contrasenas de aplicacion -> generar una nueva)
--     - El perfil debe llamarse 'Administrador SQL' (ya usado
--       en GEN_X_EnviarMail con ese nombre fijo).
-- ============================================================
USE msdb;
GO

-- 7.1  Habilitar Database Mail XPs en el servidor
IF NOT EXISTS (
    SELECT 1 FROM sys.configurations
    WHERE name = 'Database Mail XPs' AND value_in_use = 1)
BEGIN
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE WITH OVERRIDE;
    EXEC sp_configure 'Database Mail XPs', 1;
    RECONFIGURE WITH OVERRIDE;
    PRINT 'Database Mail XPs habilitado.';
END
ELSE
    PRINT 'Database Mail XPs ya estaba habilitado.';
GO

-- 7.2  Cuenta SMTP
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysmail_account WHERE name = 'ZofraMailAccount')
BEGIN
    EXEC msdb.dbo.sysmail_add_account_sp
        @account_name    = 'ZofraMailAccount',
        @description     = 'Cuenta SMTP SIGEFIDD-ZOFRA',
        @email_address   = 'billang48004@gmail.com',
        @display_name    = 'SIGEFIDD-ZOFRA Notificaciones',
        @mailserver_name = 'smtp.gmail.com',
        @port            = 587,
        @enable_ssl      = 1,
        @username        = 'billang48004@gmail.com',
        @password        = 'tlcosxwnmnqootru';
    PRINT 'Cuenta ZofraMailAccount creada.';
END
ELSE
    PRINT 'Cuenta ZofraMailAccount ya existe.';
GO

-- 7.3  Perfil de correo  (nombre fijo: 'Administrador SQL')
IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysmail_profile WHERE name = 'Administrador SQL')
BEGIN
    EXEC msdb.dbo.sysmail_add_profile_sp
        @profile_name = 'Administrador SQL',
        @description  = 'Perfil de correo institucional ZOFRATACNA';
    PRINT 'Perfil Administrador SQL creado.';
END
ELSE
    PRINT 'Perfil Administrador SQL ya existe.';
GO

-- 7.4  Asociar cuenta al perfil
IF NOT EXISTS (
    SELECT 1 FROM msdb.dbo.sysmail_profileaccount pa
    INNER JOIN msdb.dbo.sysmail_profile  p ON pa.profile_id  = p.profile_id
    INNER JOIN msdb.dbo.sysmail_account  a ON pa.account_id  = a.account_id
    WHERE p.name = 'Administrador SQL' AND a.name = 'ZofraMailAccount')
BEGIN
    EXEC msdb.dbo.sysmail_add_profileaccount_sp
        @profile_name    = 'Administrador SQL',
        @account_name    = 'ZofraMailAccount',
        @sequence_number = 1;
    PRINT 'Cuenta asociada al perfil.';
END
ELSE
    PRINT 'Cuenta ya estaba asociada al perfil.';
GO

USE FirmaDigital;
GO

-- Creamos el procedimiento de estructura y permisos para el correo
IF OBJECT_ID('dbo.GEN_X_EnviarMail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GEN_X_EnviarMail;
GO
CREATE PROCEDURE [dbo].[GEN_X_EnviarMail] 
    @Para nVarChar(100), 
    @Asunto nVarChar(250), 
    @Mensaje nVarChar(4000),
    @Adjunto nVarChar(MAX) = NULL -- Por si algún día quieres enviar un PDF
AS 
BEGIN
    SET NOCOUNT OFF;

    EXEC msdb.dbo.sp_send_dbmail 
        @profile_name = 'Administrador SQL', -- El perfil que acabamos de crear
        @recipients = @Para, 
        @subject = @Asunto, 
        @body = @Mensaje,
        @body_format = 'HTML', -- Esto permite usar negritas o tablas en el correo
        @file_attachments = @Adjunto;
END
GO

-- CORREO PARA AVISAR SOBRE REVISION DE UN DOCUMENTO
CREATE OR ALTER PROCEDURE dbo.FIR_X_NotifAsigRev
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;

    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @TipoDoc VARCHAR(150), 
            @AreaDoc VARCHAR(150), @FechaReg VARCHAR(20);
    DECLARE @EmailDestino VARCHAR(150), @NombreRevisor VARCHAR(250), 
            @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250),
            @DiasPlazo INT; -- Nueva variable para el plazo dinámico

    -- 1. Obtener datos reales del documento (Incluyendo el nombre del Área)
    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @TipoDoc = m.Descripcion,
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida'), -- JOIN con UnidadOrganica
        @FechaReg = CONVERT(VARCHAR, d.FechaCreacion, 103)
    FROM dbo.Documento d
    INNER JOIN dbo.Maestro m ON d.IdTipoDocumento = m.IdMaestro
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    -- 2. Cursor: Jalamos el Email, Nombre y su Plazo específico
    DECLARE curRevisores CURSOR FOR
    SELECT v.Email, v.NombreCompleto, dp.PlazoDias
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento
      AND m.Codigo = 'REV'; -- SOLO enviamos a revisores en esta etapa

    OPEN curRevisores;
    FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @DiasPlazo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- 3. Armamos el diseño profesional (CONCAT por bloques para evitar errores de longitud)
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

        -- 4. Preparamos el Asunto fuera del EXEC para evitar el error de sintaxis
        SET @AsuntoFinal = CONCAT(N'Asignación de Revisión - ', @CodigoDoc);

        -- 5. Enviar el correo
        EXEC dbo.GEN_X_EnviarMail 
            @Para = @EmailDestino, 
            @Asunto = @AsuntoFinal, 
            @Mensaje = @Cuerpo;

        FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @DiasPlazo;
    END

    CLOSE curRevisores;
    DEALLOCATE curRevisores;
END
GO

-- CORREO PARA AVISAR SOBRE DOCUMENTO OBSERVADO
CREATE OR ALTER PROCEDURE dbo.FIR_X_NotifObsDoc
    @IdDocumento INT,
    @LoginRevisorQueObserva VARCHAR(50), -- Se requiere para saber quién observó
    @ComentarioObservacion VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT OFF;

    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @AreaDoc VARCHAR(150), @NombreObservador VARCHAR(250);
    DECLARE @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250), @EmailDestino VARCHAR(150);

    -- 1. Obtener datos generales del documento y nombre del revisor que observa
    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida')
    FROM dbo.Documento d
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    SELECT @NombreObservador = NombreCompleto 
    FROM dbo.FIR_VW_EmpleadosActivos 
    WHERE LoginUsuario = @LoginRevisorQueObserva;

    -- 2. Cursor para enviar el correo al REGISTRADOR y a TODOS LOS REVISORES
    -- El UNION asegura que no se repitan correos si el registrador también es revisor
    DECLARE curNotificar CURSOR FOR
    SELECT DISTINCT v.Email 
    FROM dbo.Documento d 
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON d.LoginUsuarioRegistrador = v.LoginUsuario 
    WHERE d.IdDocumento = @IdDocumento
    UNION
    SELECT v.Email 
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'REV'; -- Solo revisores

    OPEN curNotificar;
    FETCH NEXT FROM curNotificar INTO @EmailDestino;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construcción de la plantilla profesional ZOFRATACNA
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            -- Header Azul Marino
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">',
            N'<table width="100%"><tr><td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>',
            N'<td style="text-align: center; opacity: 0.8;">Gestión de Firma Digital</td>',
            N'<td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td></tr></table></div>',
            -- Banner de Alerta Roja
            N'<div style="background-color: #e53e3e; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">⚠️ DOCUMENTO OBSERVADO</div>',
            -- Cuerpo del Mensaje
            N'<div style="padding: 30px; color: #444; line-height: 1.5;">',
            N'<p style="margin-top: 0;">Se informa que el revisor <strong>', @NombreObservador, N'</strong> ha realizado una observación técnica al documento.</p>',
            -- Cuadro de Comentario
            N'<div style="background-color: #fff5f5; border-left: 4px solid #e53e3e; padding: 15px; margin: 20px 0;">',
            N'<h4 style="color: #c53030; margin: 0 0 5px 0; font-size: 11px; text-transform: uppercase;">Detalle de la observación:</h4>',
            N'<p style="font-style: italic; margin: 0; color: #2d3748;">"', @ComentarioObservacion, N'"</p></div>',
            -- Tabla de Datos del Documento
            N'<table style="width: 100%; font-size: 13px; border-collapse: collapse; color: #2d3748; margin-bottom: 20px;">',
            N'<tr><td style="color: #4a5568; width: 35%; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Documento:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;"><strong>', @AsuntoDoc, N'</strong></td></tr>',
            N'<tr><td style="color: #4a5568; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Código:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;">', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 6px 0; border-bottom: 1px solid #edf2f7;">Área:</td><td style="padding: 6px 0; border-bottom: 1px solid #edf2f7;">', @AreaDoc, N'</td></tr></table>',
            -- Botón de Acción
            N'<div style="text-align: center; margin-top: 30px;">',
            N'<a href="https://zofratacna.com.pe" style="background-color: #e53e3e; color: white; padding: 12px 35px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 13px; display: inline-block;">Ver Observación en el Sistema</a></div></div>',
            -- Footer
            N'<div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: center; border-top: 1px solid #edf2f7;">Este es un mensaje automático generado por SIGEFIDD-ZOFRA. Por favor no responder.</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'OBSERVACIÓN: ', @CodigoDoc, N' - ', @AsuntoDoc);
        
        -- Envío de correo individual
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;

        FETCH NEXT FROM curNotificar INTO @EmailDestino;
    END

    CLOSE curNotificar;
    DEALLOCATE curNotificar;
END
GO


-- -- CORREO PARA AVISAR QUE SE LEVANTO LA OBSERVACION Y ESTA DE NUEVO EN REVISION
CREATE OR ALTER PROCEDURE dbo.FIR_X_NotifDocCorreg
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;

    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @NombreRegistrador VARCHAR(250), 
            @FechaCorreccion VARCHAR(20), @RevisionActual INT;
    DECLARE @EmailDestino VARCHAR(150), @NombreRevisor VARCHAR(250), 
            @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250),
            @PlazoTexto VARCHAR(100), @ListaObservaciones NVARCHAR(MAX);

    -- 1. Obtener datos básicos del documento y el nombre del Registrador
    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @RevisionActual = d.NumeroRevisionActual,
        @NombreRegistrador = v.NombreCompleto,
        @FechaCorreccion = CONVERT(VARCHAR, GETDATE(), 103) 
    FROM dbo.Documento d
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON d.LoginUsuarioRegistrador = v.LoginUsuario
    WHERE d.IdDocumento = @IdDocumento;

    -- 2. Construir el bloque de observaciones previas
    SET @ListaObservaciones = '';
    SELECT @ListaObservaciones = @ListaObservaciones + 
        N'<div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 10px; margin-bottom: 10px; font-size: 13px;">' +
        N'<strong style="color: #cb4335;">' + v.NombreCompleto + N' — ' + CONVERT(VARCHAR, rd.FechaRevision, 103) + N'</strong><br>' +
        N'<span style="color: #555;">' + rd.Comentario + N'</span>' +
        N'</div>'
    FROM dbo.RevisionDetalle rd
    INNER JOIN dbo.DocumentoParticipante dp ON rd.IdParticipante = dp.IdParticipante
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    WHERE dp.IdDocumento = @IdDocumento AND rd.EsObservacion = 1
    AND rd.NumeroRevision = (@RevisionActual - 1); 

    -- 3. Cursor corregido (se eliminó la palabra extra 'CORREGIDOS')
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

        EXEC [dbo].[GEN_X_EnviarMail] 
            @Para = @EmailDestino, 
            @Asunto = @AsuntoFinal, 
            @Mensaje = @Cuerpo;

        FETCH NEXT FROM curRevisores INTO @EmailDestino, @NombreRevisor, @PlazoTexto;
    END

    CLOSE curRevisores;
    DEALLOCATE curRevisores;
END
GO

-- CORREO PARA AVISAR SOBRE DOCUMENTO PENDIENTE DE FIRMA
CREATE OR ALTER PROCEDURE dbo.FIR_X_NotifAsigFirma
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT OFF;

    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @AreaDoc VARCHAR(150);
    DECLARE @EmailDestino VARCHAR(150), @NombreFirmante VARCHAR(250), @Orden INT;
    DECLARE @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250);

    -- 1. Obtener datos generales del documento
    SELECT 
        @AsuntoDoc = d.Asunto, 
        @CodigoDoc = d.CodigoDocumento, 
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida')
    FROM dbo.Documento d
    LEFT JOIN administracion.dbo.UnidadOrganica uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    -- 2. Cursor para notificar a cada firmante con su ORDEN específico
    DECLARE curFirmantes CURSOR FOR
    SELECT v.Email, v.NombreCompleto, dp.OrdenSecuencial 
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento 
      AND m.Codigo = 'FIR' -- Solo a los que tienen rol de Firmante
    ORDER BY dp.OrdenSecuencial; -- Los procesamos en orden

    OPEN curFirmantes;
    FETCH NEXT FROM curFirmantes INTO @EmailDestino, @NombreFirmante, @Orden;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Construcción del cuerpo personalizado con el ROL y ORDEN
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">',
            -- Header ZOFRATACNA
            N'<div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">',
            N'<table width="100%"><tr><td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>',
            N'<td style="text-align: right; opacity: 0.8;">Módulo de Firma Digital</td></tr></table></div>',
            -- Título dinámico
            N'<div style="background-color: #2c5282; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">Asignación de Firma Digital - Orden N° ', @Orden, N'</div>',
            -- Contenido
            N'<div style="padding: 30px; color: #444; line-height: 1.5;">',
            N'<p style="margin-top: 0;">Estimado(a) <strong>', @NombreFirmante, N'</strong>,</p>',
            N'<p style="font-size: 14px;">Se le informa que el proceso de revisión ha concluido satisfactoriamente. Usted ha sido asignado como <strong>Firmante N° ', @Orden, N'</strong> para el siguiente documento:</p>',
            -- Detalles del documento
            N'<div style="background-color: #f7fafc; border: 1px solid #edf2f7; border-radius: 6px; padding: 20px; margin: 20px 0;">',
            N'<table style="width: 100%; font-size: 13px; color: #2d3748;">',
            N'<tr><td style="color: #4a5568; width: 35%; padding: 4px 0;">Asunto:</td><td><strong>', @AsuntoDoc, N'</strong></td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Código:</td><td>', @CodigoDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Origen:</td><td>', @AreaDoc, N'</td></tr>',
            N'<tr><td style="color: #4a5568; padding: 4px 0;">Su Posición:</td><td><span style="background-color: #bee3f8; color: #2c5282; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Prioridad de Firma ', @Orden, N'</span></td></tr></table></div>',
            -- Botón
            N'<div style="text-align: center;"><a href="https://zofratacna.com.pe" style="background-color: #2b6cb0; color: white; padding: 12px 40px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">Ingresar para Firmar</a></div></div>',
            -- Footer
            N'<div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: center; border-top: 1px solid #edf2f7;">Este es un mensaje automático de SIGEFIDD-ZOFRA.</div></div>'
        );

        SET @AsuntoFinal = CONCAT(N'PENDIENTE DE FIRMA (N° ', @Orden, N'): ', @CodigoDoc);

        -- Enviar correo individual con su posición
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;

        FETCH NEXT FROM curFirmantes INTO @EmailDestino, @NombreFirmante, @Orden;
    END

    CLOSE curFirmantes;
    DEALLOCATE curFirmantes;
END
GO


-- ============================================================
-- PARTE 3: BASE DE DATOS  FirmaDigital_Files
--   Repositorio de archivos PDF.
--   Los PDFs se almacenan en VARBINARY(MAX) para mantener
--   todo dentro del servidor SQL sin dependencia del
--   sistema de archivos del servidor web.
--   IdDocumento no tiene FK fisica (BD separada) pero
--   debe corresponder a FirmaDigital.dbo.Documento.IdDocumento.
-- ============================================================
PRINT '';
PRINT '--- PARTE 3: FirmaDigital_Files ---';
GO


IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FirmaDigital_Files')
BEGIN
    CREATE DATABASE FirmaDigital_Files;
    PRINT 'BD FirmaDigital_Files creada.';
END
ELSE
    PRINT 'BD FirmaDigital_Files ya existe. Continuando...';
GO

USE FirmaDigital_Files;
GO

-- ------------------------------------------------------------
-- Tabla: dbo.DocumentoAdjunto
--   Almacena el contenido binario de los PDFs.
--   EsVersionFinal = 1  ->  PDF con firma aplicada (final).
--   EsEliminado    = 1  ->  borrado logico (soft delete).
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.DocumentoAdjunto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocumentoAdjunto (
        IdAdjunto           INT           IDENTITY(1,1) NOT NULL,
        IdDocumento         INT                         NOT NULL,
        ContenidoPDF        VARBINARY(MAX)              NOT NULL,
        NombreArchivo       VARCHAR(255)                NOT NULL,
        TipoMime            VARCHAR(100)                NOT NULL CONSTRAINT df_DocAdjunto_Mime    DEFAULT 'application/pdf',
        TamanioBytes        INT                         NULL,
        EsVersionFinal      BIT                         NOT NULL CONSTRAINT df_DocAdjunto_EsVF    DEFAULT 0,
        -- Auditoria
        UsuarioCreacion     VARCHAR(50)                 NOT NULL,
        FechaCreacion       DATETIME                    NOT NULL CONSTRAINT df_DocAdjunto_FechaCrea DEFAULT GETDATE(),
        UsuarioModificacion VARCHAR(50)                 NULL,
        FechaModificacion   DATETIME                    NULL,
        UsuarioEliminacion  VARCHAR(50)                 NULL,
        FechaEliminacion    DATETIME                    NULL,
        EsEliminado         BIT                         NOT NULL CONSTRAINT df_DocAdjunto_EsElim  DEFAULT 0,
        -- Version vigente vs archivada (reemplazo por correccion del registrador, auditoria)
        EsSuperado          BIT                         NOT NULL CONSTRAINT df_DocAdjunto_EsSuperado DEFAULT 0,
        FechaSuperacion     DATETIME                    NULL,
        LoginSuperacion     VARCHAR(50)                 NULL,
        MotivoSuperacion    VARCHAR(300)                NULL,
        CONSTRAINT pk_DocumentoAdjunto PRIMARY KEY CLUSTERED (IdAdjunto)
    );
    PRINT 'Tabla FirmaDigital_Files.dbo.DocumentoAdjunto creada.';
END
ELSE
    PRINT 'Tabla FirmaDigital_Files.dbo.DocumentoAdjunto ya existe.';
GO

USE FirmaDigital_Files;
GO


IF OBJECT_ID('dbo.DocumentoBloqueoEdicion', 'U') IS NOT NULL AND OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NULL
    EXEC sp_rename 'dbo.DocumentoBloqueoEdicion', 'FIR_DocumentoBloqueoEdicion';
GO

IF OBJECT_ID('dbo.FIR_DocumentoBloqueoEdicion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.FIR_DocumentoBloqueoEdicion (
        IdBloqueo             INT IDENTITY(1,1)          NOT NULL,
        IdDocumento           INT                        NOT NULL,
        TipoBloqueo           VARCHAR(20)                NOT NULL, -- REG_EDIT / REV_EDIT
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

    PRINT 'Tabla FIR_DocumentoBloqueoEdicion creada.';
END
ELSE
BEGIN
    PRINT 'Tabla FIR_DocumentoBloqueoEdicion ya existe.';
END
GO

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
PRINT '';
PRINT '============================================================';
PRINT ' VERIFICACION FINAL';
PRINT '============================================================';
GO

USE administracion;
GO
PRINT '--- administracion.dbo.Empleado ---';
SELECT IDEmpleado, CodigoPersonal, Apellido + ', ' + Nombre AS NombreCompleto,
       LoginUsuario, Email, ActivoAsist
FROM dbo.Empleado
ORDER BY IDEmpleado;
GO

USE FirmaDigital;
GO
PRINT '--- FirmaDigital: tablas ---';
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

PRINT '--- FirmaDigital: catalogo Maestro ---';
SELECT Tipo, Codigo, Descripcion, Orden
FROM dbo.Maestro
ORDER BY Tipo, Orden;

PRINT '--- FirmaDigital: vistas ---';
SELECT TABLE_NAME AS Vista
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;

PRINT '--- FirmaDigital: procedimientos ---';
SELECT ROUTINE_NAME AS Procedimiento
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
GO

USE FirmaDigital_Files;
GO
PRINT '--- FirmaDigital_Files: tablas ---';
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

USE master;
GO
PRINT '';
PRINT '============================================================';
PRINT ' INSTALACION COMPLETADA EXITOSAMENTE';
PRINT ' Bases de datos listas:';
PRINT '   - administracion        (empleados institucionales)';
PRINT '   - FirmaDigital          (core SIGEFIDD-ZOFRA)';
PRINT '   - FirmaDigital_Files    (repositorio de PDFs)';
PRINT '============================================================';
GO




-- ============================================================
-- PLANTILLAS DE CORREOS (ejemplos / pruebas manuales)
-- NOTA: Comentado para evitar envio de correos en cada ejecucion.
--       Para probar, descomentar manualmente y ejecutar por separado.
-- ============================================================
/*
USE FirmaDigital;
GO
-- Cambiamos @Cuerpo HTML por @Cuerpo NVARCHAR(MAX)
--  [ACCIÓN REQUERIDA] Documento pendiente de firma
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #ddd; margin: auto;">
    
    <!-- Encabezado Azul -->
    <div style="background-color: #1a335d; color: white; padding: 20px;">
        <span style="font-weight: bold; font-size: 18px;">ZOFRATACNA</span>
        <span style="font-size: 12px; opacity: 0.8; float: right;">Sistema de Firmado Digital</span>
    </div>

    <!-- Barra Roja de Alerta -->
    <div style="background-color: #c00000; color: white; padding: 10px; font-weight: bold; font-size: 14px; text-align: center;">
        ACCIÓN URGENTE REQUERIDA — FIRMA DIGITAL PENDIENTE
    </div>

    <!-- Cuerpo del mensaje -->
    <div style="padding: 20px; color: #333;">
        <p>Estimado(a),<br><strong>Juan Carlos Pérez Mamani</strong></p>
        <p>Se le notifica que tiene un documento <b>pendiente de firma digital</b> en el Sistema de Firmado de Documentos de ZOFRATACNA.</p>

        <!-- Cuadro de Detalle -->
        <div style="border: 1px solid #ffccbc; background-color: #fffbf0; border-radius: 8px; padding: 15px; margin-top: 20px;">
            <h4 style="color: #bf360c; margin-top: 0;">DETALLE DEL DOCUMENTO</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                <tr><td style="color: #e67e22; width: 40%; padding: 5px 0;">Asunto</td><td><b>Resolución de Gerencia N° 045-2025-GG</b></td></tr>
                <tr><td style="color: #e67e22; padding: 5px 0;">Tipo</td><td>Resolución</td></tr>
                <tr><td style="color: #e67e22; padding: 5px 0;">Área responsable</td><td>Gerencia General</td></tr>
                <tr><td style="color: #e67e22; padding: 5px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #e67e22; padding: 5px 0;">Su turno de firma</td><td>2° firmante de 3</td></tr>
                <tr><td style="color: #e67e22; padding: 5px 0;">Plazo máximo</td><td style="color: #c00000;"><b>Vence: 29 Abr 2026 (2 días)</b></td></tr>
            </table>
        </div>

        <!-- Botón -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 15px 25px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block;">
                Ir al sistema y firmar ahora
            </a>
        </div>
    </div>

    <!-- Pie de página -->
    <div style="background-color: #f9f9f9; padding: 15px; font-size: 11px; color: #888; text-align: center; border-top: 1px solid #eee;">
        Este mensaje fue generado automáticamente. No responda a este correo.<br>
        ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Acción Requerida: Documento pendiente de firma', 
    @Mensaje = @Cuerpo;



GO
-- Correo 2 — Revisión asignada
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Segoe UI, Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">
    
    <!-- Encabezado Azul Institucional -->
    <div style="background-color: #1a335d; color: white; padding: 15px 20px; font-size: 13px;">
        <table width="100%">
            <tr>
                <td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold;">ZOFRATACNA</span></td>
                <td style="text-align: center; opacity: 0.8;">Sistema de Firmado Digital</td>
                <td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td>
            </tr>
        </table>
    </div>

    <!-- Barra de Título de Documento -->
    <div style="background-color: #2b6cb0; color: white; padding: 10px 20px; font-size: 14px; font-weight: 500;">
        Documento asignado para revisión
    </div>

    <div style="padding: 30px; color: #444; line-height: 1.5;">
        <p style="margin-top: 0;">Estimado(a),<br>
        <strong style="font-size: 18px; color: #1a202c;">María Elena Torres Condori</strong></p>
        
        <p style="font-size: 14px;">Se le ha asignado un documento para revisión en el Sistema de Firmado Digital de ZOFRATACNA. La revisión puede realizarse de forma simultánea con los demás revisores designados.</p>

        <!-- Cuadro de Detalle Azul Claro -->
        <div style="background-color: #ebf4ff; border-radius: 4px; padding: 20px; margin: 20px 0;">
            <h4 style="color: #2c5282; margin: 0 0 15px 0; font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Detalle del documento</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse; color: #2d3748;">
                <tr><td style="color: #4a5568; width: 35%; padding: 4px 0;">Asunto</td><td><strong>Resolución de Gerencia N° 045-2025-GG</strong></td></tr>
                <tr><td style="color: #4a5568; padding: 4px 0;">Tipo</td><td>Resolución</td></tr>
                <tr><td style="color: #4a5568; padding: 4px 0;">Área responsable</td><td>Gerencia General</td></tr>
                <tr><td style="color: #4a5568; padding: 4px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #4a5568; padding: 4px 0;">Fecha de registro</td><td>27/04/2026</td></tr>
                <tr><td style="color: #4a5568; padding: 4px 0;">Plazo para revisar</td><td>
                    <span style="background-color: #bee3f8; color: #2c5282; padding: 2px 8px; border-radius: 12px; font-size: 11px;">Hasta 01/05/2026 (5 días)</span>
                </td></tr>
            </table>
        </div>

        <!-- Etiquetas / Pills -->
        <div style="margin-bottom: 25px;">
            <span style="background-color: #e2e8f0; color: #4a5568; padding: 5px 12px; border-radius: 15px; font-size: 12px; margin-right: 10px;">● 3 revisores asignados</span>
            <span style="background-color: #f6fedb; color: #71804b; padding: 5px 12px; border-radius: 15px; font-size: 12px; border: 1px solid #d9e7b8;">● Revisión simultánea</span>
        </div>

        <!-- Cuadro Informativo Gris -->
        <div style="background-color: #f7fafc; border: 1px solid #edf2f7; border-radius: 8px; padding: 15px; font-size: 12px; color: #4a5568; display: table;">
            <div style="display: table-cell; vertical-align: top; padding-right: 10px; font-size: 18px;">ⓘ</div>
            <div style="display: table-cell;">Podrá ingresar al sistema para visualizar el documento, registrar observaciones si detecta correcciones necesarias, o registrar comentarios de conformidad (ej. "CONFORME").</div>
        </div>

        <!-- Botón Central -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 40px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 15px; display: inline-block;">
                Revisar documento ahora
            </a>
            <p style="font-size: 11px; color: #a0aec0; margin-top: 15px;">O ingrese desde: <strong>firma.zofratacna.com.pe</strong></p>
        </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: left; border-top: 1px solid #edf2f7;">
        <table width="100%">
            <tr>
                <td>Mensaje generado automáticamente — no responda este correo<br>ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</td>
                <td style="text-align: right; vertical-align: bottom;">27/04/2026 — 08:00 hrs</td>
            </tr>
        </table>
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Documento asignado para revisión - RGG-045-2025', 
    @Mensaje = @Cuerpo;


GO
-- Correo 3 — Documento corregido, nueva revisión
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">
    
    <!-- Encabezado Azul -->
    <div style="background-color: #1a335d; color: white; padding: 15px 20px;">
        <table width="100%">
            <tr>
                <td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 14px;">ZOFRATACNA</span></td>
                <td style="text-align: center; font-size: 12px; opacity: 0.8;">Sistema de Firmado Digital</td>
                <td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td>
            </tr>
        </table>
    </div>

    <!-- Barra Naranja de Alerta -->
    <div style="background-color: #d68910; color: white; padding: 10px 20px; font-weight: bold; font-size: 13px;">
        Documento corregido — se reinicia la revisión
    </div>

    <div style="padding: 25px; color: #333;">
        <p style="margin-top: 0; font-size: 13px;">Estimado(a),<br>
        <strong style="font-size: 16px;">María Elena Torres Condori</strong></p>
        
        <p style="font-size: 14px; line-height: 1.5;">El documento que fue marcado como <b>Observado</b> ha sido corregido por el registrador responsable y ha sido enviado nuevamente a revisión. Se requiere que realice una nueva evaluación del documento corregido.</p>

        <!-- Cuadro de Detalle Naranja Suave -->
        <div style="background-color: #fef5e7; border-radius: 4px; padding: 15px; margin: 20px 0;">
            <h4 style="color: #a04000; margin: 0 0 10px 0; font-size: 12px; text-transform: uppercase;">DETALLE DEL DOCUMENTO</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                <tr><td style="color: #d68910; width: 35%; padding: 3px 0;">Asunto</td><td><b>Resolución de Gerencia N° 045-2025-GG</b></td></tr>
                <tr><td style="color: #d68910; padding: 3px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #d68910; padding: 3px 0;">Vuelta de revisión</td><td>
                    <span style="background-color: #f8c471; color: #784212; padding: 1px 8px; border-radius: 10px; font-size: 11px;">2da revisión</span>
                </td></tr>
                <tr><td style="color: #d68910; padding: 3px 0;">Corregido por</td><td>Luis Mamani Flores (Registrador)</td></tr>
                <tr><td style="color: #d68910; padding: 3px 0;">Fecha de corrección</td><td>29/04/2026</td></tr>
                <tr><td style="color: #d68910; padding: 3px 0;">Nuevo plazo</td><td>
                    <span style="background-color: #f5c061; padding: 1px 8px; border-radius: 10px; font-size: 11px;">Hasta 03/05/2026 (5 días)</span>
                </td></tr>
            </table>
        </div>

        <!-- Sección de Observaciones -->
        <h4 style="color: #555; font-size: 12px; border-bottom: 1px solid #eee; padding-bottom: 5px;">OBSERVACIONES REGISTRADAS EN LA REVISIÓN ANTERIOR</h4>
        
        <!-- Observación 1 -->
        <div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 10px; margin-bottom: 10px; font-size: 13px;">
            <strong style="color: #cb4335;">María Elena Torres — 28/04/2026</strong><br>
            <span style="color: #555;">El numeral 3.2 del documento presenta inconsistencias con el procedimiento vigente PR-021. Se debe revisar la referencia normativa.</span>
        </div>

        <!-- Observación 2 -->
        <div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 10px; margin-bottom: 20px; font-size: 13px;">
            <strong style="color: #cb4335;">Carlos Ríos Quispe — 28/04/2026</strong><br>
            <span style="color: #555;">La tabla de responsabilidades (Anexo A) no refleja la estructura organizacional actualizada según el organigrama 2025.</span>
        </div>

        <!-- Botón -->
        <div style="text-align: center; margin-top: 20px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 14px; display: inline-block;">
                Revisar documento corregido
            </a>
            <p style="font-size: 11px; color: #999; margin-top: 10px;">O ingrese desde: firma.zofratacna.com.pe</p>
        </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #f9f9f9; padding: 15px 20px; font-size: 10px; color: #999; border-top: 1px solid #eee;">
        <table width="100%">
            <tr>
                <td>Mensaje generado automáticamente — no responda este correo<br>ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</td>
                <td style="text-align: right; vertical-align: bottom;">29/04/2026 — 09:30 hrs</td>
            </tr>
        </table>
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Documento corregido — RGG-045-2025', 
    @Mensaje = @Cuerpo;



GO
-- Correo 4 — Aprobado para firma
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">
    
    <!-- Encabezado Azul -->
    <div style="background-color: #1a335d; color: white; padding: 15px 20px;">
        <table width="100%">
            <tr>
                <td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 14px;">ZOFRATACNA</span></td>
                <td style="text-align: center; font-size: 12px; opacity: 0.8;">Sistema de Firmado Digital</td>
                <td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td>
            </tr>
        </table>
    </div>

    <!-- Barra Roja de Acción Requerida -->
    <div style="background-color: #c00000; color: white; padding: 10px 20px; font-weight: bold; font-size: 13px;">
        Acción requerida — firma digital pendiente
    </div>

    <div style="padding: 25px; color: #333;">
        <p style="margin-top: 0; font-size: 13px;">Estimado(a),<br>
        <strong style="font-size: 16px;">Juan Carlos Pérez Mamani</strong></p>
        
        <p style="font-size: 14px; line-height: 1.5;">El documento ha completado satisfactoriamente la fase de revisión y ha sido <b>Aprobado para firma</b>. Usted es el <b>primer firmante</b> en el orden secuencial establecido y su firma es requerida para continuar el proceso.</p>

        <!-- Cuadro de Detalle Rojo Suave -->
        <div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 15px; margin: 20px 0;">
            <h4 style="color: #943126; margin: 0 0 10px 0; font-size: 11px; text-transform: uppercase;">DETALLE DEL DOCUMENTO</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                <tr><td style="color: #cb4335; width: 35%; padding: 3px 0;">Asunto</td><td><b>Resolución de Gerencia N° 045-2025-GG</b></td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Tipo</td><td>Resolución</td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Su posición</td><td>
                    <span style="background-color: #f5b7b1; color: #7b241c; padding: 1px 8px; border-radius: 10px; font-size: 11px;">1° de 3 firmantes</span>
                </td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Plazo para firmar</td><td>
                    <span style="background-color: #fadbd8; padding: 1px 8px; border-radius: 10px; font-size: 11px;">Hasta 02/05/2026 (3 días)</span>
                </td></tr>
            </table>
        </div>

        <!-- Flujo de Firmas (Línea de tiempo) -->
        <div style="margin: 30px 0; text-align: center;">
            <table width="100%" style="font-size: 11px; color: #777;">
                <tr>
                    <td width="33%">
                        <div style="background-color: #c00000; color: white; width: 30px; height: 30px; line-height: 30px; border-radius: 50%; margin: 0 auto; font-weight: bold;">➜</div>
                        <div style="margin-top: 5px; color: #c00000; font-weight: bold;">Juan C. Pérez<br><span style="font-weight: normal; font-size: 9px;">Pendiente (Ud.)</span></div>
                    </td>
                    <td width="33%" style="border-top: 2px solid #eee; vertical-align: middle;">
                        <div style="background-color: #fff; color: #ccc; width: 28px; height: 28px; line-height: 28px; border-radius: 50%; margin: -15px auto 0; border: 2px solid #eee;">2</div>
                        <div style="margin-top: 5px;">Ana Ramos<br><span style="font-size: 9px;">En espera</span></div>
                    </td>
                    <td width="33%" style="border-top: 2px solid #eee; vertical-align: middle;">
                        <div style="background-color: #fff; color: #ccc; width: 28px; height: 28px; line-height: 28px; border-radius: 50%; margin: -15px auto 0; border: 2px solid #eee;">3</div>
                        <div style="margin-top: 5px;">Carlos Ríos<br><span style="font-size: 9px;">En espera</span></div>
                    </td>
                </tr>
            </table>
        </div>

        <!-- Cuadro Informativo -->
        <div style="background-color: #f4f7f9; border: 1px solid #e0e6ed; border-radius: 8px; padding: 15px; font-size: 12px; color: #445; line-height: 1.4;">
            <table width="100%">
                <tr>
                    <td width="30" style="vertical-align: top; font-size: 20px; color: #3498db;">ⓘ</td>
                    <td>Necesita su token criptográfico o lector de DNI electrónico. El componente Java de firma debe estar instalado en su navegador. Una vez firmado, se notificará automáticamente al siguiente firmante.</td>
                </tr>
            </table>
        </div>

        <!-- Botón -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 35px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 15px; display: inline-block;">
                Ir al sistema y firmar ahora
            </a>
            <p style="font-size: 11px; color: #999; margin-top: 10px;">O ingrese desde: <strong>firma.zofratacna.com.pe</strong></p>
        </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #fcfcfc; padding: 15px 20px; font-size: 10px; color: #999; border-top: 1px solid #eee;">
        <table width="100%">
            <tr>
                <td>Mensaje generado automáticamente — no responda este correo<br>ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</td>
                <td style="text-align: right; vertical-align: bottom;">30/04/2026 — 08:00 hrs</td>
            </tr>
        </table>
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Acción requerida: firma digital pendiente - RGG-045-2025', 
    @Mensaje = @Cuerpo;



GO
-- Correo 5 — Recordatorio de revisión pendiente
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">
    
    <!-- Encabezado Azul -->
    <div style="background-color: #1a335d; color: white; padding: 15px 20px;">
        <table width="100%">
            <tr>
                <td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 14px;">ZOFRATACNA</span></td>
                <td style="text-align: center; font-size: 12px; opacity: 0.8;">Sistema de Firmado Digital</td>
                <td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td>
            </tr>
        </table>
    </div>

    <!-- Barra Marrón de Recordatorio -->
    <div style="background-color: #7e5109; color: white; padding: 10px 20px; font-weight: bold; font-size: 13px;">
        Recordatorio — revisiones sin completar
    </div>

    <div style="padding: 25px; color: #333;">
        <p style="margin-top: 0; font-size: 13px;">Estimado(a),<br>
        <strong style="font-size: 16px;">María Elena Torres Condori</strong></p>
        
        <p style="font-size: 14px; line-height: 1.5;">Le recordamos que tiene <b>documentos pendientes de revisión</b> en el Sistema de Firmado Digital. El proceso institucional no puede avanzar hasta que todos los revisores completen su evaluación.</p>

        <!-- Cuadro de Detalle Crema/Dorado -->
        <div style="background-color: #fef5e7; border-left: 4px solid #b7950b; padding: 15px; margin: 20px 0;">
            <h4 style="color: #7e5109; margin: 0 0 10px 0; font-size: 11px; text-transform: uppercase;">DOCUMENTOS PENDIENTES DE REVISIÓN (1)</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                <tr><td style="color: #b7950b; width: 35%; padding: 3px 0;">Documento</td><td><b>Resolución de Gerencia N° 045-2025-GG</b></td></tr>
                <tr><td style="color: #b7950b; padding: 3px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #b7950b; padding: 3px 0;">Asignado el</td><td>27/04/2026</td></tr>
                <tr><td style="color: #b7950b; padding: 3px 0;">Vence el</td><td>
                    <span style="background-color: #f8c471; color: #784212; padding: 1px 8px; border-radius: 10px; font-size: 11px;">01/05/2026 — quedan 2 días</span>
                </td></tr>
                <tr><td style="color: #b7950b; padding: 3px 0;">Estado</td><td>
                    <span style="background-color: #fbdada; color: #922b21; padding: 1px 8px; border-radius: 10px; font-size: 11px;">Sin revisión registrada</span>
                </td></tr>
            </table>
        </div>

        <!-- Cuadro Informativo con Icono de Reloj -->
        <div style="background-color: #f4f7f4; border: 1px solid #d5dbdb; border-radius: 8px; padding: 15px; font-size: 12px; color: #566573; line-height: 1.4;">
            <table width="100%">
                <tr>
                    <td width="30" style="vertical-align: top; font-size: 20px; color: #b7950b;">🕒</td>
                    <td>Este recordatorio se genera una vez al día al ingresar al sistema. Si ya realizó la revisión e ingresó su observación o comentario de conformidad, puede ignorar este mensaje.</td>
                </tr>
            </table>
        </div>

        <!-- Botón -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 35px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 15px; display: inline-block;">
                Ir a mi bandeja de pendientes
            </a>
            <p style="font-size: 11px; color: #999; margin-top: 10px;">O ingrese desde: <strong>firma.zofratacna.com.pe</strong></p>
        </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #fcfcfc; padding: 15px 20px; font-size: 10px; color: #999; border-top: 1px solid #eee;">
        <table width="100%">
            <tr>
                <td>Mensaje generado automáticamente — no responda este correo<br>ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</td>
                <td style="text-align: right; vertical-align: bottom;">29/04/2026 — 08:00 hrs</td>
            </tr>
        </table>
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Recordatorio: documentos pendientes de revisión - RGG-045-2025', 
    @Mensaje = @Cuerpo;



GO
-- Correo 6 — Recordatorio de firma pendiente
DECLARE @Cuerpo NVARCHAR(MAX) = '
<div style="font-family: Arial, sans-serif; max-width: 600px; border: 1px solid #e0e0e0; margin: auto; background-color: #ffffff;">
    
    <!-- Encabezado Azul -->
    <div style="background-color: #1a335d; color: white; padding: 15px 20px;">
        <table width="100%">
            <tr>
                <td><span style="background-color: white; color: #1a335d; padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 14px;">ZOFRATACNA</span></td>
                <td style="text-align: center; font-size: 12px; opacity: 0.8;">Sistema de Firmado Digital</td>
                <td style="text-align: right; font-size: 10px; opacity: 0.6;">ISO 9001:2015</td>
            </tr>
        </table>
    </div>

    <!-- Barra Roja de Recordatorio Urgente -->
    <div style="background-color: #c00000; color: white; padding: 10px 20px; font-weight: bold; font-size: 13px;">
        Recordatorio urgente — firma digital sin completar
    </div>

    <div style="padding: 25px; color: #333;">
        <p style="margin-top: 0; font-size: 13px;">Estimado(a),<br>
        <strong style="font-size: 16px;">Juan Carlos Pérez Mamani</strong></p>
        
        <p style="font-size: 14px; line-height: 1.5;">Le recordamos que tiene <b>una firma digital pendiente</b>. El proceso institucional está detenido a la espera de su firma. Los firmantes siguientes no pueden actuar hasta que usted complete este paso.</p>

        <!-- Cuadro de Detalle Rojo Suave -->
        <div style="background-color: #fdf2f2; border-left: 4px solid #ec7063; padding: 15px; margin: 20px 0;">
            <h4 style="color: #943126; margin: 0 0 10px 0; font-size: 11px; text-transform: uppercase;">DOCUMENTO PENDIENTE DE FIRMA</h4>
            <table style="width: 100%; font-size: 13px; border-collapse: collapse;">
                <tr><td style="color: #cb4335; width: 35%; padding: 3px 0;">Asunto</td><td><b>Resolución de Gerencia N° 045-2025-GG</b></td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Código</td><td>RGG-045-2025</td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Su posición</td><td>1° de 3 firmantes</td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Notificado el</td><td>30/04/2026</td></tr>
                <tr><td style="color: #cb4335; padding: 3px 0;">Vence el</td><td>
                    <span style="background-color: #f5b7b1; color: #7b241c; padding: 1px 8px; border-radius: 10px; font-size: 11px;">02/05/2026 — quedan 2 días</span>
                </td></tr>
            </table>
        </div>

        <!-- Flujo de Firmas (Línea de tiempo con bloqueados) -->
        <div style="margin: 30px 0; text-align: center;">
            <table width="100%" style="font-size: 11px; color: #777;">
                <tr>
                    <td width="33%">
                        <div style="background-color: #c00000; color: white; width: 30px; height: 30px; line-height: 30px; border-radius: 50%; margin: 0 auto; font-weight: bold;">➜</div>
                        <div style="margin-top: 5px; color: #c00000; font-weight: bold;">Juan C. Pérez<br><span style="font-weight: normal; font-size: 9px;">Pendiente (Ud.)</span></div>
                    </td>
                    <td width="33%" style="border-top: 2px solid #eee; vertical-align: middle;">
                        <div style="background-color: #fff; color: #ccc; width: 28px; height: 28px; line-height: 28px; border-radius: 50%; margin: -15px auto 0; border: 2px solid #eee;">2</div>
                        <div style="margin-top: 5px;">Ana Ramos<br><span style="font-size: 9px;">Bloqueado</span></div>
                    </td>
                    <td width="33%" style="border-top: 2px solid #eee; vertical-align: middle;">
                        <div style="background-color: #fff; color: #ccc; width: 28px; height: 28px; line-height: 28px; border-radius: 50%; margin: -15px auto 0; border: 2px solid #eee;">3</div>
                        <div style="margin-top: 5px;">Carlos Ríos<br><span style="font-size: 9px;">Bloqueado</span></div>
                    </td>
                </tr>
            </table>
        </div>

        <!-- Cuadro Informativo de Soporte -->
        <div style="background-color: #f4f4f4; border: 1px solid #ddd; border-radius: 8px; padding: 15px; font-size: 12px; color: #444; line-height: 1.4;">
            <table width="100%">
                <tr>
                    <td width="30" style="vertical-align: top; font-size: 20px; color: #cb4335;">ⓘ</td>
                    <td>Si tiene dificultades con el token o el componente Java, contacte a Sistemas al <b>anexo 220</b> o escriba a <b>sistemas@zofratacna.com.pe</b> antes de que venza el plazo.</td>
                </tr>
            </table>
        </div>

        <!-- Botón -->
        <div style="text-align: center; margin-top: 30px;">
            <a href="https://zofratacna.com.pe" style="background-color: #1a335d; color: white; padding: 12px 40px; text-decoration: none; border-radius: 6px; font-weight: bold; font-size: 15px; display: inline-block;">
                Firmar ahora
            </a>
            <p style="font-size: 11px; color: #999; margin-top: 15px;">O ingrese desde: <strong>firma.zofratacna.com.pe</strong></p>
        </div>
    </div>

    <!-- Footer -->
    <div style="background-color: #fcfcfc; padding: 15px 20px; font-size: 10px; color: #999; border-top: 1px solid #eee;">
        <table width="100%">
            <tr>
                <td>Mensaje generado automáticamente — no responda este correo<br>ZOFRATACNA — Panamericana Sur Km. 1308, Tacna Perú</td>
                <td style="text-align: right; vertical-align: bottom;">01/05/2026 — 08:00 hrs</td>
            </tr>
        </table>
    </div>
</div>
';
EXEC [dbo].[GEN_X_EnviarMail] 
    @Para = 'daleskanicole118@gmail.com', 
    @Asunto = 'Recordatorio urgente — firma digital sin completar - RGG-045-2025', 
    @Mensaje = @Cuerpo;
-- FIN de plantillas de prueba */

/*
-- ============================================================
-- CONSULTAS DE PRUEBA (NO EJECUTAR EN INSTALACION)
-- ============================================================
select * from empleado
select * from usuariosistema
EXEC dbo.FIR_X_NotifAsigRev @IdDocumento = 1009;

SELECT * FROM DocumentoParticipante
SELECT * FROM Documentoadjunto
SELECT * FROM maestro
SELECT * FROM unidadorganica
SELECT * FROM HISTORIALDOCUMENTO

SELECT IdMaestro, Codigo, Descripcion
FROM dbo.Maestro
WHERE IdMaestro IN (23, 24, 25, 26, 27, 28, 29, 30);

DECLARE @IdDocumento INT = 1013;

SELECT
    d.CodigoDocumento,
    v.NombreCompleto AS Persona,
    v.Email,
    p.OrdenSecuencial AS Orden,
    m.Codigo AS CodigoRol,
    m.Descripcion AS RolEnDocumento
FROM dbo.DocumentoParticipante p
INNER JOIN dbo.Documento d ON p.IdDocumento = d.IdDocumento
INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON p.LoginUsuario = v.LoginUsuario
INNER JOIN dbo.Maestro m ON p.IdTipoParticipante = m.IdMaestro
WHERE d.IdDocumento = @IdDocumento
  AND m.Codigo IN ('REV', 'FIR')
ORDER BY m.Codigo DESC, p.OrdenSecuencial ASC;

UPDATE dbo.UsuarioSistema
SET IdRolSistema = 3
WHERE IdUsuario = 1008;

SELECT * FROM dbo.UsuarioSistema WHERE IdUsuario = 1008;
*/

select * from FIR_DocumentoObsMarcador
