USE bd_gestion_flota_tractores
GO


--- Consulta 1
--- Consulta de consumo mensual de combustible por tractor
--- OBJETIVO: Obtener el total de litros y costo por tractor agrupado por mes.
--- Permite a la empresa analizar cuánto combustible se gasta por tractor y mes,
---	ayudando a detectar excesos de consumo y planificar presupuestos.

SELECT*FROM consumo_combustible;
SELECT 
  tractor_id,
  FORMAT(fecha_llenado, 'yyyy-MM') AS mes,
  SUM(litros) AS total_litros,
  SUM(costo_combustible) AS total_gasto
FROM consumo_combustible
GROUP BY tractor_id, FORMAT(fecha_llenado, 'yyyy-MM')
ORDER BY tractor_id, mes;

--- Consulta 2
--- Vista de historial de mantenimiento por tractor
--- OBJETIVO: Crear una vista que muestre los mantenimientos realizados, con fecha, tipo, descripción y costo.
--- Sirve para auditorías técnicas y programación de mantenimiento preventivo, lo que reduce averías.


SELECT*FROM mantenimientos;
SELECT*FROM tractores;

GO
CREATE VIEW vw_historial_mantenimiento AS
SELECT 
  t.placa,
  m.fecha_mantenimiento,
  m.tipo,
  m.descripcion,
  m.kilometraje,
  m.costo_mantenimiento
FROM mantenimientos m
JOIN tractores t ON m.tractor_id = t.id;

GO
SELECT*FROM vw_historial_mantenimiento;

--- Observo que en mi columna mantenimiento solo tengo un solo tipo, actualizamos el registro aleatoriamente.
UPDATE mantenimientos
SET tipo = CHOOSE(CAST(RAND(CHECKSUM(NEWID())) * 3 + 1 AS INT), 'Preventivo', 'Correctivo', 'Predictivo');

--- Tambien podemos hacerlo manualmente
UPDATE mantenimientos
SET tipo = 'Predictivo'
WHERE id = 5; -- o cualquier ID específico
UPDATE mantenimientos
SET tipo = 'Predictivo'
WHERE id = 6; -- o cualquier ID específico


--- Consulta 3
--- Procedimiento para registrar una nueva asignación
--- OBJETIVO: Insertar una asignación de tractor y conductor, validando que no esté ya asignado.
--- Evita errores de doble asignación, que pueden generar problemas logísticos o de seguridad.


SELECT*FROM asignaciones;

GO
CREATE OR ALTER PROCEDURE sp_registrar_asignacion
  @tractor_id INT,
  @conductor_id INT,
  @fecha_inicio DATE
AS
BEGIN
  IF EXISTS (
    SELECT 1 FROM asignaciones
    WHERE tractor_id = @tractor_id AND fecha_fin IS NULL
  )
  BEGIN
    RAISERROR('Este tractor ya está asignado.', 16, 1);
    RETURN;
  END

  INSERT INTO asignaciones (tractor_id, conductor_id, fecha_inicio, fecha_fin)
  VALUES (@tractor_id, @conductor_id, @fecha_inicio, NULL);
END

SELECT name FROM sys.procedures;
EXEC sp_helptext 'sp_registrar_asignacion';

--- Ejecutar mi procedimiento.
EXEC sp_registrar_asignacion @tractor_id = 1, @conductor_id = 2, @fecha_inicio = '2025-06-10';
SELECT * FROM asignaciones;

--- Si no ejecuta nada, revisar si no tengo asignación activa
SELECT id FROM tractores
WHERE id NOT IN (
  SELECT tractor_id FROM asignaciones WHERE fecha_fin IS NULL
);

--- Selecciono un tractor sin asignación y ejecuto el código
EXEC sp_registrar_asignacion @tractor_id = 6, @conductor_id = 7, @fecha_inicio = '2025-06-11';
EXEC sp_registrar_asignacion @tractor_id = 7, @conductor_id = 7, @fecha_inicio = '2025-06-11';
SELECT*FROM asignaciones;

--- Observo que un mismo conductor esta conduciendo dos tractores en el mismo día.
--- Esto es poco probable en rutas largas.
--- Corregimos el código con una segunda validación
GO
CREATE OR ALTER PROCEDURE sp_registrar_asignacion
  @tractor_id INT,
  @conductor_id INT,
  @fecha_inicio DATE
AS
BEGIN
  -- Validar si el tractor ya está asignado
  IF EXISTS (
    SELECT 1 FROM asignaciones
    WHERE tractor_id = @tractor_id AND fecha_fin IS NULL
  )
  BEGIN
    RAISERROR('Este tractor ya está asignado.', 16, 1);
    RETURN;
  END

  -- Validar si el conductor ya está asignado
  IF EXISTS (
    SELECT 1 FROM asignaciones
    WHERE conductor_id = @conductor_id AND fecha_fin IS NULL
  )
  BEGIN
    RAISERROR('Este conductor ya está asignado.', 16, 1);
    RETURN;
  END

  -- Inserta asignación válida
  INSERT INTO asignaciones (tractor_id, conductor_id, fecha_inicio, fecha_fin)
  VALUES (@tractor_id, @conductor_id, @fecha_inicio, NULL);
END;

--- Eliminamos el registro
DELETE FROM asignaciones
WHERE id = 1002;  -- O el ID que desees corregir

--- Si insertamos nuevamente, tenemos ahora dos validaciones
EXEC sp_registrar_asignacion @tractor_id = 6, @conductor_id = 7, @fecha_inicio = '2025-06-11';
EXEC sp_registrar_asignacion @tractor_id = 7, @conductor_id = 7, @fecha_inicio = '2025-06-11';
SELECT*FROM asignaciones;


--- Consulta 4
--- Función para calcular el promedio de consumo de combustible por tractor (funcion escalar).
--- OBJETIVO: Devolver el promedio de litros consumidos por cada tractor.
--- Ayuda a medir la eficiencia del combustible en base a su historial.

SELECT*FROM consumo_combustible;

GO
CREATE FUNCTION fn_promedio_consumo (@tractor_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
  DECLARE @promedio DECIMAL(10,2);
  SELECT @promedio = AVG(litros)
  FROM consumo_combustible
  WHERE tractor_id = @tractor_id;
  RETURN @promedio;
END

--- Para ver el promedio por tractor 1.
GO
SELECT dbo.fn_promedio_consumo(1) AS Promedio_Consumo;

--- Ver los datos utilizados, el tractor 1.
SELECT * FROM consumo_combustible WHERE tractor_id = 1;

--- Si no hay registros, modificar la función para que salga 0 en vez de NULL.
RETURN COALESCE(@promedio, 0);


--- Consulta 5
--- Consulta de conductores activos sin asignación actual
--- OBJETIVO: Listar conductores activos que no están asignados a ningún tractor en este momento.
--- Optimiza el uso del recurso humano y evita inactividad innecesaria.

SELECT*FROM asignaciones;
SELECT*FROM conductores;

--- Selecciono los conductores sin asignación de trasnporte en estado "Activo"
SELECT c.id, c.nombre
FROM conductores c
WHERE c.estado = 'Activo'
AND c.id NOT IN (
  SELECT conductor_id
  FROM asignaciones
  WHERE fecha_fin IS NULL
);

--- Consulta 6
--- Vista de monitoreo de viajes con duración estimada
--- OBJETIVO: Mostrar duración de viajes en horas, con detalle de sedes y observaciones.
--- Facilita el control logístico y tiempos de entrega entre sedes.

SELECT*FROM monitoreo;

GO
CREATE VIEW vw_viajes_con_duracion AS
SELECT 
  m.id,
  t.placa,
  c.nombre AS conductor,
  m.fecha_salida,
  m.hora_salida,
  m.fecha_llegada,
  m.hora_llegada,
  DATEDIFF(HOUR, 
           CAST(m.fecha_salida AS DATETIME) + CAST(m.hora_salida AS DATETIME), 
           CAST(m.fecha_llegada AS DATETIME) + CAST(m.hora_llegada AS DATETIME)
          ) AS duracion_horas,
  s1.nombre AS sede_origen,
  s2.nombre AS sede_destino,
  m.observacion
FROM monitoreo m
JOIN tractores t ON m.tractor_id = t.id
JOIN conductores c ON m.conductor_id = c.id
JOIN sedes s1 ON m.sede_origen_id = s1.id
JOIN sedes s2 ON m.sede_destino_id = s2.id;

GO
SELECT*FROM vw_viajes_con_duracion;

--- Para ver tractores específicos usar
SELECT * FROM vw_viajes_con_duracion WHERE placa = 'TR002';
SELECT * FROM vw_viajes_con_duracion WHERE placa = 'TR001';


--- Consulta 7
--- Procedimiento para cerrar una asignación activa
--- OBJETIVO: Actualizar una asignación activa para establecer su fecha de fin.
--- Mantiene el historial actualizado y permite liberar tractores para nuevas asignaciones.

SELECT*FROM asignaciones;

GO
CREATE PROCEDURE sp_cerrar_asignacion
  @asignacion_id INT,
  @fecha_fin DATE
AS
BEGIN
  UPDATE asignaciones
  SET fecha_fin = @fecha_fin
  WHERE id = @asignacion_id AND fecha_fin IS NULL;
END

--- No arroja ningun resultado porque no hay conductores asignados inactivos, todos estan activos.
--- Simulo un cierre de asignaciones
UPDATE asignaciones
SET fecha_fin = DATEADD(DAY, -1, GETDATE())
WHERE id <= 5;

--- Vuelvo a generar el procedimiento
DROP PROCEDURE sp_cerrar_asignacion;
GO

--- Tambien puedo usar la siguiente funcion
CREATE OR ALTER PROCEDURE sp_cerrar_asignacion
  @asignacion_id INT,
  @fecha_fin DATE
AS
BEGIN
  UPDATE asignaciones
  SET fecha_fin = @fecha_fin
  WHERE id = @asignacion_id AND fecha_fin IS NULL;
END;

SELECT*FROM asignaciones;

--- Ejecuto el procedimiento creado y me permite cerrar una asignación, cuando un conductor termina su ruta, es decir, puedo utilizar otro tractor.
EXEC sp_cerrar_asignacion @asignacion_id = 10, @fecha_fin = '2025-06-09';
EXEC sp_cerrar_asignacion @asignacion_id = 19, @fecha_fin = '2025-06-09';
























