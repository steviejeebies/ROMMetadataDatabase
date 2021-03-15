CREATE ROLE IF NOT EXISTS 'contributor_user', 'read_only_user', 'moderator';
  
-- Any user can SELECT any information from the database
GRANT SELECT ON game_project_14319662.* TO 'contributor_user', 'read_only_user', 'moderator';

-- Only moderators and contributor_users can add ROMs to database
GRANT EXECUTE ON PROCEDURE insert_new_rom TO 'moderator', 'contributor_user';

-- Moderators can delete, insert and update any values on any tables on the database, 
-- but cannot delete tables
GRANT INSERT ON game_project_14319662.* TO 'moderator';
GRANT UPDATE ON game_project_14319662.* TO 'moderator';
GRANT DELETE ON game_project_14319662.* TO 'moderator';

CREATE USER 'Tom'@'localhost';
CREATE USER 'Dick'@'localhost';
CREATE USER 'Harry'@'localhost';

CREATE USER 'MOD1'@'localhost';
CREATE USER 'MOD2'@'localhost';
CREATE USER 'MOD3'@'localhost';

GRANT 'contributor_user' TO 'Tom'@'localhost', 'Dick'@'localhost';
GRANT 'read_only_user' TO 'Harry'@'localhost';
GRANT 'moderator' TO 'MOD1'@'localhost', 'MOD2'@'localhost', 'MOD3'@'localhost';

REVOKE 'moderator' FROM 'MOD3'@'localhost';

SET DEFAULT ROLE 'contributor_user' TO
  'Tom'@'localhost',
  'Dick'@'localhost';
  
SET DEFAULT ROLE 'read_only_user' TO
  'Harry'@'localhost';
  
SET DEFAULT ROLE 'moderator' TO
  'MOD1'@'localhost',
  'MOD2'@'localhost';

