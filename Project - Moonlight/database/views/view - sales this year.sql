CREATE OR REPLACE VIEW sales_this_year AS
SELECT
    MONTH(date) AS sale_month, -- Corrected to use MONTH function for month extraction
    SUM(amount_due) AS total_sales
FROM orders
WHERE YEAR(date) = YEAR(CURDATE())
GROUP BY sale_month;
