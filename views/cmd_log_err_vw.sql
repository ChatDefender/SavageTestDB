CREATE OR REPLACE VIEW CMD_LOG_ERR_VW AS
SELECT
    guild_id, 
    cmd_id,
    channel_id,
    user_id,
    cmd_file_name, 
    err_msg, 
    cl.create_stamp AS cmd_log_time, 
    ce.create_stamp AS err_log_time
FROM cmd_log cl
INNER JOIN cmd_err ce ON cl.cmd_err_id = ce.cmd_err_id;
