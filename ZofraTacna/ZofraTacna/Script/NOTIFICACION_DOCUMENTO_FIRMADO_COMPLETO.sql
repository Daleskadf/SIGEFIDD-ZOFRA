-- ============================================================================
-- DESCRIPCIÓN:
--   Script corregido para Azure SQL. Implementa la notificación automática
--   cuando un documento es firmado completamente (estado FCOM).
-- CAMBIOS:
--   - Se removió el botón verde de enlace directo por solicitud.
--   - Se agregó un recuadro informativo indicando que ya pueden descargar el
--     documento firmado directamente desde el sistema SIGEFIDD-ZOFRA.
-- NOTA IMPORTANTE:
--   Azure SQL no soporta la sentencia USE. Por favor, asegúrese de conectarse
--   directamente o seleccionar la base de datos 'FirmaDigital' en el dropdown
--   de SSMS antes de ejecutar este script.
-- ============================================================================

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

PRINT '============================================================================';
PRINT ' SIGEFIDD-ZOFRA - NOTIFICACIÓN DE DOCUMENTO FIRMADO COMPLETAMENTE (FCOM) ';
PRINT '============================================================================';
GO

-- ============================================================================
-- PARTE 1: CREACIÓN DEL PROCEDIMIENTO ALMACENADO DE NOTIFICACIÓN
-- ============================================================================
PRINT '--- Creando/Actualizando Procedimiento: dbo.FIR_X_NotifDocFirmadoCompleto ---';
GO

IF OBJECT_ID('dbo.FIR_X_NotifDocFirmadoCompleto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIR_X_NotifDocFirmadoCompleto;
GO

CREATE PROCEDURE dbo.FIR_X_NotifDocFirmadoCompleto
    @IdDocumento INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AsuntoDoc VARCHAR(300), @CodigoDoc VARCHAR(50), @AreaDoc VARCHAR(150);
    DECLARE @EmailDestino VARCHAR(150), @NombreDestinatario VARCHAR(250), @RolDestinatario VARCHAR(100);
    DECLARE @Cuerpo NVARCHAR(MAX), @AsuntoFinal NVARCHAR(250);
    DECLARE @FirmantesList NVARCHAR(MAX) = '';

    -- 1. Obtener datos generales del documento usando la vista local de Unidades Orgánicas para Azure SQL
    SELECT 
        @AsuntoDoc = d.Asunto,
        @CodigoDoc = d.CodigoDocumento,
        @AreaDoc = ISNULL(uo.Descripcion, 'Área No Definida')
    FROM dbo.Documento d
    LEFT JOIN dbo.FIR_VW_UnidadesOrganicas uo ON TRY_CONVERT(INT, d.AreaResponsable) = uo.IDUnidadOrganica
    WHERE d.IdDocumento = @IdDocumento;

    -- 2. Construir la lista visual de firmantes que completaron la firma
    SELECT @FirmantesList = @FirmantesList + 
        N'<tr>' +
        N'  <td style="padding: 8px 12px; border-bottom: 1px solid #edf2f7; font-size: 13px; color: #2d3748; font-weight: 500;">' + v.NombreCompleto + N'</td>' +
        N'  <td style="padding: 8px 12px; border-bottom: 1px solid #edf2f7; text-align: right;">' +
        N'    <span style="background-color: #e8f5e9; color: #2e7d32; padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; border: 1px solid #c8e6c9; display: inline-block;">✓ Firmado</span>' +
        N'  </td>' +
        N'</tr>'
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    INNER JOIN dbo.FirmaDetalle fd ON dp.IdParticipante = fd.IdParticipante
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo = 'FIR'
    ORDER BY dp.OrdenSecuencial;

    -- Si por alguna razón la lista está vacía, mostrar mensaje alternativo
    IF ISNULL(@FirmantesList, '') = ''
    BEGIN
        SET @FirmantesList = N'<tr><td colspan="2" style="padding: 10px 12px; font-size: 12px; color: #718096; font-style: italic; text-align: center;">Todos los firmantes han completado su firma digital.</td></tr>';
    END

    -- 3. Cursor para notificar a Registrador, Revisores y Firmantes
    -- Se notifica al Registrador (creador) y a todos los Revisores y Firmantes involucrados.
    DECLARE curNotificar CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT v.Email, v.NombreCompleto, 
        CASE 
            WHEN d.LoginUsuarioRegistrador = v.LoginUsuario THEN 'Registrador (Creador)'
            WHEN m.Codigo = 'REV' THEN 'Revisor'
            ELSE 'Firmante'
        END AS Rol
    FROM dbo.Documento d 
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON d.LoginUsuarioRegistrador = v.LoginUsuario 
    LEFT JOIN dbo.DocumentoParticipante dp ON d.IdDocumento = dp.IdDocumento AND dp.LoginUsuario = v.LoginUsuario
    LEFT JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE d.IdDocumento = @IdDocumento
    
    UNION
    
    SELECT DISTINCT v.Email, v.NombreCompleto, 
        CASE 
            WHEN m.Codigo = 'REV' THEN 'Revisor'
            ELSE 'Firmante'
        END AS Rol
    FROM dbo.DocumentoParticipante dp
    INNER JOIN dbo.FIR_VW_EmpleadosActivos v ON dp.LoginUsuario = v.LoginUsuario
    INNER JOIN dbo.Maestro m ON dp.IdTipoParticipante = m.IdMaestro
    WHERE dp.IdDocumento = @IdDocumento AND m.Codigo IN ('REV', 'FIR');

    OPEN curNotificar;
    FETCH NEXT FROM curNotificar INTO @EmailDestino, @NombreDestinatario, @RolDestinatario;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Diseño visual premium con estilo esmeralda (#27ae60)
        SET @Cuerpo = CONCAT(
            N'<div style="font-family: ''Segoe UI'', Arial, sans-serif; max-width: 600px; border: 1px solid #e2e8f0; margin: auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);">',
            N'  <div style="background-color: #1a335d; color: white; padding: 18px 24px; font-size: 14px; font-weight: 500;">',
            N'    <table width="100%" style="border-collapse: collapse;"><tr>',
            N'      <td><span style="background-color: #ffffff; color: #1a335d; padding: 4px 10px; border-radius: 4px; font-weight: bold; font-size: 12px; letter-spacing: 0.5px;">ZOFRATACNA</span></td>',
            N'      <td style="text-align: right; font-size: 11px; opacity: 0.8; font-weight: normal; font-family: inherit;">Firma Digital Integrada</td>',
            N'    </tr></table>',
            N'  </div>',
            N'  <div style="background-color: #27ae60; color: white; padding: 16px 24px; font-size: 15px; font-weight: 600; letter-spacing: 0.3px;">',
            N'    ✔ DOCUMENTO FIRMADO COMPLETAMENTE',
            N'  </div>',
            N'  <div style="padding: 28px 24px; color: #2d3748; line-height: 1.6;">',
            N'    <p style="margin-top: 0; font-size: 15px;">Estimado(a) <strong>', @NombreDestinatario, N'</strong> (<em>', @RolDestinatario, N'</em>),</p>',
            N'    <p style="font-size: 14px; color: #4a5568; margin-bottom: 20px;">Nos complace informarle que el proceso de firma digital para el documento ha concluido con éxito. Todos los firmantes designados han estampado su firma digital en el archivo PDF correspondiente.</p>',
            
            -- Detalle del Documento
            N'    <div style="background-color: #f7fafc; border: 1px solid #edf2f7; border-radius: 8px; padding: 20px; margin: 24px 0;">',
            N'      <h4 style="color: #2c5282; margin: 0 0 12px 0; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">DETALLE DE LA TRANSACCIÓN</h4>',
            N'      <table style="width: 100%; font-size: 13px; border-collapse: collapse; color: #2d3748;">',
            N'        <tr><td style="color: #718096; width: 30%; padding: 5px 0;">Documento:</td><td style="padding: 5px 0; font-weight: bold; color: #1a202c;">', @AsuntoDoc, N'</td></tr>',
            N'        <tr><td style="color: #718096; padding: 5px 0;">Código:</td><td style="padding: 5px 0; font-family: Consolas, monospace; color: #2d3748;">', @CodigoDoc, N'</td></tr>',
            N'        <tr><td style="color: #718096; padding: 5px 0;">Área Origen:</td><td style="padding: 5px 0; color: #2d3748;">', @AreaDoc, N'</td></tr>',
            N'        <tr><td style="color: #718096; padding: 5px 0;">Estado Actual:</td><td style="padding: 5px 0;"><span style="background-color: #def7ec; color: #03543f; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; border: 1px solid #bfeecb;">Firmado Completo (FCOM)</span></td></tr>',
            N'      </table>',
            N'    </div>',

            -- Tabla de Firmas
            N'    <div style="border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; margin: 24px 0;">',
            N'      <div style="background-color: #f8fafc; padding: 10px 14px; border-bottom: 1px solid #e2e8f0; font-size: 12px; font-weight: bold; color: #4a5568; text-transform: uppercase; letter-spacing: 0.3px;">Lista de Firmantes</div>',
            N'      <table style="width: 100%; border-collapse: collapse;">',
            @FirmantesList,
            N'      </table>',
            N'    </div>',
            
            -- Recuadro Informativo de Descarga (Reemplaza al botón anterior)
            N'    <div style="background-color: #f0fdf4; border: 1px solid #bfeecb; border-radius: 8px; padding: 15px 20px; margin-top: 28px; color: #1e3a1e; font-size: 13.5px; text-align: center; line-height: 1.5; font-weight: 500;">',
            N'      📥 <strong>Descarga Disponible:</strong> Ya puede descargar este archivo PDF completamente firmado ingresando a su bandeja de <strong>Documentos Finalizados</strong> en el sistema <strong>SIGEFIDD-ZOFRA</strong>.',
            N'    </div>',

            N'  </div>',
            N'  <div style="background-color: #fcfcfc; padding: 20px; font-size: 10px; color: #a0aec0; text-align: center; border-top: 1px solid #edf2f7;">',
            N'    Este es un mensaje automático generado por el Sistema de Firma Digital (SIGEFIDD-ZOFRA) de la Zona Franca de Tacna.<br>Por favor, no responda a esta dirección de correo electrónico.',
            N'  </div>',
            N'</div>'
        );

        SET @AsuntoFinal = CONCAT(N'CONCLUIDO: ', @CodigoDoc, N' - Documento Firmado Completamente');

        -- Enviar vía túnel elástico a través de sp_execute_remote hacia la base de datos de administración
        EXEC dbo.GEN_X_EnviarMail @Para = @EmailDestino, @Asunto = @AsuntoFinal, @Mensaje = @Cuerpo;

        FETCH NEXT FROM curNotificar INTO @EmailDestino, @NombreDestinatario, @RolDestinatario;
    END

    CLOSE curNotificar;
    DEALLOCATE curNotificar;
END
GO

PRINT 'Procedimiento FIR_X_NotifDocFirmadoCompleto creado/actualizado exitosamente.';
GO

-- ============================================================================
-- PARTE 2: CREACIÓN DEL TRIGGER DE BASE DE DATOS EN LA TABLA Documento
-- ============================================================================
PRINT '--- Creando/Actualizando Trigger: dbo.TRG_Documento_NotifFCOM ---';
GO

IF OBJECT_ID('dbo.TRG_Documento_NotifFCOM', 'TR') IS NOT NULL
    DROP TRIGGER dbo.TRG_Documento_NotifFCOM;
GO

CREATE TRIGGER dbo.TRG_Documento_NotifFCOM
ON dbo.Documento
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Obtener el ID del estado 'FCOM'
    DECLARE @IdEstadoFcom INT;
    SELECT @IdEstadoFcom = IdMaestro 
    FROM dbo.Maestro 
    WHERE Tipo = 'ESTADO_DOC' AND Codigo = 'FCOM';

    -- Si no existe el estado FCOM en el maestro, no hacer nada
    IF @IdEstadoFcom IS NULL
        RETURN;

    -- 2. Identificar si el documento pasó al estado FCOM
    -- (i.IdEstadoDocumento = FCOM y el estado anterior d.IdEstadoDocumento != FCOM)
    DECLARE @IdDocumento INT;

    -- Usamos un cursor local por si se actualizan varios registros en lote
    DECLARE curFcom CURSOR LOCAL FAST_FORWARD FOR
    SELECT i.IdDocumento
    FROM inserted i
    INNER JOIN deleted d ON i.IdDocumento = d.IdDocumento
    WHERE i.IdEstadoDocumento = @IdEstadoFcom
      AND d.IdEstadoDocumento <> @IdEstadoFcom;

    OPEN curFcom;
    FETCH NEXT FROM curFcom INTO @IdDocumento;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- 3. Invocar al procedimiento de notificación
        BEGIN TRY
            EXEC dbo.FIR_X_NotifDocFirmadoCompleto @IdDocumento = @IdDocumento;
        END TRY
        BEGIN CATCH
            -- Capturar error para que la transacción del trigger no falle
            -- y no bloquee el guardado de la firma en el flujo principal.
            PRINT 'Error al enviar notificación FCOM para el documento ID ' + CAST(@IdDocumento AS VARCHAR) + ': ' + ERROR_MESSAGE();
        END CATCH

        FETCH NEXT FROM curFcom INTO @IdDocumento;
    END

    CLOSE curFcom;
    DEALLOCATE curFcom;
END
GO

PRINT 'Trigger TRG_Documento_NotifFCOM creado exitosamente en la tabla Documento.';
GO

-- ============================================================================
-- PARTE 3: VERIFICACIÓN
-- ============================================================================
PRINT '============================================================================';
PRINT ' VERIFICACIÓN DE OBJETOS CREADOS';
PRINT '============================================================================';
GO

SELECT ROUTINE_NAME AS Procedimiento, ROUTINE_TYPE AS Tipo
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dbo' 
  AND ROUTINE_NAME = 'FIR_X_NotifDocFirmadoCompleto';

SELECT name AS TriggerName, parent_class_desc AS ClasePadre, is_disabled AS Deshabilitado
FROM sys.triggers
WHERE name = 'TRG_Documento_NotifFCOM';
GO
