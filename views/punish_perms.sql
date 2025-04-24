CREATE OR REPLACE VIEW PUNISH_PERMS AS
SELECT 
    unit.guild_id,
    unit.unit_name,
    unit_role.discord_role_id,
    punishment.name AS punishment_name
FROM unit
JOIN unit_role ON unit.guild_id = unit_role.guild_id
    AND unit.unit_id = unit_role.unit_id
JOIN unit_punishment ON unit.guild_id = unit_punishment.guild_id
    AND unit.unit_id = unit_punishment.unit_id
JOIN punishment ON unit.guild_id = punishment.guild_id
    AND unit_punishment.punishment_id = punishment.punishment_id;
