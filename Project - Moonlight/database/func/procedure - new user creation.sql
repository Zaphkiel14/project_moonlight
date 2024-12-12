drop procedure if exists createnewuser;

delimiter $$

create procedure createnewuser(
in p_username varchar(50),
in p_password varchar(255),
in p_user_role varchar(50)
)
begin
	declare v_user_id int;
	-- declare V_role_id int;
	
		start transaction;
		main_block: begin
    
		-- check if the user already exists
		select user_id into v_user_id
		from users
		where user_name = trim(lower(p_username));
    
		-- if it does then exit the procedure
		if v_user_id is not null then
			commit;
			leave main_block;
		end if;
    
		-- check if role already exist
		-- SELECT role_id INTO v_role_id 
        -- FROM roles
		-- WHERE role_name = trim(lower(p_role_name))
		-- LIMIT 1;
    
		-- if role does not exist then insert it
		-- if v_role_id is null then
		-- 	insert into roles(role_name)
		-- 	values (trim(lower(p_role_name)));
		-- 	set v_role_id = last_insert_id();
		-- end if;
    
		-- if it does not exists then insert the user
		if v_user_id is null then
			insert into users(user_name, password, created_at, user_role)
			values(trim(lower(p_username)),trim(lower(p_password)),now(),p_user_role);
		end if;
    
		end main_block;
		commit;
end$$

delimiter ;