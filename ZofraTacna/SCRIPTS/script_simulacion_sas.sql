CREATE DATABASE administracion;
GO

USE administracion;
GO

-- TABLA: Empleado (Simulada)
-- DESCRIPCIÓN: Esta tabla emula la estructura de la base de datos institucional 
-- a la que el sistema consultará para obtener los datos de los usuarios[cite: 5, 20].
CREATE TABLE Empleado (
    IDEmpleado INT IDENTITY(1,1) PRIMARY KEY,
    CodigoPersonal VARCHAR(20),
    Apellido VARCHAR(100),
    Nombre VARCHAR(100),
    LoginUsuario VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NULL, -- Puede ser nulo para probar la lógica de correos [cite: 22]
    IDUnidadOrganica INT,
    IDCargo INT,
    IDSede INT,
    IdRol INT,
    ActivoAsist BIT DEFAULT 1 -- Solo se consideran empleados activos [cite: 21]
);
GO


INSERT INTO Empleado (CodigoPersonal, Apellido, Nombre, LoginUsuario, Email)
VALUES 
('001', 'Administrador', 'Augusto', 'augusto', 'augusto@zofratacna.com.pe'),
('002', 'Vargas Gutierrez', 'Angel', 'angel', 'angel@zofratacna.com.pe'),
('003', 'Salas', 'W.', 'wsalas', 'wsalas@zofratacna.com.pe'),
('004', 'Firmante', 'Daleska', 'daleska', 'daleska@zofratacna.com.pe');
