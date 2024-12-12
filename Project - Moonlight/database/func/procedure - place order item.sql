DELIMITER //

CREATE PROCEDURE place_order_item(
    IN p_order_id SMALLINT,
    IN p_item_id SMALLINT,
    IN p_size_id SMALLINT,
    IN p_item_quantity SMALLINT,
    IN p_addon_id SMALLINT,
    IN p_addon_quantity SMALLINT
)
BEGIN
    DECLARE v_item_id SMALLINT;
    DECLARE v_has_size BOOLEAN;
    DECLARE v_has_addons BOOLEAN;
    DECLARE v_order_item_id SMALLINT;
    DECLARE v_base_price DECIMAL(10,2);
    DECLARE v_tax_price DECIMAL(10,2);
    DECLARE v_subtotal_base_price DECIMAL(10,2);
    DECLARE v_subtotal_tax_price DECIMAL(10,2);

    -- Check if the item exists and get attributes
    SELECT item_id, has_size, has_addons
    INTO v_item_id, v_has_size, v_has_addons
    FROM items
    WHERE item_id = p_item_id;

    -- Error handling: Stop if the item does not exist
    IF v_item_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid item ID';
    END IF;

    -- Get the base and tax-inclusive price
    SELECT base_price, tax_inclusive_price
    INTO v_base_price, v_tax_price
    FROM prices
    WHERE item_id = p_item_id AND (size_id = p_size_id OR size_id IS NULL);

    -- Error handling: Stop if no price is found
    IF v_base_price IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found for the specified item/size';
    END IF;

    -- Compute subtotals
    SET v_subtotal_base_price = v_base_price * p_item_quantity;
    SET v_subtotal_tax_price = v_tax_price * p_item_quantity;

    -- Insert into order_items
    IF v_has_size THEN
        INSERT INTO order_items (
            order_id, item_id, size_id, quantity, item_base_price, item_tax_price,
            item_subtotal_base_price, item_subtotal_tax_price, item_total_base_price, item_total_tax_price
        )
        VALUES (
            p_order_id, p_item_id, p_size_id, p_item_quantity, v_base_price, v_tax_price,
            v_subtotal_base_price, v_subtotal_tax_price, v_subtotal_base_price, v_subtotal_tax_price
        );
    ELSE
        INSERT INTO order_items (
            order_id, item_id, quantity, item_base_price, item_tax_price,
            item_subtotal_base_price, item_subtotal_tax_price, item_total_base_price, item_total_tax_price
        )
        VALUES (
            p_order_id, p_item_id, p_item_quantity, v_base_price, v_tax_price,
            v_subtotal_base_price, v_subtotal_tax_price, v_subtotal_base_price, v_subtotal_tax_price
        );
    END IF;

    SET v_order_item_id = LAST_INSERT_ID();

    -- Add addons if applicable
    IF v_has_addons THEN
        CALL place_order_addons(v_order_item_id, p_addon_id, p_addon_quantity);
    END IF;

END //

DELIMITER ;
