CREATE OR REPLACE VIEW ENDED_PUNISHMENTS AS
SELECT
    punishment_log_id,
    guild_id,
    staff_id,
    user_id,
    punishment_type
FROM punishment_logs
WHERE is_archived = 0
    AND duration != 0 
    AND duration != -1
    AND is_served = 0
    AND sysdate >= create_stamp + (duration / 86400000);
