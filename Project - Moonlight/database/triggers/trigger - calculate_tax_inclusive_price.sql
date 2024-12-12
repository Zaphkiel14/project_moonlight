DELIMITER $$

CREATE TRIGGER calculate_tax_inclusive_price
BEFORE INSERT ON prices
FOR EACH ROW
BEGIN
    DECLARE v_tax_rate DECIMAL(5,2);

    -- Retrieve the current tax rate
    SELECT tax_rate INTO v_tax_rate
    FROM tax_config;

    -- Calculate the tax-inclusive price
    SET NEW.tax_inclusive_price = NEW.base_price * (1 + v_tax_rate / 100);
END$$

DELIMITER ;
 