
DELIMITER //

CREATE PROCEDURE GetSalesReportByRange(
    IN time_range VARCHAR(10),        -- Accepts 'day', 'week', 'month', or 'year'
    IN start_date DATE,               -- Start date for the range
    IN end_date DATE                  -- End date for the range
)
BEGIN
    IF time_range = 'day' THEN
        SELECT 
            DATE(date) AS sale_date,
            HOUR(date) AS sale_hour,
            SUM(amount_due) AS total_sales
        FROM orders
        WHERE DATE(date) BETWEEN start_date AND end_date
        GROUP BY sale_date, sale_hour;

    ELSEIF time_range = 'week' THEN
        SELECT 
            DATE(date) AS sale_date,
            SUM(amount_due) AS total_sales
        FROM orders
        WHERE DATE(date) BETWEEN start_date AND end_date
        GROUP BY sale_date;

    ELSEIF time_range = 'month' THEN
        SELECT 
            YEAR(date) AS sale_year,
            MONTH(date) AS sale_month,
            SUM(amount_due) AS total_sales
        FROM orders
        WHERE DATE(date) BETWEEN start_date AND end_date
        GROUP BY sale_year, sale_month;

    ELSEIF time_range = 'year' THEN
        SELECT 
            YEAR(date) AS sale_year,
            SUM(amount_due) AS total_sales
        FROM orders
        WHERE DATE(date) BETWEEN start_date AND end_date
        GROUP BY sale_year;

    ELSE
        SELECT 'Invalid time range. Please select day, week, month, or year.' AS message;
    END IF;
END //

DELIMITER ;
