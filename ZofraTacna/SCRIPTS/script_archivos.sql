CREATE DATABASE FirmaDigital_Files;
GO
USE FirmaDigital_Files;
GO

-- ============================================================
-- TABLA: DocumentoAdjunto (Repositorio de PDFs con auditoría)
-- ============================================================
IF OBJECT_ID('dbo.DocumentoAdjunto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocumentoAdjunto (
        IdAdjunto        INT IDENTITY(1,1) NOT NULL,

        -- Referencia lógica al documento (sin FK entre BD)
        IdDocumento      INT NOT NULL,

        -- Archivo
        ContenidoPDF     VARBINARY(MAX) NOT NULL,
        NombreArchivo    VARCHAR(255) NOT NULL,
        TipoMime         VARCHAR(100) DEFAULT 'application/pdf',
        TamañoBytes      INT NULL,

        -- Control de versión
        EsVersionFinal   BIT DEFAULT 0,

        -- =====================================================
        -- AUDITORÍA (OBLIGATORIO EN SISTEMA INSTITUCIONAL)
        -- =====================================================
        UsuarioCreacion  VARCHAR(50) NOT NULL,
        FechaCreacion    DATETIME DEFAULT GETDATE(),

        UsuarioModificacion VARCHAR(50) NULL,
        FechaModificacion   DATETIME NULL,

        UsuarioEliminacion  VARCHAR(50) NULL,
        FechaEliminacion    DATETIME NULL,
        EsEliminado         BIT DEFAULT 0,

        CONSTRAINT pk_DocumentoAdjunto PRIMARY KEY (IdAdjunto)
    );

    PRINT 'Tabla DocumentoAdjunto con auditoría creada.';
END
GO