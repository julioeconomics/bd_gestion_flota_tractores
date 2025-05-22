# bd_gestion_flota_tractores
Controlar, registrar y analizar la información relacionada con los tractores de carga pesada, sus mantenimientos, rutas, conductores, consumo de combustible, y operaciones logísticas para optimizar su uso y reducir costos.
🗃️ Tablas principales
1. TRACTORES
Campo	Tipo de dato	Descripción
id_tractor	INT (PK)	Identificador único del tractor
placa	VARCHAR(10)	Placa del vehículo
marca	VARCHAR(50)	Marca del tractor
modelo	VARCHAR(50)	Modelo del tractor
año_fabricacion	INT	Año de fabricación
estado_operativo	VARCHAR(20)	Activo, En mantenimiento, De baja, etc.
fecha_adquisicion	DATE	Fecha en que se adquirió el vehículo
kilometraje_actual	INT	Kilometraje total acumulado

2. CONDUCTORES
Campo	Tipo de dato	Descripción
id_conductor	INT (PK)	Identificador único del conductor
nombre_completo	VARCHAR(100)	Nombre del conductor
dni	VARCHAR(15)	Documento de identidad
licencia	VARCHAR(15)	Tipo de licencia (A3C, etc.)
fecha_ingreso	DATE	Fecha en que empezó a trabajar
estado	VARCHAR(20)	Activo, Cesado, Suspendido, etc.

3. ASIGNACIONES
Campo	Tipo de dato	Descripción
id_asignacion	INT (PK)	ID único de asignación
id_tractor	INT (FK)	Tractor asignado
id_conductor	INT (FK)	Conductor asignado
fecha_inicio	DATE	Fecha de inicio de la asignación
fecha_fin	DATE	Fecha de finalización

4. MANTENIMIENTOS
Campo	Tipo de dato	Descripción
id_mantenimiento	INT (PK)	Identificador único del mantenimiento
id_tractor	INT (FK)	Tractor que recibe mantenimiento
fecha	DATE	Fecha del mantenimiento
tipo	VARCHAR(50)	Preventivo / Correctivo
descripcion	TEXT	Descripción del trabajo realizado
costo	DECIMAL(10,2)	Costo del mantenimiento
kilometraje	INT	Kilometraje al momento del mantenimiento

5. RUTAS_REALIZADAS
Campo	Tipo de dato	Descripción
id_ruta	INT (PK)	Identificador de la ruta
id_tractor	INT (FK)	Tractor que realizó la ruta
fecha_salida	DATETIME	Fecha y hora de salida
fecha_llegada	DATETIME	Fecha y hora de llegada
origen	VARCHAR(100)	Punto de partida
destino	VARCHAR(100)	Punto de llegada
kilometros	INT	Distancia recorrida
carga	VARCHAR(100)	Tipo o descripción de la carga

6. CONSUMO_COMBUSTIBLE
Campo	Tipo de dato	Descripción
id_registro	INT (PK)	ID del registro
id_tractor	INT (FK)	Tractor al que corresponde
fecha	DATE	Fecha del consumo
litros	DECIMAL(10,2)	Litros cargados
costo_total	DECIMAL(10,2)	Costo total del combustible
proveedor	VARCHAR(100)	Estación o proveedor del combustible

🔗 Relaciones entre tablas
TRACTORES 1:N ASIGNACIONES

CONDUCTORES 1:N ASIGNACIONES

TRACTORES 1:N MANTENIMIENTOS

TRACTORES 1:N RUTAS_REALIZADAS

TRACTORES 1:N CONSUMO_COMBUSTIBLE

📊 Indicadores sugeridos (para dashboards o reportes)
Total de kilómetros por tractor (mensual/anual)

Costos de mantenimiento por tractor

Costos por kilómetro recorrido

Promedio de consumo de combustible por ruta

Ranking de conductores por kilómetros recorridos

Tractores con mayor tiempo fuera de servicio

Costo total de operación por unidad
