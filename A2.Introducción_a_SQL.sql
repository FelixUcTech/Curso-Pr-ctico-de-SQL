-------------------------------------
''' Qué es una proyección (SELECT) '''
-------------------------------------
--Como concepto SQL representa una proyectcción, es la elección de lo que queremos que se muestre, en terminos de columnas
--Podemos elegir cual se muestra Cual no, y puede integrarse a otros comandos para poder realizar consultas más complejas

SELECT *;   --Toma lo que se tiene guardado en la entidad dentro del manejador de base de datos y muestra toda la información
            --La tabla mostrada es prácticamente la proyección

SELECT "CAMPO O COLUMNA" AS "ALIAS QUE QUIERES QUE SE RENOMBRE";

-- Contamos el número de registros en la columna 'id' de la tabla actual.
SELECT COUNT(id),
       -- Sumamos los valores de la columna 'quantity'.
       SUM(quantity),
       -- Calculamos el promedio de la columna 'age'.
       AVG(age);

-- Seleccionamos la fecha mínima y la cantidad máxima en una nueva consulta.
SELECT MIN(date),
       MAX(quantity);

-------------------------------------
''' Origen (FROM) '''
-------------------------------------
SELECT * 
FROM tabla_diaria; --Esta debe estar definida
--El from puede ser tan complejo dependiendo de las necesidades que uno tenga
SELECT *
FROM TABLA_DIARIA AS TD
    JOIN TABLA_MENSUAL AS TM
    ON TD.PK = TM-FK;

-------------------------------------
''' Producto cartesiano (JOIN) '''
-------------------------------------
-- Supongamos que tenemos dos tablas: 'clientes' y 'pedidos'.

-- Tabla 'clientes'
-- | id_cliente | nombre    |
-- |------------|-----------|
-- | 1          | Juan      |
-- | 2          | Ana       |
-- | 3          | Pedro     |

-- Tabla 'pedidos'
-- | id_pedido | id_cliente | producto  |
-- |-----------|------------|-----------|
-- | 1         | 1          | Producto A|
-- | 2         | 2          | Producto B|
-- | 3         | 4          | Producto C|

-- INNER JOIN: Devuelve solo los registros que tienen coincidencias en ambas tablas.
SELECT c.nombre, p.producto
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente;

-- LEFT JOIN (o LEFT OUTER JOIN): Devuelve todos los registros de la tabla izquierda (clientes) 
-- y los registros coincidentes de la tabla derecha (pedidos). Si no hay coincidencia, devuelve NULL en la tabla derecha.
SELECT c.nombre, p.producto
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente;

-- RIGHT JOIN (o RIGHT OUTER JOIN): Devuelve todos los registros de la tabla derecha (pedidos) 
-- y los registros coincidentes de la tabla izquierda (clientes). Si no hay coincidencia, devuelve NULL en la tabla izquierda.
SELECT c.nombre, p.producto
FROM clientes c
RIGHT JOIN pedidos p ON c.id_cliente = p.id_cliente;

-- FULL JOIN (o FULL OUTER JOIN): Devuelve todos los registros de ambas tablas. 
-- Si no hay coincidencia, devuelve NULL en las columnas de la tabla que no tiene el registro.
SELECT c.nombre, p.producto
FROM clientes c
FULL JOIN pedidos p ON c.id_cliente = p.id_cliente;

-- CROSS JOIN: Devuelve el producto cartesiano de ambas tablas, 
-- es decir, combina cada registro de la primera tabla con cada registro de la segunda.
SELECT c.nombre, p.producto
FROM clientes c
CROSS JOIN pedidos p;

-- SELF JOIN: Se utiliza para unir una tabla consigo misma. 
-- Es útil para comparar filas dentro de la misma tabla.
SELECT a.nombre AS cliente1, b.nombre AS cliente2
FROM clientes a
JOIN clientes b ON a.id_cliente <> b.id_cliente;

-------------------------------------
''' Selección (WHERE) '''
-------------------------------------
--Desde mi perspectiva personal un where siempre se va poder ejecutar y fungir como filtro siempre y cuando
--Nuestra proyección de nuestro origen se le pueda aplicar esa condicionante
--Nota importante si usas condicionales lógicos los puesdes agrupas por medio de parentesis

-------------------------------------
''' Ordenamiento (Gruop By)'''
-------------------------------------
--Este comando sirve cuando ya tienes la información
--Esto se complica cuando ya hay varios tipos de datos que son los que nos indca el ordenamiento, y al
--No tener una prioridad unica pueden ayudar lo que serían los indices
SELECT *
FROM TABLA
ORDER BY FECHA;

SELECT *
FROM TABLA
ORDER BY FECHA ASC;

SELECT *
FROM TABLA
ORDER BY FECHA DESC;

-------------------------------------
--  INDICES
-------------------------------------
--Excelentes para busquedas y ordenamientos
--Cuidar para alta transaccionalidad
--Cuando tenemos indices se complica la escritura, porque cada vez que se agreag algo reodena la tabla o consulta donde estés trabajando
--Todo esto lo hace la base de datos pero implica tiempo de procesamiento, por lo cual es de cuidado saber donde poner indices, para no afectar el desempeño de la tabla
--Si vas a hacer muchas escrituras por segundo no es recomendable utilizar indices

-- Creación de la tabla usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,         -- Clave primaria. PostgreSQL crea automáticamente un índice para la clave primaria.
    nombre TEXT,                   -- Campo nombre, en el que luego aplicaremos un índice.
    email TEXT UNIQUE,             -- Campo email con restricción UNIQUE, lo que automáticamente crea un índice para este campo.
    fecha_registro DATE            -- Campo fecha_registro sin restricciones adicionales en este caso.
);

-- Creación de un índice en la columna 'nombre' para optimizar las búsquedas
CREATE INDEX idx_nombre_usuario ON usuarios (nombre);
--
-- Este índice mejorará las búsquedas en la columna 'nombre', por ejemplo:
SELECT * FROM usuarios WHERE nombre = 'Carlos';
-- 
-- COMENTARIO: 
-- Los índices son muy útiles para consultas que involucran operaciones frecuentes de búsqueda o clasificación 
-- (por ejemplo, en columnas que aparecen en las cláusulas WHERE o ORDER BY).
-- 
-- VENTAJAS:
-- 1. Aceleración de consultas: Este índice mejorará el tiempo de ejecución de las consultas que busquen usuarios por nombre.
-- 
-- DESVENTAJAS:
-- 1. Costo en las escrituras: Sin embargo, si la tabla 'usuarios' recibe muchas inserciones o actualizaciones, 
--   el índice necesitará ser actualizado cada vez que se inserte o modifique un registro, lo que puede afectar el rendimiento.
-- 2. No siempre recomendable en alta transaccionalidad: Si la tabla tiene muchas escrituras por segundo, el uso de índices puede 
--    perjudicar el rendimiento debido al costo de actualización del índice en cada operación de escritura.

-- NOTA IMPORTANTE: 
-- PostgreSQL ya crea automáticamente índices para columnas con claves primarias (PRIMARY KEY) y restricciones de unicidad (UNIQUE), 
-- como es el caso del campo 'email'. No es necesario crear índices adicionales sobre estas columnas.

-------------------------------------
''' Agregación y limitantes (gruoup by & limit) '''
-------------------------------------
--La agregación no es otra cosa que reducir los datos en grupos y se utiliza mucho en ciencia de datos
--Sirve mucho para sacar estadísticas para sacar gráficas, etc etc 

SELECT *
FROM TABLA
GROUP BY MARCA;

SELECT *
FROM TABLA
GROUP BY MARCA, MODELO;

"LIMIT"
--Normalmente es una sentencia simple pero su función o idea de uso es ahorrar rendiemiento
SELECT *
FROM TABLA
GROUP BY MARCA
LIMIT 15000;

SELECT *
FROM TABLA
LIMIT 15000;

--Sin order by, la tabla de acuerdo a como este acomodada internamente te mandara los datos que le estás pidiendo
SELECT *
FROM TABLA
OFFSET 1500 --Salta los primeros 1500
LIMIT 15000; --Luego dame los siguientes 1500

