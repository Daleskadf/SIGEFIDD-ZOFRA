# SIGEFIDD-ZOFRA

## ¿Qué hace el sistema?

SIGEFIDD-ZOFRA (Sistema de Gestión de Firma Digital de Documentos) es una aplicación web para **gestionar el ciclo completo de documentos PDF** dentro de ZOFRATACNA:

- Registro y carga de documentos (PDF).
- Asignación de participantes (revisores y firmantes).
- Flujo de revisión con observaciones y correcciones.
- Emisión de firma digital (con soporte de firma visible/desplegada).
- Auditoría/historial de acciones y cambios sobre el documento.
- Notificaciones in-app.

## ¿Cómo funciona el sistema? (flujo funcional)

El sistema está orientado a roles y estados. A nivel de usuario, se trabaja principalmente con estos roles:

- **REG**: Registrador (carga documentos y atiende observaciones).
- **REV**: Revisor (revisa y aprueba u observa).
- **FIR**: Firmante (firma documentos aprobados).
- **ADM**: Administrador (gestiona acceso/roles y operación general).

El documento avanza por estados (catálogo `Maestro` tipo `ESTADO_DOC`):

- **REG**: Registrado (documento recién cargado).
- **REV**: En Revisión (revisores asignados / revisión en proceso).
- **OBS**: Observado (hay observaciones pendientes de levantar).
- **PEN**: Pendiente de Firma (revisión completada y pasa a firma).
- **FPAR**: Firma Parcial (al menos un firmante ya firmó).
- **FCOM**: Firmado Completo (todos los firmantes terminaron).

De forma resumida:

1. El **registrador** carga el PDF y define participantes.
2. Los **revisores** emiten conformidad u observaciones.
3. Si hay observaciones, el documento entra en **OBS** y el registrador corrige/actualiza el PDF.
4. Cuando la revisión queda conforme, el documento pasa a **PEN** y se habilita la firma.
5. Los **firmantes** van firmando; el documento pasa a **FPAR** y finalmente a **FCOM**.

La actualización de estados y el registro de eventos se realiza en base de datos, manteniendo trazabilidad (historial/bitácora) y el estado individual de cada participante.

## Arquitectura

Es una solución **ASP.NET Web Forms** sobre **.NET Framework 4.8**, organizada por capas dentro del mismo proyecto.

**Capas (por carpetas):**

- **Presentación** ([Presentacion/](ZofraTacna/ZofraTacna/Presentacion/)): páginas ASPX y handlers ASHX. Maneja UI, navegación, endpoints HTTP (descargas/subidas), y el visor PDF (incluye PDF.js en la pantalla de firma).
- **Lógica de negocio** ([LogicaNegocio/](ZofraTacna/ZofraTacna/LogicaNegocio/)): módulos que orquestan el flujo (revisión/firma) y delegan persistencia al repositorio.
- **Datos** ([Datos/](ZofraTacna/ZofraTacna/Datos/)): acceso a datos con ADO.NET (SQL Server). Contiene repositorios y procedimientos de actualización de estados, adjuntos, firmas, auditoría.
- **Modelos** ([Models/](ZofraTacna/ZofraTacna/Models/)): entidades del dominio (por ejemplo, `Documento`).
- **Servicios externos** ([ServiciosExternos/](ZofraTacna/ZofraTacna/ServiciosExternos/)): integraciones (correo, conectores, y componentes relacionados a firma cuando aplica).

**Tecnologías relevantes:**

- **SQL Server** como base de datos (cadena `FirmaDigital` en configuración).
- **iTextSharp** + **BouncyCastle** para firma PDF y criptografía.
- **PDF.js** para el visor y posicionamiento de la firma visible.

## ¿Cómo realiza la firma digital?

El sistema contempla distintos caminos para firmar un PDF, pero todos convergen en lo mismo:

- Se genera/obtiene un **PDF firmado** (PAdES).
- Se guarda el archivo actualizado en la base de datos (adjunto principal o adjunto firmado).
- Se registra la firma en el flujo (tabla de detalle de firma) y se actualiza el estado del documento.


### Firma usada en esta rama para despliegue web (Cliente Web Firma Perú)

En el escenario “desplegado en web” (servidor en una máquina y usuarios firmando desde sus PCs), **la firma no se ejecuta en el servidor**. En esta rama se utiliza el **Cliente Web de Firma Perú** (JS) que invoca un componente local en la PC del usuario para firmar con su certificado.

- **Biblioteca JS**: se carga `firmaperu.min.js` desde `https://apps.firmaperu.gob.pe/web/clienteweb/firmaperu.min.js` (ver [EmitirFirma](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx) y el ejemplo [EmitirFirmaSimple](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirmaSimple.aspx)).
- **Invocación**: el navegador arma un JSON con `param_url`, `param_token` y `document_extension`, lo codifica en Base64 y llama `startSignature(48596, base64)` (ver [EmitirFirmaSimple](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirmaSimple.aspx)).
- **Token**: `param_token` es un token URL-safe Base64 generado por el sistema con el formato `idDocumento|login|ticks`. Se usa para identificar el documento y el usuario firmante en la descarga/subida del PDF (ver [DescargaDocumentoTemporal](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/DescargaDocumentoTemporal.ashx.cs) y [FirmaPeruSubir](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx.cs)).
- **Obtención de parámetros**: el componente local consulta `param_url` para obtener parámetros de firma (Base64) generados por el sistema (ver [FirmaPeruParametros](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruParametros.ashx.cs)).
- **Descarga del PDF**: el componente local descarga el PDF desde el endpoint indicado en `documentToSign` (por ejemplo [FirmaPeruDocumento](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruDocumento.ashx.cs)).
- **Firma en el equipo del usuario**: el usuario selecciona el certificado y confirma el PIN en el diálogo nativo del proveedor (token/DNIe). El PDF se firma localmente.
- **Subida del PDF firmado**: el componente local realiza un POST hacia `uploadDocumentSigned` y el sistema recibe el PDF firmado (ver [FirmaPeruSubir](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx.cs)).
- **Confirmación en UI**: la pantalla puede consultar si ya se registró la firma para el usuario/documento (polling) (ver [VerificarEstadoFirma](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/VerificarEstadoFirma.ashx)).

Este enfoque permite un despliegue web real, ya que **las llaves privadas nunca salen del dispositivo del usuario** y el servidor solo recibe el PDF ya firmado y actualiza el flujo.

## Firma desplegada (firma visible en el PDF)

La “firma desplegada” corresponde a la **firma visible** que se estampa en una posición seleccionada por el usuario dentro del PDF.

El proceso es:

1. En **Emitir firma**, el usuario activa “Posicionar Firma”.
2. El sistema muestra un visor con **PDF.js** y una caja “Firma Digital” que se puede mover y redimensionar.
3. La UI guarda en campos ocultos la posición y tamaño **en coordenadas relativas** (de 0.0 a 1.0) y la página destino.
4. Al firmar, el servidor convierte esas coordenadas relativas a coordenadas del PDF y configura la apariencia:
   - Texto de firma (titular, motivo, fecha).
   - Imagen (logo institucional) si existe.
   - Rectángulo visible en la página indicada.
5. Se ejecuta la firma PAdES en modo append para preservar firmas anteriores.

Este mecanismo permite estampar la firma en diferentes páginas y posiciones de manera consistente, independientemente del tamaño del PDF.

Nota: en el flujo de **Cliente Web Firma Perú**, la visibilidad/estilo de la firma depende de los parámetros que se entregan en [FirmaPeruParametros](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruParametros.ashx.cs) (por ejemplo `visiblePosition`). En el flujo nativo del servidor (firma con iTextSharp), la firma visible se construye con PDF.js + coordenadas relativas capturadas en [EmitirFirma](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx) y se aplica al firmar.
# SIGEFIDD-ZOFRA

