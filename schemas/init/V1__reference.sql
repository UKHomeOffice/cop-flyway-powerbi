CREATE ROLE ${powerbiownername} WITH CREATEROLE LOGIN ENCRYPTED PASSWORD '${powerbiownerpassword}';
GRANT ${powerbiownername} TO ${masteruser};
CREATE DATABASE ${powerbidbname} OWNER ${powerbiownername};
