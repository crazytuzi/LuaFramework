DROP PROCEDURE IF EXISTS `updateSql`;

DELIMITER ;;
CREATE PROCEDURE `updateSql`()
BEGIN
	DECLARE lastVersion INT DEFAULT 1;
	DECLARE lastVersion1 INT DEFAULT 1;
	DECLARE versionNotes VARCHAR(255) DEFAULT '';
	
	SELECT MAX(tb_database_version.version) INTO lastVersion FROM tb_database_version;
	
	SET lastVersion=IFNULL((lastVersion),1);
	SET lastVersion1 = lastVersion;
	
##++++++++++++++++++++表格修改开始++++++++++++++++++++++++++++++
#***************************************************************

IF lastVersion<2 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_gem_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_gem_info` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gemid` int(11) NOT NULL COMMENT '宝石配置ID',
  `slot`	int(11) NOT NULL COMMENT '孔位',	
  `pos`	int(11) NOT NULL COMMENT '装备位',
  PRIMARY KEY (`charguid`,`slot`, `pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝石表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 2;
	SET versionNotes = 'add geminfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<3 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_equips`
	DROP COLUMN  `strenval`,
	ADD COLUMN	`emptystarnum` int(11) NOT NULL DEFAULT '0' COMMENT '空星位数量';
#-------------------------------------------------
	SET lastVersion = 3;
	SET versionNotes = 'mod equip';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion<4 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_equips`
	ADD COLUMN	`strenval` int(11) NOT NULL DEFAULT '0' COMMENT '强化值';
#-------------------------------------------------
	SET lastVersion = 4;
	SET versionNotes = 'mod equip';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<5 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_consignment_items`
	ADD COLUMN	`emptystarnum` int(11) NOT NULL DEFAULT '0' COMMENT '空星位数量';
#---------------------------------------------------

#---------------------------------------------
	ALTER TABLE	 `tb_guild_storage`
	ADD COLUMN	`emptystarnum` int(11) NOT NULL DEFAULT '0' COMMENT '空星位数量';
#-------------------------------------------------
	SET lastVersion = 5;
	SET versionNotes = 'mod consignment_items  and guild_storage';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<6 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_equips`
	DROP COLUMN	`wash`,
	DROP COLUMN `wash_attr`;
#---------------------------------------------------
	SET lastVersion = 6;
	SET versionNotes = 'mod tb_player_equips';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<7 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_consignment_items`
	DROP COLUMN	`wash`,
	DROP COLUMN `wash_attr`;
#---------------------------------------------------
#---------------------------------------------
	ALTER TABLE	 `tb_guild_storage`
	DROP COLUMN	`wash`,
	DROP COLUMN `wash_attr`;
#---------------------------------------------------
	SET lastVersion = 7;
	SET versionNotes = 'mod onsignment_items  and guild_storage';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<8 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_pifeng_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_pifeng_info` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `type` int(11) NOT NULL COMMENT '披风类型 0披风 1锦囊 2魔器',
  `lv`	int(11) NOT NULL COMMENT '阶数',
  `tid` bigint(20) NOT NULL COMMENT '配置表Id',  
  `val`	int(11) NOT NULL COMMENT '读条值',
  PRIMARY KEY (`charguid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='披风表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------------
	SET lastVersion = 8;
	SET versionNotes = 'add tb_pifeng_info';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<9 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_fabao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_fabao` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `id` bigint(20) NOT NULL COMMENT '法宝GUID',
  `tid` int(11) NOT NULL COMMENT '法宝配置ID',
  `level`	int(11) NOT NULL COMMENT '法宝等级',	
  `exp`	int(11) NOT NULL COMMENT '法宝经验',
  `changed`	int(11) NOT NULL COMMENT '法宝变异',
  `state`	int(11) NOT NULL COMMENT '法宝状态',
  `skills` varchar(256) NOT NULL DEFAULT '' COMMENT '法宝技能',
  `abilities` varchar(128) NOT NULL DEFAULT '' COMMENT '法宝资质',
  `updatetime` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='法宝表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 9;
	SET versionNotes = 'add fabaoinfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<10 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_pifeng_info`;
DROP TABLE IF EXISTS `tb_player_pifeng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_pifeng` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `type` int(11) NOT NULL COMMENT '披风类型 0披风 1锦囊 2魔器',
  `lv`	int(11) NOT NULL COMMENT '阶数',
  `tid` bigint(20) NOT NULL COMMENT '配置表Id',  
  `val`	int(11) NOT NULL COMMENT '读条值',
  PRIMARY KEY (`charguid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='披风表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------

#---------------------------------------------
DROP TABLE IF EXISTS `tb_gem_info`;
DROP TABLE IF EXISTS `tb_player_gem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_gem` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `gemid` int(11) NOT NULL COMMENT '宝石配置ID',
  `slot`	int(11) NOT NULL COMMENT '孔位',	
  `pos`	int(11) NOT NULL COMMENT '装备位',
  PRIMARY KEY (`charguid`,`slot`, `pos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝石表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 10;
	SET versionNotes = 'modify tb_player_pifeng and tb_player_gem';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<11 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_vitality`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_vitality` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `exp` int(11) NOT NULL COMMENT '活跃度经验',
  `level` int(11) NOT NULL COMMENT '活跃度等级',
  `task` varchar(350) NOT NULL DEFAULT '' COMMENT '活跃度任务',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='活跃度表';
/*!40101 SET character_set_client = @saved_cs_client */;
#--------------------------------------------------
	SET lastVersion = 11;
	SET versionNotes = 'add vitality table';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<12 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_pifeng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_pifeng` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `type` int(11) NOT NULL COMMENT '披风类型 0披风 1锦囊 2魔器',
  `lv`	int(11) NOT NULL COMMENT '阶数',
  `tid` int(11) NOT NULL COMMENT '配置表Id',  
  `val`	int(11) NOT NULL COMMENT '读条值',
  PRIMARY KEY (`charguid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='披风表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 12;
	SET versionNotes = 'modify tb_player_pifeng';
#---------------------------------------------------
END IF;


IF lastVersion<13 THEN
#---------------------------------------------
#---------------------------------------------
	ALTER TABLE	 `tb_player_info`
	ADD COLUMN	`shoulder` int(11) NOT NULL  COMMENT '肩膀Tid';
#-------------------------------------------------
#-------------------------------------------------

#---------------------------------------------------
	SET lastVersion = 13;
	SET versionNotes = 'modify tb_player_info';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<14 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_juexue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_juexue` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `juexueids` varchar(256) NOT NULL DEFAULT '' COMMENT '绝学技能ID列表',
  `juexuelvs` varchar(256) NOT NULL DEFAULT '' COMMENT '绝学技能等级列表',
  `xinfaids` varchar(256) NOT NULL DEFAULT '' COMMENT '心法技能ID列表',
  `xinfalvs` varchar(256) NOT NULL DEFAULT '' COMMENT '心法技能等级列表',
  PRIMARY KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='绝学表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------

DROP TABLE IF EXISTS `tb_player_fumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_fumo` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `fumoids` varchar(512) NOT NULL DEFAULT '' COMMENT '图鉴ID列表',
  `fumolvs` varchar(512) NOT NULL DEFAULT '' COMMENT '图鉴等级列表',
  `fumonum` varchar(512) NOT NULL DEFAULT '' COMMENT '图鉴物品数量列表',
  PRIMARY KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='图鉴表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 14;
	SET versionNotes = 'add juexueinfo,fumoinfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<15 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`extraplus_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '玩家额外增加活动时长';
#-------------------------------------------------
	SET lastVersion = 15;
	SET versionNotes = 'mod activity,add extraplus_time';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<16 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_zhuanzhi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_zhuanzhi` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `lv`	int(11) NOT NULL COMMENT '几转',
  `task` varchar(128) NOT NULL COMMENT '任务id#任务完成标志#奖励领取标志',  
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='转职表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 16;
	SET versionNotes = 'modify tb_player_zhuanzhi';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<17 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_app_hang`;
DROP TABLE IF EXISTS `tb_player_wuhuns`;
DROP TABLE IF EXISTS `tb_player_ls_horse`;
DROP TABLE IF EXISTS `tb_player_wuxing_item`;
DROP TABLE IF EXISTS `tb_player_wuxing_pro`;

#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 17;
	SET versionNotes = 'delete unused tables';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<18 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_shenbing`;
DROP TABLE IF EXISTS `tb_player_realm`;

#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 18;
	SET versionNotes = 'delete unused tables';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<19 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_yuanling`;
DROP TABLE IF EXISTS `tb_player_shengling`;
DROP TABLE IF EXISTS `tb_player_shengling_skin`;
DROP TABLE IF EXISTS `tb_player_zhannu`;
DROP TABLE IF EXISTS `tb_player_lunpan`;
DROP TABLE IF EXISTS `tb_zhenbaoge`;
DROP TABLE IF EXISTS `tb_soul_info`;

#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 19;
	SET versionNotes = 'delete unused tables';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<20 THEN
#---------------------------------------------
#---------------------------------------------

DROP TABLE IF EXISTS `tb_fieldboss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_fieldboss` (
  `id` int(11) NOT NULL COMMENT '野外BOSS配置表ID',
  `isdead` int(11) NOT NULL DEFAULT '0' COMMENT 'BOSS是否死亡',
  `lastkiller` bigint(20) NOT NULL DEFAULT '0' COMMENT '击杀者GUID',
  `killername` varchar(64) NOT NULL DEFAULT '' COMMENT '击杀者名称',
  `killtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'boss被击杀时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='野外BOSS表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 20;
	SET versionNotes = 'add tb_fieldboss';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<21 THEN
#---------------------------------------------
#---------------------------------------------

DROP TABLE IF EXISTS `tb_digongboss`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_digongboss` (
  `id` int(11) NOT NULL COMMENT '地宫BOSS配置表ID',
  `isdead` int(11) NOT NULL DEFAULT '0' COMMENT 'BOSS是否死亡',
  `killtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'boss被击杀时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='地宫BOSS表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 21;
	SET versionNotes = 'add tb_digongboss';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<22 THEN
#---------------------------------------------
#---------------------------------------------
	ALTER TABLE	 `tb_player_pifeng`
	ADD COLUMN	`star`	int(11) NOT NULL COMMENT '星级';
#---------------------------------------------------
	SET lastVersion = 22;
	SET versionNotes = 'modify tb_pifeng_info';
#---------------------------------------------------
END IF;
#---------------------------------------------------
#---------------------------------------------------


#---------------------------------------------------
IF lastVersion<23 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_star`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_star` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `starpos` varchar(128) NOT NULL DEFAULT '' COMMENT '星图位置',
  `starlv` varchar(128) NOT NULL DEFAULT '' COMMENT '星图等级',
  PRIMARY KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='星图表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 23;
	SET versionNotes = 'add starinfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<24 THEN
#---------------------------------------------
#---------------------------------------------
ALTER TABLE	 `tb_pvp_season_history`
ADD COLUMN `shoulder`	int(11) NOT NULL COMMENT '肩膀';

ALTER TABLE	 `tb_party_rank`
ADD COLUMN `shoulder`	int(11) NOT NULL COMMENT '肩膀';
#-------------------------------------------------
	SET lastVersion = 24;
	SET versionNotes = 'modify tb_pvp_season_history  and  tb_party_rank';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion< 25 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_zhuanzhi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_zhuanzhi` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `lv`	int(11) NOT NULL DEFAULT '0' COMMENT '几转',
  `step` int(11) NOT NULL DEFAULT '0' COMMENT '剧情步骤',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT '任务领取次数',
  `task` varchar(128) NOT NULL DEFAULT '' COMMENT '任务id#任务完成标志#次数',
  `task1` varchar(128) NOT NULL DEFAULT '' COMMENT'任务id#任务完成标志#次数',
  `task2` varchar(128) NOT NULL DEFAULT '' COMMENT'任务id#任务完成标志#次数',
  `task3` varchar(128) NOT NULL DEFAULT '' COMMENT'任务id#任务完成标志#次数',
  `task4` varchar(128) NOT NULL DEFAULT '' COMMENT'任务id#任务完成标志#次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='转职表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------
	SET lastVersion = 25;
	SET versionNotes = 'modify tb_player_zhuanzhi';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<26 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_vitality`
	ADD COLUMN	`model` int(11) NOT NULL DEFAULT '0' COMMENT '外显模型ID';
#-------------------------------------------------
	SET lastVersion = 26;
	SET versionNotes = 'mod xianjie,add model';
#---------------------------------------------------
END IF;
#---------------------------------------------------
IF lastVersion<27 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_pifeng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_pifeng` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `type` int(11) NOT NULL COMMENT '披风类型 0披风 1锦囊 2魔器',
  `lv`	int(11) NOT NULL COMMENT '阶数',
  `tid` int(11) NOT NULL COMMENT '配置表Id',  
  `val`	int(11) NOT NULL COMMENT '读条值',
  `star`	int(11) NOT NULL COMMENT '星级',
  PRIMARY KEY (`charguid`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='披风表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 27;
	SET versionNotes = 'modify tb_player_pifeng';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion<28 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_superlib`;
DROP TABLE IF EXISTS `tb_player_superhole`;
#---------------------------------------------
#---------------------------------------------------
	SET lastVersion = 28;
	SET versionNotes = 'modify tb_player_superlib and  tb_player_superhole';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<29 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`gold_boss_reward` bigint(20) NOT NULL DEFAULT '0' COMMENT '金币BOSS金钱收益';
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`mess_fight_name` varchar(32) NOT NULL DEFAULT '' COMMENT '乱斗临时名称';
#-------------------------------------------------
	SET lastVersion = 29;
	SET versionNotes = 'mod activity,add gold_boss_reward,add mess_fight_name';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<30 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	DROP COLUMN  `mess_fight_name`,
	ADD COLUMN	`kill_count` int(11) NOT NULL DEFAULT '0' COMMENT '累计击杀';
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`be_kill_count` int(11) NOT NULL DEFAULT '0' COMMENT '累计被击杀';
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`continue_kill_count` int(11) NOT NULL DEFAULT '0' COMMENT '连续击杀';
#-------------------------------------------------
	SET lastVersion = 30;
	SET versionNotes = 'mod activity,drop mess_fight_name,add kill,add be_kill,add continue_kill';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<31 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_first_day_goal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_first_day_goal` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `goalid` int(11) NOT NULL DEFAULT '0' COMMENT '目标ID',
  `goalstate` int(11) NOT NULL DEFAULT '0' COMMENT '目标状态',
  PRIMARY KEY (`charguid`,`goalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='首日目标表,记录玩家首日目标信息';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
#---------------------------------------------------
	SET lastVersion = 31;
	SET versionNotes = 'modify tb_first_day_goal';
#---------------------------------------------------
END IF;

#----------------------------------------------------------------------
IF lastVersion<32 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_crosstask`;
	CREATE TABLE `tb_player_crosstask` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `quest_id` int(11) NOT NULL COMMENT '任务ID',
	  `questgid` bigint(20) NOT NULL COMMENT '任务唯一ID',
	  `quest_state` int(11) NOT NULL DEFAULT '0' COMMENT '任务状态',
	  `goal1` bigint(20) NOT NULL DEFAULT '0' COMMENT '任务目标ID',
	  `goal_count1` int(11) NOT NULL DEFAULT '0' COMMENT '任务目标计数',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`charguid`,`quest_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服任务表';
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_crosstask_extra`;
	CREATE TABLE `tb_player_crosstask_extra` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `score` int(11) NOT NULL COMMENT '积分',
	  `onlinetime` int(11) NOT NULL COMMENT '在线时间',
	  `refreshtimes` int(11) NOT NULL DEFAULT '0' COMMENT '剩余刷新次数',
	  `lastrefreshtime` bigint(20) NOT NULL DEFAULT '0' COMMENT '上次刷新时间',
	  `questlist` varchar(128) NOT NULL DEFAULT '' COMMENT '任务列表',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服任务额外信息表';
#----------------------------------------------------------------------
	SET lastVersion = 32; 
	SET versionNotes = 'add cross task';
#----------------------------------------------------------------------
END IF;


#---------------------------------------------------
IF lastVersion<33 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_equips`
	ADD COLUMN	`ring_lv` int(11) NOT NULL DEFAULT '0' COMMENT '左戒等级 只有左戒有';
	ALTER TABLE	 `tb_player_equips`
	ADD COLUMN	`monster_count` int(11) NOT NULL DEFAULT '0' COMMENT '左戒当前杀敌数';
#-------------------------------------------------
	SET lastVersion = 33;
	SET versionNotes = 'mod tb_player_equips';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<34 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_extra`
	ADD COLUMN	`zhanyin_num` int(11) NOT NULL DEFAULT '0' COMMENT '战印解锁个数';
	ALTER TABLE	 `tb_player_extra`
	ADD COLUMN	`dongtian_lv` int(11) NOT NULL DEFAULT '0' COMMENT '洞天等级';
#-------------------------------------------------
	SET lastVersion = 34;
	SET versionNotes = 'mod tb_player_extra';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<35 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_fengyao`
	ADD COLUMN	`monster_count` int(11) NOT NULL DEFAULT '0' COMMENT '斩妖除魔杀敌数';
	ALTER TABLE	 `tb_player_fengyao`
	ADD COLUMN  `fresh_time` bigint(20) NOT NULL COMMENT '上次刷新时间';
#-------------------------------------------------
	SET lastVersion = 35;
	SET versionNotes = 'mod tb_player_fengyao';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<36 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`meal_type` int(11) NOT NULL DEFAULT '0' COMMENT '套餐类型';
#-------------------------------------------------
	SET lastVersion = 36;
	SET versionNotes = 'mod activity,add meal_type';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<37 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`banquet_reward` bigint(20) NOT NULL DEFAULT '0' COMMENT '挂机经验奖励';
#-------------------------------------------------
	SET lastVersion = 37;
	SET versionNotes = 'mod activity,add banquet_reward';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#----------------------------------------------------------------------
IF lastVersion<38 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_dungeon_group`;
	CREATE TABLE `tb_player_dungeon_group` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `group_id` int(11) NOT NULL DEFAULT '0' COMMENT '副本组ID',
	  `diff` int(11) NOT NULL DEFAULT '0' COMMENT '难度',
	  `free_count` int(11) NOT NULL DEFAULT '0' COMMENT '剩余次数',
	  `buy_count` int(11) NOT NULL DEFAULT '0' COMMENT '购买次数',
	  `best_time` int(11) NOT NULL DEFAULT '0' COMMENT '最佳通关时间',
	  `scores` varchar(256) NOT NULL DEFAULT '0,0,0,0,0' COMMENT '积分',
	  PRIMARY KEY (`charguid`,`group_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家副本组信息表';
#----------------------------------------------------------------------
	SET lastVersion = 38; 
	SET versionNotes = 'change scores size';
#----------------------------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion<39 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_activity`
	ADD COLUMN	`banquet_cultivation` bigint(20) NOT NULL DEFAULT '0' COMMENT '挂机修为奖励';
#-------------------------------------------------
	SET lastVersion = 39;
	SET versionNotes = 'mod activity,add banquet_cultivation';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<40 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_bianshen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_bianshen` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `id` bigint(20) NOT NULL COMMENT '变身GUID',
  `tid` int(11) NOT NULL COMMENT '变身配置ID',
  `star` int(11) NOT NULL COMMENT '变身星级',	
  `step` int(11) NOT NULL COMMENT '变身阶级',
  `wish` int(11) NOT NULL COMMENT '变身灵力',
  `model` int(11) NOT NULL COMMENT '变身皮肤',
  `energy` int(11) NOT NULL COMMENT '变身能量',
  `state` int(11) NOT NULL COMMENT '变身状态',
  PRIMARY KEY (`id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='变身表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 40;
	SET versionNotes = 'add biansheninfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<41 THEN
#---------------------------------------------
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
  `dropseq` int(11) NOT NULL DEFAULT '0' COMMENT '击杀掉落序号',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='boss徽章';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 41;
	SET versionNotes = 'add dropseq';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<42 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_equipcollect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
#---------------------------------------------
   CREATE TABLE `tb_player_equipcollect` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `get_state` int(11) NOT NULL DEFAULT '0' COMMENT '领取状态',
  `lv`  int(11) NOT NULL DEFAULT '0' COMMENT '几阶',
  `first_activite` int(11) NOT NULL  DEFAULT '0' COMMENT '是否激活',
  `second_activite` int(11) NOT NULL  DEFAULT '0' COMMENT '是否激活',
  `third_activite` int(11) NOT NULL  DEFAULT '0' COMMENT '是否激活',
  `index_state` varchar(128) NOT NULL COMMENT '索引,状态#索引,状态#索引,状态',  
  PRIMARY KEY (`charguid`, lv)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神装收集';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------
#-------------------------------------------------
#---------------------------------------------------
    SET lastVersion = 42;
    SET versionNotes = 'modify tb_player_equipcollect';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<43 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_package`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_package` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `pack_id` int(11) NOT NULL DEFAULT '0' COMMENT '宝箱ID',
  `pack_num` int(11) NOT NULL DEFAULT '0' COMMENT '使用次数',
  PRIMARY KEY (`charguid`,`pack_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝箱表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
#---------------------------------------------------
    SET lastVersion = 43;
    SET versionNotes = 'add tb_player_package';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<44 THEN
#---------------------------------------------
#---------------------------------------------
	ALTER TABLE `tb_player_pifeng`
	ADD COLUMN	`outlook` int(11) NOT NULL DEFAULT '0' COMMENT '神炉外显';
	ALTER TABLE `tb_player_pifeng`
	ADD COLUMN   `set_on` int(11) NOT NULL DEFAULT '0' COMMENT '0是不启用  1是启用';
#-------------------------------------------------
	SET lastVersion = 44;
	SET versionNotes = 'mod tb_player_pifeng,add outlook';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<45 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_timers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_timers` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型',
  `timer_type` int(11) NOT NULL DEFAULT '0' COMMENT '定时器类型',
  `expire_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '过期时刻',
  `custom_data` bigint(20) NOT NULL DEFAULT '0' COMMENT '定制数据',
  PRIMARY KEY (`charguid`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='定时器表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
#---------------------------------------------------
    SET lastVersion = 45;
    SET versionNotes = 'add tb_player_timers';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<46 THEN
DROP TABLE IF EXISTS `tb_player_refine_danyao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_refine_danyao` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `xiuwei` int(11) NOT NULL DEFAULT '0' COMMENT '当前可用的修为值',
  `accumulate` int(11) NOT NULL DEFAULT '0' COMMENT '当天累计产生的修为值',
  `refine_times` bigint(20) NOT NULL DEFAULT '0' COMMENT '今日炼制丹药次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='炼制丹药表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------------
#---------------------------------------------------
    SET lastVersion = 46;
    SET versionNotes = 'add tb_player_refine_danyao';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<47 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_waterdup`
	ADD COLUMN  `fresh_time` bigint(20) NOT NULL COMMENT '上次进入副本时间';
#-------------------------------------------------
	SET lastVersion = 47;
	SET versionNotes = 'mod tb_waterdup';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion < 48 THEN
#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_taofa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_taofa` (
`charguid` bigint(20) NOT NULL COMMENT '角色GUID',
`finsh_count` int(11) NOT NULL COMMENT '当天完成次数',
`taskid` int(11) NOT NULL COMMENT '当天任务id',
PRIMARY KEY(`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='讨伐副本表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------------
#---------------------------------------------------
    SET lastVersion = 48;
    SET versionNotes = 'add tb_player_taofa';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 49 THEN
#---------------------------------------------------
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

#---------------------------------------------------
    SET lastVersion = 49;
    SET versionNotes = 'add tb_player_realm';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 50 THEN
#---------------------------------------------------
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
#---------------------------------------------------
    SET lastVersion = 50;
    SET versionNotes = 'add tb_player_shenbing';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 51 THEN
#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_lingqi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_lingqi` (
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
#---------------------------------------------------
    SET lastVersion = 51;
    SET versionNotes = 'add tb_player_lingqi';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 52 THEN
#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_zhuxianzhen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_zhuxianzhen` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL COMMENT '当前挑战层数',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '最短通关时间s',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '今日挑战次数',
  PRIMARY KEY (`charguid`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='单人副本朱仙镇';
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `tb_rank_zhuxianzhen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_rank_zhuxianzhen` (
  `rank` int(11) NOT NULL COMMENT '朱仙镇排名',
  `guid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT '时间或者层数',
  `name` varchar(32) NOT NULL DEFAULT '' COMMENT '玩家名字',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '玩家等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='朱仙镇排名';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------------
    SET lastVersion = 52;
    SET versionNotes = 'add tb_player_zhuxianzhen and  mod tb_babel_rank';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 53 THEN
#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_mingyu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_mingyu` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '命玉等级',
  `wish` int(11) NOT NULL DEFAULT '0' COMMENT '命玉祝福值',
  `proficiency` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度',
  `proficiencylvl` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度等级',
  `procenum` int(11) NOT NULL DEFAULT '0' COMMENT '进阶失败次数',
  `skinlevel` int(11) NOT NULL DEFAULT '0' COMMENT '命玉皮肤',
  `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '命玉属性丹数量',
  `bingling` varchar(300) NOT NULL DEFAULT '' COMMENT '兵灵',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='命玉表';
/*!40101 SET character_set_client = @saved_cs_client */;
#---------------------------------------------------
    SET lastVersion = 53;
    SET versionNotes = 'add tb_player_shenbing';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion < 54 THEN
#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_fumo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_fumo` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `fumoids` varchar(2048) NOT NULL DEFAULT '' COMMENT '图鉴ID列表',
  `fumolvs` varchar(1024) NOT NULL DEFAULT '' COMMENT '图鉴等级列表',
  `fumonum` varchar(1024) NOT NULL DEFAULT '' COMMENT '图鉴物品数量列表',
  PRIMARY KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='图鉴表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 54;
	SET versionNotes = 'add juexueinfo,fumoinfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<55 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_bianshen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_bianshen` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `id` bigint(20) NOT NULL COMMENT '变身GUID',
  `tid` int(11) NOT NULL COMMENT '变身配置ID',
  `star` int(11) NOT NULL COMMENT '变身星级',	
  `step` int(11) NOT NULL COMMENT '变身阶级',
  `model` int(11) NOT NULL COMMENT '变身皮肤',
  `state` int(11) NOT NULL COMMENT '变身状态',
  `curattrs` varchar(128) NOT NULL DEFAULT '' COMMENT '当前属性信息',
  `allattrs` varchar(128) NOT NULL DEFAULT '' COMMENT '所有属性信息',
  PRIMARY KEY (`id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='变身表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 55;
	SET versionNotes = 'add biansheninfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------


#---------------------------------------------------
IF lastVersion< 56 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_zhuxianzhen`
	ADD COLUMN  `history_kill` int(11) NOT NULL COMMENT '历史最高波数';
	
--
-- Table structure for table `tb_player_muyewar`
--
DROP TABLE IF EXISTS `tb_player_muyewar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_muyewar` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT 'guid',
  `count` int(11) NOT NULL DEFAULT '0' COMMENT '今日次数',
  `today` int(11) NOT NULL DEFAULT '0' COMMENT '今日层数',
  `history` int(11) NOT NULL DEFAULT '0' COMMENT '历史层数',
  `getreward` varchar(256) NOT NULL DEFAULT '' COMMENT '第几个,领取状态#第几个,领取状态',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='牧业之战副本表';
/*!40101 SET character_set_client = @saved_cs_client */;

#-------------------------------------------------
	SET lastVersion = 56;
	SET versionNotes = 'add tb_player_muyewar';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<57 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `tid` int(11) NOT NULL COMMENT '任务配置ID',
  `count` int(11) NOT NULL COMMENT '任务计数',	
  `state` int(11) NOT NULL COMMENT '任务状态',
  `reward` int(11) NOT NULL COMMENT '奖励项',
  `choice` int(11) NOT NULL COMMENT '选择项',
  PRIMARY KEY (`charguid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora_count` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `tid` int(11) NOT NULL COMMENT '奖励项配置ID',
  `count` int(11) NOT NULL COMMENT '奖励项当天完成次数',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务奖励计数表';
/*!40101 SET character_set_client = @saved_cs_client */;

#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora_info` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `finish_count` int(11) NOT NULL COMMENT '免费刷新所需完成任务次数',
  `free_refresh_points` int(11) NOT NULL COMMENT '免费刷新点数',
  `next_server_refresh` bigint(20) NOT NULL COMMENT '下次服务器刷新时刻',
  `next_accept_time` bigint(20) NOT NULL COMMENT '下次可领取任务的时刻',
  `choice_finish_num` int(11) NOT NULL COMMENT '可以选择的任务列表内已完成的任务数量',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

#-------------------------------------------------
	SET lastVersion = 57;
	SET versionNotes = 'add tb_player_questagora';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<58 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `uuid` bigint(20) NOT NULL COMMENT '唯一UUID',
  `tid` int(11) NOT NULL COMMENT '任务配置ID',
  `count` int(11) NOT NULL COMMENT '任务计数',	
  `state` int(11) NOT NULL COMMENT '任务状态',
  `reward` int(11) NOT NULL COMMENT '奖励项',
  `choice` int(11) NOT NULL COMMENT '选择项',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 58;
	SET versionNotes = 'add tb_player_questagora';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<59 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `uuid` bigint(20) NOT NULL COMMENT '唯一UUID',
  `tid` int(11) NOT NULL COMMENT '任务配置ID',
  `count` int(11) NOT NULL COMMENT '任务计数',	
  `state` int(11) NOT NULL COMMENT '任务状态',
  `reward` int(11) NOT NULL COMMENT '奖励项',
  `choice` int(11) NOT NULL COMMENT '选择项',
  `param` int(11) NOT NULL COMMENT '参数项',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 59;
	SET versionNotes = 'add tb_player_questagora';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<60 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_questagora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
#-------------------------------------------------
CREATE TABLE `tb_player_questagora` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `uuid` bigint(20) NOT NULL COMMENT '唯一UUID',
  `tid` int(11) NOT NULL COMMENT '任务配置ID',
  `count` int(11) NOT NULL COMMENT '任务计数',	
  `state` int(11) NOT NULL COMMENT '任务状态',
  `reward` int(11) NOT NULL COMMENT '奖励项',
  `choice` int(11) NOT NULL COMMENT '选择项',
  `param` int(11) NOT NULL COMMENT '参数项',
  `level` int(11) NOT NULL COMMENT '任务等级',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  PRIMARY KEY (`charguid`,`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='屠魔任务表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 60;
	SET versionNotes = 'add tb_player_questagora';
#---------------------------------------------------
END IF;
#---------------------------------------------------


IF lastVersion<61 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_rank_lingqi`;
CREATE TABLE `tb_rank_lingqi` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '灵器等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵器排行';

DROP TABLE IF EXISTS `tb_rank_baojia`;
CREATE TABLE `tb_rank_baojia` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '宝甲等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝甲排行';


DROP TABLE IF EXISTS `tb_rank_mingyu`;
CREATE TABLE `tb_rank_mingyu` (
  `rank` int(11) NOT NULL COMMENT '排行',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '命玉等级',
  PRIMARY KEY (`rank`),
  KEY `guid_idx` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='命玉排行';

#---------------------------------------------------
DROP TABLE IF EXISTS `tb_player_baojia`;
CREATE TABLE `tb_player_baojia` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT '宝甲等级',
  `wish` int(11) NOT NULL DEFAULT '0' COMMENT '宝甲祝福值',
  `proficiency` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度',
  `proficiencylvl` int(11) NOT NULL DEFAULT '0' COMMENT '熟练度等级',
  `procenum` int(11) NOT NULL DEFAULT '0' COMMENT '进阶失败次数',
  `skinlevel` int(11) NOT NULL DEFAULT '0' COMMENT '宝甲皮肤',
  `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '宝甲属性丹数量',
  `bingling` varchar(300) NOT NULL DEFAULT '' COMMENT '兵灵',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='宝甲表';

#-------------------------------------------------
	SET lastVersion = 61;
	SET versionNotes = 'add all ranks';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion< 62 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_baoji`;
CREATE TABLE `tb_player_baoji` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `end_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '道具到期时间',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT '类型',
  `kind` int(11) NOT NULL DEFAULT '0' COMMENT '子类型',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家暴击表';
#-------------------------------------------------
	SET lastVersion = 62;
	SET versionNotes = 'add tb_player_baoji';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion< 63 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_baoji`
	ADD COLUMN  `timestamp` bigint(20) NOT NULL COMMENT '时间戳';
#-------------------------------------------------
	SET lastVersion = 63;
	SET versionNotes = 'mod tb_player_baoji';
#---------------------------------------------------
END IF;
  
#---------------------------------------------------
IF lastVersion < 64 THEN
#---------------------------------------------

DROP TABLE IF EXISTS `tb_player_vip`;
CREATE TABLE `tb_player_vip` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `vip_exp` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip经验',
  `vip_lvlreward` int(11) NOT NULL DEFAULT '0' COMMENT 'vip等级奖励',
  `vip_weekrewardtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip周奖励领取时间',
  `vip_typelasttime1` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间1',
  `vip_typelasttime2` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间2',
  `vip_typelasttime3` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间3',
  `redpacketcnt` int(11) NOT NULL DEFAULT '0' COMMENT 'VIP特权红包发送次数',
  `dungeoncnt` int(11) NOT NULL DEFAULT '0' COMMENT 'VIP特权参加副本次数',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `tb_player_todayquest`;
CREATE TABLE `tb_player_todayquest` (
  `charguid` bigint(20) NOT NULL COMMENT '玩家GUID',
  `quest_id` int(11) NOT NULL DEFAULT '0' COMMENT '任务ID',
  `quest_counter` int(11) NOT NULL DEFAULT '0' COMMENT '当前环数',
  `quest_flags` int(11) NOT NULL DEFAULT '0' COMMENT '是否自动升星',
  `quest_counter_id` varchar(256) NOT NULL DEFAULT '0' COMMENT '今日完成日环信息',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='新日环信息表';

#-------------------------------------------------
	SET lastVersion = 64;
	SET versionNotes = 'mod tb_player_vip';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion< 65 THEN
#---------------------------------------------
	ALTER TABLE	 `tb_player_baojia`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
	
	ALTER TABLE	 `tb_player_mingyu`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
	
	ALTER TABLE	 `tb_player_lingqi`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
	
	ALTER TABLE	 `tb_player_shenbing`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
	
	ALTER TABLE	 `tb_player_realm`
	ADD COLUMN    `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量';
	ALTER TABLE	 `tb_player_realm`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
	
	ALTER TABLE	 `tb_ride`
	ADD COLUMN    `zizhi_num` int(11) NOT NULL DEFAULT '0' COMMENT '资质丹数量';
#-------------------------------------------------
	SET lastVersion = 65;
	SET versionNotes = 'mod tb_player_baojia';
#---------------------------------------------------
END IF;



#---------------------------------------------------
IF lastVersion< 66 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_lianqi`;
CREATE TABLE `tb_player_lianqi` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '0是 上次为银两开天 1 是元宝开天',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='炼器开天表';
#-------------------------------------------------
	SET lastVersion = 66;
	SET versionNotes = 'add tb_player_lianqi';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion< 67 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_group_charge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_group_charge` (
  `id` int(11) NOT NULL DEFAULT '0' COMMENT 'ID',
  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '首充人数',
  `extracnt` int(11) NOT NULL DEFAULT '0' COMMENT '额外人数',
  `groupid` int(11) NOT NULL DEFAULT '0' COMMENT '当前首充团购活动组id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='首充团购表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 67;
	SET versionNotes = 'add groupid to tb_group_charge';
#---------------------------------------------------
END IF;
#---------------------------------------------------


#---------------------------------------------------
IF lastVersion< 68 THEN
#---------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_party` (
  `id` int(11) NOT NULL COMMENT '活动ID',
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
  `award` int(11) NOT NULL DEFAULT '0' COMMENT '奖励标记',
  `awardtimes` int(11) NOT NULL DEFAULT '0' COMMENT '奖励次数',
  `charge` int(11) NOT NULL DEFAULT '0' COMMENT '活动期间内充值金额',
  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
  `param3` int(11) NOT NULL DEFAULT '0' COMMENT '参数3',
  PRIMARY KEY (`charguid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='运营活动表';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 68;
	SET versionNotes = 'add charge to tb_player_party';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#---------------------------------------------------
IF lastVersion<69 THEN 
#---------------------------------------------------
	ALTER TABLE tb_player_vplan
	ADD COLUMN `weishi_get_time` int(11) NOT NULL DEFAULT '0'  COMMENT '卫士渠道进入时间';
#---------------------------------------------------
	SET lastVersion = 69;
	SET versionNotes = 'add weishi get time';
#---------------------------------------------------
END IF;

#---------------------------------------------------
IF lastVersion<70 THEN 
#---------------------------------------------------
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_firstdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tb_player_firstdata` (
  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '是否已经初始化 0还没有 1已经初始化',
  PRIMARY KEY (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='';
/*!40101 SET character_set_client = @saved_cs_client */;
#-------------------------------------------------
	SET lastVersion = 70;
	SET versionNotes = 'add tb_player_firstdata';
#---------------------------------------------------
END IF;
#---------------------------------------------------

IF lastVersion<71 THEN
#---------------------------------------------
DROP TABLE IF EXISTS `tb_player_tianshen`;
CREATE TABLE `tb_player_tianshen` (
  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
  `id` bigint(20) NOT NULL COMMENT '天神GUID',
  `tid` int(11) NOT NULL COMMENT '天神配置ID',
  `cardtid` int(11) NOT NULL COMMENT '天神卡配置ID',
  `ability` int(11) NOT NULL COMMENT '天神资质',
  `star` int(11) NOT NULL COMMENT '天神星级',	
  `step` int(11) NOT NULL COMMENT '天神阶级',
  `stepexp` int(11) NOT NULL COMMENT '天神阶级进度',
  `state` int(11) NOT NULL COMMENT '天神状态',
  `pos` int(11) NOT NULL COMMENT '天神位置',
  `getmap` int(11) NOT NULL COMMENT '天神获得地图',
  `gettime` int(11) NOT NULL COMMENT '天神获得时间',
  `passskills` varchar(128) NOT NULL DEFAULT '' COMMENT '当前被动技能',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  PRIMARY KEY (`id`),
  KEY `charguid` (`charguid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='天神表';
#-------------------------------------------------
	SET lastVersion = 71;
	SET versionNotes = 'add tiansheninfo';
#---------------------------------------------------
END IF;
#---------------------------------------------------

#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
##++++++++++++++++++++表格修改完成++++++++++++++++++++++++++++++

IF lastVersion > lastVersion1 THEN 
	INSERT INTO tb_database_version(version, updateDate, lastSql) values(lastVersion, now(), versionNotes);
END IF;
END;;
DELIMITER ;
call updateSql ();
DROP PROCEDURE IF EXISTS `updateSql`;

##++++++++++++++++++++过程修改开始++++++++++++++++++++++++++++++
#***************************************************************
DELIMITER ;;

#***************************************************************
##版本1修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_gem_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gem_info`;
CREATE PROCEDURE `sp_select_gem_info`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_gem WHERE charguid=in_charguid;
END;;


-- ----------------------------
-- Procedure structure for sp_insert_update_gem
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_gem`;
CREATE PROCEDURE `sp_insert_update_gem`(IN `in_charguid` bigint, IN `in_gemid` int, IN `in_slot` int, IN `in_pos` int)
BEGIN
	INSERT INTO tb_player_gem(charguild,gemid,slot,pos) VALUES(in_charguid,in_gemid,in_slot,in_pos);
END;;
-- ----------------------------
#***************************************************************
##版本1修改完成
#***************************************************************

-- ----------------------------
#***************************************************************
##版本2修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_delete_gem
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_delete_gem`;
CREATE PROCEDURE `sp_delete_gem`(IN `in_charguid` bigint, IN `in_slot` int, IN `in_pos` int)
BEGIN
	DELETE FROM tb_player_gem WHERE charguild=in_charguid AND slot=in_slot AND pos=in_pos;
END;;
-- ----------------------------

-- ----------------------------
-- Procedure structure for sp_select_gem_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gem_info`;
CREATE PROCEDURE `sp_select_gem_info`()
BEGIN
	SELECT * FROM tb_player_gem;
END;;

#***************************************************************
##版本2修改完成修改完成
#***************************************************************

#***************************************************************
##版本3修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_gem_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gem_info`;
CREATE PROCEDURE `sp_select_gem_info`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_gem WHERE charguid=in_charguid;
END;;


-- ----------------------------
-- Procedure structure for sp_insert_update_gem
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_gem`;
CREATE PROCEDURE `sp_insert_update_gem`(IN `in_charguid` bigint, IN `in_gemid` int, IN `in_slot` int, IN `in_pos` int)
BEGIN
	INSERT INTO tb_player_gem(charguid,gemid,slot,pos) VALUES(in_charguid,in_gemid,in_slot,in_pos)
	ON DUPLICATE KEY UPDATE
	charguid=in_charguid, gemid=in_gemid, slot=in_slot, pos=in_pos;
END;;
-- ----------------------------
#***************************************************************
##版本3修改完成
#***************************************************************

#***************************************************************
##版本4修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE  PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint, IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128), IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind, wash,newgrouplvl,wash_attr,emptystarnum)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind, in_wash,in_newgrouplvl,in_wash_attr,in_emptystarnum) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr,emptystarnum = in_emptystarnum;
END;;
-- ----------------------------

-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE  PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint
	, IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128), IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, newgroup, newgroupbind,
	wash,newgrouplvl,wash_attr,emptystarnum)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_newgroup, in_newgroupbind,
	in_wash,in_newgrouplvl,in_wash_attr,in_emptystarnum)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr,emptystarnum = in_emptystarnum;
END;;

-- ----------------------------
-- Procedure structure for sp_update_guild_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_item`;
CREATE  PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int, IN `in_super1` varchar(64), 
IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64),
IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint,
IN `in_wash` varchar(64), IN `in_newgrouplvl` int, IN `in_wash_attr` varchar(128),IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_guild_storage(itemgid, gid, itemtid, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper,newgroup,newgroupbind,
	wash,newgrouplvl,wash_attr,emptystarnum)
	VALUES (in_itemgid, in_gid, in_itemtid, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper,in_newgroup,in_newgroupbind,
	in_wash,in_newgrouplvl,in_wash_attr,in_emptystarnum)
	ON DUPLICATE KEY UPDATE itemgid = in_itemgid, gid = in_gid, itemtid = in_itemtid, strenid = in_strenid,
	strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper, newgroup = in_newgroup, newgroupbind = in_newgroupbind,
	wash = in_wash,newgrouplvl = in_newgrouplvl,wash_attr = in_wash_attr,emptystarnum = in_emptystarnum;
END;;

#***************************************************************
##版本4修改完成
#***************************************************************

#***************************************************************
##版本5修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------

DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE  PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint, IN `in_newgrouplvl` int, IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind, newgrouplvl, emptystarnum)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind, in_newgrouplvl, in_emptystarnum) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	newgrouplvl = in_newgrouplvl,emptystarnum = in_emptystarnum;
END;;

-- ----------------------------
-- Procedure structure for sp_update_guild_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_item`;
CREATE  PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int, IN `in_super1` varchar(64), 
IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64),
IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint,
IN `in_newgrouplvl` int, IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_guild_storage(itemgid, gid, itemtid, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper,newgroup,newgroupbind,
	newgrouplvl,emptystarnum)
	VALUES (in_itemgid, in_gid, in_itemtid, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper,in_newgroup,in_newgroupbind,
	in_newgrouplvl,in_emptystarnum)
	ON DUPLICATE KEY UPDATE itemgid = in_itemgid, gid = in_gid, itemtid = in_itemtid, strenid = in_strenid,
	strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper, newgroup = in_newgroup, newgroupbind = in_newgroupbind,
	newgrouplvl = in_newgrouplvl,emptystarnum = in_emptystarnum;
END;;


-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE  PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint
	, IN `in_newgrouplvl` int, IN `in_emptystarnum` int)
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, newgroup, newgroupbind,
	newgrouplvl,emptystarnum)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_newgroup, in_newgroupbind,
	in_newgrouplvl,in_emptystarnum)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	newgrouplvl = in_newgrouplvl,emptystarnum = in_emptystarnum;
END;;
#***************************************************************
##版本5修改完成
#***************************************************************


#***************************************************************
##版本6修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_delete_gem
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_delete_gem`;
CREATE PROCEDURE `sp_delete_gem`(IN `in_charguid` bigint, IN `in_slot` int, IN `in_pos` int)
BEGIN
	DELETE FROM tb_player_gem WHERE charguid=in_charguid AND slot=in_slot AND pos=in_pos;
END;;
-- ----------------------------
-- ----------------------------
-- Procedure structure for sp_select_pifeng_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_pifeng_info`;
CREATE PROCEDURE `sp_select_pifeng_info`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_pifeng WHERE  charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_pifeng_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_pifeng_insert_update`;
CREATE PROCEDURE `sp_pifeng_insert_update`(IN `in_charguid` bigint, IN `in_type` int, IN `in_lv` int, IN `in_tid` int, IN `in_val` int)
BEGIN
	INSERT INTO tb_player_pifeng(charguid, type, lv, tid, val)
	VALUES(in_charguid, in_type, in_lv, in_tid, in_val)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, type = in_type, lv = in_lv, tid = in_tid, val = in_val;
END;;

#***************************************************************
##版本9修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_fabao_delete
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fabao_delete`;
CREATE PROCEDURE `sp_player_fabao_delete`(IN `in_charguid` bigint,IN `in_updatetime` bigint)
BEGIN
	delete from tb_player_fabao where charguid = in_charguid and updatetime<>in_updatetime;
END;;

-- ----------------------------
-- Procedure structure for sp_player_fabao_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fabao_select`;
CREATE PROCEDURE `sp_player_fabao_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_fabao WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_fabao_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fabao_insert_update`;
CREATE PROCEDURE `sp_player_fabao_insert_update`(IN `in_charguid` bigint, IN `in_id` bigint, IN `in_tid` int, IN `in_level` int, IN `in_exp` int, IN `in_changed` int, IN `in_state` int, IN `in_skills` varchar(256), IN `in_abilities` varchar(128),IN `in_updatetime` bigint)
BEGIN
	INSERT INTO tb_player_fabao(charguid, id, tid, level, exp, changed, state, skills, abilities, updatetime)
	VALUES(in_charguid, in_id, in_tid, in_level, in_exp, in_changed, in_state, in_skills, in_abilities, in_updatetime)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, id = in_id, tid = in_tid, level = in_level, exp = in_exp, changed = in_changed, state = in_state, skills = in_skills, abilities = in_abilities, updatetime = in_updatetime;
END;;

#***************************************************************
##版本11修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_vitality_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vitality_select`;
CREATE PROCEDURE `sp_player_vitality_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_vitality WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_vitality_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vitality_insert_update`;
CREATE PROCEDURE `sp_player_vitality_insert_update`(IN `in_charguid` bigint, IN `in_exp` int, IN `in_level` int, IN `in_task` varchar(350))
BEGIN
	INSERT INTO tb_player_vitality(charguid, exp, level, task)
	VALUES(in_charguid, in_exp, in_level, in_task)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, exp = in_exp, level = in_level, task = in_task;
END;;

-- ----------------------------
-- Procedure structure for sp_player_info_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_info_insert_update`;
CREATE PROCEDURE `sp_player_info_insert_update`(IN `in_id` bigint,  IN `in_name` varchar(32), IN `in_level` int, IN `in_exp` bigint, IN `in_vip_level` int, IN `in_vip_exp` int,
				IN `in_power` bigint, IN `in_hp` int, IN `in_mp` int, IN `in_hunli` int, IN `in_tipo` int, IN `in_shenfa` int, IN `in_jingshen` int, 
				IN `in_leftpoint` int, IN `in_totalpoint` int, IN `in_sp` int, IN `in_max_sp` int, IN `in_sp_recover` int, IN `in_bindgold` bigint, 
				IN `in_unbindgold` bigint, IN `in_bindmoney` bigint, IN `in_unbindmoney` bigint, IN `in_zhenqi` bigint, IN `in_soul` int, IN `in_pk_mode` int, IN `in_pk_status` int,
				IN `in_pk_flags` int,IN `in_pk_evil` int,IN `in_redname_time` bigint, IN `in_grayname_time` bigint, IN `in_pk_count` int, IN `in_yao_hun` int,
				IN `in_arms` int, IN `in_dress` int, IN `in_online_time` int, IN `in_head` int, IN `in_suit` int, IN `in_weapon` int, IN `in_drop_val` int, IN `in_drop_lv` int, 
				IN `in_killtask_count` int, IN `in_onlinetime_day` int, IN `in_honor` int, IN `in_hearthstone_time` bigint, IN `in_lingzhi` int, IN `in_jingjie_exp` int, IN `in_vplan` int,
				IN `in_blesstime` bigint,IN `in_equipval` bigint, IN `in_wuhunid` int, IN `in_shenbingid` int,IN `in_extremityval` bigint, IN `in_wingid` int,
				IN `in_blesstime2` bigint,IN `in_blesstime3` bigint, IN `in_suitflag` int, IN `in_crossscore` int, IN `in_crossexploit` int, IN `in_crossseasonid` int, 
				IN `in_pvplevel` int, IN `in_soul_hzlevel` int, IN `in_other_money` bigint, IN `in_wash_luck` int, IN `in_shoulder` int)
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
								pvplevel, soul_hzlevel, other_money, wash_lucky, shoulder)
	VALUES (in_id, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid,
			in_pvplevel, in_soul_hzlevel, in_other_money, in_wash_luck, in_shoulder) 
	ON DUPLICATE KEY UPDATE charguid = in_id,level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel, soul_hzlevel = in_soul_hzlevel, other_money = in_other_money, wash_lucky = in_wash_luck, shoulder = in_shoulder;
END;;

-- ----------------------------
-- Procedure structure for sp_select_player_info_by_ls
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_info_by_ls`;
CREATE PROCEDURE `sp_select_player_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT name, level, prof, iconid, power, vip_level, head, suit, weapon, wingid, suitflag, shoulder
	FROM tb_player_info 
	WHERE in_guid = charguid;
END;;


#***************************************************************
##版本13修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_zhuanzhi_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhuanzhi_select`;
CREATE PROCEDURE `sp_player_zhuanzhi_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_zhuanzhi WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_zhuanzhi_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhuanzhi_insert_update`;
CREATE PROCEDURE `sp_player_zhuanzhi_insert_update`(IN `in_id` bigint,   IN `in_level` int, IN `in_task` varchar(128))
BEGIN
	INSERT INTO tb_player_zhuanzhi(charguid, lv, task)
	VALUES (in_id,in_level,in_task) 
	ON DUPLICATE KEY UPDATE charguid = in_id, lv = in_level, task = in_task;
END;;



-- ----------------------------
-- Procedure structure for sp_player_juexue_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_juexue_select`;
CREATE PROCEDURE `sp_player_juexue_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_juexue WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_juexue_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_juexue_insert_update`;
CREATE PROCEDURE `sp_player_juexue_insert_update`(IN `in_charguid` bigint, IN `in_juexueids` varchar(256), IN `in_juexuelvs` varchar(256), IN `in_xinfaids` varchar(256), IN `in_xinfalvs` varchar(256))
BEGIN
	INSERT INTO tb_player_juexue(charguid, juexueids, juexuelvs, xinfaids, xinfalvs)
	VALUES(in_charguid, in_juexueids, in_juexuelvs, in_xinfaids, in_xinfalvs)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, juexueids = in_juexueids, juexuelvs = in_juexuelvs, xinfaids = in_xinfaids, xinfalvs = in_xinfalvs;
END;;

-- ----------------------------
-- Procedure structure for sp_player_fumo_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fumo_select`;
CREATE PROCEDURE `sp_player_fumo_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_fumo WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_fumo_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fumo_insert_update`;
CREATE PROCEDURE `sp_player_fumo_insert_update`(IN `in_charguid` bigint, IN `in_fumoids` varchar(512), IN `in_fumolvs` varchar(512), IN `in_fumonum` varchar(512))
BEGIN
	INSERT INTO tb_player_fumo(charguid, fumoids, fumolvs, fumonum)
	VALUES(in_charguid, in_fumoids, in_fumolvs, in_fumonum)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, fumoids = in_fumoids, fumolvs = in_fumolvs, fumonum = in_fumonum;
END;;

#***************************************************************
##版本14修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint)
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time;
END;;

#***************************************************************
##版本15修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_wuhuns_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_wuhuns_insert_update`;;
DROP PROCEDURE IF EXISTS `sp_player_wuhuns_delete_by_id`;;

DROP PROCEDURE IF EXISTS `sp_select_player_ls_horse`;;
DROP PROCEDURE IF EXISTS `sp_insert_update_player_ls_horse`;;

DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_item`;;
DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_pro`;;
DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_insert_update`;;
DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_delete_by_id_and_timestamp`;;
DROP PROCEDURE IF EXISTS `sp_player_wuxing_pro_insert_update`;;

#***************************************************************
##版本17修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_shenbing_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update`;;

DROP PROCEDURE IF EXISTS `sp_player_realm_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;;

#***************************************************************
##版本18修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_yuanling_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_yuanling_insert_update`;;

DROP PROCEDURE IF EXISTS `sp_player_shengling_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_shengling_insert_update`;;
DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_insert_update`;;

DROP PROCEDURE IF EXISTS `sp_player_zhannu_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_zhannu_insert_update`;;

DROP PROCEDURE IF EXISTS `sp_player_lunpan_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_lunpan_insert_update`;;

DROP PROCEDURE IF EXISTS `sp_player_select_zhenbaoge`;;
DROP PROCEDURE IF EXISTS `sp_player_update_zhenbaoge`;;

DROP PROCEDURE IF EXISTS `sp_select_soulinfo_by_id`;;
DROP PROCEDURE IF EXISTS `sp_select_player_update_soul`;;


DROP PROCEDURE IF EXISTS `sp_select_player_info_by_ls`;;
CREATE PROCEDURE `sp_select_player_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT name, level, prof, iconid, power, vip_level, head, suit, weapon, wingid, suitflag, shoulder, dress, arms
	FROM tb_player_info 
	WHERE in_guid = charguid;
END;;

#***************************************************************
##版本19修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_fieldboss_insert_update`;;
CREATE PROCEDURE `sp_fieldboss_insert_update`(IN `in_id` int,  IN `in_isdead` int, IN `in_lastkiller` bigint,IN `in_killername` varchar(64), IN `in_killtime` bigint)
BEGIN
	INSERT INTO tb_fieldboss(id, isdead, lastkiller, killername, killtime)
	VALUES (in_id, in_isdead, in_lastkiller, in_killername, in_killtime) 
	ON DUPLICATE KEY UPDATE id=in_id, isdead=in_isdead, lastkiller=in_lastkiller, killername=in_killername, killtime = in_killtime;
END;;

DROP PROCEDURE IF EXISTS `sp_fieldboss_select`;;
CREATE PROCEDURE `sp_fieldboss_select`()
BEGIN 
		select * from tb_fieldboss;
END;;

#***************************************************************
##版本20修改完成
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_digongboss_insert_update`;;
CREATE PROCEDURE `sp_digongboss_insert_update`(IN `in_id` int,  IN `in_isdead` int, IN `in_killtime` bigint)
BEGIN
	INSERT INTO tb_digongboss(id, isdead, killtime)
	VALUES (in_id, in_isdead, in_killtime) 
	ON DUPLICATE KEY UPDATE id=in_id, isdead=in_isdead, killtime = in_killtime;
END;;

DROP PROCEDURE IF EXISTS `sp_digongboss_select`;;
CREATE PROCEDURE `sp_digongboss_select`()
BEGIN 
		select * from tb_digongboss;
END;;
#***************************************************************
##版本21修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_pifeng_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_pifeng_insert_update`;
CREATE PROCEDURE `sp_pifeng_insert_update`(IN `in_charguid` bigint, IN `in_type` int, IN `in_lv` int, IN `in_tid` int, IN `in_val` int, IN `in_star` int)
BEGIN
	INSERT INTO tb_player_pifeng(charguid, type, lv, tid, val, star)
	VALUES(in_charguid, in_type, in_lv, in_tid, in_val, in_star)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, type = in_type, lv = in_lv, tid = in_tid, val = in_val, star = in_star;
END;;
#***************************************************************
##版本22修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_star_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_star_select`;
CREATE PROCEDURE `sp_player_star_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_star WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_star_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_star_insert_update`;
CREATE PROCEDURE `sp_player_star_insert_update`(IN `in_charguid` bigint, IN `in_starpos` varchar(128), IN `in_starlv` varchar(128))
BEGIN
	INSERT INTO tb_player_star(charguid, starpos, starlv)
	VALUES(in_charguid, in_starpos, in_starlv)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, starpos = in_starpos, starlv = in_starlv;
END;;

#***************************************************************
##版本23修改完成
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_insert_or_update_pvphistory`;
CREATE PROCEDURE `sp_insert_or_update_pvphistory`(IN `in_seasonid` int, IN `in_rank` int, IN `in_charguid` bigint, IN `in_groupid` int,
IN `in_power` bigint, IN `in_prof` int, IN `in_arms` int, IN `in_dress` int, IN `in_fashionhead` int, IN `in_fashionarms` int,
IN `in_fashiondress` int, IN `in_wuhunid` int, IN `in_wingid` int, IN `in_suitflag` int, IN `in_name` varchar(32), IN `in_shoulder` int)
BEGIN
	INSERT INTO tb_pvp_season_history(seasonid, rank, charguid, groupid, power, prof,
								arms, dress, fashionhead, fashionarms, fashiondress, wuhunid, wingid, 
								suitflag, name, shoulder)
	VALUES (in_seasonid, in_rank, in_charguid, in_groupid, in_power, in_prof,
			in_arms, in_dress, in_fashionhead, in_fashionarms, in_fashiondress, in_wuhunid, in_wingid, 
			in_suitflag, in_name, in_shoulder) 
	ON DUPLICATE KEY UPDATE seasonid=in_seasonid, rank=in_rank, charguid = in_charguid, groupid = in_groupid, power = in_power,
		prof=in_prof, arms=in_arms, dress=in_dress, fashionhead=in_fashionhead, fashionarms=in_fashionarms, fashiondress=in_fashiondress, wuhunid=in_wuhunid, 
		wingid=in_wingid, suitflag=in_suitflag, name = in_name, shoulder = in_shoulder;
END;;


DROP PROCEDURE IF EXISTS `sp_update_party_rank`;
CREATE PROCEDURE `sp_update_party_rank`(IN `in_id` int, IN `in_name` varchar(32), IN `in_prof` int, IN `in_arms` int,
IN `in_dress` int, IN `in_fashionhead` int, IN `in_fashionarms` int, IN `in_fashiondress` int, IN `in_wuhunid` int, 
IN `in_wingid` int, IN `in_suitflag` int, IN `in_rank1` varchar(64), IN `in_rank2` varchar(64), IN `in_rank3` varchar(64), 
IN `in_rank4` varchar(64), IN `in_rank5` varchar(64), IN `in_rank6` varchar(64), IN `in_rank7` varchar(64), 
IN `in_rank8` varchar(64), IN `in_rank9` varchar(64), IN `in_rank10` varchar(64), IN `in_param1` int,
IN `in_param2` int, IN `in_shoulder` int)
BEGIN
	INSERT INTO tb_party_rank(id, name, prof, arms, dress, fashionhead, fashionarms, fashiondress, wuhunid, 
	wingid, suitflag, rank1, rank2, rank3, rank4, rank5, rank6, rank7, rank8, rank9, rank10, param1, param2, shoulder)
	VALUES (in_id, in_name, in_prof, in_arms, in_dress, in_fashionhead, in_fashionarms, in_fashiondress, in_wuhunid,
	in_wingid, in_suitflag, in_rank1, in_rank2, in_rank3, in_rank4, in_rank5, in_rank6, in_rank7, in_rank8,
	in_rank9, in_rank10, in_param1, in_param2, in_shoulder)
	ON DUPLICATE KEY UPDATE id = in_id, name = in_name, prof = in_prof, arms = in_arms, dress = in_dress,
	fashionhead = in_fashionhead, fashionarms = in_fashionarms, fashiondress = in_fashiondress, wuhunid = in_wuhunid,
	wingid = in_wingid, suitflag = in_suitflag, rank1 = in_rank1, rank2 = in_rank2, rank3 = in_rank3, rank4 = in_rank4,
	rank5 = in_rank5, rank6 = in_rank6, rank7 = in_rank7, rank8 = in_rank8, rank9 = in_rank9, rank10 = in_rank10,
	param1 = in_param1, param2 = in_param2, shoulder =in_shoulder;
END;;

DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_base`;
CREATE PROCEDURE `sp_select_rank_human_info_base`(IN `in_id` bigint)
BEGIN
	SELECT charguid, name, prof, level, hp, mp, power, vip_level, sex, dress, 
	arms, head, suit, weapon, hunli, tipo, shenfa, jingshen, vplan, wingid, shenbingid, suitflag,crossscore, shoulder
	FROM tb_player_info WHERE charguid = in_id;
END;;

DROP PROCEDURE IF EXISTS `sp_rank_pvplevel`;
CREATE PROCEDURE `sp_rank_pvplevel`(IN `in_curseasonid` int, IN `in_pvplevel` int, IN `in_limit` int)
BEGIN
	SELECT charguid, pvplevel, crossscore, power, name, prof, level, arms, dress, head, suit, weapon, wuhunid, wingid, suitflag, shoulder FROM tb_player_info 
	WHERE crossscore > 0 and crossseasonid = in_curseasonid and pvplevel = in_pvplevel
	ORDER BY crossscore DESC, power DESC LIMIT in_limit;
END;;


DROP PROCEDURE IF EXISTS `sp_select_simple_user_info`;
CREATE PROCEDURE `sp_select_simple_user_info`(IN `in_guid` bigint)
BEGIN
	SELECT tb_player_info.charguid as charguid, name, prof, iconid, 
	level, power, arms, dress, head, suit, weapon, valid, 
	forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, 
	UNIX_TIMESTAMP(tb_account.last_logout) as last_logout, account, vip_level, vplan, wuhunid, shenbingid, wingid, suitflag, shoulder from tb_player_info 
	left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	where tb_player_info.charguid = in_guid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_zhuanzhi_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhuanzhi_insert_update`;
CREATE PROCEDURE `sp_player_zhuanzhi_insert_update`(IN `in_id` bigint,   IN `in_level` int, IN `in_step` int, IN `in_number` int, IN `in_task` varchar(128), IN `in_task1` varchar(128), IN `in_task2` varchar(128), IN `in_task3` varchar(128), IN `in_task4` varchar(128))
BEGIN
	INSERT INTO tb_player_zhuanzhi(charguid, lv, step, number, task, task1, task2, task3, task4)
	VALUES (in_id,in_level, in_step, in_number, in_task, in_task1, in_task2, in_task3, in_task4) 
	ON DUPLICATE KEY UPDATE charguid = in_id, lv = in_level, step = in_step, number = in_number, task = in_task, task1 = in_task1, task2 = in_task2, task3 = in_task3, task4 = in_task4;
END;;


#***************************************************************
##版本24修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_vitality_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vitality_insert_update`;
CREATE PROCEDURE `sp_player_vitality_insert_update`(IN `in_charguid` bigint, IN `in_exp` int, IN `in_level` int, IN `in_task` varchar(350), IN `in_model` int)
BEGIN
	INSERT INTO tb_player_vitality(charguid, exp, level, task, model)
	VALUES(in_charguid, in_exp, in_level, in_task, in_model)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, exp = in_exp, level = in_level, task = in_task, model = in_model;
END;;
#***************************************************************
##版本26修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_superlib
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_superlib_delete`;;
DROP PROCEDURE IF EXISTS `sp_player_superlib_insert_update`;;
DROP PROCEDURE IF EXISTS `sp_player_superlib_select_by_id`;;
DROP PROCEDURE IF EXISTS `sp_player_superhole_insert_update`;;
DROP PROCEDURE IF EXISTS `sp_player_superhole_select_by_id`;;
#***************************************************************
##版本28修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint, IN `in_gold_boss_reward` bigint, IN `in_mess_fight_name` varchar(32))
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time, gold_boss_reward, mess_fight_name)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time, in_gold_boss_reward, in_mess_fight_name)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time, gold_boss_reward = in_gold_boss_reward, mess_fight_name = in_mess_fight_name;
END;;
#***************************************************************
##版本29修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint, IN `in_gold_boss_reward` bigint, IN `in_kill_count` int, IN `in_be_kill_count` int, IN `in_continue_kill_count` int)
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time, gold_boss_reward, kill_count, be_kill_count, continue_kill_count)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time, in_gold_boss_reward, in_kill_count, in_be_kill_count, in_continue_kill_count)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time, gold_boss_reward = in_gold_boss_reward, kill_count = in_kill_count, be_kill_count = in_be_kill_count, continue_kill_count = in_continue_kill_count;
END;;
#***************************************************************
##版本30修改完成
#***************************************************************

#***************************************************************
##版本31修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_first_day_goal_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_first_day_goal_select`;
CREATE PROCEDURE `sp_first_day_goal_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_first_day_goal WHERE charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_first_day_goal_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_first_day_goal_update`;
CREATE PROCEDURE `sp_first_day_goal_update`(IN `in_charguid` bigint, IN `in_goalid` int, IN `in_goalstate` int)
BEGIN
	INSERT INTO tb_first_day_goal(charguid, goalid, goalstate)
	VALUES (in_charguid, in_goalid, in_goalstate)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, goalid = in_goalid, goalstate = in_goalstate;
END;;
-- ----------------------------
#***************************************************************
##版本31修改完成
#***************************************************************

#***************************************************************
##版本32修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_crosstask_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_crosstask_insert_update`;
CREATE PROCEDURE `sp_player_crosstask_insert_update`(IN `in_charguid` bigint,IN `in_quest_id` int, IN `in_questgid` bigint,
IN `in_quest_state` int, IN `in_goal1` bigint, IN `in_goal_count1` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_crosstask(charguid,quest_id,questgid,quest_state,goal1,goal_count1,time_stamp)
	VALUES (in_charguid,in_quest_id,in_questgid,in_quest_state,in_goal1,in_goal_count1,in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, quest_id = in_quest_id, questgid = in_questgid, 
	quest_state = in_quest_state, goal1 = in_goal1, goal_count1 = in_goal_count1, time_stamp = in_time_stamp;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_crosstask_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_crosstask_select_by_id`;
CREATE PROCEDURE `sp_player_crosstask_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_crosstask WHERE charguid=in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_crosstask_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_crosstask_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_crosstask_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_crosstask WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;
-- ----------------------------
-- Procedure structure for sp_player_crosstask_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_crosstask_extra_insert_update`;
CREATE PROCEDURE `sp_player_crosstask_extra_insert_update`(IN `in_charguid` bigint,IN `in_score` int, IN `in_onlinetime` int,
IN `in_refreshtimes` int, IN `in_lastrefreshtime` bigint, IN `in_questlist` varchar(128))
BEGIN
	INSERT INTO tb_player_crosstask_extra(charguid,score,onlinetime,refreshtimes,lastrefreshtime,questlist)
	VALUES (in_charguid,in_score,in_onlinetime,in_refreshtimes,in_lastrefreshtime,in_questlist)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, score = in_score, onlinetime = in_onlinetime, 
	refreshtimes = in_refreshtimes, lastrefreshtime = in_lastrefreshtime, questlist = in_questlist;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_crosstask_extra_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_crosstask_extra_select_by_id`;
CREATE PROCEDURE `sp_player_crosstask_extra_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_crosstask_extra WHERE charguid=in_charguid;
END ;;
#***************************************************************
##版本32修改完成
#***************************************************************


-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------

DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE  PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint, IN `in_newgrouplvl` int, IN `in_emptystarnum` int, IN `in_ring_lv` int,
 IN `in_monster_count` int)
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind, newgrouplvl, emptystarnum, ring_lv, monster_count)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind, in_newgrouplvl, in_emptystarnum, in_ring_lv, in_monster_count) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	newgrouplvl = in_newgrouplvl,emptystarnum = in_emptystarnum, ring_lv = in_ring_lv, monster_count = in_monster_count;
END;;
#***************************************************************
##版本33修改完成
#***************************************************************

#***************************************************************
##版本34修改
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE  PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(512), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTime` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int, IN `in_personboss_count` int, IN `in_platform_info` varchar(350), 
		IN `in_lastMonthCheckTime` int, IN `in_month_count` varchar(350), IN `in_marrystren` int, IN `in_marrystrenwish` int, IN `in_zhanyin_num` int, IN `in_dongtian_lv` int)
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
		marrystren, marrystrenwish, zhanyin_num, dongtian_lv)
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
		in_marrystren, in_marrystrenwish, in_zhanyin_num, in_dongtian_lv) 
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
		marrystren = in_marrystren, marrystrenwish = in_marrystrenwish, zhanyin_num = in_zhanyin_num, dongtian_lv=in_dongtian_lv;
END;;
#***************************************************************
##版本34修改完成
#***************************************************************

#***************************************************************
##版本35修改
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_fengyao_insert_update`;
CREATE  PROCEDURE `sp_player_fengyao_insert_update`(IN `in_charguid` bigint, IN `in_fengyao_id` int, IN `in_fengyao_grp` int, IN `in_fengyao_state` int, IN `in_fengyao_counter` int, IN `in_fengyao_score` int, IN `in_fengyao_box` varchar(64), IN `in_fengyao_refresh` int, IN `in_fengyao_first` int, IN `in_fengyao_luck` int, IN `in_monster_count` int, IN `in_fresh_time` int)
BEGIN
  INSERT INTO tb_player_fengyao(charguid, fengyao_id, fengyao_grp,fengyao_state,fengyao_counter,fengyao_score,fengyao_box,fengyao_refresh,fengyao_first,fengyao_luck,monster_count, fresh_time)
  VALUES (in_charguid, in_fengyao_id, in_fengyao_grp,in_fengyao_state,in_fengyao_counter,in_fengyao_score,in_fengyao_box,in_fengyao_refresh,in_fengyao_first,in_fengyao_luck, in_monster_count, in_fresh_time) 
  ON DUPLICATE KEY UPDATE fengyao_id=in_fengyao_id, fengyao_grp=in_fengyao_grp,fengyao_state=in_fengyao_state,fengyao_counter=in_fengyao_counter,fengyao_score=in_fengyao_score,fengyao_box=in_fengyao_box,fengyao_refresh=in_fengyao_refresh,fengyao_first=in_fengyao_first,fengyao_luck=in_fengyao_luck, monster_count=in_monster_count, fresh_time = in_fresh_time;
END;;
#***************************************************************
##版本35修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint, IN `in_gold_boss_reward` bigint, IN `in_kill_count` int, IN `in_be_kill_count` int, IN `in_continue_kill_count` int, IN `in_meal_type` int)
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time, gold_boss_reward, kill_count, be_kill_count, continue_kill_count, meal_type)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time, in_gold_boss_reward, in_kill_count, in_be_kill_count, in_continue_kill_count, in_meal_type)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time, gold_boss_reward = in_gold_boss_reward, kill_count = in_kill_count, be_kill_count = in_be_kill_count, continue_kill_count = in_continue_kill_count, meal_type = in_meal_type;
END;;
#***************************************************************
##版本36修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint, IN `in_gold_boss_reward` bigint, IN `in_kill_count` int, IN `in_be_kill_count` int, IN `in_continue_kill_count` int, IN `in_meal_type` int, IN `in_banquet_reward` bigint)
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time, gold_boss_reward, kill_count, be_kill_count, continue_kill_count, meal_type, banquet_reward)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time, in_gold_boss_reward, in_kill_count, in_be_kill_count, in_continue_kill_count, in_meal_type, in_banquet_reward)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time, gold_boss_reward = in_gold_boss_reward, kill_count = in_kill_count, be_kill_count = in_be_kill_count, continue_kill_count = in_continue_kill_count, meal_type = in_meal_type, banquet_reward = in_banquet_reward;
END;;
#***************************************************************
##版本37修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64), IN `in_extraplus_time` bigint, IN `in_gold_boss_reward` bigint, IN `in_kill_count` int, IN `in_be_kill_count` int, IN `in_continue_kill_count` int, IN `in_meal_type` int, IN `in_banquet_reward` bigint, IN `in_banquet_cultivation` bigint)
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param, extraplus_time, gold_boss_reward, kill_count, be_kill_count, continue_kill_count, meal_type, banquet_reward, banquet_cultivation)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param, in_extraplus_time, in_gold_boss_reward, in_kill_count, in_be_kill_count, in_continue_kill_count, in_meal_type, in_banquet_reward, in_banquet_cultivation)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param, extraplus_time = in_extraplus_time, gold_boss_reward = in_gold_boss_reward, kill_count = in_kill_count, be_kill_count = in_be_kill_count, continue_kill_count = in_continue_kill_count, meal_type = in_meal_type, banquet_reward = in_banquet_reward, banquet_cultivation = in_banquet_cultivation;
END;;
#***************************************************************
##版本38修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_bianshen_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_bianshen_select`;
CREATE PROCEDURE `sp_player_bianshen_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_bianshen WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_bianshen_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_bianshen_insert_update`;
CREATE PROCEDURE `sp_player_bianshen_insert_update`(IN `in_charguid` bigint, IN `in_id` bigint, IN `in_tid` int, IN `in_star` int, IN `in_step` int, IN `in_wish` int, IN `in_model` int, IN `in_energy` int, IN `in_state` int)
BEGIN
	INSERT INTO tb_player_bianshen(charguid, id, tid, star, step, wish, model, energy, state)
	VALUES(in_charguid, in_id, in_tid, in_star, in_step, in_wish, in_model, in_energy, in_state)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, id = in_id, tid = in_tid, star = in_star, step = in_step, wish = in_wish, model = in_model, energy = in_energy, state = in_state;
END;;

#***************************************************************
##版本40修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_update_boss_media
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_boss_media`;
CREATE PROCEDURE `sp_update_boss_media`(IN `in_charguid` bigint, IN `in_level` int, IN `in_star` int, IN `in_process` int,
				IN `in_point` int, IN `in_type_1` int, IN `in_type_2` int, IN `in_type_3` int, IN `in_type_4` int, IN `in_dropseq` int)
BEGIN
	INSERT INTO tb_player_boss_media(charguid, level, star, process, point, type_1, type_2, type_3, type_4, dropseq)
	VALUES(in_charguid, in_level, in_star, in_process, in_point, in_type_1, in_type_2, in_type_3, in_type_4, in_dropseq)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_level, star = in_star, process = in_process, 
		point = in_point, type_1 = in_type_1, type_2 = in_type_2, type_3 = in_type_3, type_4 = in_type_4, dropseq = in_dropseq;
END;;

#***************************************************************
##版本41修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_equipcollect_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_equipcollect_select_by_id`;
CREATE PROCEDURE `sp_equipcollect_select_by_id`(IN `in_charguid`  bigint)
BEGIN
    SELECT * FROM tb_player_equipcollect WHERE charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_equipcollect_insert_update
-- -----------------------------
DROP PROCEDURE IF EXISTS `sp_equipcollect_insert_update`;
CREATE PROCEDURE `sp_equipcollect_insert_update`(IN `in_charguid`  bigint, IN `in_get_state` int, IN `in_lv` int, IN `in_first_activite`int,
IN `in_second_activite` int, IN `in_third_activite` int, IN `in_index_state` varchar(128))
BEGIN
    INSERT INTO tb_player_equipcollect(charguid, get_state, lv, first_activite, second_activite, third_activite,index_state)
    VALUES(in_charguid, in_get_state,in_lv,in_first_activite,in_second_activite,in_third_activite,in_index_state)
    ON DUPLICATE KEY UPDATE charguid=in_charguid,get_state=in_get_state,lv=in_lv,first_activite=in_first_activite,
    second_activite=in_second_activite,third_activite=in_third_activite,index_state=in_index_state;
END;;

#***************************************************************
##版本42修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_select_package
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_package`;
CREATE PROCEDURE `sp_select_package`(IN `in_charguid`  bigint)
BEGIN
    SELECT * FROM tb_player_package WHERE charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_package_insert_update
-- -----------------------------
DROP PROCEDURE IF EXISTS `sp_player_package_insert_update`;
CREATE PROCEDURE `sp_player_package_insert_update`(IN `in_charguid`  bigint, IN `in_pack_id` int, IN `in_pack_num` int)
BEGIN
    INSERT INTO tb_player_package(charguid, pack_id, pack_num)
    VALUES(in_charguid, in_pack_id,in_pack_num)
    ON DUPLICATE KEY UPDATE charguid=in_charguid,pack_id=in_pack_id,pack_num=in_pack_num;
END;;

#***************************************************************
##版本43修改完成
#***************************************************************


-- ----------------------------
-- Procedure structure for sp_pifeng_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_pifeng_insert_update`;
CREATE PROCEDURE `sp_pifeng_insert_update`(IN `in_charguid` bigint, IN `in_type` int, IN `in_lv` int, IN `in_tid` int, IN `in_val` int, IN `in_star` int, IN `in_outlook` int, IN `in_set_on` int)
BEGIN
	INSERT INTO tb_player_pifeng(charguid, type, lv, tid, val, star, outlook, set_on)
	VALUES(in_charguid, in_type, in_lv, in_tid, in_val, in_star, in_outlook, in_set_on)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, type = in_type, lv = in_lv, tid = in_tid, val = in_val, star = in_star, outlook = in_outlook, set_on = in_set_on;
END;;
#***************************************************************
##版本44修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_select_timers
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_select_timers`;
CREATE PROCEDURE `sp_player_select_timers`(IN `in_charguid`  bigint)
BEGIN
    SELECT * FROM tb_player_timers WHERE charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_timers_insert_update
-- -----------------------------
DROP PROCEDURE IF EXISTS `sp_player_timers_insert_update`;
CREATE PROCEDURE `sp_player_timers_insert_update`(IN `in_charguid` bigint, IN `in_type` int, IN `in_timer_type` int, IN `in_expire_time` int, IN `in_custom_data` int)
BEGIN
    INSERT INTO tb_player_timers(charguid, type, timer_type, expire_time, custom_data)
    VALUES(in_charguid, in_type,in_timer_type,in_expire_time,in_custom_data)
    ON DUPLICATE KEY UPDATE charguid=in_charguid,type=in_type,timer_type=in_timer_type,expire_time=in_expire_time,custom_data=in_custom_data;
END;;

#***************************************************************
##版本45修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_finish_quest_delete
-- -----------------------------
DROP PROCEDURE IF EXISTS `sp_player_finish_quest_delete`;
CREATE PROCEDURE `sp_player_finish_quest_delete`(IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_finishquest WHERE charguid = in_charguid AND cnt = 0;
END;;

#***************************************************************
##版本45修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_equipcollect_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_refine_danyao_select_by_id`;
CREATE PROCEDURE `sp_player_refine_danyao_select_by_id`(IN `in_charguid` bigint)
BEGIN
    SELECT * FROM tb_player_refine_danyao WHERE charguid=in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_refine_danyao_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_refine_danyao_insert_update`;
CREATE PROCEDURE `sp_player_refine_danyao_insert_update`(IN `in_charguid` bigint, IN `in_xiuwei` int, IN `in_accumulate` int, IN `in_refine_times` int)
BEGIN
	INSERT INTO tb_player_refine_danyao(charguid, xiuwei, accumulate, refine_times)
	VALUES(in_charguid, in_xiuwei, in_accumulate, in_refine_times)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, xiuwei = in_xiuwei, accumulate = in_accumulate, refine_times = in_refine_times;
END;;
#***************************************************************
##版本46修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_waterdup
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_waterdup`;
CREATE PROCEDURE `sp_update_waterdup`(IN `in_charguid` bigint, IN `in_history_wave` int,
 IN `in_history_exp` bigint, IN `in_today_count` int, IN `in_reward_rate` double, IN `in_reward_exp` double,
 IN `in_history_kill` int, IN `in_buy_count` int, IN `in_fresh_time` bigint)
BEGIN
	INSERT INTO tb_waterdup(charguid, history_wave, history_exp, today_count, reward_rate, reward_exp, history_kill, buy_count, fresh_time)
	VALUES (in_charguid, in_history_wave, in_history_exp, in_today_count, in_reward_rate, in_reward_exp, in_history_kill, in_buy_count, in_fresh_time) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, history_wave = in_history_wave, 
	history_exp = in_history_exp, today_count = in_today_count, reward_rate = in_reward_rate, reward_exp = in_reward_exp,
	history_kill = in_history_kill, buy_count = in_buy_count, fresh_time = in_fresh_time;
END;;
#***************************************************************
##版本47修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_taofa
-- ----------------------------
DROP  PROCEDURE IF EXISTS `sp_player_taofa`;
CREATE PROCEDURE `sp_player_taofa`(IN `char_guid` bigint)
BEGIN 
	select * from tb_player_taofa where charguid = char_guid;
END;;
-- ----------------------------
-- Procedure structure for sp_player_taofa_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_taofa_insert_update`;
CREATE PROCEDURE `sp_player_taofa_insert_update`(IN `in_charguid` bigint, IN `in_finsh_count` int, IN `in_taskid` int)
BEGIN 
	INSERT INTO tb_player_taofa(charguid, finsh_count, taskid)
	VALUES(in_charguid, in_finsh_count, in_taskid)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, finsh_count = in_finsh_count,taskid = in_taskid;
END;;
#***************************************************************
##版本48修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;
CREATE PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int, IN `in_fh_itemnum` bigint, IN `in_fh_level_itemnum` bigint)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum, fh_itemnum,fh_level_itemnum)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum, in_fh_itemnum,in_fh_level_itemnum)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum, fh_itemnum=in_fh_itemnum, fh_level_itemnum=in_fh_level_itemnum;
END;;

DROP PROCEDURE IF EXISTS `sp_player_realm_select_by_id`;
CREATE PROCEDURE `sp_player_realm_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_realm WHERE charguid=in_charguid;
END;;

#***************************************************************
##版本49修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_shenbing_select_by_id`;
CREATE PROCEDURE `sp_player_shenbing_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_shenbing WHERE charguid=in_charguid;
END;;
DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update`;
CREATE  PROCEDURE `sp_player_shenbing_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_shenbing(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END;;
#***************************************************************
##版本50修改完成
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_lingqi_select_by_id`;
CREATE PROCEDURE `sp_player_lingqi_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_lingqi WHERE charguid=in_charguid;
END;;
DROP PROCEDURE IF EXISTS `sp_player_lingqi_insert_update`;
CREATE  PROCEDURE `sp_player_lingqi_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_lingqi(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END;;
#***************************************************************
##版本51修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_select_player_zhuxianzhen_by_id`;
CREATE PROCEDURE `sp_select_player_zhuxianzhen_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_zhuxianzhen where charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_select_zhuxianzhen_rank`;
CREATE PROCEDURE `sp_select_zhuxianzhen_rank`()
BEGIN
	SELECT * FROM tb_rank_zhuxianzhen;
END;;

DROP PROCEDURE IF EXISTS `sp_update_player_zhuxianzhen`;
CREATE PROCEDURE `sp_update_player_zhuxianzhen`(IN `in_charguid` bigint, IN `in_level` int, IN `in_time` int, IN `in_count` int )
BEGIN
	INSERT INTO tb_player_zhuxianzhen(charguid, level, time, count)
	VALUES (in_charguid, in_level, in_time, in_count) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, level = in_level, time = in_time, count = in_count;
END;;

DROP PROCEDURE IF EXISTS `sp_update_zhuxianzhen_rank`;
CREATE PROCEDURE `sp_update_zhuxianzhen_rank`(IN `in_rank` int, IN `in_guid` bigint, IN `in_val` int, IN `in_name` varchar(32), IN `in_level` int)
BEGIN
	INSERT INTO tb_rank_zhuxianzhen(rank, guid, value, name, level)
	VALUES (in_rank, in_guid, in_val, in_name, in_level) 
	ON DUPLICATE KEY UPDATE guid = in_guid, value = in_val, name = in_name, level = in_level;
END;;
#***************************************************************
##版本52修改完成
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_mingyu_select_by_id`;
CREATE PROCEDURE `sp_player_mingyu_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_mingyu WHERE charguid=in_charguid;
END;;
DROP PROCEDURE IF EXISTS `sp_player_mingyu_insert_update`;
CREATE  PROCEDURE `sp_player_mingyu_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_mingyu(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END;;
#***************************************************************
##版本53修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_fumo_select
-- ----------------------------
-- ----------------------------
-- Procedure structure for sp_player_fumo_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_fumo_insert_update`;
CREATE PROCEDURE `sp_player_fumo_insert_update`(IN `in_charguid` bigint, IN `in_fumoids` varchar(2048), IN `in_fumolvs` varchar(1024), IN `in_fumonum` varchar(1024))
BEGIN
	INSERT INTO tb_player_fumo(charguid, fumoids, fumolvs, fumonum)
	VALUES(in_charguid, in_fumoids, in_fumolvs, in_fumonum)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, fumoids = in_fumoids, fumolvs = in_fumolvs, fumonum = in_fumonum;
END;;

#***************************************************************
##版本54修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_bianshen_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_bianshen_insert_update`;
CREATE PROCEDURE `sp_player_bianshen_insert_update`(IN `in_charguid` bigint, IN `in_id` bigint, IN `in_tid` int, IN `in_star` int, IN `in_step` int, IN `in_model` int, IN `in_state` int, IN `in_curattrs` varchar(128), IN `in_allattrs` varchar(128))
BEGIN
	INSERT INTO tb_player_bianshen(charguid, id, tid, star, step, model, state, curattrs, allattrs)
	VALUES(in_charguid, in_id, in_tid, in_star, in_step, in_model, in_state, in_curattrs, in_allattrs)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, id = in_id, tid = in_tid, star = in_star, step = in_step, model = in_model, state = in_state, curattrs = in_curattrs, allattrs = in_allattrs;
END;;
#***************************************************************
##版本55修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_update_player_zhuxianzhen`;
CREATE PROCEDURE `sp_update_player_zhuxianzhen`(IN `in_charguid` bigint, IN `in_level` int, IN `in_time` int, IN `in_count` int, IN `in_history_kill` int)
BEGIN
	INSERT INTO tb_player_zhuxianzhen(charguid, level, time, count, history_kill)
	VALUES (in_charguid, in_level, in_time, in_count, in_history_kill) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, level = in_level, time = in_time, count = in_count, history_kill = in_history_kill;
END;;

DROP PROCEDURE IF EXISTS `sp_select_player_muyewar`;
CREATE PROCEDURE `sp_select_player_muyewar`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_muyewar WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_update_player_muyewar`;
CREATE PROCEDURE `sp_update_player_muyewar`(IN `in_charguid` bigint, IN `in_count` int, IN `in_today` int, IN `in_history` int, IN `in_getreward` varchar(256))
BEGIN
	INSERT INTO tb_player_muyewar(charguid, count, today, history, getreward)
	VALUES (in_charguid, in_count, in_today, in_history, in_getreward) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, count = in_count, today = in_today, history = in_history, getreward = in_getreward;
END;;

#***************************************************************
##版本56修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_questagora_insert_update`;
CREATE PROCEDURE `sp_player_questagora_insert_update`(IN `in_charguid` bigint, IN `in_tid` int, IN `in_count` int, IN `in_state` int, IN `in_reward` int, IN `in_choice` int)
BEGIN
	INSERT INTO tb_player_questagora(charguid, tid, count, state, reward, choice)
	VALUES (in_charguid, in_tid, in_count, in_state, in_reward, in_choice) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, tid = in_tid, count = in_count, state = in_state, reward = in_reward, choice = in_choice;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_select_by_id`;
CREATE PROCEDURE `sp_player_questagora_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_questagora WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_count_insert_update`;
CREATE PROCEDURE `sp_player_questagora_count_insert_update`(IN `in_charguid` bigint, IN `in_tid` int, IN `in_count` int, IN `in_timestamp` bigint)
BEGIN
	INSERT INTO tb_player_questagora_count(charguid, tid, count, timestamp)
	VALUES (in_charguid, in_tid, in_count, in_timestamp) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, tid = in_tid, count = in_count, timestamp = in_timestamp;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_count_select_by_id`;
CREATE PROCEDURE `sp_player_questagora_count_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_questagora_count WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_count_delete_by_id`;
CREATE PROCEDURE `sp_player_questagora_count_delete_by_id`(IN `in_charguid` bigint, IN `in_timestamp` bigint)
BEGIN
	DELETE FROM tb_player_questagora_count WHERE charguid = in_charguid AND timestamp <> in_timestamp;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_info_insert_update`;
CREATE PROCEDURE `sp_player_questagora_info_insert_update`(IN `in_charguid` bigint, IN `in_finish_count` int, IN `in_free_refresh_points` int, IN `in_next_server_refresh` bigint, IN `in_next_accept_time` bigint, IN `in_choice_finish_num` int)
BEGIN
	INSERT INTO tb_player_questagora_info(charguid, finish_count, free_refresh_points, next_server_refresh, next_accept_time, choice_finish_num)
	VALUES (in_charguid, in_finish_count, in_free_refresh_points, in_next_server_refresh, in_next_accept_time, in_choice_finish_num) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, finish_count = in_finish_count, free_refresh_points = in_free_refresh_points, next_server_refresh = in_next_server_refresh, next_accept_time = in_next_accept_time, choice_finish_num = in_choice_finish_num;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_info_select_by_id`;
CREATE PROCEDURE `sp_player_questagora_info_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_questagora_info WHERE charguid = in_charguid;
END;;

#***************************************************************
##版本57修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_questagora_insert_update`;
CREATE PROCEDURE `sp_player_questagora_insert_update`(IN `in_charguid` bigint, IN `in_uuid` bigint, IN `in_tid` int, IN `in_count` int, IN `in_state` int, IN `in_reward` int, IN `in_choice` int, IN `in_timestamp` bigint)
BEGIN
	INSERT INTO tb_player_questagora(charguid, uuid, tid, count, state, reward, choice, timestamp)
	VALUES (in_charguid, in_uuid, in_tid, in_count, in_state, in_reward, in_choice, in_timestamp) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, uuid=in_uuid, tid = in_tid, count = in_count, state = in_state, reward = in_reward, choice = in_choice, timestamp = in_timestamp;
END;;

DROP PROCEDURE IF EXISTS `sp_player_questagora_delete_by_id`;
CREATE PROCEDURE `sp_player_questagora_delete_by_id`(IN `in_charguid` bigint, IN `in_timestamp` bigint)
BEGIN
	DELETE FROM tb_player_questagora WHERE charguid = in_charguid AND timestamp <> in_timestamp;
END;;

#***************************************************************
##版本58修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_questagora_insert_update`;
CREATE PROCEDURE `sp_player_questagora_insert_update`(IN `in_charguid` bigint, IN `in_uuid` bigint, IN `in_tid` int, IN `in_count` int, IN `in_state` int, IN `in_reward` int, IN `in_choice` int, IN `in_param` int, IN `in_timestamp` bigint)
BEGIN
	INSERT INTO tb_player_questagora(charguid, uuid, tid, count, state, reward, choice, param, timestamp)
	VALUES (in_charguid, in_uuid, in_tid, in_count, in_state, in_reward, in_choice, in_param, in_timestamp) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, uuid=in_uuid, tid = in_tid, count = in_count, state = in_state, reward = in_reward, choice = in_choice, param = in_param, timestamp = in_timestamp;
END;;

#***************************************************************
##版本59修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_questagora_insert_update`;
CREATE PROCEDURE `sp_player_questagora_insert_update`(IN `in_charguid` bigint, IN `in_uuid` bigint, IN `in_tid` int, IN `in_count` int, IN `in_state` int, IN `in_reward` int, IN `in_choice` int, IN `in_param` int, IN `in_level` int, IN `in_timestamp` bigint)
BEGIN
	INSERT INTO tb_player_questagora(charguid, uuid, tid, count, state, reward, choice, param, level, timestamp)
	VALUES (in_charguid, in_uuid, in_tid, in_count, in_state, in_reward, in_choice, in_param, in_level, in_timestamp) 
	ON DUPLICATE KEY UPDATE  charguid=in_charguid, uuid=in_uuid, tid = in_tid, count = in_count, state = in_state, reward = in_reward, choice = in_choice, param = in_param, level = in_level, timestamp = in_timestamp;
END;;

#***************************************************************
##版本60修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_select_rank_lingqi`;
CREATE PROCEDURE `sp_select_rank_lingqi`()
BEGIN
	SELECT * FROM tb_rank_lingqi;
END;;

DROP PROCEDURE IF EXISTS `sp_select_rank_baojia`;
CREATE PROCEDURE `sp_select_rank_baojia`()
BEGIN
	SELECT * FROM tb_rank_baojia;
END;;

DROP PROCEDURE IF EXISTS `sp_select_rank_mingyu`;
CREATE PROCEDURE `sp_select_rank_mingyu`()
BEGIN
	SELECT * FROM tb_rank_mingyu;
END;;

DROP PROCEDURE IF EXISTS `sp_update_rank_lingqi`;
CREATE PROCEDURE `sp_update_rank_lingqi`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_lingqi(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END;;

DROP PROCEDURE IF EXISTS `sp_update_rank_baojia`;
CREATE PROCEDURE `sp_update_rank_baojia`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_baojia(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END;;

DROP PROCEDURE IF EXISTS `sp_update_rank_mingyu`;
CREATE PROCEDURE `sp_update_rank_mingyu`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_mingyu(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END;;

DROP PROCEDURE IF EXISTS `sp_rank_lingqi`;
CREATE PROCEDURE `sp_rank_lingqi`()
BEGIN
	SELECT tb_player_lingqi.charguid AS uid, tb_player_lingqi.level AS rankvalue FROM tb_player_lingqi left join tb_player_info
	on tb_player_lingqi.charguid = tb_player_info.charguid
	WHERE tb_player_lingqi.level > 0 ORDER BY tb_player_lingqi.level DESC, proficiencylvl DESC, proficiency DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END;;

DROP PROCEDURE IF EXISTS `sp_rank_baojia`;
CREATE PROCEDURE `sp_rank_baojia`()
BEGIN
	SELECT tb_player_baojia.charguid AS uid, tb_player_baojia.level AS rankvalue FROM tb_player_baojia left join tb_player_info
	on tb_player_baojia.charguid = tb_player_info.charguid
	WHERE tb_player_baojia.level > 0 ORDER BY tb_player_baojia.level DESC, proficiencylvl DESC, proficiency DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END;;

DROP PROCEDURE IF EXISTS `sp_rank_mingyu`;
CREATE PROCEDURE `sp_rank_mingyu`()
BEGIN
	SELECT tb_player_mingyu.charguid AS uid, tb_player_mingyu.level AS rankvalue FROM tb_player_mingyu left join tb_player_info
	on tb_player_mingyu.charguid = tb_player_info.charguid
	WHERE tb_player_mingyu.level > 0 ORDER BY tb_player_mingyu.level DESC, proficiencylvl DESC, proficiency DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END;;

DROP PROCEDURE IF EXISTS `sp_player_baojia_select_by_id`;
CREATE PROCEDURE `sp_player_baojia_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_baojia WHERE charguid=in_charguid;
END;;
DROP PROCEDURE IF EXISTS `sp_player_baojia_insert_update`;
CREATE  PROCEDURE `sp_player_baojia_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_baojia(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END;;

-- 升阶排行榜
DROP PROCEDURE IF EXISTS `sp_player_baojia_rank_info`;
CREATE  PROCEDURE `sp_player_baojia_rank_info`(IN `in_charguid` bigint)
BEGIN
	SELECT level FROM tb_player_baojia WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_mingyu_rank_info`;
CREATE  PROCEDURE `sp_player_mingyu_rank_info`(IN `in_charguid` bigint)
BEGIN
	SELECT level FROM tb_player_mingyu WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_shenbing_rank_info`;
CREATE  PROCEDURE `sp_player_shenbing_rank_info`(IN `in_charguid` bigint)
BEGIN
	SELECT level FROM tb_player_shenbing WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_fabao_rank_info`;
CREATE  PROCEDURE `sp_player_fabao_rank_info`(IN `in_charguid` bigint)
BEGIN
	SELECT level FROM tb_player_lingqi WHERE charguid = in_charguid;
END;;

-- 装备排行榜
DROP PROCEDURE IF EXISTS `sp_select_rank_human_equip_by_type`;
CREATE  PROCEDURE `sp_select_rank_human_equip_by_type`(IN `in_charguid` bigint, IN `in_type` int)
BEGIN
	SELECT item_tid,proval,flags  FROM tb_player_equips WHERE charguid = in_charguid AND bag = in_type;
END;;

-- 获取全服大于[命玉]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_level_mingyu`;
CREATE  PROCEDURE `sp_svr_role_num_level_mingyu`(IN `in_obj_level` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_player_mingyu where level >= in_obj_level;
END;;

-- 获取全服大于[境界]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_step_realm`;
CREATE  PROCEDURE `sp_svr_role_num_step_realm`(IN `in_obj_step` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_player_realm where realm_step >= in_obj_step;
END;;

-- 获取全服大于[宝甲]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_level_baojia`;
CREATE  PROCEDURE `sp_svr_role_num_level_baojia`(IN `in_obj_level` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_player_baojia where level >= in_obj_level;
END;;

-- 获取全服大于[神兵]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_level_shenbing`;
CREATE  PROCEDURE `sp_svr_role_num_level_shenbing`(IN `in_obj_level` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_player_shenbing where level >= in_obj_level;
END;;

-- 获取全服大于[宝甲]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_level_lingqi`;
CREATE  PROCEDURE `sp_svr_role_num_level_lingqi`(IN `in_obj_level` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_player_lingqi where level >= in_obj_level;
END;;

-- 获取全服大于[坐骑]指定阶数的玩家数量
DROP PROCEDURE IF EXISTS `sp_svr_role_num_step_ride`;
CREATE  PROCEDURE `sp_svr_role_num_step_ride`(IN `in_obj_step` int)
BEGIN
	SELECT count(charguid) as svr_role_num FROM tb_ride where ride_step >= in_obj_step;
END;;

#***************************************************************
##版本61修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_select_player_baoji`;
CREATE  PROCEDURE `sp_select_player_baoji`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_baoji where charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_update_player_baoji`;
CREATE  PROCEDURE `sp_update_player_baoji`(IN `in_charguid` bigint, IN `in_type` int, IN `in_end_time` int, IN `in_kind` int)
BEGIN
  INSERT INTO tb_player_baoji(charguid, type, end_time, kind)
  VALUES (in_charguid, in_type, in_end_time, in_kind) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, type=in_type,end_time=in_end_time, kind = in_kind;
END;;
#***************************************************************
##版本62修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_update_player_baoji`;
CREATE  PROCEDURE `sp_update_player_baoji`(IN `in_charguid` bigint, IN `in_type` int, IN `in_end_time` int, IN `in_kind` int, IN `in_timestamp` int)
BEGIN
  INSERT INTO tb_player_baoji(charguid, type, end_time, kind, timestamp)
  VALUES (in_charguid, in_type, in_end_time, in_kind, in_timestamp) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, type=in_type,end_time=in_end_time, kind = in_kind, timestamp = in_timestamp;
END;;

DROP PROCEDURE IF EXISTS `sp_player_baoji_delete_by_id`;
CREATE PROCEDURE `sp_player_baoji_delete_by_id`(IN `in_charguid` bigint, IN `in_timestamp` bigint)
BEGIN
	DELETE FROM tb_player_baoji WHERE charguid = in_charguid AND timestamp <> in_timestamp;
END;;
#***************************************************************
##版本63修改完成
#***************************************************************


DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update`;
CREATE PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` bigint, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint, IN `in_redpacketcnt` int, IN `in_dungeoncnt` int)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_exp,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3,redpacketcnt,dungeoncnt)
	VALUES (in_charguid,in_vip_exp,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3,in_redpacketcnt,in_dungeoncnt) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_exp=in_vip_exp,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3,redpacketcnt=in_redpacketcnt,dungeoncnt=in_dungeoncnt;
END;;

DROP PROCEDURE IF EXISTS `sp_player_todayquests_select_by_id`;
CREATE PROCEDURE `sp_player_todayquests_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_todayquest WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_todayquests_insert_update`;
CREATE PROCEDURE `sp_player_todayquests_insert_update`(IN `in_charguid` bigint,  IN `in_quest_id` int, 
IN `in_quest_counter` int, IN `in_quest_flags` int, IN `in_quest_counter_id` varchar(256))
BEGIN
  INSERT INTO tb_player_todayquest(charguid, quest_id,quest_counter,quest_flags,quest_counter_id)
  VALUES (in_charguid, in_quest_id,in_quest_counter,in_quest_flags,in_quest_counter_id) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, quest_id=in_quest_id,quest_counter=in_quest_counter,
  quest_flags=in_quest_flags,quest_counter_id=in_quest_counter_id;
END;;

#***************************************************************
##版本64修改完成
#***************************************************************
-- 保甲资质丹
DROP PROCEDURE IF EXISTS `sp_player_baojia_insert_update`;
CREATE  PROCEDURE `sp_player_baojia_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300), IN `in_zizhi_num` int)
BEGIN
  INSERT INTO tb_player_baojia(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling, zizhi_num)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling, in_zizhi_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling, zizhi_num = in_zizhi_num;
END;;

-- 命玉资质丹
DROP PROCEDURE IF EXISTS `sp_player_mingyu_insert_update`;
CREATE  PROCEDURE `sp_player_mingyu_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300), IN `in_zizhi_num` int)
BEGIN
  INSERT INTO tb_player_mingyu(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling, zizhi_num)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling, in_zizhi_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling, zizhi_num = in_zizhi_num;
END;;
-- 神兵资质丹
DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update`;
CREATE  PROCEDURE `sp_player_shenbing_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300), IN `in_zizhi_num` int)
BEGIN
  INSERT INTO tb_player_shenbing(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling, zizhi_num)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling, in_zizhi_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling, zizhi_num = in_zizhi_num;
END;;

-- 法宝资质丹
DROP PROCEDURE IF EXISTS `sp_player_lingqi_insert_update`;
CREATE  PROCEDURE `sp_player_lingqi_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300), IN `in_zizhi_num` int)
BEGIN
  INSERT INTO tb_player_lingqi(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling, zizhi_num)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling, in_zizhi_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling, zizhi_num = in_zizhi_num;
END;;

-- 坐骑资质丹
DROP PROCEDURE IF EXISTS `sp_insert_update_ride`;
CREATE  PROCEDURE `sp_insert_update_ride`(IN `in_charguid` bigint, IN `in_step` int, IN `in_select` int, IN `in_state` int, IN `in_process` int,
			IN `in_attrdan` int, IN `in_proce_num` int, IN `in_total_proce` int, IN `in_fh_zhenqi` bigint, IN `in_consum_zhenqi` bigint, IN `in_zizhi_num` int)
BEGIN
	INSERT INTO tb_ride(charguid, ride_step, ride_select, ride_state, ride_process, attrdan, proce_num, total_proce,fh_zhenqi,consum_zhenqi, zizhi_num)
	VALUES (in_charguid, in_step, in_select, in_state, in_process, in_attrdan,in_proce_num, in_total_proce,in_fh_zhenqi,in_consum_zhenqi, in_zizhi_num)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ride_step=in_step, ride_select = in_select, ride_state = in_state, ride_process = in_process, 
		attrdan=in_attrdan, proce_num=in_proce_num, total_proce=in_total_proce, fh_zhenqi=in_fh_zhenqi, consum_zhenqi=in_consum_zhenqi, zizhi_num = in_zizhi_num;
END;;

-- 境界资质丹
DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;
CREATE PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int, IN `in_fh_itemnum` bigint, IN `in_fh_level_itemnum` bigint, IN `in_attr_num` int, IN `in_zizhi_num` int)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum, fh_itemnum,fh_level_itemnum, attr_num, zizhi_num)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum, in_fh_itemnum,in_fh_level_itemnum,in_attr_num,in_zizhi_num )
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum, fh_itemnum=in_fh_itemnum, fh_level_itemnum=in_fh_level_itemnum,attr_num = in_attr_num, zizhi_num = in_zizhi_num ;
END;;


#***************************************************************
##版本65修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_lianqi_select_by_id`;
CREATE PROCEDURE `sp_player_lianqi_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_lianqi WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_lianqi_insert_update`;
CREATE PROCEDURE `sp_player_lianqi_insert_update`(IN `in_charguid` bigint,  IN `in_status` int)
BEGIN
  INSERT INTO tb_player_lianqi(charguid, status)
  VALUES (in_charguid, in_status) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, status=in_status;
END;;

#***************************************************************
#
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_update_party_group_charge`;
CREATE PROCEDURE `sp_update_party_group_charge`(IN `in_id` int, IN `in_cnt` int, IN `in_extracnt` int, IN `in_groupid` int)
BEGIN
	INSERT INTO tb_group_charge(id, cnt, extracnt, groupid)
	VALUES (in_id, in_cnt, in_extracnt, in_groupid) 
	ON DUPLICATE KEY UPDATE id=in_id, cnt=in_cnt, extracnt=in_extracnt, groupid=in_groupid;
END;;

#***************************************************************
##版本67修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_update_party`;
CREATE PROCEDURE `sp_player_update_party`(IN `in_guid` bigint, 
IN `in_id` int, 
IN `in_progress` int, 
IN `in_award` int, 
IN `in_awardtimes` int, 
IN `in_charge` int,
IN `in_param1` int, 
IN `in_param2` int, 
IN`in_param3` int, 
IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_party(charguid, id, progress, award, awardtimes, charge, param1, param2, param3, time_stamp)
	VALUES (in_guid, in_id, in_progress, in_award, in_awardtimes, in_charge, in_param1, in_param2, in_param3, in_time_stamp)
	ON DUPLICATE KEY UPDATE 
	charguid = in_guid, 
	id = in_id, 
	progress = in_progress, 
	award = in_award, 
	awardtimes = in_awardtimes, 
	charge = in_charge,
	param1 = in_param1, 
	param2 = in_param2, 
	param3 = in_param3, 
	time_stamp = in_time_stamp;
END;;

DROP PROCEDURE IF EXISTS `sp_exchange_record_insert_update`;
CREATE PROCEDURE `sp_exchange_record_insert_update`(
IN `in_order_id` varchar(32), 
IN `in_uid` varchar(32), 
IN `in_role_id` bigint, 
IN `in_platform` varchar(32), 
IN `in_money` int, 
IN `in_coins` int, 
IN `in_time` int, 
IN `in_recharge` int)
BEGIN
  INSERT INTO tb_exchange_record(order_id, uid, role_id, platform, money, coins, time, recharge)
  VALUES (in_order_id, in_uid, in_role_id, in_platform, in_money, in_coins, in_time, in_recharge);
END;;

#***************************************************************
##版本68修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_player_exchange_select_by_time`;
CREATE PROCEDURE `sp_player_exchange_select_by_time`(IN `in_role_id` bigint,IN `in_start_time` bigint,IN `in_ended_time` bigint)
BEGIN
  SELECT sum(coins) as num FROM tb_exchange_record WHERE role_id = in_role_id and time >= in_start_time and time <= in_ended_time;
END;;

#***************************************************************
##版本68修改完成
#***************************************************************

DROP PROCEDURE IF EXISTS `sp_insert_update_player_vplan`;
CREATE PROCEDURE `sp_insert_update_player_vplan`(
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
	IN `in_consume_time` int,
	IN `in_weishi_get_time` int)
BEGIN
  INSERT INTO tb_player_vplan(charguid, newbie_gift_m, newbie_gift_y, daily_gift, 
  	title_m, title_y, level_gift, mail_flag, consume_gift, consume_num, consume_time, weishi_get_time)
  VALUES (in_charguid, in_newbie_gift_m, in_newbie_gift_y, in_daily_gift, 
  	in_title_m, in_title_y, in_level_gift, in_mail_flag, in_consume_gift, in_consume_num, in_consume_time, in_weishi_get_time)
  ON DUPLICATE KEY UPDATE newbie_gift_m = in_newbie_gift_m, newbie_gift_y = in_newbie_gift_y, daily_gift = in_daily_gift, 
  title_m = in_title_m, title_y = in_title_y, level_gift = in_level_gift, mail_flag = in_mail_flag,
  consume_gift = in_consume_gift, consume_num = in_consume_num, consume_time = in_consume_time, weishi_get_time = in_weishi_get_time;
END;;

#***************************************************************
##版本69修改完成
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_firstdata_select_by_id`;
CREATE PROCEDURE `sp_player_firstdata_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_firstdata WHERE charguid = in_charguid;
END;;

DROP PROCEDURE IF EXISTS `sp_player_firstdata_insert_update`;
CREATE PROCEDURE `sp_player_firstdata_insert_update`(IN `in_charguid` bigint,  IN `in_status` int)
BEGIN
  INSERT INTO tb_player_firstdata(charguid, status)
  VALUES (in_charguid, in_status) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, status=in_status;
END;;
#***************************************************************
##版本70修改完成
#***************************************************************

-- ----------------------------
-- Procedure structure for sp_player_tianshen_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_tianshen_select`;
CREATE PROCEDURE `sp_player_tianshen_select`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_tianshen WHERE  charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_tianshen_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_tianshen_insert_update`;
CREATE PROCEDURE `sp_player_tianshen_insert_update`(
	IN `in_charguid` bigint, 
	IN `in_id` bigint, 
	IN `in_tid` int, 
	IN `in_cardtid` int,
	IN `in_ability` int,	
	IN `in_star` int, 
	IN `in_step` int, 
	IN `in_stepexp` int, 
	IN `in_state` int,
	IN `in_pos` int,
	IN `in_getmap` int,
	IN `in_gettime` int,
	IN `in_passskills` varchar(128),
	IN `in_timestamp` bigint)
BEGIN
	INSERT INTO tb_player_tianshen(charguid, id, tid, cardtid, ability, star, step, stepexp, state, pos, getmap, gettime, passskills, timestamp)
	VALUES(in_charguid, in_id, in_tid, in_cardtid, in_ability, in_star, in_step, in_stepexp, in_state, in_pos, in_getmap, in_gettime, in_passskills, in_timestamp)
	ON DUPLICATE KEY UPDATE
	charguid = in_charguid, id = in_id, tid = in_tid, cardtid = in_cardtid, ability = in_ability, star = in_star, step = in_step, stepexp = in_stepexp, state = in_state, 
	pos = in_pos, getmap = in_getmap, gettime = in_gettime, passskills = in_passskills, timestamp = in_timestamp;
END;;

DROP PROCEDURE IF EXISTS `sp_player_tianshen_delete_by_id`;
CREATE PROCEDURE `sp_player_tianshen_delete_by_id`(IN `in_charguid` bigint, IN `in_timestamp` bigint)
BEGIN
	DELETE FROM tb_player_tianshen WHERE charguid = in_charguid AND timestamp <> in_timestamp;
END;;

#***************************************************************
##版本71修改完成
#***************************************************************


#***************************************************************
#***************************************************************
##++++++++++++++++++++过程修改完成++++++++++++++++++++++++++++++
DELIMITER ;
