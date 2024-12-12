CREATE OR REPLACE VIEW sales_this_week AS
SELECT 
    DATE(date) AS sale_date,
    SUM(amount_due) AS total_sales
FROM orders
WHERE YEARWEEK(date, 1) = YEARWEEK(CURDATE(), 1)
GROUP BY sale_date;