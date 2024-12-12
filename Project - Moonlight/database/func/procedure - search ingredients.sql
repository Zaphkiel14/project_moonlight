DELIMITER //
-- Stored Procedure to Search Ingredients
CREATE PROCEDURE SearchIngredients (IN searchIngredients VARCHAR(255))
BEGIN
    SELECT *
    FROM Ingredients
    WHERE ingredient_name LIKE CONCAT('%', searchIngredients, '%');
END //

DELIMITER ;