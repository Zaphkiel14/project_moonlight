////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NOTIFICATION TRIGGERS FOR STORE BRANCH
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DELIMTER //

CREATE TRIGGER NewInsertionNotificationStoreBranch
after INSERT ON Store_branch
for each row
begin
    -- insert a notification to notify the admin regarding the new store branch
    INSERT INTO notification_log (notification_type, notification_message)
    VALUES ('new store branch', CONCAT('New Store Branch Created: ID#',new.store_branch_id));
    
DELIMITER ;

DELIMITER //

CREATE TRIGGER MissingValueNotificationStoreBranch
after insert on Store_branch
for each row
begin

    -- if corporation name is null then insert a notification to notify the admin regarding the missing value
    IF new.corporation_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Corporation Name For Store Branch in: ID#',new.store_branch_id));
    END IF;
    -- if store name is null then insert a notification to notify the admin regarding the missing value
    IF NEW.store_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Store Name For Store Branch in: ID#',new.store_branch_id));
    END IF;
    -- if store address is null then insert a notification to notify the admin regarding the missing value
    IF NEW.store_address IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Store Address For Store Branch in: ID#',new.store_branch_id));
    END IF;

end//

DELIMITER ; 

DELIMITER //

CREATE TRIGGER UpdatedValueNotificationStoreBranch
after update on Store_branch
for each row
begin

    -- if corporation name has been updated then insert a notification to notify the admin regarding the update
    IF OLD.corporation_name <> NEW.corporation_name THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Corporation Name For Store Branch in: ID#',new.store_branch_id));
    END IF;
    -- if store name has been updated then insert a notification to notify the admin regarding the update
    IF OLD.store_name <> NEW.store_name THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Store Name For Store Branch in: ID#',new.store_branch_id));
    END IF;
    -- if store address has been updated then insert a notification to notify the admin regarding the update
    IF OLD.store_address <> NEW.store_address THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Store Address For Store Branch in: ID#',new.store_branch_id));
    END IF;

end//

DELIMITER ; 

DELIMITER //

create trigger DeletedValueNotificationStoreBranch
after delete on Store_branch
for each row
begin

    -- insert a notification to notify the admin regarding the deletion
    if old.corporation_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Corporation Name For Store Branch in: ID#',old.store_branch_id));
    end if;
    if old.store_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Store Name For Store Branch in: ID#',old.store_branch_id));
    end if;
    if old.store_address is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Store Address For Store Branch in: ID#',old.store_branch_id));
    end if;
end//

DELIMITER ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NOTIFICATION TRIGGERS FOR USERS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Delimiter //

CREATE TRIGGER MissingValueNotificationUsers
after insert on users
for each row
begin
    -- if user name is null then insert a notification to notify the admin regarding the missing value
    IF NEW.user_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing User Name For User in: ID#',new.user_id));
    END IF;
    -- if user password is null then insert a notification to notify the admin regarding the missing value
    IF NEW.user_password IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing User Password For User in: ID#',new.user_id));
    END IF;
end//

DELIMITER ;


Delimiter //

CREATE TRIGGER UpdatedValueNotificationUsers
after update on users
for each row
begin
    -- if user name has been updated then insert a notification to notify the admin regarding the update
    IF OLD.user_name <> NEW.user_name THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated User Name For User in: ID#',new.user_id));
    END IF;
    -- if user password has been updated then insert a notification to notify the admin regarding the update
    IF OLD.user_password <> NEW.user_password THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated User Password For User in: ID#',new.user_id));
    END IF;
end//
DELIMITER ; 

DELIMITER //

CREATE TRIGGER DeletedValueNotificationUsers
after delete on users
for each row
begin
    -- insert a notification to notify the admin regarding the deletion
    if old.user_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted User Name For User in: ID#',old.user_id));
    end if;
    if old.user_password is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted User Password For User in: ID#',old.user_id));
    end if;
end//

DELIMITER ;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NOTIFICATION TRIGGERS FOR EMPLOYEE DETAILS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


DELIMITER //

CREATE TRIGGER MissingValueNotificationEmployeeDetails
after insert on employee_details
for each row
begin
    -- if employee name is null then insert a notification to notify the admin regarding the missing value
    IF NEW.employee_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Employee Name For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee address is null then insert a notification to notify the admin regarding the missing value
    IF NEW.employee_address IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Employee Address For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee birthdate is null then insert a notification to notify the admin regarding the missing value
    IF NEW.employee_birthdate IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Employee Birthdate For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee position is null then insert a notification to notify the admin regarding the missing value
    IF NEW.employee_position IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Employee Position For Employee Details in: ID#',new.employee_id));
    END IF;
end//

DELIMITER ;

DELIMITER //

CREATE TRIGGER UpdatedValueNotificationEmployeeDetails
after update on employee_details
for each row
begin

    -- if employee name has been updated then insert a notification to notify the admin regarding the update
    IF OLD.employee_name <> NEW.employee_name THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Employee Name For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee address has been updated then insert a notification to notify the admin regarding the update
    IF OLD.employee_address <> NEW.employee_address THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Employee Address For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee birthdate has been updated then insert a notification to notify the admin regarding the update
    IF OLD.employee_birthdate <> NEW.employee_birthdate THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Employee Birthdate For Employee Details in: ID#',new.employee_id));
    END IF;
    -- if employee position has been updated then insert a notification to notify the admin regarding the update
    IF OLD.employee_position <> NEW.employee_position THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Employee Position For Employee Details in: ID#',new.employee_id));
    END IF;

end//

DELIMITER ;

DELIMITER //

CREATE TRIGGER DeletedValueNotificationEmployeeDetails
after delete on employee_details
for each rows
begin
    -- insert a notification to notify the admin regarding the deletion
    if old.employee_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Employee Name For Employee Details in: ID#',old.employee_id));
    end if;
    if old.employee_address is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Employee Address For Employee Details in: ID#',old.employee_id));
    end if;
    if old.employee_birthdate is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Employee Birthdate For Employee Details in: ID#',old.employee_id));
    end if;
    if old.employee_position is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Employee Position For Employee Details in: ID#',old.employee_id));
    end if;
end//

DELIMITER ;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NOTIFICATION TRIGGERS FOR ITEMS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

delimiter //

create trigger MissingValueNotificationItems
after insert on items
for each row
begin
    -- if item name is null then insert a notification to notify the admin regarding the missing value
    IF NEW.item_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Item Name For Items in: ID#',new.item_id));
    END IF;
    -- if item description is null then insert a notification to notify the admin regarding the missing value
    IF NEW.item_description IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Item Description For Items in: ID#',new.item_id));
    END IF;
    -- if item picture is null then insert a notification to notify the admin regarding the missing value
    IF NEW.item_picture IS NULL THEN
        Insert INTO notification_log (notification_type, notification_message)
        Values ('missing value', CONCAT('Missing Item Picture For Items in: ID#',new.item_id));
    end if;
end//

delimiter ;

delimiter //

create trigger UpdatedValueNotificationItems
after update on items
for each row
begin

    -- if item name has been updated then insert a notification to notify the admin regarding the updated
    IF OLD.item_name <> NEW.item_name THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Item Name For Items in: ID#',new.item_id));
    END IF;
    -- if item description has been updated then insert a notification to notify the admin regarding the updated
    IF OLD.item_description <> NEW.item_description THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Item Description For Items in: ID#',new.item_id));
    END IF;
    -- if item picture has been updated then insert a notification to notify the admin regarding the updated
    IF OLD.item_picture <> NEW.item_picture THEN
        Insert into notification_log (notification_type, notification_message)
        values ('updated value', CONCAT('Updated Item Picture For Items in: ID#',new.item_id));
    end if;

end//

delimiter ;

delimiter //

create trigger DeletedValueNotificationItems
after delete on items
for each rows
begin
    -- insert a notification to notify the admin regarding the deletion
    if old.item_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Item Name For Items in: ID#',old.item_id));
    end if;
    -- insert a notification to notify the admin regarding the deletion
    if old.item_description is null then
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Item Description For Items in: ID#',old.item_id));
    end if;
    -- insert a notification to notify the admin regarding the deletion
    if old.item_picture is null then
        Insert INTO notification_log (notification_type, notification_message)
        VALUES ('deleted value', CONCAT('Deleted Item Picture For Items in: ID#',old.item_id));
    end if;
end//

Delimiter;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NOTIFICATION TRIGGERS FOR CATEGORIES
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Delimiter //

create trigger MissingValueNotificationCategories
after insert on categories
for each row
begin
    -- if category name is null then insert a notification to notify the admin regarding the missing value
    IF NEW.category_name IS NULL THEN
        INSERT INTO notification_log (notification_type, notification_message)
        VALUES ('missing value', CONCAT('Missing Category Name For Categories in: ID#',new.category_id));
    end if;

delimiter ;

delimiter //

create trigger UpdatedValueNotificationCategories
after update on categories
for each row
begin
    -- if category name has been updated then insert a notification to notify the admin regarding the updated
    IF OLD.category_name <> NEW.category_name THEN
        Insert INTO notification_log (notification_type, notification_message)
        VALUES ('updated value', CONCAT('Updated Category Name For Categories in: ID#',new.category_id));
    END IF;

end//

delimiter ;

delimiter //

create trigger DeletedValueNotificationCategories
after delete on categories
for each row
begin  

    -- insert a notification to notify the admin regarding the 
    if old.category_name is null then
        INSERT INTO notification_log (notification_type, notification_message)
        values ('deleted value', concat('Deleted Category Name For Categories in: ID#',new.category_id));
    end if;
end//

delimiter ;

