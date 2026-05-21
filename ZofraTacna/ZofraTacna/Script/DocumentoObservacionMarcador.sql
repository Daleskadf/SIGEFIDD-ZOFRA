-- ============================================================
-- DESCRIPCION:
--   Marcadores de observación anclados al PDF (página + coordenadas normalizadas).
-- USADO POR (MODULOS):
--   FirmaDigital / Revision
-- HISTORICO DE MANTENIMIENTOS:
--   SM-000-2026 Sistema, 2026-05-11
-- ============================================================

SET NOCOUNT OFF;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE FirmaDigital;
GO

IF OBJECT_ID('dbo.DocumentoObservacionMarcador', 'U') IS NOT NULL AND OBJECT_ID('dbo.FIR_DocumentoObsMarcador', 'U') IS NULL
    EXEC sp_rename 'dbo.DocumentoObservacionMarcador', 'FIR_DocumentoObsMarcador';
GO

IF OBJECT_ID('dbo.FIR_DocumentoObsMarcador', 'U') IS NULL
BEGIN
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

    CREATE INDEX ID_DocObsMar_DocBorrador
        ON dbo.FIR_DocumentoObsMarcador (IdDocumento, EsBorrador, LoginUsuario);

    PRINT 'Tabla FIR_DocumentoObsMarcador creada.';
END
ELSE
BEGIN
    PRINT 'Tabla FIR_DocumentoObsMarcador ya existe.';
END
GO

IF COL_LENGTH('dbo.FIR_DocumentoObsMarcador', 'IDUsuarioCreador') IS NULL
BEGIN
    ALTER TABLE dbo.FIR_DocumentoObsMarcador
        ADD IDUsuarioCreador VARCHAR(15) NOT NULL CONSTRAINT df_DocObsMar_IDUsuarioCreador DEFAULT '';

    UPDATE dbo.FIR_DocumentoObsMarcador
        SET IDUsuarioCreador = LoginUsuario
    WHERE IDUsuarioCreador = '';
END
GO

IF COL_LENGTH('dbo.FIR_DocumentoObsMarcador', 'IDUsuarioModificador') IS NULL
    ALTER TABLE dbo.FIR_DocumentoObsMarcador ADD IDUsuarioModificador VARCHAR(15) NULL;
GO

IF COL_LENGTH('dbo.FIR_DocumentoObsMarcador', 'FechaModificacion') IS NULL
    ALTER TABLE dbo.FIR_DocumentoObsMarcador ADD FechaModificacion SMALLDATETIME NULL;
GO

IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'pk_DocumentoObservacionMarcador')
    EXEC sp_rename 'dbo.pk_DocumentoObservacionMarcador', 'pk_FIR_DocumentoObsMarcador', 'OBJECT';
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'df_DocObsMar_Tipo')
    EXEC sp_rename 'dbo.df_DocObsMar_Tipo', 'df_DocObsMar_TipoMarcador', 'OBJECT';
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'df_DocObsMar_Borrador')
    EXEC sp_rename 'dbo.df_DocObsMar_Borrador', 'df_DocObsMar_EsBorrador', 'OBJECT';
GO

IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'df_DocObsMar_Fecha')
    EXEC sp_rename 'dbo.df_DocObsMar_Fecha', 'df_DocObsMar_FechaCreacion', 'OBJECT';
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_DocObsMar_DocBorrador')
BEGIN
    IF OBJECT_ID('dbo.DocumentoObservacionMarcador', 'U') IS NOT NULL
        EXEC sp_rename 'dbo.DocumentoObservacionMarcador.ix_DocObsMar_DocBorrador', 'ID_DocObsMar_DocBorrador', 'INDEX';
    IF OBJECT_ID('dbo.FIR_DocumentoObsMarcador', 'U') IS NOT NULL
        EXEC sp_rename 'dbo.FIR_DocumentoObsMarcador.ix_DocObsMar_DocBorrador', 'ID_DocObsMar_DocBorrador', 'INDEX';
END
GO
