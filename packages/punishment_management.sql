create or replace package punishment_management as

    procedure create_punishment(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_create_user_id number
    );

    procedure delete_punishment(
        p_guild_id varchar2,
        p_punishment_name varchar2
    );

    procedure create_tier (
        p_guild_id varchar2, 
        p_punishment_name varchar2,
        p_punishment_type varchar2,
        p_duration number
    );

    procedure remove_tier(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_punishment_tier number
    );

    procedure edit_tier(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_punishment_tier number,
        p_column_name varchar2,
        p_new_value varchar2
    );

    procedure rename_punishment(
        p_guild_id varchar2, 
        p_old_name varchar2,
        p_new_name varchar2
    );

    function does_punishment_exist(
        p_guild_id varchar2, 
        p_punishment_name varchar2
    ) return number;

    procedure add_active_punishment (
        p_guild_id         IN NUMBER,
        p_user_id          IN NUMBER,
        p_punishment_name  IN VARCHAR2
    );

    procedure check_and_remove_expired_punishments;
end;

create or replace package body punishment_management as

    procedure create_punishment(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_create_user_id number
    ) is
    
        l_punishment_id number;

    begin

        select coalesce(max(punishment_id), 0) + 1
        into l_punishment_id
        from punishment
        where guild_id = p_guild_id;

        insert into punishment (guild_id, punishment_id, name, create_user, create_stamp)
        values (p_guild_id, l_punishment_id, p_punishment_name, p_create_user_id, sysdate);

    end;

    procedure delete_punishment(
        p_guild_id varchar2,
        p_punishment_name varchar2
    ) is

        deleted_id number;

    begin

        select punishment_id
        into deleted_id
        from punishment
        where guild_id = p_guild_id
            and name = upper(p_punishment_name);

        delete from punishment
        where punishment_id = deleted_id
            and guild_id = p_guild_id;

    end;

    procedure create_tier (
        p_guild_id varchar2, 
        p_punishment_name varchar2,
        p_punishment_type varchar2,
        p_duration number
    ) is

        l_punishment_id number;
        l_tier_id number;

    begin

        select punishment_id 
        into l_punishment_id
        from punishment
        where guild_id = p_guild_id 
            and name = upper(p_punishment_name);

        select nvl(max(punishment_tier), 0) + 1 
        into l_tier_id
        from punishment_tier 
        where punishment_id = l_punishment_id;

        insert into punishment_tier (guild_id, punishment_id, punishment_tier, punishment_type, punishment_time)
        values (p_guild_id, l_punishment_id, l_tier_id, p_punishment_type, p_duration);

    end;

    procedure remove_tier(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_punishment_tier number
    ) is

        l_punishment_id number;

    begin

        select punishment_id 
        into l_punishment_id
        from punishment
        where guild_id = p_guild_id 
            and name = upper(p_punishment_name);

        delete from punishment_tier
        where guild_id = p_guild_id
            and punishment_id = l_punishment_id 
            and punishment_tier = p_punishment_tier;

        update punishment_tier
        set punishment_tier = punishment_tier - 1
        where guild_id = p_guild_id
            and punishment_id = l_punishment_id 
            and punishment_tier > p_punishment_tier;

    end;

    procedure edit_tier(
        p_guild_id varchar2,
        p_punishment_name varchar2,
        p_punishment_tier number,
        p_column_name varchar2,
        p_new_value varchar2
    ) is

        l_punishment_id number;
        l_column varchar2(100);

    begin

        select punishment_id
        into l_punishment_id
        from punishment
        where guild_id = p_guild_id 
            and name = upper(p_punishment_name);

        l_column := lower(p_column_name);

        if l_column = 'punishment_type' then

            update punishment_tier
            set punishment_type = p_new_value
            where guild_id = p_guild_id 
                and punishment_id = l_punishment_id 
                and punishment_tier = p_punishment_tier;

        elsif l_column = 'punishment_time' then

            update punishment_tier
            set punishment_time = to_number(p_new_value)
            where guild_id = p_guild_id 
                and punishment_id = l_punishment_id 
                and punishment_tier = p_punishment_tier;

        end if;

    end;

    procedure rename_punishment(
        p_guild_id varchar2, 
        p_old_name varchar2,
        p_new_name varchar2
    ) is

        l_punishment_id number;

    begin

        update punishment
        set name = p_new_name
        where guild_id = p_guild_id 
            and name = upper(p_old_name);

    end;

    function does_punishment_exist(
        p_guild_id varchar2, 
        p_punishment_name varchar2
    ) return number is

        l_count number;

    begin

        select count(*)
        into l_count
        from punishment
        where guild_id = p_guild_id
            and name = upper(p_punishment_name);

        return case when l_count > 0 then 1 else 0 end;

    end;

    procedure add_active_punishment (
        p_guild_id         IN NUMBER,
        p_user_id          IN NUMBER,
        p_punishment_name  IN VARCHAR2
    ) IS
        l_start_date      DATE;
        l_punishment_id   NUMBER;
        l_duration_in_ms  NUMBER;
        l_reset_value_ms  NUMBER;
        l_final_duration  NUMBER;
        l_next_tier       NUMBER;
        l_punishment_type VARCHAR2(100);
    BEGIN
        -- Initialize start_date
        l_start_date := SYSDATE;

        SELECT punishment_id
        INTO l_punishment_id
        FROM punishment
        WHERE guild_id = p_guild_id
            and name = UPPER(p_punishment_name);


        SELECT COUNT(*) + 1
        INTO l_next_tier
        FROM punishment_active
        WHERE guild_id = p_guild_id
          AND user_id = p_user_id
          AND punishment_id = l_punishment_id;

        select 
            case 
                when max(punishment_tier) >= l_next_tier then l_next_tier
                else max(punishment_tier)
            end
        into l_next_tier
        from punishment_tier
        where guild_id = p_guild_id
          and punishment_id = l_punishment_id;

        SELECT punishment_time, punishment_type
        INTO l_duration_in_ms, l_punishment_type
        FROM punishment_tier
        WHERE guild_id = p_guild_id
          and punishment_id = l_punishment_id
          AND punishment_tier = l_next_tier;


        SELECT COALESCE(to_number(punishment_reset), 0)
        INTO l_reset_value_ms
        FROM setting
        WHERE guild_id = p_guild_id;

        l_final_duration := l_duration_in_ms + l_reset_value_ms;

        MERGE INTO punishment_active pa
        USING (SELECT p_guild_id AS guild_id,
                      p_user_id AS user_id,
                      l_punishment_id AS punishment_id
               FROM dual) src
        ON (pa.guild_id = src.guild_id AND pa.user_id = src.user_id AND pa.punishment_id = src.punishment_id)
        WHEN MATCHED THEN
            UPDATE SET
                start_date = l_start_date,
                duration_in_ms = l_final_duration,
                punishment_tier = l_next_tier
        WHEN NOT MATCHED THEN
            INSERT (guild_id, punishment_id, punishment_tier, user_id, start_date, duration_in_ms)
            VALUES (p_guild_id, l_punishment_id, l_next_tier, p_user_id, l_start_date, l_final_duration);   
    END;

    PROCEDURE check_and_remove_expired_punishments IS

    BEGIN

        DELETE FROM punishment_active
        WHERE SYSDATE > start_date +( duration_in_ms / 86400000 );

    END;

end;
