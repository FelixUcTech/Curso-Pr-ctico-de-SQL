-----------------------------------
'''Base de datos Distribuidas'''
-----------------------------------
"
La base de datos distribuida es aquella que se encuentra separada físicamente en varios servidores
Las ventajas
    Desarrollo modular
    Incrementa la confiabilidad
    Mejora el rendimiento
    Mayor disponibilidad
    Rapidez de respuesta
Desventajas
    Manejo de seguridad
    Complejidad de procesamiento
    Integridad de datos más compleja
    Costos

Hay diferentes tipos de bases de datos
    homogenias
    Pueden ser homogenias independientemente de su logar geográfico de servidor
        ejemplos:
            comparten distribución de linux
            usan el mismo motor de base de datos
            el mismo tipo de base de datos, manejados y sistema operativo
                        
    heterogenías

Arquitecturas
    Cliente - Servidor
    Par a par
    Multimanejador de bases de datos
        cuando tienes varios manejadores de bases de datos, pueden hasta relacionarse SQL y noSQL etc
    
Estrategías de diseño
    Top down
        Cuando la planeas muy bien, y determinas bien las responsabilidades dependiendo de tus necesidades
    Bottom up
        Si ya existe un servidor que están corriendo etc etc, cuando contruyes en función de lo que ya existe, y si tus necesidades 
        requieren cambios prácticameten solucionas con lo que tengas, aunque tengas que trabajar con diferentes manejadores, etc

Almacenamiento distribuido
    Fragmmentación de datos
        Que los tengas en el lugar donde te serva más o si replicas en todos lo servidores
        Dependera del performas requerido de acuerdo a los costos limites a pagar

Fragmentación (sharding)
    Horizontal separar por fila
    Vertical separar por columna
    Mixta algo mixta

Replicación
    Completa
    Parcial
    Sin replicación

Distribución de datos
    Centralizada
    Particionada
    Replicada
"
-----------------------------------
'''Queries distribuidos'''
-----------------------------------
--Cuando tenemos bases de datos distribuidas las consultas se vuelven peculiares y considerar diversos factores
--El parametro más importante es el tiempo de tranferencia de datos, y los costos añadidos de este tipo, en resumen, mueve lo que menos pese que te permita hacer correctametne el query
--ya sea por la prioridad, el tiempo o el costo

-----------------------------------
'''Sharding'''
-----------------------------------
--La pizza que no te puedes acabar tu solo porque siempre hay datos nuevos, y el servidor no se da abasto
--Entre más servidores, hay mayor capacidad de comerse la pizza
--Puede ser por zona geográfica
--Puede ser porque se están consultando bases de datos viejitas 
    --Cuando no aplicar el sharding
        --Joins entre shards
            --por la latencia de red
        --Baja elasticidad
            --Cambiar la estructura del shard ya no es tan facil
            --Cuando los datos se mueven demasido en poco tiempo
        --Reemplaza PK
            --La reindezación, 


-----------------------------------
'''Window functions'''
-----------------------------------
"
SE DEFINE COMO LA RELACIÓN QUE EXISTE ENNTRE UNA TUPLA, UN NA FILA EN PARTICULAR, Y EL RESTO DE ROW EN UNA PARTICIÓN O EN UN WINDOWS FREIND
    El window friend o marco de ventana es...
    esto nos ahorra hacer muchos selfjoins, es un poder de procesamiento con selfjoins y ayuda a reducir ese procesamiento
    Las window function corren al final, por lo que se recomienda hacer subquery si no se pueden hablar los parámetros
"
-- Obtener la colegiatura promedio por carrera --
SELECT 	*,
		AVG(colegiatura) OVER (PARTITION BY carrera_id)
FROM	platzi.alumnos;

-- Si no se especifica una partición se toma toda la info de la tabla --
SELECT 	*,
		AVG(colegiatura) OVER ()
FROM	platzi.alumnos;

-- Obtener la suma de las colegiaturas incrementales de menor a mayor --
-- Con order by se toamen todos los valores ordenados antes o iguales a la tupla actual --
SELECT 	*,
		SUM(colegiatura) OVER (ORDER BY colegiatura)
FROM	platzi.alumnos;

-- Obtener la suma de colegiaturas por carrera ordenadas por colegiatura de menor a mayor --
SELECT 	*,
		SUM(colegiatura) OVER (PARTITION BY carrera_id ORDER BY colegiatura)
FROM	platzi.alumnos;

-- Obtener el lugar que ocupa la tupla actual en el frame de carrera con orden por colegiatura de mayor a menor --
SELECT 	*,
		RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC)
FROM	platzi.alumnos;

-- Obtener el lugar que ocupa la tupla actual en el frame de carrera con orden por colegiatura de mayor a menor --
-- Con orden posterior --
SELECT 	*,
		RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC) AS brand_rank
FROM	platzi.alumnos
ORDER BY carrera_id, brand_rank;

-- Intento de wherer en el mismo query --
SELECT 	*,
		RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC) AS brand_rank
FROM	platzi.alumnos
WHERE	brand_rank < 3
ORDER BY carrera_id, brand_rank;

-- Filtrado where en subquery --
SELECT	*
FROM	(
	SELECT 	*,
			RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC) AS brand_rank
	FROM	platzi.alumnos
) AS	ranked_colegiaturas_por_carrerra
WHERE 	brand_rank < 3
ORDER BY brand_rank;

-----------------------------------
'''Window functions  particiones y agregaciones'''
-----------------------------------
-- Obtener el número de tupla sin un orden en particular --
SELECT ROW_NUMBER() OVER() AS row_id, *
FROM platzi.alumnos;

-- Obtener el número de tupla cuando ordenamos por fecha de incorporacion --
SELECT ROW_NUMBER() OVER(ORDER BY fecha_incorporacion) AS row_id, *
FROM platzi.alumnos;

-- Obtener el valor de un atributo de la primera tupla del window frame actual (global por default) --
SELECT FIRST_VALUE(colegiatura) OVER() AS row_id, *
FROM platzi.alumnos;

-- Obtener el valor de un atributo de la primera tupla del window frame actual --
-- La colegiatura de la persona que se inscribió primero por carrera --
SELECT FIRST_VALUE(colegiatura) OVER(PARTITION BY carrera_id ORDER BY fecha_incorporacion) AS row_id, *
FROM platzi.alumnos;

-- Obtener el valor de un atributo de la ultima tupla del window frame actual --
-- La colegiatura de la persona que se inscribió al final por carrera --
SELECT LAST_VALUE(colegiatura) OVER(PARTITION BY carrera_id ORDER BY fecha_incorporacion) AS row_id, *
FROM platzi.alumnos;

-- Obtener el valor de un atributo de la tupla numero n = 3 del window frame actual --
-- La colegiatura de la persona que se inscribió en lugar 3 por carrera --
SELECT nth_value(colegiatura, 3) OVER(PARTITION BY carrera_id ORDER BY fecha_incorporacion) AS row_id, *
FROM platzi.alumnos;

-- Rank Simple: Por cada elemento cuenta 1 generando espacios en el rank --
SELECT 	*,
		RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC) AS brand_rank
FROM	platzi.alumnos
ORDER BY carrera_id, brand_rank;

-- Rank Simple: Por cada grupo de lementos iguales cuenta 1 generando rank "denso" --
SELECT 	*,
		DENSE_RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura DESC) AS brand_rank
FROM	platzi.alumnos
ORDER BY carrera_id, brand_rank;

-- Percent Rank: Genera una distribución percentual siguiendo la fórmula (rank - 1) / (total rows - 1) --
SELECT 	*,
		PERCENT_RANK() OVER (PARTITION BY carrera_id ORDER BY colegiatura ASC) AS brand_rank
FROM	platzi.alumnos
ORDER BY carrera_id, brand_rank;