-- Setup DB
CREATE ROLE ${databricksuser} WITH NOINHERIT LOGIN ENCRYPTED PASSWORD '${databrickspassword}';
GRANT USAGE ON SCHEMA ${schema} TO ${databricksuser};
GRANT ${databricksuser} to ${databricksuser};
CREATE ROLE ${powerbiuser} WITH NOINHERIT LOGIN ENCRYPTED PASSWORD '${powerbipassword}';
GRANT USAGE ON SCHEMA ${schema} TO ${powerbiuser};
GRANT ${powerbiuser} to ${powerbiuser};
