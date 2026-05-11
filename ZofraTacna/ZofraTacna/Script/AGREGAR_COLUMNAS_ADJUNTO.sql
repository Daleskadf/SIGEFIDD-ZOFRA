-- ============================================================
-- SIGEFIDD-ZOFRA - AGREGAR COLUMNAS A DocumentoAdjunto
-- Fecha: 2026-05-11
-- Descripción: Agrega las columnas nuevas que faltaban en
--              la tabla DocumentoAdjunto de FirmaDigital_Files
-- ============================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '============================================================';
PRINT ' AGREGAR COLUMNAS A DocumentoAdjunto';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '============================================================';
GO

USE FirmaDigital_Files;
GO

PRINT '';
PRINT '--- Verificando y agregando columnas a DocumentoAdjunto ---';
GO

-- Agregar columna EsSuperado si no existe
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoAdjunto') AND name='EsSuperado')
BEGIN
    ALTER TABLE dbo.DocumentoAdjunto 
    ADD EsSuperado BIT NOT NULL CONSTRAINT df_DocAdjunto_EsSup DEFAULT 0;
    PRINT '✓ Columna EsSuperado agregada.';
END
ELSE
    PRINT '✓ Columna EsSuperado ya existe.';
GO

-- Agregar columna FechaSuperacion si no existe
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoAdjunto') AND name='FechaSuperacion')
BEGIN
    ALTER TABLE dbo.DocumentoAdjunto 
    ADD FechaSuperacion DATETIME NULL;
    PRINT '✓ Columna FechaSuperacion agregada.';
END
ELSE
    PRINT '✓ Columna FechaSuperacion ya existe.';
GO

-- Agregar columna LoginSuperacion si no existe
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoAdjunto') AND name='LoginSuperacion')
BEGIN
    ALTER TABLE dbo.DocumentoAdjunto 
    ADD LoginSuperacion VARCHAR(50) NULL;
    PRINT '✓ Columna LoginSuperacion agregada.';
END
ELSE
    PRINT '✓ Columna LoginSuperacion ya existe.';
GO

-- Agregar columna MotivoSuperacion si no existe
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('dbo.DocumentoAdjunto') AND name='MotivoSuperacion')
BEGIN
    ALTER TABLE dbo.DocumentoAdjunto 
    ADD MotivoSuperacion VARCHAR(300) NULL;
    PRINT '✓ Columna MotivoSuperacion agregada.';
END
ELSE
    PRINT '✓ Columna MotivoSuperacion ya existe.';
GO

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
PRINT '';
PRINT '--- Estructura actual de DocumentoAdjunto ---';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DocumentoAdjunto' AND TABLE_SCHEMA = 'dbo'
ORDER BY ORDINAL_POSITION;
GO

PRINT '';
PRINT '============================================================';
PRINT ' COLUMNAS AGREGADAS EXITOSAMENTE';
PRINT '============================================================';
GO
