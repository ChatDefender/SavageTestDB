create or replace package GROUP_MANAGEMENT as 

    procedure create_unit (
        p_guild_id in number,
        p_unit_name in varchar2
    );

    procedure remove_unit (
        p_guild_id in number,
        p_unit_name in varchar2
    );

    procedure create_role (
        p_guild_id in number,
        p_unit_name in varchar2, 
        p_discord_role_id in number
    );

    procedure remove_role (
        p_guild_id in number,
        p_unit_name in varchar2,
        p_discord_role_id in number
    );

    procedure create_command (
        p_guild_id in number,
        p_unit_name in varchar2,
        p_name in varchar2
    );

    procedure remove_command (
        p_guild_id in number, 
        p_unit_name in varchar2,
        p_name in varchar2
    );

    procedure create_punishment (
        p_guild_id in number, 
        p_unit_name in varchar2,
        p_name in varchar2
    );

    procedure remove_punishment (
        p_guild_id in number, 
        p_unit_name in varchar2,
        p_name in varchar2
    );

end;

create or replace package body GROUP_MANAGEMENT as 

    procedure create_unit (
        p_guild_id in number,
        p_unit_name in varchar2
    ) is 
        
        l_unit_id number;

    begin

        select nvl(max(unit_id), 0) + 1
        into l_unit_id
        from unit
        where guild_id = p_guild_id;

        insert into unit
        values (p_guild_id, l_unit_id, p_unit_name);

    end;

    procedure remove_unit (
        p_guild_id in number,
        p_unit_name in varchar2
    ) is

    begin 

        delete from unit
        where guild_id = p_guild_id 
            and unit_name = upper(p_unit_name);

    end;

    procedure create_role (
        p_guild_id in number,
        p_unit_name in varchar2, 
        p_discord_role_id in number
    ) is

        l_unit_id number;

    begin

        select unit_id 
        into l_unit_id
        from unit
        where guild_id = p_guild_id
            and unit_name = upper(p_unit_name);

        insert into unit_role (guild_id, unit_id, discord_role_id)
        values (p_guild_id, l_unit_id, p_discord_role_id);

    end;

    procedure remove_role (
        p_guild_id in number,
        p_unit_name in varchar2,
        p_discord_role_id in number
    )  is 

        l_unit_id number;

    begin 

        select unit_id 
        into l_unit_id
        from unit
        where guild_id = p_guild_id
            and unit_name = upper(p_unit_name);

        delete from unit_role
        where discord_role_id = p_discord_role_id
            and guild_id = p_guild_id
            and unit_id = l_unit_id;

    end;

    procedure create_command (
        p_guild_id in number,
        p_unit_name in varchar2,
        p_name in varchar2
    ) is 

        l_unit_id number;
        l_cmd_id number;

    begin

        select unit_id 
        into l_unit_id
        from unit
        where unit_name = upper(p_unit_name)
            and guild_id = p_guild_id;

        select cmd_id
        into l_cmd_id
        from command 
        where guild_id = p_guild_id
            and name = upper(p_name);

        insert into unit_cmd
        values (p_guild_id, l_unit_id, l_cmd_id);    

    end;

    procedure remove_command (
        p_guild_id in number, 
        p_unit_name in varchar2,
        p_name in varchar2
    ) is 

        l_unit_id number;
        l_cmd_id number;

    begin

        select unit_id 
        into l_unit_id
        from unit
        where unit_name = upper(p_unit_name)
            and guild_id = p_guild_id;

        select cmd_id
        into l_cmd_id
        from command 
        where guild_id = p_guild_id
            and name = upper(p_name);

        delete from unit_cmd
        where guild_id = p_guild_id
            and unit_id = l_unit_id
            and cmd_id = l_cmd_id;    

    end;

    procedure create_punishment (
        p_guild_id in number,
        p_unit_name in varchar2,
        p_name in varchar2
    ) is 

        l_unit_id number;
        l_punishment_id number;

    begin

        select unit_id 
        into l_unit_id
        from unit
        where unit_name = upper(p_unit_name)
            and guild_id = p_guild_id;

        select punishment_id
        into l_punishment_id
        from punishment 
        where guild_id = p_guild_id
            and name = upper(p_name);

        insert into unit_punishment
        values (p_guild_id, l_unit_id, l_punishment_id);    

    end;

    procedure remove_punishment (
        p_guild_id in number, 
        p_unit_name in varchar2,
        p_name in varchar2
    )  is 

        l_unit_id number;
        l_punishment_id number;

    begin

        select unit_id 
        into l_unit_id
        from unit
        where unit_name = upper(p_unit_name)
            and guild_id = p_guild_id;

        select punishment_id
        into l_punishment_id
        from punishment 
        where guild_id = p_guild_id
            and name = upper(p_name);

        delete from unit_punishment
        where guild_id = p_guild_id
            and unit_id = l_unit_id
            and punishment_id = l_punishment_id;    

    end;


end;
