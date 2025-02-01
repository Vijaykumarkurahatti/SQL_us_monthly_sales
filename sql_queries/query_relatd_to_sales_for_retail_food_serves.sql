-- 1) Top performing industries in terms of sales for year 2021 and how do their sales compre month overmonth

WITH monthly_sales AS(
SELECT year,month,industry,SUM(sales) AS total_sales
FROM retail_sales
WHERE year = 2021
GROUP BY year,month,industry),

top_industries AS (
SELECT year,month,industry,total_sales,
RANK() OVER (PARTITION BY year,month ORDER BY total_sales DESC) AS industry_rank
FROM monthly_sales)

SELECT year,month,industry,total_sales,industry_rank
FROM top_industries
where industry_rank=1
order by year,month;



-- -- 2) Top performing industries in terms of sales in 2022, and how do their sales compare month over month
WITH monthly_sales AS (
SELECT year,month,industry, SUM(sales) as total_sales
FROM retail_sales
WHERE year=2022
GROUP BY year,month,industry),

top_industries AS (
SELECT year,month,industry,total_sales,RANK() OVER (PARTITION BY year,month ORDER BY total_sales DESC) AS industry_rank
FROM monthly_sales)

SELECT year,month,industry,total_sales
FROM top_industries
WHERE industry_rank =1
ORDER BY year,month;

-- 3) Top performing industries in terms of sales from year 2020, and how do thier saes compare month over month
WITH monthly_sales AS(
SELECT year,month,industry,SUM(sales) AS total_sales
FROM retail_sales
WHERE year=2020
GROUP BY year,month,industry
),
top_industries AS (
SELECT year,month,industry,total_sales,
RANK() OVER (PARTITION BY year,month ORDER BY total_sales DESC) AS industry_rank
FROM monthly_sales
)
SELECT year,month,industry,total_sales
FROM top_industries
where industry_rank=1
ORDER BY year,month;

-- 4) Top performing industries in terms of sales from year 2019, and how do their sales compre month-over- month
WITH monthly_sales AS(
SELECT year,month,industry,SUM(sales) AS total_sales
FROM retail_sales
WHERE year = 2019
GROUP BY year,month,industry
),
top_industries AS (
SELECT year,month,industry,total_sales,
RANK() OVER (PARTITION BY year,month ORDER BY total_sales DESC) AS industry_rank
FROM monthly_sales
)
SELECT year,month,industry,total_sales
FROM top_industries
where industry_rank=1
ORDER BY year,month;


-- 5)Busines Question : Which specific kind of business contribute the most to total sale and how does their performance vary across industies
-- SELECT * FROM retail_sales;

SELECT kind_of_business,industry,SUM(sales) AS total_sales
FROM retail_sales
GROUP BY kind_of_business,industry
ORDER BY total_sales DESC;

-- 6 Business QUestion : Is there any seasonlity in sales for specific industries and how do they perform month over month
SELECT industry,year,month,SUM(sales) AS total_sales
FROM retail_sales
GROUP BY year,industry ,month
ORDER BY year,industry,month;



-- SELECT * FROM retail_sales;
-- 7)Business quetion : How does the sales distribution vary amng industries based on their Noth AMerican Industry ClassificationSystem (NAICS) codes?
SELECT naics_code,industry,SUM(sales) AS total_sales
FROM retail_sales
GROUP BY naics_code,industry
ORDER BY naics_code,total_sales DESC;

-- 8) Busine Quetion : Are their any outliers or significant chnges in sales for specific industries during particular months or years
SELECT industry,year,month,sales
FROM retail_sales
WHERE (industry,year,month) IN (
	SELECT industry,year,month
	FROM (
		SELECT industry,year,month,sales,
		LAG(sales) OVER (PARTITION BY industry ORDER BY year,month) AS prev_sales,
		LEAD(sales) OVER (PARTITION BY industry ORDER BY year,month) AS next_sales
		FROM retail_sales
	) AS sales_analysis
	WHERE sales > 1.5 * COALESCE(prev_sales,0) OR sales > 1.5 * COALESCE(next_sales,0)
)
ORDER BY industry,year,month

--9) WHich busines all time average sale was above 10000 dolrs?
SELECT kind_of_business,AVG(sales) AS average_sale 
FROM retail_sales
GROUP BY kind_of_business
HAVING AVG(sales) > 10000;


-- 10) Which kind of business within the automaotive industrty has the highest sales revenue for 2022
SELECT kind_of_business,SUM(sales) AS total_sales 
FROM retail_sales 
WHERE industry='Automotive' and year=2022
GROUP BY kind_of_business
ORDER BY total_sales DESC

-- 11) What is the contribution percentage of each busines in the automotive industry this year?
WITH automotive_sales AS(
	SELECT kind_of_business,sum(sales) AS total_sales
	FROM retail_sales
	WHERE industry='Automotive' AND year=2022
	GROUP BY kind_of_business
 ),
 total_sales_automotive AS(
	SELECT SUM(sales) AS total_sales_automotive
	FROM retail_sales
	WHERE industry='Automotive' AND year=2022
 )
 SELECT kind_of_business,
 ROUND((total_sales/ total_sales_automotive.total_sales_automotive)*100,2) AS contribution_percentage
 FROM automotive_sales
 CROSS JOIN total_sales_automotive;


-- 12) calculate the Year-over-Year (YoY) percentage change in sales for each industry. or What are the year-over-year growth rates for each industry per year?
with total_sales as(select year, industry, sum(sales) as sales_sum
from retail_sales
GROUP BY 1,2)

SELECT curr.industry, prev.year as previous_year, curr.year as current_year,
    (curr.sales_sum - prev.sales_sum) / prev.sales_sum * 100 as YoY

from total_sales as curr
join total_sales as prev
   on curr.year=prev.year+1 AND curr.industry=prev.industry
ORDER BY industry, curr.year DESC;

--OR--
select year,industry,
	(sales- LAG(sales) OVER (PARTITION BY industry ORDER BY year)) / LAG(sales) OVER (PARTITION BY industry ORDER BY year) * 100 AS growth_rate
FROM retail_sales
ORDER BY industry,year

-- 13) What are the yerly total sales for women clothing store and mens clothing store 
SELECT 
    year,
    sum(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales ELSE 0 END) as women_sales,
    sum(CASE WHEN kind_of_business = 'Men''s clothing stores' THEN sales ELSE 0 END) as men_sales
FROM 
    retail_sales
GROUP BY 
    year;

-- 14) What is the yearly ratio of total sales for women clothing store to total sales for men's clothing stores?
SELECT year, women_sales/NULLIF(men_sales,0) AS Women_to_Men_ratio
FROM (
	SELECT year,
	sum(CASE when kind_of_business = 'Women''s clothing stores' THEN sales ELSE 0 END) as women_sales,
	sum(CASE when kind_of_business = 'Men''s clothing stores' THEN sales ELSE 0 END) as men_sales
	FROM retail_sales
	GROUP BY 1
);


--15 What is the yer to date total sale of each month for 2019,2020,2021 and 2022 for womens clothing stores?
SELECT rs.month,rs.year,rs.sales,
	(
		(
			SELECT SUM(sales)
			FROM retail_sales rs2
			where rs2.year = rs.year
			and rs2.month <=rs.month
			AND rs2.kind_of_business = 'Women''s clothing stores'
		)
	) AS ytd_sales
FROM retail_sales as rs
WHERE rs.kind_of_business = 'Women''s clothing stores'
	AND rs.year IN (2019,2020,2021,2022);


-- 16 What is the month-over-month growth rate of women clothing business in 2022
--Q1
SELECT month,sales AS current_sales,
		-- now we want sales from one previous period 
		LAG(sales,1) OVER (ORDER BY month) AS prev_sales
	FROM
		retail_sales
	WHERE
		kind_of_business = 'Women''s clothing stores'
		AND year=2022;
--Q2

SELECT
    month,
    sales AS current_sales,
    LAG(sales, 1) OVER (ORDER BY month) AS prev_sales,
    (sales - LAG(sales, 1) OVER (ORDER BY month)) / LAG(sales, 1) OVER (ORDER BY month) * 100 AS growth_rate
FROM
    retail_sales
WHERE
    kind_of_business = 'Women''s clothing stores'
    AND year = 2022;













