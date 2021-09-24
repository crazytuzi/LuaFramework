userinfo.20140120
ALTER TABLE `userinfo`
  DROP COLUMN `alliance`,
  CHANGE COLUMN `flags` `flags` VARCHAR(5000) NULL DEFAULT '' AFTER `logindate`,
  ADD COLUMN `alliance` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `protect`,  
  ADD COLUMN `alliancename` VARCHAR(50) NOT NULL DEFAULT '' AFTER `alliance`;

mail.2014214
   ALTER TABLE  `mail` ADD INDEX (  `uid` ) ;

tradelog.20140214
ALTER TABLE `tradelog`
  ADD COLUMN `extra_num` INT UNSIGNED NULL DEFAULT '0' AFTER `comment`;

alliance.20140218
ALTER TABLE `alliance_members` ADD `weekraising` INT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `raising` 
ALTER TABLE `alliance_members` ADD `join_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `signature` 
ALTER TABLE `alliance_members` ADD `raising_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `logined_at` 
ALTER TABLE `alliance_members` ADD `raisendtime` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `raising_at` 
ALTER TABLE `alliance` ADD `raising_rf` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `updated_at` 
DROP TABLE IF EXISTS `alliance_skill`;
CREATE TABLE `alliance_skill` (
  `aid` int(10) unsigned NOT NULL,
  `s1` int(10) unsigned NOT NULL DEFAULT '0',
  `s1_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s2` int(10) unsigned NOT NULL DEFAULT '0',
  `s2_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s3` int(10) unsigned NOT NULL DEFAULT '0',
  `s3_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s4` int(10) unsigned NOT NULL DEFAULT '0',
  `s4_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s5` int(10) unsigned NOT NULL DEFAULT '0',
  `s5_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s6` int(10) unsigned NOT NULL DEFAULT '0',
  `s6_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s7` int(10) unsigned NOT NULL DEFAULT '0',
  `s7_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s8` int(10) unsigned NOT NULL DEFAULT '0',
  `s8_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s9` int(10) unsigned NOT NULL DEFAULT '0',
  `s9_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s10` int(10) unsigned NOT NULL DEFAULT '0',
  `s10_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s11` int(10) unsigned NOT NULL DEFAULT '0',
  `s11_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s12` int(10) unsigned NOT NULL DEFAULT '0',
  `s12_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s13` int(10) unsigned NOT NULL DEFAULT '0',
  `s13_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s14` int(10) unsigned NOT NULL DEFAULT '0',
  `s14_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s15` int(10) unsigned NOT NULL DEFAULT '0',
  `s15_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s16` int(10) unsigned NOT NULL DEFAULT '0',
  `s16_point` int(10) unsigned NOT NULL DEFAULT '0',
  `s17` int(10) unsigned NOT NULL DEFAULT '0',
  `s17_point` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` int(11) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
