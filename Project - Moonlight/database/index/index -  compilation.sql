--  index for item
create index idx_item on items(item_name,item_description);

show index from items;

-- index for orders
create unique index idx_date on orders(date);

create index idx_date_amount on orders(data, amount_due);
show index from orders;

-- index for order_items

create index idx_inventory on inventory(inventory_id,ingredient_id);
create index idx_invetory1 on inventory(inventory_id,addon_id);

-- index for item_ingredients

create index idx_item_ingredients on item_ingredients(item_id,ingredient_id,quantity_needed);
create index idx_item_addons on item_addons(item_id,addon_id,quantity_needed);

-- index for prices

create index idx_price_with_size on prices(item_id, size_id);
create index idx_price_addon on prices(addon_id);
create index idx_price_without_size on prices(item_id);