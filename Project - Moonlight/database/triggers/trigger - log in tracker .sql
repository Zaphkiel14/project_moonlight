drop trigger if exists loggintracker;

delimiter $$

create trigger loggedintracker
after update
on users
for each row
begin
	insert into login_log (user_id,user_name, user_status, date)
    values(new.user_id,new.user_name, new.user_status, now());
end$$

delimiter ;