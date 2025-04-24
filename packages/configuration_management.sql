create or replace package CONFIGURATION_MANAGEMENT as 

    procedure verify_guild_setting (
        p_guild_id in number
    );

    FUNCTION get_setting (
        f_guild_id IN NUMBER, 
        f_setting IN VARCHAR2
    ) RETURN VARCHAR2;

    PROCEDURE update_settings (
        p_guild_id IN NUMBER,
        p_setting IN VARCHAR2,
        p_new_setting IN VARCHAR2
    );

    procedure remove_muted_role( 
        p_guild_id in number, 
        p_muted_role_id in number
    );

    procedure remove_punishment_logs (  
        p_guild_id in number, 
        p_text_chan_id number 
    );

end;


create or replace package body CONFIGURATION_MANAGEMENT as 

    -- About: Verifies if settings exist for that specific guild
    procedure  verify_guild_setting (
        p_guild_id in number
    ) as

        l_guild_count number;
        l_cmd_count number;

    begin

        select count(*)
        into l_guild_count
        from setting
        where guild_id = p_guild_id;

        if l_guild_count = 0 then 

            insert into setting (guild_id) VALUES (p_guild_id);

        end if;

        select count(*)
        into l_cmd_count
        from command
        where guild_id = p_guild_id;

        if l_cmd_count = 0 then 

            insert into command (guild_id, cmd_id, category, name)
            select p_guild_id, cmd_id, category, name
            from base_command;

        end if;


    end;

    -- About: Returns the requested setting to SavageBot Application
    FUNCTION get_setting (

        f_guild_id IN NUMBER,
        f_setting IN VARCHAR2

    ) RETURN VARCHAR2 IS

        l_rtn_val VARCHAR2(4000);
        l_count NUMBER := 0;
        l_query VARCHAR2(4000);

    BEGIN

        verify_guild_setting(p_guild_id => f_guild_id);

        SELECT COUNT(*)
        INTO l_count
        FROM all_tab_columns
        WHERE table_name = 'SETTING'
            and owner = (select user from dual)
            AND column_name = upper(f_setting);

        IF l_count = 1 THEN
            l_query := 'SELECT ' || f_setting || 
                       ' INTO :val FROM setting WHERE guild_id = :id';

            EXECUTE IMMEDIATE l_query INTO l_rtn_val USING f_guild_id;
        END IF;

        RETURN l_rtn_val;
    END;

    -- About: Updates a specified setting to a new value
    PROCEDURE           update_settings (
        p_guild_id IN NUMBER,
        p_setting IN VARCHAR2,
        p_new_setting IN VARCHAR2
    ) AS
        l_count NUMBER := 0;
        l_query VARCHAR2(4000);
    BEGIN

        verify_guild_setting(p_guild_id => p_guild_id);

        -- Validate that p_setting is a valid column name in the settings table
        SELECT COUNT(*)
        INTO l_count
        FROM all_tab_columns
        WHERE table_name = 'SETTING'
            AND column_name = upper(p_setting)
            AND owner = (select user from dual);  -- Ensure to check within the right schema

        -- Call verify_settings procedure

        -- If the column exists, proceed with the update
        IF l_count = 1 THEN
            l_query := 'UPDATE setting SET ' || p_setting || ' = :new_setting WHERE guild_id = :guild_id';

            EXECUTE IMMEDIATE l_query USING p_new_setting, p_guild_id;

        END IF;

    END;

    procedure remove_muted_role(
        p_guild_id in number, 
        p_muted_role_id number 
    ) as

    begin

        update setting
        set mute_role_id = null
        where guild_id = p_guild_id
            and mute_role_id = p_muted_role_id;

    end;

    procedure remove_punishment_logs (  
        p_guild_id in number, 
        p_text_chan_id number 
    ) as

    begin

        update setting
        set punishment_log_id = null
        where guild_id = p_guild_id
            and punishment_log_id = p_text_chan_id;

    end;

end;
