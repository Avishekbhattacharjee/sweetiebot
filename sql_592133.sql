DELIMITER //

ALTER TABLE `editlog`
	CHANGE COLUMN `Timestamp` `Timestamp` DATETIME NOT NULL AFTER `ID`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`ID`, `Timestamp`)//

DROP TRIGGER IF EXISTS `chatlog_before_update`//
CREATE TRIGGER `chatlog_before_update` BEFORE UPDATE ON `chatlog` FOR EACH ROW INSERT INTO editlog (ID, Timestamp, Author, Message, Channel, Everyone, Guild)
VALUES (OLD.ID, OLD.Timestamp, OLD.Author, OLD.Message, OLD.Channel, OLD.Everyone, OLD.Guild)//

DROP TRIGGER IF EXISTS `chatlog_before_delete`//

DROP EVENT IF EXISTS `CleanChatlog`//
CREATE EVENT `CleanChatlog` ON SCHEDULE EVERY 1 DAY STARTS '2016-01-29 17:04:34' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM chatlog WHERE Timestamp < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 7 DAY);
DELETE FROM editlog WHERE Timestamp < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 7 DAY);
END//

DROP EVENT IF EXISTS `CleanAliases`//
CREATE EVENT `CleanAliases`
	ON SCHEDULE
		EVERY 1 DAY STARTS '2018-01-23 16:29:25'
	ON COMPLETION PRESERVE
	ENABLE
	COMMENT ''
	DO BEGIN

Block1: BEGIN
DECLARE done INT DEFAULT 0;
DECLARE uid BIGINT UNSIGNED;
DECLARE aid VARCHAR(128);
DECLARE c_1 CURSOR FOR SELECT User FROM aliases GROUP BY User HAVING COUNT(Alias) > 10;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN c_1;
REPEAT
FETCH c_1 INTO uid;

Block2: BEGIN
DECLARE done2 INT DEFAULT 0;
DECLARE c_2 CURSOR FOR SELECT Alias FROM aliases WHERE User = uid ORDER BY Duration DESC LIMIT 9999 OFFSET 10;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = 1;
OPEN c_2;
REPEAT
FETCH c_2 INTO aid;

DELETE FROM aliases WHERE User=uid AND Alias=aid;

UNTIL done2 END REPEAT;
CLOSE c_2;
END Block2;

UNTIL done END REPEAT;
CLOSE c_1;
END Block1;


END//