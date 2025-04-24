CREATE OR REPLACE VIEW ACTIVE_PUNISHMENTS AS
SELECT
    guild_id, 
    punishment_log_id,
    user_id,
    punishment_type
FROM punishment_logs
WHERE is_archived = 0
    AND sysdate <= create_stamp + (duration / 86400000);
