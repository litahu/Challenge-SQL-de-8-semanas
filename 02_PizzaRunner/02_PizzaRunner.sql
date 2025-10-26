


Use [Challenge_sql];

-- -------------------------------
-- Exploración inicial
-- -------------------------------

-- Verificar cantidad de registros por tabla
SELECT COUNT(*) AS total_runners FROM [Challenge_sql].[dbo].[runners];
SELECT COUNT(*) AS total_orders FROM [Challenge_sql].[dbo].[customer_orders];
SELECT COUNT(*) AS total_runner_orders FROM [Challenge_sql].[dbo].[runner_orders];
SELECT COUNT(*) AS total_pizzas FROM [Challenge_sql].[dbo].[pizza_names];
SELECT COUNT(*) AS total_recipes FROM [Challenge_sql].[dbo].[pizza_recipes];
SELECT COUNT(*) AS total_toppings FROM [Challenge_sql].[dbo].[pizza_toppings];

-- -------------------------------
-- Detección de valores nulos
-- -------------------------------
-- Buscar valores nulos en runner_orders
SELECT * FROM [Challenge_sql].[dbo].[runner_orders]
WHERE pickup_time IS NULL OR distance IS NULL OR duration IS NULL;

-- Buscar duplicados en customer_orders
SELECT order_id, customer_id, COUNT(*) AS repeticiones
FROM [Challenge_sql].[dbo].[customer_orders]
GROUP BY order_id, customer_id
HAVING COUNT(*) > 1;

-- -------------------------------
-- Normalización de columnas
-- -------------------------------
-- Crear vista limpia para análisis
CREATE VIEW clean_runner_orders AS
SELECT 
  order_id,
  runner_id,
  pickup_time,
  CAST(REPLACE(distance, 'km', '') AS FLOAT) AS distance_km,
  CAST(REPLACE(REPLACE(duration, 'minutes', ''), 'mins', '') AS INT) AS duration_min,
  CASE 
    WHEN cancellation IS NULL OR CAST(cancellation AS VARCHAR(MAX)) = '' THEN 'Completed'
    ELSE CAST(cancellation AS VARCHAR(MAX))
  END AS status
FROM [Challenge_sql].[dbo].[runner_orders];

-- -------------------------------
-- Unión de tablas
-- -------------------------------
SELECT * FROM [Challenge_sql].[dbo].[runner_orders];
SELECT * FROM [Challenge_sql].[dbo].[customer_orders];

-- Unir customer_orders con runner_orders y pizza_names
SELECT 
  co.order_id,
  co.customer_id,
  pn.pizza_name,
  ro.runner_id,
  ro.pickup_time,
  ro.distance,
  ro.duration,
  ro.cancellation
FROM [Challenge_sql].[dbo].[customer_orders] co
LEFT JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
LEFT JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id;



-- -------------------------------
-- Metricas claves
-- -------------------------------
-- Tiempo promedio por corredor
SELECT runner_id, AVG(distance_km) AS avg_km, AVG(duration_min) AS avg_min
FROM clean_runner_orders
WHERE status = 'Completed'
GROUP BY runner_id;

-- Total de cancelaciones por tipo
SELECT status, COUNT(*) AS total_cancelaciones
FROM clean_runner_orders
WHERE status LIKE '%Cancellation%'
GROUP BY status;



-- Ver ingredientes de cada pizza
SELECT 
  pr.pizza_id,
  pn.pizza_name,
  pt.topping_name
FROM [Challenge_sql].[dbo].[pizza_recipes] pr
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON pr.pizza_id = pn.pizza_id
CROSS APPLY STRING_SPLIT(CAST(pr.toppings AS VARCHAR(MAX)), ',') AS split
JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON pt.topping_id = CAST(split.value AS INT);


-- -------------------------------
-- Análisis de datos 
-- -------------------------------

/****** A. Métricas de pizza ******/
-- 1.¿Cuántas pizzas se pidieron?
SELECT
	[Total de pizzas vendidas] = COUNT([pizza_id])
FROM [Challenge_sql].[dbo].[customer_orders];

-- 2.¿Cuántos pedidos de clientes únicos se realizaron?
SELECT
	[customer_id],
	COUNT(*) AS Total_ordenes
FROM [Challenge_sql].[dbo].[customer_orders]
GROUP BY [customer_id];

-- 3.¿Cuántos pedidos entregados con éxito fueron realizados por cada corredor?
SELECT 
  runner_id,
  COUNT(*) AS pedidos_exitosos
FROM [Challenge_sql].[dbo].[runner_orders]
WHERE pickup_time IS NOT NULL
  AND (cancellation IS NULL OR CAST(cancellation AS VARCHAR(MAX)) = '')
GROUP BY runner_id;

-- 4.¿Cuántas pizzas de cada tipo se entregaron?
SELECT 
  pn.pizza_name,
  COUNT(*) AS total_entregadas
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY pn.pizza_name
ORDER BY total_entregadas DESC;

-- 5.¿Cuántos vegetarianos y carnívoros pidió cada cliente?
SELECT 
  co.customer_id,
  SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS total_vegetarianas,
  SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS total_carnivoras
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- 6.¿Cuál fue el número máximo de pizzas entregadas en un solo pedido?
SELECT TOP 1 
  co.order_id,
  COUNT(*) AS total_pizzas_entregadas
FROM [Challenge_sql].[dbo].[customer_orders]  co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY co.order_id
ORDER BY total_pizzas_entregadas DESC;

-- 7.Para cada cliente, ¿cuántas pizzas entregadas tuvieron al menos 1 cambio y cuántas no tuvieron cambios?
SELECT 
  co.customer_id,
  SUM(CASE WHEN (co.exclusion IS NOT NULL AND co.exclusion <> '') 
            OR (co.extras IS NOT NULL AND co.extras <> '') THEN 1 ELSE 0 END) AS con_cambios,
  SUM(CASE WHEN (co.exclusion IS NULL OR co.exclusion = '') 
            AND (co.extras IS NULL OR co.extras = '') THEN 1 ELSE 0 END) AS sin_cambios
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY co.customer_id;


-- 8.¿Cuántas pizzas se entregaron que tenían exclusiones y extras?
SELECT 
  COUNT(*) AS pizzas_con_exclusiones_y_extras
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
  AND (co.exclusion IS NOT NULL AND co.exclusion <> '')
  AND (co.extras IS NOT NULL AND co.extras <> '');

-- 9.¿Cuál fue el volumen total de pizzas pedidas durante cada hora del día?
SELECT 
  DATEPART(HOUR, co.order_time) AS hora,
  COUNT(*) AS total_pizzas
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY DATEPART(HOUR, co.order_time)
ORDER BY hora;

-- 10.¿Cuál fue el volumen de pedidos para cada día de la semana?
SELECT 
  DATENAME(WEEKDAY, co.order_time) AS dia_semana,
  COUNT(DISTINCT co.order_id) AS total_pedidos
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY DATENAME(WEEKDAY, co.order_time)
ORDER BY total_pedidos DESC;


/****** B. Corredor y experiencia del cliente ******/

-- 1.¿Cuántos corredores se inscribieron para cada período de 1 semana? (es decir, semana de inicio 2021-01-01)
SELECT 
  DATEPART(WEEK, [registration_date]) AS semana,
  COUNT(*) AS corredores_registrados
FROM [Challenge_sql].[dbo].[runners]
GROUP BY DATEPART(WEEK, [registration_date])
ORDER BY semana;

/* 2.¿Cuál fue el tiempo promedio en minutos que tardó cada corredor en llegar a la sede de Pizza Runner
para recoger el pedido? */
SELECT 
  [runner_id],
  AVG(CAST(REPLACE(REPLACE([duration], 'minutes', ''), 'mins', '') AS INT)) AS tiempo_promedio_min
FROM [Challenge_sql].[dbo].[runner_orders]
WHERE [pickup_time] IS NOT NULL
  AND ([cancellation] IS NULL OR CAST([cancellation] AS VARCHAR(MAX)) = '')
GROUP BY [runner_id];

-- 3.¿Existe alguna relación entre la cantidad de pizzas y el tiempo que tarda en prepararse el pedido?
WITH cantidad_pizzas AS (
  SELECT 
    [order_id],
    COUNT(*) AS total_pizzas
  FROM [Challenge_sql].[dbo].[customer_orders]
  GROUP BY [order_id]
)
SELECT 
  cp.[total_pizzas],
  CAST(REPLACE(REPLACE(ro.[duration], 'minutes', ''), 'mins', '') AS INT) AS duracion_min
FROM cantidad_pizzas cp
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON cp.[order_id] = ro.[order_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '');

-- 4.¿Cuál fue la distancia promedio recorrida por cada cliente?
SELECT 
  co.[customer_id],
  AVG(CAST(REPLACE(ro.[distance], 'km', '') AS FLOAT)) AS distancia_promedio_km
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '')
GROUP BY co.[customer_id];

-- 5.¿Cuál fue la diferencia entre los tiempos de entrega más largos y más cortos para todos los pedidos?
SELECT 
  MAX(CAST(REPLACE(REPLACE([duration], 'minutes', ''), 'mins', '') AS INT)) -
  MIN(CAST(REPLACE(REPLACE([duration], 'minutes', ''), 'mins', '') AS INT)) AS diferencia_minutos
FROM [Challenge_sql].[dbo].[runner_orders]
WHERE [pickup_time] IS NOT NULL
  AND ([cancellation] IS NULL OR CAST([cancellation] AS VARCHAR(MAX)) = '');

-- 6.¿Cuál fue la velocidad promedio de cada corredor en cada entrega y observa alguna tendencia en estos valores?
SELECT 
  [runner_id],
  [order_id],
  ROUND(CAST(REPLACE([distance], 'km', '') AS FLOAT) / 
        CAST(REPLACE(REPLACE([duration], 'minutes', ''), 'mins', '') AS FLOAT), 2) AS velocidad_km_por_min
FROM [Challenge_sql].[dbo].[runner_orders]
WHERE [pickup_time] IS NOT NULL
  AND ([cancellation] IS NULL OR CAST([cancellation] AS VARCHAR(MAX)) = '')
ORDER BY [runner_id], [pickup_time];

-- 7.¿Cuál es el porcentaje de entrega exitosa de cada corredor?
SELECT 
  [runner_id],
  COUNT(*) AS total_entregas,
  SUM(CASE WHEN [pickup_time] IS NOT NULL AND 
                 ([cancellation] IS NULL OR CAST([cancellation] AS VARCHAR(MAX)) = '') 
           THEN 1 ELSE 0 END) AS entregas_exitosas,
  ROUND(100.0 * SUM(CASE WHEN [pickup_time] IS NOT NULL AND 
                          ([cancellation] IS NULL OR CAST([cancellation] AS VARCHAR(MAX)) = '') 
                    THEN 1 ELSE 0 END) / COUNT(*), 2) AS porcentaje_exito
FROM [Challenge_sql].[dbo].[runner_orders]
GROUP BY [runner_id];


/****** C. Optimización de ingredientes ******/

-- 1.¿Cuáles son los ingredientes estándar de cada pizza?
SELECT 
  pn.[pizza_name],
  pt.[topping_name]
FROM [Challenge_sql].[dbo].[pizza_recipes] pr
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON pr.[pizza_id] = pn.[pizza_id]
CROSS APPLY STRING_SPLIT(CAST(pr.[toppings] AS VARCHAR(MAX)), ',') AS t
JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON CAST(t.[value] AS INT) = pt.[topping_id]
ORDER BY pn.[pizza_name], CAST(pt.[topping_name] AS VARCHAR(MAX));

-- 2.¿Cuál fue el extra añadido más comúnmente?
SELECT 
  CAST(pt.[topping_name] AS VARCHAR(MAX)) AS topping_name,
  COUNT(*) AS veces_agregado
FROM [Challenge_sql].[dbo].[customer_orders] co
CROSS APPLY STRING_SPLIT(CAST(co.[extras] AS VARCHAR(MAX)), ',') AS e
JOIN [Challenge_sql].[dbo].[pizza_toppings] pt 
  ON TRY_CAST(LTRIM(RTRIM(e.[value])) AS INT) = pt.[topping_id]
WHERE co.[extras] IS NOT NULL AND co.[extras] <> ''
GROUP BY CAST(pt.[topping_name] AS VARCHAR(MAX))
ORDER BY veces_agregado DESC;

-- 3.¿Cuál fue la exclusión más común?
SELECT 
  CAST(pt.[topping_name] AS VARCHAR(MAX)) AS topping_name,
  COUNT(*) AS veces_excluido
FROM [Challenge_sql].[dbo].[customer_orders] co
CROSS APPLY STRING_SPLIT(CAST(co.[exclusion] AS VARCHAR(MAX)), ',') AS ex
JOIN [Challenge_sql].[dbo].[pizza_toppings] pt 
  ON TRY_CAST(LTRIM(RTRIM(ex.[value])) AS INT) = pt.[topping_id]
WHERE co.[exclusion] IS NOT NULL AND co.[exclusion] <> ''
GROUP BY CAST(pt.[topping_name] AS VARCHAR(MAX))
ORDER BY veces_excluido DESC;

-- 4.Genere un elemento de pedido para cada registro de la customers_orderstabla en el formato de uno de los siguientes:
-->>> Meat Lovers
--> Meat Lovers - Exclude Beef
--> Meat Lovers - Extra Bacon
--> Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
SELECT 
  co.[order_id],
  pn.[pizza_name] +
    CASE 
      WHEN co.[exclusion] IS NOT NULL AND co.[exclusion] <> '' THEN 
        ' - Exclude ' + (
          SELECT STRING_AGG(CAST(pt.[topping_name] AS VARCHAR(MAX)), ', ')
          FROM STRING_SPLIT(CAST(co.[exclusion] AS VARCHAR(MAX)), ',') AS ex
          JOIN [Challenge_sql].[dbo].[pizza_toppings] pt 
            ON TRY_CAST(LTRIM(RTRIM(ex.[value])) AS INT) = pt.[topping_id]
        )
      ELSE ''
    END +
    CASE 
      WHEN co.[extras] IS NOT NULL AND co.[extras] <> '' THEN 
        ' - Extra ' + (
          SELECT STRING_AGG(CAST(pt.[topping_name] AS VARCHAR(MAX)), ', ')
          FROM STRING_SPLIT(CAST(co.[extras] AS VARCHAR(MAX)), ',') AS ex
          JOIN [Challenge_sql].[dbo].[pizza_toppings] pt 
            ON TRY_CAST(LTRIM(RTRIM(ex.[value])) AS INT) = pt.[topping_id]
        )
      ELSE ''
    END AS descripcion_pedido
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.[pizza_id] = pn.[pizza_id]
ORDER BY co.[order_id];


/* 5.Genere una lista de ingredientes separados por comas y ordenada alfabéticamente para cada pedido de 
pizza de la customer_orderstabla y agregue un 2xdelante de cualquier ingrediente relevante 
--> Por ejemplo:"Meat Lovers: 2xBacon, Beef, ... , Salami" */
WITH receta_base AS (
  SELECT 
    co.[order_id],
    pt.[topping_name]
  FROM [Challenge_sql].[dbo].[customer_orders] co
  JOIN [Challenge_sql].[dbo].[pizza_recipes] pr ON co.[pizza_id] = pr.[pizza_id]
  CROSS APPLY STRING_SPLIT(CAST(pr.[toppings] AS VARCHAR(MAX)), ',') AS t
  JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON CAST(t.[value] AS INT) = pt.[topping_id]
),
exclusiones AS (
  SELECT 
    co.[order_id],
    pt.[topping_name]
  FROM [Challenge_sql].[dbo].[customer_orders] co
  CROSS APPLY STRING_SPLIT(CAST(co.[exclusion] AS VARCHAR(MAX)), ',') AS ex
  JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON TRY_CAST(LTRIM(RTRIM(ex.[value])) AS INT) = pt.[topping_id]
),
extras AS (
  SELECT 
    co.[order_id],
    pt.[topping_name]
  FROM [Challenge_sql].[dbo].[customer_orders] co
  CROSS APPLY STRING_SPLIT(CAST(co.[extras] AS VARCHAR(MAX)), ',') AS ex
  JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON TRY_CAST(LTRIM(RTRIM(ex.[value])) AS INT) = pt.[topping_id]
),
ingredientes_finales AS (
  SELECT 
    rb.[order_id],
    CASE 
      WHEN e.[topping_name] IS NOT NULL THEN '2x' + CAST(rb.[topping_name] AS VARCHAR(MAX))
      ELSE CAST(rb.[topping_name] AS VARCHAR(MAX))
    END AS ingrediente
  FROM receta_base rb
  LEFT JOIN exclusiones x 
    ON rb.[order_id] = x.[order_id] 
    AND CAST(rb.[topping_name] AS VARCHAR(MAX)) = CAST(x.[topping_name] AS VARCHAR(MAX))
  LEFT JOIN extras e 
    ON rb.[order_id] = e.[order_id] 
    AND CAST(rb.[topping_name] AS VARCHAR(MAX)) = CAST(e.[topping_name] AS VARCHAR(MAX))
  WHERE x.[topping_name] IS NULL
  UNION ALL
  SELECT 
    [order_id],
    '2x' + CAST([topping_name] AS VARCHAR(MAX))
  FROM extras
)
SELECT 
  co.[order_id],
  CAST(pn.[pizza_name] AS VARCHAR(MAX)) + ': ' + 
    STRING_AGG(i.[ingrediente], ', ') 
    WITHIN GROUP (ORDER BY i.[ingrediente]) AS ingredientes_pedido
FROM ingredientes_finales i
JOIN [Challenge_sql].[dbo].[customer_orders] co ON i.[order_id] = co.[order_id]
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.[pizza_id] = pn.[pizza_id]
GROUP BY co.[order_id], CAST(pn.[pizza_name] AS VARCHAR(MAX))
ORDER BY co.[order_id];


/* 6.¿Cuál es la cantidad total de cada ingrediente utilizado en todas las pizzas entregadas ordenadas por 
frecuencia primero? */
WITH entregas_exitosas AS (
  SELECT DISTINCT co.[order_id], co.[pizza_id]
  FROM [Challenge_sql].[dbo].[customer_orders] co
  JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
  WHERE ro.[pickup_time] IS NOT NULL
    AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '')
),
ingredientes_usados AS (
  SELECT 
    pt.[topping_name]
  FROM entregas_exitosas e
  JOIN [Challenge_sql].[dbo].[pizza_recipes] pr ON e.[pizza_id] = pr.[pizza_id]
  CROSS APPLY STRING_SPLIT(CAST(pr.[toppings] AS VARCHAR(MAX)), ',') AS t
  JOIN [Challenge_sql].[dbo].[pizza_toppings] pt ON CAST(t.[value] AS INT) = pt.[topping_id]
)
SELECT 
  CAST([topping_name] AS VARCHAR(MAX)) AS ingrediente,
  COUNT(*) AS cantidad_usada
FROM ingredientes_usados
GROUP BY CAST([topping_name] AS VARCHAR(MAX))
ORDER BY cantidad_usada DESC;


/****** D. Precio y calificaciones ******/

/* 1.Si una pizza Meat Lovers cuesta $12 y una vegetariana cuesta $10 y no hay cargos 
por cambios, ¿cuánto dinero ganó Pizza Runner hasta ahora si no hay cargos por envío? */
SELECT 
  SUM(CASE 
        WHEN pn.[pizza_name] = 'Meatlovers' THEN 12
        WHEN pn.[pizza_name] = 'Vegetarian' THEN 10
        ELSE 0
      END) AS total_ingresos
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.[pizza_id] = pn.[pizza_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '');

/* 2.¿Qué pasa si hay un cargo adicional de $1 por cualquier pizza extra?
Agregar queso cuesta $1 extra */
SELECT 
  SUM(
    CASE 
      WHEN pn.[pizza_name] = 'Meatlovers' THEN 12
      WHEN pn.[pizza_name] = 'Vegetarian' THEN 10
      ELSE 0
    END
    + ISNULL(LEN(co.[extras]) - LEN(REPLACE(co.[extras], ',', '')) + 1, 0) * 1
  ) AS total_ingresos_con_extras
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.[pizza_id] = pn.[pizza_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '');

/* 3.El equipo de Pizza Runner ahora quiere agregar un sistema de calificación adicional
que permita a los clientes calificar a su corredor. ¿Cómo diseñarías una tabla adicional
para este nuevo conjunto de datos? Genera un esquema para esta nueva tabla e inserta tus
propios datos para calificaciones para cada pedido de cliente exitoso entre 1 y 5. */
-- Crear tabla de calificaciones
CREATE TABLE [Challenge_sql].[dbo].[runner_ratings] (
  order_id INT PRIMARY KEY,
  rating INT CHECK (rating BETWEEN 1 AND 5)
);

-- Insertar calificaciones de ejemplo para pedidos exitosos
INSERT INTO [Challenge_sql].[dbo].[runner_ratings] (order_id, rating) VALUES
  (1, 5),
  (2, 4),
  (3, 5),
  (4, 3),
  (5, 4),
  (7, 5),
  (8, 4),
  (10, 5);

  SELECT * FROM [Challenge_sql].[dbo].[runner_ratings]

/* 4.Utilizando la tabla recién generada, ¿puede unir toda la información para formar una tabla
que contenga la siguiente información para entregas exitosas?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Tiempo entre el pedido y la recogida
Duración de la entrega
Velocidad media
Número total de pizzas */

SELECT 
  co.[customer_id],
  co.[order_id],
  ro.[runner_id],
  rr.[rating],
  co.[order_time],
  ro.[pickup_time],
  DATEDIFF(MINUTE, co.[order_time], ro.[pickup_time]) AS minutos_espera,
  CAST(REPLACE(REPLACE(ro.[duration], 'minutes', ''), 'mins', '') AS INT) AS duracion_min,
  ROUND(CAST(REPLACE(ro.[distance], 'km', '') AS FLOAT) / 
        NULLIF(CAST(REPLACE(REPLACE(ro.[duration], 'minutes', ''), 'mins', '') AS FLOAT), 0), 2) AS velocidad_km_por_min,
  (SELECT COUNT(*) 
   FROM [Challenge_sql].[dbo].[customer_orders] co2 
   WHERE co2.[order_id] = co.[order_id]) AS total_pizzas
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
JOIN [Challenge_sql].[dbo].[runner_ratings] rr ON co.[order_id] = rr.[order_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '')
GROUP BY co.[customer_id], co.[order_id], ro.[runner_id], rr.[rating], co.[order_time], ro.[pickup_time], ro.[distance], ro.[duration];


/* 5.Si una pizza para amantes de la carne costaba $12 y una vegetariana $10, 
precios fijos sin costo por extras y a cada corredor se le paga $0,30 por kilómetro recorrido,
¿cuánto dinero le queda a Pizza Runner después de estas entregas? */
SELECT 
  SUM(
    CASE 
      WHEN pn.[pizza_name] = 'Meatlovers' THEN 12
      WHEN pn.[pizza_name] = 'Vegetarian' THEN 10
      ELSE 0
    END
  ) - 
  SUM(CAST(REPLACE(ro.[distance], 'km', '') AS FLOAT) * 0.30) AS ganancia_neta
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.[order_id] = ro.[order_id]
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.[pizza_id] = pn.[pizza_id]
WHERE ro.[pickup_time] IS NOT NULL
  AND (ro.[cancellation] IS NULL OR CAST(ro.[cancellation] AS VARCHAR(MAX)) = '');







