DELIMITER //

CREATE TRIGGER AutoInsertIntoInventoryAddons
    AFTER INSERT ON Addons
    FOR EACH ROW
BEGIN
    INSERT INTO Inventory (addon_id, quantity)
    VALUES (NEW.id, 0);
END//

DELIMITER ;