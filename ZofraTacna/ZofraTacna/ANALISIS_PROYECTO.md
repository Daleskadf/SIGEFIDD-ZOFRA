# ANÁLISIS COMPLETO - PROYECTO SIGEFIDD-ZOFRA
## Sistema de Gestión de Firma Digital de Documentos - Zona Franca de Tacna

**Fecha de Análisis:** 29 de Abril de 2026  
**Versión:** 1.0  
**Estándar:** ET-003 Rev.4 ZOFRATACNA

---

## 📋 TABLA DE CONTENIDOS
1. [Descripción General](#descripción-general)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Estructura de la Base de Datos](#estructura-de-la-base-de-datos)
4. [Modelos de Datos](#modelos-de-datos)
5. [Capas de la Aplicación](#capas-de-la-aplicación)
6. [Flujo de Procesos](#flujo-de-procesos)
7. [Servicios Externos](#servicios-externos)
8. [Estado Actual](#estado-actual)
9. [Recomendaciones](#recomendaciones)

---

## 🎯 Descripción General

**SIGEFIDD-ZOFRA** es un sistema web en **ASP.NET 4.8** que gestiona el ciclo completo de documentos con firma digital:

- **Registrador**: Carga documentos en formato PDF
- **Revisor**: Revisa documentos y emite observaciones
- **Firmante**: Aplica firma digital a documentos aprobados
- **Administrador**: Gestión de usuarios y roles del sistema

### Características Principales
✅ Gestión de documentos con PDF  
✅ Workflow de revisión y firma  
✅ Auditoria completa (historial de cambios)  
✅ Soporte para participantes múltiples  
✅ Integración con firma digital (ReFirma/Firma Perú)  
✅ Categorización por tipos de documento  
✅ Prioridad de documentos (ALTA, MEDIA, BAJA)  
✅ Límites de tiempo para revisión y aprobación  

---

## 🏗️ Arquitectura del Proyecto

### Stack Tecnológico
```
Frontend:     ASP.NET Web Forms (ASPX) + C#
Backend:      C# .NET Framework 4.8
BD:           SQL Server Express 2022 (SQLEXPRESS)
Servicios:    Componente Java ReFirma (pendiente integración)
Email:        SMTP + SQL Server Mail
Auth:         Autenticación Forms + DropDownList (simulación)
```

### Estructura de Carpetas
```
ZofraTacna/
├── Models/                      # Clases de modelo de datos
│   └── Documento.cs             # Entidades principales
├── Datos/                       # Capa de acceso a datos
│   ├── RepositorioDocumentos.cs
│   ├── RepositorioAuditoria.cs
│   └── RepositorioUsuariosRoles.cs
├── LogicaNegocio/              # Capa de lógica de negocio
│   ├── ModuloGestionDocumental.cs
│   ├── ModuloAutenticacion.cs
│   ├── ModuloFirmaDigital.cs
│   ├── ModuloRevision.cs
│   ├── ModuloAuditoria.cs
│   └── ModuloNotificaciones.cs
├── ServiciosExternos/          # Integraciones externas
│   ├── ComponenteFirma.cs      # Wrapper de ReFirma (TODO)
│   ├── ConectorSAS.cs          # Conecta con BD de administración
│   └── ServicioSMTP.cs         # Servicio de correo
├── Presentacion/               # Interfaz web (ASPX)
│   ├── Default.aspx
│   ├── Firmante.aspx
│   ├── Registrador.aspx
│   ├── Revisor.aspx
│   ├── BandejaTrabajo/
│   ├── GestionDocumentos/
│   ├── GestionRoles/
│   ├── InicioSesion/
│   └── VisualizarFirmantes/
├── Script/
│   └── Zofra-todojunto.sql    # Script completo de BD
├── Documentos/                # Almacenamiento local de PDFs
├── Web.config                 # Configuración de conexiones
└── Global.asax               # Ciclo de vida de aplicación
```

---

## 🗄️ Estructura de la Base de Datos

### 3 BASES DE DATOS PRINCIPALES

#### 1️⃣ **administracion** (BD Institucional)
Emula la BD de ZOFRATACNA. El sistema consulta esta BD via JOIN cross-database para obtener datos de empleados.

**Tablas:**
- `Empleado` - Datos de empleados institucionales

**Registro de Empleados (Seed):**
```sql
augusto   | Administrador | ADM    | augusto@zofratacna.com.pe
angel     | Vargas        | REG    | angel@zofratacna.com.pe
wsalas    | Salas, W.     | REV    | wsalas@zofratacna.com.pe
daleska   | Firmante      | FIR    | daleska@zofratacna.com.pe
```

---

#### 2️⃣ **FirmaDigital** (Core del Sistema)

**Catálogo Maestro (Configuración):**

| Tipo | Código | Descripción |
|------|--------|-------------|
| **ROL_SISTEMA** | ADM | Administrador |
| | REG | Registrador |
| | REV | Revisor |
| | FIR | Firmante |
| **ESTADO_DOC** | REG | Registrado |
| | REV | En Revisión |
| | OBS | Observado |
| | PEN | Pendiente de Firma |
| | FPAR | Firma Parcial |
| | FCOM | Firmado Completo |
| **TIPO_DOC** | MEM | Memorando |
| | OFI | Oficio |
| | RES | Resolución |
| | INF | Informe |
| | ACT | Acta |
| | CON | Contrato |
| | DIR | Directiva |
| | CIR | Circular |
| | PLA | Plan |
| | PRO | Procedimiento |
| **ESTADO_PARTICIPANTE** | PEN | Pendiente |
| | REV | En Revisión |
| | OBS | Observado |
| | FIR | Firmado |

**Tablas Principales:**

```
Maestro
├── IdMaestro (PK)
├── Tipo (Catálogo)
├── Codigo (Valor)
├── Descripcion
├── Orden
├── Activo
└── Auditoria (Usuario/Fecha)

UsuarioSistema
├── IdUsuario (PK)
├── LoginUsuario (UNIQUE)
├── Password (NULL - simulación)
├── IdRolSistema (FK → Maestro)
├── Activo
└── Auditoria

Documento (TABLA PRINCIPAL)
├── IdDocumento (PK)
├── CodigoDocumento (UNIQUE)
├── Asunto
├── IdTipoDocumento (FK → Maestro)
├── AreaResponsable
├── AreaCategoria
├── LoginUsuarioRegistrador
├── RutaArchivoPDF
├── RutaArchivoPDF_Firmado
├── IdArchivoPrincipal (FK → FirmaDigital_Files)
├── IdEstadoDocumento (FK → Maestro)
├── NumeroRevisionActual (DEFAULT 1)
├── Prioridad (ALTA/MEDIA/BAJA)
├── FechaCreacion
├── FechaLimiteRevision
├── FechaLimiteAprobacion
├── TieneArchivo (BIT)
├── Activo
└── Auditoria

DocumentoParticipante
├── IdParticipante (PK)
├── IdDocumento (FK)
├── LoginUsuario
├── CorreoInstitucional
├── OrdenSecuencial (orden de firma)
├── IdTipoParticipante (FK → Maestro: REV/FIR)
├── EstadoParticipante (FK → Maestro)
├── FechaAsignacion
└── Auditoria

RevisionDetalle
├── IdRevision (PK)
├── IdParticipante (FK)
├── Comentario
├── NumeroRevision (DEFAULT 1)
├── EsObservacion (BIT)
├── FechaRevision
└── Auditoria

FirmaDetalle
├── IdFirma (PK)
├── IdParticipante (FK)
├── IdEstadoFirma (FK → Maestro)
├── FirmaDigitalHash (token de ReFirma)
├── FechaFirma
└── Auditoria

HistorialDocumento (AUDITORIA)
├── IdHistorial (PK)
├── IdDocumento (FK)
├── IdEstadoAnterior (FK → Maestro, NULL en creación)
├── IdEstadoNuevo (FK → Maestro)
├── LoginUsuarioAccion
├── DetalleAccion
├── FechaCambio
└── Auditoria

LogErrorSistema
├── IdLog (PK)
├── Capa (Presentación|Negocio|Datos|ServiciosExternos)
├── MensajeError
├── DetalleStacktrace
├── LoginUsuario
└── FechaError
```

**Vistas:**
- `VW_EmpleadosActivos` - JOIN cross-database con `administracion.dbo.Empleado`

**Procedimientos Almacenados:**
- `sp_InsertarParticipante(@IdDocumento, @LoginUsuario, @IdTipoParticipante)` - Inserta revisores/firmantes
- `GEN_X_EnviarMail(@Para, @Asunto, @Mensaje, @Adjunto)` - Envío de correos vía Database Mail

---

#### 3️⃣ **FirmaDigital_Files** (Repositorio de PDFs)

Almacena archivos PDF en `VARBINARY(MAX)` para mantener todo dentro del servidor SQL sin dependencia del sistema de archivos.

```
DocumentoAdjunto
├── IdAdjunto (PK)
├── IdDocumento
├── NombreArchivo
├── ContentType
├── TamanoBytes
├── ContenidoPDF (VARBINARY(MAX))
├── EsOriginal (BIT)
├── FechaSubida
└── Auditoria
```

---

## 📊 Modelos de Datos

### Clases C# Principales

```csharp
// Documento.cs
public class Documento
{
    public int      IdDocumento
    public string   CodigoDocumento
    public string   Asunto
    public string   Descripcion
    public int      IdTipoDocumento
    public string   AreaResponsable
    public string   AreaCategoria
    public string   Prioridad              // ALTA/MEDIA/BAJA
    public DateTime FechaCreacion
    public string   LoginUsuarioRegistrador
    public string   RutaArchivoPDF
    public string   RutaArchivoPDF_Firmado
    public int      IdEstadoDocumento
    public DateTime FechaLimiteRevision
    public DateTime FechaLimiteAprobacion
    public bool     Activo
}

public class RegistrarDocumentoRequest
{
    public string CodigoDocumento
    public string Asunto
    public string Descripcion
    public int    IdTipoDocumento
    public string Prioridad
    public int    HorasRevision
    public int    HorasFirma
    public List<RegistrarParticipanteItem> Participantes
    public byte[] ContenidoPDF
    public string NombreArchivoPDF
}

public class RegistrarParticipanteItem
{
    public string Login  // usuario que revisa o firma
    public string Tipo   // REV | FIR
    public int    Orden  // secuencia de firma
}

public class DocumentoAdjunto
{
    public int      IdAdjunto
    public int      IdDocumento
    public string   NombreArchivo
    public string   ContentType
    public int      TamanoBytes
    public byte[]   ContenidoPDF
    public bool     EsOriginal
    public DateTime FechaSubida
}
```

---

## 🧩 Capas de la Aplicación

### 1. CAPA DE PRESENTACIÓN (Presentacion/)

**Páginas ASP.NET Web Forms:**

| Página | Propósito | Rol |
|--------|-----------|-----|
| **Default.aspx** | Dashboard principal | ADM |
| **Firmante.aspx** | Interfaz de firmante | FIR |
| **Registrador.aspx** | Interfaz de registrador | REG |
| **Revisor.aspx** | Interfaz de revisor | REV |
| **BandejaTrabajo/BandejaTrabajo.aspx** | Tareas pendientes | REV/FIR |
| **GestionDocumentos/CargarDocumento.aspx** | Cargar PDF | REG |
| **GestionDocumentos/MisDocumentos.aspx** | Listar docs del usuario | REG |
| **GestionDocumentos/Historial.aspx** | Historial de cambios | ALL |
| **GestionRoles/GestionRoles.aspx** | Gestión de usuarios | ADM |
| **InicioSesion/Login.aspx** | Autenticación (simulada) | ALL |
| **VisualizarFirmantes/VisualizarFirmantes.aspx** | Ver lista de firmantes | REV/FIR |

**Autenticación:**
```csharp
<authentication mode="Forms">
  <forms loginUrl="~/Presentacion/InicioSesion/Login.aspx" 
         defaultUrl="~/Presentacion/Default.aspx" 
         timeout="30"/>
</authentication>
```

---

### 2. CAPA DE LÓGICA DE NEGOCIO (LogicaNegocio/)

```csharp
ModuloGestionDocumental
├── ObtenerDocumentosPorUsuario(login)
├── RegistrarDocumento(Documento)
└── ActualizarEstado(idDoc, idEstado, login, detalle)

ModuloAutenticacion
├── AutenticarUsuario(login)
├── ObtenerRolUsuario(login)
└── ValidarPermisos(login, recurso)

ModuloFirmaDigital
├── RegistrarFirma(idParticipante, hashFirma)
└── GenerarHash(rutaPDF)

ModuloRevision
├── AgregarComentario(idParticipante, comentario)
├── AgregarObservacion(idParticipante, observacion)
└── ObtenerRevisionesPendientes(login)

ModuloAuditoria
├── InsertarHistorial(idDoc, estadoAnterior, estadoNuevo, login, detalle)
├── InsertarLogError(capa, mensaje, stackTrace, login)
└── ObtenerHistorialDocumento(idDoc)

ModuloNotificaciones
├── NotificarRevision(idDoc, loginRevisor)
├── NotificarFirma(idDoc, loginFirmante)
└── NotificarObservaciones(idDoc, loginRegistrador)
```

---

### 3. CAPA DE DATOS (Datos/)

```csharp
RepositorioDocumentos
├── LECTURA
│   ├── ObtenerPorRegistrador(login)
│   ├── ObtenerPorRevisor(login)
│   ├── ObtenerPorFirmante(login)
│   ├── ObtenerParticipantes(idDoc)
│   └── ObtenerHistorial(idDoc)
├── INSERCIÓN
│   ├── Insertar(Documento)
│   ├── InsertarDocumentoConParticipantes(request, login)
│   ├── InsertarParticipante(idDoc, loginUsuario, idTipo)
│   └── InsertarRevision(idParticipante, comentario)
└── ACTUALIZACIÓN
    ├── ActualizarEstado(idDoc, idEstado, login, detalle)
    └── InsertarFirma(FirmaDetalle)

RepositorioAuditoria
├── InsertarHistorial(HistorialDocumento)
└── InsertarLogError(capa, mensaje, stackTrace, login)

RepositorioUsuariosRoles
├── ObtenerTodos()
├── CambiarEstado(idUsuario, activo)
└── ObtenerEmpleadosActivos()
```

---

### 4. SERVICIOS EXTERNOS (ServiciosExternos/)

```csharp
ComponenteFirma (PENDIENTE INTEGRACIÓN)
├── FirmarDocumento(rutaPDF, certificado) → ResultadoFirma
├── ValidarFirma(rutaPDFFirmado) → bool
└── ResultadoFirma { Exitoso, Mensaje, HashFirma }

ConectorSAS
├── ObtenerEmpleadosActivos() → List<EmpleadoSASDto>
└── SincronizarRoles()

ServicioSMTP
├── EnviarCorreo(para, asunto, cuerpo)
├── EnviarCorreoHtml(para, asunto, cuerpoHtml)
└── EnviarCorreoConAdjunto(para, asunto, cuerpo, rutaArchivo)
```

---

## 🔄 Flujo de Procesos

### 1. WORKFLOW DE UN DOCUMENTO

```
[REGISTRADOR carga documento PDF]
                ↓
        [Estado: REG - Registrado]
                ↓
    [Inserta participantes: Revisores]
                ↓
        [Estado: REV - En Revisión]
                ↓
[REVISOR emite comentarios/observaciones]
                ↓
        ┌───────┴────────┐
        ↓                ↓
   [Aprobado]     [Con Observaciones]
        ↓                ↓
   [Estado: PEN]   [Estado: OBS]
   [Pendiente]           ↓
        ↓        [REGISTRADOR corrige]
        ↓                ↓
        └────────┬───────┘
                 ↓
        [Estado: PEN]
        [Pendiente de Firma]
                 ↓
    [Inserta participantes: Firmantes]
                 ↓
    [FIRMANTE aplica firma digital]
                 ↓
        [Estado: FPAR]
        [Firma Parcial]
                 ↓
        [¿Todos firmaron?]
                 ↓
        ┌────────┴────────┐
        ↓                 ↓
      NO                 SI
        ↓                 ↓
   [Esperar]        [Estado: FCOM]
                    [Firmado Completo]
                            ↓
                        [FIN]
```

---

### 2. ESTADO DE PARTICIPANTE

```
Cuando se asigna un revisor/firmante:
    Estado: PEN (Pendiente)
            ↓
    Inicia revisión: REV (En Revisión)
            ↓
    ┌───────┴────────┐
    ↓                ↓
[Aprueba]      [Observa]
    ↓                ↓
  [FIR]            [OBS]
[Firmado]      [Observado]
```

---

## 🔌 Servicios Externos

### Firma Digital (PENDIENTE INTEGRACIÓN)
**Estado Actual:** Stub/Mock
```csharp
public ResultadoFirma FirmarDocumento(string rutaPDF, string certificado)
{
    // TODO: Invocar componente Java via proceso externo o WebService
    return new ResultadoFirma { Exitoso = false, Mensaje = "Componente no integrado aun." };
}
```

**Próxima Integración:**
- Componente: **ReFirma** (Open Source) o **Firma Perú**
- Protocolo: WebService SOAP o REST
- Entrada: PDF bytes
- Salida: FirmaDigitalHash (token/Hash de firma)

### Correo (Database Mail)
```sql
EXEC msdb.dbo.sp_send_dbmail 
    @profile_name = 'Administrador SQL',
    @recipients = @Para, 
    @subject = @Asunto, 
    @body = @Mensaje,
    @body_format = 'HTML',
    @file_attachments = @Adjunto;
```

### BD Institucional (administracion)
JOIN cross-database para sincronizar empleados:
```sql
CREATE VIEW dbo.VW_EmpleadosActivos AS
    SELECT * FROM administracion.dbo.Empleado
    WHERE ActivoAsist = 1;
```

---

## 📈 Estado Actual

### ✅ COMPLETADO
- ✓ Estructura de BD (3 bases de datos)
- ✓ Tablas y relaciones
- ✓ Catálogo maestro (roles, estados, tipos)
- ✓ Autenticación simulada (DropDownList)
- ✓ Capa de datos con ADO.NET
- ✓ Módulos de negocio básicos
- ✓ Interfaz web (ASPX)
- ✓ Auditoria (historial de cambios)
- ✓ Configuración de conexiones

### 🔨 EN DESARROLLO / PENDIENTE
- ⏳ Integración con componente de firma digital (ReFirma)
- ⏳ Validación de firmas
- ⏳ Configuración Database Mail (SMTP)
- ⏳ Notificaciones por correo
- ⏳ Interfaz de firmantes mejorada
- ⏳ Reportes y estadísticas
- ⏳ Gestión de certificados

### ⚠️ PROBLEMAS IDENTIFICADOS
1. **ComponenteFirma.cs** - Solo es un stub, sin lógica real
2. **Database Mail** - No configurado en SQL Server
3. **Permisos de Roles** - Falta implementación granular
4. **Validación de Entrada** - Podría mejorar sanitización

---

## 💡 Recomendaciones

### CORTO PLAZO (Semanas)
1. **Integrar Firma Digital**
   - Evaluar ReFirma vs Firma Perú
   - Implementar WebService wrapper
   - Pruebas de integración

2. **Configurar Notificaciones**
   - Setup Database Mail en SQL Server
   - Implementar templates de correo
   - Pruebas de envío

3. **Mejorar Seguridad**
   - Implementar autenticación real (no simulada)
   - Hash de contraseñas (BCrypt/PBKDF2)
   - Validación CSRF
   - Sanitización de entrada

### MEDIANO PLAZO (Meses)
1. **Refactoring a N-Capas Modern**
   - Migrar a Entity Framework Core
   - Implementar Repository Pattern
   - Dependency Injection

2. **Testing**
   - Unit tests (xUnit)
   - Integration tests
   - Cobertura >80%

3. **Documentación**
   - API documentation
   - User manual
   - Administrator guide

### LARGO PLAZO (Trimestres)
1. **Modernización Tecnológica**
   - ASP.NET Core (dotnet 8+)
   - React/Angular frontend
   - REST API

2. **Escalabilidad**
   - Microservicios
   - Caching (Redis)
   - Message Queue (RabbitMQ)

3. **DevOps**
   - CI/CD (GitHub Actions)
   - Docker containerization
   - Cloud deployment (Azure/AWS)

---

## 📚 Conclusión

SIGEFIDD-ZOFRA es un sistema **bien estructurado** con:
- ✅ Arquitectura clara en 3 capas
- ✅ Base de datos normalizada
- ✅ Flujos de negocio bien definidos
- ✅ Auditoria completa
- ⏳ Necesita integración de firma digital para producción
- ⏳ Requiere hardening de seguridad

El proyecto está en etapa **beta-funcional** y listo para pilotaje con las mejoras mencionadas arriba.

---

**Documento elaborado automáticamente**  
**Última actualización:** 2026-04-29  
**Próxima revisión recomendada:** 2026-06-30
