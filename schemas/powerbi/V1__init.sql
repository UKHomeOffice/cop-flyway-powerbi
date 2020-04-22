Use MASTER;

BEGIN
  EXEC sp_configure 'show advanced options',1
  RECONFIGURE WITH OVERRIDE;
  EXEC sp_configure 'contained database authentication', 1
  RECONFIGURE WITH OVERRIDE;
END;


IF NOT EXISTS
  (SELECT name FROM master.dbo.sysdatabases 
      WHERE name = N'${dbname}')
    BEGIN
      print 'db does not exist'
      CREATE DATABASE ${dbname}
        CONTAINMENT = PARTIAL
    END
