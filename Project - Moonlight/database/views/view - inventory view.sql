CREATE OR REPLACE VIEW Inventory_View AS
SELECT
    SELECT 
        inv.inventory_id,
        COALESCE(ing.ingredient_name, a.addon_name) AS stock_name,
        inv.quantity,
        inv.reorder_level
    FROM 
        inventory inv
    LEFT JOIN ingredients ing ON inv.ingredient_id = ing.ingredient_id
    LEFT JOIN addons a ON inv.addon_id = a.addon_id