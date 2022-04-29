EXECUTE DBMS_STATS.GATHER_SCHEMA_STATS(ownname => 'SCHEMA NAME',cascade => true,  degree => 6   ); 

EXECUTE DBMS_STATS.GATHER_DATABASE_STATS(ownname => 'SCHEMA NAME',cascade => true,  degree => 6   ); 

EXECUTE DBMS_STATS.GATHER_TABLE_STATS(ownname => 'SCHEMA NAME',cascade => true,  degree => 6   ); 