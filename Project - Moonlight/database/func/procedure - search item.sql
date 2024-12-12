DELIMITER //
-- Stored Procedure to Search Items
CREATE PROCEDURE SearchItems (IN searchItems VARCHAR(255))
BEGIN
    SELECT *
    FROM Items
    WHERE item_name LIKE CONCAT('%', searchItems, '%')
    OR item_description LIKE  CONCAT('%', searchItems, '%') ;
END //
DELIMITER ;