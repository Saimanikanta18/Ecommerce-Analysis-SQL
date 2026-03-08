
-- ================================================================================================
-- E-Commerce Sales Analysis and Business Insights with SQL
-- ================================================================================================

--  Created Database
CREATE DATABASE ecommerce_db;

-- using the created db
USE  ecommerce_db;

-- Created table in the data base accornding to csv file
CREATE TABLE ecommerce (
OrderID VARCHAR(20),
Product VARCHAR(100),
Category VARCHAR(50),
Brand VARCHAR(50),
Platform VARCHAR(50),
City VARCHAR(50),
Price DECIMAL(10,2),
Quantity INT,
TotalAmount DECIMAL(10,2),
Rating DECIMAL(2,1),
Reviews INT,
OrderDate DATE
);

-- Query to fetch count of total records
SELECT COUNT(*) AS total_records
FROM ecommerce;


SELECT *
FROM ecommerce;

-- Total revenue by each company
SELECT Brand,SUM(TotalAmount) AS Revenue
FROM ecommerce
GROUP BY Brand;

-- total orders by customers
SELECT Product,SUM(Quantity) AS Total_Orders_Product
FROM ecommerce
GROUP BY Product;

SELECT SUM(Quantity) AS total_Orders
FROM ecommerce;

-- Average order Value 
SELECT ROUND(AVG(TotalAmount),2) AS Avg_order
FROM ecommerce;

-- Unique Products Sold
SELECT COUNT(DISTINCT(Product)) AS Unique_Products
FROM ecommerce;

-- Unique Brands
SELECT COUNT(DISTINCT(Brand))  AS Unique_Brands
FROM ecommerce;

-- Products that generate highest revenue
SELECT Product,Brand,SUM(TotalAmount) AS Revenue
FROM ecommerce
GROUP BY Product,Brand
ORDER BY Revenue DESC
LIMIT 1;

-- Products are most sold in terms in terms of quantity
SELECT Product,Brand,Sum(Quantity) AS HighestQuantity
FROM ecommerce
GROUP BY Product,Brand
ORDER BY HighestQuantity DESC
LIMIT 1;

-- Products that generate least revenue
SELECT Product,Brand,SUM(TotalAmount) AS Revenue
FROM ecommerce
GROUP BY Product,Brand
ORDER BY Revenue 
LIMIT 1;

-- Top 10 Products by total sales amount
SELECT Product,Brand,SUM(TotalAmount) AS Revenue
FROM ecommerce
GROUP BY Product,Brand
ORDER BY Revenue DESC
LIMIT 10;

-- Products having highest avg rating
SELECT Product,Brand,AVG(Rating) AS HighestAverageRating
FROM ecommerce
GROUP BY Product,Brand
ORDER BY HighestAverageRating DESC
LIMIT 1;

-- Category with highest revenue
WITH cte_table AS
(
SELECT 
    Category,
    SUM(TotalAmount) AS TotalRevenue,
    DENSE_RANK() OVER(ORDER BY SUM(TotalAmount) DESC) AS Ranks
FROM ecommerce
GROUP BY Category
)

SELECT Category, TotalRevenue
FROM cte_table
WHERE Ranks = 1;

-- category sells highest quantity of products
WITH cte_table AS
(
SELECT 
    Category,
    SUM(Quantity) AS TotalQuantity,
    DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC) AS Ranks
FROM ecommerce
GROUP BY Category
)
SELECT Category,TotalQuantity
FROM cte_table
WHERE Ranks=1;

-- Category highest avearge product rating
SELECT t.Category,t.HighestAverageRating
FROM(SELECT Category,AVG(Rating) AS HighestAverageRating,Dense_RANK() OVER(ORDER BY AVG(Rating) DESC)AS Ranks
	 FROM ecommerce
	 GROUP BY Category)t
WHERE Ranks=1;

-- category has highest number of products sold
SELECT t.Category,t.ProductsSold
FROM(SELECT Category,
            SUM(Quantity) AS ProductsSold,
            DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC) AS Ranks
	  FROM ecommerce
	  GROUP BY Category)t
WHERE RANKS=1;

-- brands generate the highest revenue
SELECT t.Brand,t.HighestRevenue
FROM (SELECT Brand,SUM(TotalAmount) AS HighestRevenue,
      DENSE_RANK() OVER(ORDER BY SUM(TotalAmount) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Brand)t
WHERE Ranks=1;

-- brands highest qunintity of products
SELECT t.Brand,t.HighestQuantity
FROM (SELECT Brand,SUM(Quantity) AS HighestQuantity,
      DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Brand)t
WHERE Ranks=1;

-- brands has highest avg product rating
SELECT t.Brand,t.HighestAverage
FROM (SELECT Brand,AVG(Rating) AS HighestAverage,
      DENSE_RANK() OVER(ORDER BY AVG(Rating) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Brand)t
WHERE Ranks=1;

-- brands recived most reviews
SELECT t.Brand,t.HighestReviews
FROM (SELECT Brand,SUM(Reviews) AS HighestReviews,
      DENSE_RANK() OVER(ORDER BY SUM(Reviews) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Brand)t
WHERE Ranks=1;

-- platform has the highest number of orders

SELECT t.Platform,t.TotalOrders
FROM (SELECT Platform,COUNT(OrderID) AS TotalOrders,
      DENSE_RANK() OVER(ORDER BY COUNT(OrderID) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Platform)t
WHERE Ranks=1;

-- platform generate highest revenue
SELECT t.Platform,t.HighestRevenue
FROM (SELECT Platform,SUM(TotalAmount) AS HighestRevenue,
      DENSE_RANK() OVER(ORDER BY SUM(TotalAmount) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Platform)t
WHERE Ranks=1;

-- platform has highest avg rating
SELECT t.Platform,t.AverageRating
FROM (SELECT Platform,AVG(Rating) AS AverageRating,
      DENSE_RANK() OVER(ORDER BY AVG(Rating) DESC) AS Ranks
	  FROM ecommerce
      GROUP BY Platform)t
WHERE Ranks=1;

-- city Analysis
WITH cte_table AS
(
SELECT City,
       SUM(TotalAmount)AS HighestRevenue,
       COUNT(OrderID)AS HighestOrders,
       AVG(TotalAmount)AS HighestAvgValue,
       DENSE_RANK() OVER(ORDER BY SUM(TotalAmount)DESC,COUNT(OrderID)DESC,AVG(TotalAmount)DESC) AS ranks
FROM ecommerce
GROUP BY City
)
-- cities generate the highest revenue,number of orders,highestavgvalue
SELECT City, HighestRevenue,HighestOrders,HighestAvgValue
FROM cte_table
WHERE Ranks=1;

-- Customer Feedback Insights
-- Which product has the highest number of reviews and highest average rating?

WITH cte_table AS
(
SELECT Product,
       SUM(Reviews) AS TotalReviews,
       DENSE_RANK() OVER(ORDER BY SUM(Reviews)DESC,AVG(Rating)DESC) AS HighestRank,
	   Category,
       AVG(Rating) AS AvgRating,
       Brand
FROM ecommerce
GROUP BY Product,Category,Brand
)

SELECT Product,TotalReviews,Category,AvgRating,Brand
FROM cte_table
WHERE HighestRank =1;

-- Time Based Analysis
-- month with highest revenue and orders
WITH 
	cte_table AS
	(
	SELECT TotalAmount,
		   MONTH(OrderDate) AS MonthNo,
		   YEAR(OrderDate) AS OrderYear,
		   OrderID
	FROM ecommerce
	),
    cte_table_2 AS
    (
     SELECT MonthNo,
            SUM(TotalAmount) AS TotalRevenue,
            COUNT(OrderID) AS TotalOrders,
            DENSE_RANK() OVER(ORDER BY SUM(TotalAmount)DESC,COUNT(OrderID) DESC )AS ranks
	 FROM cte_table
     GROUP BY MonthNo
    )
    
SELECT MonthNo,TotalOrders,TotalRevenue
FROM cte_table_2
WHERE ranks=1;

-- How does average order value change over time?
-- How does revenue trend over time

WITH trends AS
(
	SELECT  Month(OrderDate) AS OrderMonth,
			ROUND(AVG(TotalAmount),2) AS AvgOrdervalue,
			ROUND(SUM(TotalAmount),2) AS TotalRevenue
	FROM ecommerce
	GROUP BY OrderMonth 
  
),
trends2 AS(
SELECT *,LAG(AvgOrderValue,1,0) Over(ORDER BY OrderMonth) AS PrevmonthAvgOrder,
		LAG(TotalRevenue,1,0) OVER(ORDER BY OrderMonth) AS PrevMonthRevenue
FROM trends
)

SELECT  OrderMonth,(AvgOrdervalue-PrevmonthAvgOrder) AS Monthlyavgchange,
		(TotalRevenue-PrevMonthRevenue) AS RevenueOvertimeTrend
FROM trends2;

-- What percentage of revenue comes from the top 5 products? 

WITH product_revenue AS (
    SELECT 
        Product,
        SUM(TotalAmount) AS ProductRevenue
    FROM ecommerce
    GROUP BY Product
),

ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER(ORDER BY ProductRevenue DESC) AS rnk
    FROM product_revenue
),

total_revenue AS (
    SELECT SUM(ProductRevenue) AS TotalRevenue
    FROM product_revenue
)

SELECT 
       r.Product,
       r.ProductRevenue,
       ROUND((r.ProductRevenue / t.TotalRevenue) * 100, 2) AS Percentage
FROM ranked_products r
CROSS JOIN total_revenue t
WHERE r.rnk <= 5;

-- What percentage of revenue comes from the top brands?









