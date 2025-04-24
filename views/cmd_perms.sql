CREATE OR REPLACE VIEW CMD_PERMS AS
SELECT 
    unit.guild_id,
    unit.unit_name,
    unit_role.discord_role_id,
    command.category AS cmd_category,
    command.name AS cmd_name
FROM unit
    JOIN unit_role ON unit.guild_id = unit_role.guild_id
        AND unit.unit_id = unit_role.unit_id
    JOIN unit_cmd ON unit.guild_id = unit_cmd.guild_id
        AND unit.unit_id = unit_cmd.unit_id
    JOIN command ON unit.guild_id = command.guild_id
        AND unit_cmd.cmd_id = command.cmd_id;
