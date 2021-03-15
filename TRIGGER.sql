-- This trigger is necessary, as there is no way to DELETE CASCADE on ROM as it has no foreign keys
 DELIMITER //
CREATE TRIGGER delete_rom_entirely 
	AFTER DELETE ON Game_ROM
    FOR EACH ROW
    BEGIN
		DELETE FROM ROM WHERE ROM.rom_id = OLD.rom_id;
	END //
DELIMITER ;

-- drop procedure insert_new_rom;
DELIMITER //
CREATE PROCEDURE insert_new_rom (IN game_id int, IN md5 char(32), IN sha1 char(40), IN region_code char, IN lang char(2), file_type varchar(10))
COMMENT 'Allows users to submit ROMs, inserting them in the ROM and GAME_ROM tables'
LANGUAGE SQL
MODIFIES SQL DATA
SQL SECURITY DEFINER
BEGIN
	-- If file_type of ROM is not valid for this console, abort without modifying anything
	IF NOT EXISTS (SELECT * FROM Console_File_Type AS CFT INNER JOIN Game WHERE CFT.console_id = Game.console_id AND CFT.file_type = file_type)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INVALID FILETYPE'; 
    END IF;
	IF EXISTS (SELECT * FROM Game WHERE Game.game_id = game_id)
    THEN
		INSERT INTO ROM VALUES (null, md5, sha1, region_code, lang, file_type);
		SET @new_ROM_id = (SELECT rom_id FROM ROM WHERE ROM.md5 = md5 AND ROM.sha1 = sha1);
		INSERT INTO Game_ROM VALUES (game_id, @new_ROM_id);
	ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'GAME_ID NOT PRESENT IN DATABASE';
	END IF;
END //
 DELIMITER ;
 
 DELIMITER //
CREATE TRIGGER increment_num_games
    AFTER INSERT ON Game
    FOR EACH ROW 
    BEGIN
	 UPDATE Console SET num_games = num_games+1 WHERE (NEW.Console_id = Console.console_id);
	 UPDATE Developer SET num_games = num_games+1 WHERE (NEW.developer_id = Developer.developer_id);
	END //
 DELIMITER ;
 
 DELIMITER //
CREATE TRIGGER decrement_num_games
    BEFORE DELETE ON Game
    FOR EACH ROW 
    BEGIN
	 UPDATE Console SET num_games = num_games-1 WHERE (OLD.Console_id = Console.console_id);
	 UPDATE Developer SET num_games = num_games-1 WHERE (OLD.developer_id = Developer.developer_id);
	END //
 DELIMITER ;
 