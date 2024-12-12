DELIMITER //

CREATE TRIGGER AutoInsertIntoInventoryIngredients
    AFTER INSERT ON Ingredients
    FOR EACH ROW
BEGIN
    INSERT INTO Inventory (ingredient_id, quantity)
    VALUES (NEW.id, 0);
END //
DELIMITER ;