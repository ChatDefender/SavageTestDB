create or replace TRIGGER "SAVAGEBOT_PROD"."TRG_UPPERCASE_PUNISHMENT_TYPE" 
BEFORE INSERT OR UPDATE ON punishment_tier
FOR EACH ROW
BEGIN
    :NEW.punishment_type := UPPER(:NEW.punishment_type);
END;
