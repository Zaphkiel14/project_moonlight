DELIMITER //
-- Stored Procedure to Search Addons
CREATE PROCEDURE SearchAddons (IN searchAddons VARCHAR(255))
BEGIN
    SELECT *
    FROM Addons
    WHERE addon_name LIKE CONCAT('%', searchAddons, '%');
END //
DELIMITER ;