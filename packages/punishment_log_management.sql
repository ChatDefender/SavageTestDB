create or replace package punishment_log_management as 

    function insert_punishment(
        p_guild_id in NUMBER,
        p_staff_id in NUMBER,
        p_user_id in NUMBER,
        p_punishment_type in VARCHAR2,
        p_duration in VARCHAR2,
        p_reason in VARCHAR2
    ) return number;

    procedure archive (
        p_guild_id in number,
        p_punishment_log_id in number
    );

    procedure bulk_archive ( 
        p_guild_id in number,
        p_discord_id in number,
        p_is_staff in number
    );

    procedure unarchive (
        p_guild_id in number,
        p_punishment_log_id in number
    );

    procedure bulk_unarchive (
        p_guild_id in number,
        p_discord_id in number,
        p_is_staff in number
    );

end;

create or replace package body punishment_log_management as 

    function insert_punishment(
    
        p_guild_id in NUMBER,
        p_staff_id in NUMBER,
        p_user_id in NUMBER,
        p_punishment_type in VARCHAR2,
        p_duration in VARCHAR2,
        p_reason in VARCHAR2
        
    ) return number as 

        l_punishment_id number;

    begin

        select nvl(max(punishment_log_id), 0) + 1
        into l_punishment_id
        from punishment_logs
        where guild_id = p_guild_id;

        insert into punishment_logs (guild_id, punishment_log_id, staff_id, user_id, punishment_type, duration, reason)
        values (p_guild_id, l_punishment_id, p_staff_id, p_user_id, p_punishment_type, p_duration, p_reason);

        return l_punishment_id;

    end;

    procedure archive (
        p_guild_id in number,
        p_punishment_log_id in number
    ) as

    begin

        update punishment_logs
        set is_archived = 1
        where guild_id = p_guild_id
            and punishment_log_id = p_punishment_log_id;

    end;

    procedure bulk_archive ( 
        p_guild_id in number,
        p_discord_id in number,
        p_is_staff in number
    ) as
    begin

        if p_is_staff = 1 then 
            update punishment_logs
            set is_archived = 1
            where staff_id = p_discord_id
                and guild_id = p_guild_id;
        else 
            update punishment_logs
            set is_archived = 1
            where user_id = p_discord_id
                and guild_id = p_guild_id;
        end if;

    end;



    -- About: Archives specified log
    procedure unarchive (
        p_guild_id in number,
        p_punishment_log_id in number
    ) as

    begin

        update punishment_logs
        set is_archived = 0
        where guild_id = p_guild_id
            and punishment_log_id = p_punishment_log_id;

    end;

    procedure bulk_unarchive (
        p_guild_id in number,
        p_discord_id in number,
        p_is_staff in number
    ) as
    begin

        if p_is_staff = 1 then 
            update punishment_logs
            set is_archived = 0
            where staff_id = p_discord_id
                and guild_id = p_guild_id;
        else 
            update punishment_logs
            set is_archived = 0
            where user_id = p_discord_id
                and guild_id = p_guild_id;
        end if;

    end;



end;
