CREATE OR REPLACE VIEW sales_today AS
SELECT 
    HOUR(date) AS sale_hour,
    SUM(amount_due) AS total_sales
FROM orders 
WHERE DATE(date) = CURDATE()
GROUP BY sale_hour;
