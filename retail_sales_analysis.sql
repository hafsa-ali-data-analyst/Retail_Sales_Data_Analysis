/* =========================================================
                RETAIL SALES DATA ANALYSIS
   =========================================================

Project Objective:
Analyze retail sales data using SQL to uncover insights
related to customer behavior, product performance,
sales trends, revenue generation, and employee performance.

Tools Used:
- SQL
- MySQL Workbench

Analysis Areas:
1. Customer Analysis
2. Product & Category Performance
3. Sales Trend Analysis
4. Revenue Analysis
5. Employee Performance Analysis

========================================================= */

USE  retail_sales;

/* =========================================================
   BASIC DATA EXPLORATION
   ========================================================= */

SELECT * FROM product;        --  Retrieved all records from the Product table. 

SELECT
    productName, unitPrice 
FROM product 
WHERE unitPrice > 50;          -- Retrieved  product names and unit prices of products whose unit price is more than $50. 

SELECT * FROM customer;        -- Retrieved all records from the Customer table. 

SELECT custId 
FROM customer 
WHERE country ='Germany';      -- Retrieved all customers located in Germany. 

/* =========================================================
   SQL FUNCTIONS & AGGREGATIONS
   ========================================================= */ 

 SELECT * FROM orderdetail;    -- Retrieved all records from the Order Detail table. 
 
SELECT COUNT( DISTINCT orderId) as total_orders 
FROM orderdetail;              -- Calculated the total number of orders placed. 

SELECT ROUND(AVG(unitPrice),2) as avg_unit_price
FROM product;                  -- Calculated the average unit price of all products.

SELECT ROUND(SUM(unitPrice * quantity * (1 - discount)),2) as Revenue
FROM orderdetail;              --  Calculated the total revenue generated. 

/* =========================================================
   JOIN OPERATIONS
   ========================================================= */

SELECT
    p.productName as Product_Name,
    c.categoryName as Category_Name,
    p.unitPrice as Unit_Price
FROM product as p
JOIN category as c 
ON p.categoryId = c.categoryId;  -- Product Category Analysis

SELECT 
    c.companyName as Company_Name,
    s.orderId as Order_ID,
    s.orderDate as Order_Date
FROM customer as c
JOIN salesorder as s 
ON c.custId = s.custId;          -- Customer Order Analysis 

SELECT 
    CONCAT(e.firstname, ' ', e.lastname) AS Employee_Name,
    s.orderId as Order_ID,
    c.companyName as Customer_Name
FROM  salesorder as s 
JOIN employee as e 
ON s.employeeId = e.employeeId
JOIN customer as c 
ON s.custId = c.custId;           -- Sales Performance by Employee 

/* =========================================================
   SUBQUERIES
   ========================================================= */

SELECT 
    productId as Product_ID, 
    productName as Product_Name 
FROM product
WHERE unitPrice > (
    SELECT AVG(unitPrice) as avg_unit_price
    FROM product
);                                -- products whose unit price is higher than the average price of all products.

SELECT 
    c.custId as Customer_ID,
    c.companyName as Customer_Name,
    COUNT(s.orderId) as Total_Order_ID 
FROM customer as c 
JOIN salesorder as s 
ON c.custId = s.custId
GROUP BY Customer_ID, Customer_Name
HAVING COUNT(s.orderId) > 5;        -- Retrieved customers who have placed more than 5 orders

SELECT 
    productId as Product_ID,
    productName as Product_Name
FROM product
WHERE productId NOT IN (
    SELECT 
         productId
	FROM orderdetail     
);                                -- Identified products that have never been ordered. 

/* =========================================================
   WINDOW FUNCTIONS
   ========================================================= */

SELECT 
    productId as Product_ID,
    productName as Product_Name,
    categoryId as Category_ID,
    unitPrice as Unit_Price, 
    RANK() OVER (PARTITION BY categoryId ORDER BY unitPrice DESC) as Price_Rank
FROM product;                     -- Ranked products based on their unit price within each category.

SELECT 
    orderDate as Order_Date,
    SUM(Order_Revenue) as Order_Revenue,
    SUM(SUM(Order_Revenue)) OVER ( ORDER BY orderDate ) as Running_Total_Revenue
FROM (
    SELECT 
       s.orderDate,
       ROUND(o.unitPrice * o.quantity * (1- o.discount),2) as Order_Revenue
   FROM salesorder as s 
   JOIN orderdetail as o 
   ON s.orderId = o.orderId
)  as order_data_details
GROUP BY orderDate 
ORDER BY orderDate;                 -- Calculated the running total of revenue by order date. 
   
SELECT 
    c.companyName as Customer_Name,
    ROUND(SUM(o.unitPrice * o.quantity * (1 - o.discount)), 2) as Total_Revenue,
    RANK() OVER ( ORDER BY ROUND(SUM(o.unitPrice * o.quantity * (1 - o.discount)), 2) DESC ) as Customer_Rank
FROM customer as c 
JOIN salesorder as s 
ON c.custId = s.custId 
JOIN orderdetail as o 
ON s.orderId = o.orderId
GROUP BY c.companyName;                -- Calculated total revenue generated by each customer and assigned a rank.

/* =========================================================
   ADVANCED ANALYTICAL QUERIES
   ========================================================= */

SELECT 
      c.categoryName as Category_Name,
      ROUND(SUM(o.unitPrice * o.quantity * (1 - o.discount)),2) as Revenue,
      RANK() OVER ( ORDER BY ROUND(SUM(o.unitPrice * o.quantity * (1 - o.discount)),2) DESC) as Category_RANK
FROM category as c
JOIN product as p
ON c.categoryId = p.categoryId
JOIN orderdetail as o 
ON p.productId = o.productId
GROUP BY c.categoryName
LIMIT 1;                             -- Among all product categories, Beverages generates the highest revenue.

SELECT 
    Customer_Name,
    Total_Orders
FROM (
    SELECT 
        cu.companyName AS Customer_Name,
        COUNT(s.orderId) AS Total_Orders,
        RANK() OVER ( ORDER BY COUNT(s.orderId) DESC ) AS rnk
    FROM customer as cu 
    JOIN salesorder as s 
        ON cu.custId = s.custId
    GROUP BY cu.companyName
) as a
WHERE rnk = 1;                        -- Among all Customers, Customer LCOUJ has placed the most number of orders. 

SELECT 
    Employee_Name,
    Total_Orders
FROM (
    SELECT 
        CONCAT(e.firstname, ' ', e.lastname) AS Employee_Name,
        COUNT(s.orderId) AS Total_Orders,
        RANK() OVER ( ORDER BY COUNT(s.orderId) DESC ) AS rnk
    FROM employee as e
    JOIN salesorder as s 
        ON e.employeeId = s.employeeId
    GROUP BY Employee_Name
) as a
WHERE rnk = 1;                         -- Among all Employees, Yael Peled has handled the highest number of orders.

/* =========================================================
   OVERALL BUSINESS INSIGHTS
   =========================================================

1. Beverages generated the highest revenue among all categories.

2. A small group of customers contributed significantly
   to total sales revenue.

3. Some products showed no sales activity and may require
   inventory or marketing review.

4. Revenue demonstrated a positive growth trend over time.

5. Employee sales performance varied across the organization.

========================================================= */
 
/* =========================================================
   BUSINESS RECOMMENDATIONS
   =========================================================

1. Increase focus on high-performing categories such as
   Beverages through improved inventory management,
   promotions, and distribution strategies.

2. Implement customer retention strategies such as
   loyalty programs and personalized offers to retain
   high-value customers.

3. Review low-performing products to identify whether
   pricing, marketing, or demand issues are affecting sales.

4. Continue and strengthen current sales strategies,
   as revenue trends indicate steady business growth.

5. Provide performance-based training and incentives
   to improve employee sales performance.

========================================================= */ 











