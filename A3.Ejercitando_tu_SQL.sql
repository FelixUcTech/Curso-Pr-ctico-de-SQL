-------------------------------------
'''EL PRIMERO'''
-------------------------------------
--Formas homologas de consultar la primera fila / row
-- Supongamos que estamos seleccionando usuarios de una tabla.
-- Queremos obtener solo el primer registro en la lista, para eso usamos:

SELECT * 
FROM usuarios
ORDER BY fecha_registro DESC
FETCH FIRST 1 ROW ONLY;

"
fetch1 /fɛtʃ/  
v. 
to go and bring back;
return with;
get:[~ + object]
to fetch a glass of water.
[no object]
She taught the dog to fetch.
to cause to come;
bring:
[~ + object]Go fetch a doctor.
to sell for or bring (a price, financial return, etc.):
[~ + object]The horse fetched more money than it cost.
"

-- Explicación:
-- 1. `ORDER BY fecha_registro DESC` ordena los registros en función de la columna 'fecha_registro', de mayor a menor. 
--    Esto significa que el usuario más reciente aparecerá primero.
-- 
-- 2. `FETCH FIRST 1 ROW ONLY` limita el resultado de la consulta a **solo una fila**.
--    En este caso, tras ordenar los usuarios por fecha de registro en orden descendente, obtendremos 
--    solo el usuario más reciente.
-- 
-- COMENTARIO:
-- Este comando es útil cuando solo se necesita el primer resultado de una consulta que podría devolver muchas filas.
-- En lugar de recuperar todos los registros, que consume más recursos, obtenemos únicamente la primera fila.
-- 
-- Este tipo de consultas también es útil en situaciones donde necesitas la primera ocurrencia, como:
-- - Obtener el último registro insertado
-- - Obtener el primer resultado de un conjunto grande de datos
-- 
-- Alternativas:
-- En algunos sistemas, el comando equivalente es `LIMIT 1`, que tiene el mismo efecto:
--   SELECT * FROM usuarios ORDER BY fecha_registro DESC LIMIT 1;

select *
from platzi.alumnos
LIMIT 1;
--Depeendera del motor de busqueda las opciones para hacer la consulta, que se pueda habilitar la función limit

-------------------------------------
--WINDOW FUNCTION preliminar
-------------------------------------
--Una window function es la relación entre el row que queremos medir y la totalidad de rows en un grupo
-- Supongamos que tenemos una tabla llamada 'calificaciones' con los siguientes datos:
-- | Estudiante | Calificación |
-- |------------|--------------|
-- | Juan       | 85           |
-- | María      | 90           |
-- | Pedro      | 75           |
-- | Ana        | 95           |

-- Queremos calcular el promedio de calificaciones para cada estudiante usando una window function.

SELECT 
    Estudiante,                         -- Seleccionamos la columna 'Estudiante'
    Calificación,                      -- Seleccionamos la columna 'Calificación'
    AVG(Calificación) OVER () AS Promedio  -- Calculamos el promedio de calificaciones
FROM 
    calificaciones;                     -- Desde la tabla 'calificaciones'

-- En este caso:
-- - 'AVG(Calificación)' calcula el promedio de la columna 'Calificación'.
-- - 'OVER ()' indica que queremos calcular este promedio sobre todas las filas de la tabla
--   sin agruparlas, lo que significa que cada fila seguirá mostrándose como individual.
-- - Como resultado, cada estudiante tendrá su calificación y el promedio de todas las calificaciones.

-- Resultado de la consulta:
-- | Estudiante | Calificación | Promedio |
-- |------------|--------------|----------|
-- | Juan       | 85           | 86.25    |
-- | María      | 90           | 86.25    |
-- | Pedro      | 75           | 86.25    |
-- | Ana        | 95           | 86.25    |

-------------------------------------
--OVER()
-------------------------------------
OVER ()--: Calcula la función sobre todas las filas.
OVER (PARTITION BY columna)--: Divide el conjunto de datos en grupos.
OVER (ORDER BY columna)--: Define el orden en el que se aplican los cálculos.
OVER (PARTITION BY columna ORDER BY columna)--: Combina ambas para cálculos más específicos.

"
¿Qué es ROW_NUMBER()?
La función ROW_NUMBER() asigna un número de fila único y secuencial a cada fila dentro de un conjunto de resultados, comenzando desde 1. Este número se asigna en el orden especificado en la cláusula ORDER BY dentro de OVER().

La función ROW_NUMBER() y una primary key (clave primaria) son conceptos diferentes en bases de datos y tienen propósitos distintos. Aquí te explico las diferencias clave entre ambos:

1. Definición
ROW_NUMBER():
Es una función de ventana que asigna un número de fila único y secuencial a cada fila en el conjunto de resultados, basado en el orden especificado. Este número es temporal y solo existe en el contexto de la consulta en la que se utiliza.
Primary Key:
Es una restricción en la base de datos que asegura que cada fila en una tabla tenga un identificador único. Una primary key no puede contener valores nulos y debe ser única para cada fila de la tabla. Se utiliza para identificar de manera única cada registro en la tabla.
2. Persistencia
ROW_NUMBER():

El número de fila se calcula dinámicamente y no se almacena en la tabla. Cada vez que se ejecuta la consulta, se genera un nuevo conjunto de números de fila.
Primary Key:

La clave primaria es un atributo o conjunto de atributos que se define en la estructura de la tabla y se almacena físicamente. Siempre está presente en la tabla y se utiliza para mantener la integridad de los datos.
3. Uso
ROW_NUMBER():

Se utiliza principalmente para clasificación, paginación de resultados y tareas donde se necesita un número de fila único temporalmente, pero no necesariamente para identificar un registro de manera única en la base de datos.
Primary Key:

Se utiliza para identificar registros únicos, establecer relaciones entre tablas (por ejemplo, en claves foráneas) y garantizar la integridad de los datos.
"
select *
from (
    select ROW_NUMBER() OVER() AS row_id, *
    from platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id = 10;

--CONSULTA OFFSET Y LIMIT
select *
from (
    select ROW_NUMBER() OVER() AS row_id, *
    from platzi.alumnos
) AS alumnos_with_row_num
OFFSET 100
LIMIT 1;

--Opción peculiar de llamar a las 10 últimas filas
--¿Qué forma es la más eficiente para hacer lo siguiente, será esa o existe otra?
WITH alumnos_with_row_num AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY ID) AS row_id,  -- Cambia 'ID' por la columna por la que quieras ordenar
        *
    FROM 
        platzi.alumnos
),
total_count AS (
    SELECT COUNT(*) AS total FROM platzi.alumnos  -- Cuenta el total de filas
)
SELECT *
FROM alumnos_with_row_num, total_count
WHERE row_id > total - 10  -- Filtra las últimas 10 filas
ORDER BY row_id;  -- Opcional: ordena los resultados

-------------------------------------
select *
from (
    select ROW_NUMBER() OVER() AS row_id, *
    from platzi.alumnos
) AS alumnos_with_row_num
OFFSET 1
fetch FIRST 10 row ONLY;
--UNA FORMA DE PROFUNDIZAR ES VER EL TIEMPO DE PROCESAMIENTO PARA REALIZAR LA CONSULTA

 -- Con fetch --
SELECT *
FROM platzi.alumnos
FETCH FIRST 5 ROWS ONLY;

-- Con limit --
SELECT *
FROM platzi.alumnos
LIMIT 5;

-- Con subquery y window function --
SELECT *
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id <= 5;


-------------------------------------
'''EL el segundo más alto'''
-------------------------------------

/**
 * Encuentra la segunda colegiatura más alta
 * encuentra todos los alumnos con esa misma colegiatura
 */

-- Contar por join entre las tablas --
SELECT DISTINCT colegiatura
FROM platzi.alumnos a1
WHERE 2=(
	SELECT COUNT(DISTINCT colegiatura)-- aqui en count fungue como un ciclo hace algo peculiar
	FROM platzi.alumnos a2
	WHERE a1.colegiatura<=a2.colegiatura
);

-- Sencillo con limit --
SELECT DISTINCT colegiatura, tutor_id
FROM platzi.alumnos
WHERE tutor_id = 20
ORDER BY colegiatura DESC
LIMIT 1 OFFSET 1;

-- Join con subquery --

SELECT *
FROM platzi.alumnos AS datos_alumnos
INNER JOIN (
	SELECT DISTINCT colegiatura
	FROM platzi.alumnos
	WHERE tutor_id = 20
	ORDER BY colegiatura DESC
	LIMIT 1 OFFSET 1
) AS segunda_mayor_colegiatura
ON datos_alumnos.colegiatura = segunda_mayor_colegiatura.colegiatura;


-- Subquery en Where --

SELECT *
FROM platzi.alumnos AS datos_alumnos
WHERE colegiatura = (
	SELECT DISTINCT colegiatura
	FROM platzi.alumnos
	WHERE tutor_id = 20
	ORDER BY colegiatura DESC
	LIMIT 1 OFFSET 1
);

/**
  * RETO: Presentar la segunda mitad de la tabla.
  */
SELECT ROW_NUMBER() OVER() AS row_id, *
FROM platzi.alumnos
OFFSET (
	SELECT COUNT(*)/2
	FROM platzi.alumnos
);

-------------------------------------
''' Seleccionar de un set de opciones'''
-------------------------------------

/**
  * Seleccionar resultados en un set
  */

-- In array --
SELECT  *
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id IN (1,2,3,4,5);

-- In con subquery --
SELECT  *
FROM platzi.alumnos
WHERE id IN (
    SELECT id
    FROM platzi.alumnos
    WHERE tutor_id = 30
);

-- not In array --
SELECT  *
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id not IN (1,2,3,4,5);

-- not In con subquery --
SELECT  *
FROM platzi.alumnos
WHERE id not IN (
    SELECT id
    FROM platzi.alumnos
    WHERE tutor_id = 30
);

-----------------------------------
''' En mis tiempos'''
------------------------------------
/**
  * Extraer partes de una fecha
  */
-- Con EXTRACT --
SELECT EXTRACT(YEAR FROM fecha_incorporacion) AS anio_incorporacion
FROM platzi.alumnos;

-- Con DATE_PART --
SELECT DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion
FROM platzi.alumnos;

SELECT  DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion,
        DATE_PART('MONTH', fecha_incorporacion) AS mes_incorporacion,
        DATE_PART('DAY', fecha_incorporacion) AS dia_incorporacion
FROM platzi.alumnos;

--Campo de una hora
SELECT  DATE_PART('HOUR', fecha_incorporacion) AS hora_incorporacion,
        DATE_PART('MINUTE', fecha_incorporacion) AS minuto_incorporacion,
        DATE_PART('SECOND', fecha_incorporacion) AS segundo_incorporacion
FROM platzi.alumnos;

-----------------------------------
'''SELECCIONAR POR AÑO'''
-----------------------------------
/**
  * Filtrar los alumnos que se inscribieron en 2019
  */
-- Filtro EXTRACT --
SELECT *
FROM platzi.alumnos
WHERE (EXTRACT(YEAR FROM fecha_incorporacion)) = 2019;
-- Filtro DATE_PART --
SELECT *
FROM platzi.alumnos
WHERE (DATE_PART('YEAR', fecha_incorporacion)) = 2019;
-- Filtro subquery DATE_PART --
SELECT	*
FROM (
	SELECT	*,
			DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion
	FROM platzi.alumnos
) AS alumnos_con_anio_mes
WHERE	anio_incorporacion = 2019;

-- Filtro subquery DATE_PART  año y mes--
SELECT	*
FROM (
	SELECT	*,
			DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion,
            DATE_PART('MONTH', fecha_incorporacion) AS mes_incorporacion
	FROM platzi.alumnos
) AS alumnos_con_anio_mes
WHERE(	
		anio_incorporacion = 2018
		AND mes_incorporacion = 5);

SELECT *
FROM platzi.alumnos
WHERE ((EXTRACT(YEAR FROM fecha_incorporacion)) = 2018
		and (EXTRACT(MONTH FROM fecha_incorporacion)) = 5);

-----------------------------------
'''DUPLICADOS TROUBLE'''
-----------------------------------

/**
  * Borrar los registros duplicados de una tabla
  */

-- Subquery by id --
SELECT	*
FROM 	platzi.alumnos ou
WHERE (
	SELECT	COUNT(*)
	FROM	platzi.alumnos inr
	WHERE	inr.id = ou.id
) > 1;

-- Hash text --
SELECT (platzi.alumnos.*)::text, COUNT(*)
FROM platzi.alumnos
GROUP BY platzi.alumnos.*
HAVING COUNT(*) > 1;

-- Hash excluyendo ID --
SELECT (
	platzi.alumnos.nombre,
	platzi.alumnos.apellido,
	platzi.alumnos.email,
	platzi.alumnos.colegiatura,
	platzi.alumnos.fecha_incorporacion,
	platzi.alumnos.carrera_id,
	platzi.alumnos.tutor_id
)::text, COUNT(*)
FROM platzi.alumnos
GROUP BY platzi.alumnos.nombre,
	platzi.alumnos.apellido,
	platzi.alumnos.email,
	platzi.alumnos.colegiatura,
	platzi.alumnos.fecha_incorporacion,
	platzi.alumnos.carrera_id,
	platzi.alumnos.tutor_id
HAVING COUNT(*) > 1;
'
La razón por la que se utiliza HAVING en lugar de WHERE para detectar registros duplicados es porque HAVING filtra los resultados después de haber aplicado la agregación (GROUP BY y COUNT(*) en este caso).

WHERE se usa para filtrar filas antes de aplicar cualquier función de agregación.
HAVING se usa para filtrar las filas después de que se ha realizado la agregación (como COUNT()).
En tu caso, estás usando COUNT(*) para contar cuántas filas tienen los mismos valores en las columnas agrupadas. Solo después de hacer esa agregación puedes filtrar los duplicados, por lo que necesitas usar HAVING COUNT(*) > 1.
'
-- Partición por todos los campos excepto ID --
SELECT	*
FROM (
	SELECT id,
	ROW_NUMBER() OVER(
		PARTITION BY
			nombre,
			apellido,
			email,
			colegiatura,
			fecha_incorporacion,
			carrera_id,
			tutor_id
		ORDER BY id asc
	) AS row,
	*
	FROM platzi.alumnos
) duplicados
WHERE duplicados.row > 1;

--:: es el equivalente a hacer un cast en sql

-- Partición por todos los campos excepto ID --
SELECT	*
FROM (
	SELECT id as id1,
	ROW_NUMBER() OVER(
		PARTITION BY
			nombre,
			apellido,
			email,
			colegiatura,
			fecha_incorporacion,
			carrera_id,
			tutor_id
		ORDER BY id asc
	) AS row,
	*
	FROM platzi.alumnos
) duplicados
order by id1; --La subconsulta encuentra un segundo elemento repetido, y a ese segundo le da el nombre de 2


-- Borrado de arreglo de ID por partición por todos los campos --
DELETE FROM platzi.alumnos
WHERE id IN
    (
	SELECT	id
	FROM (
		SELECT id,
		ROW_NUMBER() OVER(
			PARTITION BY
				nombre,
				apellido,
				email,
				colegiatura,
				fecha_incorporacion,
				carrera_id,
				tutor_id
			ORDER BY id asc
		) AS row
		FROM platzi.alumnos
	) duplicados
	WHERE duplicados.row > 1
);

-----------------------------------
'''Selectores de rango'''
-----------------------------------
/**
  * Rangos y solapes
  */

-- Ejemplos iniciales --
SELECT *
FROM platzi.alumnos
WHERE tutor_id IN (11,12,13,14,15,16,17,18,19,20);
SELECT *
FROM platzi.alumnos
WHERE tutor_id >= 1
    AND tutor_id <= 10;

SELECT *
FROM platzi.alumnos
WHERE tutor_id BETWEEN 1 AND 10;

-- ¿En rango? --
SELECT int4range(10, 20) @> 3;

-- ¿Se solapan? --
SELECT numrange(11.1, 22.2) && numrange(20.0, 30.0);

-- Obtener el límite superior --
SELECT upper(int8range(15, 25));

-- Calcular la intersección --
SELECT int4range(10, 20) * int4range(15, 25);

-- ¿Rango vacío?
SELECT isempty(numrange(1, 5));

-- Filtrar alumnos cuyo tutor_id esté entre 1 y 10 --
SELECT *
FROM platzi.alumnos
WHERE int4range(10, 20) @> tutor_id;

/**
  * RETO:   Encontrar los números en común entre
  *         los id de tutor y carrera;
  */

SELECT numrange(
	(SELECT min(tutor_id) FROM platzi.alumnos),
	(SELECT max(tutor_id) FROM platzi.alumnos)
) * numrange(
	(SELECT min(carrera_id) FROM platzi.alumnos),
	(SELECT max(carrera_id) FROM platzi.alumnos)
);

-----------------------------------
'''Eres lo máximo'''
-----------------------------------
-- Máximo absoluto de la tabla --
SELECT	fecha_incorporacion
FROM	platzi.alumnos
ORDER BY fecha_incorporacion DESC
LIMIT 1;

-- Intento por GROUP BY --
SELECT	carrera_id, fecha_incorporacion
FROM	platzi.alumnos
GROUP BY carrera_id, fecha_incorporacion
ORDER BY fecha_incorporacion DESC;

-- Funcion MAX --
SELECT	carrera_id, MAX(fecha_incorporacion)
FROM	platzi.alumnos
GROUP BY carrera_id
ORDER BY carrera_id;

-- Mínimo absoluto de la tabla --
SELECT	nombre
FROM	platzi.alumnos
ORDER BY nombre ASC
LIMIT 1;

-- Funcion MIN --
SELECT	tutor_id, MIN(nombre)
FROM	platzi.alumnos
GROUP BY tutor_id
ORDER BY tutor_id;

select nombre
from platzi.alumnos pa
group by nombre
having pa.nombre = min(pa.nombre);

select nombre, count(nombre)
from platzi.alumnos
group by nombre
having count(nombre) > 1
order by nombre asc;
-----------------------------------
'''Egoísta (selfish)'''
-----------------------------------
--Toda la lista de los alumnos tutores
SELECT CONCAT(t.nombre, ' ', t.apellido) AS tutor,
		count(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
	Inner join platzi.alumnos AS t 
	ON a.tutor_id = t.id
	group by tutor
	order by alumnos_por_tutor ASC;

--Los primeros 10 con menos tutorados
SELECT CONCAT(t.nombre, ' ', t.apellido) AS tutor,
		count(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
	Inner join platzi.alumnos AS t 
	ON a.tutor_id = t.id
	group by tutor
	order by alumnos_por_tutor ASC
	limit 10;

--Los explotados laboralmente
SELECT CONCAT(t.nombre, ' ', t.apellido) AS tutor,
		count(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
	Inner join platzi.alumnos AS t 
	ON a.tutor_id = t.id
	group by tutor
	order by alumnos_por_tutor DESC
	limit 10;

--El promedio general por tutor de alumnos
select tutor, alumnos_por_tutor, avg(alumnos_por_tutor)
from(
SELECT CONCAT(t.nombre, ' ', t.apellido) AS tutor,
		count(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
	Inner join platzi.alumnos AS t 
	ON a.tutor_id = t.id
	group by tutor
	order by alumnos_por_tutor DESC)
	group by tutor, alumnos_por_tutor;

-----------------------------------
'''Resolviendo diferencias'''
-----------------------------------
--Para detectar si hay filas borradas en tabla carreras
select a.nombre, a.apellido, c.carrera
from platzi.alumnos as a
	left join platzi.carreras as c
		on a.carrera_id = c.id
	where c.id is null;

--Detecta todo lo que está en ambas tablas, y lo que aparezca en null es porque no está en la tabla de la columna correspondiente a la tabla
--Pero que en teoría si exite en la otra tabla pero no se están relacionando por medio de la declaración de on
select a.nombre, a.apellido, c.carrera
from platzi.alumnos as a
	full outer join platzi.carreras as c
		on a.carrera_id = c.id
	where c.id is null;


-----------------------------------
'''JOINs'''
-----------------------------------

/**
  * Tipos de JOIN
  */
-- Left Join Exclusivo: Intersección --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	LEFT JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
WHERE c.id IS NULL;

-- Left Join --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	LEFT JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
ORDER BY c.id DESC;

-- Right Join Exclusivo: Intersección --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	RIGHT JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
WHERE a.id IS NULL
ORDER BY c.id;

-- Right Join --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	RIGHT JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
ORDER BY c.id DESC;

-- Inner Join: Producto cartesiano --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	INNER JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
ORDER BY c.id DESC;

-- Diferencia simétrica --
SELECT 	a.nombre,
		a.apellido,
		a.carrera_id,
		c.id,
		c.carrera
FROM	platzi.alumnos AS a
	FULL OUTER JOIN platzi.carreras AS c
	ON a.carrera_id = c.id
ORDER BY a.carrera_id DESC, c.id DESC;


-----------------------------------
'''Triangulando'''
-----------------------------------
-- Funcion lpad --
SELECT lpad('sql', 15, '*');

-- Lpad con incrementales --
SELECT lpad ('sql', id, '*')
FROM platzi.alumnos
WHERE id < 10;

-- Generar un triángulo usando Lpad --
SELECT lpad ('*', id, '*')
FROM platzi.alumnos
WHERE id < 4;

-- Desordenando el triángulo --
SELECT lpad ('*', id, '*')
FROM platzi.alumnos
WHERE id < 10
ORDER BY carrera_id;

-- Tabla con row_id --
SELECT *
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id <= 5;

-- lpad con row_id --
SELECT lpad('*', CAST (row_id AS int), '*')
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id <= 10;

-- Reordenando lpad con row_id --
SELECT lpad('*', CAST (row_id AS int), '*')
FROM (
	SELECT ROW_NUMBER() OVER() AS row_id, *
	FROM platzi.alumnos
) AS alumnos_with_row_num
WHERE row_id <= 10;

-- Funcion lpad --
SELECT rpad('sql', 15, '*');

-- Lpad con incrementales --
SELECT rpad ('sql', id, '*')
FROM platzi.alumnos
WHERE id < 10;

-- Generar un triángulo usando Lpad --
SELECT rpad ('*', id, '*')
FROM platzi.alumnos
WHERE id < 10;

-----------------------------------
'''Generando rangos'''
-----------------------------------

/**
  * Generar rangos en tuplas
  */

-- Genera una serie del 1 al 4 --
SELECT  *
FROM    generate_series(1,4);

-- Genera una serie decreciente de 5 a 1 de 2 en 2 --
SELECT  *
FROM generate_series(5,1,-2);

-- Genera un arreglo con 0 tuplas --
SELECT *
FROM generate_series(3,4);

SELECT *
FROM generate_series(4,3);

SELECT *
FROM generate_series(4,4);

SELECT *
FROM generate_series(3,4,-1);

-- Serie de 1.1 hasta 4 o menos paso de 1.3 --
SELECT generate_series(1.1, 4, 1.3);

-- Genera una secuencia de fechas empezando en la fecha actual
-- Con una separación de 7 días (1 semana) con el operador + de fecha
SELECT current_date + s.a AS dates
FROM generate_series(0,14,7) AS s(a);

-- Genera una secuencia de 10 en 10 horas --
SELECT * FROM generate_series('2020-09-01 00:00'::timestamp,
                              '2020-09-04 12:00', '10 hours');

-- Join con secuencia --
SELECT 	a.id,
		a.nombre,
		a.apellido,
		a.carrera_id,
		s.a
FROM	platzi.alumnos AS a
	INNER JOIN	generate_series(0,10) AS s(a)
	ON s.a = a.carrera_id
ORDER BY a.carrera_id;

SELECT  lpad ('*', generate_series, '*')
FROM    generate_series(1,10);

-- Generate independent ordinality --
SELECT  *
FROM    generate_series(1,10) WITH ordinality;

-- Use ordinality for lpad --
SELECT  lpad('*', CAST(ordinality AS int), '*')
FROM    generate_series(1,10) WITH ordinality;

-- Probando en series distintas --
SELECT  lpad('*', CAST(ordinality AS int), '*')
FROM    generate_series(10,2, -2) WITH ordinality;

-----------------------------------
'''Regularizando expresiones'''
-----------------------------------
--las expresiones regulares son una forma contraida de hacer una validación de patrones muy compleja
--como una ecuación matemática, dependiendo la teoria, en este caso se parecen a las de teoria de conjuntos o la place
--Tu filtro podría ser más facíl de hacer si dominas las expresiones regulares

SELECT email
FROM platzi.alumnos
WHERE email ~*'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}';
--  "~*", con este se  inicializa la expresión regular


SELECT email
FROM platzi.alumnos
WHERE email ~*'[A-Z0-9._%+-]+@google[A-Z0-9.-]+\.[A-Z]{2,4}';
