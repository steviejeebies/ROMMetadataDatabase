drop database game_project_14319662;
create database game_project_14319662;
use game_project_14319662;

create table Publisher (
	publisher_id int auto_increment primary key,
    publisher_name varchar(32) not null,
    country_origin varchar(32) not null,
    founded_date date not null
);

create table Developer (
	developer_id int auto_increment primary key,
    developer_name varchar(32),
    publisher_id int not null,
    num_games int not null default 0
);

-- Showing a Alter Statement
ALTER TABLE Developer ADD FOREIGN KEY (publisher_id) REFERENCES Publisher (publisher_id) ON UPDATE CASCADE ON DELETE RESTRICT;

-- With ROMs, there is a convention wrt. Regions. J, E, U, are Japan, Europe, North America respectively. 
-- For this project, I will stick with using only J, E, U, A, S (A is Australia and S is South America), 
-- as this is enough for demonstration
create table Region (
    region_code char not null primary key
);

-- Will stick to 5 languages for this demonstration - en, jp, fr, de, es
create table Languages (
	lang char(2) not null primary key
);

create table Console (
	console_id int auto_increment primary key,
    console_name varchar(30) not null,
    publisher_id int not null,
    foreign key (publisher_id) references Publisher (publisher_id) ON DELETE RESTRICT,
    num_games int not null default 0
);

create table Console_File_Type (
	console_id int,
    foreign key (console_id) references Console (console_id) ON DELETE RESTRICT,
    file_type varchar(10),	-- picked 10 because file extensions are rarely above 3 in length, but this provides space if necessary
	primary key (console_id, file_type)
);

-- if the same game is released on multiple consoles (i.e. ports, handheld versions), then we 
-- treat these as distinct games, as the cover art, release date and developer are almost guaranteed to vary
create table Game (
	game_id int auto_increment primary key,
    console_id int not null,
    foreign key (console_id) references Console (console_id) ON DELETE RESTRICT,
    developer_id int not null,
    foreign key (developer_id) references Developer (developer_id) ON DELETE RESTRICT,
    age_rating_min_age int not null default 3,	
    max_players int not null default 1
);

-- The following two tables were created to eliminate data redundancy in the following table, Game_Regional, as the UK and US versions of the game may have the same title (although
-- for retro games, this was much less common than today). Also, associating Game_Title with Game_BoxArt would create a massive amount of redundancy
-- as in general, Game_BoxArt would be vary for every region and language, but Game_Title would not vary to the same extent. We can reuse the same tuple
-- from this table for the EU English and US English Regional Versions, if they are the same
create table Game_Title (
	title_id int auto_increment primary key,
    game_title varchar(50) not null unique			-- Unique constraints on these three tables, as the purpose of these is to eliminate redundancy
);

create table Game_BoxArt ( 
	boxart_id int auto_increment primary key,
	boxart varchar(255) not null unique 	
);

-- Each game has a different version for each region and language. Each tuple on this table signifies the
-- region it is released in (EU, US, etc.) and the language of this version. So for Europe, we have a English, a French
-- and a Spanish tuple. We also have EU English and US English tuples, due to the difference in box-arts/titles. The tables
-- following this one break the table down into NF and eliminate redundancy.
create table Game_Regional (
	game_id int,
    foreign Key (game_id) references Game (game_id) ON DELETE CASCADE,
    region_code char,
    foreign Key (region_code) references Region (region_code) ON DELETE RESTRICT,
    lang char(2),
    foreign key (lang) references Languages (lang) ON DELETE RESTRICT,
    primary key(game_id, region_code, lang),
    title_id int,
    foreign Key (title_id) references Game_Title (title_id) ON UPDATE CASCADE ON DELETE RESTRICT,				-- see p16, lecture 6
    boxart_id int,
    foreign key (boxart_id) references Game_BoxArt (boxart_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    release_date date not null									-- game can be released in the same region for different languages at different times, so this is 3NF complaint
);

create table Rom (
    rom_id int not null auto_increment primary key,
    md5 char(32) not null unique,
    sha1 char(40) not null unique,
    region_code char not null,
    foreign key (region_code) references Region (region_code) ON DELETE RESTRICT,   -- ROMs are specified with a region, e.g. [U] for US, [E] for Europe, etc.
    lang char(2) not null,
    foreign key (lang) references Languages (lang) ON DELETE RESTRICT,
    file_type varchar(10) not null
);

-- matches rom to a game (adding game_id to Rom would require it to be a primary key, but this would break 2NF since md5 and sha1 is not dependendant on game_id)
CREATE TABLE Game_Rom (
	game_id int,
    foreign key (game_id) references Game (game_id) ON DELETE CASCADE,
    rom_id int,
    foreign Key (rom_id) references Rom (rom_id) ON DELETE CASCADE,
    primary key(game_id, rom_id)
);