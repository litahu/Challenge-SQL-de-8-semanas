# 🚀 Challenge SQL de 8 semanas
<br>

**Herramienta** : MySQL <br> 
**Visualización** : Microsoft Excel <br>
**Dataset** : Desafío SQL - ["Data With Danny"](https://8weeksqlchallenge.com/)
<br>

## 📂 **Esquema**

No | Outline | Description
---|---|---
1 | [Dannys´Diner](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-1:-Dannys´Diner) | Analice más de cerca el comportamiento de los clientes de comida japonesa, y utilice técnicas MySQL para identificar sus patrones de consumo
2 | [Pizza Runner](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-2:-Pizza-Runner) | hnloop,ñkkkkkkkk
3 | [Foodie-FI](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-3:-Foodie-FI) | hnloop,ñkkkkkkkk
4 | [Data Bank](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-4:-Data-Bank) | hnloop,ñkkkkkkkk
5 | [Data Mart](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-5:-Data-Mart) | hnloop,ñkkkkkkkk
6 | [CliqueBait](https://github.com/litahu/Challenge-SQL-de-8-semanas#-Caso-práctico-Nº-6:-CliqueBait) |  hnloop,ñkkkkkkkk
7 | [Balanced Tree](https://github.com/litahu/Challenge-SQL-de-8-semanas?tab=readme-ov-file#-caso-pr%C3%A1ctico-n%C2%BA-7-balanced-tree-clothing-co) | hnloop,ñkkkkkkkk
8 | [Fresh Segments](https://github.com/litahu/Challenge-SQL-de-8-semanas?tab=readme-ov-file#-caso-pr%C3%A1ctico-n%C2%BA-8-segmentos-nuevos) |  hnloop,ñkkkkkkkk

<br>

---

## 📌 **Caso práctico Nº 1: Dannys´Diner**

<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_1.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**
<br> <br>
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
<br> <br>
2. ¿Cuántos días ha visitado cada cliente el restaurante?
```
SELECT
    customer_id AS Cliente,
    COUNT(DISTINCT order_date) AS Presente
FROM [Challenge_sql].[dbo].[sales]
GROUP BY customer_id
ORDER BY Presente DESC;
```
<br> <br>
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
<br> <br>
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
```
SELECT
    B.product_name AS [Artículo más comprado],
    COUNT(*) AS [Cantidad de veces comprado]
FROM [Challenge_sql].[dbo].[sales] A
    JOIN [Challenge_sql].[dbo].[menu] B
        ON A.product_id = B.product_id
GROUP BY B.product_name
ORDER BY [Cantidad de veces comprado] DESC;
```
<br> <br>
5. ¿Qué artículo fue el más popular para cada cliente?
```
SELECT
    B.product_name AS [Artículo más comprado],
    COUNT(*) AS [Cantidad de veces comprado]
FROM [Challenge_sql].[dbo].[sales] A
    JOIN [Challenge_sql].[dbo].[menu] B
        ON A.product_id = B.product_id
GROUP BY B.product_name
ORDER BY [Cantidad de veces comprado] DESC;
```
<br> <br>
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
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

### **Conclusiones**




<br>

---

## 📌 **Caso práctico Nº 2: Pizza Runner**

<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_2.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**




<br>

---

## 📌 **Caso práctico Nº 3: Foodie-FI**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_3.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**


<br>

---

## 📌 **Caso práctico Nº 4: Data Bank**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_4.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**



<br>

---

## 📌 **Caso práctico Nº 5: Data Mart**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_5.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**



<br>

---

## 📌 **Caso práctico Nº 6: CliqueBait**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_6.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**



<br>

---

## 📌 **Caso práctico Nº 7: Balanced Tree Clothing Co**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_7.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**



<br>

---

## 📌 **Caso práctico Nº 8: Segmentos nuevos**


<p align="center">
  <kbd> <img width="300" alt="eer" src="https://github.com/litahu/Challenge-SQL-de-8-semanas/blob/main/assets/week_8.JPG"></kbd> <br>
</p>
<br>

### **Problema del negocio**

Frente al primer emprendimiento de Dany: un restaurante de comida que lleva pocos meses de funcionamiento en una zona muy comercial. No obstante, últimamente, ha estado preocupado pues su negocio tiene un flujo de caja estancada. En ese sentido Dany para mantener a flote el negocio se ha interesado por ampliar su cartera de clientes más leales.

### **Análisis de datos**

1. ¿Cuál es el importe total que gastó cada cliente en el restaurante?
    ```
    cd terraform
    ```
2. ¿Cuántos días ha visitado cada cliente el restaurante?
    ```
    terraform init
    ```
3. ¿Cuál fue el primer artículo del menú que compró cada cliente?
    ```
    terraform apply
    ```
4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?
    ```
    terraform apply
    ```
5. ¿Qué artículo fue el más popular para cada cliente?
    ```
    terraform apply
    ```
6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
    ```
    terraform apply
    ```
7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
     ```
    terraform apply
    ```
8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
     ```
    terraform apply
    ```
9. Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos de 2x, ¿cuántos puntos tendría cada cliente?
     ```
    terraform apply
    ```
10. En la primera semana después de que un cliente se une al programa (incluida su fecha de unión), gana el doble de puntos en todos los artículos, no solo en sushi: ¿cuántos puntos tienen los clientes A y B al final de enero?
     ```
    terraform apply
    ```

### **Conclusiones**


<br>
