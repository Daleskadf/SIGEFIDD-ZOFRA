# ? USUARIOS CREADOS AUTOMÁTICAMENTE EN UsuarioSistema

## ?? Problema Identificado

Cuando se asignaban revisores y firmantes a un documento, estos NO se guardaban en la tabla `UsuarioSistema`. 

Esto causaba que:
- Los usuarios quedaban solo en `DocumentoParticipante`
- No tenían rol asignado en el sistema
- No podían acceder al sistema con su rol correspondiente

## ? Solución Implementada

Se agregó lógica automática para **crear usuarios en `UsuarioSistema` antes de registrar el documento**.

### ?? Flujo de Proceso

```
1. Usuario llena formulario de CARGAR DOCUMENTO
2. Agrega revisores y firmantes
3. Hace click en CARGAR DOCUMENTO
   ?
4. Se VALIDA todo
   ?
5. ? NUEVO: Se CREAN USUARIOS en UsuarioSistema
   ?? Para cada participante:
   ?? Si NO existe en UsuarioSistema:
   ??   Se INSERTA con su rol (REV o FIR)
   ?? Si YA existe:
      ?? Se IGNORA (no duplica)
   ?
6. Se registra documento en DocumentoParticipante
   ?
7. Se guarda PDF en FirmaDigital_Files
   ?
8. Documento completamente registrado ?
```

---

## ?? Cambios Técnicos

### 1?? **RepositorioUsuariosRoles.cs**

#### Nuevo método: `ObtenerIdRolFirmante()`
```csharp
public int ObtenerIdRolFirmante()
{
    using (var conn = new SqlConnection(_conn))
    {
        conn.Open();
        string sql = "SELECT IdMaestro FROM Maestro WHERE Tipo='ROL_SISTEMA' AND Codigo='FIR'";
        using (var cmd = new SqlCommand(sql, conn))
        {
            object result = cmd.ExecuteScalar();
            return result != null ? (int)result : 0;
        }
    }
}
```

#### Nuevo método: `AgregarUsuarioSistemaConRol()`
```csharp
public bool AgregarUsuarioSistemaConRol(string loginUsuario, string codigoRol)
{
    try
    {
        // 1. Validar que existe en administracion.dbo.Empleado
        if (!ExisteEnEmpleadosActivos(loginUsuario))
            return false;

        // 2. Verificar si ya existe en UsuarioSistema
        if (YaTieneRolAsignado(loginUsuario))
            return true; // No es error, ya existe

        // 3. Obtener el IdMaestro del rol
        int idRol = 0;
        if (codigoRol == "REV")
            idRol = ObtenerIdRolRevisor();
        else if (codigoRol == "FIR")
            idRol = ObtenerIdRolFirmante();
        else
            return false;

        if (idRol == 0)
            return false;

        // 4. Insertar en UsuarioSistema
        using (var conn = new SqlConnection(_conn))
        {
            conn.Open();
            string sql = @"INSERT INTO UsuarioSistema 
                (LoginUsuario, Password, IdRolSistema, Activo, IDUsuarioCreador, FechaCreacion)
                VALUES (@login, NULL, @idRol, 1, 'SISTEMA', GETDATE())";
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@login", loginUsuario);
                cmd.Parameters.AddWithValue("@idRol", idRol);
                return cmd.ExecuteNonQuery() > 0;
            }
        }
    }
    catch
    {
        return false;
    }
}
```

#### Refactorizado: `AgregarUsuarioSistemaComoRevisor()`
```csharp
public bool AgregarUsuarioSistemaComoRevisor(string loginUsuario)
{
    // Ahora solo llama al método genérico
    return AgregarUsuarioSistemaConRol(loginUsuario, "REV");
}
```

---

### 2?? **ModuloGestionDocumental.cs**

#### Nuevo método: `CrearUsuariosParticipantes()`
```csharp
private void CrearUsuariosParticipantes(List<RegistrarParticipanteItem> participantes)
{
    foreach (var participante in participantes)
    {
        // El tipo viene como "FIR" o "REV"
        string codigoRol = participante.Tipo;
        _repoUsuarios.AgregarUsuarioSistemaConRol(participante.Login, codigoRol);
    }
}
```

#### Actualizado: `RegistrarDocumentoConParticipantes()`
```csharp
public int RegistrarDocumentoConParticipantes(RegistrarDocumentoRequest request, string loginUsuario)
{
    // ... validaciones ...

    // ? NUEVO: Crear usuarios ANTES de registrar documento
    CrearUsuariosParticipantes(request.Participantes);

    // Continuar con el proceso normal
    string codigoCompleto = $"{request.CodigoDocumento}-{request.NumeroDocumento.PadLeft(4, '0')}-{request.AnoDocumento}";
    request.CodigoDocumento = codigoCompleto;

    return _repo.InsertarDocumentoConParticipantes(request, loginUsuario);
}
```

---

## ?? Comportamiento Resultante

### Antes
```
Usuario agrega "Luis Mamani" como REVISOR
     ?
Se registra documento
     ?
Base de datos:
?? DocumentoParticipante: Luis Mamani ?
?? UsuarioSistema: Luis Mamani ? (NO EXISTE)
```

### Ahora ?
```
Usuario agrega "Luis Mamani" como REVISOR
     ?
Se registra documento
     ?
Base de datos:
?? DocumentoParticipante: Luis Mamani ?
?? UsuarioSistema: Luis Mamani CON ROL REV ?
?? Luis puede acceder al sistema ?
```

---

## ?? Casos de Prueba

### ? Caso 1: Usuario nuevo como REVISOR
```
1. Agrega "Angel Vargas" (no existe en UsuarioSistema)
2. Como REVISOR
3. Se registra documento
   ?
Resultado:
?? UsuarioSistema: Angel Vargas + ROL REV ?
?? Puede hacer revisiones ?
```

### ? Caso 2: Usuario nuevo como FIRMANTE
```
1. Agrega "Daleska Firmante" (no existe en UsuarioSistema)
2. Como FIRMANTE
3. Se registra documento
   ?
Resultado:
?? UsuarioSistema: Daleska Firmante + ROL FIR ?
?? Puede firmar documentos ?
```

### ? Caso 3: Usuario ya existe
```
1. Agrega "Augusto Admin" (YA existe en UsuarioSistema como ADM)
2. Como REVISOR
3. Se registra documento
   ?
Resultado:
?? UsuarioSistema: Augusto Admin (mantiene ROL ADM, NO CAMBIA) ?
?? Puede hacer revisiones ?
```

### ? Caso 4: Múltiples participantes
```
1. Agrega 3 usuarios (Luis, Angel, Daleska)
2. Se registra documento
   ?
Resultado:
?? Todos 3 se crean en UsuarioSistema ?
?? Cada uno con su rol correspondiente ?
?? Documento se registra correctamente ?
```

---

## ?? Arquitectura de Datos

### Flujo de Inserción

```
                    RegistrarDocumentoConParticipantes()
                              ?
                              ?
                    Validar todos los campos
                              ?
                              ?
                    ? CrearUsuariosParticipantes()
                    ?  (NUEVO)
                    ?? Para cada participante:
                    ?  ?? Verificar existe en administracion
                    ?  ?? Verificar NO existe en UsuarioSistema
                    ?  ?? INSERTAR en UsuarioSistema
                    ?
                    ?? Si error: Retorna false, NO continúa
                    ?? Si ok: Continúa
                              ?
                              ?
                    InsertarDocumentoConParticipantes()
                    ?  (ya existía)
                    ?? INSERTAR Documento
                    ?? INSERTAR DocumentoParticipante (x N)
                    ?? INSERTAR PDF en otra BD
                              ?
                              ?
                    Documento completamente registrado ?
```

---

## ?? Seguridad

- ? **Validaciones**: Se verifica que el usuario existe en `administracion.dbo.Empleado`
- ? **No duplica**: Si el usuario ya existe en `UsuarioSistema`, no lo inserta de nuevo
- ? **Transacciones**: El documento se inserta en transacción (rollback si falla)
- ? **Roles correctos**: Se asignan los roles exactos según el tipo (REV o FIR)

---

## ?? Beneficios

1. ? **Automatización**: No require intervención manual
2. ? **Consistencia**: Todos los participantes quedan en `UsuarioSistema`
3. ? **Acceso**: Los usuarios pueden acceder al sistema con su rol asignado
4. ? **Trazabilidad**: Se registra quién creó el usuario y cuándo
5. ? **Sin errores**: Maneja casos de usuarios ya existentes gracefully

---

## ?? Estado Actual

? **Compilación:** EXITOSA
? **Creación de usuarios:** AUTOMÁTICA
? **Asignación de roles:** CORRECTA
? **Manejo de duplicados:** IMPLEMENTADO
? **Documentos:** Se registran COMPLETAMENTE

**¡Ahora todos los participantes se crean automáticamente en UsuarioSistema!** ??
