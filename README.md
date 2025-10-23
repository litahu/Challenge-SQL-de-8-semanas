
# 📌 **Caso práctico Nº 1: Dannys´Diner**

<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_1.JPG"></kbd> <br>
</p>
<br>

---
## 📂**Historia de fondo**

Medir el rendimiento empresarial es crucial para cualquier empresa. Esto ayuda a monitorear y evaluar el éxito o el fracaso de diversos procesos. De ese modo ante un estancamiento del flujo de caja, Dany se ha interesado por ampliar su cartera de clientes más leales como estrategia para revertir dicha situación. En ese contexto, la preparación empresarial exige aplicar métodos de gestión que permitan medir el rendimiento con precisión y mantener el negocio en marcha.
### **Objetivo**
1. **Categoría de productos por ventas**
2. **Crecimiento de demanda por cliente**
3. **Efectividad de la membresía**



## 📂**Análisis de datos**

```
USE Challenge_sql;

-- Tabla del menú
CREATE TABLE menu (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(50),
    price INTEGER
);

-- Tabla de miembros
CREATE TABLE members (
    customer_id VARCHAR(1) PRIMARY KEY,
    join_date DATE
);

-- Tabla de ventas con clave primaria artificial
CREATE TABLE sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY, -- clave primaria autoincremental
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);

-- Datos de ventas
INSERT INTO sales (customer_id, order_date, product_id) VALUES
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

-- Datos del menú
INSERT INTO menu (product_id, product_name, price) VALUES
(1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);

-- Datos de miembros
INSERT INTO members (customer_id, join_date) VALUES
('A', '2021-01-07'),
('B', '2021-01-09');
```
<p align="center">
  <kbd> <img width="550" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/01_DannysDinner/asset/q_1.PNG"></kbd> <br>
  Imagen 1 — Diagrama de relación de miembros, venta y productos de Dannys´Diner
</p>

<br>

1. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
```
SELECT
    B.customer_id AS Cliente,
    SUM(A.price) AS [Monto total]

FROM [Challenge_sql].[dbo].[menu] A
	JOIN [Challenge_sql].[dbo].[sales] B
		ON A.product_id = B.product_id
GROUP BY B.customer_id
ORDER BY [Monto total] DESC;
```

2. ¿Cuántos días ha visitado cada cliente el restaurante?
```
SELECT
    customer_id AS Cliente,
    COUNT(DISTINCT order_date) AS Presente
FROM [Challenge_sql].[dbo].[sales]
GROUP BY customer_id
ORDER BY Presente DESC;
```

3. ¿Cuál fue el primer artículo del menú comprado por cada cliente?
```
WITH PrimerCompra AS (
    SELECT
        A.customer_id AS Cliente,
        A.order_date AS Fecha,
        B.product_name AS [Menú comprado],
        ROW_NUMBER() OVER (PARTITION BY A.customer_id ORDER BY A.order_date ASC) AS fila
    FROM [Challenge_sql].[dbo].[sales] A
    JOIN [Challenge_sql].[dbo].[menu] B
        ON A.product_id = B.product_id
)
SELECT
    Cliente,
    Fecha,
    [Menú comprado]
FROM PrimerCompra
WHERE fila = 1
ORDER BY Cliente;
```

4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
```
SELECT TOP 1
    m.product_name AS [Artículo más comprado],
    COUNT(*) AS [Cantidad de veces comprado]
FROM [Challenge_sql].[dbo].[sales] s
JOIN [Challenge_sql].[dbo].[menu] m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(*) DESC;
```

5. ¿Qué artículo fue el más popular para cada cliente?
```
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
    product_name AS [Artículo más popular],
    cantidad AS [Veces comprado]
FROM ConteoCompras
WHERE fila = 1
ORDER BY Cliente;
```

6. ¿Qué artículo compró primero el cliente después de hacerse miembro?
```
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
    product_name AS [Primer artículo comprado]
FROM ComprasPosteriores
WHERE fila = 1
ORDER BY Cliente;
```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
```
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
    product_name AS [Artículo previo a membresía]
FROM ComprasPrevias
WHERE fila = 1
ORDER BY Cliente;
```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
```
SELECT
    m.customer_id AS Cliente,
    COUNT(*) AS [Artículos comprados],
    SUM(me.price) AS [Monto gastado]
FROM [Challenge_sql].[dbo].[members] m
JOIN [Challenge_sql].[dbo].[sales] s
    ON m.customer_id = s.customer_id
JOIN [Challenge_sql].[dbo].[menu] me
    ON s.product_id = me.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id
ORDER BY [Monto gastado] DESC;
```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
```
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
```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
```
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
```
<br>

## 📂**Conclusiones**






<br>
