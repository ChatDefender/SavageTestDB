create or replace package command_management as

    procedure cmd_log_err(
    
        p_cmd_log_id in number,
        p_file_name in varchar2,
        p_err_msg in varchar2
    
    ); 

    function insert_cmd_log (

        p_guild_id in number,
        p_channel_id in number,
        p_user_id in number,
        p_command in varchar2,
        p_has_perms in number

    ) return number;

end;

create or replace package body command_management as 

    procedure cmd_log_err(
    
        p_cmd_log_id in number,
        p_file_name in varchar2,
        p_err_msg in varchar2
    
    ) as
    
        l_cmd_err_id number;

    begin

        insert into cmd_err (
            cmd_file_name,  
            err_msg
        ) VALUES (
            p_file_name,
            p_err_msg
        )
        returning cmd_err_id
        into l_cmd_err_id;

        update cmd_log
        set cmd_err_id = l_cmd_err_id
        where cmd_log_id = p_cmd_log_id;

    end;

    function insert_cmd_log (

        p_guild_id in number,
        p_channel_id in number,
        p_user_id in number,
        p_command in varchar2,
        p_has_perms in number

    ) return number as

        l_cmd_log_id number;
        l_cmd_id number;

    begin

        select cmd_id
        into l_cmd_id
        from command 
        where name = upper(p_command)
            and guild_id = p_guild_id;

        insert into cmd_log (
            guild_id,
            cmd_id,
            channel_id,
            user_id,
            has_perms
        ) VALUES (
            p_guild_id,
            l_cmd_id,
            p_channel_id,
            p_user_id,
            p_has_perms
        )
        returning cmd_log_id 
        into l_cmd_log_id;

        return l_cmd_log_id;

    end;

end;

