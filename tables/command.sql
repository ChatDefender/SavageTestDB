CREATE TABLE COMMAND (
    GUILD_ID NUMBER, 
    CMD_ID NUMBER, 
    NAME VARCHAR2(255 BYTE), 
    CATEGORY VARCHAR2(50 BYTE), 
    CONSTRAINT COMMAND_PK PRIMARY KEY (GUILD_ID, CMD_ID),
    CONSTRAINT CMD_SETTING_FK FOREIGN KEY (GUILD_ID) REFERENCES SETTING(GUILD_ID)
);
