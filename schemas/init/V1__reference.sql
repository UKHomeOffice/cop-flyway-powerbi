CREATE USER ${powerbiusername} WITH PASSWORD '${powerbipassword}';
ALTER ROLE db_datareader ADD MEMBER ${powerbiusername};
CREATE USER ${databricksusername} WITH PASSWORD '${databrickspassword}'
ALTER ROLE db_datareader ADD MEMBER ${databricksusername};
ALTER ROLE db_datawriter ADD MEMBER ${databricksusername};
ALTER ROLE db_ddladmin ADD MEMBER ${databricksusername};
