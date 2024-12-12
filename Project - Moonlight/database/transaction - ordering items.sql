
-- set isolation level for transaction
set transaction isolation level repeatable read;
start transaction;

-- new order

insert into order (order_status) values('in_progress');
savepoint startorder;
call place_order_items();




commit;

DELIMITER //

CREATE PROCEDURE place_order_items(
    in p_order_id smallint,
    in p_item_id smallint,
    in p_size_id smallint,
    in p_item_quantity smallint,
    in p_addon_quantity smallint
)
BEGIN
DECLARE v_order_item_id smallint;
DECLARE v_item_id smallint;
DECLARE v_item_name varchar(100);
DECLARE v_has_size boolean;
DECLARE v_has_addons boolean;
DECLARE v_item_tax_inclusive_price decimal(10,2);
DECLARE v_item_base_price decimal(10,2);
DECLARE v_addon_tax_inclusive_price decimal(10,2);
DECLARE v_addon_base_price decimal(10,2);


    -- insert order_items to initiate a new record for ordering items
    insert into order_items(order_id)
    values (p_order_id);
    set v_order_item_id = LAST_INSERT_ID();

    -- select the details of the item selected by the user
    select item_name, has_size, has_addons
    into v_item_name, v_has_size, v_has_addons
    from items
    where item_id = p_item_id;

    -- if size is true then use the user input to select the size they want
    if has_size then
        select tax_inclusive_price, base_price
        into v_item_tax_inclusive_price, v_item_base_price
        from prices
        where item_id = p_item_id and size = p_size_id
    end if;

    -- if addons are true then use the user input to select the addons they want
    if has_addons then
        select tax_inclusive_price, base_price
        into v_addon_tax_inclusive_price, v_addon_base_price
        from prices
        where item_id = p_item_id and addon_id = p_addon_id;
    end if;

    -- insert into order_items table
    insert into order_items (order_id,item_id,size_id,quantity item_price,item_total_price)
    values (p_order_id, p_item_id, p_size_id,p_item_quantity, v_item_tax_inclusive_price, v_item_tax_inclusive_price * p_item_quantity )

END//

DELIMITER ;

-- finished 
delimiter //
create procedure place_order_item(
    in p_order_id smallint,
    in p_item_id smallint,
    in p_size_id smallint,
    in p_item_quantity smallint,
    in p_addon_id smallint,
    in p_addon_quantity smallint
)
begin
declare v_item_id smallint;
declare v_has_size boolean;
declare v_has_addons boolean;
declare v_order_item_id smallint;

    select item_id, has_size, has_addons 
    into v_item_id, v_has_size, v_has_addons
    from items
    where item_id = p_item_id;

    if has_size then
        insert into order_items (order_id, item_id, size_id, quantity)
        values (p_order_id, p_item_id, p_size_id, p_item_quantity);
        set v_order_item_id = LAST_INSERT_ID();

    else
        insert into order_items (order_id, item_id, quantity)
        values (p_order_id, p_item_id, p_item_quantity);
        set v_order_item_id = LAST_INSERT_ID();
    end if;

    if has_addons then
        call place_order_addons(v_order_item_id, p_addon_id, p_addon_quantity);
    end if

end ; 
delimiter ;




DELIMITER //

CREATE PROCEDURE place_order_addons(
    in p_order_item_id smallint,
    in p_addon_id smallint,
    in p_addon_quantity smallint
)

BEGIN
DECLARE v_order_item_addon_id smallint;
DECLARE v_addon_base_price decimal(10,2);
DECLARE v_item_tax_inclusive_price decimal(10,2);
    --

    insert into order_item_addons(order_item_id,addon_id,addon_quantity)
    values (p_order_item_id,p_addon_id,p_addon_quantity);

END;

DELIMITER ;


delimiter //

create trigger auto_compute_pricing_in_addons
before insert on order_item_addons
for each row
begin
    set new.addon_base_price = (select base_price from prices where addon_id = new.addon_id);
    set new.addon_tax_price = (select tax_inclusive_price from prices where addon_id = new.addon_id);
    set new.item_total_base_price = new.addon_base_price * new.addon_quantity;
    set new.item_total_tax_price = new.addon_tax_price * new.addon_quantity;

end//

delimiter ; 


delimiter //

create trigger auto_compute_pricing_in_items
before insert on order_items
for each row
begin
    set new.item_base_price = (select base_price from prices where item_id = new.item_id and size_id = new.size_id);
    set new.item_tax_price = (select tax_inclusive_price from prices where item_id = new.item_id and size_id = new.size_id);
    set new.item_subtotal_base_price = new.item_base_price * new.quantity;
    set new.item_subtotal_tax_price = new.item_tax_price * new.quantity;
    set new.item_total_base_price = new.item_subtotal_base_price + (select SUM(addon_total_base_price) from order_item_addons where order_item_id = new.order_item_id);
    set new.item_total_tax_price = new.item_subtotal_tax_price + (select SUM(addon_total_tax_price) from order_item_addons where order_item_id = new.order_item_id)
end//

delimiter ;
