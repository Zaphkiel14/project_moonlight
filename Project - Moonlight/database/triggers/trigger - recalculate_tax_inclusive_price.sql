DELIMITER $$

CREATE TRIGGER calculate_tax_inclusive_price
AFTER UPDATE ON tax_config
FOR EACH ROW
BEGIN

    DECLARE v_tax_rate DECIMAL(5,2);

    -- retrieve new tax rate and store it in v_tax_rate
    SELECT NEW.tax_rate INTO v_tax_rate
    FROM tax_config;

    -- update the prices with the new tax rate
    UPDATE prices SET tax_inclusive_price = base_price * (1 + v_tax_rate / 100);
END$$

DELIMITER ;
