-- Marcadores de observacion anclados al PDF (pagina + coordenadas normalizadas).
-- Ejecutar en la base FirmaDigital antes de usar anotaciones en EmitirRevision.

IF OBJECT_ID('dbo.DocumentoObservacionMarcador', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocumentoObservacionMarcador (
        IdMarcador         INT            IDENTITY(1,1) NOT NULL,
        IdDocumento        INT            NOT NULL,
        LoginUsuario       VARCHAR(15)    NOT NULL,
        TipoMarcador       VARCHAR(12)    NOT NULL CONSTRAINT df_DocObsMar_Tipo DEFAULT 'pin',
        Pagina             INT            NOT NULL,
        PosX               FLOAT          NOT NULL,
        PosY               FLOAT          NOT NULL,
        Ancho              FLOAT          NULL,
        Alto               FLOAT          NULL,
        TextoSeleccionado  NVARCHAR(500)  NULL,
        Comentario         NVARCHAR(1000) NOT NULL,
        EsBorrador         BIT            NOT NULL CONSTRAINT df_DocObsMar_Borrador DEFAULT 1,
        FechaCreacion      DATETIME       NOT NULL CONSTRAINT df_DocObsMar_Fecha DEFAULT GETDATE(),
        CONSTRAINT pk_DocumentoObservacionMarcador PRIMARY KEY CLUSTERED (IdMarcador)
    );

    CREATE INDEX ix_DocObsMar_DocBorrador
        ON dbo.DocumentoObservacionMarcador (IdDocumento, EsBorrador, LoginUsuario);

    PRINT 'Tabla DocumentoObservacionMarcador creada.';
END
ELSE
    PRINT 'Tabla DocumentoObservacionMarcador ya existe.';
