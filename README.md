<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zepto Inventory Analysis</title>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            line-height: 1.6;
            margin: 40px;
            background-color: #fafafa;
            color: #333;
        }
        h1, h2, h3 {
            color: #6a1b9a;
        }
        ul {
            margin-left: 20px;
        }
        .section {
            margin-bottom: 30px;
        }
        .tech span {
            background: #e1bee7;
            padding: 6px 10px;
            border-radius: 6px;
            margin-right: 6px;
            display: inline-block;
        }
    </style>
</head>

<body>

    <h1>Zepto Inventory Analysis 📦📊</h1>

    <div class="section">
        <h2>Project Overview</h2>
        <p>
            This project analyzes Zepto’s product inventory and pricing data to uncover insights related to 
            stock availability, discount strategies, pricing efficiency, and revenue contribution across 
            categories. The analysis leverages SQL for deep querying and Power BI for interactive visualization 
            to support inventory optimization and business decision-making.
        </p>
    </div>

    <div class="section">
        <h2>Objectives</h2>
        <ul>
            <li>Analyze inventory availability and out-of-stock patterns across product categories</li>
            <li>Evaluate pricing strategies and discount effectiveness</li>
            <li>Identify revenue-driving categories and high-value products</li>
            <li>Assess inventory health and stock optimization opportunities</li>
            <li>Build an interactive dashboard for business insights</li>
        </ul>
    </div>

    <div class="section">
        <h2>Dataset Summary</h2>
        <ul>
            <li>Total Products (SKUs): 3,700+</li>
            <li>Key Fields: Category, Product Name, MRP, Discount %, Selling Price, Weight, Stock Status</li>
            <li>Inventory Metrics: Available Quantity, Out-of-Stock Flag, Product Weight</li>
        </ul>
    </div>

    <div class="section">
        <h2>Data Cleaning & Preparation</h2>
        <ul>
            <li>Removed products with zero MRP or invalid pricing</li>
            <li>Converted prices from paise to rupees for consistency</li>
            <li>Validated null values and ensured data completeness</li>
            <li>Standardized numeric fields for accurate calculations</li>
        </ul>
    </div>

    <div class="section">
        <h2>SQL Analysis Highlights</h2>
        <ul>
            <li>Identified top-value products based on highest discount percentages</li>
            <li>Analyzed high-MRP out-of-stock products against category averages</li>
            <li>Calculated estimated revenue contribution by category</li>
            <li>Performed price-per-gram analysis to classify product value</li>
            <li>Used CTEs, window functions, ranking, percentiles, and CASE statements</li>
            <li>Assessed inventory health using stock availability thresholds</li>
        </ul>
    </div>

    <div class="section">
        <h2>Dashboard Insights (Power BI)</h2>
        <ul>
            <li>Total Units: 3,731 | Total Sales: 530K+</li>
            <li>Out-of-Stock Rate: ~12%</li>
            <li>Category-wise sales, stock levels, and discount trends</li>
            <li>Weight-based pricing and average selling price analysis</li>
            <li>Interactive filters for category and weight segmentation</li>
        </ul>
    </div>

    <div class="section">
        <h2>Key Business Insights</h2>
        <ul>
            <li>Cooking Essentials and Munchies emerged as top revenue-driving categories</li>
            <li>Bulk-weight products showed higher average selling prices</li>
            <li>Several high-MRP products were frequently out of stock, indicating restocking gaps</li>
            <li>Discount-heavy products significantly influenced category-level sales performance</li>
        </ul>
    </div>

    <div class="section">
        <h2>Tools & Technologies</h2>
        <div class="tech">
            <span>PostgreSQL</span>
            <span>SQL</span>
            <span>Power BI</span>
            <span>Excel</span>
            <span>Data Analysis</span>
            <span>Business Intelligence</span>
        </div>
    </div>

    <div class="section">
        <h2>Conclusion</h2>
        <p>
            This project demonstrates the use of SQL-driven analytics and dashboarding to evaluate 
            inventory efficiency, pricing strategies, and revenue performance. The insights can help 
            improve stock planning, optimize discount strategies, and enhance overall operational efficiency 
            for quick-commerce platforms like Zepto.
        </p>
    </div>

</body>
</html>
