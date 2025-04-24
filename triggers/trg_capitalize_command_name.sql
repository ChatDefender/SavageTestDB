create or replace TRIGGER "SAVAGEBOT_PROD"."TRG_CAPITALIZE_COMMAND_NAME" 
BEFORE INSERT ON command
FOR EACH ROW
BEGIN
    :NEW.name := UPPER(:NEW.name);
    :NEW.category := UPPER(:NEW.category);
END;
