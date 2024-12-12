DELIMITER //

-- Stored Procedure to Search Categories
CREATE PROCEDURE SearchCategories (IN searchCategories VARCHAR(255))
BEGIN
    SELECT *
    FROM Categories
    WHERE category_name LIKE CONCAT('%', searchCategories, '%');
END //

DELIMITER ;