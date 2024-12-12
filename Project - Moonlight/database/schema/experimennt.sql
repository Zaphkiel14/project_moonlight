-- Complete Integrated Schema
drop database if exists project;
create database project;    
use project;

-- Database: store

-- Table: Store Branch
CREATE TABLE store_branch (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Employee Details
CREATE TABLE employee_details (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (branch_id) REFERENCES store_branch(branch_id) ON DELETE CASCADE
);

-- Table: Users (Updated with Roles Integration)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Roles
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Privileges
CREATE TABLE privileges (
    privilege_id INT AUTO_INCREMENT PRIMARY KEY,
    privilege_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    scope VARCHAR(100) DEFAULT '*.*', -- Specify target table or database
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Role_Privileges Mapping
CREATE TABLE role_privileges (
    role_id INT NOT NULL,
    privilege_id INT NOT NULL,
    PRIMARY KEY (role_id, privilege_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (privilege_id) REFERENCES privileges(privilege_id) ON DELETE CASCADE
);

-- Table: Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    branch_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES store_branch(branch_id) ON DELETE CASCADE
);

-- Procedure: Create Server User
DELIMITER $$
CREATE PROCEDURE create_server_user (
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_role_name VARCHAR(50)
)
BEGIN
    DECLARE v_role_id INT;

    -- Check if role exists
    SELECT role_id INTO v_role_id FROM roles WHERE role_name = p_role_name;
    IF v_role_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Role does not exist';
    END IF;

    -- Create the MySQL server user
    SET @create_user_query = CONCAT('CREATE USER ''', p_username, '''@''localhost'' IDENTIFIED BY ''', p_password, '''');
    PREPARE stmt FROM @create_user_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Assign database privileges based on role
    INSERT INTO users (username, password_hash, role_id) 
    VALUES (p_username, SHA2(p_password, 256), v_role_id);

    CALL grant_role_privileges_to_user(p_username, v_role_id);
END$$
DELIMITER ;

-- Procedure: Grant Role Privileges to User
DELIMITER $$
CREATE PROCEDURE grant_role_privileges_to_user (
    IN p_username VARCHAR(50),
    IN p_role_id INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_privilege_name VARCHAR(50);
    DECLARE v_scope VARCHAR(100);
    DECLARE cur CURSOR FOR SELECT privilege_name, scope FROM privileges p 
                          JOIN role_privileges rp ON p.privilege_id = rp.privilege_id
                          WHERE rp.role_id = p_role_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_privilege_name, v_scope;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET @grant_priv_query = CONCAT('GRANT ', v_privilege_name, ' ON ', v_scope, ' TO ''', p_username, '''@''localhost''');
        PREPARE stmt FROM @grant_priv_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cur;

    FLUSH PRIVILEGES;
END$$
DELIMITER ;

-- Example Usage
-- Step 1: Insert Roles
INSERT INTO roles (role_name) VALUES ('DB_Admin'), ('DB_User');

-- Step 2: Insert Privileges
INSERT INTO privileges (privilege_name, description, scope) 
VALUES 
    ('SELECT', 'Allows reading data', 'store.orders'),
    ('INSERT', 'Allows inserting data', 'store.orders'),
    ('UPDATE', 'Allows updating data', 'store.*');

-- Step 3: Assign Privileges to Roles
INSERT INTO role_privileges (role_id, privilege_id) 
VALUES 
    (1, 1), -- DB_Admin gets SELECT on store.orders
    (1, 2), -- DB_Admin gets INSERT on store.orders
    (1, 3), -- DB_Admin gets UPDATE on all tables in store
    (2, 1); -- DB_User gets SELECT only on store.orders

-- Step 4: Create Server Users
CALL create_server_user('admin_user', 'secure_password', 'DB_Admin');
CALL create_server_user('readonly_user', 'readonly_password', 'DB_User');
