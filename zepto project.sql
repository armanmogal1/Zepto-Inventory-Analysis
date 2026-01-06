drop table if exists zepto;

create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

--DATA EXPLORATION

--1)Count of total rows
select count(*) from zepto

--2)Understanding Data
select * from zepto limit 10;

--3)Finding NULL values
select * from zepto 
Where category is NULL
or name is NULL
or mrp is NULL
or discountpercent is NULL
or availablequantity is NULL
or discountedsellingprice is  NULL
or weightingms is NULL
or outofstock is NULL
or quantity is NULL ;

--Finding different product categories
select distinct category from zepto 
order by category ;

--Products in stock and out of stock total
select count(sku_id), outofstock
from zepto 
group by outofstock ;

--Products name present multiple times
select name,count(sku_id) as "Number of Skus"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) DESC;

--DATA CLEANING
--a)product with price=0
select * from zepto
where mrp=0 or discountedsellingprice = 0 ;

Delete from zepto 
where mrp=0;

--b)Converting paise into rupees
update zepto
set mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0 ;

select mrp,discountedsellingprice from zepto ;

--BUSINESS INSIGHT QUERIES
--Q.1)Find the top 10 best value product based on the discount percentage?
SELECT 
    name, 
    category,
    mrp, 
    discountpercent,
    discountedsellingprice
FROM zepto 
WHERE outofstock = false
ORDER BY discountpercent DESC
LIMIT 10;

-- Q.2) Calculate estimated revenue for each category with percentage
SELECT 
    category,
    ROUND(SUM(discountedsellingprice * availablequantity), 2) as total_revenue,
    ROUND(SUM(discountedsellingprice * availablequantity) * 100.0 / 
          SUM(SUM(discountedsellingprice * availablequantity)) OVER (), 2) as revenue_percentage
FROM zepto 
GROUP BY category
ORDER BY total_revenue DESC;

-- Q.3) Find products with discount higher than their category average
SELECT 
    z.name,
    z.category,
    z.discountpercent,
    ROUND(cat_avg.avg_discount, 2) as category_avg_discount,
    ROUND(z.discountpercent - cat_avg.avg_discount, 2) as discount_advantage
FROM zepto z
JOIN (
    SELECT category, AVG(discountpercent) as avg_discount
    FROM zepto
    GROUP BY category
) cat_avg ON z.category = cat_avg.category
WHERE z.discountpercent > cat_avg.avg_discount
ORDER BY discount_advantage DESC
LIMIT 20;

-- Q.4) Top 5 categories by average discount with product count
SELECT 
    category,
    COUNT(DISTINCT sku_id) as total_products,
    ROUND(AVG(discountpercent), 2) as average_discount_percentage,
    ROUND(MIN(discountpercent), 2) as min_discount,
    ROUND(MAX(discountpercent), 2) as max_discount
FROM zepto 
GROUP BY category
HAVING COUNT(DISTINCT sku_id) >= 5
ORDER BY average_discount_percentage DESC
LIMIT 5;

-- Q.5) Price per gram analysis with value indicator
SELECT 
    name,
    category,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms > 0
ORDER BY price_per_gram;

-- Q.6) Weight categories with aggregated statistics
select distinct name, weightingms ,
CASE WHEN weightingms < 1000 then 'LOW'
     WHEN weightingms < 5000 then 'MEDIUM'
	 ELSE 'BULK'
	 END as weight_category
from zepto ;

-- Q.7) Total inventory weight per category with stock health
SELECT 
    category,
    SUM(availableQuantity) AS total_units,
    COUNT(*) AS total_products,
    SUM(CASE WHEN outOfStock = true THEN 1 ELSE 0 END) AS out_of_stock_products
FROM zepto
GROUP BY category;

-- Q.8) Rank products within each category by their discount percentage and show only top 3 from each category
WITH RankedProducts AS (
    SELECT 
        category,
        name,
        mrp,
        discountpercent,
        discountedsellingprice,
        RANK() OVER (PARTITION BY category ORDER BY discountpercent DESC) as discount_rank
    FROM zepto
    WHERE outofstock = false
)
SELECT 
    category,
    name,
    mrp,
    discountpercent,
    discountedsellingprice,
    discount_rank
FROM RankedProducts
WHERE discount_rank <= 3
ORDER BY category, discount_rank;

-- Q.9) Calculate running total of revenue for each category ordered by product price
SELECT 
    category,
    name,
    discountedSellingPrice,
    discountedSellingPrice * availableQuantity AS product_revenue
FROM zepto
WHERE outOfStock = false
ORDER BY category, product_revenue DESC;

-- Q.10) Find products whose price is above the average price of their category
WITH CategoryAvgPrice AS (
    SELECT 
        category,
        AVG(discountedsellingprice) as avg_category_price
    FROM zepto
    GROUP BY category
)
SELECT 
    z.category,
    z.name,
    z.discountedsellingprice,
    ROUND(cap.avg_category_price, 2) as category_avg_price,
    ROUND(z.discountedsellingprice - cap.avg_category_price, 2) as price_difference
FROM zepto z
JOIN CategoryAvgPrice cap ON z.category = cap.category
WHERE z.discountedsellingprice > cap.avg_category_price
ORDER BY z.category, price_difference DESC;

-- Q.11) Compare each product's discount with the maximum discount in its category
SELECT 
    z.category,
    z.name,
    z.discountPercent,
    m.max_discount
FROM zepto z
JOIN (
    SELECT category, MAX(discountPercent) AS max_discount
    FROM zepto
    GROUP BY category
) m ON z.category = m.category;

-- Q.12) Calculate the price percentile for each product within its category
SELECT 
    category,
    name,
    discountedSellingPrice,
    CASE
        WHEN discountedSellingPrice < 100 THEN 'Budget'
        WHEN discountedSellingPrice < 300 THEN 'Economy'
        ELSE 'Premium'
    END AS price_segment
FROM zepto
WHERE outOfStock = false
ORDER BY category, discountedSellingPrice;









