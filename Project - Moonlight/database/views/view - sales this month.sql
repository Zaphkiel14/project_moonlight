CREATE OR REPLACE VIEW sales_this_month AS
SELECT 
    WEEK(date, 1) AS sale_week,
    SUM(amount_due) AS total_sales
FROM orders
WHERE MONTH(date) = MONTH(CURDATE()) AND YEAR(date) = YEAR(CURDATE())
GROUP BY sale_week;