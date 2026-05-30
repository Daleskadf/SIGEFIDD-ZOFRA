# SIGEFIDD-ZOFRA

## ¿Qué hace el sistema?

SIGEFIDD-ZOFRA (Sistema de Gestión de Firma Digital de Documentos) es una aplicación web para **gestionar el ciclo completo de documentos PDF** dentro de ZOFRATACNA, desde el registro y revisión hasta la emisión de firmas digitales y la trazabilidad del proceso.

- Registro y carga de documentos (PDF).
- Asignación de participantes (revisores y firmantes).
- Flujo de revisión con observaciones y correcciones.
- Emisión de firma digital (PAdES) con soporte de firma visible (posicionamiento en el PDF).
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

- **Presentación** ([Presentacion/](ZofraTacna/ZofraTacna/Presentacion/)): páginas ASPX y handlers ASHX. Maneja UI, navegación, endpoints HTTP (descargas/subidas) y el visor PDF (incluye PDF.js en la pantalla de firma).
- **Lógica de negocio** ([LogicaNegocio/](ZofraTacna/ZofraTacna/LogicaNegocio/)): módulos que orquestan el flujo (revisión/firma) y delegan persistencia al repositorio.
- **Datos** ([Datos/](ZofraTacna/ZofraTacna/Datos/)): acceso a datos con ADO.NET (SQL Server). Contiene repositorios y procedimientos para adjuntos, firmas, auditoría y cambios de estado.
- **Modelos** ([Models/](ZofraTacna/ZofraTacna/Models/)): entidades del dominio (por ejemplo, [Documento](ZofraTacna/ZofraTacna/Models/Documento.cs)).
- **Servicios externos** ([ServiciosExternos/](ZofraTacna/ZofraTacna/ServiciosExternos/)): integraciones (correo y conectores). Existe un wrapper para Firma Perú pendiente/mixto según el flujo.

**Tecnologías relevantes:**

- **SQL Server** como base de datos (cadena `FirmaDigital` en configuración).
- **iTextSharp** + **BouncyCastle** para firma PDF (PAdES) y criptografía.
- **PDF.js** para el visor y posicionamiento de la firma visible.

**Componentes clave (rutas/archivos):**

- Pantalla de firma: [EmitirFirma.aspx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx) + [EmitirFirma.aspx.cs](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx.cs).
- Visor/servido de PDF: [ServirPdf.ashx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/ServirPdf.ashx) + [ServirPdf.ashx.cs](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/ServirPdf.ashx.cs).
- Descarga para firma por agente: [DescargaDocumentoTemporal.ashx.cs](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/DescargaDocumentoTemporal.ashx.cs).
- Subida de PDF firmado (agente / Firma Perú): [FirmaPeruSubir.ashx.cs](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx.cs).
- Polling de estado de firma: [VerificarEstadoFirma.ashx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/VerificarEstadoFirma.ashx).
- Orquestación del flujo (incluye actualización de estado al firmar): [ModuloGestionDocumental](ZofraTacna/ZofraTacna/LogicaNegocio/ModuloGestionDocumental.cs).
- Persistencia de adjuntos/historial y firma: [RepositorioDocumentos](ZofraTacna/ZofraTacna/Datos/RepositorioDocumentos.cs).

## ¿Cómo realiza la firma digital?

El sistema contempla distintos caminos para firmar un PDF, pero todos convergen en lo mismo:

- Se genera/obtiene un **PDF firmado** (PAdES).
- Se guarda el archivo actualizado en la base de datos (adjunto principal/historial o adjunto firmado).
- Se registra la firma en el flujo (tabla de detalle de firma) y se actualiza el estado del documento (PEN → FPAR → FCOM).

## ¿Cómo realiza la firma en la página web? (paso a paso)

La firma se ejecuta desde la pantalla [EmitirFirma.aspx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx) y combina 2 partes: **posicionamiento de la firma visible** en el navegador y **firma criptográfica** (en servidor o en el equipo del usuario, según el método).

### 1) Posicionamiento de firma visible (PDF.js en el navegador)

1. La página muestra el PDF (iframe) y permite activar “Posicionar Firma”.
2. Al activar el modo de posicionamiento, se renderiza el PDF con PDF.js y aparece un recuadro “Firma Digital” movible/redimensionable.
3. Antes de firmar, JavaScript calcula y guarda en campos ocultos:
   - Página destino (`hfFirmaPage`)
   - Coordenadas y tamaño relativos al canvas (0.0 a 1.0): `hfFirmaX`, `hfFirmaY`, `hfFirmaW`, `hfFirmaH`
   - Rotación (`hfFirmaRot`)
4. El servidor usa esos valores para estampar la firma visible en la página y posición exactas del PDF.

### 2) Firma criptográfica (métodos disponibles)

En el modal “Opciones de Firma” existen dos enfoques principales:

#### A) Firma nativa (server-side) con certificado del almacén Windows

En este flujo, al hacer postback (botones “Firmar con DNIe” / “Firmar con Token USB”), el servidor:

1. Obtiene el PDF desde la BD (adjunto principal).
2. Firma con iTextSharp en modo **append** para preservar firmas previas: `PdfStamper.CreateSignature(..., append:true)`.
3. Configura la apariencia visible de la firma (texto + logo) y el rectángulo usando las coordenadas guardadas en los hidden fields (ver `ConfigurarAparienciaFirma`).
4. Guarda el PDF resultante en BD con historial (`ReemplazarPdfConHistorial`) y registra la firma/estado del flujo (`RegistrarFirmaConEstado`).

Archivos principales:

- UI y captura de coordenadas: [EmitirFirma.aspx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx) (función `prepararFirma()`).
- Firma PAdES y sello visible: [EmitirFirma.aspx.cs](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/EmitirFirma.aspx.cs) (métodos `btnFirmarDnie_Click`, `btnFirmarUsb_Click`, `ConfigurarAparienciaFirma`).

Notas:

- DNIe: se filtran certificados de RENIEC con uso de No Repudio y se firma con RSA o ECDSA según el tipo de clave (implementaciones `LegacySmartCardSignature` y `ModernCngSignature`).
- Token USB: firma con `X509Certificate2Signature` (SHA-256).

#### B) Firma con agente local (client-side) para Token USB (ZofraTacna Signer)

Este flujo está pensado para firmar en el **equipo del usuario** (donde está el token), usando un agente local. La página:

1. Construye un JSON con URLs de descarga/subida y un `token` del documento.
2. Lo codifica a Base64 y abre un esquema de URL personalizado: `zofratacna://{base64}`.
3. El agente descarga el PDF desde [DescargaDocumentoTemporal.ashx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/DescargaDocumentoTemporal.ashx.cs), firma localmente y sube el PDF firmado a [FirmaPeruSubir.ashx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx.cs).
4. La web consulta periódicamente [VerificarEstadoFirma.ashx](ZofraTacna/ZofraTacna/Presentacion/BandejaTrabajo/VerificarEstadoFirma.ashx) hasta detectar que el documento ya registra firma.


## Firma desplegada (firma visible en el PDF)

La “firma desplegada” corresponde a la **firma visible** que se estampa en una posición seleccionada por el usuario dentro del PDF.

El proceso es:

1. En **Emitir firma**, el usuario activa “Posicionar Firma”.
2. El sistema muestra un visor con **PDF.js** y una caja “Firma Digital” que se puede mover y redimensionar.
3. La UI guarda la posición y tamaño **en coordenadas relativas** (de 0.0 a 1.0) y la página destino.
4. Al firmar, el servidor convierte esas coordenadas relativas a coordenadas del PDF y configura la apariencia (texto/imagen) y el rectángulo visible.
5. Se ejecuta la firma PAdES en modo **append** para preservar firmas anteriores.

Este mecanismo permite estampar la firma en diferentes páginas y posiciones de manera consistente, independientemente del tamaño del PDF.

