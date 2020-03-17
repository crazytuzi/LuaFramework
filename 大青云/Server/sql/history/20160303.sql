-- MySQL dump 10.13  Distrib 5.5.15, for Linux (x86_64)
--
-- Host: localhost    Database: venus
-- ------------------------------------------------------
-- Server version	5.5.15-log

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
-- Table structure for table `tb_LastGuildWarMailTime`
--

DROP TABLE IF EXISTS `tb_LastGuildWarMailTime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_LastGuildWarMailTime` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'id',
  `nLastSendTime` int(11) NOT NULL DEFAULT '0' COMMENT '上次发送时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录上次帮派战邮件发送时间';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_Realm_Strenthen`
--

DROP TABLE IF EXISTS `tb_Realm_Strenthen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_Realm_Strenthen` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `strenthen_id` int(11) NOT NULL DEFAULT '0' COMMENT '境界巩固id',
  `select_id` int(11) NOT NULL DEFAULT '0' COMMENT '当前选择境界模型id',
  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '境界巩固进度',
  `break_id` int(11) NOT NULL DEFAULT '0' COMMENT '巩固突破',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='境界巩固';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_account`
--

DROP TABLE IF EXISTS `tb_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_account` (
  `account` varchar(64) NOT NULL COMMENT '账号名',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `create_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '创角时间',
  `last_logout` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '上次登出时间',
  `last_login` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '上次登录时间',
  `valid` int(11) NOT NULL DEFAULT '0' COMMENT '封禁标识(暂未用)',
  `forb_chat_time` int(11) NOT NULL DEFAULT '0' COMMENT '禁言时间点',
  `forb_chat_last` int(11) NOT NULL DEFAULT '0' COMMENT '禁言持续时间(单位s)',
  `forb_acc_time` int(11) NOT NULL DEFAULT '0' COMMENT '账号封禁时间点',
  `forb_acc_last` int(11) NOT NULL DEFAULT '0' COMMENT '账号封禁持续时间(单位s)',
  `last_ip` varchar(32) NOT NULL DEFAULT '' COMMENT '上次登录IP地址',
  `last_mac` varchar(32) NOT NULL DEFAULT '' COMMENT '上次登录Mac',
  `adult` int(11) NOT NULL DEFAULT '0' COMMENT '防沉迷标识(1-成年人, 0-未成年)',
  `groupid` int(11) NOT NULL DEFAULT '0' COMMENT '区服ID',
  `gm_flag` int(11) NOT NULL DEFAULT '0' COMMENT 'GM帐号标识',
  `forb_type` int(11) NOT NULL DEFAULT '0' COMMENT '禁封类型',
  `lock_reason` varchar(128) NOT NULL DEFAULT '' COMMENT '禁封原因',
  `welfare` int(11) NOT NULL DEFAULT '0' COMMENT '福利账号状态',
  `oper` varchar(64) NOT NULL DEFAULT '' COMMENT '福利账号申请人',
  `oper_time` int(11) NOT NULL DEFAULT '0' COMMENT '福利账号申请时间',
  PRIMARY KEY (`charguid`),
  KEY `account` (`account`),
  KEY `groupid` (`groupid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家账号表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_activity`
--

DROP TABLE IF EXISTS `tb_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_activity` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `activity` int(11) NOT NULL DEFAULT '0' COMMENT '活动配表ID',
  `join_count` int(11) NOT NULL DEFAULT '0' COMMENT '参加活动次数',
  `last_join` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次进入时间点',
  `flags` int(11) NOT NULL DEFAULT '0' COMMENT '活动标识',
  `param` varchar(64) NOT NULL DEFAULT '0' COMMENT '活动参数',
  `online_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家在活动时长',
  PRIMARY KEY (`charguid`,`activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='活动表,记录玩家参与活动信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_app_hang`
--

DROP TABLE IF EXISTS `tb_app_hang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_app_hang` (
  `charguid` bigint(20) NOT NULL DEFAULT '0',
  `taskid` bigint(20) NOT NULL DEFAULT '0',
  `mapid` int(11) NOT NULL DEFAULT '0',
  `monsterid` int(11) NOT NULL DEFAULT '0',
  `start` int(11) NOT NULL DEFAULT '0',
  `end` int(11) NOT NULL DEFAULT '0',
  `isget` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `exp` bigint(20) NOT NULL,
  `gold` bigint(20) NOT NULL,
  `item` varchar(4096) NOT NULL DEFAULT '',
  `lastchecktime` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`taskid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_arena`
--

DROP TABLE IF EXISTS `tb_arena`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_arena` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '当前竞技场排名',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '昨日竞技场排名',
  `challtime` int(11) NOT NULL DEFAULT '0' COMMENT '今日挑战次数',
  `conwincnt` int(11) NOT NULL DEFAULT '0' COMMENT '连续胜利次数',
  `totalgold` int(11) NOT NULL DEFAULT '0' COMMENT '累计获得金币数',
  `totalhonor` int(11) NOT NULL DEFAULT '0' COMMENT '累计获得荣誉值',
  `reward_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次领奖时间',
  `cooldown_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次挑战冷却时间',
  `newday_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次查看时间',
  `buy_challtime` int(11) NOT NULL DEFAULT '0' COMMENT '购买挑战次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='离线竞技场信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_arena_att`
--

DROP TABLE IF EXISTS `tb_arena_att`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_arena_att` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `atk` double NOT NULL DEFAULT '0' COMMENT '攻击力',
  `hp` double NOT NULL DEFAULT '0' COMMENT '最大血量',
  `hit` double NOT NULL DEFAULT '0' COMMENT '命中率',
  `dodge` double NOT NULL DEFAULT '0' COMMENT '闪避',
  `subdef` double NOT NULL DEFAULT '0' COMMENT '破防',
  `def` double NOT NULL DEFAULT '0' COMMENT '防御力',
  `cri` double NOT NULL DEFAULT '0' COMMENT '暴击',
  `crivalue` double NOT NULL DEFAULT '0' COMMENT '暴伤',
  `absatk` double NOT NULL DEFAULT '0' COMMENT '穿刺',
  `defcri` double NOT NULL DEFAULT '0' COMMENT '韧性',
  `subcri` double NOT NULL DEFAULT '0' COMMENT '免爆',
  `parryvalue` double NOT NULL DEFAULT '0' COMMENT '格挡值',
  `dmgsub` double NOT NULL DEFAULT '0' COMMENT '伤害减免',
  `dmgadd` double NOT NULL DEFAULT '0' COMMENT '伤害增强',
  `skill1` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏1',
  `skill2` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏2',
  `skill3` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏3',
  `skill4` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏4',
  `skill5` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏5',
  `skill6` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏6',
  `skill7` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏7',
  `skill8` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏8',
  `skill9` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏9',
  `skill10` int(10) NOT NULL DEFAULT '0' COMMENT '技能栏10',
  `parryrate` double NOT NULL DEFAULT '0',
  `supper` double NOT NULL DEFAULT '0',
  `suppervalue` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='竞技场属性表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_arena_event`
--

DROP TABLE IF EXISTS `tb_arena_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_arena_event` (
  `aid` bigint(20) NOT NULL,
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `cfgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '记录配置ID',
  `time` bigint(20) NOT NULL DEFAULT '0' COMMENT '挑战时间',
  `param` varchar(64) NOT NULL DEFAULT '0' COMMENT '挑战记录参数',
  PRIMARY KEY (`aid`),
  KEY `guid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='竞技场挑战记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_aura`
--

DROP TABLE IF EXISTS `tb_aura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_aura` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `aura_gid` bigint(20) NOT NULL COMMENT 'BUFF GUID',
  `aura_id` int(11) NOT NULL COMMENT 'BUFF 配置ID',
  `cast_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '施法者GUID',
  `end_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '到期时间点',
  `flags` int(11) NOT NULL DEFAULT '0' COMMENT '标识',
  PRIMARY KEY (`charguid`,`aura_gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='下线保存BUFF表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_babel`
--

DROP TABLE IF EXISTS `tb_babel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_babel` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL COMMENT '当前挑战层数',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '最短通关时间s',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '挑战次数',
  PRIMARY KEY (`charguid`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='斗破苍穹记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_babel_rank`
--

DROP TABLE IF EXISTS `tb_babel_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_babel_rank` (
  `rank` int(11) NOT NULL COMMENT '斗破苍穹排名',
  `guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT '时间或者层数',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名字',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '玩家等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='斗破苍穹排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_consignment_items`
--

DROP TABLE IF EXISTS `tb_consignment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_consignment_items` (
  `sale_guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '记录GUID',
  `char_guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家guid',
  `sale_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '寄售时间',
  `save_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '到期时间',
  `price` bigint(20) NOT NULL DEFAULT '0' COMMENT '价格',
  `player_name` varchar(64) NOT NULL DEFAULT '' COMMENT '卖家名',
  `itemtid` int(11) NOT NULL DEFAULT '0' COMMENT '装备配表ID',
  `item_count` int(11) NOT NULL DEFAULT '0' COMMENT '物品个数',
  `strenid` int(11) NOT NULL DEFAULT '0' COMMENT '强化等级',
  `strenval` int(11) NOT NULL DEFAULT '0' COMMENT '强化值',
  `proval` int(11) NOT NULL DEFAULT '0' COMMENT '升品值',
  `extralv` int(11) NOT NULL DEFAULT '0' COMMENT '追加等级',
  `superholenum` int(11) NOT NULL DEFAULT '0' COMMENT '附加属性数量',
  `super1` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性1',
  `super2` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性2',
  `super3` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性3',
  `super4` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性4',
  `super5` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性5',
  `super6` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性6',
  `super7` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性7',
  `newsuper` varchar(64) NOT NULL DEFAULT '' COMMENT '新卓越属性',
  `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
  `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态',
  `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性',
  `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
  `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值',
  PRIMARY KEY (`sale_guid`),
  KEY `char_guid` (`char_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='寄售行';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_consignment_record`
--

DROP TABLE IF EXISTS `tb_consignment_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_consignment_record` (
  `record_guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '记录GUID',
  `char_guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '贩卖人GUID',
  `item_id` int(11) NOT NULL DEFAULT '0' COMMENT '物品ID',
  `item_count` int(11) NOT NULL DEFAULT '0' COMMENT '物品个数',
  `sale_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '卖出时间',
  `gain_money` bigint(20) NOT NULL DEFAULT '0' COMMENT '得到收益',
  `buy_char_name` varchar(64) NOT NULL DEFAULT '' COMMENT '购买人名字',
  PRIMARY KEY (`record_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='寄售行收益记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_crossarena_history`
--

DROP TABLE IF EXISTS `tb_crossarena_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_crossarena_history` (
  `seasonid` int(11) NOT NULL COMMENT '赛季ID',
  `arenaid` int(11) NOT NULL DEFAULT '0' COMMENT '竞技ID',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT '玩家名字',
  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '战力',
  PRIMARY KEY (`seasonid`,`arenaid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服擂台表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_crossarena_xiazhu`
--

DROP TABLE IF EXISTS `tb_crossarena_xiazhu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_crossarena_xiazhu` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家id',
  `seasonid` int(10) NOT NULL DEFAULT '0' COMMENT '赛季ID',
  `targetguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '目标玩家guid',
  `xiazhunum` int(11) NOT NULL DEFAULT '0' COMMENT '下注金额',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家下注信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_crossboss_history`
--

DROP TABLE IF EXISTS `tb_crossboss_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_crossboss_history` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'ID',
  `avglv` int(11) NOT NULL DEFAULT '0' COMMENT '平均等级',
  `firstname1` varchar(32) NOT NULL DEFAULT '' COMMENT '第一玩家',
  `killname1` varchar(32) NOT NULL DEFAULT '' COMMENT '击杀玩家',
  `firstname2` varchar(32) NOT NULL DEFAULT '' COMMENT '第一玩家',
  `killname2` varchar(32) NOT NULL DEFAULT '' COMMENT '击杀玩家',
  `firstname3` varchar(32) NOT NULL DEFAULT '' COMMENT '第一玩家',
  `killname3` varchar(32) NOT NULL DEFAULT '' COMMENT '击杀玩家',
  `firstname4` varchar(32) NOT NULL DEFAULT '' COMMENT '第一玩家',
  `killname4` varchar(32) NOT NULL DEFAULT '' COMMENT '击杀玩家',
  `firstname5` varchar(32) NOT NULL DEFAULT '' COMMENT '第一玩家',
  `killname5` varchar(32) NOT NULL DEFAULT '' COMMENT '击杀玩家',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服BOSS记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_daily_buy`
--

DROP TABLE IF EXISTS `tb_daily_buy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_daily_buy` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家guid',
  `buy_exp` int(11) NOT NULL DEFAULT '0' COMMENT '今日购买经验次数',
  `buy_lingli` int(11) NOT NULL DEFAULT '0' COMMENT '今日购买灵力次数',
  `buy_silver` int(11) NOT NULL DEFAULT '0' COMMENT '今日购买银两次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='每日购买记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_database_version`
--

DROP TABLE IF EXISTS `tb_database_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_database_version` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL COMMENT '版本号',
  `lastSql` varchar(255) DEFAULT NULL COMMENT '更新说明',
  `updateDate` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8 COMMENT='版本表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_day_history`
--

DROP TABLE IF EXISTS `tb_day_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_day_history` (
  `date_time` varchar(32) NOT NULL DEFAULT '0' COMMENT '日期',
  `maxonline` int(20) NOT NULL DEFAULT '0' COMMENT '人数',
  PRIMARY KEY (`date_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='最大在线表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_dupl_rank`
--

DROP TABLE IF EXISTS `tb_dupl_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_dupl_rank` (
  `groupid` int(11) NOT NULL DEFAULT '0' COMMENT '副本组id',
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '排名',
  `guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT '通关时间',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名称',
  `icon` int(11) NOT NULL DEFAULT '0' COMMENT '玩家头像ID',
  PRIMARY KEY (`groupid`,`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='副本排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_exchange_record`
--

DROP TABLE IF EXISTS `tb_exchange_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_exchange_record` (
  `order_id` varchar(32) NOT NULL COMMENT '充值订单ID',
  `uid` varchar(32) NOT NULL DEFAULT '' COMMENT '账号ID',
  `role_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `money` int(11) NOT NULL DEFAULT '0' COMMENT '钱',
  `coins` int(11) NOT NULL DEFAULT '0' COMMENT '元宝',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '时间',
  `recharge` int(11) NOT NULL DEFAULT '1' COMMENT '是否兑换',
  `platform` varchar(32) NOT NULL DEFAULT '' COMMENT '平台',
  PRIMARY KEY (`order_id`),
  KEY `guid_idx` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='充值记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_extremity_rank`
--

DROP TABLE IF EXISTS `tb_extremity_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_extremity_rank` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型：0,boss 1:monster',
  `headid` int(11) NOT NULL DEFAULT '0' COMMENT '头像',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '名字',
  `rankval` bigint(20) NOT NULL DEFAULT '0' COMMENT '排序值：BOSS时是伤害 MONSTER时是杀怪数',
  `updatetime` bigint(20) NOT NULL DEFAULT '0' COMMENT '更新时间',
  `getawardtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '领取奖励时间',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`charguid`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_fashion`
--

DROP TABLE IF EXISTS `tb_fashion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_fashion` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `f_tid` int(11) NOT NULL DEFAULT '0' COMMENT '时装ID',
  `time` varchar(128) NOT NULL DEFAULT '' COMMENT '到期时间点',
  PRIMARY KEY (`charguid`,`f_tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='时装表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_festivalact`
--

DROP TABLE IF EXISTS `tb_festivalact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_festivalact` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'id',
  `festival_param` int(11) NOT NULL DEFAULT '0' COMMENT '节日活动参数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='节日活动';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_forb_mac`
--

DROP TABLE IF EXISTS `tb_forb_mac`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_forb_mac` (
  `mac` varchar(32) NOT NULL DEFAULT '' COMMENT 'mac地址',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'charguid',
  `skey` int(11) NOT NULL DEFAULT '0' COMMENT '服务器组',
  `reason` varchar(128) NOT NULL DEFAULT '' COMMENT '封禁原因',
  `locktime` int(11) NOT NULL DEFAULT '0' COMMENT '封禁时间',
  PRIMARY KEY (`mac`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_gem_info`
--

DROP TABLE IF EXISTS `tb_gem_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_gem_info` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gemid` int(11) NOT NULL COMMENT '宝石配置ID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '宝石等级',
  PRIMARY KEY (`charguid`,`gemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝石表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_gm_account`
--

DROP TABLE IF EXISTS `tb_gm_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_gm_account` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `gm_level` int(11) NOT NULL DEFAULT '0' COMMENT 'GM等级',
  `oper` varchar(32) NOT NULL DEFAULT '' COMMENT '操作者',
  `oper_time` int(11) NOT NULL DEFAULT '0' COMMENT '操作时间',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='GM帐号表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_gm_oper`
--

DROP TABLE IF EXISTS `tb_gm_oper`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_gm_oper` (
  `gid` bigint(20) NOT NULL DEFAULT '0',
  `oper` varchar(32) NOT NULL DEFAULT '',
  `time` int(11) NOT NULL DEFAULT '0',
  `errno` varchar(32) NOT NULL DEFAULT '',
  `errmsg` varchar(32) NOT NULL DEFAULT '',
  `type` varchar(32) NOT NULL DEFAULT '',
  `post_data` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`gid`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_group_charge`
--

DROP TABLE IF EXISTS `tb_group_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_group_charge` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '首充人数',
  `extracnt` int(11) NOT NULL DEFAULT '0' COMMENT '额外人数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='首充团购表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_group_purchase`
--

DROP TABLE IF EXISTS `tb_group_purchase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_group_purchase` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '活动ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '次数',
  `extracnt` int(11) NOT NULL DEFAULT '0' COMMENT '额外次数',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='团购表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild`
--

DROP TABLE IF EXISTS `tb_guild`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild` (
  `gid` bigint(20) NOT NULL COMMENT '帮派GUID',
  `capital` double NOT NULL DEFAULT '0' COMMENT '帮派资金',
  `name` varchar(50) NOT NULL DEFAULT '0' COMMENT '帮派名称',
  `notice` varchar(256) NOT NULL DEFAULT '0' COMMENT '帮派公告',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '帮派等级',
  `flag` int(11) NOT NULL DEFAULT '0' COMMENT '帮派标识信息',
  `count1` int(11) NOT NULL DEFAULT '0' COMMENT '帮派资源1数量',
  `count2` int(11) NOT NULL DEFAULT '0' COMMENT '帮派资源2数量',
  `count3` int(11) NOT NULL DEFAULT '0' COMMENT '帮派资源3数量',
  `create_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派创建时间',
  `alianceid` bigint(20) NOT NULL DEFAULT '0' COMMENT '同盟帮派GUID',
  `liveness` int(11) NOT NULL DEFAULT '0' COMMENT '帮派活跃度',
  `bless` varchar(256) NOT NULL DEFAULT '' COMMENT '帮派祈福记录信息',
  `extendnum` int(11) NOT NULL DEFAULT '0' COMMENT '扩展人数',
  `statuscnt` int(11) NOT NULL DEFAULT '0' COMMENT '帮派雕像次数',
  PRIMARY KEY (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_aliance_apply`
--

DROP TABLE IF EXISTS `tb_guild_aliance_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_aliance_apply` (
  `gid` bigint(20) NOT NULL COMMENT '帮派GUID',
  `applygid` bigint(20) NOT NULL COMMENT '申请同盟帮派GUID',
  `time` bigint(20) NOT NULL DEFAULT '0' COMMENT '申请时间',
  PRIMARY KEY (`gid`,`applygid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派同盟申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_apply`
--

DROP TABLE IF EXISTS `tb_guild_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_apply` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `time` bigint(20) NOT NULL DEFAULT '0' COMMENT '申请时间',
  PRIMARY KEY (`charguid`,`gid`),
  KEY `gid` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_boss`
--

DROP TABLE IF EXISTS `tb_guild_boss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_boss` (
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `boss_time` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Boss召唤时间',
  PRIMARY KEY (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派BOSS表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_citywar`
--

DROP TABLE IF EXISTS `tb_guild_citywar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_citywar` (
  `id` int(11) NOT NULL DEFAULT '0',
  `atkgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '攻击帮派GUID',
  `defgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '防守帮派GUID',
  `goduid` bigint(20) NOT NULL DEFAULT '0' COMMENT '神王GUID',
  `contdef` int(11) NOT NULL DEFAULT '0' COMMENT '连续防守次数',
  `contreward` int(11) NOT NULL DEFAULT '0' COMMENT '剩余礼包数',
  `statusgid1` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像1所属帮派GUID',
  `statusgid2` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像2所属帮派GUID',
  `statusgid3` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像3所属帮派GUID',
  `statusgid4` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像4所属帮派GUID',
  `statusuid1` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像1所属角色GUID',
  `statusuid2` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像2所属角色GUID',
  `statusuid3` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像3所属角色GUID',
  `statusuid4` bigint(20) NOT NULL DEFAULT '0' COMMENT '神像4所属角色GUID',
  `isfirst` int(11) NOT NULL DEFAULT '1' COMMENT '是否是第一次',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派王城战信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_event`
--

DROP TABLE IF EXISTS `tb_guild_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_event` (
  `aid` bigint(20) NOT NULL,
  `guid` bigint(20) NOT NULL COMMENT '帮派GUID',
  `cfgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派事件配置ID',
  `time` bigint(20) NOT NULL DEFAULT '0' COMMENT '事件时间',
  `param` varchar(64) NOT NULL DEFAULT '0' COMMENT '事件参数',
  PRIMARY KEY (`aid`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派事件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_hell`
--

DROP TABLE IF EXISTS `tb_guild_hell`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_hell` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `lasttime` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次挑战时间',
  `hellinfo` varchar(256) NOT NULL DEFAULT '' COMMENT '挑战信息',
  PRIMARY KEY (`charguid`),
  KEY `gid` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_mem`
--

DROP TABLE IF EXISTS `tb_guild_mem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_mem` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '成员标识',
  `time` bigint(20) NOT NULL DEFAULT '0' COMMENT '进入帮派时间',
  `contribute` int(11) NOT NULL DEFAULT '0' COMMENT '当前贡献值',
  `allcontribute` int(11) NOT NULL DEFAULT '0' COMMENT '累计贡献值',
  `skillflag` int(11) NOT NULL DEFAULT '0' COMMENT '帮派技能',
  `pos` int(11) NOT NULL DEFAULT '0' COMMENT '职位',
  `addlv` int(11) NOT NULL DEFAULT '0' COMMENT '帮派加持等级',
  `atk` int(11) NOT NULL DEFAULT '0' COMMENT '帮派洗练攻击',
  `def` int(11) NOT NULL DEFAULT '0' COMMENT '帮派洗练加成防御',
  `hp` int(11) NOT NULL DEFAULT '0' COMMENT '帮派洗练加成最大血量',
  `subdef` int(11) NOT NULL DEFAULT '0' COMMENT '帮派洗练加成破防',
  `worships` int(11) NOT NULL DEFAULT '0' COMMENT '被膜拜次数',
  `loyalty` int(11) NOT NULL DEFAULT '0' COMMENT '忠诚度',
  PRIMARY KEY (`charguid`),
  KEY `gid` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派成员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_palace`
--

DROP TABLE IF EXISTS `tb_guild_palace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_palace` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '地宫ID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `signtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '城主时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫城主';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_palace_sign`
--

DROP TABLE IF EXISTS `tb_guild_palace_sign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_palace_sign` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '地宫ID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `gold` bigint(20) NOT NULL DEFAULT '0' COMMENT '报名费',
  `signtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '报名时间',
  `sign_state` int(11) NOT NULL DEFAULT '0' COMMENT '是否返还 0 未返还',
  PRIMARY KEY (`id`,`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫报名';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_storage`
--

DROP TABLE IF EXISTS `tb_guild_storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_storage` (
  `itemgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '装备GUID',
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `itemtid` int(11) NOT NULL DEFAULT '0' COMMENT '装备配表ID',
  `strenid` int(11) NOT NULL DEFAULT '0' COMMENT '强化等级',
  `strenval` int(11) NOT NULL DEFAULT '0' COMMENT '强化值',
  `proval` int(11) NOT NULL DEFAULT '0' COMMENT '升品值',
  `extralv` int(11) NOT NULL DEFAULT '0' COMMENT '追加等级',
  `superholenum` int(11) NOT NULL DEFAULT '0' COMMENT '附加属性数量',
  `super1` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性1',
  `super2` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性2',
  `super3` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性3',
  `super4` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性4',
  `super5` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性5',
  `super6` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性6',
  `super7` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性7',
  `newsuper` varchar(64) NOT NULL DEFAULT '' COMMENT '新卓越属性',
  `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
  `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态',
  `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性',
  `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
  `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值',
  PRIMARY KEY (`itemgid`),
  KEY `gid` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派仓库表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_guild_storage_op`
--

DROP TABLE IF EXISTS `tb_guild_storage_op`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_guild_storage_op` (
  `aid` bigint(20) NOT NULL,
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
  `opname` varchar(64) NOT NULL DEFAULT '' COMMENT '操作者名称',
  `optime` bigint(20) NOT NULL DEFAULT '0' COMMENT '操作时间',
  `optype` int(11) NOT NULL DEFAULT '0' COMMENT '操作类型',
  `opitem` int(11) NOT NULL DEFAULT '0' COMMENT '操作装备配置ID',
  `opextra` int(11) NOT NULL DEFAULT '0' COMMENT '其他信息',
  PRIMARY KEY (`aid`),
  KEY `gid` (`gid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派仓库操作记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_homeland_quest`
--

DROP TABLE IF EXISTS `tb_homeland_quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_homeland_quest` (
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '任务GUID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家战斗力',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '玩家等级',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名字',
  `tid` int(11) NOT NULL DEFAULT '0' COMMENT '配表iD',
  `quest_lv` int(11) NOT NULL DEFAULT '0' COMMENT '任务等级',
  `finish_time` int(11) NOT NULL DEFAULT '0' COMMENT '开始时间',
  `last_time` int(11) NOT NULL DEFAULT '0' COMMENT '持续时间',
  `quality` int(11) NOT NULL DEFAULT '0' COMMENT '品质',
  `rob_cnt` int(11) NOT NULL DEFAULT '0' COMMENT '掠夺次数',
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '任务状态',
  `mon_1` int(11) NOT NULL DEFAULT '0' COMMENT '怪物一',
  `mon_2` int(11) NOT NULL DEFAULT '0' COMMENT '怪物二',
  `mon_3` int(11) NOT NULL DEFAULT '0' COMMENT '怪物三',
  `item_id` int(11) NOT NULL DEFAULT '0' COMMENT '物品ID',
  `reward_type` int(11) NOT NULL DEFAULT '0' COMMENT '奖励类型',
  `reward` bigint(20) NOT NULL DEFAULT '0' COMMENT '奖励',
  `exp` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子经验',
  `disciple_1` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子一',
  `disciple_2` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子二',
  `disciple_3` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子三',
  PRIMARY KEY (`gid`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='家园已接取任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_killtask`
--

DROP TABLE IF EXISTS `tb_killtask`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_killtask` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '档位值',
  `level_count` int(11) NOT NULL DEFAULT '0' COMMENT '杀怪数量',
  PRIMARY KEY (`charguid`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='杀戮表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_lingshoumudi`
--

DROP TABLE IF EXISTS `tb_lingshoumudi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_lingshoumudi` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '挑战玩家guid',
  `today_layer` int(11) NOT NULL DEFAULT '0' COMMENT '今日挑战层数',
  `history_layer` int(11) NOT NULL DEFAULT '0' COMMENT '历史挑战最高层数',
  `history_reward_state` int(11) NOT NULL DEFAULT '0' COMMENT '今日已过层领奖状态 0:未领取 1:已领取',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵兽墓地配表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_lingshoumudi_rank`
--

DROP TABLE IF EXISTS `tb_lingshoumudi_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_lingshoumudi_rank` (
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '玩家排名',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家GUID',
  `player_name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名',
  `layer` int(11) NOT NULL DEFAULT '0' COMMENT '挑战层数',
  `rank_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '记录时间',
  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '玩家职业',
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵兽墓地排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_mail`
--

DROP TABLE IF EXISTS `tb_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_mail` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `mailgid` bigint(20) NOT NULL COMMENT '邮件GUID',
  `readflag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已读标识',
  `deleteflag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '删除标识',
  `recvflag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否收取附件标识',
  PRIMARY KEY (`charguid`,`mailgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='邮件索引表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_mail_content`
--

DROP TABLE IF EXISTS `tb_mail_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_mail_content` (
  `mailgid` bigint(20) NOT NULL COMMENT '邮件GUID',
  `refflag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '群发标识',
  `title` varchar(50) NOT NULL DEFAULT '' COMMENT '标题',
  `content` varchar(512) NOT NULL DEFAULT '' COMMENT '内容',
  `sendtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '发送时间',
  `validtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '有效时间',
  `item1` int(11) NOT NULL DEFAULT '0' COMMENT '附件ID',
  `itemnum1` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item2` int(11) NOT NULL DEFAULT '0',
  `itemnum2` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item3` int(11) NOT NULL DEFAULT '0',
  `itemnum3` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item4` int(11) NOT NULL DEFAULT '0',
  `itemnum4` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item5` int(11) NOT NULL DEFAULT '0',
  `itemnum5` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item6` int(11) NOT NULL DEFAULT '0',
  `itemnum6` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item7` int(11) NOT NULL DEFAULT '0',
  `itemnum7` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `item8` int(11) NOT NULL DEFAULT '0',
  `itemnum8` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
  `param1` int(11) NOT NULL DEFAULT '0',
  `param2` int(11) NOT NULL DEFAULT '0',
  `paramb1` bigint(20) NOT NULL DEFAULT '0',
  `paramb2` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mailgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='邮件内容表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_merge`
--

DROP TABLE IF EXISTS `tb_merge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_merge` (
  `srvid` int(11) NOT NULL DEFAULT '0' COMMENT '区服ID',
  `mergeid` int(11) NOT NULL DEFAULT '0' COMMENT '合服ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '合服次数',
  PRIMARY KEY (`srvid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='合服表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_party_rank`
--

DROP TABLE IF EXISTS `tb_party_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_party_rank` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '活动ID',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名字',
  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
  `arms` int(11) NOT NULL DEFAULT '0' COMMENT '武器',
  `dress` int(11) NOT NULL DEFAULT '0' COMMENT '衣服',
  `fashionhead` int(11) NOT NULL DEFAULT '0' COMMENT '时装头',
  `fashionarms` int(11) NOT NULL DEFAULT '0' COMMENT '时装武器',
  `fashiondress` int(11) NOT NULL DEFAULT '0' COMMENT '时装衣服',
  `wuhunid` int(11) NOT NULL DEFAULT '0' COMMENT '武魂ID',
  `wingid` int(11) NOT NULL DEFAULT '0' COMMENT '翅膀ID',
  `suitflag` int(11) NOT NULL DEFAULT '0' COMMENT '时装标识',
  `rank1` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名1',
  `rank2` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名2',
  `rank3` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名3',
  `rank4` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名4',
  `rank5` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名5',
  `rank6` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名6',
  `rank7` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名7',
  `rank8` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名8',
  `rank9` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名9',
  `rank10` varchar(64) NOT NULL DEFAULT '0' COMMENT '排名10',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='活动排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_achievement`
--

DROP TABLE IF EXISTS `tb_player_achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_achievement` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '成就配置ID',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '成就参数',
  `param2` int(11) NOT NULL DEFAULT '0',
  `param3` int(11) NOT NULL DEFAULT '0',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='成就表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_actpet`
--

DROP TABLE IF EXISTS `tb_player_actpet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_actpet` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家guid',
  `actpet_id` int(11) NOT NULL DEFAULT '0' COMMENT '萌宠id',
  `actpet_state` int(11) NOT NULL DEFAULT '0' COMMENT '萌宠状态 0:未激活 1:休息 2:出战 3:过期',
  `actpet_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '萌宠期限',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`actpet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='萌宠表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_adventure`
--

DROP TABLE IF EXISTS `tb_player_adventure`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_adventure` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '奇遇ID',
  `eventid` int(11) NOT NULL DEFAULT '0' COMMENT '奇遇事件ID',
  `state` int(11) NOT NULL DEFAULT '0' COMMENT '奇遇事件ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '当天次数',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `parma2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  `zhuoyueguide_flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '卓越引导标识',
  `zhuoyueguide_info` varchar(128) NOT NULL DEFAULT '' COMMENT '卓越引导信息',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='奇遇表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_binghun`
--

DROP TABLE IF EXISTS `tb_player_binghun`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_binghun` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂ID',
  `state` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂状态， 1：关闭',
  `current` int(11) NOT NULL DEFAULT '0' COMMENT '当前兵魂， 1：当前',
  `activetime` bigint(20) NOT NULL DEFAULT '0' COMMENT '激活时间',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  `shenghun` varchar(256) NOT NULL DEFAULT '' COMMENT '圣魂',
  `shenghun_hole` int(11) NOT NULL DEFAULT '0' COMMENT '圣魂孔',
  PRIMARY KEY (`charguid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兵魂';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_boss_media`
--

DROP TABLE IF EXISTS `tb_player_boss_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_boss_media` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
  `star` int(11) NOT NULL DEFAULT '0' COMMENT '星级',
  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `point` int(11) NOT NULL DEFAULT '0' COMMENT '总点数',
  `type_1` int(11) NOT NULL DEFAULT '0' COMMENT '类型1',
  `type_2` int(11) NOT NULL DEFAULT '0' COMMENT '类型2',
  `type_3` int(11) NOT NULL DEFAULT '0' COMMENT '类型3',
  `type_4` int(11) NOT NULL DEFAULT '0' COMMENT '类型4',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='boss徽章';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_cd`
--

DROP TABLE IF EXISTS `tb_player_cd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_cd` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型：0,item 1:skill',
  `tid` int(11) NOT NULL DEFAULT '0' COMMENT '表id',
  `cdtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'CD时间',
  `timestamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`type`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_challenge_dupl`
--

DROP TABLE IF EXISTS `tb_player_challenge_dupl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_challenge_dupl` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '今日次数',
  `today` int(11) NOT NULL DEFAULT '0' COMMENT '今日层数',
  `history` int(11) NOT NULL DEFAULT '0' COMMENT '历史层数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='挑战副本表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_crosspvp`
--

DROP TABLE IF EXISTS `tb_player_crosspvp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_crosspvp` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `curcnt` int(11) NOT NULL DEFAULT '0' COMMENT '当天1v1次数',
  `totalcnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1总次数',
  `wincnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1胜利次数',
  `contwincnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1连胜次数',
  `flags` int(11) NOT NULL DEFAULT '0' COMMENT '标识',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家跨服1V1';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_dailyquest`
--

DROP TABLE IF EXISTS `tb_player_dailyquest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_dailyquest` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家GUID',
  `quest_id` int(11) NOT NULL DEFAULT '0' COMMENT '任务ID',
  `quest_star` int(11) NOT NULL DEFAULT '0' COMMENT '日环星级',
  `quest_double` int(11) NOT NULL DEFAULT '0' COMMENT '日环倍率',
  `quest_counter` int(11) NOT NULL DEFAULT '0' COMMENT '当前环数',
  `quest_auto_star` int(11) NOT NULL DEFAULT '0' COMMENT '是否自动升星',
  `quest_counter_id` varchar(256) NOT NULL DEFAULT '0' COMMENT '今日完成日环信息',
  `quest_reward_id` varchar(128) NOT NULL DEFAULT '' COMMENT '日环奖励信息',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='日环信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_disciple`
--

DROP TABLE IF EXISTS `tb_player_disciple`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_disciple` (
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子GUID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `quality` int(11) NOT NULL DEFAULT '0' COMMENT '品质',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '弟子姓名',
  `skill_1` int(11) NOT NULL DEFAULT '0' COMMENT '技能一',
  `skill_2` int(11) NOT NULL DEFAULT '0' COMMENT '技能二',
  `skill_3` int(11) NOT NULL DEFAULT '0' COMMENT '技能三',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
  `exp` int(11) NOT NULL DEFAULT '0' COMMENT '当前经验',
  `icon` int(11) NOT NULL DEFAULT '0' COMMENT '头像',
  `attr` int(11) NOT NULL DEFAULT '0' COMMENT '属性',
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '状态',
  PRIMARY KEY (`gid`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='弟子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_dungeon`
--

DROP TABLE IF EXISTS `tb_player_dungeon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_dungeon` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `dungeon` int(11) NOT NULL DEFAULT '0' COMMENT '副本ID',
  `gamemap` bigint(11) NOT NULL DEFAULT '0' COMMENT '地图唯一ID',
  `line` int(11) NOT NULL DEFAULT '0' COMMENT '线ID',
  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `end_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '结束时间',
  `left_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '剩余时间',
  `last_map` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次唯一地图ID',
  `last_pos_x` double NOT NULL DEFAULT '0' COMMENT '上次位置X',
  `last_pos_z` double NOT NULL DEFAULT '0' COMMENT '上次位置Y',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_dungeon_group`
--

DROP TABLE IF EXISTS `tb_player_dungeon_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_dungeon_group` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `group_id` int(11) NOT NULL DEFAULT '0' COMMENT '副本组ID',
  `diff` int(11) NOT NULL DEFAULT '0' COMMENT '难度',
  `free_count` int(11) NOT NULL DEFAULT '0' COMMENT '剩余次数',
  `buy_count` int(11) NOT NULL DEFAULT '0' COMMENT '购买次数',
  `best_time` int(11) NOT NULL DEFAULT '0' COMMENT '最佳通关时间',
  `scores` varchar(64) NOT NULL DEFAULT '0,0,0,0,0' COMMENT '积分',
  PRIMARY KEY (`charguid`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本组信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_equip_pos`
--

DROP TABLE IF EXISTS `tb_player_equip_pos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_equip_pos` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `pos` int(11) NOT NULL COMMENT '装备位',
  `idx` int(11) NOT NULL COMMENT '位置',
  `groupid` int(11) NOT NULL COMMENT '套装ID',
  `lvl` int(11) NOT NULL COMMENT '套装等级',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`pos`,`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备位套装';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_equips`
--

DROP TABLE IF EXISTS `tb_player_equips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_equips` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `item_id` bigint(20) NOT NULL COMMENT '物品GUID',
  `item_tid` int(11) NOT NULL DEFAULT '0' COMMENT '物品配表ID',
  `slot_id` int(11) NOT NULL DEFAULT '0' COMMENT '位置',
  `stack_num` int(11) NOT NULL DEFAULT '0' COMMENT '叠放数量',
  `flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '标识',
  `bag` int(11) NOT NULL DEFAULT '0' COMMENT '背包',
  `strenid` int(11) NOT NULL DEFAULT '0' COMMENT '强化等级',
  `strenval` int(11) NOT NULL DEFAULT '0' COMMENT '强化值',
  `proval` int(11) NOT NULL DEFAULT '0' COMMENT '升品值',
  `extralv` int(11) NOT NULL DEFAULT '0' COMMENT '追加等级',
  `superholenum` int(11) NOT NULL DEFAULT '0' COMMENT '附加属性数',
  `super1` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性1',
  `super2` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性2',
  `super3` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性3',
  `super4` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性4',
  `super5` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性5',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  `super6` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性6',
  `super7` varchar(64) NOT NULL DEFAULT '' COMMENT '附加属性7',
  `newsuper` varchar(64) NOT NULL DEFAULT '' COMMENT '新卓越属性',
  `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
  `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态',
  `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性',
  `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
  `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值',
  PRIMARY KEY (`item_id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家装备表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_extra`
--

DROP TABLE IF EXISTS `tb_player_extra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_extra` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `expend_bag` int(11) NOT NULL DEFAULT '0' COMMENT '扩展包数量',
  `bag_online` int(11) NOT NULL DEFAULT '0',
  `expend_storage` int(11) NOT NULL DEFAULT '0' COMMENT '扩展仓库',
  `storage_online` int(11) NOT NULL DEFAULT '0',
  `func_flags` varchar(128) NOT NULL DEFAULT '' COMMENT '功能开启标识',
  `babel_count` int(11) NOT NULL DEFAULT '0',
  `offmin` int(11) NOT NULL DEFAULT '0',
  `awardstatus` bigint(20) NOT NULL DEFAULT '0',
  `timing_count` int(11) NOT NULL DEFAULT '0',
  `vitality` varchar(350) NOT NULL DEFAULT '' COMMENT '活力值',
  `actcode_flags` varchar(512) NOT NULL DEFAULT '' COMMENT '激活码标识',
  `vitality_num` varchar(350) NOT NULL DEFAULT '',
  `daily_yesterday` varchar(350) NOT NULL DEFAULT '',
  `worshipstime` bigint(20) NOT NULL DEFAULT '0',
  `zhanyinchip` int(11) NOT NULL DEFAULT '0',
  `baojia_level` int(11) NOT NULL DEFAULT '0',
  `baojia_wish` int(11) NOT NULL DEFAULT '0',
  `baojia_procenum` int(11) NOT NULL DEFAULT '0',
  `addicted_freetime` int(11) NOT NULL DEFAULT '0',
  `fatigue` int(11) NOT NULL DEFAULT '0',
  `reward_bits` int(11) NOT NULL DEFAULT '0',
  `huizhang_lvl` int(11) NOT NULL DEFAULT '0',
  `huizhang_times` int(11) NOT NULL DEFAULT '0',
  `huizhang_zhenqi` int(11) NOT NULL DEFAULT '0',
  `huizhang_progress` varchar(100) NOT NULL DEFAULT '',
  `vitality_getid` int(11) NOT NULL DEFAULT '0',
  `achievement_flag` bigint(20) NOT NULL DEFAULT '0',
  `lianti_pointid` varchar(100) NOT NULL DEFAULT '',
  `huizhang_dropzhenqi` int(11) NOT NULL DEFAULT '0',
  `zhuzairoad_energy` int(11) NOT NULL DEFAULT '0',
  `equipcreate_unlockid` varchar(300) NOT NULL DEFAULT '',
  `sale_count` int(11) NOT NULL DEFAULT '0' COMMENT '今日上架次数',
  `freeshoe_count` int(11) NOT NULL DEFAULT '0' COMMENT '今日免费飞鞋使用次数',
  `lingzhen_level` int(11) NOT NULL DEFAULT '0',
  `lingzhen_wish` int(11) NOT NULL DEFAULT '0',
  `lingzhen_procenum` int(11) NOT NULL DEFAULT '0',
  `item_shortcut` int(11) NOT NULL DEFAULT '0',
  `extremity_monster` bigint(20) NOT NULL DEFAULT '0' COMMENT 'MONSTER时是杀怪数',
  `extremity_damage` bigint(20) NOT NULL DEFAULT '0' COMMENT 'BOSS时是伤害',
  `flyshoe_tick` int(11) NOT NULL DEFAULT '0' COMMENT '飞鞋回复时间计数',
  `seven_day` int(11) NOT NULL DEFAULT '0' COMMENT '七日登录奖励',
  `zhuan_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '转生次数',
  `zhuan_step` bigint(20) NOT NULL DEFAULT '0' COMMENT '转生步骤',
  `lastCheckTime` int(11) NOT NULL DEFAULT '0',
  `daily_count` varchar(350) NOT NULL DEFAULT '' COMMENT '每日计数',
  `lingzhen_attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '灵阵属性丹数量',
  `footprints` int(11) NOT NULL DEFAULT '0' COMMENT '脚印ID',
  `equipcreate_tick` int(11) NOT NULL DEFAULT '0' COMMENT '装备打造活力值在线时间',
  `huizhang_tick` int(11) NOT NULL DEFAULT '0' COMMENT '聚灵碗在线时间',
  `personboss_count` int(11) NOT NULL DEFAULT '0' COMMENT '个人boss购买次数',
  `platform_info` varchar(350) NOT NULL DEFAULT '' COMMENT '平台数据',
  `lastMonthCheckTime` int(11) NOT NULL DEFAULT '0',
  `month_count` varchar(350) NOT NULL DEFAULT '' COMMENT '每月计数',
  `marrystren` int(11) NOT NULL DEFAULT '0' COMMENT '婚戒强化等级',
  `marrystrenwish` int(11) NOT NULL DEFAULT '0' COMMENT '婚戒强化祝福值',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家额外信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_fengyao`
--

DROP TABLE IF EXISTS `tb_player_fengyao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_fengyao` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `fengyao_id` int(11) NOT NULL DEFAULT '0' COMMENT '封妖ID',
  `fengyao_grp` int(11) NOT NULL DEFAULT '0',
  `fengyao_state` int(11) NOT NULL DEFAULT '0',
  `fengyao_counter` int(11) NOT NULL DEFAULT '0',
  `fengyao_score` int(11) NOT NULL DEFAULT '0',
  `fengyao_box` varchar(64) NOT NULL DEFAULT '0',
  `fengyao_refresh` int(11) NOT NULL DEFAULT '0',
  `fengyao_luck` int(11) NOT NULL DEFAULT '0',
  `fengyao_first` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='封妖表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_finishquest`
--

DROP TABLE IF EXISTS `tb_player_finishquest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_finishquest` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `questid` int(11) NOT NULL DEFAULT '0' COMMENT '任务ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '完成次数',
  PRIMARY KEY (`charguid`,`questid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='完成任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_hl_quest`
--

DROP TABLE IF EXISTS `tb_player_hl_quest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_hl_quest` (
  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '任务GUID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `tid` int(11) NOT NULL DEFAULT '0' COMMENT '配表iD',
  `need_time` int(11) NOT NULL DEFAULT '0' COMMENT '需要时间',
  `quality` int(11) NOT NULL DEFAULT '0' COMMENT '品质',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
  `mon_1` int(11) NOT NULL DEFAULT '0' COMMENT '怪物一',
  `mon_2` int(11) NOT NULL DEFAULT '0' COMMENT '怪物二',
  `mon_3` int(11) NOT NULL DEFAULT '0' COMMENT '怪物三',
  `item_id` int(11) NOT NULL DEFAULT '0' COMMENT '物品ID',
  `reward_type` int(11) NOT NULL DEFAULT '0' COMMENT '奖励类型',
  `reward` bigint(20) NOT NULL DEFAULT '0' COMMENT '奖励',
  `exp` bigint(20) NOT NULL DEFAULT '0' COMMENT '弟子经验',
  PRIMARY KEY (`gid`,`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='待接取家园任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_homeland`
--

DROP TABLE IF EXISTS `tb_player_homeland`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_homeland` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `main_lv` int(11) NOT NULL DEFAULT '0' COMMENT '大殿等级',
  `quest_lv` int(11) NOT NULL DEFAULT '0' COMMENT '任务殿等级',
  `xunxian_lv` int(11) NOT NULL DEFAULT '0' COMMENT '寻仙台等级',
  `rob_cnt` int(11) NOT NULL DEFAULT '0' COMMENT '掠夺次数',
  `rob_cd` int(11) NOT NULL DEFAULT '0' COMMENT '掠夺CD',
  `xunxian_ref` int(11) NOT NULL DEFAULT '0' COMMENT '寻仙台刷新时间',
  `xunxian_cnt` int(11) NOT NULL DEFAULT '0' COMMENT '寻仙台刷新时间',
  `quest_ref` int(11) NOT NULL DEFAULT '0' COMMENT '任务殿刷新时间',
  `rob_cnt_cd` int(11) NOT NULL DEFAULT '0' COMMENT '抢夺次数刷新时间',
  `recruit` int(11) NOT NULL DEFAULT '0' COMMENT '招募次数',
  `quest_cnt` int(11) NOT NULL DEFAULT '0' COMMENT '任务刷新次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='家园表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_info`
--

DROP TABLE IF EXISTS `tb_player_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_info` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `name` varchar(64) NOT NULL DEFAULT '' COMMENT '名称',
  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
  `iconid` int(11) NOT NULL DEFAULT '0' COMMENT '头像ID',
  `sex` int(11) NOT NULL DEFAULT '0' COMMENT '性别',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '等级',
  `exp` bigint(20) NOT NULL DEFAULT '0' COMMENT '经验',
  `vip_level` int(11) NOT NULL DEFAULT '0' COMMENT 'vip等级',
  `vip_exp` int(11) NOT NULL DEFAULT '0' COMMENT 'vip经验',
  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '战斗力',
  `leftpoint` int(11) NOT NULL DEFAULT '0' COMMENT '剩余点数',
  `totalpoint` int(11) NOT NULL DEFAULT '0' COMMENT '总点数',
  `bindgold` bigint(20) NOT NULL DEFAULT '0' COMMENT '绑定金币',
  `unbindgold` bigint(20) NOT NULL DEFAULT '0' COMMENT '非绑定金币',
  `bindmoney` bigint(20) NOT NULL DEFAULT '0' COMMENT '礼金',
  `unbindmoney` bigint(20) NOT NULL DEFAULT '0' COMMENT '元宝',
  `hp` int(11) NOT NULL DEFAULT '0' COMMENT '血量',
  `mp` int(11) NOT NULL DEFAULT '0' COMMENT '魔法',
  `hunli` int(11) NOT NULL DEFAULT '0' COMMENT '魂力',
  `tipo` int(11) NOT NULL DEFAULT '0' COMMENT '体魄',
  `shenfa` int(11) NOT NULL DEFAULT '0' COMMENT '身法',
  `jingshen` int(11) NOT NULL DEFAULT '0' COMMENT '精神',
  `sp` int(11) NOT NULL DEFAULT '100' COMMENT '体力值',
  `max_sp` int(11) NOT NULL DEFAULT '100' COMMENT '最大体力值',
  `sp_recover` int(11) NOT NULL DEFAULT '30' COMMENT '体力恢复',
  `zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '真气',
  `func_flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '功能开启标志',
  `soul` int(11) NOT NULL DEFAULT '0' COMMENT '魂值',
  `pk_mode` int(11) NOT NULL DEFAULT '0' COMMENT 'pk模式',
  `pk_status` int(11) NOT NULL DEFAULT '0' COMMENT 'pk状态',
  `pk_flags` int(11) NOT NULL DEFAULT '0' COMMENT 'pk标识',
  `pk_evil` int(11) NOT NULL DEFAULT '0' COMMENT 'pk值',
  `redname_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '红名时间',
  `grayname_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '灰名时间',
  `pk_count` int(11) NOT NULL DEFAULT '0' COMMENT '善恶值',
  `yao_hun` int(11) NOT NULL DEFAULT '0' COMMENT '妖魂',
  `arms` int(11) NOT NULL DEFAULT '0' COMMENT '当前武器',
  `dress` int(11) NOT NULL DEFAULT '0' COMMENT '当前衣服',
  `online_time` int(11) NOT NULL DEFAULT '0' COMMENT '在线时间',
  `head` int(11) NOT NULL DEFAULT '0' COMMENT '当前时装头盔',
  `suit` int(11) NOT NULL DEFAULT '0' COMMENT '当前时装套装',
  `weapon` int(11) NOT NULL DEFAULT '0' COMMENT '当前时装武器',
  `drop_val` int(11) NOT NULL DEFAULT '0' COMMENT '掉落值',
  `drop_lv` int(11) NOT NULL DEFAULT '0' COMMENT '掉落等级',
  `killtask_count` int(11) NOT NULL DEFAULT '0' COMMENT '击杀数',
  `onlinetime_day` int(11) NOT NULL DEFAULT '0' COMMENT '在线天数',
  `honor` int(11) NOT NULL DEFAULT '0' COMMENT '荣誉值',
  `hearthstone_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '回城时间',
  `lingzhi` int(11) NOT NULL DEFAULT '0' COMMENT '灵值',
  `jingjie_exp` int(11) NOT NULL DEFAULT '0' COMMENT '境界经验',
  `vplan` int(11) NOT NULL DEFAULT '0' COMMENT 'Vplan',
  `blesstime` bigint(20) NOT NULL DEFAULT '0' COMMENT '膜拜时间',
  `equipval` int(11) NOT NULL DEFAULT '0' COMMENT '装备值',
  `wuhunid` int(11) NOT NULL DEFAULT '0' COMMENT '当前武魂id',
  `shenbingid` int(11) NOT NULL DEFAULT '0' COMMENT '当前神兵id',
  `extremityval` bigint(20) NOT NULL DEFAULT '0' COMMENT '极限桃战积分',
  `wingid` int(11) NOT NULL DEFAULT '0' COMMENT '当前翅膀ID',
  `blesstime2` bigint(20) NOT NULL DEFAULT '0' COMMENT '膜拜时间2',
  `blesstime3` bigint(20) NOT NULL DEFAULT '0' COMMENT '膜拜时间3',
  `suitflag` int(11) NOT NULL DEFAULT '0' COMMENT '套装标识',
  `crossscore` int(11) NOT NULL DEFAULT '0' COMMENT '跨服积分',
  `crossexploit` int(11) NOT NULL DEFAULT '0' COMMENT '跨服功勋',
  `crossseasonid` int(11) NOT NULL DEFAULT '0' COMMENT '赛季ID',
  `pvplevel` int(11) NOT NULL DEFAULT '0' COMMENT '段位',
  `soul_hzlevel` int(11) NOT NULL DEFAULT '0' COMMENT '噬魂徽章等级',
  `other_money` bigint(20) NOT NULL DEFAULT '0' COMMENT '非充值元宝',
  `HBCheatNum` int(11) NOT NULL DEFAULT '0' COMMENT '加速挂次数',
  `wash_lucky` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_items`
--

DROP TABLE IF EXISTS `tb_player_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_items` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `item_id` bigint(20) NOT NULL COMMENT '物品GUID',
  `item_tid` int(11) NOT NULL DEFAULT '0' COMMENT '物品配表ID',
  `slot_id` int(11) NOT NULL DEFAULT '0' COMMENT '位置',
  `stack_num` int(11) NOT NULL DEFAULT '0' COMMENT '叠放数量',
  `flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '标识',
  `bag` int(11) NOT NULL DEFAULT '0' COMMENT '背包',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  `param3` int(11) NOT NULL DEFAULT '0' COMMENT '参数3',
  `param4` bigint(20) NOT NULL DEFAULT '0' COMMENT '物品参数4',
  `param5` bigint(20) NOT NULL DEFAULT '0' COMMENT '物品参数5',
  `param6` varchar(64) NOT NULL DEFAULT '' COMMENT '物品参数6',
  `param7` varchar(64) NOT NULL DEFAULT '' COMMENT '物品参数7',
  PRIMARY KEY (`item_id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家物品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_ls_horse`
--

DROP TABLE IF EXISTS `tb_player_ls_horse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_ls_horse` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lshorse_step` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑阶数',
  `lshorse_process` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑进度',
  `lshorse_procenum` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑进阶次数',
  `lshorse_totalproce` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑总进阶次数',
  `lshorse_attr` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑属性丹次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵兽坐骑';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_lunpan`
--

DROP TABLE IF EXISTS `tb_player_lunpan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_lunpan` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `lunpan_attr` varchar(128) NOT NULL DEFAULT '' COMMENT '轮盘属性',
  `lunpan_num` int(11) NOT NULL DEFAULT '0' COMMENT '轮盘今日次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='轮盘';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_map_info`
--

DROP TABLE IF EXISTS `tb_player_map_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_map_info` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `base_map` int(11) NOT NULL DEFAULT '0' COMMENT '地图配表ID',
  `game_map` bigint(20) NOT NULL DEFAULT '0' COMMENT '地图唯一ID',
  `pos_x` double NOT NULL DEFAULT '0' COMMENT '位置X',
  `pos_z` double NOT NULL DEFAULT '0' COMMENT '位置Y',
  `dir` double NOT NULL DEFAULT '0' COMMENT '朝向',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='地图表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_marry_info`
--

DROP TABLE IF EXISTS `tb_player_marry_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_marry_info` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家ID',
  `mateguid` bigint(20) NOT NULL COMMENT '配偶ID',
  `marryState` int(11) NOT NULL DEFAULT '0' COMMENT '婚姻状态',
  `marryTime` bigint(20) NOT NULL COMMENT '结婚时间',
  `marryType` int(11) NOT NULL DEFAULT '0' COMMENT '婚礼类型',
  `marryTraveled` int(11) NOT NULL DEFAULT '0' COMMENT '是否巡游过0否 1是',
  `marryDinnered` int(11) NOT NULL DEFAULT '0' COMMENT '是否开启过婚宴0否 1是',
  `marryRingCfgId` int(11) NOT NULL DEFAULT '0' COMMENT '婚戒档次ID',
  `marryIntimate` int(11) NOT NULL DEFAULT '0' COMMENT '亲密度',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='结婚信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_marry_invite_card`
--

DROP TABLE IF EXISTS `tb_player_marry_invite_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_marry_invite_card` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `mailGid` bigint(20) NOT NULL DEFAULT '0' COMMENT '邮件Gid',
  `inviteTime` bigint(20) NOT NULL COMMENT '请帖的时间戳',
  `scheduleId` int(11) NOT NULL COMMENT '预定时间配置表ID',
  `inviteRoleName` varchar(32) NOT NULL DEFAULT '' COMMENT '邀请人名字',
  `inviteMateName` varchar(32) NOT NULL DEFAULT '' COMMENT '邀请人配偶字',
  `profId` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
  PRIMARY KEY (`charguid`,`mailGid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='请帖表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_marry_schedule`
--

DROP TABLE IF EXISTS `tb_player_marry_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_marry_schedule` (
  `charguid` bigint(20) NOT NULL COMMENT '预订人ID',
  `mateguid` bigint(20) NOT NULL COMMENT '配偶ID',
  `roleName` varchar(32) NOT NULL DEFAULT '' COMMENT '预订人名字',
  `mateName` varchar(32) NOT NULL DEFAULT '' COMMENT '配偶名字',
  `roleProfId` int(11) NOT NULL DEFAULT '0' COMMENT '预订人职业',
  `mateProfId` int(11) NOT NULL DEFAULT '0' COMMENT '配偶职业',
  `scheduleId` int(11) NOT NULL DEFAULT '0' COMMENT '预约时间段ID',
  `scheduleTime` bigint(20) NOT NULL COMMENT '时间戳',
  `invites` varchar(2048) NOT NULL DEFAULT '' COMMENT '被邀请的玩家ID',
  PRIMARY KEY (`charguid`,`mateguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='婚礼预约表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_onlinereward`
--

DROP TABLE IF EXISTS `tb_player_onlinereward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_onlinereward` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `draw_id` int(11) NOT NULL DEFAULT '0' COMMENT '抽奖ID',
  `draw_level` int(11) NOT NULL DEFAULT '0' COMMENT '抽奖等级',
  `draw_index` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`draw_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='在线奖励表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_party`
--

DROP TABLE IF EXISTS `tb_player_party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_party` (
  `id` int(11) NOT NULL COMMENT '活动ID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `award` int(11) NOT NULL DEFAULT '0' COMMENT '奖励标记',
  `awardtimes` int(11) NOT NULL DEFAULT '0' COMMENT '奖励次数',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  `param3` int(11) NOT NULL DEFAULT '0' COMMENT '参数3',
  PRIMARY KEY (`charguid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='运营活动表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_personboss`
--

DROP TABLE IF EXISTS `tb_player_personboss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_personboss` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `id` int(11) NOT NULL DEFAULT '0' COMMENT '个人bossID',
  `cur_count` int(11) NOT NULL DEFAULT '0' COMMENT '当前次数',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '更新时间',
  `first` int(11) NOT NULL DEFAULT '0' COMMENT '首通标记1,首通',
  PRIMARY KEY (`charguid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='个人boss';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_prerogative`
--

DROP TABLE IF EXISTS `tb_player_prerogative`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_prerogative` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `prerogative` int(11) NOT NULL DEFAULT '0' COMMENT '特权类型',
  `param_32` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param_64` bigint(20) NOT NULL DEFAULT '0' COMMENT '参数2',
  PRIMARY KEY (`charguid`,`prerogative`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='特权奖励表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_protodata`
--

DROP TABLE IF EXISTS `tb_player_protodata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_protodata` (
  `char_guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家guid',
  `binary_data` blob NOT NULL COMMENT '玩家二进制数据',
  PRIMARY KEY (`char_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家的protobuff数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_quests`
--

DROP TABLE IF EXISTS `tb_player_quests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_quests` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `quest_id` int(11) NOT NULL COMMENT '任务ID',
  `quest_state` int(11) NOT NULL DEFAULT '0' COMMENT '任务状态',
  `goal1` bigint(20) NOT NULL DEFAULT '0' COMMENT '任务目标ID',
  `goal_count1` int(11) NOT NULL DEFAULT '0' COMMENT '任务目标计数',
  `goal2` bigint(20) NOT NULL DEFAULT '0',
  `goal_count2` int(11) NOT NULL DEFAULT '0',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`quest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_realm`
--

DROP TABLE IF EXISTS `tb_player_realm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_realm` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `realm_step` int(11) NOT NULL DEFAULT '0' COMMENT '境界等级',
  `realm_feed_num` int(11) NOT NULL DEFAULT '0' COMMENT '境界灌注次数',
  `realm_progress` varchar(128) NOT NULL DEFAULT '' COMMENT '境界属性进度',
  `realm_strenthen` int(11) NOT NULL DEFAULT '0',
  `wish` int(11) NOT NULL DEFAULT '0' COMMENT '祝福值',
  `procenum` int(11) NOT NULL DEFAULT '0' COMMENT '进阶失败次数',
  `fh_itemnum` bigint(20) NOT NULL DEFAULT '0' COMMENT '返还道具数量',
  `fh_level_itemnum` int(11) NOT NULL DEFAULT '0' COMMENT '返还道具数量当前等阶',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='境界表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_refinery`
--

DROP TABLE IF EXISTS `tb_player_refinery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_refinery` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `id` varchar(256) NOT NULL DEFAULT '' COMMENT '强化信息',
  `cost_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '消耗真气',
  `fh_cost_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '返还消耗真气',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='强化表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_ride_dupl`
--

DROP TABLE IF EXISTS `tb_player_ride_dupl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_ride_dupl` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '今日次数',
  `today` int(11) NOT NULL DEFAULT '0' COMMENT '今日层数',
  `history` int(11) NOT NULL DEFAULT '0' COMMENT '历史层数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='骑战副本表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_ridewar`
--

DROP TABLE IF EXISTS `tb_player_ridewar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_ridewar` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `ridewar_id` int(11) NOT NULL DEFAULT '0' COMMENT '骑战id',
  `ridewar_wish` int(11) NOT NULL DEFAULT '0' COMMENT '骑战祝福值',
  `ridewar_procenum` int(11) NOT NULL DEFAULT '0' COMMENT '骑战进阶失败次数',
  `ridewar_attrnum` int(11) NOT NULL DEFAULT '0' COMMENT '骑战属性丹数',
  `ridewar_skin` int(11) NOT NULL DEFAULT '0' COMMENT '骑战当前选择id',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='骑战表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_setting`
--

DROP TABLE IF EXISTS `tb_player_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_setting` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `param1` int(11) NOT NULL DEFAULT '1024' COMMENT '参数1',
  `param2` varchar(128) NOT NULL DEFAULT '' COMMENT '参数2',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='系统设置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shenbing`
--

DROP TABLE IF EXISTS `tb_player_shenbing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shenbing` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '神兵等级',
  `wish` int(11) NOT NULL DEFAULT '0' COMMENT '祝福值',
  `proficiency` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度',
  `proficiencylvl` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度等级',
  `procenum` int(11) NOT NULL DEFAULT '0' COMMENT '进阶失败次数',
  `skinlevel` int(11) NOT NULL DEFAULT '0' COMMENT '神兵皮肤',
  `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '神兵属性丹数量',
  `bingling` varchar(300) NOT NULL DEFAULT '' COMMENT '兵灵',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兵表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shengling`
--

DROP TABLE IF EXISTS `tb_player_shengling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shengling` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
  `total_proce` int(11) NOT NULL DEFAULT '0' COMMENT '总失败次数',
  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shengling_skin`
--

DROP TABLE IF EXISTS `tb_player_shengling_skin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shengling_skin` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `skin_id` int(11) NOT NULL COMMENT '皮肤ID',
  `skin_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '皮肤到期时间',
  PRIMARY KEY (`charguid`,`skin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='圣灵皮肤表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shenshou`
--

DROP TABLE IF EXISTS `tb_player_shenshou`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shenshou` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `shenshou_id` int(11) NOT NULL DEFAULT '0' COMMENT '神兽ID',
  `skin_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '神兽皮肤时间',
  PRIMARY KEY (`charguid`,`shenshou_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兽';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shenwu`
--

DROP TABLE IF EXISTS `tb_player_shenwu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shenwu` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `shenwu_level` int(11) NOT NULL DEFAULT '0' COMMENT '神武等级',
  `shenwu_star` int(11) NOT NULL DEFAULT '0' COMMENT '神武星级',
  `shenwu_stone` int(11) NOT NULL DEFAULT '0' COMMENT '神武成功石',
  `shenwu_failnum` int(11) NOT NULL DEFAULT '0' COMMENT '神武升星失败次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神武';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shop_item`
--

DROP TABLE IF EXISTS `tb_player_shop_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shop_item` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `shopitem` int(11) NOT NULL DEFAULT '0' COMMENT '商品ID',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '剩余数量',
  `flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '标识',
  PRIMARY KEY (`charguid`,`shopitem`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='商店表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shortcuts`
--

DROP TABLE IF EXISTS `tb_player_shortcuts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shortcuts` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `shortcut_id` int(11) NOT NULL DEFAULT '0' COMMENT '技能栏ID',
  `shortcut_pos` int(11) NOT NULL COMMENT '技能栏位置',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  `shortcut_type` int(11) NOT NULL DEFAULT '0' COMMENT '技能栏类型',
  PRIMARY KEY (`charguid`,`shortcut_pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='技能栏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shouhun`
--

DROP TABLE IF EXISTS `tb_player_shouhun`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shouhun` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `shouhun_id` int(11) NOT NULL COMMENT '兽魂id',
  `shouhun_level` int(11) NOT NULL COMMENT '兽魂等级',
  `shouhun_star` int(11) NOT NULL COMMENT '兽魂星级',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`shouhun_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兽魂';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_shouhunlv`
--

DROP TABLE IF EXISTS `tb_player_shouhunlv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_shouhunlv` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `shouhun_maxlv` int(11) NOT NULL DEFAULT '0' COMMENT '兽魂最大等阶',
  `shouhun_commonlv` int(11) NOT NULL DEFAULT '0' COMMENT '兽魂所有等级',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兽魂升级表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_sign`
--

DROP TABLE IF EXISTS `tb_player_sign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_sign` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `sign_day` int(32) NOT NULL DEFAULT '0' COMMENT '签到天数',
  `sign_reward0` varchar(10) NOT NULL DEFAULT '0' COMMENT '签到奖励',
  `sign_reward1` varchar(10) NOT NULL DEFAULT '0',
  `sign_reward2` varchar(10) NOT NULL DEFAULT '0',
  `sign_reward3` varchar(10) NOT NULL DEFAULT '0',
  `sign_reward4` varchar(10) NOT NULL DEFAULT '0',
  `level_reward` varchar(64) NOT NULL DEFAULT '0',
  `future_sign` int(11) NOT NULL DEFAULT '0',
  `fill_sign` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='签到表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_skills`
--

DROP TABLE IF EXISTS `tb_player_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_skills` (
  `charguid` bigint(11) NOT NULL COMMENT '角色GUID',
  `skill_id` int(11) NOT NULL COMMENT '技能ID',
  `skill_exp` int(11) NOT NULL DEFAULT '0' COMMENT '技能经验值',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`skill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家技能表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_smelt`
--

DROP TABLE IF EXISTS `tb_player_smelt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_smelt` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `smelt_level` int(11) NOT NULL DEFAULT '0' COMMENT '熔炼等级',
  `smelt_exp` int(11) NOT NULL DEFAULT '0' COMMENT '熔炼经验',
  `smelt_flags` bigint(20) NOT NULL DEFAULT '0' COMMENT '熔炼品质',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家熔炼炉';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_superhole`
--

DROP TABLE IF EXISTS `tb_player_superhole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_superhole` (
  `guid` bigint(20) NOT NULL,
  `pos` int(11) NOT NULL,
  `lv1` int(11) NOT NULL,
  `lv2` int(11) NOT NULL,
  `lv3` int(11) NOT NULL,
  `lv4` int(11) NOT NULL,
  `lv5` int(11) NOT NULL,
  PRIMARY KEY (`guid`,`pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='附加觉醒表(废弃)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_superlib`
--

DROP TABLE IF EXISTS `tb_player_superlib`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_superlib` (
  `id` bigint(20) NOT NULL COMMENT '附加属性GUID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `tid` int(11) NOT NULL COMMENT '附加属性ID',
  `att1` int(11) NOT NULL COMMENT '附加属性值',
  `att2` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `guid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='附加属性库表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_title`
--

DROP TABLE IF EXISTS `tb_player_title`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_title` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `title_id` int(11) NOT NULL DEFAULT '0' COMMENT '称号ID',
  `title_status` int(11) NOT NULL DEFAULT '0' COMMENT '称号状态',
  `title_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '称号到期时间',
  PRIMARY KEY (`charguid`,`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='称号表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_vip`
--

DROP TABLE IF EXISTS `tb_player_vip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_vip` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `vip_exp` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip经验',
  `vip_lvlreward` int(11) NOT NULL DEFAULT '0' COMMENT 'vip等级奖励',
  `vip_weekrewardtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip周奖励领取时间',
  `vip_typelasttime1` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间1',
  `vip_typelasttime2` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间2',
  `vip_typelasttime3` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间3',
  `redpacketcnt` int(11) NOT NULL DEFAULT '0' COMMENT 'VIP特权红包发送次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_vplan`
--

DROP TABLE IF EXISTS `tb_player_vplan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_vplan` (
  `charguid` bigint(20) NOT NULL,
  `newbie_gift_m` tinyint(2) NOT NULL DEFAULT '0',
  `newbie_gift_y` tinyint(2) NOT NULL DEFAULT '0',
  `daily_gift` tinyint(2) NOT NULL DEFAULT '0',
  `title_m` tinyint(2) NOT NULL DEFAULT '0',
  `title_y` tinyint(2) NOT NULL DEFAULT '0',
  `level_gift` varchar(128) NOT NULL DEFAULT '',
  `mail_flag` tinyint(4) NOT NULL DEFAULT '0',
  `consume_gift` varchar(64) NOT NULL DEFAULT '0' COMMENT '消费领奖状态',
  `consume_num` int(11) NOT NULL DEFAULT '0' COMMENT '消费量',
  `consume_time` int(11) NOT NULL DEFAULT '0' COMMENT '消费周期时间',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='V计划表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_wuhuns`
--

DROP TABLE IF EXISTS `tb_player_wuhuns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_wuhuns` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `wuhun_id` int(11) NOT NULL DEFAULT '0' COMMENT '武魂ID',
  `wuhun_wish` int(11) NOT NULL DEFAULT '0' COMMENT '武魂祝福值',
  `trytime` int(11) NOT NULL DEFAULT '0',
  `wuhun_progress` int(11) NOT NULL COMMENT '当前进度',
  `cur_hunzhu` int(11) NOT NULL DEFAULT '0' COMMENT '当前魂值',
  `wuhun_state` int(11) NOT NULL DEFAULT '0' COMMENT '武魂状态',
  `feed_num` int(11) NOT NULL DEFAULT '0' COMMENT '喂养次数',
  `wuhun_sp` int(11) NOT NULL DEFAULT '0',
  `cur_shenshou` int(11) NOT NULL DEFAULT '0',
  `shenshou_data` varchar(128) NOT NULL DEFAULT '',
  `total_proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '总失败次数',
  `fh_item_num` int(11) NOT NULL DEFAULT '0' COMMENT '可返还道具',
  `select_id` int(11) NOT NULL DEFAULT '0' COMMENT '选中灵兽',
  `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
  `fh_level_item_num` bigint(20) NOT NULL DEFAULT '0' COMMENT '可返还道具当前等阶',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='武魂表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_wuxing_item`
--

DROP TABLE IF EXISTS `tb_player_wuxing_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_wuxing_item` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `itemgid` bigint(20) NOT NULL DEFAULT '0' COMMENT '物品ID',
  `itemtid` int(11) NOT NULL DEFAULT '0' COMMENT '物品TID',
  `pos` int(11) NOT NULL DEFAULT '0' COMMENT '位置',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '背包类型',
  `att1` varchar(64) NOT NULL DEFAULT '' COMMENT '属性1',
  `att2` varchar(64) NOT NULL DEFAULT '' COMMENT '属性2',
  `att3` varchar(64) NOT NULL DEFAULT '' COMMENT '属性3',
  `att4` varchar(64) NOT NULL DEFAULT '' COMMENT '属性4',
  `att5` varchar(64) NOT NULL DEFAULT '' COMMENT '属性5',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`itemgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='五行物品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_wuxing_pro`
--

DROP TABLE IF EXISTS `tb_player_wuxing_pro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_wuxing_pro` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
  `lv` int(11) NOT NULL DEFAULT '0' COMMENT '五行等阶',
  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='五行升阶信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_xunbao`
--

DROP TABLE IF EXISTS `tb_player_xunbao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_xunbao` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `playerlvl` int(11) NOT NULL DEFAULT '0' COMMENT '接任务时玩家等级',
  `maptabid1` int(11) NOT NULL DEFAULT '0' COMMENT '随机地图点1',
  `maptabid2` int(11) NOT NULL DEFAULT '0' COMMENT '随机地图点2',
  `passmaptabid` int(11) NOT NULL DEFAULT '0' COMMENT '通过地图点',
  `quality` int(11) NOT NULL DEFAULT '0' COMMENT '品质',
  `times` int(11) NOT NULL DEFAULT '0' COMMENT '已接次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_yaodan`
--

DROP TABLE IF EXISTS `tb_player_yaodan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_yaodan` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `yaodan_id` int(11) NOT NULL DEFAULT '0' COMMENT '妖丹ID',
  `yaodan_today` int(11) NOT NULL DEFAULT '0' COMMENT '当天使用次数',
  `yaodan_total` int(11) NOT NULL DEFAULT '0' COMMENT '累计使用次数',
  PRIMARY KEY (`charguid`,`yaodan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='妖丹表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_yaohun`
--

DROP TABLE IF EXISTS `tb_player_yaohun`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_yaohun` (
  `charguid` bigint(20) NOT NULL DEFAULT '0',
  `yaohun_type` int(11) NOT NULL DEFAULT '0',
  `yaohun_num` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`charguid`,`yaohun_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='妖魂表(废弃)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_yuanling`
--

DROP TABLE IF EXISTS `tb_player_yuanling`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_yuanling` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
  `total_proce` int(11) NOT NULL DEFAULT '0' COMMENT '总失败次数',
  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
  `secs` int(11) NOT NULL DEFAULT '0' COMMENT '在线时间',
  `dianshu` int(11) NOT NULL DEFAULT '0' COMMENT '点数',
  `dunstate` int(11) NOT NULL DEFAULT '0' COMMENT '盾状态',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_zhannu`
--

DROP TABLE IF EXISTS `tb_player_zhannu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_zhannu` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
  `total_proce` int(11) NOT NULL DEFAULT '0' COMMENT '总失败次数',
  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_zhanyin`
--

DROP TABLE IF EXISTS `tb_player_zhanyin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_zhanyin` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `bag` int(11) NOT NULL COMMENT '战印背包',
  `pos` int(11) NOT NULL COMMENT '战印位置',
  `tid` int(11) NOT NULL DEFAULT '0' COMMENT '配置ID',
  `exp` int(11) NOT NULL DEFAULT '0' COMMENT '经验',
  `updatetime` bigint(20) NOT NULL,
  PRIMARY KEY (`charguid`,`bag`,`pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='战印表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_player_zhuzairoad`
--

DROP TABLE IF EXISTS `tb_player_zhuzairoad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_zhuzairoad` (
  `charguid` bigint(20) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '关卡',
  `level_star` int(11) NOT NULL DEFAULT '0' COMMENT '星级',
  `challenge` int(11) NOT NULL DEFAULT '0' COMMENT '挑战次数',
  `buy_num` int(11) NOT NULL DEFAULT '0' COMMENT '购买次数',
  `sweep_state` int(11) NOT NULL DEFAULT '0' COMMENT '扫荡状态',
  `sweep_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '扫荡时间',
  `road_box` varchar(32) NOT NULL DEFAULT '' COMMENT '主宰之路宝箱',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  `sweep_times` int(11) NOT NULL DEFAULT '0' COMMENT '扫荡次数',
  PRIMARY KEY (`charguid`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='主宰之路表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_pvp_season_history`
--

DROP TABLE IF EXISTS `tb_pvp_season_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_pvp_season_history` (
  `seasonid` int(11) NOT NULL DEFAULT '0' COMMENT '赛季ID',
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '排名',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `groupid` int(11) NOT NULL DEFAULT '0' COMMENT '服务器组ID',
  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '战斗力',
  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
  `arms` int(11) NOT NULL DEFAULT '0' COMMENT '武器',
  `dress` int(11) NOT NULL DEFAULT '0' COMMENT '衣服',
  `fashionhead` int(11) NOT NULL DEFAULT '0' COMMENT '时装头',
  `fashionarms` int(11) NOT NULL DEFAULT '0' COMMENT '时装武器',
  `fashiondress` int(11) NOT NULL DEFAULT '0' COMMENT '时装衣服',
  `wuhunid` int(11) NOT NULL DEFAULT '0' COMMENT '武魂ID',
  `wingid` int(11) NOT NULL DEFAULT '0' COMMENT '翅膀ID',
  `suitflag` int(11) NOT NULL DEFAULT '0' COMMENT '时装标识',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名字',
  PRIMARY KEY (`seasonid`,`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='赛季历史记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_crossscore`
--

DROP TABLE IF EXISTS `tb_rank_crossscore`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_crossscore` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '跨服积分',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服段位排行';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_extramity_monster`
--

DROP TABLE IF EXISTS `tb_rank_extramity_monster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_extramity_monster` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '极限挑战杀怪数',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='极限挑战杀怪排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_extremity_boss`
--

DROP TABLE IF EXISTS `tb_rank_extremity_boss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_extremity_boss` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '极限挑战对BOSS伤害',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='极限挑战对BOSS伤害排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_level`
--

DROP TABLE IF EXISTS `tb_rank_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_level` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '等级',
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='等级排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_lingshou`
--

DROP TABLE IF EXISTS `tb_rank_lingshou`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_lingshou` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '灵兽ID',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵兽排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_lingzhen`
--

DROP TABLE IF EXISTS `tb_rank_lingzhen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_lingzhen` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '灵阵等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵阵排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_power`
--

DROP TABLE IF EXISTS `tb_rank_power`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_power` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '战斗力',
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='战斗力排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_realm`
--

DROP TABLE IF EXISTS `tb_rank_realm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_realm` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '境界等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='境界排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_ride`
--

DROP TABLE IF EXISTS `tb_rank_ride`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_ride` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '坐骑等阶',
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='坐骑排行榜表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_ride_dupl`
--

DROP TABLE IF EXISTS `tb_rank_ride_dupl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_ride_dupl` (
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '排名',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `layer` int(11) NOT NULL DEFAULT '0' COMMENT '层数',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '时间',
  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '总战斗力',
  `name_1` varchar(32) NOT NULL DEFAULT '0' COMMENT '队员1',
  `name_2` varchar(32) NOT NULL DEFAULT '0' COMMENT '队员2',
  `name_3` varchar(32) NOT NULL DEFAULT '0' COMMENT '队员3',
  `name_4` varchar(32) NOT NULL DEFAULT '0' COMMENT '队员4',
  `type` int(11) NOT NULL DEFAULT '21' COMMENT '副本类型',
  PRIMARY KEY (`type`,`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='骑战副本排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_rank_shenbing`
--

DROP TABLE IF EXISTS `tb_rank_shenbing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_shenbing` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '神兵等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兵排行';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_relation`
--

DROP TABLE IF EXISTS `tb_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_relation` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `rid` bigint(20) NOT NULL COMMENT '关系GUID',
  `relation_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '关系类型',
  `relation_degree` int(11) NOT NULL DEFAULT '0' COMMENT '友好度',
  `bekill_num` int(11) NOT NULL DEFAULT '0' COMMENT '被击杀数量',
  `recent_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '最近联系时间',
  `kill_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '被击杀时间',
  PRIMARY KEY (`charguid`,`rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_ride`
--

DROP TABLE IF EXISTS `tb_ride`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_ride` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `ride_state` int(11) NOT NULL DEFAULT '0' COMMENT '坐骑状态',
  `ride_process` int(11) NOT NULL DEFAULT '0' COMMENT '坐骑进度',
  `ride_select` int(11) NOT NULL DEFAULT '0',
  `attrdan` int(11) NOT NULL DEFAULT '0',
  `ride_step` int(11) NOT NULL DEFAULT '0' COMMENT '坐骑等阶',
  `proce_num` int(11) NOT NULL DEFAULT '0',
  `total_proce` int(11) NOT NULL DEFAULT '0',
  `fh_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '可返还真气',
  `consum_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '消耗真气 升级后清零',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='坐骑表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_ride_skin`
--

DROP TABLE IF EXISTS `tb_ride_skin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_ride_skin` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `skin_id` int(11) NOT NULL COMMENT '皮肤ID',
  `skin_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '皮肤到期时间',
  PRIMARY KEY (`charguid`,`skin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='坐骑皮肤表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_setting`
--

DROP TABLE IF EXISTS `tb_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_setting` (
  `key_type` int(11) NOT NULL DEFAULT '0' COMMENT 'key_type',
  `value` varchar(128) NOT NULL DEFAULT '' COMMENT 'value',
  PRIMARY KEY (`key_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_soul_info`
--

DROP TABLE IF EXISTS `tb_soul_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_soul_info` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `monsterid` int(11) NOT NULL DEFAULT '0' COMMENT '怪物配置ID',
  `num` int(11) NOT NULL DEFAULT '0' COMMENT '杀怪数量',
  PRIMARY KEY (`charguid`,`monsterid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='噬魂表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_virtual_recharge`
--

DROP TABLE IF EXISTS `tb_virtual_recharge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_virtual_recharge` (
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `account` varchar(32) NOT NULL DEFAULT '' COMMENT '账号',
  `role_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '角色名称',
  `moneys` int(11) NOT NULL DEFAULT '0' COMMENT '钱',
  `oper` varchar(32) NOT NULL DEFAULT '' COMMENT '操作类型',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '时间',
  PRIMARY KEY (`order_id`,`role_id`),
  KEY `time_idx` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='虚拟充值表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_waterdup`
--

DROP TABLE IF EXISTS `tb_waterdup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_waterdup` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家guid',
  `history_wave` int(11) NOT NULL DEFAULT '0' COMMENT '最高波数',
  `history_exp` bigint(20) NOT NULL DEFAULT '0' COMMENT '最高经验',
  `today_count` int(11) NOT NULL DEFAULT '0' COMMENT '已用次数',
  `reward_rate` double NOT NULL DEFAULT '0' COMMENT '经验副本倍率',
  `reward_exp` double NOT NULL DEFAULT '0' COMMENT '经验副本单倍经验',
  `history_kill` double NOT NULL DEFAULT '0' COMMENT '经验副本历史最高杀怪',
  `buy_count` int(11) NOT NULL DEFAULT '0' COMMENT '经验副本道具购买次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='流水副本表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_waterdup_rank`
--

DROP TABLE IF EXISTS `tb_waterdup_rank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_waterdup_rank` (
  `rank` int(11) NOT NULL DEFAULT '0' COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `wave` int(11) NOT NULL DEFAULT '0' COMMENT '波数',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '名称',
  `icon` int(11) NOT NULL DEFAULT '0' COMMENT '头像ID',
  `updatetime` bigint(20) NOT NULL DEFAULT '0' COMMENT '灵路试炼刷新时间',
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='流水副本排行表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_wingstren`
--

DROP TABLE IF EXISTS `tb_wingstren`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_wingstren` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `wing_stren_level` int(11) NOT NULL DEFAULT '0' COMMENT '翅膀强化星级',
  `wing_stren_process` int(11) NOT NULL DEFAULT '0' COMMENT '翅膀强化进度',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='翅膀强化';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_worldboss`
--

DROP TABLE IF EXISTS `tb_worldboss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_worldboss` (
  `id` int(11) NOT NULL COMMENT '世界BOSS活动ID',
  `isdead` int(11) NOT NULL DEFAULT '0' COMMENT 'BOSS是否死亡',
  `lastkiller` bigint(20) NOT NULL DEFAULT '0' COMMENT '击杀者GUID',
  `killername` varchar(64) NOT NULL DEFAULT '' COMMENT '击杀者名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='世界BOSS表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_ws_offline_logic`
--

DROP TABLE IF EXISTS `tb_ws_offline_logic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_ws_offline_logic` (
  `aid` bigint(20) NOT NULL,
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑类型',
  `param_b1` bigint(20) NOT NULL DEFAULT '0' COMMENT '逻辑参数',
  `param_b2` bigint(20) NOT NULL DEFAULT '0',
  `param1` int(11) NOT NULL DEFAULT '0',
  `param2` int(20) NOT NULL DEFAULT '0',
  `param_str` varchar(32) NOT NULL DEFAULT '',
  `save_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '存储时间',
  PRIMARY KEY (`aid`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='离线逻辑表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_zhenbaoge`
--

DROP TABLE IF EXISTS `tb_zhenbaoge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_zhenbaoge` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `zhenbao_id` int(11) NOT NULL DEFAULT '0' COMMENT '珍宝配表ID',
  `submit_times` int(11) NOT NULL DEFAULT '0' COMMENT '提交次数',
  `submit_num` int(11) NOT NULL DEFAULT '0' COMMENT '提交数量 ',
  `item_num1` int(11) NOT NULL DEFAULT '0' COMMENT '物品数量1',
  `item_num2` int(11) NOT NULL DEFAULT '0' COMMENT '物品数量2',
  `item_num3` int(11) NOT NULL DEFAULT '0' COMMENT '物品数量3',
  `submit_once_num` int(11) NOT NULL DEFAULT '0' COMMENT '一次提交次数',
  `zhenbao_process` int(11) NOT NULL DEFAULT '0' COMMENT '珍宝进度',
  `zhenbao_break_num` int(11) NOT NULL DEFAULT '0' COMMENT '珍宝突破次数',
  PRIMARY KEY (`charguid`,`zhenbao_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='珍宝阁表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tb_zhuzairoad_box`
--

DROP TABLE IF EXISTS `tb_zhuzairoad_box`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_zhuzairoad_box` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `road_box` varchar(32) NOT NULL DEFAULT '' COMMENT '宝箱信息',
  `buy_num` int(11) NOT NULL DEFAULT '0' COMMENT '购买精力次数',
  `zhuzairoad_tick` int(11) NOT NULL DEFAULT '0' COMMENT '主宰之路精力值回复时间计数',
  `challenge_count` int(11) NOT NULL DEFAULT '0' COMMENT '主宰之路挑战共享次数',
  `roadlv_max` int(11) NOT NULL DEFAULT '0' COMMENT '主宰之路挑战最高等级',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='主宰之路宝箱表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'venus'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_account_adult_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_account_adult_update`(IN `in_charguid` bigint,  IN `in_adult` int)
BEGIN
	UPDATE tb_account SET  adult = in_adult	WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_account_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_account_create`(IN `in_account` varchar(64), IN `in_groupid` int, IN `in_guid` bigint, IN `in_timestamp` bigint, IN `in_ip` varchar(32), IN `in_mac` varchar(32))
BEGIN
	INSERT INTO tb_account(account, groupid, charguid, create_time, last_login, last_logout, last_ip, last_mac)
	VALUES(in_account, in_groupid, in_guid, FROM_UNIXTIME(in_timestamp), FROM_UNIXTIME(in_timestamp), FROM_UNIXTIME(in_timestamp), in_ip, in_mac);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_account_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_account_select`(IN `in_account` varchar(64), IN `in_groupid` int)
BEGIN
	SELECT account, groupid, charguid, valid, forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, UNIX_TIMESTAMP(last_logout) as last_logout, UNIX_TIMESTAMP(last_login) as last_login, UNIX_TIMESTAMP(create_time) as create_time
	FROM tb_account WHERE account = in_account AND groupid = in_groupid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_account_select_by_guid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_account_select_by_guid`(IN `in_charguid` bigint)
BEGIN
	SELECT account, groupid, charguid, valid, forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, adult,
		 UNIX_TIMESTAMP(last_logout) as last_logout, UNIX_TIMESTAMP(last_login) as last_login, UNIX_TIMESTAMP(create_time) as create_time,
		 gm_flag, welfare, forb_type, lock_reason
	FROM tb_account WHERE charguid = in_charguid ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_activity_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_activity_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_activity WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_activity_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64))
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_change_pvp_lv` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_change_pvp_lv`(IN `in_charguid` bigint, IN `in_lv` int)
BEGIN
	UPDATE tb_player_info SET pvplevel = in_lv WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_change_role_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_change_role_name`(IN `in_charguid` bigint, IN `in_name` varchar(64))
BEGIN
	UPDATE tb_player_info SET name = in_name WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_check_forb_mac` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_check_forb_mac`(IN `in_mac` varchar(32))
BEGIN
	SELECT * FROM tb_forb_mac WHERE mac = in_mac;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_check_role_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_check_role_name`(IN `in_name` varchar(32))
BEGIN
	select * from tb_player_info where name = in_name;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_check_user_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_check_user_account`(IN `in_account` varchar(32), IN `in_groupid` int)
BEGIN
	SELECT charguid, last_logout, create_time, valid  FROM tb_account
	WHERE account = in_account AND groupid = in_groupid; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_check_user_playerinfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_check_user_playerinfo`(IN `in_charguid` bigint(20))
BEGIN
	SELECT name, online_time, prof, level, exp  FROM tb_player_info
	WHERE charguid = in_charguid; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_consignment_item_delete_by_playerid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_consignment_item_delete_by_playerid`(IN `in_gid` bigint)
BEGIN
	delete from tb_consignment_items where char_guid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_consignment_item_delete_by_saleid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_consignment_item_delete_by_saleid`(IN `in_gid` bigint)
BEGIN
	delete from tb_consignment_items where sale_guid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_consignment_record_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_consignment_record_delete_by_id`(IN `in_gid` bigint)
BEGIN
	delete from tb_consignment_record where record_guid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_consignment_record_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_consignment_record_insert_update`( IN `in_record_guid` bigint, IN `in_char_guid` bigint,
														IN `in_item_id` int, IN `in_item_count` int,
														IN `in_sale_time` bigint, IN `in_gain_money` int,
														IN `in_buy_char_name` varchar(64))
BEGIN
	INSERT INTO tb_consignment_record(record_guid, char_guid, item_id, item_count, sale_time, gain_money, buy_char_name)
	VALUES (in_record_guid, in_char_guid, in_item_id, in_item_count, in_sale_time, in_gain_money, in_buy_char_name)
	ON DUPLICATE KEY UPDATE 
	record_guid=in_record_guid, char_guid=in_char_guid, item_id=in_item_id,item_count=in_item_count,sale_time=in_sale_time,
	gain_money=in_gain_money, buy_char_name = in_buy_char_name;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_consignment_record_select_by_playerid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_consignment_record_select_by_playerid`(IN `in_gid` bigint)
BEGIN
	SELECT * from tb_consignment_record where char_guid = in_gid order by sale_time desc; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_aura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_aura`(IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_aura where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_cross_arena_xiazhu` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_cross_arena_xiazhu`(IN `in_seasonid` int)
BEGIN
	DELETE FROM tb_crossarena_xiazhu WHERE seasonid = in_seasonid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_equip_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_equip_by_id`(IN `in_uid` bigint)
BEGIN
	DELETE FROM tb_player_equips WHERE charguid = in_uid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_equip_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_equip_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_equips` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_extremity_by_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_extremity_by_timestamp`(IN `in_time_stamp` bigint)
BEGIN
	delete from tb_extremity_rank where time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_guild_aliance_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_guild_aliance_applys`(IN `in_gid` bigint, IN `in_applygid` bigint)
BEGIN
	DELETE FROM tb_guild_aliance_apply where gid = in_gid and applygid = in_applygid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_guild_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_guild_applys`(IN `in_charguid` bigint, IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_guild_apply where charguid = in_charguid and gid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_guild_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_guild_item`(IN `in_guid` bigint)
BEGIN
	DELETE FROM tb_guild_storage WHERE itemgid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_guild_palace_sign` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_guild_palace_sign`(IN `in_id` int)
BEGIN
	delete FROM tb_guild_palace_sign where id = in_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_item_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_item_by_id`(IN `in_uid` bigint)
BEGIN
	DELETE FROM tb_player_items WHERE charguid = in_uid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_item_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_item_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_items` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_mail_info_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_mail_info_by_id`(IN `in_charguid` bigint, IN `in_mailgid` bigint)
BEGIN
	DELETE FROM tb_mail_content WHERE mailgid = in_mailgid AND refflag = 0;
	IF row_count() > 0 THEN
		DELETE FROM tb_mail WHERE charguid = in_charguid AND mailgid = in_mailgid;
	ELSE
		UPDATE tb_mail SET deleteflag = 1 WHERE charguid = in_charguid AND mailgid = in_mailgid;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_player_quests_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_player_quests_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_quests` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_ws_offlogic` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_delete_ws_offlogic`(IN `in_aid` bigint)
BEGIN
	DELETE FROM tb_ws_offline_logic where aid = in_aid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_del_disciple` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_del_disciple`(IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_player_disciple WHERE gid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_del_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_del_hl_quest`(IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_homeland_quest WHERE gid = in_gid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_del_player_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_del_player_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_hl_quest WHERE gid = in_gid and charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_dimiss_guild` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_dimiss_guild`(IN `in_guid` bigint)
BEGIN
	DELETE FROM tb_guild WHERE gid = in_guid;
	UPDATE tb_guild_mem SET gid = 0, allcontribute = 0, loyalty = 0 WHERE gid = in_guid;
	DELETE FROM tb_guild_event WHERE guid = in_guid;
	DELETE FROM tb_guild_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_aliance_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_storage WHERE gid = in_guid;
	DELETE FROM tb_guild_storage_op WHERE gid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_exchange_record_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_exchange_record_insert_update`(IN `in_order_id` varchar(32), IN `in_uid` varchar(32), IN `in_role_id` bigint, 
	IN `in_platform` int, IN `in_money` int, IN `in_coins` int, IN `in_time` int, IN `in_recharge` int)
BEGIN
  INSERT INTO tb_exchange_record(order_id, uid, role_id, platform, money, coins, time, recharge)
  VALUES (in_order_id, in_uid, in_role_id, in_platform, in_money, in_coins, in_time, in_recharge);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_exchange_record_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_exchange_record_select`(IN `in_order_id` varchar(32))
BEGIN
 	SELECT * FROM tb_exchange_record
 	WHERE order_id = in_order_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_forb_mac_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_forb_mac_list`()
BEGIN
	SELECT * FROM tb_forb_mac;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_db_version` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_get_db_version`()
BEGIN
	SELECT MAX(version) as Ver FROM tb_database_version;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_oper_insert` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_oper_insert`(IN `in_gid` bigint, IN `in_oper` varchar(32), IN `in_time` int, IN `in_errno` varchar(32),
							IN `in_errmsg` varchar(32), IN `in_type` varchar(32), IN `in_post_data` varchar(256))
BEGIN
  INSERT INTO tb_gm_oper(gid, oper, time, errno, errmsg, type, post_data)
  VALUES (in_gid, in_oper, in_time, in_errno, in_errmsg, in_type, in_post_data);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_oper_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_oper_select`(IN `in_type` varchar(32), IN `in_time1` int, IN `in_time2` int)
BEGIN
 	SELECT * FROM tb_gm_oper
 	WHERE `type` like in_type AND `time` > in_time1 AND `time` < in_time2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_forb_acc_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_forb_acc_list`(IN `in_cur` int)
BEGIN
	SELECT *, (forb_acc_time + forb_acc_last) AS last_time FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE forb_acc_time + forb_acc_last > in_cur;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_forb_chat_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_forb_chat_list`(IN `in_cur` int)
BEGIN
	SELECT *, (forb_chat_time + forb_chat_last) AS last_time FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE forb_chat_time + forb_chat_last > in_cur;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_forb_mac_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_forb_mac_list`(IN `in_cur` int)
BEGIN
	SELECT *, (0) AS last_time FROM tb_forb_mac left join tb_account
	on tb_forb_mac.charguid = tb_account.charguid
	left join tb_player_info
	on tb_player_info.charguid = tb_account.charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_base` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_base`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_account AS A, tb_player_info AS P, tb_player_map_info AS M 
	WHERE A.charguid = in_guid AND P.charguid = in_guid AND M.charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_by_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_by_name`(IN `in_name` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE name = in_name;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_list_by_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_list_by_account`(IN `in_account` VARCHAR(32))
BEGIN
	SELECT tb_player_info.charguid, account, name FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE account like in_account;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_list_by_guid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_list_by_guid`(IN `in_guid` bigint)
BEGIN
	SELECT tb_player_info.charguid, account, name FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE tb_player_info.charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_list_by_ip` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_list_by_ip`(IN `in_last_ip` VARCHAR(32))
BEGIN
	SELECT tb_player_info.charguid, account, name FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE last_ip like in_last_ip;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_gm_select_role_list_by_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_gm_select_role_list_by_name`(IN `in_name` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE name like in_name;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_guild_boss_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_guild_boss_select`()
BEGIN
	SELECT * FROM tb_guild_boss;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_guild_citywar_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_guild_citywar_select_by_id`(IN `in_id` int)
BEGIN
	SELECT * FROM tb_guild_citywar WHERE id = in_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_guild_events` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_guild_events`(IN `in_aid` bigint, IN `in_guid` bigint, IN `in_cfgid` int, IN `in_time` bigint, IN `in_param` varchar(64))
BEGIN
	INSERT INTO tb_guild_event(aid, guid, cfgid, time, param)
	VALUES (in_aid, in_guid, in_cfgid, in_time, in_param);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_or_update_player_pvp_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_or_update_player_pvp_info`(IN `in_charguid` bigint, IN `in_curcnt` int, IN `in_totalcnt` int, IN `in_wincnt` int,
IN `in_contwincnt` int, IN `in_flags` int)
BEGIN
	INSERT INTO tb_player_crosspvp(charguid, curcnt, totalcnt, wincnt, contwincnt, flags)
	VALUES (in_charguid, in_curcnt, in_totalcnt, in_wincnt, in_contwincnt, in_flags) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, curcnt=in_curcnt, totalcnt = in_totalcnt, 
	wincnt = in_wincnt, contwincnt = in_contwincnt, flags = in_flags;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_or_update_pvphistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_or_update_pvphistory`(IN `in_seasonid` int, IN `in_rank` int, IN `in_charguid` bigint, IN `in_groupid` int,
IN `in_power` bigint, IN `in_prof` int, IN `in_arms` int, IN `in_dress` int, IN `in_fashionhead` int, IN `in_fashionarms` int,
IN `in_fashiondress` int, IN `in_wuhunid` int, IN `in_wingid` int, IN `in_suitflag` int, IN `in_name` varchar(32))
BEGIN
	INSERT INTO tb_pvp_season_history(seasonid, rank, charguid, groupid, power, prof,
								arms, dress, fashionhead, fashionarms, fashiondress, wuhunid, wingid, 
								suitflag, name)
	VALUES (in_seasonid, in_rank, in_charguid, in_groupid, in_power, in_prof,
			in_arms, in_dress, in_fashionhead, in_fashionarms, in_fashiondress, in_wuhunid, in_wingid, 
			in_suitflag, in_name) 
	ON DUPLICATE KEY UPDATE seasonid=in_seasonid, rank=in_rank, charguid = in_charguid, groupid = in_groupid, power = in_power,
		prof=in_prof, arms=in_arms, dress=in_dress, fashionhead=in_fashionhead, fashionarms=in_fashionarms, fashiondress=in_fashiondress, wuhunid=in_wuhunid, 
		wingid=in_wingid, suitflag=in_suitflag, name = in_name;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_achievement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_achievement`(IN `in_guid` bigint, IN `in_id` int, IN `in_param1` int, IN `in_param2` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_achievement(charguid, id, param1, param2, time_stamp)
	VALUES (in_guid, in_id, in_param1, in_param2, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_guid, id = in_id, param1 = in_param1, param2 = in_param2, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_actpet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_actpet`(IN `in_charguid` bigint,IN `in_actpet_id` int,
	IN `in_actpet_state` int, IN `in_actpet_time` int, IN `in_time_stamp` bigint)
BEGIN
		INSERT INTO tb_player_actpet(charguid, actpet_id, actpet_state, actpet_time, time_stamp)
		VALUES (in_charguid,in_actpet_id, in_actpet_state, in_actpet_time, in_time_stamp) 
		ON DUPLICATE KEY UPDATE charguid=in_charguid, actpet_id = in_actpet_id,	
		   actpet_state = in_actpet_state, actpet_time = in_actpet_time, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_arena` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_arena`(IN `in_charguid` bigint,  IN `in_rank` int, IN `in_lastrank` int, 
IN `in_challtime` int, IN `in_conwincnt` int, IN `in_totalgold` int, IN `in_totalhonor` int, 
IN `in_reward_time` bigint, IN `in_cooldown_time` bigint, IN `in_newday_time` bigint, IN `in_buy_challtime` int)
BEGIN
	INSERT INTO tb_arena(charguid, rank, lastrank, challtime, conwincnt, totalgold, totalhonor, reward_time, cooldown_time, newday_time, buy_challtime)
	VALUES (in_charguid, in_rank, in_lastrank, in_challtime, in_conwincnt, in_totalgold, in_totalhonor, in_reward_time, in_cooldown_time, in_newday_time, in_buy_challtime) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, rank=in_rank, lastrank=in_lastrank, challtime=in_challtime, 
	conwincnt=in_conwincnt, totalgold=in_totalgold, totalhonor=in_totalhonor, reward_time=in_reward_time, 
	cooldown_time = in_cooldown_time, newday_time = in_newday_time, buy_challtime = in_buy_challtime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_arena_att` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_arena_att`(IN `in_charguid` bigint, IN `in_atk` double, IN `in_hp` double, IN `in_hit` double, IN `in_dodge` double, IN `in_subdef` double
, IN `in_def` double, IN `in_cri` double, IN `in_crivalue` double, IN `in_absatk` double, IN `in_defcri` double, IN `in_subcri` double, IN `in_parryvalue` double
, IN `in_dmgsub` double, IN `in_dmgadd` double, IN `in_skill1` int, IN `in_skill2` int, IN `in_skill3` int, IN `in_skill4` int, IN `in_skill5` int, IN `in_skill6` int
, IN `in_skill7` int, IN `in_skill8` int, IN `in_skill9` int, IN `in_skill10` int, IN `in_parryrate` double, IN `in_supper` double, IN `in_suppervalue` double)
BEGIN
  INSERT INTO tb_arena_att(charguid, atk, hp, hit, dodge, subdef, def, cri, crivalue, absatk, defcri, subcri, parryvalue, dmgsub, dmgadd,
	skill1, skill2, skill3, skill4, skill5, skill6, skill7, skill8, skill9, skill10, parryrate, supper, suppervalue)
	VALUES (in_charguid, in_atk, in_hp, in_hit, in_dodge, in_subdef, in_def, in_cri, in_crivalue, in_absatk, in_defcri,
	in_subcri, in_parryvalue, in_dmgsub, in_dmgadd, in_skill1, in_skill2, in_skill3, in_skill4, in_skill5, in_skill6,
	in_skill7, in_skill8, in_skill9, in_skill10, in_parryrate, in_supper, in_suppervalue)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, atk=in_atk, hp=in_hp, hit=in_hit, dodge=in_dodge, 
	subdef=in_subdef, def=in_def, cri=in_cri, crivalue=in_crivalue, absatk=in_absatk, defcri=in_defcri, subcri=in_subcri, parryvalue=in_parryvalue,
	dmgsub=in_dmgsub, dmgadd=in_dmgadd, skill1=in_skill1, skill2=in_skill2, skill3=in_skill3, skill4=in_skill4, skill5=in_skill5, skill6=in_skill6,
	skill7=in_skill7, skill8=in_skill8, skill9=in_skill9, skill10=in_skill10, parryrate=in_parryrate, supper=in_supper, suppervalue=in_suppervalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_arena_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_arena_event`(IN `in_aid` bigint, IN `in_charguid` bigint,  IN `in_cfgid` int, IN `in_time` bigint, IN `in_param` varchar(64))
BEGIN
	INSERT INTO tb_arena_event(aid, charguid, cfgid, time, param)
	VALUES (in_aid, in_charguid, in_cfgid, in_time, in_param);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_consignment_items` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_consignment_items`(IN `in_sale_guid` bigint, 
													  IN `in_player_guid` bigint, 
													  IN `in_item_type` int,
													  IN `in_item_tid` int, 
													  IN `in_item_count` int, 
													  IN `in_sale_time` bigint,
													  IN `in_price` int,
													  IN `in_price_type` int)
BEGIN
	INSERT INTO tb_consignment_items(sale_guid,player_guid,item_type,item_tid,item_count,
						sale_time,price,price_type)
	VALUES(in_sale_guid,in_player_guid, in_item_type, in_item_tid, in_item_count, in_sale_time,
				in_price,in_price_type)
	ON DUPLICATE KEY UPDATE sale_guid=in_sale_guid, player_guid = in_player_guid,
			item_type=in_item_type, item_tid = in_item_tid, item_count=in_item_count,
			sale_time=in_sale_time,price=in_price,price_type=in_price_type;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_daily_buy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_daily_buy`(
		IN `in_charguid` bigint, IN `in_buy_exp` int, IN `in_buy_lingli` int, IN `in_buy_silver` int)
BEGIN
	INSERT INTO tb_daily_buy(charguid, buy_exp, buy_lingli, buy_silver)
	VALUES (in_charguid, in_buy_exp, in_buy_lingli, in_buy_silver)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, buy_exp = in_buy_exp, buy_lingli = in_buy_lingli, buy_silver = in_buy_silver;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_gem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_gem`(IN `in_charguid` bigint,  IN `in_gemid` int, IN `in_level` int)
BEGIN
  INSERT INTO tb_gem_info(charguid, gemid, level)
  VALUES (in_charguid, in_gemid, in_level) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, gemid=in_gemid, level=in_level;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_guild` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_guild`(IN `in_gid` bigint, IN `in_capital` double, IN `in_name` varchar(50), IN `in_notice` varchar(256), IN `in_level` int,
IN `in_flag` int, IN `in_count1` int, IN `in_count2` int, IN `in_count3` int, IN `in_create_time` bigint, IN `in_alianceid` bigint, IN `in_liveness` int,
IN `in_extendnum` int, IN `in_statuscnt` int)
BEGIN
	INSERT INTO tb_guild(gid, capital, name, notice, level, flag, count1, count2, count3, create_time, alianceid, liveness, extendnum, statuscnt)
	VALUES (in_gid, in_capital, in_name, in_notice, in_level, in_flag, in_count1, in_count2, in_count3, in_create_time, in_alianceid, in_liveness, in_extendnum, in_statuscnt)
	ON DUPLICATE KEY UPDATE gid = in_gid, capital = in_capital, name = in_name, notice = in_notice, level = in_level, 
	flag = in_flag, count1 = in_count1, count2 = in_count2, count3 = in_count3, create_time=in_create_time, alianceid=in_alianceid, 
	liveness = in_liveness, extendnum = in_extendnum, statuscnt = in_statuscnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_guild_aliance_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_guild_aliance_applys`(IN `in_gid` bigint, IN `in_applygid` bigint, IN `in_time` bigint)
BEGIN
	INSERT INTO tb_guild_aliance_apply(gid, applygid, time)
	VALUES (in_gid, in_applygid, in_time)
	ON DUPLICATE KEY UPDATE gid = in_gid, applygid = in_applygid, time = in_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_guild_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_guild_applys`(IN `in_charguid` bigint, IN `in_gid` bigint, IN `in_time` bigint)
BEGIN
	INSERT INTO tb_guild_apply(charguid, gid, time)
	VALUES (in_charguid, in_gid, in_time)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, gid = in_gid, time = in_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_guild_mems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_guild_mems`(IN `in_charguid` bigint, IN `in_gid` bigint, IN `in_flags` bigint, IN `in_time` bigint, 
IN `in_contribute` int, IN `in_allcontribute` int, IN `in_skillflag` int, IN `in_pos` int, IN `in_addlv` int, IN `in_atk` int, 
IN `in_def` int, IN `in_hp` int, IN `in_subdef` int, IN `in_worships` int, IN `in_loyalty` int)
BEGIN
	INSERT INTO tb_guild_mem(charguid, gid, flags, time, contribute, allcontribute, 
		skillflag, pos, addlv, atk, def, hp, subdef, worships, loyalty)
	VALUES (in_charguid, in_gid, in_flags, in_time, in_contribute, in_allcontribute, 
		in_skillflag, in_pos, in_addlv, in_atk, in_def, in_hp, in_subdef, in_worships, in_loyalty)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, gid = in_gid, flags = in_flags, time = in_time, contribute = in_contribute, 
	allcontribute = in_allcontribute, skillflag = in_skillflag, pos = in_pos, addlv = in_addlv, atk = in_atk, 
	def = in_def, hp = in_hp, subdef = in_subdef, worships = in_worships, loyalty = in_loyalty;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_killtask` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_killtask`(IN `in_charguid` bigint, IN `in_level` int, IN `in_level_count` int)
BEGIN
	INSERT INTO tb_killtask(charguid, level, level_count)
	VALUES (in_charguid, in_level, in_level_count) 
	ON DUPLICATE KEY UPDATE  level = in_level, level_count = in_level_count;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_lingshoumudi` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_lingshoumudi`(	IN `in_charguid` bigint,IN `in_today_layer` int,
	IN `in_history_layer` int, IN `in_history_reward_state` int)
BEGIN
		INSERT INTO tb_lingshoumudi(charguid, today_layer, history_layer, history_reward_state)
		VALUES (in_charguid,in_today_layer, in_history_layer, in_history_reward_state) 
		ON DUPLICATE KEY UPDATE charguid=in_charguid, 
								today_layer=in_today_layer,
								history_layer = in_history_layer,
								history_reward_state = in_history_reward_state;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_lingshoumudi_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_lingshoumudi_rank`(IN `in_rank` int,IN `in_charguid` bigint,
	IN `in_player_name` varchar(32),IN `in_layer` int,IN `in_rank_time` bigint, IN `in_prof` int)
BEGIN
	INSERT INTO `tb_lingshoumudi_rank` (rank, charguid, player_name, layer, rank_time, prof)
	VALUES (in_rank,in_charguid, in_player_name, in_layer, in_rank_time, in_prof) 
	ON DUPLICATE KEY UPDATE 	rank=in_rank, 
								charguid=in_charguid,
								player_name = in_player_name,
								layer = in_layer,
								rank_time = in_rank_time,
								prof = in_prof;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_onlinereward` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_onlinereward`(IN `in_charguid` bigint,  IN `in_draw_id` int, IN `in_draw_level` int, IN `in_draw_index` int)
BEGIN
	INSERT INTO tb_player_onlinereward(charguid, draw_id, draw_level, draw_index)
	VALUES (in_charguid, in_draw_id, in_draw_level, in_draw_index)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, draw_id=in_draw_id, draw_level=in_draw_level, draw_index=in_draw_index;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_player_ls_horse` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_player_ls_horse`(IN `in_charguid` bigint, IN `in_lshorse_step` int,
IN `in_lshorse_process` int, IN `in_lshorse_procenum` int, IN `in_lshorse_totalproce` int, IN `in_lshorse_attr` int)
BEGIN
	INSERT INTO tb_player_ls_horse(charguid, lshorse_step, lshorse_process, lshorse_procenum, lshorse_totalproce, lshorse_attr)
	VALUES (in_charguid, in_lshorse_step, in_lshorse_process, in_lshorse_procenum, in_lshorse_totalproce, in_lshorse_attr) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lshorse_step = in_lshorse_step,	lshorse_process = in_lshorse_process,
	 lshorse_procenum = in_lshorse_procenum, lshorse_totalproce = in_lshorse_totalproce, lshorse_attr = in_lshorse_attr;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_player_personboss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_player_personboss`(IN `in_charguid` bigint, IN `in_id` int,
IN `in_cur_count` int, IN `in_first` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_personboss(charguid, id, cur_count, first, time_stamp)
	VALUES (in_charguid, in_id, in_cur_count, in_first, in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, id = in_id,	cur_count = in_cur_count, first = in_first,
	 time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_player_vplan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_player_vplan`(
	IN `in_charguid` bigint, 
	IN `in_newbie_gift_m` tinyint, 
	IN `in_newbie_gift_y` tinyint, 
	IN `in_daily_gift` tinyint, 
	IN `in_title_m` tinyint, 
	IN `in_title_y` tinyint, 
	IN `in_level_gift` varchar(128),
	IN `in_mail_flag` tinyint,
	IN `in_consume_gift` varchar(64),
	IN `in_consume_num` int,
	IN `in_consume_time` int)
BEGIN
  INSERT INTO tb_player_vplan(charguid, newbie_gift_m, newbie_gift_y, daily_gift, 
  	title_m, title_y, level_gift, mail_flag, consume_gift, consume_num, consume_time)
  VALUES (in_charguid, in_newbie_gift_m, in_newbie_gift_y, in_daily_gift, 
  	in_title_m, in_title_y, in_level_gift, in_mail_flag, in_consume_gift, in_consume_num, in_consume_time)
  ON DUPLICATE KEY UPDATE newbie_gift_m = in_newbie_gift_m, newbie_gift_y = in_newbie_gift_y, daily_gift = in_daily_gift, 
  title_m = in_title_m, title_y = in_title_y, level_gift = in_level_gift, mail_flag = in_mail_flag,
  consume_gift = in_consume_gift, consume_num = in_consume_num, consume_time = in_consume_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_ride` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_ride`(IN `in_charguid` bigint, IN `in_step` int, IN `in_select` int, IN `in_state` int, IN `in_process` int,
			IN `in_attrdan` int, IN `in_proce_num` int, IN `in_total_proce` int, IN `in_fh_zhenqi` bigint, IN `in_consum_zhenqi` bigint)
BEGIN
	INSERT INTO tb_ride(charguid, ride_step, ride_select, ride_state, ride_process, attrdan, proce_num, total_proce,fh_zhenqi,consum_zhenqi)
	VALUES (in_charguid, in_step, in_select, in_state, in_process, in_attrdan,in_proce_num, in_total_proce,in_fh_zhenqi,in_consum_zhenqi)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ride_step=in_step, ride_select = in_select, ride_state = in_state, ride_process = in_process, 
		attrdan=in_attrdan, proce_num=in_proce_num, total_proce=in_total_proce, fh_zhenqi=in_fh_zhenqi, consum_zhenqi=in_consum_zhenqi;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_ridewar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_ridewar`(IN `in_charguid` bigint, IN `in_ridewar_id` int,
IN `in_ridewar_wish` int, IN `in_ridewar_procenum` int, IN `in_ridewar_attrnum` int, IN `in_ridewar_skin` int)
BEGIN
	INSERT INTO tb_player_ridewar(charguid, ridewar_id, ridewar_wish, ridewar_procenum, ridewar_attrnum, ridewar_skin)
	VALUES (in_charguid, in_ridewar_id, in_ridewar_wish, in_ridewar_procenum, in_ridewar_attrnum, in_ridewar_skin) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ridewar_id = in_ridewar_id,	ridewar_wish = in_ridewar_wish,
	 ridewar_procenum = in_ridewar_procenum, ridewar_attrnum = in_ridewar_attrnum, ridewar_skin = in_ridewar_skin;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_sign` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_sign`(IN `in_charguid` bigint,  IN `in_sign_day` int, IN `in_sign_reward0` varchar(10), IN `in_sign_reward1` varchar(10),
IN `in_sign_reward2` varchar(10), IN `in_sign_reward3` varchar(10), IN `in_sign_reward4` varchar(10), IN `in_level_reward` varchar(64), IN `in_future_sign` int, IN `in_fill_sign` int)
BEGIN
	INSERT INTO tb_player_sign(charguid, sign_day, sign_reward0, sign_reward1, sign_reward2, sign_reward3, sign_reward4, level_reward,future_sign,fill_sign)
	VALUES (in_charguid, in_sign_day, in_sign_reward0, in_sign_reward1, in_sign_reward2, in_sign_reward3, in_sign_reward4, in_level_reward,in_future_sign,in_fill_sign)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, sign_day=in_sign_day, sign_reward0=in_sign_reward0, sign_reward1=in_sign_reward1, sign_reward2=in_sign_reward2, 
	sign_reward3=in_sign_reward3, sign_reward4=in_sign_reward4, level_reward=in_level_reward,future_sign=in_future_sign,fill_sign=in_fill_sign;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_insert_update_smelt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_insert_update_smelt`(IN `in_charguid` bigint, IN `in_smelt_level` int, IN `in_smelt_exp` int,
 IN `in_smelt_flags` bigint)
BEGIN
	INSERT INTO tb_player_smelt(charguid,smelt_level,smelt_exp,smelt_flags)
	VALUES (in_charguid,in_smelt_level,in_smelt_exp,in_smelt_flags) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, smelt_level=in_smelt_level, 
	smelt_exp=in_smelt_exp, smelt_flags=in_smelt_flags;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_load_all_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_load_all_hl_quest`()
BEGIN
	SELECT * FROM tb_homeland_quest;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_lunpan_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_lunpan_insert_update`(IN `in_charguid` bigint,  IN `in_lunpan_attr` varchar(128), IN `in_lunpan_num` int)
BEGIN
	INSERT INTO tb_player_lunpan(charguid, lunpan_attr, lunpan_num)
	VALUES (in_charguid, in_lunpan_attr, in_lunpan_num)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, lunpan_attr=in_lunpan_attr, lunpan_num = in_lunpan_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mail_content_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mail_content_insert_update`(IN `in_mailgid` bigint, IN `in_refflag` tinyint, IN `in_title` varchar(50), IN `in_content` varchar(512), IN `in_sendtime` bigint, IN `in_validtime` bigint, 
IN `in_item1` int, IN `in_itemnum1` bigint,IN `in_item2` int, IN `in_itemnum2` bigint,IN `in_item3` int, IN `in_itemnum3` bigint,IN `in_item4` int, IN `in_itemnum4` bigint,
IN `in_item5` int, IN `in_itemnum5` bigint,IN `in_item6` int, IN `in_itemnum6` bigint,IN `in_item7` int, IN `in_itemnum7` bigint,IN `in_item8` int, IN `in_itemnum8` bigint,
IN `in_param1` int, IN `in_param2` int, IN `in_paramb1` bigint, IN `in_paramb2` bigint)
BEGIN
	INSERT INTO tb_mail_content(mailgid, refflag, title, content, sendtime, validtime, 
	item1, itemnum1, item2, itemnum2, item3, itemnum3, item4, itemnum4, 
	item5, itemnum5, item6, itemnum6, item7, itemnum7, item8, itemnum8,
	param1, param2, paramb1, paramb2)
	VALUES (in_mailgid, in_refflag, in_title, in_content, in_sendtime, in_validtime,
	in_item1, in_itemnum1, in_item2, in_itemnum2, in_item3, in_itemnum3, in_item4, in_itemnum4, 
	in_item5, in_itemnum5, in_item6, in_itemnum6, in_item7, in_itemnum7, in_item8, in_itemnum8,
	in_param1, in_param2, in_paramb1, in_paramb2)
	ON DUPLICATE KEY UPDATE mailgid = in_mailgid, refflag = in_refflag, title = in_title, content = in_content, sendtime = in_sendtime, validtime =  in_validtime,
	item1 = in_item1, itemnum1 = in_itemnum1, item2 = in_item2, itemnum2 = in_itemnum2, item3 = in_item3, itemnum3 = in_itemnum3, item4 = in_item4, itemnum4 = in_itemnum4, 
	item5 = in_item5, itemnum5 = in_itemnum5, item6 = in_item6, itemnum6 = in_itemnum6, item7 = in_item7, itemnum7 = in_itemnum7, item8 = in_item8, itemnum8 = in_itemnum8,
	param1 = in_param1, param2 = in_param2, paramb1 = in_paramb1, paramb2 = in_paramb2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_mail_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_mail_insert_update`(IN `in_charguid` bigint, IN `in_mailgid` bigint, IN `in_readflag` tinyint, IN `in_deleteflag` tinyint, IN `in_recvflag` tinyint)
BEGIN
	INSERT INTO tb_mail(charguid, mailgid, readflag, deleteflag, recvflag)
	VALUES (in_charguid, in_mailgid, in_readflag, in_deleteflag, in_recvflag)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, mailgid = in_mailgid, readflag = in_readflag, deleteflag = in_deleteflag, recvflag = in_recvflag;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_platform_select_create_role_list_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_platform_select_create_role_list_info`(IN `in_date` VARCHAR(32),IN `in_begin` int,IN `in_num` int)
BEGIN
	select *, (select count(*) from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(create_time) = TO_DAYS(in_date)) as c
from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(create_time) = TO_DAYS(in_date) limit in_begin,in_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_platform_select_login_role_list_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_platform_select_login_role_list_info`(IN `in_date` VARCHAR(32),IN `in_begin` int,IN `in_num` int)
BEGIN
	select *, (select count(*) from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(last_login) = TO_DAYS(in_date)) as c
from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(last_login) = TO_DAYS(in_date) limit in_begin,in_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_platform_select_role_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_platform_select_role_info`(IN `in_account` VARCHAR(32), IN `in_groupid` int)
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account and groupid = in_groupid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_platform_select_role_little_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_platform_select_role_little_info`(IN `in_account` VARCHAR(32), IN `in_groupid` int)
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account and groupid = in_groupid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_actpet_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_actpet_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_actpet` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_adventure_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_adventure_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_adventure WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_adventure_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_adventure_insert_update`(IN `in_charguid` bigint, IN `in_id` int, IN `in_eventid` int, IN `in_state` int,
IN `in_cnt` int, IN `in_param1` int, IN `in_parma2` int, IN `in_zhuoyueguide_flags` bigint, IN `in_zhuoyueguide_info` varchar(128))
BEGIN
	INSERT INTO tb_player_adventure(charguid, id, eventid, state, cnt, param1, parma2, zhuoyueguide_flags, zhuoyueguide_info)
	VALUES (in_charguid, in_id, in_eventid, in_state, in_cnt, in_param1, in_parma2, in_zhuoyueguide_flags, in_zhuoyueguide_info)
	ON DUPLICATE KEY UPDATE 
	charguid=in_charguid, id=in_id, eventid=in_eventid,state=in_state,cnt=in_cnt,
	param1=in_param1,parma2=in_parma2,zhuoyueguide_flags=in_zhuoyueguide_flags, 
	zhuoyueguide_info=in_zhuoyueguide_info;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_ahcieve_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_ahcieve_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_achievement WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_binghun_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_binghun_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_binghun` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_binghun_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_binghun_insert_update`(IN `in_charguid` bigint, IN `in_id` int, IN `in_state` int, IN `in_current` int,
	IN `in_activetime` bigint,IN `in_time_stamp` bigint,IN `in_shenghun` varchar(256),IN `in_hole` int)
BEGIN
  INSERT INTO tb_player_binghun(charguid, id, state, current,activetime,time_stamp, shenghun, shenghun_hole)
  VALUES (in_charguid, in_id, in_state, in_current,in_activetime,in_time_stamp,in_shenghun,in_hole) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, id=in_id, state=in_state, current=in_current,
	activetime=in_activetime,time_stamp=in_time_stamp,shenghun=in_shenghun,shenghun_hole=in_hole;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_binghun_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_binghun_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_binghun WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_cd_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_cd_delete`(IN `in_charguid` bigint,IN `in_time_stamp` bigint)
BEGIN
	delete from tb_player_cd where charguid = in_charguid and timestamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_cd_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_cd_insert_update`(IN `in_charguid` bigint, IN `in_type` int, IN `in_tid` int, IN `in_cdtime` bigint, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_cd(charguid,type, tid, cdtime,timestamp)
	VALUES (in_charguid,in_type,in_tid,in_cdtime,in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, type = in_type, tid = in_tid,cdtime = in_cdtime, timestamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_cd_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_cd_select_by_id`(IN `in_charguid` bigint,IN `in_type` int)
BEGIN
  SELECT * FROM tb_player_cd WHERE charguid = in_charguid and type = in_type;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_create_role_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_create_role_insert_update`(IN `in_id` bigint,  IN `in_name` varchar(32), IN `in_level` int, IN `in_prof` int, IN `in_icon` int, IN `in_sex` int, 
		IN `in_bindgold` int, IN `in_zhenqi` int, IN `in_mp` int, IN `in_hp` int, IN `in_power` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, prof, iconid, sex, bindgold, zhenqi, mp, hp, power)
	VALUES (in_id, in_name, in_level, in_prof, in_icon, in_sex, in_bindgold, in_zhenqi, in_mp, in_hp, in_power) 
	ON DUPLICATE KEY UPDATE charguid=in_id, name=in_name, level=in_level, prof = in_prof, iconid = in_icon, sex = in_sex, 
		bindgold=in_bindgold, zhenqi=in_zhenqi, mp=in_mp, hp=in_hp, power=in_power;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_dailyquests_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_dailyquests_insert_update`(IN `in_charguid` bigint,  IN `in_quest_id` int, 
IN `in_quest_star` int, IN `in_quest_counter` int, IN `in_quest_counter_id` varchar(256), 
IN `in_quest_reward_id` varchar(128), IN `in_quest_double` int, IN `in_quest_auto_star` int)
BEGIN
  INSERT INTO tb_player_dailyquest(charguid, quest_id, quest_star,quest_counter,
  quest_counter_id,quest_reward_id,quest_double,quest_auto_star)
  VALUES (in_charguid, in_quest_id,in_quest_star,in_quest_counter,
  in_quest_counter_id,in_quest_reward_id,in_quest_double,in_quest_auto_star) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, quest_id=in_quest_id, quest_star=in_quest_star,
  quest_counter=in_quest_counter,quest_counter_id=in_quest_counter_id,quest_reward_id=in_quest_reward_id,
  quest_double=in_quest_double,quest_auto_star=in_quest_auto_star;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_dailyquests_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_dailyquests_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_dailyquest WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equips_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equips_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_equips WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint, IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128))
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind, wash,newgrouplvl,wash_attr)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind, in_wash,in_newgrouplvl,in_wash_attr) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equips_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equips_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_equips WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equip_pos_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equip_pos_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_equip_pos` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equip_pos_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equip_pos_insert_update`(IN `in_charguid` bigint, IN `in_pos` int, IN `in_idx` int, IN `in_groupid` int, IN `in_lvl` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_equip_pos(charguid, pos,idx,groupid,lvl,time_stamp)
	VALUES (in_charguid, in_pos,in_idx,in_groupid,in_lvl,in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, pos = in_pos, idx = in_idx, groupid = in_groupid, lvl = in_lvl, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_equip_pos_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_equip_pos_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_equip_pos WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_extra_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_extra_info`(IN `in_uid` bigint)
BEGIN
	SELECT * FROM tb_player_extra WHERE charguid = in_uid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(512), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTime` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int, IN `in_personboss_count` int, IN `in_platform_info` varchar(350), 
		IN `in_lastMonthCheckTime` int, IN `in_month_count` varchar(350), IN `in_marrystren` int, IN `in_marrystrenwish` int)
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus,
		vitality, actcode_flags,vitality_num,daily_yesterday, worshipstime,
		zhanyinchip,baojia_level, baojia_wish,baojia_procenum,addicted_freetime,
		fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,
		zhuzairoad_energy,equipcreate_unlockid,sale_count,freeshoe_count,lingzhen_level,
		lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,
		flyshoe_tick,seven_day,zhuan_id,zhuan_step,lastCheckTime,daily_count,
		lingzhen_attr_num, footprints,equipcreate_tick,huizhang_tick,personboss_count,platform_info,lastMonthCheckTime,month_count,
		marrystren, marrystrenwish)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTime,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick,in_huizhang_tick,in_personboss_count,in_platform_info,in_lastMonthCheckTime,in_month_count,
		in_marrystren, in_marrystrenwish) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag,
		bag_online=in_bag_online,expend_storage=in_expend_storage, storage_online=in_storage_online,
		babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTime = in_lastCheckTime,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints, equipcreate_tick = in_equipcreate_tick, huizhang_tick = in_huizhang_tick, personboss_count = in_personboss_count,
		platform_info = in_platform_info,lastMonthCheckTime = in_lastMonthCheckTime,month_count = in_month_count,
		marrystren = in_marrystren, marrystrenwish = in_marrystrenwish;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_fengyao_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_fengyao_insert_update`(IN `in_charguid` bigint, IN `in_fengyao_id` int, IN `in_fengyao_grp` int, IN `in_fengyao_state` int, IN `in_fengyao_counter` int, IN `in_fengyao_score` int, IN `in_fengyao_box` varchar(64), IN `in_fengyao_refresh` int, IN `in_fengyao_first` int, IN `in_fengyao_luck` int)
BEGIN
  INSERT INTO tb_player_fengyao(charguid, fengyao_id, fengyao_grp,fengyao_state,fengyao_counter,fengyao_score,fengyao_box,fengyao_refresh,fengyao_first,fengyao_luck)
  VALUES (in_charguid, in_fengyao_id, in_fengyao_grp,in_fengyao_state,in_fengyao_counter,in_fengyao_score,in_fengyao_box,in_fengyao_refresh,in_fengyao_first,in_fengyao_luck) 
  ON DUPLICATE KEY UPDATE fengyao_id=in_fengyao_id, fengyao_grp=in_fengyao_grp,fengyao_state=in_fengyao_state,fengyao_counter=in_fengyao_counter,fengyao_score=in_fengyao_score,fengyao_box=in_fengyao_box,fengyao_refresh=in_fengyao_refresh,fengyao_first=in_fengyao_first,fengyao_luck=in_fengyao_luck;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_finish_quest_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_finish_quest_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_finishquest WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_info_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_info_insert_update`(IN `in_id` bigint,  IN `in_name` varchar(32), IN `in_level` int, IN `in_exp` bigint, IN `in_vip_level` int, IN `in_vip_exp` int,
				IN `in_power` bigint, IN `in_hp` int, IN `in_mp` int, IN `in_hunli` int, IN `in_tipo` int, IN `in_shenfa` int, IN `in_jingshen` int, 
				IN `in_leftpoint` int, IN `in_totalpoint` int, IN `in_sp` int, IN `in_max_sp` int, IN `in_sp_recover` int, IN `in_bindgold` bigint, 
				IN `in_unbindgold` bigint, IN `in_bindmoney` bigint, IN `in_unbindmoney` bigint, IN `in_zhenqi` bigint, IN `in_soul` int, IN `in_pk_mode` int, IN `in_pk_status` int,
				IN `in_pk_flags` int,IN `in_pk_evil` int,IN `in_redname_time` bigint, IN `in_grayname_time` bigint, IN `in_pk_count` int, IN `in_yao_hun` int,
				IN `in_arms` int, IN `in_dress` int, IN `in_online_time` int, IN `in_head` int, IN `in_suit` int, IN `in_weapon` int, IN `in_drop_val` int, IN `in_drop_lv` int, 
				IN `in_killtask_count` int, IN `in_onlinetime_day` int, IN `in_honor` int, IN `in_hearthstone_time` bigint, IN `in_lingzhi` int, IN `in_jingjie_exp` int, IN `in_vplan` int,
				IN `in_blesstime` bigint,IN `in_equipval` bigint, IN `in_wuhunid` int, IN `in_shenbingid` int,IN `in_extremityval` bigint, IN `in_wingid` int,
				IN `in_blesstime2` bigint,IN `in_blesstime3` bigint, IN `in_suitflag` int, IN `in_crossscore` int, IN `in_crossexploit` int, IN `in_crossseasonid` int, 
				IN `in_pvplevel` int, IN `in_soul_hzlevel` int, IN `in_other_money` bigint, IN `in_wash_luck` int)
BEGIN
	INSERT INTO tb_player_info(charguid, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, 
								pvplevel, soul_hzlevel, other_money, wash_lucky)
	VALUES (in_id, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid,
			in_pvplevel, in_soul_hzlevel, in_other_money, in_wash_luck) 
	ON DUPLICATE KEY UPDATE level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel, soul_hzlevel = in_soul_hzlevel, other_money = in_other_money, wash_lucky = in_wash_luck;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_info_select_all` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_info_select_all`()
BEGIN
	SELECT * FROM tb_player_info;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_info_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_info_select_by_id`(IN `in_id` bigint)
BEGIN
	SELECT * FROM tb_player_info WHERE charguid = in_id ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_items_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_items_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_items WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_items_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_items_insert_update`(IN `in_charguid` bigint(20), IN `in_item_id` bigint, IN `in_item_tid` int, 
IN `in_slot_id` int, IN `in_stack_num` int, IN `in_flags` bigint, IN `in_bag` int ,IN `in_time_stamp` bigint,
IN `in_param1` int, IN `in_param2` int, IN `in_param3` int, IN `in_param4` bigint, IN `in_param5` bigint, IN `in_param6` varchar(64), IN `in_param7` varchar(64))
BEGIN
	INSERT INTO tb_player_items(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, time_stamp,
	param1, param2, param3, param4, param5, param6, param7)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_time_stamp,
	in_param1, in_param2, in_param3, in_param4, in_param5, in_param6, in_param7) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, time_stamp = in_time_stamp, param1 = in_param1,
	param2 = in_param2, param3 = in_param3, param4 = in_param4, param5 = in_param5, param6 = in_param6, param7 = in_param7;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_items_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_items_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_items WHERE charguid=in_charguid ORDER BY `slot_id`;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_lunpan_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_lunpan_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_lunpan WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_map_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_map_insert_update`(IN `in_id` bigint, IN `in_base_map` bigint, IN `in_game_map` bigint, IN `in_pos_x` double, IN `in_pos_z` double, IN `in_dir` double)
BEGIN
	INSERT INTO tb_player_map_info(charguid, base_map, game_map, pos_x, pos_z, dir)
	VALUES (in_id, in_base_map, in_game_map, in_pos_x, in_pos_z, in_dir) 
	ON DUPLICATE KEY UPDATE charguid=in_id, base_map=in_base_map, game_map=in_game_map, pos_x=in_pos_x, pos_z=in_pos_z, dir=in_dir;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_map_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_map_select`(IN  `in_id`  bigint)
BEGIN
	SELECT * FROM tb_player_map_info WHERE charguid = in_id ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marryInfo_replace` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marryInfo_replace`(IN `in_charguid` bigint(20), IN `in_mateguid` bigint(20), IN `in_marryState` int(11), 
											   IN `in_marryTime` bigint(20), IN `in_marryType` int(11), IN `in_marryTraveled` int(11), 
											   IN `in_marryDinnered` int(11), IN `in_marryRingCfgId` int(11), IN `in_marryIntimate` int(11))
BEGIN
	REPLACE INTO tb_player_marry_info(charguid, mateguid, marryState, marryTime, marryType, marryTraveled, marryDinnered, marryRingCfgId, marryIntimate) 
	VALUES (in_charguid, in_mateguid, in_marryState, in_marryTime, in_marryType, in_marryTraveled, in_marryDinnered, in_marryRingCfgId, in_marryIntimate);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marryInfo_schedule_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marryInfo_schedule_select`()
BEGIN
	SELECT * FROM tb_player_marry_schedule;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marryInfo_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marryInfo_select`(IN `in_charguid` bigint(20))
BEGIN
	SELECT * FROM tb_player_marry_info WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marryInfo_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marryInfo_update`(IN `in_charguid` bigint(20))
BEGIN
	UPDATE tb_player_marry_info SET marryTime = 0, marryType = 0, marryTraveled = 0, marryDinnered = 0 WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marryInfo_update_except_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marryInfo_update_except_type`(IN `in_charguid` bigint(20), IN `in_marryTime` bigint(20), IN `in_marryTraveled` int(11), IN `in_marryDinnered` int(11))
BEGIN
	UPDATE tb_player_marry_info SET marryTime = in_marryTime, marryTraveled = in_marryTraveled, marryDinnered = in_marryDinnered WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marrySchedule_clear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marrySchedule_clear`(IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_marry_schedule WHERE charguid = in_charguid or mateguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_marrySchedule_replace` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_marrySchedule_replace`(IN `in_charguid` bigint, IN `in_mateguid` bigint,    
												   IN `in_roleName` varchar(32), IN `in_mateName` varchar(32), 
												   IN `in_roleProfId` int(10), IN `in_mateProfId` int(10),
												   IN `in_scheduleId` int, IN `in_scheduleTime` bigint, 
												   IN `in_invites` varchar(2048))
BEGIN
	REPLACE INTO tb_player_marry_schedule(`charguid`, `mateguid`, `roleName`, `mateName`, `roleProfId`, `mateProfId`, `scheduleId`, `scheduleTime`, invites) 
	VALUES(in_charguid, in_mateguid, in_roleName, in_mateName, in_roleProfId, in_mateProfId, in_scheduleId, in_scheduleTime, in_invites);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_onlinereward_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_onlinereward_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_onlinereward WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_party_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_party_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_party WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_personboss_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_personboss_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_personboss` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_proto_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_proto_insert_update`(IN `in_char_guid` bigint,IN `in_binary_data` blob)
BEGIN
	INSERT INTO tb_player_protodata(char_guid,binary_data)
	VALUES (in_char_guid,in_binary_data) 
	ON DUPLICATE KEY UPDATE char_guid = in_char_guid, binary_data = in_binary_data;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_proto_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_proto_select`(IN `in_char_guid` bigint)
BEGIN
	SELECT * from tb_player_protodata WHERE char_guid = in_char_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_quests_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_quests_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_quests WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_quests_finish_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_quests_finish_insert_update`(IN `in_charguid` bigint, IN `in_questid` int, IN `in_cnt` int)
BEGIN
	INSERT INTO tb_player_finishquest(charguid, questid, cnt)
	VALUES (in_charguid, in_questid, in_cnt) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, questid = in_questid, cnt = in_cnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_quests_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_quests_insert_update`(IN `in_charguid` bigint,  IN `in_quest_id` int, 
IN `in_quest_state` int, IN `in_goal1` bigint, IN `in_goal_count1` int,
IN `in_goal2` bigint, IN `in_goal_count2` int, IN `in_time_stamp` bigint)
BEGIN
  INSERT INTO tb_player_quests(charguid, quest_id, quest_state ,goal1,goal_count1,goal2,goal_count2,time_stamp)
  VALUES (in_charguid, in_quest_id, in_quest_state, in_goal1,in_goal_count1,in_goal2,in_goal_count2, in_time_stamp) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, quest_id=in_quest_id, quest_state=in_quest_state,goal1=in_goal1,
  goal_count1=in_goal_count1, goal2=in_goal2,goal_count2=in_goal_count2, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_quests_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_quests_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_quests WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int, IN `in_fh_itemnum` bigint, IN `in_fh_level_itemnum` bigint)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum, fh_itemnum,fh_level_itemnum)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum, in_fh_itemnum,in_fh_level_itemnum)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum, fh_itemnum=in_fh_itemnum, fh_level_itemnum=in_fh_level_itemnum;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_realm_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_realm_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_realm WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_recharge_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_recharge_list`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_exchange_record WHERE role_id = in_charguid AND recharge = 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_refinery_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_refinery_insert_update`(IN `in_gid` bigint,  IN `in_id` varchar(256),IN `in_cost_zhenqi` bigint,IN `in_fh_cost_zhenqi` bigint)
BEGIN
	INSERT INTO tb_player_refinery(charguid, id, cost_zhenqi, fh_cost_zhenqi)
	VALUES (in_gid, in_id, in_cost_zhenqi, in_fh_cost_zhenqi) 
	ON DUPLICATE KEY UPDATE charguid=in_gid, id=in_id,cost_zhenqi=in_cost_zhenqi, fh_cost_zhenqi=in_fh_cost_zhenqi;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_rideskins_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_rideskins_insert_update`(IN `in_charguid` bigint, IN `in_skin_id` int, IN `in_skin_time` bigint)
BEGIN
	INSERT INTO tb_ride_skin(charguid, skin_id, skin_time)
	VALUES (in_charguid, in_skin_id, in_skin_time) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, skin_id = in_skin_id, skin_time = in_skin_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_rideskins_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_rideskins_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_ride_skin WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_ridewar_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_ridewar_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_ridewar WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_dungeon` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_dungeon`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_dungeon WHERE charguid=in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_refinery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_refinery`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_refinery WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_shopitem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_shopitem`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_shop_item WHERE charguid=in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_zhenbaoge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_zhenbaoge`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_zhenbaoge WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_zhuzairoad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_zhuzairoad`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_zhuzairoad WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_select_zhuzairoadbox` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_select_zhuzairoadbox`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_zhuzairoad_box WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenbing_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_shenbing(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenbing_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenbing_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_shenbing WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenglingskins_insert_update`(IN `in_charguid` bigint, IN `in_skin_id` int, IN `in_skin_time` bigint)
BEGIN
	INSERT INTO tb_player_shengling_skin(charguid, skin_id, skin_time)
	VALUES (in_charguid, in_skin_id, in_skin_time) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, skin_id = in_skin_id, skin_time = in_skin_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenglingskins_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shengling_skin WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shengling_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shengling_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_shengling(charguid, level, process, sel, proce_num, total_proce, attrdan)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num, total_proce = in_total_proce, attrdan = in_attrdan;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shengling_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shengling_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shengling WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenshouskins_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenshouskins_insert_update`(IN `in_charguid` bigint, IN `in_shenshou_id` int, IN `in_skin_time` bigint)
BEGIN
	INSERT INTO tb_player_shenshou(charguid, shenshou_id, skin_time)
	VALUES (in_charguid, in_shenshou_id, in_skin_time)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, shenshou_id=in_shenshou_id, skin_time=in_skin_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenshou_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenshou_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shenshou WHERE in_charguid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenwu_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenwu_insert_update`(IN `in_charguid` bigint, IN `in_shenwu_level` int,
 IN `in_shenwu_star` int, IN `in_shenwu_stone` int, IN `in_shenwu_failnum` int)
BEGIN
	INSERT INTO tb_player_shenwu(charguid, shenwu_level, shenwu_star, shenwu_stone, shenwu_failnum)
	VALUES (in_charguid, in_shenwu_level, in_shenwu_star, in_shenwu_stone, in_shenwu_failnum) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shenwu_level = in_shenwu_level,	shenwu_star = in_shenwu_star, 
	shenwu_stone = in_shenwu_stone, shenwu_failnum = in_shenwu_failnum;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shenwu_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shenwu_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_shenwu WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shortcuts_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shortcuts_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_shortcuts WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shortcuts_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shortcuts_insert_update`(IN `in_charguid` bigint, IN `in_shortcut_id` int, IN `in_shortcut_pos` int, 
	   IN `in_shortcut_type` int, IN `in_time_stamp` bigint)
BEGIN
  INSERT INTO tb_player_shortcuts(charguid, shortcut_id, shortcut_pos, shortcut_type, time_stamp)
  VALUES (in_charguid, in_shortcut_id, in_shortcut_pos, in_shortcut_type, in_time_stamp) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, shortcut_id=in_shortcut_id, shortcut_pos=in_shortcut_pos,
    shortcut_type = in_shortcut_type, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shortcuts_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shortcuts_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_shortcuts WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shortcut_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shortcut_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_shortcuts` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shouhunlv_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shouhunlv_insert_update`(IN `in_charguid` bigint, IN `in_shouhun_maxlv` int,
 IN `in_shouhun_commonlv` int)
BEGIN
	INSERT INTO tb_player_shouhunlv(charguid, shouhun_maxlv, shouhun_commonlv)
	VALUES (in_charguid, in_shouhun_maxlv, in_shouhun_commonlv)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shouhun_maxlv = in_shouhun_maxlv,
	 shouhun_commonlv = in_shouhun_commonlv;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shouhunlv_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shouhunlv_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shouhunlv WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shouhun_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shouhun_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_shouhun WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_shouhun_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_shouhun_insert_update`(IN `in_charguid` bigint, IN `in_shouhun_id` int,
 IN `in_shouhun_level` int, IN `in_shouhun_star` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_shouhun(charguid, shouhun_id, shouhun_level, shouhun_star, time_stamp)
	VALUES (in_charguid, in_shouhun_id, in_shouhun_level, in_shouhun_star, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shouhun_id = in_shouhun_id, shouhun_level = in_shouhun_level, 
	shouhun_star = in_shouhun_star, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_sign_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_sign_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_sign WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_skills_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_skills_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_skills WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_skills_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_skills_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_skills` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_skills_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_skills_insert_update`(IN `in_charguid` bigint, IN `in_skill_id` int, IN `in_skill_exp` int,IN `in_time_stamp` bigint)
BEGIN
  INSERT INTO tb_player_skills(charguid, skill_id, skill_exp, time_stamp)
  VALUES (in_charguid, in_skill_id, in_skill_exp, in_time_stamp) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, skill_id=in_skill_id, skill_exp=in_skill_exp,time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_skills_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_skills_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_skills WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_smelt_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_smelt_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_smelt WHERE in_charguid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_superhole_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_superhole_insert_update`(IN `in_guid` bigint, IN `in_pos` int, IN `in_lv1` int, 
IN `in_lv2` int, IN `in_lv3` int, IN `in_lv4` int, IN `in_lv5` int)
BEGIN
	INSERT INTO tb_player_superhole(guid, pos, lv1, lv2, lv3, lv4, lv5)
	VALUES (in_guid, in_pos, in_lv1, in_lv2, in_lv3, in_lv4, in_lv5) 
	ON DUPLICATE KEY UPDATE guid=in_guid, pos=in_pos, lv1 = in_lv1, lv2 = in_lv2, lv3 = in_lv3,
	lv4 = in_lv4, lv5 = in_lv5;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_superhole_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_superhole_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_superhole WHERE guid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_superlib_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_superlib_delete`(IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_superlib WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_superlib_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_superlib_insert_update`(IN `in_charguid` bigint, IN `in_id` bigint, IN `in_tid` int, IN `in_att1` int, IN `in_att2` int)
BEGIN
	INSERT INTO tb_player_superlib(charguid, id, tid, att1, att2)
	VALUES (in_charguid, in_id, in_tid, in_att1, in_att2) 
	ON DUPLICATE KEY UPDATE id=in_id, charguid=in_charguid, tid = in_tid, att1 = in_att1, att2 = in_att2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_superlib_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_superlib_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_superlib WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_update_dungeon` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_update_dungeon`(IN `in_charguid` bigint, IN `in_dungeon` int, IN `in_gamemap` bigint, IN `in_line` int, 
							IN `in_process` int, IN `in_end_time` bigint, IN `in_left_time` bigint, IN `in_last_map` bigint, IN `in_pos_x` double, IN `in_pos_z` double)
BEGIN
	INSERT INTO tb_player_dungeon(charguid, dungeon, gamemap, line, process, end_time, left_time, last_map, last_pos_x, last_pos_z)
	VALUES (in_charguid, in_dungeon, in_gamemap, in_line, in_process, in_end_time, in_left_time, in_last_map, in_pos_x, in_pos_z)
	ON DUPLICATE KEY UPDATE dungeon = in_dungeon, gamemap = in_gamemap, line = in_line, 
	   process = in_process, end_time = in_end_time, left_time = in_left_time, last_map = in_last_map, last_pos_x = in_pos_x, last_pos_z = in_pos_z;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_update_party` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_update_party`(IN `in_guid` bigint, IN `in_id` int, IN `in_progress` int, IN `in_award` int, 
IN `in_awardtimes` int, IN `in_param1` int, IN `in_param2` int, IN`in_param3` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_party(charguid, id, progress, award, awardtimes, param1, param2, param3, time_stamp)
	VALUES (in_guid, in_id, in_progress, in_award, in_awardtimes, in_param1, in_param2, in_param3, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_guid, id = in_id, progress = in_progress, 
	award = in_award, awardtimes = in_awardtimes, param1 = in_param1, 
	param2 = in_param2, param3 = in_param3, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_update_shopitem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_update_shopitem`(IN `in_guid` bigint, IN `in_shopItem` int, IN `in_count` int, IN `in_flags` bigint)
BEGIN
	INSERT INTO tb_player_shop_item(charguid, shopitem, count, flags)
	VALUES (in_guid, in_shopitem, in_count, in_flags)
	ON DUPLICATE KEY UPDATE count = in_count, flags = in_flags;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_update_zhenbaoge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_update_zhenbaoge`(IN `in_charguid` bigint, IN `in_zhenbao_id` int, IN `in_submit_once_num` int,IN `in_submit_times` int, IN `in_submit_num` int, IN `in_special_item_num1` int, 
	IN `in_special_item_num2` int, IN `in_special_item_num3` int, IN `in_zhenbao_process` int, IN `in_zhenbao_break_num` int)
BEGIN
	INSERT INTO tb_zhenbaoge(charguid, zhenbao_id, submit_once_num, submit_times, submit_num, item_num1, item_num2, item_num3, zhenbao_process, zhenbao_break_num)
	VALUES (in_charguid, in_zhenbao_id, in_submit_once_num, in_submit_times, in_submit_num, in_special_item_num1, in_special_item_num2, in_special_item_num3, in_zhenbao_process, in_zhenbao_break_num)
	ON DUPLICATE KEY UPDATE charguid = in_charguid,zhenbao_id = in_zhenbao_id, submit_once_num=in_submit_once_num, submit_times = in_submit_times, submit_num = in_submit_num, 
	item_num1 = in_special_item_num1, item_num2 = in_special_item_num2, item_num3 = in_special_item_num3, zhenbao_process = in_zhenbao_process, zhenbao_break_num = in_zhenbao_break_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` bigint, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint, IN `in_redpacketcnt` int)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_exp,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3,redpacketcnt)
	VALUES (in_charguid,in_vip_exp,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3,in_redpacketcnt) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_exp=in_vip_exp,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3,redpacketcnt=in_redpacketcnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_vip_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_vip_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_vip WHERE in_charguid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wingstren_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wingstren_insert_update`(IN `in_charguid` bigint, IN `in_wing_stren_level` int, IN `in_wing_stren_process` int)
BEGIN
	INSERT INTO tb_wingstren(charguid, wing_stren_level, wing_stren_process)
	VALUES (in_charguid, in_wing_stren_level, in_wing_stren_process) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, wing_stren_level = in_wing_stren_level,	wing_stren_process = in_wing_stren_process;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wingstren_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wingstren_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_wingstren WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuhuns_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuhuns_delete_by_id`(IN `in_charguid` bigint)
BEGIN
  DELETE FROM tb_player_wuhuns WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuhuns_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuhuns_insert_update`(IN `in_charguid` bigint, IN `in_wuhun_id` int, IN `in_wuhun_wish` int, IN `in_trytime` int, IN `in_cur_hunzhu` int,
 	IN `in_wuhun_progress` int, IN `in_feed_num` int, IN `in_wuhun_state` int, IN `in_wuhun_sp` int,IN `in_cur_shenshou` int,IN `in_shenshou_data` varchar(128),
	IN `in_total_proce_num` int,IN `in_fh_item_num` int, IN `in_select` int, IN `in_attr_num` int, IN `in_fh_level_item_num` int)
BEGIN
  INSERT INTO tb_player_wuhuns(charguid, wuhun_id, wuhun_wish, trytime, cur_hunzhu,
   wuhun_progress, feed_num, wuhun_state, wuhun_sp, cur_shenshou, shenshou_data,
    total_proce_num, fh_item_num, select_id, attr_num,fh_level_item_num)
  VALUES (in_charguid, in_wuhun_id, in_wuhun_wish, in_trytime, in_cur_hunzhu,
   in_wuhun_progress, in_feed_num, in_wuhun_state, in_wuhun_sp, in_cur_shenshou, in_shenshou_data,
   in_total_proce_num, in_fh_item_num, in_select, in_attr_num,in_fh_level_item_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, wuhun_id=in_wuhun_id, wuhun_wish=in_wuhun_wish, trytime=in_trytime, cur_hunzhu=in_cur_hunzhu,
    wuhun_progress=in_wuhun_progress, feed_num=in_feed_num, wuhun_state=in_wuhun_state, wuhun_sp=in_wuhun_sp, cur_shenshou = in_cur_shenshou, shenshou_data = in_shenshou_data,
    total_proce_num = in_total_proce_num, fh_item_num = in_fh_item_num, select_id =in_select, attr_num = in_attr_num, fh_level_item_num = in_fh_level_item_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuhuns_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuhuns_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_wuhuns WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuxing_item_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_wuxing_item WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuxing_item_insert_update`(IN `in_charguid` bigint, IN `in_itemgid` bigint, IN `in_itemtid` int, IN `in_pos` int, IN `in_type` int,
IN `in_att1` varchar(60), IN `in_att2` varchar(60), IN `in_att3` varchar(60), IN `in_att4` varchar(60), IN `in_att5` varchar(60), IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_wuxing_item(charguid, itemgid, itemtid, pos, type, att1, att2, att3, att4, att5, time_stamp)
	VALUES (in_charguid, in_itemgid,in_itemtid,in_pos,in_type,in_att1,in_att2,in_att3,in_att4,in_att5,in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, itemtid = in_itemgid, itemtid = in_itemtid, pos = in_pos, type = in_type,
	att1 = in_att1, att2 = in_att2, att3 = in_att3, att4 = in_att4, att5 = in_att5, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_wuxing_pro_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_wuxing_pro_insert_update`(IN `in_charguid` bigint, IN `in_lv` int, IN `in_progress` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_wuxing_pro(charguid, lv, progress,attrdan)
	VALUES (in_charguid, in_lv, in_progress,in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lv = in_lv, progress = in_progress, attrdan = in_attrdan;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_xunbao_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_xunbao_insert_update`(IN `in_charguid` bigint, IN `in_maptabid1` int, IN `in_maptabid2` int, IN `in_passmaptabid` int, IN `in_quality` int, IN `in_times` int, IN `in_playerlvl` int)
BEGIN
  INSERT INTO tb_player_xunbao(charguid, maptabid1, maptabid2, passmaptabid, quality, times,playerlvl)
  VALUES (in_charguid, in_maptabid1, in_maptabid2, in_passmaptabid, in_quality, in_times,in_playerlvl) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, maptabid1=in_maptabid1, maptabid2=in_maptabid2, passmaptabid=in_passmaptabid, quality=in_quality, times=in_times, playerlvl=in_playerlvl;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_xunbao_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_xunbao_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_xunbao WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_yaodan_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_yaodan_insert_update`(IN `in_charguid` bigint, IN `in_yaodan_id` int, IN `in_yaodan_today` int, IN `in_yaodan_total` int)
BEGIN
  INSERT INTO tb_player_yaodan(charguid, yaodan_id, yaodan_today,yaodan_total)
  VALUES (in_charguid, in_yaodan_id, in_yaodan_today,in_yaodan_total) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, yaodan_id=in_yaodan_id, yaodan_today=in_yaodan_today,yaodan_total=in_yaodan_total;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_yaohun_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_yaohun_insert_update`(IN `in_charguid` bigint, IN `in_yaohun_type` int, IN `in_yaohun_num` int)
BEGIN
  INSERT INTO tb_player_yaohun(charguid, yaohun_type, yaohun_num)
  VALUES (in_charguid, in_yaohun_type, in_yaohun_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, yaohun_type=in_yaohun_type, yaohun_num=in_yaohun_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_yaohun_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_yaohun_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_yaohun WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_yuanling_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_yuanling_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int, IN `in_secs` int, IN `in_dianshu` int, IN `in_dunstate` int)
BEGIN
	INSERT INTO tb_player_yuanling(charguid, level, process, sel, proce_num, total_proce, attrdan,secs,dianshu,dunstate)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan,in_secs,in_dianshu,in_dunstate)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num
	, total_proce = in_total_proce, attrdan = in_attrdan, secs = in_secs, dianshu = in_dianshu, dunstate = in_dunstate;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_yuanling_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_yuanling_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_yuanling WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhannu_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhannu_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_zhannu(charguid, level, process, sel, proce_num, total_proce, attrdan)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num, total_proce = in_total_proce, attrdan = in_attrdan;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhannu_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhannu_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_zhannu WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhanyin_delete_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhanyin_delete_by_id`(IN `in_charguid` bigint,IN `in_updatetime` bigint)
BEGIN
	delete from tb_player_zhanyin where charguid = in_charguid and updatetime<>in_updatetime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhanyin_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhanyin_insert_update`(IN `in_charguid` bigint,IN `in_bag` int,IN `in_pos` int,IN `in_tid` int,IN `in_exp` int,IN `in_updatetime` bigint)
BEGIN
	INSERT INTO tb_player_zhanyin(charguid, bag, pos, tid, exp,updatetime)
	VALUES (in_charguid, in_bag, in_pos, in_tid, in_exp,in_updatetime)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, bag=in_bag, pos=in_pos, tid=in_tid,
	exp=in_exp, updatetime=in_updatetime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhanyin_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhanyin_select`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_zhanyin WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhuzairoadbox_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhuzairoadbox_insert_update`(IN `in_charguid` bigint, IN `in_road_box` varchar(32), IN `in_buy_num` int, IN `in_zhuzairoad_tick` int,
IN `in_challenge_count` int, IN `in_roadlv_max` int)
BEGIN
	INSERT INTO tb_zhuzairoad_box(charguid, road_box, buy_num, zhuzairoad_tick, challenge_count, roadlv_max)
	VALUES (in_charguid, in_road_box, in_buy_num, in_zhuzairoad_tick, in_challenge_count, in_roadlv_max)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, road_box=in_road_box, buy_num=in_buy_num, zhuzairoad_tick = in_zhuzairoad_tick,
	 challenge_count = in_challenge_count, roadlv_max = in_roadlv_max;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhuzairoad_delete_by_id_and_timestamp` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhuzairoad_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_zhuzairoad` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_player_zhuzairoad_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_player_zhuzairoad_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_level_star` int, 
IN `in_challenge` int, IN `in_sweep_state` int, IN `in_sweep_time` bigint, IN `in_sweep_times` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_zhuzairoad(charguid, level, level_star, challenge, sweep_state, sweep_time, sweep_times,time_stamp)
	VALUES (in_charguid, in_level, in_level_star, in_challenge, in_sweep_state, in_sweep_time, in_sweep_times,in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, level_star=in_level_star, challenge=in_challenge, 
	sweep_state=in_sweep_state, sweep_time=in_sweep_time, sweep_times=in_sweep_times, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_crossscore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_crossscore`(IN `in_curseasonid` int)
BEGIN
	SELECT charguid AS uid, pvplevel AS rankvalue FROM tb_player_info 
	WHERE pvplevel > 0 and crossscore > 0 and crossseasonid = in_curseasonid 
	ORDER BY pvplevel ASC , crossscore DESC, power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_extremity_boss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_extremity_boss`()
BEGIN
	SELECT charguid AS uid, extremity_damage AS rankvalue FROM tb_player_extra WHERE extremity_damage > 0 ORDER BY extremity_damage DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_extremity_monster` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_extremity_monster`()
BEGIN
	SELECT charguid AS uid, extremity_monster AS rankvalue FROM tb_player_extra WHERE extremity_monster > 0 ORDER BY extremity_monster DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_level` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_level`()
BEGIN
	SELECT charguid AS uid, level AS rankvalue FROM tb_player_info ORDER BY level DESC, exp DESC, power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_lingshou` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_lingshou`()
BEGIN
	SELECT tb_player_wuhuns.charguid AS uid, wuhun_id AS rankvalue FROM tb_player_wuhuns left join tb_player_info
	on tb_player_wuhuns.charguid = tb_player_info.charguid
	WHERE wuhun_id > 0 ORDER BY wuhun_id DESC, cur_hunzhu DESC, wuhun_progress DESC, wuhun_wish DESC, tb_player_info.power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_lingzhen` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_lingzhen`()
BEGIN
	SELECT tb_player_extra.charguid AS uid, lingzhen_level AS rankvalue FROM tb_player_extra left join tb_player_info
	on tb_player_extra.charguid = tb_player_info.charguid
	WHERE lingzhen_level > 0 ORDER BY lingzhen_level DESC, lingzhen_wish DESC, lingzhen_procenum DESC, tb_player_info.power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_power` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_power`()
BEGIN
	SELECT charguid AS uid, power AS rankvalue FROM tb_player_info ORDER BY power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_pvplevel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_pvplevel`(IN `in_curseasonid` int, IN `in_pvplevel` int, IN `in_limit` int)
BEGIN
	SELECT charguid, pvplevel, crossscore, power, name, prof, level, arms, dress, head, suit, weapon, wuhunid, wingid, suitflag FROM tb_player_info 
	WHERE crossscore > 0 and crossseasonid = in_curseasonid and pvplevel = in_pvplevel
	ORDER BY crossscore DESC, power DESC LIMIT in_limit;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_realm` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_realm`()
BEGIN
	SELECT tb_player_realm.charguid AS uid, realm_step AS rankvalue FROM tb_player_realm left join tb_player_info
	on tb_player_realm.charguid = tb_player_info.charguid
	WHERE realm_step > 0 ORDER BY realm_step DESC, realm_progress DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_ride` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_ride`()
BEGIN
	SELECT tb_ride.charguid AS uid, ride_step AS rankvalue FROM tb_ride left join tb_player_info
	on tb_ride.charguid = tb_player_info.charguid
	WHERE ride_step > 0 ORDER BY ride_step DESC, ride_process DESC, tb_player_info.power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rank_shenbing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_rank_shenbing`()
BEGIN
	SELECT tb_player_shenbing.charguid AS uid, tb_player_shenbing.level AS rankvalue FROM tb_player_shenbing left join tb_player_info
	on tb_player_shenbing.charguid = tb_player_info.charguid
	WHERE tb_player_shenbing.level > 0 ORDER BY tb_player_shenbing.level DESC, proficiencylvl DESC, proficiency DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_realm_strenthen_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_realm_strenthen_insert_update`(IN `in_charguid` bigint, IN `in_strenthen_id` int,
 IN `in_select_id` int, IN `in_progress` int, IN `in_break_id` int)
BEGIN
	INSERT INTO tb_Realm_Strenthen(charguid, strenthen_id, select_id, progress, break_id)
	VALUES (in_charguid, in_strenthen_id, in_select_id, in_progress, in_break_id)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, strenthen_id = in_strenthen_id,	select_id = in_select_id, 
	progress = in_progress, break_id = in_break_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_Realm_Strenthen_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_Realm_Strenthen_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_Realm_Strenthen WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_relation_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_relation_insert_update`(IN `in_charguid` bigint, IN `in_rid` bigint, IN `in_relation_type` int, IN `in_relation_degree` int, IN `in_bekill_num` int, IN `in_recent_time` bigint, IN `in_kill_time` bigint)
BEGIN
  INSERT INTO tb_relation(charguid, rid, relation_type, relation_degree, bekill_num, recent_time, kill_time)
  VALUES (in_charguid, in_rid, in_relation_type, in_relation_degree, in_bekill_num, in_recent_time, in_kill_time) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, rid=in_rid, relation_type=in_relation_type, relation_degree = in_relation_degree, bekill_num = in_bekill_num, recent_time = in_recent_time, kill_time = in_kill_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_relation_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_relation_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_relation WHERE charguid=in_charguid and relation_type <> 0 ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remove_disciple` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_remove_disciple`(IN `in_charguid` bigint, IN `in_status` int)
BEGIN
	DELETE FROM tb_player_disciple WHERE charguid = in_charguid AND status = in_status;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remove_forb_mac` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_remove_forb_mac`(IN `in_mac` varchar(32))
BEGIN
	DELETE FROM tb_forb_mac WHERE mac = in_mac;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_actpet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_actpet`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_actpet where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_arena` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_arena`()
BEGIN
	SELECT tb_arena.*, tb_arena_att.* from tb_arena
	left join tb_arena_att
	on tb_arena.charguid = tb_arena_att.charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_arena_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_arena_history`()
BEGIN
	SELECT * FROM tb_crossarena_history;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_merge_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_merge_info`()
BEGIN
	SELECT * FROM tb_merge;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_party_group_purchase` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_party_group_purchase`()
BEGIN
	SELECT * FROM tb_group_purchase;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_party_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_party_rank`()
BEGIN
	SELECT * FROM tb_party_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_all_pvphistory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_all_pvphistory`()
BEGIN
	SELECT * FROM tb_pvp_season_history;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_arena_att` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_arena_att`(IN `in_charguid` bigint)
BEGIN
	SELECT * from tb_arena_att where charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_arena_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_arena_event`(IN `in_charguid` bigint)
BEGIN
	SELECT * from tb_arena_event where charguid=in_charguid ORDER BY time DESC LIMIT 6;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_aura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_aura`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_aura WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_babel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_babel`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_babel WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_babel_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_babel_rank`()
BEGIN
	SELECT * FROM tb_babel_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_boss_media` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_boss_media`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_boss_media WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_consignment_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_consignment_item`()
BEGIN
	SELECT * FROM tb_consignment_items where sale_guid<>0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_consignment_items` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_consignment_items`()
BEGIN
	SELECT * FROM tb_consignment_items;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_cross_arena_xiazhu` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_cross_arena_xiazhu`(IN `in_seasonid` int)
BEGIN
	SELECT * FROM tb_crossarena_xiazhu WHERE seasonid = in_seasonid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_cross_boss_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_cross_boss_history`()
BEGIN
	select * from tb_crossboss_history;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_daily_buy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_daily_buy`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_daily_buy where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_day_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_day_history`(IN `in_date` VARCHAR(32))
BEGIN
	select * from tb_day_history where TO_DAYS(date_time) = TO_DAYS(in_date);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_dungeon_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_dungeon_group`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_dungeon_group WHERE charguid=in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_dupl_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_dupl_rank`()
BEGIN
	SELECT * FROM tb_dupl_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_equip_info_by_ls` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_equip_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_equips WHERE in_guid = charguid 
	AND (slot_id = 1 or slot_id = 3)
	AND bag = 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_extremity_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_extremity_rank`()
BEGIN
	SELECT * FROM tb_extremity_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_fashion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_fashion`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_fashion WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_fengyao_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_fengyao_info`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_fengyao WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_festival_activity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_festival_activity`()
BEGIN
  SELECT * FROM tb_festivalact;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_gem_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_gem_info`(IN `in_charguid` bigint)
BEGIN
	SELECT * from tb_gem_info where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_gm_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_gm_account`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_gm_account 
	WHERE charguid = in_charguid; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_gm_account_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_gm_account_list`()
BEGIN
	SELECT tb_gm_account.gm_level, tb_account.charguid, tb_account.account, tb_player_info.name 
	FROM tb_account, tb_player_info, tb_gm_account 
	WHERE tb_gm_account.gm_level > 0 
	AND tb_player_info.charguid = tb_account.charguid
	AND tb_gm_account.charguid = tb_account.charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_gm_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_gm_list`()
BEGIN
	SELECT tb_account.gm_flag, tb_account.charguid, tb_account.account, tb_player_info.name 
	FROM tb_account, tb_player_info  
	WHERE tb_account.gm_flag > 0 AND tb_player_info.charguid = tb_account.charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guilds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guilds`()
BEGIN
	SELECT * FROM tb_guild;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_aliance_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_aliance_applys`()
BEGIN
	SELECT * FROM tb_guild_aliance_apply;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_applys` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_applys`()
BEGIN
	SELECT * FROM tb_guild_apply;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_events` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_events`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_guild_event WHERE guid = in_guid ORDER BY time DESC LIMIT 100;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_hell` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_hell`()
BEGIN
	SELECT * FROM tb_guild_hell WHERE gid <> 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_itemops` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_itemops`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_guild_storage_op WHERE gid = in_guid ORDER BY optime DESC LIMIT 50;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_items` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_items`()
BEGIN
	SELECT * FROM tb_guild_storage WHERE gid <> 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_mems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_mems`()
BEGIN
	SELECT * FROM tb_guild_mem;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_palace` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_palace`()
BEGIN
	SELECT * FROM tb_guild_palace;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_guild_palace_sign` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_guild_palace_sign`()
BEGIN
	SELECT * FROM tb_guild_palace_sign;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_killtask` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_killtask`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_killtask WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_last_guild_mail_time` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_last_guild_mail_time`()
BEGIN
  SELECT * FROM tb_LastGuildWarMailTime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_lingshoumudi` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_lingshoumudi`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_lingshoumudi where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_lingshoumudi_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_lingshoumudi_rank`()
BEGIN
	SELECT * FROM tb_lingshoumudi_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_mail_info_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_mail_info_by_id`(IN `in_charguid` bigint, IN `in_createtime` bigint)
BEGIN
	DECLARE cur_time bigint DEFAULT '0';
	SET cur_time = UNIX_TIMESTAMP(now());
	
	SELECT * FROM (SELECT IFNULL(tb_mail.charguid, 0) AS guid, IFNULL(tb_mail.readflag, 0) AS readflag, IFNULL(tb_mail.deleteflag, 0) AS deleteflag, 
		IFNULL(tb_mail.recvflag, 0) AS recvflag, tb_mail_content.* FROM tb_mail RIGHT JOIN tb_mail_content 
	ON tb_mail.mailgid = tb_mail_content.mailgid AND tb_mail_content.validtime > cur_time WHERE charguid = in_charguid AND deleteflag = 0
	UNION ALL
	SELECT 0, 0, 0, 0, tb_mail_content.* FROM tb_mail_content WHERE refflag = 1 AND tb_mail_content.validtime > cur_time AND tb_mail_content.sendtime > in_createtime AND NOT EXISTS 
	(SELECT tb_mail.mailgid FROM tb_mail WHERE tb_mail_content.mailgid = tb_mail.mailgid AND charguid = in_charguid))t ORDER BY validtime DESC;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_map_info_by_ls` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_map_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT base_map FROM tb_player_map_info WHERE in_guid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_merge_cnt` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_merge_cnt`()
BEGIN
	SELECT min(cnt) AS cnt FROM tb_merge;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_party_group_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_party_group_charge`()
BEGIN
	select * from tb_group_charge;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_plat_setting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_plat_setting`()
BEGIN
	SELECT * FROM tb_setting;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_achievement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_achievement`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_achievement WHERE charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_challenge_dupl` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_challenge_dupl`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_challenge_dupl WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_disciple` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_disciple`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_disciple WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_hl_quest`(In `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_hl_quest WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_homeland` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_homeland`(In `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_homeland WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_info_by_ls` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT name, level, prof, iconid, power, vip_level, head, suit, weapon, wingid, suitflag
	FROM tb_player_info 
	WHERE in_guid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_ls_horse` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_ls_horse`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_ls_horse WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_party` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_party`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_party WHERE charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_personboss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_personboss`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_personboss WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_prerogative` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_prerogative`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_prerogative WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_pvp_info_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_pvp_info_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_crosspvp WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_ride_dupl` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_ride_dupl`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_ride_dupl WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_shouhun_info_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_shouhun_info_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shouhun WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_update_soul` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_update_soul`(IN `in_charguid` bigint, IN `in_monsterid` int, IN `in_num` int)
BEGIN
	INSERT tb_soul_info(charguid, monsterid, num)
	VALUE (in_charguid, in_monsterid, in_num)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, monsterid = in_monsterid, num = in_num;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_vplan` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_vplan`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_vplan where charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_wuxing_item`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_wuxing_item WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_pro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_player_wuxing_pro`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_wuxing_pro WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_crossscore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_crossscore`()
BEGIN
	SELECT * FROM tb_rank_crossscore;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_extremity_boss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_extremity_boss`()
BEGIN
	SELECT * FROM tb_rank_extremity_boss;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_extremity_monster` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_extremity_monster`()
BEGIN
	SELECT * FROM tb_rank_extramity_monster;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_equip` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_equip`(IN `in_uid` bigint)
BEGIN
	SELECT * 
	FROM tb_player_equips WHERE charguid = in_uid 
	AND item_tid <> 0
	AND bag = 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_guild` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_guild`(IN `in_charguid` bigint)
BEGIN
	SELECT IFNULL(tb_guild.name, '') AS name FROM tb_guild_mem 
	LEFT JOIN tb_guild
	ON tb_guild.gid = tb_guild_mem.gid
	WHERE tb_guild_mem.charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_base` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_info_base`(IN `in_id` bigint)
BEGIN
	SELECT charguid, name, prof, level, hp, mp, power, vip_level, sex, dress, 
	arms, head, suit, weapon, hunli, tipo, shenfa, jingshen, vplan, wingid, shenbingid, suitflag,crossscore
	FROM tb_player_info WHERE charguid = in_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_info_detail`(IN `in_charguid` bigint)
BEGIN
	SELECT hp, atk, def, hit, cri
	FROM tb_arena_att WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_ride` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_ride`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_ride WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_rideskin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_rideskin`(IN `in_charguid` bigint)
BEGIN
	SELECT skin_id
	FROM tb_ride_skin WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_ride_equip` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_ride_equip`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_equips WHERE charguid = in_charguid AND bag = 3;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_roleitem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_roleitem`(IN `in_uid` bigint)
BEGIN
	SELECT * FROM tb_player_items WHERE charguid = in_uid AND bag = 4;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_skill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_skill`(IN `in_uid` bigint)
BEGIN
	SELECT skill_id
	FROM tb_player_skills WHERE charguid = in_uid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_human_wuhun_equip` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_human_wuhun_equip`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_equips WHERE charguid = in_charguid AND bag = 5;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_level` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_level`()
BEGIN
	SELECT * FROM tb_rank_level;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_lingshou` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_lingshou`()
BEGIN
	SELECT * FROM tb_rank_lingshou;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_lingzhen` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_lingzhen`()
BEGIN
	SELECT * FROM tb_rank_lingzhen;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_power` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_power`()
BEGIN
	SELECT * FROM tb_rank_power;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_realm` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_realm`()
BEGIN
	SELECT * FROM tb_rank_realm;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_ride` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_ride`()
BEGIN
	SELECT * FROM tb_rank_ride;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rank_shenbing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rank_shenbing`()
BEGIN
	SELECT * FROM tb_rank_shenbing;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_rides` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_rides`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_ride WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_ride_dupl_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_ride_dupl_rank`()
BEGIN
	SELECT * FROM tb_rank_ride_dupl;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_role_mac` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_role_mac`(IN `in_guid` bigint)
BEGIN
	SELECT last_mac FROM tb_account WHERE charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_setting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_setting`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_setting WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_simple_user_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_simple_user_info`(IN `in_guid` bigint)
BEGIN
	SELECT tb_player_info.charguid as charguid, name, prof, iconid, 
	level, power, arms, dress, head, suit, weapon, valid, 
	forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, 
	UNIX_TIMESTAMP(tb_account.last_logout) as last_logout, account, vip_level, vplan, wuhunid, shenbingid, wingid, suitflag from tb_player_info 
	left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	where tb_player_info.charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_soulinfo_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_soulinfo_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *
	FROM tb_soul_info 
	WHERE in_charguid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_title` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_title`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_title WHERE charguid=in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_total_recharge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_total_recharge`(IN `in_charguid` bigint)
BEGIN
	SELECT SUM(coins) AS total_coins, SUM(money) AS total_money FROM tb_exchange_record WHERE role_id = in_charguid GROUP BY NULL;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_total_virtual_recharge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_total_virtual_recharge`(IN `in_charguid` bigint)
BEGIN
	SELECT SUM(moneys) AS total_money FROM tb_virtual_recharge WHERE role_id = in_charguid GROUP BY NULL;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_waterdup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_waterdup`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_waterdup where charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_waterdup_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_waterdup_rank`()
BEGIN
	SELECT * FROM tb_waterdup_rank;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_welfare_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_welfare_list`()
BEGIN
	SELECT tb_account.*, tb_player_info.name
	FROM tb_account 
	LEFT JOIN tb_player_info
	ON tb_player_info.charguid = tb_account.charguid	
	WHERE tb_account.welfare > 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_worldboss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_worldboss`()
BEGIN
	SELECT * FROM tb_worldboss;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_ws_human_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_ws_human_info`(IN `in_charguid` bigint)
BEGIN
	SELECT P.charguid,P.level,P.name,P.prof,P.blesstime, M.base_map,M.game_map,P.blesstime2,P.blesstime3,P.HBCheatNum
	FROM tb_player_info AS P,tb_player_map_info AS M where in_charguid = P.charguid AND in_charguid = M.charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_wuhun_by_ls` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_wuhun_by_ls`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_wuhuns where charguid=in_charguid and wuhun_state = 1;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_select_yaodan_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_select_yaodan_info`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_yaodan WHERE charguid=in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_set_gm_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_set_gm_account`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_oper` varchar(32), IN `in_time` int)
BEGIN
	INSERT INTO tb_gm_account(charguid, gm_level, oper, oper_time)
	VALUES (in_charguid, in_lvl, in_oper, in_time)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, gm_level = in_lvl, oper = in_oper, oper_time = in_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_add` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tb_player_marry_invite_card_add`(IN `in_charguid` bigint(20), IN `in_mailGid` bigint(20), IN `in_inviteTime` bigint(20)
													 ,IN `in_scheduleId` int(10), IN `in_inviteRoleName` varchar(32), IN `in_inviteMateName` varchar(32)
													 ,IN `in_profId` int(10))
BEGIN
	REPLACE INTO tb_player_marry_invite_card(charguid, mailGid, inviteTime, scheduleId, inviteRoleName, inviteMateName, profId) 
	VALUES(in_charguid, in_mailGid, in_inviteTime, in_scheduleId, in_inviteRoleName, in_inviteMateName, in_profId);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tb_player_marry_invite_card_delete`(IN `in_mailGid` bigint(20))
BEGIN
	DELETE FROM tb_player_marry_invite_card WHERE mailGid = in_mailGid AND inviteTime = 0;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_query` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_tb_player_marry_invite_card_query`(IN `in_charguid` bigint(20))
BEGIN
	SELECT * FROM tb_player_marry_invite_card WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_aura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_aura`(IN `in_charguid` bigint, IN `in_aura_gid` bigint, IN `in_aura_id` bigint, IN `in_cast_id` bigint, IN `in_end_time` bigint, IN `in_flags` int)
BEGIN
	INSERT INTO tb_aura(charguid, aura_gid, aura_id, cast_id, end_time, flags)
	VALUES (in_charguid, in_aura_gid, in_aura_id, in_cast_id, in_end_time, in_flags) 
	ON DUPLICATE KEY UPDATE  aura_id = in_aura_id, cast_id = in_cast_id, end_time = in_end_time, flags = in_flags;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_babel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_babel`(IN `in_charguid` bigint, IN `in_level` int, IN `in_time` int, IN `in_count` int )
BEGIN
	INSERT INTO tb_babel(charguid, level, time, count)
	VALUES (in_charguid, in_level, in_time, in_count) 
	ON DUPLICATE KEY UPDATE  level = in_level, time = in_time, count = in_count;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_babel_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_babel_rank`(IN `in_rank` int, IN `in_guid` bigint, IN `in_val` int, IN `in_name` varchar(32), IN `in_level` int)
BEGIN
	INSERT INTO tb_babel_rank(rank, guid, value, name, level)
	VALUES (in_rank, in_guid, in_val, in_name, in_level) 
	ON DUPLICATE KEY UPDATE  guid = in_guid, value = in_val, name = in_name, level = in_level;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_boss_media` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_boss_media`(IN `in_charguid` bigint, IN `in_level` int, IN `in_star` int, IN `in_process` int,
				IN `in_point` int, IN `in_type_1` int, IN `in_type_2` int, IN `in_type_3` int, IN `in_type_4` int)
BEGIN
	INSERT INTO tb_player_boss_media(charguid, level, star, process, point, type_1, type_2, type_3, type_4)
	VALUES (in_charguid, in_level, in_star, in_process, in_point, in_type_1, in_type_2, in_type_3, in_type_4) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_level, star = in_star, process = in_process, 
		point = in_point, type_1 = in_type_1, type_2 = in_type_2, type_3 = in_type_3, type_4 = in_type_4;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_cheat_num` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_cheat_num`(IN `in_charguid` bigint, IN `in_HBCheatNum` int)
BEGIN
	update tb_player_info set HBCheatNum = in_HBCheatNum where in_charguid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_consignment_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint
	, IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128))
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, newgroup, newgroupbind,
	wash,newgrouplvl,wash_attr)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_newgroup, in_newgroupbind,
	in_wash,in_newgrouplvl,in_wash_attr)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_cross_arena_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_cross_arena_history`(IN `in_seasonid` int, IN `in_arenaid` int, IN `in_name` varchar(64), IN `in_prof` int, IN `in_power` bigint(20))
BEGIN
  INSERT INTO tb_crossarena_history(seasonid, arenaid, name, prof, power)
  VALUES (in_seasonid, in_arenaid, in_name, in_prof, in_power) 
  ON DUPLICATE KEY UPDATE seasonid=in_seasonid, arenaid=in_arenaid, name=in_name, prof=in_prof, power=in_power;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_cross_arena_xiazhu` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_cross_arena_xiazhu`(IN `in_charguid` bigint, IN `in_seasonid` int, IN `in_targetguid` bigint, IN `in_xiazhunum` int)
BEGIN
	INSERT INTO tb_crossarena_xiazhu(charguid, seasonid, targetguid, xiazhunum)
	VALUES (in_charguid, in_seasonid, in_targetguid, in_xiazhunum) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, seasonid = in_seasonid,	targetguid = in_targetguid, xiazhunum = in_xiazhunum;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_cross_boss_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_cross_boss_history`(IN `in_id` int, IN `in_avglv` int, 
	IN `in_firstname1` varchar(32), IN `in_killname1` varchar(32),
	IN `in_firstname2` varchar(32), IN `in_killname2` varchar(32),
	IN `in_firstname3` varchar(32), IN `in_killname3` varchar(32),
	IN `in_firstname4` varchar(32), IN `in_killname4` varchar(32),
	IN `in_firstname5` varchar(32), IN `in_killname5` varchar(32))
BEGIN
	INSERT INTO tb_crossboss_history(id, avglv, firstname1, killname1, firstname2, killname2, firstname3, killname3, firstname4, killname4, firstname5, killname5)
	VALUES (in_id, in_avglv, in_firstname1, in_killname1, in_firstname2, in_killname2, in_firstname3, in_killname3, in_firstname4, in_killname4, in_firstname5, in_killname5) 
	ON DUPLICATE KEY UPDATE id=in_id, avglv=in_avglv, firstname1=in_firstname1, killname1=in_killname1, firstname2=in_firstname2, killname2=in_killname2
	, firstname3=in_firstname3, killname3=in_killname3, firstname4=in_firstname4, killname4=in_killname4, firstname5=in_firstname5, killname5=in_killname5;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_day_history` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_day_history`(IN `in_date` VARCHAR(32),IN `in_maxonline` int)
BEGIN
	insert into tb_day_history(date_time, maxonline) values(in_date, in_maxonline) on duplicate key update maxonline=in_maxonline;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_disciple` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_disciple`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_quality` int, IN `in_name` varchar(32),
	IN `in_skill_1` int, IN `in_skill_2` int, IN `in_skill_3` int, IN `in_level` int, IN `in_exp` int, IN `in_icon` int, IN `in_attr` int,
	IN `in_status` int)
BEGIN
	INSERT INTO tb_player_disciple(gid, charguid, quality, name, skill_1, skill_2, skill_3, level, exp, icon, attr, status)
	VALUES (in_gid, in_charguid,in_quality, in_name, in_skill_1, in_skill_2, in_skill_3, in_level, in_exp, in_icon,in_attr,in_status) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, quality = in_quality, name = in_name, skill_1 = in_skill_1, 
		skill_2 = in_skill_2, skill_3 = in_skill_3, level = in_level, exp = in_exp, icon = in_icon, attr = in_attr, status = in_status;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_dungeon_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_dungeon_group`(IN `in_charguid` bigint, IN `in_group_id` bigint, IN `in_diff` int, IN `in_free_count` int, IN `int_buy_count` int, IN `in_best_time` int, IN `in_scores` varchar(64))
BEGIN
	INSERT INTO tb_player_dungeon_group(charguid, group_id, diff, free_count, buy_count, best_time, scores)
	VALUES (in_charguid, in_group_id, in_diff, in_free_count, int_buy_count, in_best_time, in_scores)
	ON DUPLICATE KEY UPDATE diff = in_diff, free_count = in_free_count, buy_count = int_buy_count, best_time = in_best_time, scores = in_scores;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_dupl_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_dupl_rank`(IN `in_groupid` int, IN `in_rank` int, IN `in_guid` bigint, IN `in_value` int, IN `in_name` varchar(32), IN `in_icon` int)
BEGIN
	INSERT INTO tb_dupl_rank(groupid, rank, guid, value, name, icon)
	VALUES (in_groupid, in_rank, in_guid, in_value, in_name, in_icon) 
	ON DUPLICATE KEY UPDATE groupid = in_groupid, rank = in_rank, value = in_value, name = in_name, icon = in_icon;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_extremity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_extremity`(IN `in_charguid` bigint, IN `in_type` int, IN `in_headid` int, IN `in_name` varchar(32), IN `in_rankval` bigint, IN `in_updatetime` int, IN `in_getawardtime` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_extremity_rank(charguid, type, headid, name,rankval,updatetime,getawardtime,time_stamp)
	VALUES (in_charguid, in_type, in_headid,in_name,in_rankval,in_updatetime,in_getawardtime,in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, type = in_type, headid = in_headid, name = in_name, rankval = in_rankval, updatetime = in_updatetime, getawardtime = in_getawardtime, time_stamp = in_time_stamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_fashion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_fashion`(IN `in_charguid` bigint, IN `in_f_tid` int, IN `in_time` bigint)
BEGIN
	INSERT INTO tb_fashion(charguid, f_tid, time)
	VALUES (in_charguid, in_f_tid, in_time) 
	ON DUPLICATE KEY UPDATE  charguid = in_charguid, f_tid = in_f_tid, time = in_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_festival_activity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_festival_activity`(IN `in_id` bigint, IN `in_festival_param` int)
BEGIN
	INSERT INTO tb_festivalact(id, festival_param)
	VALUES (in_id, in_festival_param) 
	ON DUPLICATE KEY UPDATE id = in_id, festival_param = in_festival_param;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_forbidden_acc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_forbidden_acc`(IN  `in_charguid`  bigint(20), IN `in_forb_acc_last` int, IN `in_forb_acc_time` int, 
					IN `in_super` int, IN `in_reason` VARCHAR(128))
BEGIN
	UPDATE tb_account SET  forb_acc_last = in_forb_acc_last, forb_acc_time = in_forb_acc_time,
		 forb_type = in_super, lock_reason = in_reason
	WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_forbidden_acc_by_acc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_forbidden_acc_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_acc_last` int, IN `in_forb_acc_time` int, IN `in_groupid` int)
BEGIN
	UPDATE tb_account SET  forb_acc_last = in_forb_acc_last, forb_acc_time = in_forb_acc_time
	WHERE account = in_account and groupid = in_groupid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_forbidden_chat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_forbidden_chat`(IN  `in_charguid`  bigint(20), IN `in_forb_chat_last` int, IN `in_forb_chat_time` int)
BEGIN
	UPDATE tb_account SET  forb_chat_last = in_forb_chat_last, forb_chat_time = in_forb_chat_time
	WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_forbidden_chat_by_acc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_forbidden_chat_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_chat_last` int, IN `in_forb_chat_time` int, IN `in_groupid` int)
BEGIN
	UPDATE tb_account SET  forb_chat_last = in_forb_chat_last, forb_chat_time = in_forb_chat_time
	WHERE account = in_account and groupid = in_groupid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_forb_mac` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_forb_mac`(IN `in_mac` varchar(32), IN `in_guid` bigint, IN `in_skey` int, IN `in_reason` varchar(128), IN `in_locktime` int)
BEGIN
	INSERT INTO tb_forb_mac(mac, charguid, skey, reason, locktime)
	VALUES (in_mac, in_guid, in_skey, in_reason, in_locktime)
	ON DUPLICATE KEY UPDATE
	charguid = in_guid, skey = in_skey, reason = in_reason, locktime = in_locktime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_gm_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_gm_account`(IN `in_charguid` bigint, IN `in_gm` int)
BEGIN
	UPDATE tb_account SET gm_flag = in_gm WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_boss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_boss`(IN `in_gid` bigint, IN `in_boss_time` bigint)
BEGIN
	INSERT INTO tb_guild_boss(gid, boss_time)
 	VALUES (in_gid, in_boss_time)
 	ON DUPLICATE KEY UPDATE boss_time = in_boss_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_citywar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_citywar`(IN `in_id` int, IN `in_atkgid` bigint, IN `in_defgid` bigint, IN `in_goduid` bigint, IN `in_contdef` int, In `in_contreward` int,
IN `in_statusgid1` bigint, IN `in_statusgid2` bigint, IN `in_statusgid3` bigint, IN `in_statusgid4` bigint,
IN `in_statusuid1` bigint, IN `in_statusuid2` bigint, IN `in_statusuid3` bigint, IN `in_statusuid4` bigint, IN `in_isfirst` int)
BEGIN
	INSERT INTO tb_guild_citywar(id, atkgid, defgid, goduid, contdef, contreward, 
	statusgid1, statusgid2, statusgid3, statusgid4,
	statusuid1, statusuid2, statusuid3, statusuid4, isfirst)
	VALUES (in_id, in_atkgid, in_defgid, in_goduid, in_contdef, in_contreward, 
	in_statusgid1, in_statusgid2, in_statusgid3, in_statusgid4, 
	in_statusuid1, in_statusuid2, in_statusuid3, in_statusuid4, in_isfirst)
	ON DUPLICATE KEY UPDATE  id = in_id, atkgid = in_atkgid, defgid = in_defgid, goduid = in_goduid, contdef = in_contdef, contreward = in_contreward,
	statusgid1 = in_statusgid1, statusgid2 = in_statusgid2, statusgid3 = in_statusgid3, statusgid4 = in_statusgid4,
	statusuid1 = in_statusuid1, statusuid2 = in_statusuid2, statusuid3 = in_statusuid3, statusuid4 = in_statusuid4,
	isfirst = in_isfirst;	
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_hell` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_hell`(IN `in_charguid` bigint, IN `in_gid` bigint, IN `in_lasttime` bigint, IN `in_hellinfo` varchar(256))
BEGIN
	INSERT INTO tb_guild_hell(charguid, gid, lasttime, hellinfo)
	VALUES (in_charguid, in_gid, in_lasttime, in_hellinfo) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, gid = in_gid, lasttime = in_lasttime, hellinfo = in_hellinfo;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_item` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int, IN `in_super1` varchar(64), 
IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64),
IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint,
IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128))
BEGIN
	INSERT INTO tb_guild_storage(itemgid, gid, itemtid, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper,newgroup,newgroupbind,
	wash,newgrouplvl,wash_attr)
	VALUES (in_itemgid, in_gid, in_itemtid, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper,in_newgroup,in_newgroupbind,
	in_wash,in_newgrouplvl,in_wash_attr)
	ON DUPLICATE KEY UPDATE itemgid = in_itemgid, gid = in_gid, itemtid = in_itemtid, strenid = in_strenid,
	strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper, newgroup = in_newgroup, newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_itemop` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_itemop`(IN `in_aid` bigint, IN `in_gid` bigint, IN `in_opname` varchar(64), IN `in_optime` bigint, 
IN `in_optype` int, IN `in_opitem` int, IN `in_opextra` int)
BEGIN
	INSERT INTO tb_guild_storage_op(aid, gid, opname, optime, optype, opitem, opextra)
	VALUES (in_aid, in_gid, in_opname, in_optime, in_optype, in_opitem, in_opextra)
	ON DUPLICATE KEY UPDATE gid = in_gid, opname = in_opname, optime = in_optime, optype = in_optype,
	opitem = in_opitem, opextra = in_opextra;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_mail_time` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_mail_time`(IN `in_SendTime` BIGINT)
BEGIN
	REPLACE INTO tb_LastGuildWarMailTime(id, nLastSendTime) VALUES (1, in_SendTime);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_palace` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_palace`(IN `in_id` int, IN `in_gid` bigint, IN `in_signtime` bigint)
BEGIN
	INSERT INTO tb_guild_palace(id, gid, signtime)
	VALUES (in_id, in_gid, in_signtime) 
	ON DUPLICATE KEY UPDATE id = in_id, gid = in_gid, signtime = in_signtime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_guild_palace_sign` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_guild_palace_sign`(IN `in_id` int, IN `in_gid` bigint, IN `in_gold` bigint, IN `in_signtime` bigint,IN `in_sign_state` int)
BEGIN
	INSERT INTO tb_guild_palace_sign(id, gid, gold, signtime,sign_state)
	VALUES (in_id, in_gid, in_gold, in_signtime,in_sign_state) 
	ON DUPLICATE KEY UPDATE id = in_id, gid = in_gid, gold = in_gold, signtime = in_signtime, sign_state = in_sign_state;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_power` bigint, IN `in_level` int, IN `in_name` varchar(32),
	IN `in_tid` int, IN `in_quest_lv` int, IN `in_finish_time` int, IN `in_last_time` int, IN `in_quality` int,
	IN `in_rob_cnt` int, IN `in_status` int, IN `in_mon_1` int, IN `in_mon_2` int, IN `in_mon_3` int, IN `in_item_id` int,
	IN `in_reward_type` int, IN `in_reward` bigint, IN `in_exp` bigint, IN `in_dis_1` bigint, IN `in_dis_2` bigint, IN `in_dis_3` bigint)
BEGIN
	INSERT INTO tb_homeland_quest(gid, charguid, power, level, name,
		tid, quest_lv, finish_time, last_time, quality,
		rob_cnt, status, mon_1, mon_2, mon_3, item_id, 
		reward_type, reward, exp, disciple_1, disciple_2, disciple_3)
	VALUES (in_gid, in_charguid, in_power, in_level, in_name,
		in_tid, in_quest_lv, in_finish_time, in_last_time, in_quality,
		in_rob_cnt, in_status, in_mon_1, in_mon_2, in_mon_3, in_item_id, 
		in_reward_type,in_reward,in_exp,in_dis_1,in_dis_2,in_dis_3) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, power = in_power, level = in_level, name = in_name,
		tid = in_tid, quest_lv = in_quest_lv, finish_time = in_finish_time, last_time = in_last_time, quality = in_quality,
		rob_cnt = in_rob_cnt, status = in_status, mon_1 = in_mon_1, mon_2 = in_mon_2, mon_3 = in_mon_3, item_id = in_item_id,
		reward_type = in_reward_type, reward = in_reward, exp = in_exp, disciple_1 = in_dis_1, disciple_2 = in_dis_2, disciple_3 = in_dis_3;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_login_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_login_info`(IN `in_guid` bigint, IN `in_ip` VARCHAR(32), IN `in_mac` VARCHAR(32), IN `in_timestamp` bigint)
BEGIN
	UPDATE tb_account 
	SET last_ip = in_ip, last_mac = in_mac, last_login = FROM_UNIXTIME(in_timestamp) 
	WHERE charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_merge_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_merge_info`(IN `in_srvid` int, IN `in_mergeid` int, IN `in_cnt` int)
BEGIN
	INSERT INTO tb_merge(srvid, mergeid, cnt)
	VALUES (in_srvid, in_mergeid, in_cnt) 
	ON DUPLICATE KEY UPDATE srvid = in_srvid, mergeid = in_mergeid,	cnt = in_cnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_party_group_charge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_party_group_charge`(IN `in_id` int, IN `in_cnt` int, IN `in_extracnt` int)
BEGIN
	INSERT INTO tb_group_charge(id, cnt, extracnt)
	VALUES (in_id, in_cnt, in_extracnt) 
	ON DUPLICATE KEY UPDATE id=in_id, cnt=in_cnt, extracnt=in_extracnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_party_group_purchase` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_party_group_purchase`(IN `in_id` int, IN `in_cnt` int, IN `in_extracnt` int, IN `in_param1` int, IN `in_param2` int)
BEGIN
	INSERT INTO tb_group_purchase(id, cnt, extracnt, param1, param2)
	VALUES (in_id, in_cnt, in_extracnt, in_param1, in_param2)
	ON DUPLICATE KEY UPDATE id = in_id, cnt = in_cnt, extracnt = in_extracnt, param1 = in_param1,
	param2 = in_param2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_party_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_party_rank`(IN `in_id` int, IN `in_name` varchar(32), IN `in_prof` int, IN `in_arms` int,
IN `in_dress` int, IN `in_fashionhead` int, IN `in_fashionarms` int, IN `in_fashiondress` int, IN `in_wuhunid` int, 
IN `in_wingid` int, IN `in_suitflag` int, IN `in_rank1` varchar(64), IN `in_rank2` varchar(64), IN `in_rank3` varchar(64), 
IN `in_rank4` varchar(64), IN `in_rank5` varchar(64), IN `in_rank6` varchar(64), IN `in_rank7` varchar(64), 
IN `in_rank8` varchar(64), IN `in_rank9` varchar(64), IN `in_rank10` varchar(64), IN `in_param1` int,
IN `in_param2` int)
BEGIN
	INSERT INTO tb_party_rank(id, name, prof, arms, dress, fashionhead, fashionarms, fashiondress, wuhunid, 
	wingid, suitflag, rank1, rank2, rank3, rank4, rank5, rank6, rank7, rank8, rank9, rank10, param1, param2)
	VALUES (in_id, in_name, in_prof, in_arms, in_dress, in_fashionhead, in_fashionarms, in_fashiondress, in_wuhunid,
	in_wingid, in_suitflag, in_rank1, in_rank2, in_rank3, in_rank4, in_rank5, in_rank6, in_rank7, in_rank8,
	in_rank9, in_rank10, in_param1, in_param2)
	ON DUPLICATE KEY UPDATE id = in_id, name = in_name, prof = in_prof, arms = in_arms, dress = in_dress,
	fashionhead = in_fashionhead, fashionarms = in_fashionarms, fashiondress = in_fashiondress, wuhunid = in_wuhunid,
	wingid = in_wingid, suitflag = in_suitflag, rank1 = in_rank1, rank2 = in_rank2, rank3 = in_rank3, rank4 = in_rank4,
	rank5 = in_rank5, rank6 = in_rank6, rank7 = in_rank7, rank8 = in_rank8, rank9 = in_rank9, rank10 = in_rank10,
	param1 = in_param1, param2 = in_param2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_plat_setting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_plat_setting`(IN `in_key` int, IN `in_value` varchar(128))
BEGIN
	INSERT INTO tb_setting(key_type, value)
	VALUES (in_key, in_value)
	ON DUPLICATE KEY UPDATE
	value = in_value;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_challenge_dupl` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_challenge_dupl`(IN `in_charguid` bigint, IN `in_count` int, IN `in_today` int, IN `in_history` int)
BEGIN
	INSERT INTO tb_player_challenge_dupl(charguid, count, today, history)
	VALUES (in_charguid, in_count, in_today, in_history) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, count = in_count, today = in_today, history = in_history;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_hl_quest` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_tid` int, 
	IN `in_need_time` int, IN `in_quality` int, IN `in_level` int,IN `in_mon_1` int, IN `in_mon_2` int, 
	IN `in_mon_3` int, IN `in_item_id` int, IN `in_reward_type` int, IN `in_reward` bigint, IN `in_exp` bigint)
BEGIN
	INSERT INTO tb_player_hl_quest(gid, charguid, tid,
	 				need_time, quality, level, mon_1, mon_2, 
	 				mon_3, item_id, reward_type, reward, exp)
	VALUES (in_gid, in_charguid, in_tid,
		in_need_time, in_quality, in_level, in_mon_1, in_mon_2,
		in_mon_3, in_item_id, in_reward_type, in_reward, in_exp) 
	ON DUPLICATE KEY UPDATE tid = in_tid,
			need_time = in_need_time, quality = in_quality, level = in_level, mon_1 = in_mon_1, mon_2 = in_mon_2, 
			mon_3 = in_mon_3, item_id = in_item_id, reward_type = in_reward_type, reward = in_reward, exp = in_exp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_homeland` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
	IN `in_xunxian` int, IN `in_rob` int, IN `in_rob_cd` int, IN `in_xunxian_ref` int, IN `in_xunxian_cnt` int,
	IN `in_quest_ref` int, IN `in_rob_cnt_cd` int, IN `in_recruit` int, IN `in_quest_cnt` int)
BEGIN
	INSERT INTO tb_player_homeland(charguid, main_lv, quest_lv, xunxian_lv, rob_cnt, rob_cd, xunxian_ref, xunxian_cnt,
	 quest_ref, rob_cnt_cd, recruit, quest_cnt)
	VALUES (in_charguid, in_main, in_quest, in_xunxian, in_rob, in_rob_cd, in_xunxian_ref, in_xunxian_cnt,
	 in_quest_ref, in_rob_cnt_cd, in_recruit, in_quest_cnt) 
	ON DUPLICATE KEY UPDATE main_lv = in_main, quest_lv = in_quest, xunxian_lv = in_xunxian, 
		rob_cnt = in_rob, rob_cd = in_rob_cd, xunxian_ref = in_xunxian_ref, xunxian_cnt = in_xunxian_cnt, quest_ref = in_quest_ref,
		 rob_cnt_cd = in_rob_cnt_cd, recruit = in_recruit, quest_cnt = in_quest_cnt;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_prerogative` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_prerogative`(IN `in_charguid` bigint, IN `in_type` int, IN `in_param_32` int, IN `in_param_64` bigint)
BEGIN
	INSERT INTO tb_player_prerogative(charguid, prerogative, param_32, param_64)
	VALUES (in_charguid, in_type, in_param_32, in_param_64) 
	ON DUPLICATE KEY UPDATE param_32 = in_param_32, param_64 = in_param_64;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_recharge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_recharge`(IN `in_order_id` VARCHAR(32))
BEGIN
	update tb_exchange_record set recharge = recharge + 1 where order_id = in_order_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_ride_dupl` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_ride_dupl`(IN `in_charguid` bigint, IN `in_count` int, IN `in_today` int, IN `in_history` int)
BEGIN
	INSERT INTO tb_player_ride_dupl(charguid, count, today, history)
	VALUES (in_charguid, in_count, in_today, in_history) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, count = in_count, today = in_today, history = in_history;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_player_time_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_player_time_info`(IN `in_guid` bigint, IN `in_timestamp` bigint)
BEGIN
	UPDATE tb_account SET last_logout = FROM_UNIXTIME(in_timestamp) where in_guid = charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_crossscore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_crossscore`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_crossscore(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_extremity_boss` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_extremity_boss`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_extremity_boss(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_extremity_monster` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_extremity_monster`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_extramity_monster(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_level` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_level`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_level(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_lingshou` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_lingshou`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_lingshou(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_lingzhen` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_lingzhen`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_lingzhen(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_power` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_power`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_power(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_realm` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_realm`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_realm(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_ride` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_ride`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_ride(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_rank_shenbing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_rank_shenbing`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_shenbing(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_ride_dupl_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_ride_dupl_rank`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_layer` int, IN `in_time` int, IN `in_power` bigint,
		 IN `in_name_1` varchar(32), IN `in_name_2` varchar(32), IN `in_name_3` varchar(32), IN `in_name_4` varchar(32), IN `in_type` int)
BEGIN
	INSERT INTO tb_rank_ride_dupl(rank, charguid, layer, time, power, name_1, name_2, name_3, name_4, type)
	VALUES (in_rank, in_charguid, in_layer, in_time, in_power, in_name_1, in_name_2, in_name_3, in_name_4, in_type) 
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, layer = in_layer, time = in_time, power = in_power, 
		name_1 = in_name_1, name_2 = in_name_2, name_3 = in_name_3, name_4 = in_name_4, type = in_type;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_setting` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_setting`(IN `in_charguid` bigint, IN `in_param1` int, IN `in_param2` varchar(128))
BEGIN
	INSERT INTO tb_player_setting(charguid, param1, param2)
	VALUES (in_charguid, in_param1, in_param2) 
	ON DUPLICATE KEY UPDATE  param1 = in_param1, param2 = in_param2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_title` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_title`(IN `in_charguid` bigint, IN `in_title_id` int, in `in_title_status` int, IN `in_title_time` bigint)
BEGIN
	INSERT INTO tb_player_title(charguid, title_id, title_status, title_time)
	VALUES (in_charguid, in_title_id, in_title_status, in_title_time)
	ON DUPLICATE KEY UPDATE title_status = in_title_status, title_time = in_title_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_waterdup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_waterdup`(IN `in_charguid` bigint, IN `in_history_wave` int,
 IN `in_history_exp` bigint, IN `in_today_count` int, IN `in_reward_rate` double, IN `in_reward_exp` double,
 IN `in_history_kill` int, IN `in_buy_count` int)
BEGIN
	INSERT INTO tb_waterdup(charguid, history_wave, history_exp, today_count, reward_rate, reward_exp, history_kill, buy_count)
	VALUES (in_charguid, in_history_wave, in_history_exp, in_today_count, in_reward_rate, in_reward_exp, in_history_kill, in_buy_count) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, history_wave = in_history_wave, 
	history_exp = in_history_exp, today_count = in_today_count, reward_rate = in_reward_rate, reward_exp = in_reward_exp,
	history_kill = in_history_kill, buy_count = in_buy_count;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_waterdup_rank` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_waterdup_rank`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_wave` int, IN `in_name` varchar(32), IN `in_icon` int,
      IN `in_updatetime` bigint)
BEGIN
	INSERT INTO tb_waterdup_rank(rank, charguid, wave, name, icon, updatetime)
	VALUES (in_rank, in_charguid, in_wave, in_name, in_icon, in_updatetime) 
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, wave = in_wave, name = in_name, icon = in_icon, updatetime = in_updatetime;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_welfare_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_welfare_account`(IN `in_charguid` bigint, IN `in_welfare` int, IN `in_oper` varchar(64), IN `in_oper_time` int)
BEGIN
	UPDATE tb_account
	SET welfare = in_welfare, oper = in_oper, oper_time = in_oper_time
	WHERE charguid = in_charguid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_ws_offlogic` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_update_ws_offlogic`(IN `in_aid` bigint, IN `in_charguid` bigint, IN `in_type` int, 
			IN `in_param_b1` bigint, IN `in_param_b2` bigint,
	 		IN `in_param1` int, IN `in_param2` int,
	 		IN `in_param_str` varchar(32), IN `in_time` bigint)
BEGIN
	INSERT INTO tb_ws_offline_logic(aid, charguid, type, param_b1, param_b2, param1, param2, param_str, save_time)
	VALUES (in_aid, in_charguid, in_type, in_param_b1, in_param_b2, in_param1, in_param2, in_param_str, in_time) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, type=in_type, param_b1=in_param_b1, param_b2=in_param_b2,
		param1=in_param1, param2=in_param2, param_str = in_param_str, save_time = in_time;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_virtual_recharge_insert` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_virtual_recharge_insert`(IN `in_order_id` bigint, IN `in_account` varchar(32), IN `in_role_id` bigint, IN `in_name` varchar(32),
							IN `in_moneys` int, IN `in_oper` varchar(32), IN `in_time` int)
BEGIN
  INSERT INTO tb_virtual_recharge(order_id, account, role_id, name, moneys, oper, time)
  VALUES (in_order_id, in_account, in_role_id, in_name, in_moneys, in_oper, in_time);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_virtual_recharge_select` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_virtual_recharge_select`(IN `in_time1` int, IN `in_time2` int)
BEGIN
 	SELECT * FROM tb_virtual_recharge
 	WHERE time > in_time1 AND time < in_time2;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_worldboss_insert_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_worldboss_insert_update`(IN `in_id` bigint,  IN `in_isdead` int, IN `in_lastkiller` bigint,IN `in_killername` varchar(64))
BEGIN
	INSERT INTO tb_worldboss(id, isdead, lastkiller, killername)
	VALUES (in_id, in_isdead, in_lastkiller, in_killername) 
	ON DUPLICATE KEY UPDATE id=in_id, isdead=in_isdead, lastkiller=in_lastkiller, killername=in_killername;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ws_offlogic_select_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50020 DEFINER=`root`@`localhost`*/ /*!50003 PROCEDURE `sp_ws_offlogic_select_by_id`(IN `in_guid` bigint)
BEGIN
	SELECT * from tb_ws_offline_logic where charguid = in_guid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-03-03 13:33:20
