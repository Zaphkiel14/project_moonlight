DELIMITER //

CREATE PROCEDURE place_order_item(
    IN p_order_id SMALLINT,
    IN p_item_id SMALLINT,
    IN p_size_id SMALLINT, -- Can be NULL
    IN p_item_quantity SMALLINT,
    IN p_addons JSON -- JSON array of addons with addon_id and quantity
)
BEGIN
    DECLARE v_item_id SMALLINT;
    DECLARE v_has_size BOOLEAN;
    DECLARE v_has_addons BOOLEAN;
    DECLARE v_base_price DECIMAL(10, 2);
    DECLARE v_tax_price DECIMAL(10, 2);
    DECLARE v_subtotal_base_price DECIMAL(10, 2);
    DECLARE v_subtotal_tax_price DECIMAL(10, 2);
    DECLARE v_order_item_id SMALLINT;
    DECLARE v_addon_id SMALLINT;
    DECLARE v_addon_quantity DECIMAL(10, 2);
    DECLARE v_index INT DEFAULT 0;

    -- Retrieve item details
    SELECT item_id, has_size, has_addons
    INTO v_item_id, v_has_size, v_has_addons
    FROM items
    WHERE item_id = p_item_id;

    -- Retrieve the price based on whether the item has sizes
    IF v_has_size THEN
        SELECT base_price, tax_inclusive_price
        INTO v_base_price, v_tax_price
        FROM prices
        WHERE item_id = p_item_id AND size_id = p_size_id;

        IF v_base_price IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found for the specified item/size';
        END IF;
    ELSE
        SELECT base_price, tax_inclusive_price
        INTO v_base_price, v_tax_price
        FROM prices
        WHERE item_id = p_item_id AND size_id IS NULL;

        IF v_base_price IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found for the specified item without size';
        END IF;
    END IF;

    -- Calculate subtotal prices for the item
    SET v_subtotal_base_price = v_base_price * p_item_quantity;
    SET v_subtotal_tax_price = v_tax_price * p_item_quantity;

    -- Insert the order item
    INSERT INTO order_items (
        order_id, item_id, size_id, quantity, item_base_price, item_tax_price, 
        item_subtotal_base_price, item_subtotal_tax_price, 
        item_total_base_price, item_total_tax_price
    )
    VALUES (
        p_order_id, p_item_id, p_size_id, p_item_quantity, 
        v_base_price, v_tax_price, 
        v_subtotal_base_price, v_subtotal_tax_price, 
        v_subtotal_base_price, v_subtotal_tax_price -- Initial total prices without addons
    );

    SET v_order_item_id = LAST_INSERT_ID();

    -- Handle addons if applicable
    IF v_has_addons AND JSON_LENGTH(p_addons) > 0 THEN
        WHILE v_index < JSON_LENGTH(p_addons) DO
            SET v_addon_id = JSON_UNQUOTE(JSON_EXTRACT(p_addons, CONCAT('$[', v_index, '].addon_id')));
            SET v_addon_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_addons, CONCAT('$[', v_index, '].quantity')));

            CALL place_order_addons(v_order_item_id, p_item_id, v_addon_id, v_addon_quantity);

            SET v_index = v_index + 1;
        END WHILE;
    END IF;

    -- Update total prices for the order item after processing addons
    UPDATE order_items
    SET item_total_base_price = item_subtotal_base_price + (
        SELECT IFNULL(SUM(addon_total_base_price), 0) 
        FROM order_item_addons 
        WHERE order_item_id = v_order_item_id
    ),
    item_total_tax_price = item_subtotal_tax_price + (
        SELECT IFNULL(SUM(addon_total_tax_price), 0) 
        FROM order_item_addons 
        WHERE order_item_id = v_order_item_id
    )
    WHERE order_item_id = v_order_item_id;
END;
//
DELIMITER ;

DELIMITER //

CREATE PROCEDURE place_order_addons(
    IN p_order_item_id SMALLINT,
    IN p_item_id SMALLINT,
    IN p_addon_id SMALLINT,
    IN p_addon_quantity DECIMAL(10,2)
)
BEGIN
    DECLARE v_addon_base_price DECIMAL(10, 2);
    DECLARE v_addon_tax_price DECIMAL(10, 2);

    -- Validate that the addon is linked to the item's addons
    IF NOT EXISTS (
        SELECT 1 
        FROM item_addons 
        WHERE addon_id = p_addon_id AND item_id = p_item_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Addon is not linked to the item';
    END IF;

    -- Retrieve addon price
    SELECT base_price, tax_inclusive_price
    INTO v_addon_base_price, v_addon_tax_price
    FROM prices
    WHERE addon_id = p_addon_id;

    -- Insert the addon into order_item_addons
    INSERT INTO order_item_addons (
        order_item_id, addon_id, addon_quantity, 
        addon_base_price, addon_tax_price, 
        addon_total_base_price, addon_total_tax_price
    )
    VALUES (
        p_order_item_id, p_addon_id, p_addon_quantity, 
        v_addon_base_price, v_addon_tax_price, 
        v_addon_base_price * p_addon_quantity, 
        v_addon_tax_price * p_addon_quantity
    );
END;
//
DELIMITER ;
