DELIMITER //

CREATE PROCEDURE place_order_addons(
    IN p_order_item_id SMALLINT,
    IN p_addon_id SMALLINT,
    IN p_addon_quantity SMALLINT
)
BEGIN
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_tax_price DECIMAL(10,2);
    DECLARE v_total_base_price DECIMAL(10,2);
    DECLARE v_total_tax_price DECIMAL(10,2);

    -- Check if the addon exists and get pricing
    SELECT base_price, tax_inclusive_price
    INTO v_base_price, v_tax_price
    FROM prices
    WHERE addon_id = p_addon_id;

    -- Error handling: Stop if the addon does not exist or price is missing
    IF v_base_price IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found for the specified addon';
    END IF;

    -- Compute total addon pricing
    SET v_total_base_price = v_base_price * p_addon_quantity;
    SET v_total_tax_price = v_tax_price * p_addon_quantity;

    -- Insert into order_item_addons
    INSERT INTO order_item_addons (
        order_item_id, addon_id, addon_quantity, addon_base_price, addon_tax_price, 
        addon_total_base_price, addon_total_tax_price
    )
    VALUES (
        p_order_item_id, p_addon_id, p_addon_quantity, v_base_price, v_tax_price,
        v_total_base_price, v_total_tax_price
    );

    -- Update order_items total price fields
    UPDATE order_items
    SET item_total_base_price = item_total_base_price + v_total_base_price,
        item_total_tax_price = item_total_tax_price + v_total_tax_price
    WHERE order_item_id = p_order_item_id;

END //

DELIMITER ;
