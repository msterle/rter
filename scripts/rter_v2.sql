-- MySQL rter v2
-- ===========
-- Run these commands to setup the MySQL databases for the rter v2 project

SET foreign_key_checks = 0;

DROP TABLE IF EXISTS Roles;
CREATE TABLE IF NOT EXISTS Roles (
	Title VARCHAR(64) NOT NULL,
	Permissions INT NOT NULL DEFAULT 0,

	PRIMARY KEY(Title)
);

DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users (
	ID INT NOT NULL AUTO_INCREMENT,
	Username VARCHAR(64) NOT NULL,
	Password CHAR(128) NOT NULL,
	Salt CHAR(16) NOT NULL,

	Role VARCHAR(64) NOT NULL DEFAULT "public",
	TrustLevel INT NOT NULL DEFAULT 0,

	CreateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY(ID),
	UNIQUE KEY(Username),
	FOREIGN KEY(Role) REFERENCES Roles (Title) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS UserDirections;
CREATE TABLE IF NOT EXISTS UserDirections (
	UserID INT NOT NULL,
	LockUserID INT NOT NULL DEFAULT -1,
	Command VARCHAR(64) NOT NULL DEFAULT "none",

	Heading DECIMAL(9, 6) NOT NULL DEFAULT 0,
	Lat DECIMAL(9, 6) NOT NULL DEFAULT 0,
	Lng DECIMAL(9, 6) NOT NULL DEFAULT 0,

	UpdateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	PRIMARY KEY(UserID),
	FOREIGN KEY(UserID) REFERENCES Users (ID) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS Items;
CREATE TABLE IF NOT EXISTS Items (
	ID INT NOT NULL AUTO_INCREMENT,
	Type VARCHAR(64) NOT NULL,
	AuthorID INT NOT NULL,

	ThumbnailURI VARCHAR(2048) NOT NULL DEFAULT "",
	ContentURI VARCHAR(2048) NOT NULL DEFAULT "",
	UploadURI VARCHAR(2048) NOT NULL DEFAULT "",

	HasGeo TINYINT(1) NOT NULL DEFAULT 0,
	Heading DECIMAL(9, 6) NOT NULL DEFAULT 0,
	Lat DECIMAL(9, 6) NOT NULL DEFAULT 0,
	Lng DECIMAL(9, 6) NOT NULL DEFAULT 0,

	StartTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	StopTime DATETIME NOT NULL,

	PRIMARY KEY(ID),
	FOREIGN KEY(AuthorID) REFERENCES Users (ID) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS ItemComments;
CREATE TABLE IF NOT EXISTS ItemComments (
	ID INT NOT NULL AUTO_INCREMENT,
	ItemID INT NOT NULL,
	AuthorID INT NOT NULL,

	Body TEXT NOT NULL,

	CreateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY(ID),
	FOREIGN KEY(ItemID) REFERENCES Items (ID) ON UPDATE CASCADE,
	FOREIGN KEY(AuthorID) REFERENCES Users (ID) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS TaxonomyTerms;
CREATE TABLE IF NOT EXISTS TaxonomyTerms (
	ID INT NOT NULL,
	Term VARCHAR(256) NOT NULL,

	Automated TINYINT(1) NOT NULL DEFAULT 0,
	AuthorID INT NOT NULL,

	CreateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

	PRIMARY KEY(ID),
	FOREIGN KEY(AuthorID) REFERENCES Users (ID) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS TaxonomyTermRankings;
CREATE TABLE IF NOT EXISTS TaxonomyTermRankings (
	TermID INT NOT NULL,
	Ranking TEXT NOT NULL,
	
	UpdateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

	PRIMARY KEY(TermID),
	FOREIGN KEY(TermID) REFERENCES TaxonomyTerms (ID) ON UPDATE CASCADE
);

-- DROP TABLE IF EXISTS TaxonomyRankingsArchive;
-- CREATE TABLE IF NOT EXISTS TaxonomyRankingsArchive (
-- 	ID INT NOT NULL,
-- 	TaxonomyRankingID INT NOT NULL,
-- 	Ranking TEXT NOT NULL,

-- 	TaxonomyID INT NOT NULL,
	
-- 	UpdateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

-- 	PRIMARY KEY(ID),
-- 	FOREIGN KEY(TaxonomyRankingID) REFERENCES TaxonomyRankings (ID) ON UPDATE CASCADE,
-- 	FOREIGN KEY(TaxonomyID) REFERENCES Taxonomy (ID) ON UPDATE CASCADE
-- );

SET foreign_key_checks = 1;