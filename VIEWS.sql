-- This View makes the Game_ROM table more useful, showing the full contents of the rows associated with its two foreign keys
CREATE OR REPLACE VIEW Game_Rom_View AS
SELECT Game.*, Rom.* FROM Game_Rom
INNER JOIN Rom ON Game_Rom.rom_id = Rom.rom_id
INNER JOIN Game ON Game_Rom.game_id = Game.game_id
WITH CHECK OPTION;

select * from Game_Rom_View;

CREATE OR REPLACE VIEW Insert_Rom_View AS
SELECT GR.game_id, R.rom_id FROM Game_Rom AS GR
INNER JOIN Rom AS R ON GR.rom_id = R.rom_id;

select * from Insert_Rom_View;

-- Finds all Games, and all the Regional Versions of those games, accompanied with the metadata (title, boxart) associated with that Regional Version
CREATE OR REPLACE VIEW Game_All_Regions_View AS
SELECT G.game_id, GR.region_code, GR.lang, GR.release_date, T.game_title, B.boxart, C.console_name, D.developer_name, P.publisher_name, G.age_rating_min_age AS age_rating, G.max_players
FROM Game_Regional AS GR
INNER JOIN Game AS G ON GR.game_id = G.game_id
INNER JOIN Game_Title AS T ON GR.title_id = T.title_id
INNER JOIN Game_Boxart AS B ON GR.boxart_id = B.boxart_id
INNER JOIN Console AS C ON G.console_id = C.console_id
INNER JOIN Developer AS D ON G.developer_id = D.developer_id
INNER JOIN Publisher As P On D.publisher_id = P.publisher_id;

SELECT * FROM Game_All_Regions_View;

-- This Table isn't really part of my database, its just a test table to demonstrate that 
-- the MD5 searching is working as intended. This is five ROM files picked at random, 
-- showing we can uniquely identify and provide ample information about the ROM/Game
-- using just the MD5 value.
create table My_ROMs ( md5 varchar(32) not null );
INSERT INTO My_ROMs VALUES ('3279ACEED4663F9584689C0036776B8B');
INSERT INTO My_ROMs VALUES ('18FB2CF8B58C144CD12BC035755CBC12');
INSERT INTO My_ROMs VALUES ('F462C6B1098A890A225106AA5F2A1B20');
INSERT INTO My_ROMs VALUES ('0D4F4DE68E2C9DD76076F12098BC1874');
INSERT INTO My_ROMs VALUES ('0DB0E82831555607EE9830612106DBAB');

-- Search for roms by their MD5 and/or SHA1, delivering all relevant metadata for this ROM
CREATE OR REPLACE VIEW MD5_SHA1_Search_View AS
SELECT GRV.md5, GRV.sha1, GRV.file_type, GAR.* FROM Game_All_Regions_View AS GAR
INNER JOIN Game_Rom_View AS GRV ON
	GRV.game_id = GAR.game_id AND GRV.region_code = GAR.region_code AND GRV.lang = GAR.lang;

-- Demonstrating using MD5_SHA1_Search_View with the My_ROMs table
SELECT Results.* FROM MD5_SHA1_Search_View AS Results
INNER JOIN My_ROMs ON Results.md5 = My_ROMs.md5;

CREATE OR REPLACE VIEW Publisher_Developer_View AS
SELECT d.developer_id, d.developer_name, p.publisher_id, p.publisher_name, p.country_origin, p.founded_date
FROM Developer AS D
INNER JOIN Publisher AS P ON D.publisher_id = P.publisher_id;

SELECT * FROM Publisher_Developer_View;