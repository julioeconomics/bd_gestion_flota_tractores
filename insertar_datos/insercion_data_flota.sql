USE bd_gestion_flota_tractores
GO

-----------------------------------------
------ Inserción de datos en mis tablas

-- Para la tabla SEDES
SELECT * FROM sedes;
DELETE FROM sedes;
DBCC CHECKIDENT ('sedes', RESEED, 0);

GO
DECLARE @i INT = 1;
WHILE @i <= 20
BEGIN
  INSERT INTO sedes (nombre, ciudad, region, direccion, estado)
  VALUES (
    CONCAT('Sede ', @i),
    CONCAT('Ciudad ', @i),
    CONCAT('Región ', @i),
    CONCAT('Av. Transporte #', @i * 100),
    'Activo'
  );
  SET @i = @i + 1;
END

-- Para la tabla TRACTORES
SELECT * FROM tractores;
DELETE FROM tractores;
DBCC CHECKIDENT ('tractores', RESEED, 0);

GO
DECLARE @i INT = 1;
WHILE @i <= 20
BEGIN
  INSERT INTO tractores (placa, marca, modelo, anio_fabricacion, estado_operativo, fecha_adquisicion, kilometraje_actual)
  VALUES (
    CONCAT('TR', FORMAT(@i, '000')),
	CONCAT('Marca ', @i),
    CONCAT('Modelo ', 2020 + @i),
    2015 + @i % 10,
	CHOOSE(FLOOR(RAND() * 3) + 1, 'Operativo', 'En mantenimiento', 'Fuera de servicio'),
    DATEADD(YEAR, -@i, GETDATE()),
    50000 + (@i * 1000)
  );
  SET @i = @i + 1;
END

-- Para la tabla Conductores
SELECT * FROM conductores;
DELETE FROM conductores;
DBCC CHECKIDENT ('conductores', RESEED, 0);

GO
DECLARE @i INT=1;
WHILE @i <= 20
BEGIN
  INSERT INTO conductores (nombre, dni, licencia, fecha_ingreso, estado)
  VALUES (
    CONCAT('Conductor ', @i),
    CONCAT('10', FORMAT(@i, '000000')),
    CONCAT('B', @i),
    DATEADD(YEAR, -@i, GETDATE()),
    CHOOSE(CAST(RAND()*3 + 1 AS INT), 'Activo', 'Suspendido', 'Vacaciones')
  );
  SET @i = @i + 1;
END

-- Para la tabla ASIGNACIONES
SELECT * FROM asignaciones;
DELETE FROM asignaciones;
DBCC CHECKIDENT ('asignaciones', RESEED, 0);

GO
DECLARE @i INT=1;
WHILE @i <= 20
BEGIN
  INSERT INTO asignaciones (tractor_id, conductor_id, fecha_inicio, fecha_fin)
  VALUES (
    (@i % 5) + 1, -- 1 a 5
    (@i % 5) + 1,
    DATEADD(DAY, -@i * 10, GETDATE()),
    NULL
  );
  SET @i = @i + 1;
END

-- Para la tabla MANTENIMIENTOS
SELECT * FROM mantenimientos;
DELETE FROM mantenimientos;
DBCC CHECKIDENT ('mantenimientos', RESEED, 0);

GO
DECLARE @i INT = 1;
WHILE @i <= 20
BEGIN
  INSERT INTO mantenimientos (tractor_id, tipo, descripcion, frecuencia_km, fecha_mantenimiento, costo_mantenimiento, kilometraje)
  VALUES (
    (@i % 5) + 1,
    'Preventivo',
    CONCAT('Cambio de aceite ', @i),
    CHOOSE(FLOOR(RAND()*4 ) + 1, 5000, 7500, 10000, 15000),
    DATEADD(DAY, -@i * 15, GETDATE()),
    150.00 + (@i * 5),
    50000 + (@i * 1200)
  );
  SET @i = @i + 1;
END

-- Para la tabla CONSUMO_COMBUSTIBLE
SELECT * FROM consumo_combustible;
DELETE FROM consumo_combustible;
DBCC CHECKIDENT ('consumo_combustible', RESEED, 0);

GO
DECLARE @i INT=1;
WHILE @i <= 20
BEGIN
  INSERT INTO consumo_combustible (tractor_id, fecha_llenado, litros, costo_combustible, proveedor)
  VALUES (
    (@i % 5) + 1,
    DATEADD(DAY, -@i * 3, GETDATE()),
    50 + (@i * 2),
    (50 + (@i * 2)) * 5.5,
    CONCAT('Proveedor ', @i)
  );
  SET @i = @i + 1;
END

-- Para la tabla MONITOREO
SELECT * FROM monitoreo;
DELETE FROM monitoreo;
DBCC CHECKIDENT ('monitoreo', RESEED, 0);

GO
DECLARE @i INT = 1;
WHILE @i <= 20
BEGIN
  INSERT INTO monitoreo (
    tractor_id, conductor_id, fecha_salida, hora_salida,
    fecha_llegada, hora_llegada, sede_origen_id, sede_destino_id, observacion)
  VALUES (
    (@i % 5) + 1,
    (@i % 5) + 1,
    DATEADD(DAY, -@i * 2, GETDATE()),
    CAST(DATEADD(MINUTE, CAST(RAND()*180 AS INT), '06:00:00') AS TIME),
    DATEADD(DAY, -@i * 2 + 1, GETDATE()),
    CAST(DATEADD(MINUTE, CAST(RAND()*180 AS INT), '17:00:00') AS TIME),
    1 + ((@i + 1) % 5),
    1 + (@i % 5),
    CONCAT('Viaje número ', @i)
  );
  SET @i = @i + 1;
END
