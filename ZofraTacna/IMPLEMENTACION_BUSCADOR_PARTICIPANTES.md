# ?? IMPLEMENTACIÓN: Buscador y Asignación de Participantes - CargarDocumento.aspx

## ? Resumen de Cambios Realizados

### 1. **Nueva Interfaz de Usuario (CargarDocumento.aspx)**
   - ? **Buscador con Autocomplete**: Campo de texto que busca empleados en tiempo real mientras escribes
   - ?? **Dos Columnas Visuales**:
     - **Columna Izquierda**: "REVISORES" - Sin orden de ejecución
     - **Columna Derecha**: "FIRMANTES" - Con selector de orden de firma
   - ??? **Tags de Participantes**: Cada empleado asignado aparece como etiqueta con botón (×) para eliminar
   - ?? **Entrada de Orden para Firmantes**: Campo numérico editable para establecer el orden secuencial de firma

### 2. **Backend - Gestor de Empleados (BuscadorEmpleados.ashx)**
   - Nuevo handler ASHX que retorna empleados en formato JSON
   - Búsqueda por nombre o login (case-insensitive)
   - Máximo 20 resultados por búsqueda
   - Incluye badge "Nuevo" para empleados que no están en el sistema

### 3. **Modelos Actualizados (Documento.cs)**
   ```csharp
   public class EmpleadoDTO
   {
       - IDEmpleado
       - LoginUsuario
       - Nombre, Apellido, NombreCompleto
       - Email
       - EnSistema (bool) // Si ya existe en UsuarioSistema
   }

   public class ParticipanteAsignadoDTO
   {
       - LoginUsuario
       - NombreCompleto
       - Tipo (REV | FIR)
       - Orden
   }
   ```

### 4. **Repositorio de Usuarios Actualizado (RepositorioUsuariosRoles.cs)**
   **Nuevos Métodos:**
   - `ObtenerEmpleadosConEstado()`: Obtiene todos los empleados con info de si están en UsuarioSistema
   - `ObtenerIdRolRevisor()`: Obtiene el ID del rol Revisor desde Maestro
   - `AgregarUsuarioSistemaComoRevisor()`: Agrega automáticamente un empleado como Revisor si no existe

### 5. **Módulo de Negocio Actualizado (ModuloGestionDocumental.cs)**
   **Nuevos Métodos:**
   - `ObtenerEmpleadosDisponibles()`: Devuelve lista de empleados para el buscador
   - `AgregarEmpleadoComoRevisor()`: Wrapper para agregar empleado al sistema

### 6. **Code-Behind Refactorizado (CargarDocumento.aspx.cs)**
   **Métodos Eliminados:**
   - `btnAgregarFirmante_Click()` ?
   - `rptFirmantes_ItemCommand()` ?
   - `BindFirmantes()` ?
   - Referencia a `ddlFirmante` ?

   **Nuevos Métodos:**
   - `AgregarEmpleado()` - WebMethod para registrar empleado en UsuarioSistema
   - `btnCargar_Click()` - **Completamente refactorizado** para procesar JSON de participantes

   **Flujo Actualizado:**
   1. Validación de participantes desde JSON (campo oculto `hfParticipantes`)
   2. Separación de revisores y firmantes
   3. Preservación del orden de firmantes
   4. Registro en BD con transacción completa

### 7. **JavaScript Completo (CargarDocumento.aspx)**
   **Funciones Principales:**
   - `fetch(BuscadorEmpleados.ashx)` - Búsqueda autocomplete en tiempo real
   - `mostrarDialogoTipo()` - Modal para elegir rol (Revisor o Firmante)
   - `agregarParticipante()` - Añade empleado a lista temporal
   - `renderizarParticipantes()` - Redibuja las dos columnas
   - `actualizarOrden()` - Gestiona el orden de firmantes
   - `guardarParticipantes()` - Serializa a JSON en campo oculto
   - `removerRevisor()` / `removerFirmante()` - Elimina participantes

### 8. **Estilos CSS Nuevos**
   ```css
   .empleado-resultado     - Opción en dropdown autocomplete
   .empleado-nombre        - Nombre en negrita
   .empleado-login         - Login en gris
   .badge-novedad          - "Nuevo" para empleados sin rol
   .participante-tag       - Etiqueta de empleado asignado
   .orden-input            - Campo de entrada numérica para orden
   .drop-zone-active       - Zona de arrastre activa
   ```

---

## ??? **Cambios en Base de Datos**

### BD: `FirmaDigital`
- **Tabla `administracion.dbo.Empleado`** (cross-database JOIN)
  - Se consulta para obtener empleados activos (`ActivoAsist = 1`)

- **Tabla `UsuarioSistema`**
  - Se INSERT automáticamente cuando se selecciona un empleado
  - Se asigna por defecto el rol "Revisor" (REV)

- **Tabla `Maestro`**
  - Se consulta para obtener `ROL_SISTEMA.REV` al crear usuario

---

## ?? **Flujo de Ejecución**

```
1. Usuario abre CargarDocumento.aspx
   ?
2. Escribe en el buscador (ej: "Angel")
   ?
3. fetch() llama a BuscadorEmpleados.ashx?q=Angel
   ?
4. Handler retorna JSON con empleados que coinciden
   ?
5. JavaScript renderiza dropdown con resultados
   ?
6. Usuario hace click en un empleado
   ?
7. Modal pregunta: ¿Revisor o Firmante?
   ?
8. Se llama AgregarEmpleado() WebMethod (background)
   ?
9. Se agrega a UsuarioSistema como Revisor (si no existe)
   ?
10. Empleado aparece como tag en columna seleccionada
    ?
11. Si es FIRMANTE: apareceentrada de orden editable
    ?
12. Usuario puede eliminar con botón (×)
    ?
13. Al hacer click "Cargar Documento":
    - Se valida JSON de participantes
    - Se registra el documento
    - Se asignan todos los participantes
```

---

## ?? **Datos Guardados en BD**

### Tabla: `Documento`
- Documento se crea una sola vez con metadatos

### Tabla: `DocumentoParticipante`
Para cada participante (revisor o firmante):
```sql
INSERT INTO DocumentoParticipante
(
    IdDocumento,
    LoginUsuario,
    OrdenSecuencial,    -- 0 para revisores, 1,2,3... para firmantes
    IdTipoParticipante, -- REV o FIR (IDs del Maestro)
    EstadoParticipante, -- PEN (Pendiente, por defecto)
    CorreoInstitucional
)
```

### Tabla: `UsuarioSistema` (si no existe el usuario)
```sql
INSERT INTO UsuarioSistema
(
    LoginUsuario,
    Password,              -- NULL (modo simulación)
    IdRolSistema,          -- ID del rol REV (Revisor)
    Activo,                -- 1
    IDUsuarioCreador       -- 'SISTEMA'
)
```

---

## ?? **Ventajas de la Nueva Implementación**

? **Búsqueda Rápida**: No necesita dropdown precargado, busca en tiempo real
? **Interfaz Clara**: Dos columnas separan conceptualmente revisores de firmantes
? **Gestión de Orden**: Entrada numérica intuitiva para ordenar firmantes
? **Auto-registro**: Los empleados se agregan automáticamente a UsuarioSistema
? **Validación JSON**: Datos pasados al servidor en formato JSON estructurado
? **Sin Postbacks Innecesarios**: Todo se maneja con JavaScript + un único click final
? **Responsive**: Se adapta a diferentes anchos de pantalla

---

## ?? **Configuración Requerida**

1. **Session**: Usuario debe estar autenticado
2. **Base de Datos**: Las 3 BDs deben estar disponibles
3. **JavaScript**: Habilitado en navegador (fetch API)
4. **Maestro**: Debe existir rol `REV` en Maestro (Revisor)

---

## ?? **Pruebas Recomendadas**

1. ? Buscar empleado por nombre
2. ? Buscar empleado por login
3. ? Seleccionar como Revisor
4. ? Seleccionar como Firmante
5. ? Establecer orden de firmantes (1, 2, 3)
6. ? Cambiar orden de firmantes
7. ? Eliminar participante
8. ? Guardar documento con múltiples participantes
9. ? Verificar que se creó en UsuarioSistema
10. ? Verificar orden en DocumentoParticipante

---

## ?? **Archivos Modificados**

| Archivo | Cambios |
|---------|---------|
| `Models/Documento.cs` | +2 DTOs nuevos |
| `Datos/RepositorioUsuariosRoles.cs` | +3 métodos |
| `LogicaNegocio/ModuloGestionDocumental.cs` | +2 métodos, 1 field |
| `Presentacion/GestionDocumentos/CargarDocumento.aspx` | ? Nueva interfaz + JS |
| `Presentacion/GestionDocumentos/CargarDocumento.aspx.cs` | ?? Refactorizado |
| `Presentacion/GestionDocumentos/CargarDocumento.aspx.designer.cs` | +1 control |
| `Presentacion/GestionDocumentos/BuscadorEmpleados.ashx` | ? NUEVO |
| `Presentacion/GestionDocumentos/BuscadorEmpleados.ashx.cs` | ? NUEVO |

---

## ?? **Próximos Pasos (Sugerencias)**

- [ ] Agregar validación de duplicados en frontend
- [ ] Agregar arrastre y suelta (drag & drop) para reordenar
- [ ] Agregar notificación visual cuando se carga empleado
- [ ] Agregar búsqueda por email también
- [ ] Agregar spinner de loading durante la búsqueda
- [ ] Agregar confirmación antes de eliminar participante

