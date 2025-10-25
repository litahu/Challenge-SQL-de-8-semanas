# 📌 **Caso práctico Nº 2: Pizza Runner**

<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_2.JPG"></kbd> <br>
</p>
<br>

¿Sabías que se consumen más de 115 millones de kilos de pizza al día en todo el mundo? (Bueno, según Wikipedia…)

Danny estaba navegando por su feed de Instagram cuando algo realmente le llamó la atención: "¡El estilo retro de los 80 y la pizza son el futuro!"


## 📂**Historia de negocio**

A Danny le convenció la idea, pero sabía que la pizza por sí sola no lo iba a ayudar a obtener fondos iniciales para expandir su nuevo Pizza Empire, así que tuvo otra idea genial para combinarla: iba a Uberizarla , ¡y así se lanzó Pizza Runner!

Danny comenzó reclutando "corredores" para entregar pizza fresca desde la sede de Pizza Runner (también conocida como la casa de Danny) y también agotó su tarjeta de crédito para pagar a desarrolladores independientes para que crearan una aplicación móvil para aceptar pedidos de los clientes.

### **Objetivo**
1. **Optimizar las operaciones de Pizza Runner**
2. **Dirigir mejor a sus corredores**


## 📂**Análisis de datos**
Danny ha compartido contigo 3 conjuntos de datos clave para este estudio de caso:
* corredores
* pedido_clientes
* ordenes_corredores
* nombre_pizza
* recetas_piZza
* ingredientes_pizza

<br>

```
-- -------------------------------
-- Creación de tablas
-- -------------------------------

DROP TABLE IF EXISTS runners;
DROP TABLE IF EXISTS customer_orders;
DROP TABLE IF EXISTS runner_orders;
DROP TABLE IF EXISTS pizza_names;
DROP TABLE IF EXISTS pizza_recipes;
DROP TABLE IF EXISTS pizza_toppings;

CREATE TABLE runners (
    runner_id INT PRIMARY KEY,
    registration_date DATE
);

CREATE TABLE customer_orders (
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusion VARCHAR(10),
    extras VARCHAR(10),
    order_time DATETIME
);

CREATE TABLE runner_orders (
    order_id INT,
    runner_id INT,
    pickup_time DATETIME,
    distance VARCHAR(10), -- Ejemplo: '20km'
    duration VARCHAR(10), -- Ejemplo: '30mins'
    cancellation TEXT
);

CREATE TABLE pizza_names (
    pizza_id INT PRIMARY KEY,
    pizza_name VARCHAR(50)
);

CREATE TABLE pizza_recipes (
    pizza_id INT,
    toppings TEXT
);

CREATE TABLE pizza_toppings (
    topping_id INT PRIMARY KEY,
    topping_name TEXT
);

-- -------------------------------
-- Agregando valores a las tablas
-- -------------------------------

-- Datos corredores
INSERT INTO runners (runner_id, registration_date) VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


-- Datos pedido_clientes
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusion, extras, order_time) VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Datos ordenes_corredores
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4km', '40 mins', NULL),
  (5, 3, '2020-01-08 21:10:57', '10km', '15 mins', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25 mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4km', '15 mins', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10 mins', NULL);

-- Datos nombre_pizza
INSERT INTO pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- Datos recetas_pizZa
INSERT INTO pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- Datos ingredientes_pizza
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
```

Puede inspeccionar el diagrama de relación de entidades y los datos de ejemplo a continuación:

<p align="center">
  <kbd> <img width="550" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/02_PizzaRunner/02_DER.PNG"></kbd> <br>
  Imagen 1 — Diagrama de relación de miembros, venta y productos de Danny's Diner

<br>

### Métricas de pizza
---
1. ¿Cuántas pizzas se pidieron?
```
SELECT
	[Total de pizzas vendidas] = COUNT([pizza_id])
FROM [Challenge_sql].[dbo].[customer_orders];
```
2. ¿Cuántos pedidos de clientes únicos se realizaron?
```
SELECT
	[customer_id],
	COUNT(*) AS Total_ordenes
FROM [Challenge_sql].[dbo].[customer_orders]
GROUP BY [customer_id];
```
3. ¿Cuántos pedidos entregados con éxito fueron realizados por cada corredor?
```
SELECT 
  runner_id,
  COUNT(*) AS pedidos_exitosos
FROM [Challenge_sql].[dbo].[runner_orders]
WHERE pickup_time IS NOT NULL
  AND (cancellation IS NULL OR CAST(cancellation AS VARCHAR(MAX)) = '')
GROUP BY runner_id;
```
4. ¿Cuántas pizzas de cada tipo se entregaron?
```
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
```
5. ¿Cuántos vegetarianos y carnívoros pidió cada cliente?
```
SELECT 
  co.customer_id,
  SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS total_vegetarianas,
  SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS total_carnivoras
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[pizza_names] pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id
ORDER BY co.customer_id;
```
6. ¿Cuál fue el número máximo de pizzas entregadas en un solo pedido?
```
SELECT TOP 1 
  co.order_id,
  COUNT(*) AS total_pizzas_entregadas
FROM [Challenge_sql].[dbo].[customer_orders]  co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY co.order_id
ORDER BY total_pizzas_entregadas DESC;
```
7. Para cada cliente, ¿cuántas pizzas entregadas tuvieron al menos 1 cambio y cuántas no tuvieron cambios?
```
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
```
8. ¿Cuántas pizzas se entregaron que tenían exclusiones y extras?
```
SELECT 
  COUNT(*) AS pizzas_con_exclusiones_y_extras
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
  AND (co.exclusion IS NOT NULL AND co.exclusion <> '')
  AND (co.extras IS NOT NULL AND co.extras <> '');
```
9. ¿Cuál fue el volumen total de pizzas pedidas durante cada hora del día?
```
SELECT 
  DATEPART(HOUR, co.order_time) AS hora,
  COUNT(*) AS total_pizzas
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY DATEPART(HOUR, co.order_time)
ORDER BY hora;
```
10. ¿Cuál fue el volumen de pedidos para cada día de la semana?
```
SELECT 
  DATENAME(WEEKDAY, co.order_time) AS dia_semana,
  COUNT(DISTINCT co.order_id) AS total_pedidos
FROM [Challenge_sql].[dbo].[customer_orders] co
JOIN [Challenge_sql].[dbo].[runner_orders] ro ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
  AND (ro.cancellation IS NULL OR CAST(ro.cancellation AS VARCHAR(MAX)) = '')
GROUP BY DATENAME(WEEKDAY, co.order_time)
ORDER BY total_pedidos DESC;
```


### Experiencia del corredor y del cliente
---
1. ¿Cuántos corredores se inscribieron para cada período de 1 semana? (es decir, semana de inicio 2021-01-01)
```
    cd terraform
```
2. ¿Cuál fue el tiempo promedio en minutos que tardó cada corredor en llegar a la sede de Pizza Runner para recoger el pedido?
```
    terraform init
```
3. ¿Existe alguna relación entre la cantidad de pizzas y el tiempo que tarda en prepararse el pedido?
```
    terraform apply
```
4. ¿Cuál fue la distancia promedio recorrida por cada cliente?
```
    terraform apply
```
5. ¿Cuál fue la diferencia entre los tiempos de entrega más largos y más cortos para todos los pedidos?
```
    terraform apply
```
6. ¿Cuál fue la velocidad promedio de cada corredor en cada entrega y observa alguna tendencia en estos valores?
```
    terraform apply
```
7. ¿Cuál es el porcentaje de entrega exitosa de cada corredor?
```
    terraform apply
```

### Optimización de ingredientes
---
1. ¿Cuáles son los ingredientes estándar de cada pizza?
```
    cd terraform
```
2. ¿Cuál fue el extra añadido más comúnmente?
```
    terraform init
```
3. ¿Cuál fue la exclusión más común?
```
    terraform apply
```
4. Genere un elemento de pedido para cada registro de la customers_orderstabla en el formato de uno de los siguientes:
* Meat Lovers
* Meat Lovers - Exclude Beef
* Meat Lovers - Extra Bacon
* Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```
    terraform apply
```
5. Genere una lista de ingredientes separados por comas y ordenada alfabéticamente para cada pedido de pizza de la customer_orderstabla y agregue un 2xdelante de cualquier ingrediente relevante
* Por ejemplo:"Meat Lovers: 2xBacon, Beef, ... , Salami"

```
    terraform apply
```
6. ¿Cuál es la cantidad total de cada ingrediente utilizado en todas las pizzas entregadas ordenadas por frecuencia primero?
```
    terraform apply
```

### Precios y calificaciones
---
1. Si una pizza Meat Lovers cuesta $12 y una vegetariana cuesta $10 y no hay cargos por cambios, ¿cuánto dinero ganó Pizza Runner hasta ahora si no hay cargos por envío?
```
    cd terraform
```
2. ¿Qué pasa si hay un cargo adicional de $1 por cualquier pizza extra?
* Agregar queso cuesta $1 extra
```
    terraform init
```
3. El equipo de Pizza Runner ahora quiere agregar un sistema de calificación adicional que permita a los clientes calificar a su corredor. ¿Cómo diseñarías una tabla adicional para este nuevo conjunto de datos? Genera un esquema para esta nueva tabla e inserta tus propios datos para calificaciones para cada pedido de cliente exitoso entre 1 y 5.
```
    terraform apply
```
4. Utilizando la tabla recién generada, ¿puede unir toda la información para formar una tabla que contenga la siguiente información para entregas exitosas?
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Tiempo entre el pedido y la recogida
* Duración de la entrega
* Velocidad media
* Número total de pizzas

```
    terraform apply
```
5. Si una pizza para amantes de la carne costaba $12 y una vegetariana $10, precios fijos sin costo por extras y a cada corredor se le paga $0,30 por kilómetro recorrido, ¿cuánto dinero le queda a Pizza Runner después de estas entregas?
```
    terraform apply
```


## 📂**Conclusiones**




<br>






