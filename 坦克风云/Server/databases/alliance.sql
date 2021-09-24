-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: 192.168.8.204    Database: game_alliance
-- ------------------------------------------------------
-- Server version       5.5.20-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alliance`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alliance` (
  `aid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `oid` int(11) unsigned NOT NULL DEFAULT '0',
  `oname` varchar(100) NOT NULL,
  `commander` varchar(100) NOT NULL,
  `commander_id` int(11) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `desc` varchar(200) NOT NULL DEFAULT '',
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `level_point` int(11) unsigned NOT NULL DEFAULT '0',
  `fight` bigint(20) unsigned NOT NULL DEFAULT '0',
  `notice` varchar(200) NOT NULL DEFAULT '',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `maxnum` int(10) unsigned NOT NULL,
  `requests` varchar(500) NOT NULL DEFAULT '',
  `type` int(1) unsigned NOT NULL DEFAULT '0',
  `level_limit` int(10) unsigned NOT NULL DEFAULT '0',
  `fight_limit` int(10) unsigned NOT NULL DEFAULT '0',
  `groupmsg_limit` int(10) unsigned NOT NULL,
  `groupmsg_ts` int(11) unsigned NOT NULL,
  `created_at` int(11) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  `raising_rf` int(11) unsigned NOT NULL DEFAULT '0',
  `fight_updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  `levelup_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `commander_id` (`commander_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alliance_barrier`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alliance_barrier` (
  `aid` int(11) unsigned NOT NULL,
  `maxbid` int(11) unsigned NOT NULL DEFAULT '1',
  `b1` varchar(100) DEFAULT NULL,
  `b2` varchar(100) DEFAULT NULL,
  `b3` varchar(100) DEFAULT NULL,
  `b4` varchar(100) DEFAULT NULL,
  `b5` varchar(100) DEFAULT NULL,
  `b6` varchar(100) DEFAULT NULL,
  `b7` varchar(100) DEFAULT NULL,
  `b8` varchar(100) DEFAULT NULL,
  `b9` varchar(100) DEFAULT NULL,
  `b10` varchar(100) DEFAULT NULL,
  `b11` varchar(100) DEFAULT NULL,
  `b12` varchar(100) DEFAULT NULL,
  `b13` varchar(100) DEFAULT NULL,
  `b14` varchar(100) DEFAULT NULL,
  `b15` varchar(100) DEFAULT NULL,
  `b16` varchar(100) DEFAULT NULL,
  `b17` varchar(100) DEFAULT NULL,
  `b18` varchar(100) DEFAULT NULL,
  `b19` varchar(100) DEFAULT NULL,
  `b20` varchar(100) DEFAULT NULL,
  `b21` varchar(100) DEFAULT NULL,
  `b22` varchar(100) DEFAULT NULL,
  `b23` varchar(100) DEFAULT NULL,
  `b24` varchar(100) DEFAULT NULL,
  `b25` varchar(100) DEFAULT NULL,
  `kill_at` int(11) unsigned NOT NULL DEFAULT '0',
  `ac_at` int(11) unsigned NOT NULL DEFAULT '0',
  `ac_id` int(11) unsigned NOT NULL DEFAULT '1',
  `refresh_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alliance_events`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alliance_events` (
  `aid` int(10) unsigned NOT NULL DEFAULT '0',
  `events` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alliance_members`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alliance_members` (
  `uid` int(11) unsigned NOT NULL,
  `aid` int(11) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `fight` int(10) unsigned NOT NULL DEFAULT '0',
  `role` int(10) unsigned NOT NULL DEFAULT '0',
  `stats` int(10) unsigned NOT NULL DEFAULT '0',
  `raising` int(11) unsigned NOT NULL DEFAULT '0',
  `use_rais` int(11) unsigned NOT NULL DEFAULT '0',
  `weekraising` int(10) unsigned NOT NULL DEFAULT '0',
  `requests` varchar(500) NOT NULL DEFAULT '',
  `signature` varchar(200) NOT NULL,
  `join_at` int(11) unsigned NOT NULL,
  `logined_at` int(11) unsigned NOT NULL DEFAULT '0',
  `raising_at` int(11) unsigned NOT NULL DEFAULT '0',
  `reward_at` int(11) unsigned NOT NULL DEFAULT '0',
  `attack_at` int(11) unsigned NOT NULL DEFAULT '0',
  `barrier` varchar(500) DEFAULT NULL,
  `raisendtime` int(11) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alliance_skill`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-04-03 11:35:03

-- --------------------------------
-- 20140515
-- 军团大战 进入战场的时间
-- lmh
ALTER TABLE `alliance_members` ADD `joinline_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `raisendtime` ;

-- 20140513
-- 军团奖金
-- lmh
ALTER TABLE `alliance` ADD `point_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' COMMENT '计算资金结算时间' AFTER `levelup_at` ;
ALTER TABLE `alliance` ADD `point` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' COMMENT '军团资金' AFTER `level_point` ;


  -- --------------------------------
  -- 20140607
  -- 军团战报名表
  -- lmh
CREATE TABLE `alliance_battle` (
  `aid` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `name` VARCHAR(100) NOT NULL,
  `areaid` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '报名的区域id',
  `point` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '报名的点数',
  `ownid` INT(11) NOT NULL DEFAULT '0',
  `warid` INT(11) UNSIGNED NOT NULL COMMENT '上一次战斗地区的id',
  `own_at` INT(11) NOT NULL DEFAULT '0',
  `status` INT(4) NOT NULL DEFAULT '0' COMMENT '返还未参见战斗的资金',
  `apply_at` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `updated_at` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

  -- --------------------------------
  -- 20140607
  -- 军团战结算战报表
  -- hwm
CREATE TABLE `alliance_battlelog` (
  `areaid` INT(11) NOT NULL,
  `warId` VARCHAR(50) NOT NULL COMMENT '战斗id',
  `redAllianceId` INT(10) UNSIGNED NOT NULL COMMENT '红方军团Id',
  `blueAllianceId` INT(10) UNSIGNED NOT NULL COMMENT '蓝方军团Id',
  `redAllianceName` VARCHAR(100) NOT NULL COMMENT '红方军团名',
  `blueAllianceName` VARCHAR(100) NOT NULL COMMENT '蓝方军团名',
  `redAlliancePoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '红方军团分数',
  `blueAlliancePoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '蓝方军团分数',
  `redAllianceRaising` INT(11) UNSIGNED NULL DEFAULT '0',
  `blueAllianceRaising` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `redAllianceKillNum` VARCHAR(1000) NOT NULL COMMENT '红方军团击杀数',
  `blueAllianceKillNum` VARCHAR(1000) NOT NULL COMMENT '蓝方军团击杀数',
  `redMvp` VARCHAR(100) NOT NULL,
  `blueMvp` VARCHAR(100) NOT NULL,
  `updated_at` INT(10) UNSIGNED NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`areaid`, `warId`),
  INDEX `battleId` (`warId`)
)
COMMENT='军团大战结果表'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


-- --------------------------------
  -- 20140607
  -- 军团战战场信息表
  -- hwm
CREATE TABLE `alliance_battleposition` (
  `areaid` INT(11) NOT NULL COMMENT '阵地标识',
  `aid` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT '占领者',
  `name` VARCHAR(100) NOT NULL,
  `updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`areaid`)
)
COMMENT='军团大战阵地'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


-- --------------------------------
  -- 20140607
  -- 军团战军团成员上阵下阵信息表
  -- hwm
CREATE TABLE `alliance_battlequeue` (
  `aid` INT(11) NOT NULL AUTO_INCREMENT COMMENT '地块id(东西战场1-8)',
  `q1` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q2` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q3` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q4` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q5` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q6` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q7` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q8` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q9` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q10` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q11` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q12` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q13` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q14` INT(11) UNSIGNED NULL DEFAULT NULL,
  `q15` INT(11) UNSIGNED NULL DEFAULT NULL,
  `updated_at` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
)
COMMENT='军团大战上阵队列'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0;

-- --------------------------------
  -- 20140607
  -- 军团战用户战报表
  -- hwm
CREATE TABLE `alliance_battleuserlog` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `warId` VARCHAR(50) NOT NULL COMMENT '战斗id',
  `attacker` INT(10) UNSIGNED NOT NULL COMMENT '攻击方',
  `defender` INT(10) UNSIGNED NOT NULL COMMENT '防守方',
  `attackerName` VARCHAR(100) NOT NULL,
  `defenderName` VARCHAR(100) NOT NULL,
  `attackerAllianceId` INT(10) UNSIGNED NOT NULL COMMENT '攻击方军团Id',
  `defenderAllianceId` INT(10) UNSIGNED NOT NULL COMMENT '防守方军团Id',
  `attAllianceName` VARCHAR(100) NOT NULL COMMENT '攻击方军团名',
  `defAllianceName` VARCHAR(100) NOT NULL COMMENT '防守方军团名',
  `attBuff` VARCHAR(200) NOT NULL COMMENT '攻击方Buff',
  `defBuff` VARCHAR(200) NOT NULL COMMENT '防守方Buff',
  `attPoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '获得的积分',
  `defPoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '获得的积分',
  `victor` INT(10) UNSIGNED NOT NULL COMMENT '胜利方用户Id',
  `report` VARCHAR(20000) NOT NULL COMMENT '战报',
  `attRaising` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '攻击者贡献',
  `defRaising` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '防守者贡献',
  `position` INT(4) NOT NULL,
  `placeid` INT(11) NOT NULL DEFAULT '0',
  `updated_at` INT(10) UNSIGNED NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `battleId` (`warId`),
  INDEX `attacker` (`attacker`),
  INDEX `defender` (`defender`)
)
COMMENT='军团大战回合战斗报告'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0;

-- --------------------------------
  -- 20140607
  -- 军团战用户积分表
  -- hwm
CREATE TABLE `alliance_battleuserraising` (
  `uid` INT(10) UNSIGNED NOT NULL COMMENT '用户id',
  `warId` VARCHAR(50) NOT NULL COMMENT '战斗Id',
  `raising` VARCHAR(1000) NOT NULL COMMENT '分数详情',
  `point` INT(11) UNSIGNED NOT NULL DEFAULT '0',
  `updated_at` INT(10) UNSIGNED NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`uid`),
  INDEX `uid` (`uid`)
)
COMMENT='军团大战用户获得的积分'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


-- 军团优化
-- 2014-08-15
-- lmh
ALTER TABLE `alliance_members` ADD `oc` INT( 4 ) NOT NULL DEFAULT '0' COMMENT '创建或者加入军团领取一奖励' AFTER `joinline_at` ;

ALTER TABLE `alliance_members` ADD INDEX `aid` (`aid`);


--  军团活跃
--  2015-02-11 小年
--  lmh
ALTER TABLE  `alliance` ADD  `alevel` INT( 10 ) UNSIGNED NOT NULL DEFAULT  '1' COMMENT  '军团活跃等级' AFTER  `point` ;
ALTER TABLE  `alliance` ADD  `apoint` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '军团活跃点数' AFTER  `alevel` ;
ALTER TABLE  `alliance` ADD  `ainfo` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT  '[]' COMMENT  '军团活跃存储资源信息' AFTER  `apoint` ;
ALTER TABLE  `alliance` ADD  `apoint_at` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '当天活跃刷新凌晨时间' AFTER  `point_at` ;
ALTER TABLE  `alliance` ADD `setname_at` INT( 11 ) NOT NULL DEFAULT '0' AFTER `apoint_at` ;




ALTER TABLE  `alliance_members` ADD  `apoint` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `raising` ;  -- 当天自己的活跃
ALTER TABLE  `alliance_members` ADD  `apoint_at` INT( 11 ) NOT NULL DEFAULT  '0' AFTER  `apoint` ; -- 当前活跃的凌晨时间戳
ALTER TABLE  `alliance_members` ADD  `ar` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '存储领取奖励的资源数' AFTER  `apoint_at` ;
ALTER TABLE  `alliance_members` ADD  `ar_at` INT( 11 ) NOT NULL DEFAULT  '0' COMMENT  '领奖的凌晨时间戳' AFTER  `ar` ;



ALTER TABLE `alliance` CHANGE `ainfo` `ainfo` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '[]' COMMENT '军团活跃存储资源信息';
ALTER TABLE `alliance_members` CHANGE `ar` `ar` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '[]' COMMENT '存储领取奖励的资源数';

-- 区域战
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

