-- Creacion de base de datos gestion de flota de tractores
CREATE DATABASE bd_gestion_flota_tractores;
GO

-- Uso de base de datos
USE bd_gestion_flota_tractores;
GO

--- Creación de tablas
CREATE TABLE sedes (
  id INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  ciudad VARCHAR(100) NOT NULL,
  region VARCHAR(100) NOT NULL,
  direccion VARCHAR(255),
  estado VARCHAR(50) NOT NULL
);

CREATE TABLE tractores (
  id INT IDENTITY(1,1) PRIMARY KEY,
  placa VARCHAR(10) UNIQUE NOT NULL,
  marca VARCHAR(50),
  modelo VARCHAR(50),
  anio_fabricacion INT,
  estado_operativo VARCHAR(50),
  fecha_adquisicion DATE,
  kilometraje_actual DECIMAL(10,2)
);

CREATE TABLE conductores (
  id INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  dni CHAR(8) UNIQUE NOT NULL,
  licencia VARCHAR(20),
  fecha_ingreso DATE,
  estado VARCHAR(50)
);

CREATE TABLE asignaciones (
  id INT IDENTITY(1,1) PRIMARY KEY,
  tractor_id INT NOT NULL,
  conductor_id INT NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE,
  FOREIGN KEY (tractor_id) REFERENCES tractores(id),
  FOREIGN KEY (conductor_id) REFERENCES conductores(id)
);

CREATE TABLE mantenimientos (
  id INT IDENTITY(1,1) PRIMARY KEY,
  tractor_id INT NOT NULL,
  tipo VARCHAR(50),
  descripcion VARCHAR(255),
  frecuencia_km INT,
  fecha_mantenimiento DATE,
  costo_mantenimiento DECIMAL(10,2),
  kilometraje INT,
  FOREIGN KEY (tractor_id) REFERENCES tractores(id)
);

CREATE TABLE consumo_combustible (
  id INT IDENTITY(1,1) PRIMARY KEY,
  tractor_id INT NOT NULL,
  fecha_llenado DATE NOT NULL,
  litros DECIMAL(10,2),
  costo_combustible DECIMAL(10,2),
  proveedor VARCHAR(100),
  FOREIGN KEY (tractor_id) REFERENCES tractores(id)
);


CREATE TABLE monitoreo (
  id INT IDENTITY(1,1) PRIMARY KEY,
  tractor_id INT NOT NULL,
  conductor_id INT NOT NULL,
  fecha_salida DATE,
  hora_salida TIME,
  fecha_llegada DATE,
  hora_llegada TIME,
  sede_origen_id INT NOT NULL,
  sede_destino_id INT NOT NULL,
  observacion VARCHAR(255),
  FOREIGN KEY (tractor_id) REFERENCES tractores(id),
  FOREIGN KEY (conductor_id) REFERENCES conductores(id),
  FOREIGN KEY (sede_origen_id) REFERENCES sedes(id),
  FOREIGN KEY (sede_destino_id) REFERENCES sedes(id)
);





