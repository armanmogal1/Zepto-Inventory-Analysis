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

-- Q.2) High MRP out of stock products with category average comparison
SELECT 
    z.name,
    z.category,
    z.mrp,
    z.outofstock,
    ROUND((SELECT AVG(mrp) FROM zepto WHERE category = z.category), 2) as category_avg_mrp,
    ROUND(z.mrp - (SELECT AVG(mrp) FROM zepto WHERE category = z.category), 2) as difference
FROM zepto z
WHERE z.outofstock = true 
  AND z.mrp > 250
ORDER BY z.mrp DESC;

-- Q.3) Calculate estimated revenue for each category with percentage
SELECT 
    category,
    ROUND(SUM(discountedsellingprice * availablequantity), 2) as total_revenue,
    ROUND(SUM(discountedsellingprice * availablequantity) * 100.0 / 
          SUM(SUM(discountedsellingprice * availablequantity)) OVER (), 2) as revenue_percentage
FROM zepto 
GROUP BY category
ORDER BY total_revenue DESC;

-- Q.4) Find products with discount higher than their category average
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

-- Q.5) Top 5 categories by average discount with product count
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

-- Q.6) Price per gram analysis with value indicator
SELECT 
    name,
    category,
    weightingms,
    discountedsellingprice,
    ROUND(discountedsellingprice / weightingms, 4) as price_per_gram,
    CASE 
        WHEN ROUND(discountedsellingprice / weightingms, 4) < 0.5 THEN 'Excellent Value'
        WHEN ROUND(discountedsellingprice / weightingms, 4) < 1.0 THEN 'Good Value'
        WHEN ROUND(discountedsellingprice / weightingms, 4) < 2.0 THEN 'Average Value'
        ELSE 'Premium Pricing'
    END as value_rating
FROM zepto
WHERE weightingms > 100
ORDER BY price_per_gram
LIMIT 30;

-- Q.7) Weight categories with aggregated statistics
select distinct name, weightingms ,
CASE WHEN weightingms < 1000 then 'LOW'
     WHEN weightingms < 5000 then 'MEDIUM'
	 ELSE 'BULK'
	 END as weight_category
from zepto ;

-- Q.8) Total inventory weight per category with stock health
SELECT 
    category,
    SUM(weightingms * availablequantity) as total_inventory_weight,
    SUM(availablequantity) as total_units,
    COUNT(DISTINCT sku_id) as product_variety,
    SUM(CASE WHEN outofstock = true THEN 1 ELSE 0 END) as out_of_stock_count,
    ROUND(SUM(CASE WHEN outofstock = true THEN 1 ELSE 0 END)::NUMERIC * 100.0 / 
          COUNT(DISTINCT sku_id), 2) as out_of_stock_percentage,
    CASE 
        WHEN SUM(CASE WHEN outofstock = true THEN 1 ELSE 0 END)::NUMERIC * 100.0 / 
             COUNT(DISTINCT sku_id) > 30 THEN 'Critical'
        WHEN SUM(CASE WHEN outofstock = true THEN 1 ELSE 0 END)::NUMERIC * 100.0 / 
             COUNT(DISTINCT sku_id) > 15 THEN 'Attention Needed'
        ELSE 'Healthy'
    END as inventory_health
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;

-- Q.9) Rank products within each category by their discount percentage and show only top 3 from each category
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

-- Q.10) Calculate running total of revenue for each category ordered by product price
WITH CategoryRevenue AS (
    SELECT 
        category,
        name,
        discountedsellingprice,
        availablequantity,
        (discountedsellingprice * availablequantity) as product_revenue
    FROM zepto
    WHERE outofstock = false
)
SELECT 
    category,
    name,
    discountedsellingprice,
    product_revenue,
    SUM(product_revenue) OVER (
        PARTITION BY category 
        ORDER BY discountedsellingprice 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total_revenue
FROM CategoryRevenue
ORDER BY category, discountedsellingprice;

-- Q.11) Find products whose price is above the average price of their category
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

-- Q.12) Compare each product's discount with the maximum discount in its category
WITH CategoryMaxDiscount AS (
    SELECT 
        category,
        name,
        discountpercent,
        MAX(discountpercent) OVER (PARTITION BY category) as max_category_discount,
        ROUND(AVG(discountpercent) OVER (PARTITION BY category), 2) as avg_category_discount
    FROM zepto
)
SELECT 
    category,
    name,
    discountpercent,
    max_category_discount,
    avg_category_discount,
    ROUND(max_category_discount - discountpercent, 2) as discount_gap_from_max,
    CASE 
        WHEN discountpercent >= avg_category_discount THEN 'Above Average'
        ELSE 'Below Average'
    END as discount_status
FROM CategoryMaxDiscount
ORDER BY category, discountpercent DESC;

-- Q.13) Calculate the price percentile for each product within its category
WITH PricePercentiles AS (
    SELECT 
        category,
        name,
        discountedsellingprice,
        NTILE(4) OVER (PARTITION BY category ORDER BY discountedsellingprice) as price_quartile,
        PERCENT_RANK() OVER (PARTITION BY category ORDER BY discountedsellingprice) as price_percentile
    FROM zepto
    WHERE outofstock = false
)
SELECT 
    category,
    name,
    discountedsellingprice,
    price_quartile,
    ROUND(price_percentile * 100, 2) as price_percentile_pct,
    CASE 
        WHEN price_quartile = 1 THEN 'Budget'
        WHEN price_quartile = 2 THEN 'Economy'
        WHEN price_quartile = 3 THEN 'Premium'
        ELSE 'Luxury'
    END as price_segment
FROM PricePercentiles
ORDER BY category, discountedsellingprice;

-- Q.14) Identify products with inventory levels below category average and calculate lag/lead values
WITH CategoryInventory AS (
    SELECT 
        category,
        name,
        availablequantity,
        ROUND(AVG(availablequantity) OVER (PARTITION BY category), 2) as avg_category_inventory,
        LAG(availablequantity, 1) OVER (PARTITION BY category ORDER BY availablequantity) as prev_product_quantity,
        LEAD(availablequantity, 1) OVER (PARTITION BY category ORDER BY availablequantity) as next_product_quantity,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY availablequantity) as inventory_position
    FROM zepto
    WHERE outofstock = false
)
SELECT 
    category,
    name,
    availablequantity,
    avg_category_inventory,
    ROUND(availablequantity - avg_category_inventory, 2) as inventory_variance,
    prev_product_quantity,
    next_product_quantity,
    inventory_position,
    CASE 
        WHEN availablequantity < avg_category_inventory THEN 'Restock Needed'
        WHEN availablequantity > avg_category_inventory * 1.5 THEN 'Overstocked'
        ELSE 'Optimal'
    END as inventory_status
FROM CategoryInventory
WHERE availablequantity < avg_category_inventory
ORDER BY category, availablequantity;

