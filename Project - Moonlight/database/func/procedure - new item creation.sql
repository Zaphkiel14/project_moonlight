DELIMITER $$

CREATE PROCEDURE InsertNewItem(
    IN p_item_name VARCHAR(100),
    IN p_item_description VARCHAR(255),
    IN p_item_picture BLOB,
    IN p_has_size BOOLEAN,
    IN p_has_addons BOOLEAN,
    IN p_category_names VARCHAR(255),
    IN p_base_prices_csv TEXT,
    IN p_addon_names VARCHAR(255),
    IN p_ingredients_csv TEXT
)
BEGIN
    DECLARE v_item_id smallint unsigned;
    DECLARE v_category_id smallint unsigned;
    DECLARE v_size_id smallint unsigned;
    DECLARE v_addon_id smallint unsigned;
    DECLARE v_ingredient_id smallint unsigned;
    DECLARE v_size_name VARCHAR(50);
    DECLARE v_size_base_price DECIMAL(10, 2);
    DECLARE v_temp_category_name VARCHAR(100);
    DECLARE v_temp_addon_name VARCHAR(100);
    DECLARE v_ingredient_name VARCHAR(100);
    DECLARE v_quantity_needed DECIMAL(10, 2);
    DECLARE v_unit VARCHAR(50);
    DECLARE v_csv_length smallint unsigned DEFAULT (LENGTH(p_ingredients_csv) - LENGTH(REPLACE(p_ingredients_csv, ',', '')))/3;
    DECLARE v_index smallint unsigned DEFAULT 0;
    DECLARE v_base_prices_index smallint unsigned DEFAULT 0;
    DECLARE v_base_prices_length smallint unsigned DEFAULT (LENGTH(p_base_prices_csv) - LENGTH(REPLACE(p_base_prices_csv, ',', '')))/2;

    -- Handle errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'An error occurred, rolling back.' AS Error_Message;
        -- Handle exception if needed
    END;

    -- Start transaction
    START TRANSACTION;

    -- Main Block
    main_block: BEGIN

-- check if the item already exists

    SELECT item_id INTO v_item_id
    FROM items
    WHERE Item_name = p_item_name ;
    
    -- if it does then exit the procedure
    IF v_item_id IS NOT NULL THEN
        commit;
         LEAVE main_block;
    END IF;

    -- if does not exit then insert the item name
    IF v_item_id IS NULL THEN
      INSERT INTO items (Item_name, Item_description, Item_picture, Has_size, Has_addons) 
      VALUES (p_item_name, p_item_description, p_item_picture, p_has_size, p_has_addons);
      SET v_item_id = LAST_INSERT_ID();
    END IF;

    -- handle categories  
     WHILE LENGTH(p_category_names) > 0 DO
        SET v_temp_category_name = TRIM(SUBSTRING_INDEX(p_category_names, ',', 1));


        -- Reset category id before each iteration
        SET v_category_id = NULL;
        
        -- check if category already exists

        SELECT Category_id INTO v_category_id 
        FROM categories 
        WHERE Category_name = v_temp_category_name 
        LIMIT 1;
        -- if category does not exist then insert it

        IF v_category_id IS NULL THEN
            INSERT INTO categories (Category_name) 
            VALUES (v_temp_category_name);
            SET v_category_id = LAST_INSERT_ID();
        END IF;

        -- Insert into item_categories, ensuring uniqueness
        INSERT IGNORE INTO item_categories (Item_id, Category_id) 
        VALUES (v_item_id, v_category_id);

        SELECT CONCAT('Inserted Category: ', v_temp_category_name, ' - ID: ', v_category_id) AS Debug_Category;

        -- Remove processed category from the list
        SET p_category_names = TRIM(BOTH ',' FROM SUBSTRING(p_category_names, LENGTH(v_temp_category_name) + 2));
    END WHILE;


    -- check if sizes is true 
    case
        when p_has_size = TRUE then
            -- handle sizes and base_prices 
            WHILE v_base_prices_index < v_base_prices_length DO
            SET v_size_name = TRIM(SUBSTRING_INDEX(p_base_prices_csv, ',', 1));
            SET p_base_prices_csv = SUBSTRING(p_base_prices_csv, LENGTH(v_size_name) + 2);
                
            SET v_size_base_price = TRIM(SUBSTRING_INDEX(p_base_prices_csv, ',', 1));
            SET p_base_prices_csv = SUBSTRING(p_base_prices_csv, LENGTH(v_size_base_price) + 2);
            
            -- reset size id before each iteration
            SET v_size_id = NULL;

            -- check if the size already exists
            SELECT size_id into v_size_id
            FROM sizes
            WHERE size_name = v_size_name
            LIMIT 1;
            
            -- if the size doesn't exist then insert it     
            IF v_size_id IS NULL THEN
            INSERT INTO sizes (size_name)
            VALUES (v_size_name);
            SET v_size_id = LAST_INSERT_ID();
            END IF;


            -- insert into base_base_prices to create a unique association
            INSERT IGNORE INTO prices (Item_id, Size_id, base_price) 
            VALUES (v_item_id, v_size_id, v_size_base_price);


            -- debugging
            SELECT CONCAT('Inserted Size: ', v_size_name, ' - base_price: ', v_size_base_price) AS Debug_Size;

            SET v_base_prices_index = v_base_prices_index + 1;
            END WHILE;
        when p_has_size = false then
            -- insert into base_prices to create a unique association
            INSERT IGNORE INTO prices (item_id, base_price) 
            VALUES (v_item_id, p_base_prices_csv);
            SELECT CONCAT('Inserted base_price: ', p_base_prices_csv, 'with item id: ', v_item_id) AS Debug_base_price;
        else
            -- insert into base_prices to create a unique association
            leave main_block;

    end case;
    case 
        when p_has_addons = true then
            -- Handle Addons
            WHILE LENGTH(p_addon_names) > 0 DO
            SET v_temp_addon_name = TRIM(SUBSTRING_INDEX(p_addon_names, ',', 1));

            -- Reset addon ID before each iteration
            SET v_addon_id = NULL;

            -- Insert addon if it doesn't exist
            SELECT Addon_id INTO v_addon_id 
            FROM addons 
            WHERE Addon_name = v_temp_addon_name 
            LIMIT 1;

            IF v_addon_id IS NULL THEN
                INSERT INTO addons (Addon_name) 
                VALUES (v_temp_addon_name);
                SET v_addon_id = LAST_INSERT_ID();
            END IF;

            -- Insert into item_addons to create unique associations
            INSERT IGNORE INTO item_addons (Item_id, Addon_id) 
            VALUES (v_item_id, v_addon_id);

            -- Debugging
            SELECT CONCAT('Inserted Addon: ', v_temp_addon_name) AS Debug_Addon;

            -- SET p_addon_names = TRIM(BOTH ',' FROM SUBSTRING(p_addon_names, CHAR_LENGTH(v_temp_addon_name) + 1));
            SET p_addon_names = TRIM(BOTH ',' FROM SUBSTRING(p_addon_names, LENGTH(v_temp_addon_name) + 2));
            
            END WHILE;
        when p_has_addons = false then
            SELECT 'No addons to process.' AS Debug_Message;
        
        else
            leave main_block;
    END CASE;

    WHILE v_index < v_csv_length DO
      SET v_ingredient_name = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ingredients_csv, ',', v_index * 3 + 1), ',', -1));
      SET v_quantity_needed = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ingredients_csv, ',', v_index * 3 + 2), ',', -1));
      SET v_unit = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p_ingredients_csv, ',', v_index * 3 + 3), ',', -1));


      SET v_ingredient_id = NULL;

      -- Insert ingredient if it doesn't exist
      SELECT Ingredient_id INTO v_ingredient_id 
      FROM ingredients 
      WHERE Ingredient_name = v_ingredient_name
      LIMIT 1;

      IF v_ingredient_id IS NULL THEN
        INSERT INTO ingredients (Ingredient_name, Unit) 
        VALUES (v_ingredient_name, v_unit);
        SET v_ingredient_id = LAST_INSERT_ID();
      END IF;

      -- Insert into item_ingredients to create unique associations
      INSERT IGNORE INTO item_ingredients (Item_id, Ingredient_id, Quantity_needed) 
      VALUES (v_item_id, v_ingredient_id, v_quantity_needed);

      -- debugging
      SELECT CONCAT('Inserted Ingredient: ', v_ingredient_name, ' - Quantity: ', v_quantity_needed) AS Debug_Ingredient;

      SET v_index = v_index + 1;
    END WHILE;
	END main_block;
    COMMIT;
    
  END$$
DELIMITER ;


CALL InsertNewItem(
    'Cheese Pizza deluxe',                  -- p_item_name
    'A delicious cheese pizza.',     -- p_item_description
    NULL,                            -- p_item_picture (you can put a BLOB here if needed)
    true,                            -- p_has_size (TRUE/FALSE if the item has sizes)
    true,                            -- p_has_addons (TRUE/FALSE if the item has addons)
    'Pizza,Vegetarian',              -- p_category_names (comma-separated category names)
    'Small,5.99,Medium,7.99,Large,9.99', -- p_base_prices_csv (comma-separated sizes and base_prices)
   --  9.00,
    'ExtraCheese,Olives',           -- p_addon_names (comma-separated addon names)
    'Cheese,200,grams,Flour,500,grams,Tomato Sauce,100,ml' -- p_ingredients_csv (comma-separated ingredients in name, quantity, unit order)
);
 select * from menuoverview;