--  军团活跃
--  2015-02-11 小年
--  lmh
ALTER TABLE  `alliance` ADD  `alevel` INT( 10 ) UNSIGNED NOT NULL DEFAULT  '1' COMMENT  '军团活跃等级' AFTER  `point` ;
ALTER TABLE  `alliance` ADD  `apoint` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '军团活跃点数' AFTER  `alevel` ;
ALTER TABLE `alliance` ADD `ainfo` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `apoint` ;
ALTER TABLE  `alliance` ADD  `apoint_at` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '当天活跃刷新凌晨时间' AFTER  `point_at` ;
ALTER TABLE `alliance` ADD `setname_at` INT( 11 ) NOT NULL DEFAULT '0' AFTER `apoint_at` ;



ALTER TABLE  `alliance_members` ADD  `apoint` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `raising` ;  -- 当天自己的活跃
ALTER TABLE  `alliance_members` ADD  `apoint_at` INT( 11 ) NOT NULL DEFAULT  '0' AFTER  `apoint` ; -- 当前活跃的凌晨时间戳
ALTER TABLE  `alliance_members` ADD  `ar` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '存储领取奖励的资源数' AFTER  `apoint_at` ;
ALTER TABLE  `alliance_members` ADD  `ar_at` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '领奖的凌晨时间戳' AFTER  `ar` ;


ALTER TABLE `alliance` CHANGE `ainfo` `ainfo` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '[]' COMMENT '军团活跃存储资源信息';
ALTER TABLE `alliance_members` CHANGE `ar` `ar` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '[]' COMMENT '存储领取奖励的资源数';

-- 区域站
-- 2015-07-15
-- lmh

CREATE TABLE IF NOT EXISTS `alliance_areabattle` (
  `aid` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(200) NOT NULL,
  `point` int(10) NOT NULL DEFAULT '0',
  `own_at` int(10) NOT NULL,
  `own` int(4) NOT NULL DEFAULT '0',
  `kingname` varchar(50) NOT NULL,
  `status` int(2) NOT NULL DEFAULT '0',
  `jobs` varchar(1000) NOT NULL,
  `aslave` varchar(10000) NOT NULL,
  `content` varchar(2000) NOT NULL,
  `apply_at` int(10) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`),
  KEY `point` (`point`),
  KEY `aid` (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;ALTER TABLE `alliance_members` CHANGE `ar` `ar` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '[]' COMMENT '存储领取奖励的资源数';


ALTER TABLE `alliance` CHANGE `fight` `fight` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `level_point`;

-- 军团战改版
-- lmh
-- 2016-01-12

ALTER TABLE `alliance_battleuserlog` ADD `attdonate` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '攻击方贡献记录' AFTER `defRaising` ;
ALTER TABLE `alliance_battleuserlog` ADD `defdonate` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '攻击方贡献记录' AFTER `defRaising` ;
ALTER TABLE `alliance_battleuserlog` CHANGE `placeid` `placeid` VARCHAR( 5 ) NOT NULL DEFAULT '""';
ALTER TABLE `alliance_battlelog` CHANGE `blueAllianceName` `blueAllianceName` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '""' COMMENT '';


-- 军团叛军
-- lmh
--  2016-7-26
CREATE TABLE IF NOT EXISTS `alliance_forces` (
  `aid` int(10) NOT NULL AUTO_INCREMENT,
  `info` varchar(5000) NOT NULL,
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 区域渣改版
-- lmh
-- 2016-04-05

ALTER TABLE `alliance_areabattle` ADD `wcount` INT( 10 ) NOT NULL DEFAULT '0' AFTER `own` ;

-- 修改战力字段长度
-- hwm
-- 2015-7-31 10:51
ALTER TABLE `alliance_members`  CHANGE COLUMN `fight` `fight` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `name`;

-- 军团旗帜
-- wht
-- 2016-12-17
ALTER TABLE `alliance` ADD `logo` varchar( 100 ) NOT NULL DEFAULT '[]' AFTER `name` ;


-- 跨服区域站
-- lmh
-- 2015-11-18

CREATE TABLE IF NOT EXISTS `alliance_areateambattle` (
  `aid` int(10) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL,
  `fight` bigint(20) NOT NULL DEFAULT '0',
  `score` bigint(20) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL,
  `apply_at` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- lm
-- 2018/1/4 15:30
-- 军团新加uid字段
ALTER TABLE `alliance_areabattle` ADD COLUMN `uid` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `aid`;
ALTER TABLE `alliance_battleposition` ADD COLUMN `uid` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `aid`;
ALTER TABLE `alliance_battle` ADD COLUMN `uid` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `aid`;

-- hwm
-- 2018/04/09
-- 军团成员权限字段
ALTER TABLE `alliance_members` ADD COLUMN `auth` TINYINT NOT NULL DEFAULT '0' COMMENT '权限' AFTER `oc`;

-- hwm
-- 2018-08-23
-- 合服时部分玩家被删除，但members表未删，如果新增的玩家名字跟合服时被删除的玩家名重复是检测不出来的，但是加军团时，这儿给拦住了
ALTER TABLE `alliance_members`
  DROP INDEX `name`,
  ADD INDEX `name` (`name`);
