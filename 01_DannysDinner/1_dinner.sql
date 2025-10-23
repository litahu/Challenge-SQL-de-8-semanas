SELECT *
FROM [Challenge_sql].[dbo].[members]

SELECT *
FROM [Challenge_sql].[dbo].[menu]

SELECT *
FROM [Challenge_sql].[dbo].[sales]

----------------------------------
--- PREGUNTAS CASO DE ESTUDIO 
----------------------------------
USE [Challenge_sql];

-- 1. �Cu�l es el monto total que gast� cada cliente en el restaurante?

SELECT
    B.customer_id AS Cliente,
    SUM(A.price) AS [Monto total]

FROM [Challenge_sql].[dbo].[menu] A
	JOIN [Challenge_sql].[dbo].[sales] B
		ON A.product_id = B.product_id
GROUP BY B.customer_id
ORDER BY [Monto total] DESC;

-- 2. �Cu�ntos d�as ha visitado cada cliente el restaurante?

SELECT
    customer_id AS Cliente,
    COUNT(DISTINCT order_date) AS Presente
FROM [Challenge_sql].[dbo].[sales]
GROUP BY customer_id
ORDER BY Presente DESC;

-- 3. �Cu�l fue el primer art�culo del men� comprado por cada cliente?

WITH PrimerCompra AS (
    SELECT
        A.customer_id AS Cliente,
        A.order_date AS Fecha,
        B.product_name AS [Men� comprado],
        ROW_NUMBER() OVER (PARTITION BY A.customer_id ORDER BY A.order_date ASC) AS fila
    FROM [Challenge_sql].[dbo].[sales] A
    JOIN [Challenge_sql].[dbo].[menu] B
        ON A.product_id = B.product_id
)
SELECT
    Cliente,
    Fecha,
    [Men� comprado]
FROM PrimerCompra
WHERE fila = 1
ORDER BY Cliente;

-- 4. �Cu�l es el art�culo m�s comprado del men� y cu�ntas veces lo compraron todos los clientes?

SELECT TOP 1
    m.product_name AS [Art�culo m�s comprado],
    COUNT(*) AS [Cantidad de veces comprado]
FROM [Challenge_sql].[dbo].[sales] s
JOIN [Challenge_sql].[dbo].[menu] m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(*) DESC;

-- 5. �Qu� art�culo fue el m�s popular para cada cliente?
WITH ConteoCompras AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS cantidad,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(*) DESC
        ) AS fila
    FROM [Challenge_sql].[dbo].[sales] s
    JOIN [Challenge_sql].[dbo].[menu] m
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT
    customer_id AS Cliente,
    product_name AS [Art�culo m�s popular],
    cantidad AS [Veces comprado]
FROM ConteoCompras
WHERE fila = 1
ORDER BY Cliente;

-- 6. �Qu� art�culo compr� primero el cliente despu�s de hacerse miembro?
WITH ComprasPosteriores AS (
    SELECT
        m.customer_id,
        s.order_date,
        me.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY m.customer_id
            ORDER BY s.order_date
        ) AS fila
    FROM [Challenge_sql].[dbo].[members] m
    JOIN [Challenge_sql].[dbo].[sales] s
        ON m.customer_id = s.customer_id
    JOIN [Challenge_sql].[dbo].[menu] me
        ON s.product_id = me.product_id
    WHERE s.order_date > m.join_date
)
SELECT
    customer_id AS Cliente,
    order_date AS [Fecha de compra],
    product_name AS [Primer art�culo comprado]
FROM ComprasPosteriores
WHERE fila = 1
ORDER BY Cliente;

-- 7. �Qu� art�culo se compr� justo antes de que el cliente se convirtiera en miembro?
WITH ComprasPrevias AS (
    SELECT
        m.customer_id,
        s.order_date,
        me.product_name,
        ROW_NUMBER() OVER (
            PARTITION BY m.customer_id
            ORDER BY s.order_date DESC
        ) AS fila
    FROM [Challenge_sql].[dbo].[members] m
    JOIN [Challenge_sql].[dbo].[sales] s
        ON m.customer_id = s.customer_id
    JOIN [Challenge_sql].[dbo].[menu] me
        ON s.product_id = me.product_id
    WHERE s.order_date < m.join_date
)
SELECT
    customer_id AS Cliente,
    order_date AS [Fecha de compra],
    product_name AS [Art�culo previo a membres�a]
FROM ComprasPrevias
WHERE fila = 1
ORDER BY Cliente;

-- 8. �Cu�l es el total de art�culos y el monto gastado por cada miembro antes de convertirse en miembro?
SELECT
    m.customer_id AS Cliente,
    COUNT(*) AS [Art�culos comprados],
    SUM(me.price) AS [Monto gastado]
FROM [Challenge_sql].[dbo].[members] m
JOIN [Challenge_sql].[dbo].[sales] s
    ON m.customer_id = s.customer_id
JOIN [Challenge_sql].[dbo].[menu] me
    ON s.product_id = me.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id
ORDER BY [Monto gastado] DESC;


-- 9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, �cu�ntos puntos tendr�a cada cliente? 
SELECT
    s.customer_id AS Cliente,
    SUM(
        CASE 
            WHEN me.product_name = 'sushi' THEN me.price * 10 * 2
            ELSE me.price * 10
        END
    ) AS [Puntos acumulados]
FROM [Challenge_sql].[dbo].[sales] s
JOIN [Challenge_sql].[dbo].[menu] me
    ON s.product_id = me.product_id
GROUP BY s.customer_id
ORDER BY [Puntos acumulados] DESC;

-- 10. En la primera semana despu�s de que un cliente se une al programa (incluida su fecha de uni�n), gana 2x puntos 
-- en todos los art�culos,no solo en sushi: �cu�ntos puntos tienen los clientes A y B al final de enero?

SELECT
    s.customer_id AS Cliente,
    SUM(
        CASE
            WHEN s.order_date BETWEEN m.join_date AND DATEADD(DAY, 6, m.join_date) THEN me.price * 10 * 2
            WHEN me.product_name = 'sushi' THEN me.price * 10 * 2
            ELSE me.price * 10
        END
    ) AS [Puntos hasta enero]
FROM [Challenge_sql].[dbo].[sales] s
JOIN [Challenge_sql].[dbo].[members] m
    ON s.customer_id = m.customer_id
JOIN [Challenge_sql].[dbo].[menu] me
    ON s.product_id = me.product_id
WHERE s.order_date <= '2025-01-31'
  AND s.customer_id IN ('A', 'B')
GROUP BY s.customer_id
ORDER BY [Puntos hasta enero] DESC;


