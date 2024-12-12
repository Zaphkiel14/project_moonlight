DELIMITER $$

CREATE TRIGGER MissingValueNotificationIngredient
AFTER INSERT ON ingredients
FOR EACH ROW
BEGIN
    -- Check if 'unit' is NULL and log a notification
    IF NEW.unit IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('unit is missing for ingredient: ',new.ingredient_name));
    END IF;
END$$

DELIMITER ; 
