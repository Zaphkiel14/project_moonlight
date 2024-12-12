DELIMITER $$

CREATE TRIGGER StockNotifications
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    DECLARE item_name VARCHAR(100);

    -- Determine whether to fetch the ingredient name or addon name
    SET item_name = (
        CASE
            WHEN NEW.ingredient_id IS NOT NULL THEN (SELECT ingredient_name FROM ingredients WHERE ingredient_id = NEW.ingredient_id)
            WHEN NEW.addon_id IS NOT NULL THEN (SELECT addon_name FROM addons WHERE addon_id = NEW.addon_id)
            ELSE 'Unknown'
        END
    );

    -- Insert "Out of Stock" notification if quantity reaches 0
    IF NEW.quantity = 0 THEN
        INSERT INTO notification_log (notification_type, notification_message, notification_time)
        VALUES ('Out of stock', CONCAT(item_name, ' is out of stock'), NOW());
    END IF;

    -- Insert "Low on Stock" notification if quantity falls below reorder level
    IF NEW.quantity <= NEW.reorder_level THEN
        INSERT INTO notification_log (notification_type, notification_message, notification_time)
        VALUES ('Low on stock', CONCAT(item_name, ' is low on stock'), NOW());
    END IF;
END $$

DELIMITER ;
