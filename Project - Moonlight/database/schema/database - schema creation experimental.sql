drop database if exists project_moonlight_cafe;
create database project_moonlight_cafe;
use project_moonlight_cafe;

create table Store_branch(
	store_branch_id smallint unsigned primary key auto_increment,
    corporation_name varchar(100),
    store_name varchar(100),
    store_address varchar(100)
);

CREATE TABLE users (
    user_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_status boolean default false,
    user_role VARCHAR(50),
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'False = Not verified, True = Verified by admin'
);

create table employee_details(
	employee_id smallint unsigned primary key auto_increment,
    store_branch_id smallint unsigned,
    user_id smallint unsigned,
    employee_name varchar(100),
    employee_address varchar(100),
    employee_birthdate datetime,
    employee_position varchar(50),
    foreign key (store_branch_id) references store_branch(store_branch_id),
    foreign key (user_id) references users(user_id)
);

CREATE TABLE login_log(
	login_log_id smallint unsigned primary key auto_increment,
    user_id smallint unsigned,
    user_name varchar(50) not null,
    user_status enum('Logged In', 'Logged out'),
    date timestamp default current_timestamp,
    foreign key (user_id) references users(user_id)
);

CREATE TABLE items (
    item_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100),
    item_description VARCHAR(100),
    item_picture BLOB,
    has_size BOOLEAN DEFAULT FALSE,
    has_addons BOOLEAN DEFAULT FALSE,
    item_status ENUM('In stock','Sold Out')
);

CREATE TABLE categories (
    category_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100)
);

CREATE TABLE item_categories (
    item_category_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    item_id smallint unsigned,
    category_id smallint unsigned,
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE sizes (
    size_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    size_name VARCHAR(50),
    size_description VARCHAR(50)
);

CREATE TABLE orders (
    order_id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id SMALLINT UNSIGNED,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    vatable_sales DECIMAL(10,2),              -- Base price total (before tax)
    vat_amount DECIMAL(10,2),                 -- Total tax amount
    amount_due DECIMAL(10,2),                -- Price after tax (vatable_sales + vat_amount)
    amount_tendered DECIMAL(10,2),
    order_change DECIMAL(10,2),
    order_status ENUM('pending', 'in_progress','saved', 'completed','paid', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_id SMALLINT UNSIGNED NOT NULL,
    item_id SMALLINT UNSIGNED NOT NULL,
    size_id SMALLINT UNSIGNED NULL,
    quantity SMALLINT UNSIGNED NOT NULL,
    item_base_price DECIMAL(10,2) NOT NULL, -- base price
    item_tax_price DECIMAL(10,2), --  tax included price
    item_subtotal_base_price DECIMAL(10,2), -- total base price * item quantity
    item_subtotal_tax_price DECIMAL(10,2), -- total tax included price * item quantity
    item_total_base_price DECIMAL(10,2), -- total base price * item quantity + total base price addon * quantity
    item_total_tax_price DECIMAL(10,2), -- total tax included price * item quantity + total tax included price addon * quantity
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id)
);


CREATE TABLE ingredients (
    ingredient_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100),
    unit VARCHAR(50) -- e.g., liters, grams
);

CREATE TABLE addons (
    addon_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    addon_name VARCHAR(100),
    unit VARCHAR(50) -- e.g., liters, grams
);

-- Updated prices table to be polymorphic
CREATE TABLE prices (
    price_id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    item_id SMALLINT UNSIGNED NULL,            -- Item ID (used only for item-size pricing)
    size_id SMALLINT UNSIGNED NULL,            -- Size ID (used only for item-size pricing)
    addon_id SMALLINT UNSIGNED NULL,           -- Addon ID (used only for addon pricing)
    base_price DECIMAL(10,2) NOT NULL,         -- Base price before tax
    tax_inclusive_price DECIMAL(10,2),         -- Pre-calculated price with tax
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (size_id) REFERENCES sizes(size_id),
    FOREIGN KEY (addon_id) REFERENCES addons(addon_id),
    CHECK (
        (item_id IS NOT NULL AND size_id IS NULL AND addon_id IS NULL) OR
        (item_id IS NOT NULL AND size_id IS NOT NULL AND addon_id IS NULL) OR 
        (addon_id IS NOT NULL AND item_id IS NULL AND size_id IS NULL)
    )
);
CREATE TABLE order_item_addons (
    order_item_addon_id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_item_id SMALLINT UNSIGNED NOT NULL, -- Reference to the specific order item
    addon_id SMALLINT UNSIGNED NOT NULL,      -- Reference to the specific addon
    addon_quantity DECIMAL(10,2) NOT NULL DEFAULT 1, -- Quantity of the addon
    addon_base_price DECIMAL(10,2),               -- base price of the addon
    addon_tax_price DECIMAL(10,2),                -- tax included price of the addon
    addon_total_base_price DECIMAL(10,2), -- total base price of the addon multiplied by the quantity
    addon_total_tax_price DECIMAL(10,2), -- total tax included price of the addon multiplied by the quantity
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id),
    FOREIGN KEY (addon_id) REFERENCES addons(addon_id)
);


CREATE TABLE item_addons (
    item_addon_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    item_id smallint unsigned,
    addon_id smallint unsigned,
	 quantity_needed DECIMAL(10,2),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (addon_id) REFERENCES addons(addon_id)
);

-- Updated inventory table to be polymorphic
CREATE TABLE inventory (
    inventory_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    ingredient_id smallint unsigned NULL,       -- Ingredient ID (used only for ingredients)
    addon_id smallint unsigned NULL,            -- Addon ID (used only for addons)
    quantity DECIMAL(10,2) unsigned default 0 , -- Current stock level
	reorder_level DECIMAL(10,2),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id),
    FOREIGN KEY (addon_id) REFERENCES addons(addon_id),
    CHECK (
        (ingredient_id IS NOT NULL AND addon_id IS NULL) OR 
        (addon_id IS NOT NULL AND ingredient_id IS NULL)
    )
);


CREATE TABLE item_ingredients (
    item_ingredient_id smallint unsigned PRIMARY KEY AUTO_INCREMENT,
    item_id smallint unsigned,
    ingredient_id smallint unsigned,
    quantity_needed DECIMAL(10,2),
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
create table Notification_log(
	notification_id smallint unsigned primary key auto_increment,
    notification_type varchar(50),
    notification_message varchar(255),
    notification_time datetime
);

create table customer_feedback(
	customer_feedback_id smallint unsigned primary key auto_increment,
    order_id smallint unsigned,
	feedback_rating enum('0','1','2','3','4','5') default'0',
	feedback_message varchar(255),
    foreign key (order_id) references orders(order_id)
);


CREATE TABLE tax_config (
    tax_id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    tax_rate DECIMAL(5,2) NOT NULL DEFAULT 12.00 COMMENT 'Tax rate as a percentage (e.g., 12.00 for 12%)'
);
