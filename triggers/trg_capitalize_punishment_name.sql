create or replace TRIGGER "SAVAGEBOT_PROD"."TRG_CAPITALIZE_PUNISHMENT_NAME" 
BEFORE INSERT OR UPDATE ON punishment
FOR EACH ROW
BEGIN
    :new.name := upper(:new.name);
END;
