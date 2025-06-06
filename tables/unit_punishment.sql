CREATE TABLE UNIT_PUNISHMENT (
    GUILD_ID NUMBER,
    UNIT_ID NUMBER,
    PUNISHMENT_ID NUMBER,
    CONSTRAINT UNIT_PUNISHMENT_PK PRIMARY KEY (GUILD_ID, PUNISHMENT_ID),
    CONSTRAINT UNIT_PUNISHMENT_UNIT_FK FOREIGN KEY (GUILD_ID, UNIT_ID)
        REFERENCES UNIT(GUILD_ID, UNIT_ID) ON DELETE CASCADE,
    CONSTRAINT UNIT_PUNISHMENT_PUNISHMENT_FK FOREIGN KEY (GUILD_ID, PUNISHMENT_ID)
        REFERENCES PUNISHMENT(GUILD_ID, PUNISHMENT_ID) ON DELETE CASCADE
);
