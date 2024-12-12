CREATE VIEW menuoverview AS
SELECT 
    i.Item_id,
    i.Item_name,
    i.Item_description,
    i.Has_size,
    i.Has_addons,

    -- Subquery for Categories
    (
        SELECT GROUP_CONCAT(DISTINCT c.Category_name ORDER BY c.Category_name ASC)
        FROM item_categories ic 
        JOIN categories c ON ic.Category_id = c.Category_id
        WHERE ic.Item_id = i.Item_id
    ) AS Categories,

    -- Subquery for Sizes and Prices (CSV format)
    (
        CASE 
            WHEN i.Has_size = TRUE THEN 
                (
                    SELECT GROUP_CONCAT(CONCAT(s.Size_name, ',', p.tax_inclusive_price) ORDER BY s.Size_name ASC)
                    FROM prices p
                    JOIN sizes s ON p.Size_id = s.Size_id
                    WHERE p.Item_id = i.Item_id
                )
            ELSE 
                (
                    SELECT GROUP_CONCAT(p.tax_inclusive_price ORDER BY p.tax_inclusive_price ASC)
                    FROM prices p
                    WHERE p.Item_id = i.Item_id AND p.Size_id IS NULL
                )
        END
    ) AS Item_Prices,

    -- Subquery for Addons
    (
        SELECT GROUP_CONCAT(DISTINCT a.Addon_name ORDER BY a.Addon_name ASC)
        FROM item_addons ia 
        JOIN addons a ON ia.Addon_id = a.Addon_id
        WHERE ia.Item_id = i.Item_id
    ) AS Addons,

    -- Subquery for Ingredients (CSV format)
    (
        SELECT GROUP_CONCAT(CONCAT(ing.Ingredient_name, ',', ii.Quantity_needed, ',', ing.Unit) ORDER BY ing.Ingredient_name ASC)
        FROM item_ingredients ii
        JOIN ingredients ing ON ii.Ingredient_id = ing.Ingredient_id
        WHERE ii.Item_id = i.Item_id
    ) AS Ingredients

FROM items i;
