-- hwm
-- 2014-02-27 
-- 协防功能，增加协防字段
ALTER TABLE `troops`
    ADD COLUMN `helpdefense` VARCHAR(2000) NOT NULL AFTER `defense`;

--
-- Table structure for table `alliance_events`
--  lmh
--  2014-02-27 
--  军团事件

-- DROP TABLE IF EXISTS `alliance_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alliance_events` (
  `aid` int(10) unsigned NOT NULL DEFAULT '0',
  `events` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

ALTER TABLE `alliance`
    ADD COLUMN `fight_updated_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `raising_rf`,
    ADD COLUMN `levelup_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `fight_updated_at`;


-- Dump completed on 2014-03-08 15:40:57
-- hwm 
-- 活动

-- DROP TABLE IF EXISTS `active`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '0off|1on',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `active`
--
-- WHERE:  id=1

LOCK TABLES `active` WRITE;
/*!40000 ALTER TABLE `active` DISABLE KEYS */;
INSERT INTO `active` (`id`, `name`, `type`, `st`, `et`, `status`, `updated_at`) VALUES (1,'firstRecharge',1,0,1849306698,1,1394111108);
/*!40000 ALTER TABLE `active` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

-- DROP TABLE IF EXISTS `useractive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `useractive` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(2000) NOT NULL,
  `takeaward` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `take_at` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




-- ---------------------------------------------------------------------------------------------------------------------


-- 2014-03-14
-- hwm
-- 活动字段加长

ALTER TABLE `useractive`
  ALTER `info` DROP DEFAULT;
ALTER TABLE `useractive`
  CHANGE COLUMN `info` `info` VARCHAR(5000) NOT NULL AFTER `uid`;

-- 2014-03-19
-- lmh
-- 三期  军团副本

ALTER TABLE `alliance_members` ADD `reward_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `raising_at` ;
ALTER TABLE `alliance_members` ADD `attack_at` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `reward_at` ;
ALTER TABLE `alliance_members` ADD `barrier` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `attack_at` ;
ALTER TABLE `alliance_members` ADD `userais` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `raising` ;
ALTER TABLE `alliance_members` CHANGE `userais` `use_rais` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0';

-- DROP TABLE IF EXISTS `alliance_barrier`;
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


-- Dump completed on 2014-03-19  9:56:06


-- ------------------------------------------------------------------------------------
-- 20140322
-- hwm
-- 公告带礼包字段

ALTER TABLE `notice` ADD COLUMN `gift` TINYINT(3) UNSIGNED NULL DEFAULT '0' AFTER `user_to`;



-- -------------------------------------------------------------------------------------

-- 序列号礼包卡
CREATE TABLE `giftbag` (
  `cdkey` varchar(50) NOT NULL,
  `uid` int(10) unsigned DEFAULT '0',
  `type` tinyint(3) unsigned NOT NULL,
  `bag` tinyint(3) unsigned NOT NULL,
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `zoneid` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`cdkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------
-- 20140421
-- 装备与精英关卡
CREATE TABLE `echallenge` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(5000) DEFAULT NULL,
  `dailykill` varchar(5000) DEFAULT NULL,
  `resetnum` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `reset_at` int(10) unsigned NOT NULL DEFAULT '0',
  `star` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `accessory` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(15000) NOT NULL COMMENT '背包信息',
  `used` varchar(1000) NOT NULL COMMENT '使用中的装备',
  `fragment` varchar(1500) NOT NULL COMMENT '碎片',
  `props` varchar(1500) NOT NULL,
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  `refine_at` int(11) unsigned NOT NULL DEFAULT '0',
  `upgrade_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户装备表';

-- --------------------------------
-- 20140504
-- 成长计划
-- lmh
ALTER TABLE `userinfo` ADD `grow` INT( 4 ) UNSIGNED NULL DEFAULT '0' COMMENT '是否购买成长计划' AFTER `guest` ;
ALTER TABLE `userinfo` ADD `growrd` INT( 4 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `grow` ;

-- --------------------------------
-- 20140506
-- 自定义邮件礼包
-- lmh
ALTER TABLE `notice` ADD `item` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `gift` ;

-- ------------------------------------------------------------------------------------------------------------------------------

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
-- 20140521
-- 军团大战 玩家驻守的部队
-- hwm
ALTER TABLE `troops`
  ADD COLUMN `alliancewar` VARCHAR(2000) NOT NULL DEFAULT '' COMMENT '军团战部队' AFTER `attack`;

  -- --------------------------------
  -- 20140607
  -- 军团战用户数据
  -- hwm
CREATE TABLE `useralliancewar` (
  `uid` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `b1` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '冶炼专家',
  `b2` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '指挥专家',
  `b3` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '采集专家',
  `b4` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '统计专家',
  `upgradeinfo` VARCHAR(1000) NOT NULL DEFAULT '',
  `cdtime_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  `battle_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  `buff_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  `updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
)
COMMENT='用户军团战斗信息表'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=0;

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

-- --------------------------------
-- 2014/6/23
-- 军团商店已购买物品信息
-- hwm
ALTER TABLE `props` ADD COLUMN `allianceinfo` VARCHAR(2000) NOT NULL DEFAULT '' AFTER `info`;


--  ----------------------------------
--  2014/6/23
--  增加个人vip点数
--  killer

ALTER TABLE `userinfo` ADD `vippoint` INT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `vip` ;

--  ----------------------------------
--  2014/7/7
--  活动取消唯一索引
--  hwm

ALTER TABLE `active` DROP INDEX `name`;


--  ---------------------------------- 
-- 生成日期: 2014 年 07 月 13 日 00:00
-- killer 
-- 军事演习表
-- --------------------------------------------------------

--
-- 表的结构 `userarena`
--

CREATE TABLE IF NOT EXISTS `userarena` (
  `uid` int(10) unsigned NOT NULL,
  `ranking` int(10) unsigned NOT NULL DEFAULT '0',
  `ranked` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上一次排名',
  `ranked_at` int(10) unsigned NOT NULL DEFAULT '0',
  `victory` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '连胜次数',
  `troops` varchar(1000) NOT NULL DEFAULT '[]',
  `attack_at` int(10) unsigned NOT NULL DEFAULT '0',
  `attack_count` int(10) unsigned NOT NULL DEFAULT '0',
  `attack_num` int(10) unsigned NOT NULL DEFAULT '5',
  `cdtime_at` int(10) unsigned NOT NULL DEFAULT '0',
  `reward_at` int(10) NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`uid`),
  KEY `ranking` (`ranking`),
  KEY `ranking_2` (`ranking`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


--  ---------------------------------- 
-- 生成日期: 2014 年 07 月 13 日 00:07
-- killer
-- 军事演习战报表

-- 表的结构 `userarenalog`
--

CREATE TABLE IF NOT EXISTS `userarenalog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `receiver` int(10) unsigned NOT NULL,
  `dfname` varchar(100) NOT NULL,
  `isvictory` int(10) unsigned NOT NULL,
  `rank` int(4) NOT NULL,
  `type` int(4) unsigned NOT NULL,
  `content` varchar(2000) NOT NULL,
  `isRead` int(4) unsigned NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- 军事演习战报字段短了
-- 2014/7/16 18:07 
-- lmh
ALTER TABLE `userarenalog` CHANGE `content` `content` VARCHAR( 10000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ;

-- 需要直接存库的临时数据
-- 2014/7/16 18:07 
-- hwm
CREATE TABLE `freedata` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID不要用',
	`name` VARCHAR(50) NOT NULL COMMENT '英文名称',
	`info` VARCHAR(5000) NULL DEFAULT NULL COMMENT '数据',
	`update_at` INT(10) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `ming_cheng` (`name`)
)
COMMENT='系统参数'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1;

-- 北美facebookid领奖记录
-- 2014/7/25 17:17
-- ln
CREATE TABLE IF NOT EXISTS `facebookuserinfo` (
  `fid` int(10) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `facebookid` varchar(100) NOT NULL COMMENT 'facebookid',
  `rewardinfo` varchar(100) NOT NULL COMMENT '获取奖励类型',
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`fid`),
  UNIQUE KEY `facebookid` (`facebookid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 功能开关
-- 2014/8/11 11:52
-- hwm
CREATE TABLE `gameconfig` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` VARCHAR(50) NOT NULL COMMENT '功能英文名称',
  `value` INT(4) NULL DEFAULT '0' COMMENT '值',
  `comment` VARCHAR(100) NULL DEFAULT NULL COMMENT '功能说明',
  `readonly` ENUM('Y','N') NULL DEFAULT 'N' COMMENT '是否只读',
  `platform` VARCHAR(50) NULL DEFAULT NULL COMMENT '属于哪个平台（默认没有值就是公共平台的）',
  `updated_at` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name` (`name`)
)
COMMENT='游戏配制'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


-- 东南亚公告
-- 2014-08-12  15:14
-- lmh
ALTER TABLE `notice` ADD `lag` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `item` ;

ALTER TABLE `notice` ADD `nid` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `lag` ;


-- 月卡功能
-- 2014-08-5
-- lmh
ALTER TABLE `userinfo` ADD `mc` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' AFTER `growrd` ;

-- 关卡字段长度修改
-- 2014-08-20
-- ln
ALTER TABLE  `challenge` CHANGE  `info`  `info` VARCHAR( 10000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;

-- 军团优化
-- 2014-08-15
-- lmh
ALTER TABLE `alliance_members` ADD `oc` INT( 4 ) NOT NULL DEFAULT '0' COMMENT '创建或者加入军团领取一奖励' AFTER `joinline_at` ;

ALTER TABLE `userinfo` ADD `ips` VARCHAR( 8000 ) NOT NULL DEFAULT '' AFTER `mc` ;
ALTER TABLE `userinfo` ADD `ip` VARCHAR( 80 ) NOT NULL DEFAULT '' AFTER `ips` ;
ALTER TABLE `userinfo` ADD `buyts` INT( 11 ) NOT NULL DEFAULT '0' AFTER `ip` ;
ALTER TABLE `userinfo` ADD `freeg` INT( 11 ) NOT NULL DEFAULT '0' AFTER `buyts` ;
ALTER TABLE `userinfo` ADD `olt` INT( 11 ) NOT NULL DEFAULT '0' AFTER `freeg` ;
ALTER TABLE `userinfo` ADD `logdc` INT( 11 ) NOT NULL DEFAULT '0' AFTER `olt` ;
ALTER TABLE `userinfo` ADD `online_at` INT( 11 ) NOT NULL DEFAULT '0' AFTER `logdc` ;

-- 每日任务新版
-- 2014 -09-02
-- lmh 
ALTER TABLE `dailytask` ADD `newinfo` VARCHAR( 2000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL AFTER `info` ;





-- 飞流战地通讯活动话费表
-- 2014-09-04
-- ln
CREATE TABLE IF NOT EXISTS `phoneinfo` (
  `id` char(11) NOT NULL COMMENT '手机号码',
  `tradeId` varchar(32) NOT NULL,
  `uid` int(11) NOT NULL,
  `reward` int(4) NOT NULL,
  `status` varchar(4) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 活动多个配置文件支持
-- 2014-09-11
-- ln
ALTER TABLE `active` ADD `cfg` INT( 2 ) NOT NULL DEFAULT '1' AFTER `type` ;

--   管理工具发邮件（包括奖励邮件）
-- 2014-09-17
--  lmh
ALTER TABLE `mail` ADD `item` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `isRead` ;
ALTER TABLE `mail` ADD `isreward` INT( 4 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `isRead` ;
ALTER TABLE `mail` ADD `gift` INT( 4 ) NOT NULL DEFAULT '0' AFTER `isRead` ;

--
--  `sysmail`
--

CREATE TABLE IF NOT EXISTS `sysmail` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `st` int(10) NOT NULL,
  `et` int(10) NOT NULL,
  `type` int(4) NOT NULL DEFAULT '0',
  `subject` varchar(200) NOT NULL,
  `content` varchar(5000) NOT NULL,
  `gift` int(4) NOT NULL DEFAULT '0',
  `item` varchar(500) NOT NULL,
  `update_at` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 关卡累积奖励字段
-- 2014-09-19
-- ln
ALTER TABLE `challenge` ADD `reward` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' AFTER `info` ;


-- 新军衔系统 添加的字段
-- 2014 -10-09
ALTER TABLE `userinfo`
	ADD COLUMN `rp` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '军功值' AFTER `rank`,
	ADD COLUMN `drp` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '每日军功值' AFTER `rp`,
	ADD COLUMN `rpt` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '上一次获取军功时间' AFTER `drp`,
	ADD COLUMN `urt` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '更新军衔时间' AFTER `rpt`;



-- 日本坦克拉吧自定义版本
-- 2014-10-08
-- ln
ALTER TABLE  `active` ADD  `selfcfg` VARCHAR( 10000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT  '{}' AFTER  `cfg` ;

-- 系统邮件 加send
-- 2014-10-21
-- lmh
ALTER TABLE `sysmail` ADD `send` INT( 4 ) NOT NULL DEFAULT '0' AFTER `et` ;


-- 跨服战
-- lmh
-- 2014-10-13 10：00
-- 表的结构 `serverbattlecfg`
--

CREATE TABLE IF NOT EXISTS `serverbattlecfg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st` int(11) NOT NULL DEFAULT '0',
  `bid` int(11) NOT NULL DEFAULT '0' COMMENT '战斗id',
  `et` int(11) NOT NULL DEFAULT '0',
  `type` int(4) NOT NULL DEFAULT '0',
  `servers` varchar(50) DEFAULT NULL,
  `round` int(4) NOT NULL DEFAULT '0' COMMENT '轮次',
  `gap` int(4) NOT NULL DEFAULT '0',
  `info` varchar(200) DEFAULT NULL,
  `reward` varchar(5000) NOT NULL DEFAULT '{}',
  `updated_at` int(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- 跨服战信息表
-- ln
-- 2014-10-23
CREATE TABLE IF NOT EXISTS `crossinfo` (
  `uid` int(10) NOT NULL,
  `point` text NOT NULL,
  `bet` varchar(2000) NOT NULL DEFAULT '{}',
  `rank` varchar(2000) NOT NULL DEFAULT '{}',
  `battle` text,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- hwm 把活动串长度改为10000
ALTER TABLE `useractive`
  CHANGE COLUMN `info` `info` VARCHAR(10000) NOT NULL AFTER `uid`;

-- 禁言列表
-- ln
-- 2014-10-31
CREATE TABLE IF NOT EXISTS `blacklist` (
  `uid` int(10) NOT NULL,
  `info` varchar(100) NOT NULL DEFAULT '{}',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='被禁言列表';


-- 自定义配置表
-- ln
-- 2014-10-31
CREATE TABLE IF NOT EXISTS `customconfig` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(50) NOT NULL COMMENT '功能英文名称',
  `value` varchar(500) DEFAULT '{}' COMMENT '值',
  `comment` varchar(100) DEFAULT NULL COMMENT '功能说明',
  `readonly` enum('Y','N') DEFAULT 'N' COMMENT '是否只读',
  `platform` varchar(50) DEFAULT NULL COMMENT '属于哪个平台（默认没有值就是公共平台的）',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='游戏配制' AUTO_INCREMENT=1 ;

-- 数据库引擎全换成innodb的
-- hwm  
-- 2014-11-05
ALTER TABLE `userarenalog` ENGINE=InnoDB;
ALTER TABLE `facebookuserinfo` ENGINE=InnoDB;
ALTER TABLE `notice` ENGINE=InnoDB;
ALTER TABLE `phoneinfo` ENGINE=InnoDB;


-- 修改blacklist表
-- ln
-- 2014-11-7
ALTER TABLE  `blacklist` ADD  `count` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `info` ,
ADD  `st` INT( 11 ) NOT NULL DEFAULT  '0' AFTER  `count` ,
ADD  `et` INT( 11 ) NOT NULL DEFAULT  '0' AFTER  `st` ;
ALTER TABLE  `blacklist` ADD  `fresh` INT( 11 ) NOT NULL DEFAULT  '0' AFTER  `info` ;

--
-- 表的结构 `hero`
-- lmh
-- 2014-11-14

CREATE TABLE IF NOT EXISTS `hero` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hero` varchar(10000) DEFAULT NULL,
  `soul` varchar(2000) DEFAULT NULL,
  `info` varchar(200) DEFAULT NULL,
  `stats` varchar(1000) DEFAULT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- 表的结构 `friends`
-- ln
-- 2014-11-27
CREATE TABLE IF NOT EXISTS `friends` (
  `uid` int(10) NOT NULL AUTO_INCREMENT,
  `info` varchar(1000) DEFAULT NULL,
  `updated_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 增加渠道分类
-- ln
-- 2014-12-4
ALTER TABLE `sysmail` ADD `appid` INT( 10 ) NOT NULL DEFAULT '0' AFTER `type` ;
ALTER TABLE  `notice` ADD  `appid` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `type` ;

-- 远征军
-- lmh
-- 2014-12-20
CREATE TABLE IF NOT EXISTS `expedition` (
  `uid` int(10) NOT NULL,
  `grade` int(4) NOT NULL DEFAULT '0' COMMENT '按着战斗力分档次',
  `name` varchar(100) NOT NULL DEFAULT '''''',
  `aname` varchar(100) NOT NULL DEFAULT '''''',
  `info` varchar(5000) DEFAULT NULL,
  `binfo` varchar(10000) DEFAULT NULL,
  `level` int(4) NOT NULL DEFAULT '0',
  `fc` int(11) NOT NULL DEFAULT '0',
  `maxt` int(10) NOT NULL DEFAULT '0',
  `pic` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`,`grade`),
  KEY `grade` (`grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- 个人
CREATE TABLE IF NOT EXISTS `userexpedition` (
  `uid` int(10) NOT NULL,
  `eid` int(4) NOT NULL DEFAULT '1',
  `point` int(10) NOT NULL DEFAULT '0',
  `info` varchar(10000) DEFAULT '{}',
  `binfo` varchar(10000) DEFAULT NULL,
  `reset` int(4) NOT NULL DEFAULT '0',
  `reset_at` int(11) NOT NULL DEFAULT '0',
  `log` text,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 战报
CREATE TABLE IF NOT EXISTS `userexpeditionlog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `eid` int(10) NOT NULL DEFAULT '1',
  `receiver` int(10) unsigned NOT NULL,
  `dfname` varchar(100) NOT NULL,
  `dlvl` int(10) NOT NULL DEFAULT '1',
  `isvictory` int(10) unsigned NOT NULL,
  `type` int(4) unsigned NOT NULL,
  `content` varchar(10000) NOT NULL,
  `isRead` int(4) unsigned NOT NULL DEFAULT '0',
  `update_at` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--  累计充值金额
--  李明辉
--  2014 12 27

ALTER TABLE `userinfo` ADD `cost` DOUBLE NOT NULL DEFAULT '-1' COMMENT '累计充值金额' AFTER `buygems` ;

--  累计购买次数
--  黄万敏
--  2014-12-30 14:53

ALTER TABLE `userinfo` ADD `buyn` SMALLINT  NOT NULL  DEFAULT '-1'  COMMENT '累计购买次数'  AFTER `buyts`;



-- 军团跨服战带走的军饷
-- lmh
-- 2014 11-26
ALTER TABLE `userinfo` ADD `usegems` INT( 10 ) NOT NULL DEFAULT '0' COMMENT '跨服军团战金币设置' AFTER `buygems` ;

-- 2014  12-3
ALTER TABLE `userinfo` ADD `usegems_at` INT( 10 ) NOT NULL DEFAULT '0' AFTER `updated_at` ;
ALTER TABLE `userinfo` ADD `bid` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '''''' AFTER `usegems` ;
-- 军团跨服战押注信息
-- ln
-- 2014-12-03
CREATE TABLE IF NOT EXISTS `acrossinfo` (
  `uid` int(10) NOT NULL,
  `point` text NOT NULL,
  `bet` varchar(2000) NOT NULL DEFAULT '{}',
  `rank` varchar(2000) NOT NULL DEFAULT '{}',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 军团跨服战服内军团表
-- lmh
-- 2014 11-26
CREATE TABLE `alliance` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主id',
  `bid` varchar(50) NOT NULL COMMENT '跨服战标识',
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `zid` int(10) unsigned NOT NULL COMMENT '服id',
  `commander` varchar(100) DEFAULT NULL,
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `fight` int(11) unsigned NOT NULL DEFAULT '0',
  `num` int(10) unsigned NOT NULL DEFAULT '0',
  `zrank` int(10) unsigned NOT NULL COMMENT '服排名',
  `name` varchar(50) DEFAULT NULL COMMENT '军团名称',
  `basedonatenum` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '基地捐献次数',
  `basetroops` varchar(2000) DEFAULT NULL COMMENT '基地部队',
  `point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获得的总积分',
  `round` int(10) unsigned NOT NULL DEFAULT '1' COMMENT '轮次',
  `ranking` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '名次',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '1,2,3',
  `st` int(10) unsigned NOT NULL COMMENT '起始时间',
  `et` int(10) unsigned NOT NULL COMMENT '结束时间',
  `pos` varchar(32) DEFAULT NULL COMMENT '上一轮位置',
  `teams` varchar(500) NOT NULL COMMENT '上阵队伍',
  `servers` varchar(50) NOT NULL COMMENT '包含的服',
  `log` varchar(500) DEFAULT NULL COMMENT '对阵log',
  `apply_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '报名时间',
  `donate_at` int(10) NOT NULL DEFAULT '0',
  `battle_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '上次战斗时间',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_aid_zid` (`bid`,`aid`,`zid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `alliance_members` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `aid` int(11) unsigned NOT NULL,
  `zid` int(10) unsigned NOT NULL,
  `uid` int(11) unsigned NOT NULL,
  `gems` int(10) unsigned NOT NULL DEFAULT '0',
  `carrygems` int(10) unsigned NOT NULL DEFAULT '0',
  `nickname` varchar(100) DEFAULT NULL,
  `pic` int(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '1',
  `rank` int(10) unsigned NOT NULL DEFAULT '1',
  `fc` int(10) unsigned NOT NULL DEFAULT '0',
  `aname` varchar(50) DEFAULT '',
  `b1` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '冶炼',
  `b2` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '指挥',
  `b3` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '采集',
  `b4` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '统计',
  `b5` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '行军',
  `gdonatenum` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '金币捐献次数',
  `rdonatenum` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '资源捐献次数',
  `binfo` varchar(10000) NOT NULL,
  `hero` varchar(100) DEFAULT NULL,
  `heroAccessoryInfo` varchar(500) DEFAULT NULL COMMENT '英雄与配件详情',
  `troops` varchar(500) DEFAULT NULL,
  `buff_at` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_uid_aid_zid` (`bid`,`uid`,`aid`,`zid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--  跨服战bid 加唯一索引
--  lmh 
ALTER TABLE `serverbattlecfg` ADD UNIQUE (
`bid`
);

-- 军功商店
-- 李明辉
-- 2015 01.16

ALTER TABLE `userinfo` ADD `rpb` INT( 11 ) NULL DEFAULT '-1' COMMENT '军功币' AFTER `rp` ;


ALTER TABLE `props` CHANGE `info` `info` VARCHAR( 8000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;
ALTER TABLE `props` ADD `shop` VARCHAR( 2000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' AFTER `allianceinfo` ;

--  世界boss
--  lmh
--   2015 02 05
CREATE TABLE IF NOT EXISTS `worldboss` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(200) NOT NULL DEFAULT '{}',
  `binfo` varchar(2000) NOT NULL DEFAULT '{}',
  `point` varchar(100) NOT NULL DEFAULT '0' COMMENT '打掉的boss积分',
  `auto` int(4) NOT NULL DEFAULT '0',
  `attack_at` int(11) NOT NULL DEFAULT '0',
  `buy_at` int(11) NOT NULL DEFAULT '0' COMMENT '购买buff时间',
  `reward_at` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 每日答题
-- ln
-- 2015 1-29
CREATE TABLE IF NOT EXISTS  `dailychoice` (
 `uid` INT( 10 ) NOT NULL ,
 `info` VARCHAR( 10000 ) NOT NULL DEFAULT  '{}',
 `weelts` INT( 11 ) NOT NULL ,
 `score` INT( 11 ) NOT NULL ,
 `rank` INT( 10 ) NOT NULL ,
 `updated_at` INT( 11 ) NOT NULL ,
PRIMARY KEY (  `uid` )
) ENGINE = INNODB DEFAULT CHARSET = utf8;

-- 每日领取体力
-- ln
-- 2015 1-29
CREATE TABLE IF NOT EXISTS  `dailyenergy` (
 `uid` INT( 10 ) NOT NULL ,
 `info` VARCHAR( 10000 ) NOT NULL DEFAULT  '{}',
 `updated_at` INT( 11 ) NOT NULL ,
PRIMARY KEY (  `uid` )
) ENGINE = INNODB DEFAULT CHARSET = utf8;

-- 邮件vip和等级限制
-- ln
-- 2015-03-05
ALTER TABLE  `sysmail` ADD  `limittype` INT( 1 ) NOT NULL DEFAULT  '0' AFTER  `item` ,
ADD  `min` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `limittype` ,
ADD  `max` INT( 10 ) NOT NULL DEFAULT  '0' AFTER  `min` ;

-- 好友赠送功能
-- ln
-- 2015-2-7

CREATE TABLE IF NOT EXISTS `alliancememgift` (
  `uid` int(10) NOT NULL,
  `give` varchar(10000) NOT NULL DEFAULT '{}',
  `receive` varchar(10000) NOT NULL DEFAULT '{}',
  `reftime` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 异星科技
-- ln
-- 2015-3-11

CREATE TABLE IF NOT EXISTS `alien` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(10000) NOT NULL,
  `used` varchar(6000) NOT NULL,
  `prop` varchar(500) NOT NULL,
  `pinfo` varchar(500) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;



-- 洗练
-- lmh
-- 2015-3-23
ALTER TABLE `accessory` ADD `m_exp` INT( 10 ) NOT NULL DEFAULT '0' AFTER `props` ;
ALTER TABLE `accessory` ADD `m_level` INT( 10 ) NOT NULL DEFAULT '1' AFTER `m_exp` ;
ALTER TABLE `accessory` CHANGE `used` `used` VARCHAR( 3000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'ä½¿ç”¨ä¸­çš„è£…å¤‡';
ALTER TABLE `accessory` ADD `sinfo` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' AFTER `m_level` ;
ALTER TABLE `accessory` ADD `succ_at` INT( 10 ) NOT NULL DEFAULT '0' AFTER `refine_at` ;


-- 跨服军团站
-- 2015-4-13
-- lmh

ALTER TABLE `alliance_members` ADD `usegems` INT( 10 ) NOT NULL DEFAULT '0' AFTER `gems` ;

--  公告加个系统
--  2015 04-23
--  lmh

ALTER TABLE `notice` ADD `sys` VARCHAR( 10 ) NULL DEFAULT NULL AFTER `nid` ;


-- 世界大战
-- lmh
-- 2015-3-17

ALTER TABLE `serverbattlecfg` CHANGE `servers` `servers` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;


-- 世界大战
-- lmh
-- 2015-04-14
CREATE TABLE IF NOT EXISTS `worldwar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `bid` varchar(50) NOT NULL,
  `zid` int(10) NOT NULL,
  `level` int(10) NOT NULL,
  `nickname` varchar(50) NOT NULL,
  `pic` int(10) NOT NULL DEFAULT '0',
  `rank` int(10) NOT NULL DEFAULT '1',
  `fc` int(10) NOT NULL DEFAULT '0',
  `aname` varchar(50) NOT NULL DEFAULT '""',
  `point` int(10) NOT NULL DEFAULT '0',
  `score` int(10) NOT NULL DEFAULT '0',
  `status` int(10) NOT NULL DEFAULT '0',
  `binfo` varchar(15000) NOT NULL,
  `tinfo` varchar(5000) DEFAULT NULL,
  `land` varchar(20) DEFAULT NULL COMMENT '地形',
  `strategy` varchar(50) NOT NULL DEFAULT '{}' COMMENT '策略',
  `line` varchar(50) NOT NULL DEFAULT '{}',
  `jointype` int(4) NOT NULL COMMENT '参加的大师还是精英',
  `heroAccessoryInfo` varchar(500) NOT NULL,
  `apply_at` int(10) NOT NULL,
  `battle_at` int(10) NOT NULL DEFAULT '0',
  `updated_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1;


CREATE TABLE IF NOT EXISTS `wcrossinfo` (
  `uid` int(10) NOT NULL,
  `pointlog` text NOT NULL,
  `bet` varchar(10000) NOT NULL DEFAULT '{}',
  `point` int(10) NOT NULL DEFAULT '0',
  `rank` varchar(5000) NOT NULL DEFAULT '{}',
  `info` varchar(500) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




-- 异星矿场
-- 2015-04-17
ALTER TABLE `alien` ADD `mine_at` INT( 10 ) NOT NULL DEFAULT '0' AFTER `pinfo` ;
ALTER TABLE `alien` ADD `m_count` INT( 11 ) NOT NULL DEFAULT '0' AFTER `mine_at` ;

-- 异星矿场地图
-- hwm
-- 2015-5-4 14:52
CREATE TABLE `alienmap` (
  `id` int(11) NOT NULL,
  `x` int(11) NOT NULL,
  `y` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `data` varchar(100) NOT NULL,
  `oid` int(10) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `power` int(10) unsigned NOT NULL,
  `rank` int(10) unsigned NOT NULL DEFAULT '0',
  `alliance` varchar(100) NOT NULL,
  `protect` int(11) unsigned NOT NULL DEFAULT '0',
  `pic` int(11) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `x` (`x`,`y`,`type`),
  KEY `oid_type` (`oid`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 世界大战修改
-- lmh
-- 2015--5-12

ALTER TABLE `serverbattlecfg` CHANGE `servers` `servers` VARCHAR( 500 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;

-- uid 军事演习索引
-- lmh 
-- 2015-05-12
ALTER TABLE `userarenalog` ADD INDEX ( `uid` ) ;
-- 将领授勋
-- lmh 
-- 2015 05-05

ALTER TABLE `hero` ADD `feat` VARCHAR( 50 ) NOT NULL DEFAULT '{}' AFTER `stats` ;
ALTER TABLE `hero` ADD `finfo` VARCHAR( 3000 ) NOT NULL DEFAULT '{}' AFTER `feat` ;
ALTER TABLE `hero` ADD `hfeats` VARCHAR( 1000 ) NOT NULL DEFAULT '{}' AFTER `finfo` ;

-- 用户资源超限(请注意快用已经执行过这一段sql)
-- hwm 
-- 2015-5-22 22:05
ALTER TABLE `userinfo`
	CHANGE COLUMN `gold` `gold` BIGINT UNSIGNED NOT NULL DEFAULT '5000' AFTER `gems`,
	CHANGE COLUMN `r1` `r1` BIGINT UNSIGNED NOT NULL DEFAULT '5000' AFTER `gold`,
	CHANGE COLUMN `r2` `r2` BIGINT UNSIGNED NOT NULL DEFAULT '5000' AFTER `r1`,
	CHANGE COLUMN `r3` `r3` BIGINT UNSIGNED NOT NULL DEFAULT '5000' AFTER `r2`,
	CHANGE COLUMN `r4` `r4` BIGINT UNSIGNED NOT NULL DEFAULT '5000' AFTER `r3`;

-- 邮件黑名单
-- lmh
-- 2015-5-25 22:03
 CREATE TABLE `mailblack` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(1000) NOT NULL DEFAULT '{}',
  `updated_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 微信礼包
-- hwm 
-- 2015-6-8 16:48
ALTER TABLE `giftbag`
	ALTER `type` DROP DEFAULT;
ALTER TABLE `giftbag`
	ADD COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST,
	CHANGE COLUMN `bag` `bag` SMALLINT UNSIGNED NOT NULL AFTER `type`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY (`id`),
	ADD UNIQUE INDEX `cdkey` (`cdkey`);

ALTER TABLE `giftbag` 
  CHANGE `bag` `bag` INT( 10 ) UNSIGNED NOT NULL ;

-- 2015-7-13
-- other 记录首次通关奖励
ALTER TABLE `challenge` ADD `other` varchar( 5000 );

-- 2015-7-31
-- 自动升级
ALTER TABLE `buildings` ADD `auto` int(11) NOT NULL DEFAULT 0 AFTER `updated_at`;
ALTER TABLE `buildings` ADD `auto_expire` int(11) NOT NULL DEFAULT 0 AFTER `auto`;

 -- 繁荣度系统
-- lmh
-- 2015-8-11 22:03
 CREATE TABLE `boom` (
  `uid` int(10) unsigned NOT NULL,
  `boom` int(11) NOT NULL DEFAULT '0',
  `boom_max` int(11) NOT NULL DEFAULT '0',
  `boom_ts` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2015-9-24
-- piclist 记录激活头像的id
ALTER TABLE `userinfo` ADD `piclist` varchar( 1000 ) NOT NULL DEFAULT '{}' AFTER `flags`;

-- 区域战职位表
 -- lmh
 -- 2015-07-16
CREATE TABLE IF NOT EXISTS `areawarcity` (
  `date` int(11) NOT NULL,
  `aname` varchar(100) NOT NULL,
  `pic` int(4) NOT NULL DEFAULT '1',
  `commander` varchar(100) NOT NULL,
  PRIMARY KEY (`date`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 表的结构 `areawarlog`
CREATE TABLE IF NOT EXISTS `areawarlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `btype` varchar(10) NOT NULL,
  `attuid` int(11) NOT NULL DEFAULT '0',
  `defuid` int(11) NOT NULL DEFAULT '0',
  `attaid` int(11) NOT NULL DEFAULT '0',
  `defaid` int(11) NOT NULL DEFAULT '0',
  `attname` varchar(100) NOT NULL,
  `defname` varchar(100) NOT NULL,
  `attaname` varchar(100) NOT NULL DEFAULT '',
  `defaname` varchar(100) NOT NULL,
  `win` int(4) NOT NULL DEFAULT '0',
  `occupy` int(4) NOT NULL DEFAULT '0',
  `report` varchar(10000) NOT NULL,
  `updated_at` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attuid` (`attuid`),
  KEY `defuid` (`defuid`),
  KEY `attaid` (`attaid`),
  KEY `defaid` (`defaid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


-- 表的结构 `jobs`

CREATE TABLE IF NOT EXISTS `jobs` (
  `uid` int(11) NOT NULL,
  `aid` int(11) NOT NULL,
  `job` int(4) NOT NULL DEFAULT '0',
  `end_at` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  IF NOT EXISTS `schallenge` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(10000) DEFAULT NULL,
  `resetnum` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `reset_at` int(11) NOT NULL DEFAULT '0',
  `pernum` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 邮件锁
ALTER TABLE `mail` ADD COLUMN `mlock` TINYINT(3) UNSIGNED NULL DEFAULT '0' AFTER `gift`;

-- 公告
ALTER TABLE `notice` ADD COLUMN `showtype` TINYINT(3) UNSIGNED NULL DEFAULT '0';

-- 军团战改版
-- lmh
--  2016-1-5

ALTER TABLE `useralliancewar` ADD `aid` INT( 11 ) NOT NULL DEFAULT '0' AFTER `uid` ;
ALTER TABLE `useralliancewar` ADD `rank` INT( 4 ) NOT NULL DEFAULT '0' COMMENT '排名' AFTER `uid` ;
ALTER TABLE `useralliancewar` ADD `binfo` VARCHAR( 10000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' COMMENT '部队info串' AFTER `b4` ;
ALTER TABLE `useralliancewar` ADD `info` VARCHAR( 5000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' COMMENT '将领和部队' AFTER `binfo` ;
ALTER TABLE `useralliancewar` ADD `bid` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '""' AFTER `uid` ;
ALTER TABLE `userinfo` CHANGE `rp` `rp` BIGINT UNSIGNED NOT NULL DEFAULT '0' COMMENT '军功值';
ALTER TABLE `userinfo` CHANGE `rpb` `rpb` BIGINT NULL DEFAULT '-1' COMMENT '军功币';
ALTER TABLE `useralliancewar` ADD COLUMN `task` VARCHAR(200) NOT NULL DEFAULT '{}' AFTER `upgradeinfo`;

-- 奖励中心
-- wht
-- 2015-07-13
CREATE TABLE `rewardcenter` (
	`id` VARCHAR(200) NOT NULL,
	`type` VARCHAR(60) NOT NULL,
	`title` VARCHAR(200) NOT NULL DEFAULT '',
	`uid` INT(11) UNSIGNED NOT NULL DEFAULT '0',
	`status` INT(1) UNSIGNED NOT NULL DEFAULT '0',
	`st` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`et` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`info` VARCHAR(1000) NOT NULL,
	`reward` VARCHAR(1000) NOT NULL,
	`updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	INDEX `getlist` (`uid`,`st`,`et`),
	INDEX `getlistbyuid` (`uid`),
	INDEX `et` (`et`)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

ALTER TABLE `crossinfo` CHANGE `bet` `bet` varchar(10000) NOT NULL DEFAULT '{}' COMMENT '押注';

-- 异元战场
-- wht
-- 2016-3-24
CREATE TABLE `userwar` (
  `uid` int(10) NOT NULL DEFAULT '0',
  `bid` varchar(20) NOT NULL DEFAULT '""',
  `name` varchar(60) NOT NULL DEFAULT '""',
  `level` int(9) unsigned NOT NULL DEFAULT '0',
  `point` int(10) NOT NULL DEFAULT '0' COMMENT '商店可用积分',
  `point1` int(10) NOT NULL DEFAULT '0' COMMENT '生存积分',
  `point2` int(10) NOT NULL DEFAULT '0' COMMENT '亡者积分',
  `energy` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '行动力',
  `status` int(4) NOT NULL DEFAULT '0' COMMENT '玩家状态0生存1亡者2死亡',
  `round1` int(11) NOT NULL DEFAULT '0' COMMENT '生存回合',
  `round2` int(11) NOT NULL DEFAULT '0' COMMENT '亡者回合',
  `place` int(4) NOT NULL DEFAULT '0',
  `mapx` int(4) NOT NULL DEFAULT '0',
  `mapy` int(4) NOT NULL DEFAULT '0',
  `buff` varchar(500) NOT NULL DEFAULT '{}',
  `info` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '原始部队信息',
  `troops` varchar(1000) NOT NULL DEFAULT '{}',
  `binfo` varchar(10000) NOT NULL DEFAULT '{}' COMMENT '战斗用部队信息',
  `hide` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '躲猫猫记录',
  `support1` int(2) unsigned NOT NULL DEFAULT '0' COMMENT '补给1恢复行动力',
  `support2` int(2) unsigned NOT NULL DEFAULT '0' COMMENT '补给2补充部队',
  `support3` int(2) unsigned NOT NULL DEFAULT '0' COMMENT '补给3清除异常状态',
  `pointlog` varchar(6000) NOT NULL DEFAULT '{}' COMMENT '积分流向',
  `bcount` varchar(1000) NOT NULL DEFAULT '{}',
  `apply_at` int(10) NOT NULL DEFAULT '0' COMMENT '报名时间',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `userwarlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `bid` varchar(10) NOT NULL DEFAULT '""',
  `round` int(10) NOT NULL DEFAULT '0',
  `content` varchar(1000) NOT NULL DEFAULT '""',
  `report` varchar(10000) NOT NULL DEFAULT '""',
  `update_at` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 侦查日志
CREATE TABLE IF NOT EXISTS `scoutlog` (
  `id` varchar(50) NOT NULL,
  `uid` int(11) unsigned NOT NULL DEFAULT '0',
  `cnt` int(11) DEFAULT NULL,
  `cntperhour` int(11) DEFAULT NULL,
  `ipcnt` int(11) DEFAULT NULL,
  `ipcntperhour` int(11) DEFAULT NULL,
  `scoutdata` int(10) NOT NULL,
  `ip` varchar(50) NOT NULL,
  `update_at` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 世界大战 淘汰赛重新设部队 标记
ALTER TABLE `worldwar` ADD COLUMN `eliminateTroopsFlag` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '淘汰赛设兵标识';

-- 军事演习 改版
ALTER TABLE `userarena` ADD `point` INT( 10 ) NOT NULL DEFAULT '0' AFTER `ranking` ;
ALTER TABLE `userarena` ADD `info` VARCHAR( 10000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '{}' AFTER `victory` ;
ALTER TABLE `userarena` ADD `score` INT( 10 ) NOT NULL DEFAULT '0' COMMENT '购买商店的积分' AFTER `point` ;
ALTER TABLE `userarena` ADD `buy_num` INT( 4 ) NOT NULL DEFAULT '0' AFTER `attack_num` ;
ALTER TABLE `userarena` ADD `ref_num` INT( 4 ) NOT NULL DEFAULT '0' AFTER `buy_num` ;

-- 超级装备
CREATE TABLE IF NOT EXISTS `sequip` (
  `uid` int(10) NOT NULL,
  `sequip` varchar(2000) DEFAULT NULL COMMENT '装备信息',
  `info` varchar(1000) DEFAULT NULL COMMENT '装备抽取数据',
  `stats` varchar(200) DEFAULT NULL COMMENT '装备出战数据',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 修复关卡字段顺序不一致， 会导致合服失败
ALTER TABLE `challenge` CHANGE COLUMN `other` `other` varchar( 5000 ) AFTER `star` ;

-- 矿点升级
-- 2016-04-14   科比退役了
-- lmh 

ALTER TABLE `map` ADD `exp` INT( 10 ) NOT NULL DEFAULT '0' AFTER `level` ;

-- 叛军
-- hwm
-- 2016-07-21
ALTER TABLE `map` CHANGE COLUMN `data` `data` VARCHAR(2000) NOT NULL AFTER `exp`;

-- 叛军
-- lmh
-- 2016-7-26

CREATE TABLE IF NOT EXISTS `allianceforceslog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dieid` varchar(50) NOT NULL,
  `aid` int(10) NOT NULL,
  `rfname` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `alliancename` varchar(100) DEFAULT NULL,
  `lvl` int(10) NOT NULL DEFAULT '0',
  `kill_at` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dieid` (`dieid`),
  KEY `aid` (`aid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `userforces` (
  `uid` int(11) NOT NULL,
  `info` varchar(5000) NOT NULL,
  `energy` int(10) NOT NULL DEFAULT '0',
  `energyts` int(11) NOT NULL DEFAULT '0',
  `energybuy` int(4) NOT NULL DEFAULT '0',
  `buyts` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 新增统计数据
ALTER TABLE `userinfo` ADD `deviceid` varchar( 50 )  NOT NULL DEFAULT '' AFTER `logdc` ;
ALTER TABLE `userinfo` ADD `platid` varchar( 100 )  NOT NULL DEFAULT '' AFTER `deviceid` ;

-- GM操作日志
CREATE TABLE `adminlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `requestlog` varchar(10000) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 异星科技 
-- hzy
-- 2016-09-02
ALTER TABLE `alien` ADD `used1` text NOT NULL DEFAULT '' AFTER `used` ;
ALTER TABLE `alien` ADD `shop` varchar(1000) NOT NULL DEFAULT '{}' AFTER `pinfo` ;

-- 将领装备
-- lmh 
-- 2016-9-10
CREATE TABLE IF NOT EXISTS `equip` (
  `uid` int(11) NOT NULL,
  `e1` int(10) NOT NULL DEFAULT '0',
  `e2` int(10) NOT NULL DEFAULT '0',
  `e3` int(10) NOT NULL DEFAULT '0',
  `info` varchar(10000) NOT NULL,
  `last_at` int(10) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 将领装备关卡
-- wht
-- 2016-09-10
CREATE TABLE `hchallenge` (
  `uid` int(11) unsigned NOT NULL,
  `info` varchar(10000) DEFAULT '{}',
  `attack` varchar(10000) NOT NULL DEFAULT '{}',
  `reward` varchar(500) NOT NULL DEFAULT '{}',
  `star` int(10) unsigned NOT NULL DEFAULT '0',
  `weets` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 区域站优化
-- lmh
-- 2016-04-21
CREATE TABLE IF NOT EXISTS `userareawar` (
  `uid` int(10) NOT NULL DEFAULT '0',
  `aid` int(10) NOT NULL DEFAULT '0',
  `bid` varchar(50) NOT NULL DEFAULT '''''',
  `info` varchar(5000) NOT NULL,
  `task` varchar(200) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 将领经验书的优化
-- lmh 
-- 2016-2-18

ALTER TABLE `hero` ADD `exp` INT( 11 ) NOT NULL DEFAULT '0' AFTER `uid`; 

-- 世界大战修改
-- hzy
-- 2016-11-11

ALTER TABLE `serverbattlecfg` CHANGE `servers` `servers` VARCHAR( 2000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;

--  军团协助
--   lmh
--  2015-12-15 圣诞节
CREATE TABLE IF NOT EXISTS `alliancehelp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL DEFAULT '0',
  `aid` int(11) NOT NULL DEFAULT '0',
  `mc` int(11) NOT NULL DEFAULT '0',
  `cc` int(11) NOT NULL DEFAULT '0',
  `et` int(11) NOT NULL DEFAULT '0',
  `type` varchar(20) NOT NULL,
  `info` varchar(100) NOT NULL,
  `list` varchar(1000) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  KEY `aid` (`aid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--  军团协助
--   lmh
--  2015-12-15 圣诞节
CREATE TABLE IF NOT EXISTS `alliancehelplog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL DEFAULT '0',
  `info` varchar(100) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- 名将试炼
-- hzy
-- 2016-11-12
ALTER TABLE `hero` ADD `anneal` VARCHAR( 1000 ) NOT NULL DEFAULT '{}' AFTER `finfo` ;

-- 试炼log
CREATE TABLE IF NOT EXISTS `annealog` (
  `uid` int(11) NOT NULL,
  `info` varchar(1000) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 统计数据
-- 2016-11-21
ALTER TABLE `userinfo` ADD `channelid` varchar( 50 )  NOT NULL DEFAULT '' AFTER `platid` ;
ALTER TABLE `userinfo` CHANGE COLUMN `online_at` `online_at` INT( 11 ) NOT NULL DEFAULT '0' AFTER `channelid` ;

ALTER TABLE `userinfo` ADD `oltd` INT( 11 ) NOT NULL DEFAULT '0' AFTER `olt` ;

-- 异星武器
-- hzy
-- 2016-11-26
CREATE TABLE IF NOT EXISTS `alienweapon` (
  `uid` int(10) NOT NULL DEFAULT '0',
  `info` varchar(5000) NOT NULL,
  `used` varchar(100) NOT NULL,
  `fragment` varchar(1000) NOT NULL,
  `props` varchar(1000) NOT NULL,
  `trade` varchar(2000) NOT NULL,
  `tinfo` varchar(1000) NOT NULL,
  `sinfo` varchar(1000) NOT NULL,
  `exp` BIGINT(10) NOT NULL DEFAULT '0',
  `y1` BIGINT(10) NOT NULL DEFAULT '0',
  `tflag` tinyint(4) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 异星武器NPC库
-- hzy
-- 2016-12-05
CREATE TABLE IF NOT EXISTS `alienweaponpc` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `troops` varchar(1000) NOT NULL,
  `sr` varchar(1000) NOT NULL,
  `cr` varchar(1000) NOT NULL,
  `level` int(10) NOT NULL DEFAULT '0',
  `slot` int(10) NOT NULL DEFAULT '0',
  `fc` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- 战报
CREATE TABLE IF NOT EXISTS `alienweaponlog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` tinyint(4) unsigned NOT NULL,
  `isvictory` tinyint(4) unsigned NOT NULL,
  `dfname` varchar(100) NOT NULL,
  `content` varchar(10000) NOT NULL,
  `isRead` tinyint(10) unsigned NOT NULL DEFAULT '0',
  `ts` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--  装甲矩阵
-- lmh
-- 2016-12-21

CREATE TABLE IF NOT EXISTS `armor` (
  `uid` int(10) NOT NULL,
  `info` varchar(10000) NOT NULL,
  `used` varchar(1000) NOT NULL,
  `free` varchar(500) NOT NULL,
  `exp` int(10) NOT NULL DEFAULT '0',
  `count` int(10) NOT NULL DEFAULT '0',
  `buynum` int(4) NOT NULL DEFAULT '0',
  `props` varchar(1000) NOT NULL,
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 体力上限扩展
-- chenyunhe
-- 2017-3-7
ALTER TABLE `userinfo` ADD COLUMN `extraenergy`int(10) DEFAULT 0 AFTER `energycd`;

-- 扫矿log添加字段
-- 2017-3-13
-- lmh
ALTER TABLE `scoutlog` ADD `x` INT( 10 ) NOT NULL DEFAULT '0' AFTER `ipcnt` ;
ALTER TABLE `scoutlog` ADD `y` INT( 10 ) NOT NULL DEFAULT '0' AFTER `x` ;

-- 字段类型更改
-- hwm
-- 2017-3-21
ALTER TABLE `alienmap` CHANGE COLUMN `power` `power` BIGINT UNSIGNED NOT NULL AFTER `name`;
ALTER TABLE `alliance` CHANGE COLUMN `fight` `fight` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `level`;
ALTER TABLE `alliance_members` CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `rank`;
ALTER TABLE `expedition`  CHANGE COLUMN `fc` `fc` BIGINT NOT NULL DEFAULT '0' AFTER `level`;
ALTER TABLE `map`  CHANGE COLUMN `power` `power` BIGINT UNSIGNED NOT NULL AFTER `name`;
ALTER TABLE `userinfo`  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `urt`;
ALTER TABLE `worldwar`  CHANGE COLUMN `fc` `fc` BIGINT NOT NULL DEFAULT '0' AFTER `rank`;
ALTER TABLE `userinfo` CHANGE `exp` `exp` BIGINT(20)  UNSIGNED  NOT NULL  DEFAULT '100';


-- 每日捷报资讯表
-- hwm
-- 2017-01-13
CREATE TABLE `news_article` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`day` INT(11) NOT NULL DEFAULT '0' COMMENT '第几日生成',
	`title` VARCHAR(50) NOT NULL COMMENT '标题',
	`content` VARCHAR(1000) NOT NULL COMMENT '内容',
	`ext1` VARCHAR(100) NOT NULL DEFAULT '0' COMMENT '扩展字段1',
	`updated_at` INT(10) UNSIGNED NOT NULL COMMENT '修改时间',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `day` (`day`, `title`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

-- 每日捷报头条表
-- hwm
-- 2017-01-13
CREATE TABLE `news_headline` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`day` INT(11) NOT NULL DEFAULT '0' COMMENT '第几日生成',
	`title` VARCHAR(50) NOT NULL COMMENT '标题',
	`content` VARCHAR(1000) NOT NULL COMMENT '内容',
	`goodpost` INT(11) NOT NULL DEFAULT '0' COMMENT '好评数',
	`comment` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '评论代号',
	`commenter` VARCHAR(100) NOT NULL DEFAULT '' COMMENT '评论人',
	`updated_at` INT(10) UNSIGNED NOT NULL COMMENT '修改时间',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `day` (`day`, `title`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

-- 每日捷公共历史数据表
-- hwm
-- 2017-01-13
CREATE TABLE `news_history_common` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NOT NULL,
	`value1` INT(10) NOT NULL DEFAULT '0',
	`value2` INT(10) NOT NULL DEFAULT '0',
	`value3` INT(10) NOT NULL DEFAULT '0',
	`updated_at` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

-- 每日捷报用户历史数据表
-- hwm
-- 2017-01-13
CREATE TABLE `news_history_user` (
	`uid` INT(11) NOT NULL,
	`fcrank` INT(11) NOT NULL DEFAULT '0',
	`challangerank` INT(11) NOT NULL DEFAULT '0',
	`arenarank` INT(11) NOT NULL DEFAULT '0',
	`ranklv` INT(11) NOT NULL DEFAULT '0',
	`accessorypoint` INT(11) NOT NULL DEFAULT '0',
	`heropoint` INT(11) NOT NULL DEFAULT '0',
	`fcrankold` INT(11) NOT NULL DEFAULT '0',
	`challangerankold` INT(11) NOT NULL DEFAULT '0',
	`arenarankold` INT(11) NOT NULL DEFAULT '0',
	`ranklvold` INT(11) NOT NULL DEFAULT '0',
	`accessorypointold` INT(11) NOT NULL DEFAULT '0',
	`heropointold` INT(11) NOT NULL DEFAULT '0',
	`updated_at` INT(11) NOT NULL DEFAULT '0',
	PRIMARY KEY (`uid`)
)
COMMENT='每日捷报用户历史数据'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

-- 每日捷公共历史记录数据
INSERT INTO `news_history_common` (`id`, `name`, `value1`, `value2`, `value3`, `updated_at`) VALUES (1, 'd2', 0, 0, 0, 0);
INSERT INTO `news_history_common` (`id`, `name`, `value1`, `value2`, `value3`, `updated_at`) VALUES (2, 'd5', 0, 0, 0, 0);
INSERT INTO `news_history_common` (`id`, `name`, `value1`, `value2`, `value3`, `updated_at`) VALUES (3, 'd7', 0, 0, 0, 0);


-- 军团旗帜
-- wht
ALTER TABLE `map` ADD COLUMN `alliancelogo` VARCHAR(100) NOT NULL DEFAULT '{}' AFTER `alliance`;

-- 军团跨服战旗帜
-- hwm
-- 20170317
ALTER TABLE `alliance` ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '[]' COMMENT '军团旗帜' AFTER `name`;

ALTER TABLE `scoutlog` ADD `mcnt` INT( 10 ) NOT NULL DEFAULT '0' AFTER `cnt` ;

-- 用户注册时的IP
-- hwm
-- 20170328
ALTER TABLE `userinfo` ADD COLUMN `regip` VARCHAR(80) NOT NULL DEFAULT '' COMMENT '用户注册ip' AFTER `ip`;



-- 地图上繁荣度优化
-- chenyunhe
-- 2017-3-21
ALTER TABLE `map` ADD `boom` INT UNSIGNED NOT NULL DEFAULT '0' AFTER `pic`;
ALTER TABLE `map` ADD `boom_max` INT UNSIGNED NOT NULL DEFAULT '0' AFTER `boom`;
ALTER TABLE `map` ADD `boom_ts` INT UNSIGNED NOT NULL DEFAULT '0' AFTER `boom_max`;

-- 远征手动攻击通关次数
ALTER TABLE `userexpedition` ADD `acount` INT( 4 ) NOT NULL DEFAULT '0' AFTER `reset` ;

-- 跟3k审计相关的值
-- chenyunhe
-- 2017-5-12
ALTER TABLE `tradelog` ADD `zoneid` INT(10) NOT NULL DEFAULT '0' COMMENT '服务器ID' , ADD `appid` VARCHAR(100) NULL DEFAULT NULL COMMENT '渠道编号' , ADD `platid` VARCHAR(100) NULL DEFAULT NULL COMMENT '玩家账号' , ADD `nickname` VARCHAR(100) NULL DEFAULT NULL COMMENT '角色名' , ADD `deviceid` VARCHAR(100) NULL DEFAULT NULL COMMENT '设备标识' , ADD `iffirstbuy` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '是否首充' , ADD `apporderid` VARCHAR(200) NULL DEFAULT NULL COMMENT '订单号' , ADD `os` VARCHAR(100) NULL DEFAULT NULL COMMENT '系统' ;


-- 头像框、挂件
-- chenyunhe
-- 2017-6-2
ALTER TABLE `userinfo` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `userinfo` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

CREATE TABLE `picstore` (
  `uid` INT(11) NOT NULL,
  `p` VARCHAR(1000)  DEFAULT '' COMMENT '头像库',
  `b` VARCHAR(1000)  DEFAULT '' COMMENT '头像框库',
  `a` VARCHAR(1000)  DEFAULT '' COMMENT '挂件库',
  `e` VARCHAR(1000)  DEFAULT '' COMMENT '聊天气泡库',
  `updated_at` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
)
COMMENT='头像、头像框、挂件、聊天气泡'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


ALTER TABLE `expedition` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `expedition` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

ALTER TABLE `areawarcity` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `areawarcity` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

ALTER TABLE `map` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `map` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

ALTER TABLE `worldwar` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `worldwar` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;




-- 击杀赛(夺海奇兵)
-- hwm
-- 2017-6-19
-- 击杀赛战报
CREATE TABLE `killrace_battlelog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `defendername` varchar(100) NOT NULL DEFAULT '',
  `score` int(11) NOT NULL DEFAULT '0' COMMENT '积分',
  `grade` tinyint(4) NOT NULL DEFAULT '0',
  `queue` tinyint(4) NOT NULL DEFAULT '0',
  `isvictory` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否胜利',
  `content` text NOT NULL,
  `isRead` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 击杀赛兑换日志
CREATE TABLE `killrace_changelog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `content` varchar(1000) NOT NULL,
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 击杀赛镜像数据
CREATE TABLE `killrace_image` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `pic` INT(10)  NOT NULL DEFAULT '0' COMMENT '头像',
  `bpic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '头像框',
  `apic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '挂件',
  `level` tinyint(4) NOT NULL DEFAULT '0' COMMENT '等级',
  `nickname` varchar(100) NOT NULL DEFAULT '' COMMENT '昵称',
  `grade` tinyint(4) NOT NULL DEFAULT '0' COMMENT '段位',
  `queue` tinyint(4) NOT NULL DEFAULT '0' COMMENT '小段位',
  `dmgrate` int(11) NOT NULL DEFAULT '0' COMMENT '最高战损率(整数部分)',
  `fight` int(11) NOT NULL DEFAULT '0' COMMENT '战力',
  `troops` varchar(100) NOT NULL DEFAULT '' COMMENT '部队信息',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `grade_uid` (`grade`,`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 击杀赛赛季数据
CREATE TABLE `killrace_season` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `st` int(11) NOT NULL DEFAULT '0' COMMENT '起始时间',
  `et` int(11) NOT NULL DEFAULT '0' COMMENT '结束时间',
  `season` int(11) NOT NULL DEFAULT '0' COMMENT '当前赛季',
  `season_st` int(11) NOT NULL DEFAULT '0' COMMENT '当前赛季起始时间',
  `season_et` int(11) NOT NULL DEFAULT '0' COMMENT '当前赛季结束时间',
  `season_offset` tinyint(4) NOT NULL DEFAULT '0' COMMENT '赛季修正值',
  `season_reset` int(11) NOT NULL DEFAULT '0' COMMENT '已重置的赛季',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 击杀赛用户数据
CREATE TABLE `userkillrace` (
  `uid` int(11) unsigned NOT NULL,
  `nickname` varchar(100) NOT NULL DEFAULT '' COMMENT '昵称',
  `entry` tinyint(4) NOT NULL DEFAULT '0' COMMENT '报名标识',
  `score` int(11) NOT NULL DEFAULT '0' COMMENT '积分',
  `kcoin` int(11) NOT NULL DEFAULT '0' COMMENT 'K币数量',
  `fight` int(11) NOT NULL DEFAULT '0' COMMENT '标谁战力',
  `grade` tinyint(4) NOT NULL DEFAULT '0' COMMENT '当前大段位',
  `queue` tinyint(4) NOT NULL DEFAULT '0' COMMENT '当前小段位',
  `max_grade` tinyint(4) NOT NULL DEFAULT '0' COMMENT '最高大段位',
  `max_queue` tinyint(4) NOT NULL DEFAULT '0' COMMENT '最高小段位',
  `max_dmg_rate` int(11) NOT NULL DEFAULT '0' COMMENT '最高战损率(整数部分)',
  `total_change` int(11) NOT NULL DEFAULT '0' COMMENT '部队总兑换次数',
  `total_killed` int(11) NOT NULL DEFAULT '0' COMMENT '总击杀数',
  `total_battle_num` int(11) NOT NULL DEFAULT '0' COMMENT '总战斗次数',
  `grade_battle_num` int(11) NOT NULL DEFAULT '0' COMMENT '最高段位总战斗次数',
  `match_info` varchar(500) NOT NULL DEFAULT '{}' COMMENT '匹配的对手信息',
  `match_ocean` tinyint(4) NOT NULL DEFAULT '0' COMMENT '匹配到的地形',
  `match_weather` tinyint(4) NOT NULL DEFAULT '0' COMMENT '匹配到的天气',
  `image_flags` tinyint(4) NOT NULL DEFAULT '0' COMMENT '镜像设置标识',
  `grade_reward_flags` tinyint(4) NOT NULL DEFAULT '0' COMMENT '段位奖励领取标识',
  `grade_task` tinyint(4) NOT NULL DEFAULT '0' COMMENT '段位任务',
  `season` tinyint(4) NOT NULL DEFAULT '0' COMMENT '赛季',
  `day_grade` tinyint(4) NOT NULL DEFAULT '0' COMMENT '跨天时的段位',
  `day_change` int(11) NOT NULL DEFAULT '0' COMMENT '当日部队兑换总数',
  `day_killed` int(11) NOT NULL DEFAULT '0' COMMENT '当日击杀数',
  `day_match_num` int(11) NOT NULL DEFAULT '0' COMMENT '重置匹配次数',
  `day_wins` int(11) NOT NULL DEFAULT '0' COMMENT '当日胜利次数',
  `day_battle_num` int(11) NOT NULL DEFAULT '0' COMMENT '当日战斗次数',
  `day_max_continue_wins` int(11) NOT NULL DEFAULT '0' COMMENT '当日最大连胜次数',
  `day_continue_wins` int(11) NOT NULL DEFAULT '0' COMMENT '当时连胜次数(失败会被清掉)',
  `day_troops_give` tinyint(4) NOT NULL DEFAULT '0' COMMENT '每日部队赠送标识',
  `day_reward_flags` tinyint(4) NOT NULL DEFAULT '0' COMMENT '每日奖励标识',
  `day_at` int(11) NOT NULL DEFAULT '0',
  `switch` tinyint(4) NOT NULL DEFAULT '0' COMMENT '自动补兵开关',
  `troops` varchar(2000) NOT NULL DEFAULT '{}',
  `shop` varchar(500) NOT NULL DEFAULT '{}' COMMENT '商店信息',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 全服邮件增加一个最后登录时间限制的字段
-- hwm
-- 2017-6-26 14:17
ALTER TABLE `sysmail` ADD COLUMN `lastlogintime` INT(10) NOT NULL DEFAULT '0' AFTER `max`;


-- 跨服区域站
-- lmh
-- 2015-11-18

CREATE TABLE IF NOT EXISTS `areacrossinfo` (
  `uid` int(10) NOT NULL,
  `bid` varchar(20) NOT NULL,
  `gems` int(10) NOT NULL DEFAULT '0',
  `usegems` int(10) NOT NULL DEFAULT '0',
  `usegems_at` int(11) NOT NULL DEFAULT '0',
  `point` int(10) NOT NULL DEFAULT '0',
  `pointlog` varchar(10000) NOT NULL DEFAULT '{}',
  `info` varchar(10000) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- 每日金币洗练次数
-- chenyunhe
-- 2017-6-22
ALTER TABLE `accessory` ADD `gt` INT(10) DEFAULT '0' AFTER `succ_at`;
ALTER TABLE `accessory` ADD `lt` INT(10) DEFAULT '0' AFTER `gt`;
ALTER TABLE `accessory` ADD `hig` INT(10) DEFAULT '0' AFTER `lt`;
ALTER TABLE `accessory` ADD `com` INT(10) DEFAULT '0' AFTER `hig`;

ALTER TABLE `sequip`
	CHANGE COLUMN `sequip` `sequip` VARCHAR(5000) NULL DEFAULT NULL COMMENT 'è' AFTER `uid`,
	CHANGE COLUMN `info` `info` VARCHAR(3000) NULL DEFAULT NULL COMMENT 'è' AFTER `sequip`,
	CHANGE COLUMN `stats` `stats` VARCHAR(1000) NULL DEFAULT NULL COMMENT 'è' AFTER `info`;

-- 天梯榜 名人堂历史信息
-- wht
-- 2015-11-10
CREATE TABLE `skyladder_historydata` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bid` int(11) unsigned NOT NULL,
  `season` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 军团结算标记
-- wht
-- 2015-11-10
CREATE TABLE IF NOT EXISTS `allianceskyladder` (
  `id` int(11) NOT NULL,
  `info` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 个人结算标记
-- wht
-- 2015-11-10
CREATE TABLE `userexpand` (
	`uid` INT(11) UNSIGNED NOT NULL,
	`uhead` VARCHAR(1000) NOT NULL,
	`utitle` VARCHAR(1000) NOT NULL,
	`skyladder` VARCHAR(5000) NOT NULL DEFAULT '{}',
	`updated_at` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`uid`),
	INDEX `uid` (`uid`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


-- 给老玩家发首次通关奖励标识
-- chenyunhe
-- 2017-7-20
ALTER TABLE `challenge` ADD `frpass` INT(10) DEFAULT '0' AFTER `star`;



-- 绑定订单
-- chenyunhe
-- 2017-9-18
CREATE TABLE `bindorder` (
  `uid` int(11) unsigned NOT NULL,
  `order` varchar(100) DEFAULT NULL COMMENT '订单编号',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 邀请码(每人生成一个)
-- 2017-09-25
-- chenyunhe
CREATE TABLE `invitecode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `uid` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_name` (`uid`,`name`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='用户的邀请码(一个邀请码对应一个uid)';

-- 公海领地
-- chenyunhe
-- 2017-08-31
CREATE TABLE `territory` (
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `b1` varchar(100) DEFAULT NULL COMMENT '主基地',
  `b2` varchar(100) DEFAULT NULL COMMENT '炮台1',
  `b3` varchar(100) DEFAULT NULL COMMENT '炮台2',
  `b4` varchar(100) DEFAULT NULL COMMENT '炮台3',
  `b5` varchar(100) DEFAULT NULL COMMENT '炮台4',
  `b6` varchar(100) DEFAULT NULL COMMENT '控制台',
  `b7` varchar(100) DEFAULT NULL COMMENT '仓库',
  `b8` varchar(100) DEFAULT NULL COMMENT '铀矿',
  `b9` varchar(100) DEFAULT NULL COMMENT '天然气',
  `r1` bigint(20) unsigned DEFAULT '0' COMMENT '铁',
  `r2` bigint(20) unsigned DEFAULT '0' COMMENT '铝',
  `r3` bigint(20) unsigned DEFAULT '0' COMMENT '钛',
  `r4` bigint(20) unsigned DEFAULT '0' COMMENT '石油',
  `r6` bigint(20) unsigned DEFAULT '0' COMMENT '铀',
  `r7` bigint(20) unsigned DEFAULT '0' COMMENT '天然气',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '挂起状态',
  `level` INT(10) DEFAULT '0' COMMENT '主基地等级',
  `task` varchar(500) DEFAULT NULL COMMENT '军团任务和个人任务',
  `mapx` int(11) DEFAULT '-1' COMMENT 'X坐标',
  `mapy` int(11) DEFAULT '-1' COMMENT 'Y坐标',
  `score` int(11) unsigned DEFAULT '1000' COMMENT '积分',
  `dev_point` int(11) unsigned DEFAULT '10000' COMMENT '发展值',
  `power` int(11) NOT NULL DEFAULT '0' COMMENT '控制台能量',
  `daypower` INT(10) DEFAULT '0' COMMENT '每日增加的能量',
  `killcount` int(11) NOT NULL DEFAULT '0' COMMENT '击杀海盗',
  `kill_at` int(11) NOT NULL DEFAULT 0 COMMENT '击杀时间标识',
  `bqueue` varchar(2000) NOT NULL COMMENT '建筑队列',
  `minerefresh` varchar(200) NOT NULL COMMENT '特殊矿刷新',
  `mt` INT(10) DEFAULT '0' COMMENT '迁城时间',
  `ct` INT(10) DEFAULT '0' COMMENT '领地创建时间',
  `main_point` int(11) NOT NULL DEFAULT '10000' COMMENT '维护时的发展值',
  `main_power` int(11) NOT NULL DEFAULT '0' COMMENT '维护所需能量',
  `maintained_at` int(11) NOT NULL DEFAULT '0' COMMENT '上次维护时间',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 公海成员
CREATE TABLE `atmember` (
  `aid` int(11) unsigned NOT NULL COMMENT '军团id',
  `uid` int(11) unsigned NOT NULL,
  `task` varchar(500) DEFAULT NULL COMMENT '个人任务',
  `crack` varchar(100) DEFAULT '' COMMENT '破译密码(膜拜)',
  `collect` INT(10) DEFAULT '0' COMMENT '每日采集次数',
  `daytime` INT(10) DEFAULT '0' COMMENT '每日采集重置时间标识',
  `killcount` int(11) NOT NULL DEFAULT 0 COMMENT '击杀海盗',
  `kill_at` int(11) NOT NULL DEFAULT 0 COMMENT '击杀时间标识',
  `killreward` INT(10) DEFAULT '0' COMMENT '击杀海盗排行榜奖励领取标识',
  `seacoin` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '公海币',
  `atcontri` varchar(100) DEFAULT '' COMMENT '军团任务贡献值',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `uid_aid` (`uid`,`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- hwm
-- 2017/11/17 17:59
-- 远征加VIP字段
ALTER TABLE `expedition` ADD COLUMN `vip` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `apic`;

-- 宝石
-- chenyunhe
-- 2017-10-23
ALTER TABLE `alienweapon` ADD COLUMN `jewelinfo1` VARCHAR(1000) NOT NULL DEFAULT '{}' COMMENT '1-9级宝石信息' AFTER `sinfo`;
ALTER TABLE `alienweapon` ADD COLUMN `jewelinfo2` VARCHAR(3000) NOT NULL  DEFAULT '{}' COMMENT '10级宝石信息' AFTER `jewelinfo1`;
ALTER TABLE `alienweapon` ADD COLUMN `jewelused` VARCHAR(500) NOT NULL  DEFAULT '{}' COMMENT '装配的宝石' AFTER `jewelinfo2`;
ALTER TABLE `alienweapon` ADD COLUMN `crystal` INT(10) NOT NULL  DEFAULT '0' COMMENT '宝石结晶' AFTER `jewelused`;
ALTER TABLE `alienweapon` ADD COLUMN `stive` INT(10) NOT NULL  DEFAULT '0' COMMENT '宝石粉尘' AFTER `crystal`;

-- 战报超长
-- 2016-10-19 16:06
-- hwm
ALTER TABLE `userexpeditionlog` CHANGE COLUMN `content` `content` TEXT NOT NULL AFTER `type`;
ALTER TABLE `userarenalog` CHANGE COLUMN `content` `content` TEXT NOT NULL AFTER `type`;
ALTER TABLE `areawarlog` CHANGE COLUMN `report` `report` TEXT NOT NULL AFTER `occupy`;
ALTER TABLE `userwarlog` CHANGE COLUMN `report` `report` TEXT NOT NULL AFTER `content`;

-- lm
-- 2017/12/6 20:30
-- 用户新加版本统计字段
ALTER TABLE `userinfo` ADD COLUMN `newstrongversion` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' AFTER `channelid`;

-- hwm 击杀赛镜像图片字段调整
ALTER TABLE `killrace_image`
	CHANGE COLUMN `pic` `pic` INT(10) NOT NULL DEFAULT '0' COMMENT '头像' AFTER `uid`;

-- 指挥官新技能 
-- chenyunhe
-- 2017-12-14
ALTER TABLE `skills` ADD `s201` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s112` ;
ALTER TABLE `skills` ADD `s202` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s201` ;
ALTER TABLE `skills` ADD `s203` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s202` ;
ALTER TABLE `skills` ADD `s204` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s203` ;
ALTER TABLE `skills` ADD `s205` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s204` ;
ALTER TABLE `skills` ADD `s206` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s205` ;
ALTER TABLE `skills` ADD `s207` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s206` ;
ALTER TABLE `skills` ADD `s208` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s207` ;
ALTER TABLE `skills` ADD `s209` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s208` ;
ALTER TABLE `skills` ADD `s210` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s209` ;
ALTER TABLE `skills` ADD `s301` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s210` ;
ALTER TABLE `skills` ADD `s302` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s301` ;
ALTER TABLE `skills` ADD `s303` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s302` ;
ALTER TABLE `skills` ADD `s304` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s303` ;
ALTER TABLE `skills` ADD `s305` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s304` ;
ALTER TABLE `skills` ADD `s306` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s305` ;
ALTER TABLE `skills` ADD `s307` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s306` ;
ALTER TABLE `skills` ADD `s308` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s307` ;
ALTER TABLE `skills` ADD `s309` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s308` ;
ALTER TABLE `skills` ADD `s310` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s309` ;
ALTER TABLE `skills` ADD `s311` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s310` ;
ALTER TABLE `skills` ADD `s312` SMALLINT( 10 ) UNSIGNED NOT NULL DEFAULT '0' AFTER `s311` ;
ALTER TABLE `skills` ADD `buy_at` INT( 11 ) NOT NULL DEFAULT '0' AFTER `s312` ;


-- hwm
-- 2018/1/16 16:14
ALTER TABLE `map`  DROP INDEX `x_2`;
ALTER TABLE `alienweaponlog` ADD INDEX `uid` (`uid`);
ALTER TABLE `buildings` ADD INDEX `auto` (`auto`);

-- 个人信息仓库
-- 2016-06-06
CREATE TABLE `infostorage` (
  `uid` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户个人的信息仓库 用于记录一些功能需求信息';

-- 跨平台激活码 类型字段修改为字符以适应平台返回的1003-3格式
ALTER TABLE `giftbag`  CHANGE COLUMN `bag` `bag` VARCHAR(10);

-- 玩家请求记录
-- chenyunhe
-- 2018-01-22
CREATE TABLE `requestlog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `recordkey` varchar(100) DEFAULT '' COMMENT '标识',
  `cmd` varchar(100) DEFAULT '' COMMENT 'api接口',
  `request` varchar(500) DEFAULT '' COMMENT '请求串参数',
  `value` varchar(500) DEFAULT '' COMMENT '',
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- lm
-- 2018/1/4 15:30
-- 改名记录表
CREATE TABLE IF NOT EXISTS `namelog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `vip` int(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '0',
  `oldname` varchar(200) NOT NULL,
  `newname` varchar(200) NOT NULL,
  `update_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- hwm
-- 2017/12/9 14:33
-- 增加领海战积分字段
ALTER TABLE `atmember`
  ADD COLUMN `warscore` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战积分' AFTER `seacoin`,
  ADD COLUMN `war_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战时间' AFTER `warscore`,
  ADD COLUMN `warreward` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领奖标识' AFTER `war_at`;

ALTER TABLE `territory`
  ADD COLUMN `warscore` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战积分' AFTER `ct`,
  ADD COLUMN `warstatus` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战状态1是失败' AFTER `warscore`,
  ADD COLUMN `war_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战时间' AFTER `warstatus`,
  ADD COLUMN `apply` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战报名标识' AFTER `war_at`,
  ADD COLUMN `apply_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '领海战报名时间' AFTER `apply`;

ALTER TABLE `useractive` CHANGE COLUMN `info` `info` VARCHAR(20000) NOT NULL AFTER `uid`;

ALTER TABLE `alienweaponlog` CHANGE COLUMN `content` `content` TEXT NOT NULL AFTER `dfname`;

--  第七飞机
-- 2017-03-28
-- lmh
CREATE TABLE IF NOT EXISTS `plane` (
  `uid` int(10) NOT NULL,
  `info` varchar(1000) NOT NULL,
  `sinfo` varchar(10000) NOT NULL,
  `plane` varchar(2000) NOT NULL,
  `stats` varchar(1000) NOT NULL,
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 飞机建筑
-- 2018-01-15
-- chenyunhe
ALTER TABLE `buildings` ADD `b106` varchar(100) DEFAULT '{}' AFTER `b51`;

-- 飞机建筑等级
-- 2018-01-18
-- chenyunhe
ALTER TABLE `plane` ADD `level` int(10) DEFAULT 0 AFTER `uid`;

-- 军团活动
-- 2018/3/27 11:06
-- hwm
CREATE TABLE `allianceactive` (
  `aid` int(10) unsigned NOT NULL,
  `info` varchar(15000) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='军团活动';

-- 关卡排行榜优化
-- 2018/3/27 22:08
-- hwm
ALTER TABLE `challenge`
	ADD COLUMN `star_at` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `star`;



-- 跨服战资比拼
-- 2018-03-13
-- chenyunhe
CREATE TABLE `zzbp` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `groupid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '当前属于哪一组',
  `cfgid` tinyint(4) NOT NULL DEFAULT 0 COMMENT '使用的哪个配置',
  `zones` varchar(500) DEFAULT '{}' COMMENT '本次活动配置的服',
  `task` varchar(500) DEFAULT '{}' COMMENT '获得积分的任务',
  `sScore` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '全服积分',
  `pScore` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '个人积分',
  `st` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `et` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


-- 跨服战资比拼玩家活动数据
-- 2018-03-16
-- chenyunhe
CREATE TABLE `zzbpuser` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家的id',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `task` varchar(500) DEFAULT '{}' COMMENT '任务数据',
  `person` varchar(20) DEFAULT '{}' COMMENT '全服积分奖励',
  `server` varchar(20) DEFAULT '{}' COMMENT '个人积分奖励',
  `rank` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '排行榜奖励', 
  `fserver` tinyint(1) NOT NULL DEFAULT 0 COMMENT '积分第一服务器奖励',
  `receive` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '有没有接收别人送的',
  `senduid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '转赠给他人的uid',
  `tlog` varchar(1000) DEFAULT '{}' COMMENT '玩家每天各任务获得积分记录',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


--  渠道活动发布（允许多个平台或者单一平台上的活动）
--  lm 
--  2018-04-12
ALTER TABLE `active` ADD `plats` VARCHAR( 2000 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `status` ;

-- 预定攻打世界boss
-- 2018-04-12
-- chenyunhe
ALTER TABLE `worldboss` ADD `book` int(10) DEFAULT 0 AFTER `auto`;

-- 修改邮件公告
-- 2018-04-25
-- liming
ALTER TABLE `notice` CHANGE COLUMN `title` `title` varchar(1000) NOT NULL DEFAULT '' AFTER `appid`;
ALTER TABLE `mail` CHANGE COLUMN `subject` `subject` varchar(1000) NOT NULL DEFAULT '' AFTER `mail_to`;
ALTER TABLE `sysmail` CHANGE COLUMN `subject` `subject` varchar(1000) NOT NULL DEFAULT '' AFTER `appid`;

-- 修改邮件公告
-- 2018-04-25
-- liming
ALTER TABLE `notice` CHANGE COLUMN `content` `content` TEXT NOT NULL DEFAULT '' AFTER `title`;
ALTER TABLE `mail` CHANGE COLUMN `content` `content` TEXT NOT NULL DEFAULT '' AFTER `subject`;
ALTER TABLE `sysmail` CHANGE COLUMN `content` `content` TEXT NOT NULL DEFAULT '' AFTER `subject`;

-- 超级装备大师
-- 2018-03-27
-- chenyunhe
ALTER TABLE `sequip` ADD `smaster` varchar(2000) DEFAULT '{"m1":["e901",[0,0,0],{},[0,{}],0,{}]}' AFTER `stats`;
ALTER TABLE `sequip` ADD `sshop` varchar(100) DEFAULT '{}' AFTER `smaster`;
ALTER TABLE `sequip` ADD `xtimes` varchar(100) DEFAULT '{}' AFTER `sshop`;

-- 补给舰
-- 2018-05-30
-- hwm
 CREATE TABLE `tender` (
  `uid` int(10) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `enhancelvl` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '强化等级',
  `exp` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '级验',
  `bag` varchar(2000) NOT NULL DEFAULT '' COMMENT '背包',
  `weight` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '已用背包重量',
  `strength` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '补给舰强度',
  `material` varchar(2000) NOT NULL DEFAULT '' COMMENT '材料',
  `task` varchar(1000) NOT NULL DEFAULT '' COMMENT '任务',
  `taskcd` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '任务刷新计时',
  `buycount` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '购买任务次数',
  `queue` varchar(1000) NOT NULL DEFAULT '' COMMENT '生产队列',
  `used` varchar(200) NOT NULL DEFAULT '' COMMENT '使用信息',
  `shop` varchar(200) NOT NULL DEFAULT '{}' COMMENT '商店信息',
  `day_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '当日时间戳跨天用',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='补给舰';

-- 战争雕像系统 statue
-- 2017-10-23
-- ym
CREATE TABLE IF NOT EXISTS `statue` (
  `uid` int(11) NOT NULL,
  `statue` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '雕像信息',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='雕像系统';

-- 超级装备优化
-- 2018-07-03
-- chenyunhe
ALTER TABLE `sequip` ADD `etypes` varchar(100) DEFAULT '{}' AFTER `xtimes`;

-- 远洋征战
-- 2018-06-22
-- chenyunhe
CREATE TABLE `oceanexpedition` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家的id',
  `nickname` varchar(50) DEFAULT '{}' COMMENT '玩家昵称',
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `bid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'gm分组',
  `signUpStatus` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否报名0未报名1元帅2队长3小喽啰',
  `canMaster` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '有没有资格竞选元帅1有资格',
  `job` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '职位0成员 1统帅 2队长',
  `tid` int(10) unsigned NOT NULL DEFAULT '100' COMMENT '默认100（随便写的） 队伍编号 1 2,3,4,5 元帅 0',
  `fc` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '战力',
  `feats` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '功绩',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `fscore` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '鲜花积分',
  `scoreround` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '已获取积分的轮次',
  `morale` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '士气值',
  `info` varchar(5000) DEFAULT '{}' COMMENT '部队、将领、装备等信息',
  `battr` varchar(500) NOT NULL DEFAULT '[]',
  `shop` varchar(100) DEFAULT '{}' COMMENT '商店数据',
  `appteam` varchar(20) DEFAULT '[0,0,0,0,0]' COMMENT '申请的队伍',
  `apply_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '参与时间',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

ALTER TABLE `serverbattlecfg` CHANGE COLUMN `info` `info` VARCHAR(1500) NULL DEFAULT NULL AFTER `gap`;
ALTER TABLE `serverbattlecfg` ADD COLUMN `ext1` INT(11) NOT NULL DEFAULT '0' AFTER `gap`;


-- 2018-3-23
-- ym
-- 用户成就数据
CREATE TABLE IF NOT EXISTS `achievement` (
  `uid` int(11) unsigned NOT NULL,
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '成就等级',
  `uinfo` varchar(500) NOT NULL DEFAULT '{}' COMMENT '用户成就数据',
  `reward` varchar(5000) NOT NULL DEFAULT '{}' COMMENT '领奖数据',
  `info` varchar(500) NOT NULL DEFAULT '{}' COMMENT '其他数据',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户成就数据';

CREATE TABLE `user_like_achievement` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(11) unsigned NOT NULL,
  `achvid` int(11) NOT NULL DEFAULT '0' COMMENT '成就id',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_achvid` (`uid`,`achvid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户已点赞数据';

-- 击杀赛增加一个字段记录黄金场次胜利次数
-- hwm
-- 2018-07-26
ALTER TABLE `userkillrace`
  ADD COLUMN `avt_gold_wins` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '黄金场胜利总次数' AFTER `shop`;

-- 成就点赞
-- hwm
-- 2018-07-26
ALTER TABLE `achievement` ADD COLUMN `liked` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '赞数' AFTER `info`;

ALTER TABLE `achievement`
  ADD COLUMN `achvnum` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '成就数' AFTER `liked`;

ALTER TABLE `achievement`
  ADD COLUMN `achvat` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '成就时间' AFTER `achvnum`;

-- 装备大师洗练保底
-- 2018-07-30
-- chenyunhe
ALTER TABLE `sequip` ADD `gtimes` varchar(100) DEFAULT '{}' AFTER `etypes`;

-- 矩阵商店
-- hwm
-- 2018-08-22
ALTER TABLE `armor`
  ADD COLUMN `shopAt` INT(11) UNSIGNED NOT NULL DEFAULT '0' AFTER `props`;

-- 远洋征战修改主键
-- chenyunhe
-- 2018-08-30
ALTER TABLE `oceanexpedition` DROP COLUMN `id`; 
ALTER TABLE `oceanexpedition` ADD PRIMARY KEY(`uid`);

-- 远洋征战修改字段类型
-- hwm
-- 2018-09-01
ALTER TABLE `oceanexpedition`
  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' COMMENT '战力' AFTER `tid`;


-- 问卷调查
-- 2018-08-28
-- chenyunhe
CREATE TABLE `questions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `qid` int(10) unsigned NOT NULL COMMENT '问卷编号',
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '期限单位秒',
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '限制等级',
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `gift` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '问卷奖励',
  `statistics` varchar(2000) NOT NULL DEFAULT '{}' COMMENT '统计',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `qid` (`qid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


-- 问卷调查结果
-- 2018-08-28
-- chenyunhe
CREATE TABLE `answers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `qid` int(10) unsigned NOT NULL COMMENT '问卷编号',
  `answers` varchar(1000) NOT NULL DEFAULT '{}',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_qid` (`uid`,`qid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- 极品融合器
-- hwm
-- 2018-09-05
CREATE TABLE `amixer` (
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `sequip` varchar(600) NOT NULL DEFAULT '{}' COMMENT '超级装备',
  `armor` varchar(700) NOT NULL DEFAULT '{}' COMMENT '海兵方阵',
  `accessory` varchar(2000) NOT NULL DEFAULT '{}' COMMENT '配件',
  `alienweapon` varchar(500) NOT NULL DEFAULT '{}' COMMENT '异星武器',
  `items` varchar(3000) NOT NULL DEFAULT '{}' COMMENT '合成的珍品',
  `itime` varchar(50) NOT NULL DEFAULT '{}' COMMENT '珍品产出时间',
  `ptime` int(11) NOT NULL DEFAULT '0' COMMENT '最近合成时间',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '状态0无需合成1可合成',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `umixer` (
  `uid` int(10) unsigned NOT NULL COMMENT 'uid',
  `crystal` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '晶体(代币)',
  `sequipnum` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '超级装备投入数',
  `armornum` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '海兵方阵投入数',
  `accessorynum` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '配件投入数',
  `alienweaponnum` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '异星武器投入数',
  `shop` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '商店信息',
  `day_at` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `amixerlog` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '日志类型',
  `content` varchar(2000) NOT NULL DEFAULT '' COMMENT '最近合成时间',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `aid` (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 拼多多
CREATE TABLE `active_pdd` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL COMMENT '玩家uid',
  `bid` int(10) unsigned NOT NULL COMMENT ' 购买商品id',
  `bnum` int(10) unsigned NOT NULL COMMENT '购买商品数量',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
);


-- 指挥官徽章
-- 2018-09-12
-- chenyunhe
CREATE TABLE `badge` (
  `uid` int(10) unsigned NOT NULL,
  `info` varchar(5000) NOT NULL DEFAULT '{}' COMMENT '背包信息',
  `used` varchar(200) NOT NULL DEFAULT '{0,0,0,0,0,0}' COMMENT '使用中的',
  `fragment` varchar(1500) NOT NULL COMMENT '碎片',
  `exp` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '经验池',
  `challenge` varchar(1500) NOT NULL DEFAULT '{}' COMMENT '副本',
  `material` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '突破材料',
  `expPro` varchar(200) NOT NULL DEFAULT '{}' COMMENT '经验道具',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='指挥官徽章';

-- 是否已初始赠送徽章
ALTER TABLE `badge` ADD `initate` tinyint(1) unsigned NOT NULL DEFAULT '0' AFTER `expPro`;


-- 增加一个字段记录夺海奇兵总击杀数
-- 2018-11-7
-- hwm
ALTER TABLE `userkillrace`
  ADD COLUMN `avt_total_killed` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT '成就总击杀' AFTER `shop`;

-- 徽章系统 每个玩家购买挑战次数 消耗挑战次数
-- 2018-11-15
-- chenyunhe
ALTER TABLE `badge` ADD `buytimes` INT(11)  unsigned NOT NULL DEFAULT '0' AFTER `initate`;
ALTER TABLE `badge` ADD `battletimes` INT(11)  unsigned NOT NULL DEFAULT '0' AFTER `buytimes`;

-- 伟大航线
-- hwm
-- 2018-11-13
CREATE TABLE `agreatroute` (
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `bid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '大战id',
  `st` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '开启时间',
  `apply` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '报名标识',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `ranking` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '排名',
  `f1` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '据点',
  `f2` bigint(20) unsigned NOT NULL DEFAULT '0',
  `f3` bigint(20) unsigned NOT NULL DEFAULT '0',
  `f4` bigint(20) unsigned NOT NULL DEFAULT '0',
  `f5` bigint(20) unsigned NOT NULL DEFAULT '0',
  `f6` int(10) unsigned NOT NULL DEFAULT '0',
  `f7` int(10) unsigned NOT NULL DEFAULT '0',
  `f8` int(10) unsigned NOT NULL DEFAULT '0',
  `f9` int(10) unsigned NOT NULL DEFAULT '0',
  `f10` int(10) unsigned NOT NULL DEFAULT '0',
  `f11` int(10) unsigned NOT NULL DEFAULT '0',
  `f12` int(10) unsigned NOT NULL DEFAULT '0',
  `f13` int(10) unsigned NOT NULL DEFAULT '0',
  `f14` int(10) unsigned NOT NULL DEFAULT '0',
  `f15` int(10) unsigned NOT NULL DEFAULT '0',
  `f16` int(10) unsigned NOT NULL DEFAULT '0',
  `f17` int(10) unsigned NOT NULL DEFAULT '0',
  `f18` int(10) unsigned NOT NULL DEFAULT '0',
  `f19` int(10) unsigned NOT NULL DEFAULT '0',
  `f20` int(10) unsigned NOT NULL DEFAULT '0',
  `f21` int(10) unsigned NOT NULL DEFAULT '0',
  `f22` int(10) unsigned NOT NULL DEFAULT '0',
  `f23` int(10) unsigned NOT NULL DEFAULT '0',
  `f24` int(10) unsigned NOT NULL DEFAULT '0',
  `f25` int(10) unsigned NOT NULL DEFAULT '0',
  `pspeed` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '生产速度',
  `rebel` varchar(1500) NOT NULL DEFAULT '{}' COMMENT '叛军',
  `invadertroops` varchar(400) NOT NULL DEFAULT '{}' COMMENT '侵部队',
  `produce_at` int(11) unsigned NOT NULL DEFAULT '0',
  `invade_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '入侵时间',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ugreatroute` (
  `uid` int(10) unsigned NOT NULL COMMENT 'uid',
  `bid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '大战id',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `feat` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '功绩',
  `actionpoint` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '行动点数',
  `buff` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '部队编号',
  `rewarded` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '领奖标识',
  `explored` varchar(255) NOT NULL DEFAULT '{}' COMMENT '已参与过的地图信息',
  `day_buycnt` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '每日购买行动点次数',
  `shop` varchar(1000) NOT NULL DEFAULT '{}' COMMENT '商店信息',
  `ap_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '行动点恢复时间',
  `day_at` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ugreatroute_log` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '大战id',
  `uid` int(10) unsigned NOT NULL COMMENT '玩家id',
  `fort` char(3) NOT NULL DEFAULT '' COMMENT '据点id',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `win` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '是否胜利',
  `content` text NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `bid_uid` (`bid`,`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ugreatroute_troops` (
  `uid` int(10) unsigned NOT NULL COMMENT 'uid',
  `bid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '大战id',
  `troops` varchar(500) NOT NULL DEFAULT '{}' COMMENT '部队信息',
  `binfo` varchar(10000) DEFAULT '{}' COMMENT '部队战斗信息',
  `updated_at` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

