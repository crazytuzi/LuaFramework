--  2015 3-13
--  lmh
--   和服

ALTER TABLE `services` ADD `oldzoneid` INT( 10 ) NOT NULL DEFAULT '0' AFTER `add_at` ;

ALTER TABLE `giftbag`
	ALTER `type` DROP DEFAULT;
ALTER TABLE `giftbag`
	ADD COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST,
	CHANGE COLUMN `bag` `bag` SMALLINT UNSIGNED NOT NULL AFTER `type`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`id`),
	ADD UNIQUE INDEX `cdkey` (`cdkey`);
	
ALTER TABLE `giftbag` CHANGE `bag` `bag` INT( 10 ) UNSIGNED NOT NULL ;
