delimiter $$
create trigger AccountVerificationNotification
after insert on users
for each row
begin

    if new.is_verified is null THEN
    INSERT INTO notification_log (notification_type, notification_message)
    VALUES ('Account Verification', CONCAT('Verify new user account named: ',new.user_name));
    END IF;

end$$

delimiter ;