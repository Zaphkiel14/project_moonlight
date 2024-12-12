DROP PROCEDURE IF EXISTS LoginUser;
DELIMITER $$

CREATE PROCEDURE LoginUser (
    IN p_user_name VARCHAR(50),
    IN p_password VARCHAR(255),
    OUT login_message VARCHAR(100),
    OUT p_user_id SMALLINT UNSIGNED,
    OUT p_user_role VARCHAR(50)
)
BEGIN
    DECLARE v_password VARCHAR(255);
    DECLARE v_user_id SMALLINT UNSIGNED;
    DECLARE v_user_role VARCHAR(50);
    DECLARE v_is_verified BOOLEAN;

    -- Initialize output variables
    SET login_message = '';
    SET p_user_id = NULL;
    SET p_user_role = NULL;

    login_block: BEGIN
        -- Check if username exists and retrieve stored details
        SELECT user_id, password, user_role, is_verified 
        INTO v_user_id, v_password, v_user_role, v_is_verified
        FROM users
        WHERE LOWER(TRIM(user_name)) = LOWER(TRIM(p_user_name));

        -- If no user is found, set login message and leave the block
        IF v_user_id IS NULL THEN
            SET login_message = 'User not found';
            LEAVE login_block;
        END IF;

        -- Check if the account is verified
        IF v_is_verified = FALSE THEN
            SET login_message = 'Account is not verified. Please contact admin.';
            LEAVE login_block;
        END IF;

        -- Verify password
        IF v_password = p_password THEN
            SET login_message = 'Login successful';
            SET p_user_role = v_user_role;
            SET p_user_id = v_user_id;

            -- Update the user's status to 'Logged In'
            UPDATE users 
            SET user_status = TRUE 
            WHERE user_id = v_user_id;
        ELSE
            SET login_message = 'Incorrect password';
            SET p_user_id = NULL;
            SET p_user_role = NULL;
        END IF;
    END login_block;
END$$

DELIMITER ;

-- Test the procedure
SET @user_name = '';
SET @password = '';
SET @login_message = '';
SET @user_id = NULL;
SET @user_role = '';

CALL LoginUser(@user_name, @password, @login_message, @user_id, @user_role);
SELECT @login_message AS login_message, @user_id AS user_id, @user_role AS user_role;
