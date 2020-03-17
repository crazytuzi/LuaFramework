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
IF lastVersion<201 THEN 
#----------------------------------------------------------------------
	CREATE TABLE `tb_guild_boss` (
	  `gid` bigint(20) NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `boss_time` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Boss召唤时间',
	  PRIMARY KEY (`gid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派BOSS表';
	#----------------------------------------------------------------------
		SET lastVersion = 201;
		SET versionNotes = 'add guildboss';
	#----------------------------------------------------------------------
END IF;
#----------------------------------------------------------------------
#***************************************************************
IF lastVersion<202 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE tb_player_realm
	ADD COLUMN `wish` int(11) NOT NULL DEFAULT '0' COMMENT '祝福值',
	ADD COLUMN `procenum` int(11) NOT NULL DEFAULT '0' COMMENT '进阶失败次数';
#----------------------------------------------------------------------
	SET lastVersion = 202; 
	SET versionNotes = 'add wish,procenum';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<203 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	CREATE TABLE `tb_rank_shenbing` (
	  `rank` int(11) NOT NULL COMMENT '排行',
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
	  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '神兵等级',
	  PRIMARY KEY (`rank`),
	  KEY `guid_idx` (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兵排行';
#----------------------------------------------------------------------
	SET lastVersion = 203; 
	SET versionNotes = 'add rank shenbing';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<204 THEN 
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_vip` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `vip_exp` int(11) NOT NULL DEFAULT '0' COMMENT 'vip经验',
	  `vip_lvlreward` int(11) NOT NULL DEFAULT '0' COMMENT 'vip等级奖励',
	  `vip_weekrewardtime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip周奖励领取时间',
	  `vip_typelasttime1` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间1',
	  `vip_typelasttime2` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间2',
	  `vip_typelasttime3` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'vip类型到期时间3',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	ALTER TABLE `tb_ride`
	ADD COLUMN `fh_total_proce` int(11) NOT NULL DEFAULT '0' COMMENT '返还次数';
	 
	ALTER TABLE `tb_player_wuhuns`
	ADD COLUMN `total_proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '总失败次数',
	ADD COLUMN `fh_total_proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '返还次数';
	
	ALTER TABLE tb_player_refinery
	ADD COLUMN `cost_zhenqi` int(11) NOT NULL DEFAULT '0' COMMENT '消耗真气',
	ADD COLUMN `fh_cost_zhenqi` int(11) NOT NULL DEFAULT '0' COMMENT '返还消耗真气';	
#----------------------------------------------------------------------
	SET lastVersion = 204;
	SET versionNotes = 'create tb_player_vip';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<205 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_ride`
	DROP COLUMN `fh_total_proce`,
	ADD COLUMN `fh_zhenqi` int(11) NOT NULL DEFAULT '0' COMMENT '可返还真气';
	 
	ALTER TABLE `tb_player_wuhuns`
	DROP COLUMN `fh_total_proce_num`,
	ADD COLUMN `fh_item_num` int(11) NOT NULL DEFAULT '0' COMMENT '可返还道具';

#----------------------------------------------------------------------
	SET lastVersion = 205;
	SET versionNotes = 'alter vip';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<206 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_homeland`;
	CREATE TABLE `tb_player_homeland` (
	  `charguid` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `main_lv` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '大殿等级',
	  `quest_lv` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '任务殿等级',
	  `xunxian_lv` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '寻仙台等级',
	  `rob_cnt`  	int(11)		NOT NULL DEFAULT '0' COMMENT '掠夺次数',
	  `rob_cd`  	int(11)		NOT NULL DEFAULT '0' COMMENT '掠夺CD',
	  `xunxian_ref`	int(11)		NOT NULL DEFAULT '0' COMMENT '寻仙台刷新时间',
	  `xunxian_cnt`	int(11)		NOT NULL DEFAULT '0' COMMENT '寻仙台刷新时间',
	  `quest_ref`	int(11)		NOT NULL DEFAULT '0' COMMENT '任务殿刷新时间',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '家园表';
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_disciple`;
	CREATE TABLE `tb_player_disciple` (
	  `gid`		 bigint(20)  NOT NULL DEFAULT '0' COMMENT '弟子GUID',
	  `charguid` bigint(20)  NOT NULL DEFAULT '0' COMMENT 'guid',
	  `quality`  int(11) 	 NOT NULL DEFAULT '0' COMMENT '品质',
	  `name` 	 varchar(32) NOT NULL DEFAULT ''  COMMENT '弟子姓名',
	  `skill_1`  int(11) 	 NOT NULL DEFAULT '0' COMMENT '技能一',
	  `skill_2`  int(11) 	 NOT NULL DEFAULT '0' COMMENT '技能二', 
	  `skill_3`  int(11) 	 NOT NULL DEFAULT '0' COMMENT '技能三', 
	  `level`    int(11) 	 NOT NULL DEFAULT '0' COMMENT '等级',
	  `exp`   	 int(11) 	 NOT NULL DEFAULT '0' COMMENT '当前经验',
	  `icon`	 int(11) 	 NOT NULL DEFAULT '0' COMMENT '头像',
	  `attr`	 int(11) 	 NOT NULL DEFAULT '0' COMMENT '属性',
	  `status` 	 int(11)  	 NOT NULL DEFAULT '0' COMMENT '状态',
	  PRIMARY KEY (`gid`),
	  KEY `charguid` (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '弟子表';
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_homeland_quest`;
	CREATE TABLE `tb_homeland_quest` (
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '任务GUID',
	  `charguid` 	bigint(20)	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `power`		bigint(20)	NOT NULL DEFAULT '0' COMMENT '玩家战斗力',
	  `level`		int(11)		NOT NULL DEFAULT '0' COMMENT '玩家等级',
	  `name`		varchar(32)	NOT NULL DEFAULT ''  COMMENT '玩家名字',
	  `tid` 		int(11)		NOT NULL DEFAULT '0' COMMENT '配表iD',
	  `quest_lv` 	int(11)		NOT NULL DEFAULT '0' COMMENT '任务等级',
	  `finish_time`	int(11)		NOT NULL DEFAULT '0' COMMENT '开始时间',
	  `last_time`	int(11)		NOT NULL DEFAULT '0' COMMENT '持续时间',
	  `quality`  	int(11) 	NOT NULL DEFAULT '0' COMMENT '品质',
	  `rob_cnt`		int(11)		NOT NULL DEFAULT '0' COMMENT '掠夺次数',
	  `status`		int(11)		NOT NULL DEFAULT '0' COMMENT '任务状态',
	  `mon_1`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物一',
	  `mon_2`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物二', 
	  `mon_3`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物三', 
	  `item_id`		int(11)		NOT NULL DEFAULT '0' COMMENT '物品ID',
	  `reward_type`	int(11)		NOT NULL DEFAULT '0' COMMENT '奖励类型',
	  `reward`		bigint(20)	NOT NULL DEFAULT '0' COMMENT '奖励',
	  `exp` 		bigint(20)	NOT NULL DEFAULT '0' COMMENT '弟子经验',
	  `disciple_1`	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '弟子一',
	  `disciple_2`  bigint(20) 	NOT NULL DEFAULT '0' COMMENT '弟子二', 
	  `disciple_3`  bigint(20) 	NOT NULL DEFAULT '0' COMMENT '弟子三',
	  PRIMARY KEY (`gid`),
	  KEY `charguid` (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '家园已接取任务表';
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_hl_quest`;
	CREATE TABLE `tb_player_hl_quest` (
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '任务GUID',
	  `charguid` 	bigint(20)	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `tid` 		int(11)		NOT NULL DEFAULT '0' COMMENT '配表iD',
	  `need_time`	int(11)		NOT NULL DEFAULT '0' COMMENT '需要时间',
	  `quality`		int(11)		NOT NULL DEFAULT '0' COMMENT '品质',
	  `level`		int(11)		NOT NULL DEFAULT '0' COMMENT '等级',
	  `mon_1`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物一',
	  `mon_2`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物二', 
	  `mon_3`  		int(11) 	NOT NULL DEFAULT '0' COMMENT '怪物三', 
	  `item_id`		int(11)		NOT NULL DEFAULT '0' COMMENT '物品ID',
	  `reward_type`	int(11)		NOT NULL DEFAULT '0' COMMENT '奖励类型',
	  `reward`		bigint(20)	NOT NULL DEFAULT '0' COMMENT '奖励',
	  `exp` 		bigint(20)	NOT NULL DEFAULT '0' COMMENT '弟子经验',
	  PRIMARY KEY (`gid`),
	  KEY `charguid` (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '待接取家园任务表';
#----------------------------------------------------------------------
	SET lastVersion = 206;
	SET versionNotes = 'add homeland';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<207 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	ADD COLUMN `blesstime2` bigint(20) NOT NULL DEFAULT '0' COMMENT '膜拜时间2',
	ADD COLUMN `blesstime3` bigint(20) NOT NULL DEFAULT '0' COMMENT '膜拜时间3',
	ADD COLUMN `suitflag` int(11) NOT NULL DEFAULT '0' COMMENT '套装标识',
	ADD COLUMN `crossscore` int(11) NOT NULL DEFAULT '0' COMMENT '跨服积分',
	ADD COLUMN `crossexploit` int(11) NOT NULL DEFAULT '0' COMMENT '跨服功勋';
#----------------------------------------------------------------------
	SET lastVersion = 207;
	SET versionNotes = 'add suitflag ,bless, cross arena';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<208 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_homeland`
	ADD COLUMN `buy_cnt` int(11) NOT NULL DEFAULT '0' COMMENT '够买次数';
#----------------------------------------------------------------------
	SET lastVersion = 208;
	SET versionNotes = 'add buy cnt';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<209 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 209;
	SET versionNotes = 'edit vip';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<210 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_homeland`
	DROP COLUMN `buy_cnt`,
	ADD COLUMN `rob_cnt_cd` int(11) NOT NULL DEFAULT '0' COMMENT '抢夺次数刷新时间';
#----------------------------------------------------------------------
	SET lastVersion = 210;
	SET versionNotes = 'edit homeland';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<211 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 211;
	SET versionNotes = 'edit homeland';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<212 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_mail_content`
	CHANGE COLUMN `itemnum1` `itemnum1` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum2` `itemnum2` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum3` `itemnum3` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum4` `itemnum4` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum5` `itemnum5` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum6` `itemnum6` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum7` `itemnum7` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量',
	CHANGE COLUMN `itemnum8` `itemnum8` bigint(20) NOT NULL DEFAULT '0' COMMENT '附件数量';
#----------------------------------------------------------------------
	SET lastVersion = 212;
	SET versionNotes = 'alter mail';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<213 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_activity
	ADD COLUMN `online_time` bigint(20) NOT NULL DEFAULT '0'  COMMENT '玩家在活动时长';
#----------------------------------------------------------------------
	SET lastVersion = 213;
	SET versionNotes = 'add online_time';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<214 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_hl_quest
	DROP INDEX `charguid`,
	DROP PRIMARY KEY,
	ADD PRIMARY KEY(`gid`, `charguid`);
#----------------------------------------------------------------------
	SET lastVersion = 214;
	SET versionNotes = 'add online_time';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<215 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_guild_mem`
	ADD COLUMN `loyalty` int(11) NOT NULL DEFAULT '0' COMMENT '忠诚度';
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	ADD COLUMN `crossseasonid` int(11) NOT NULL DEFAULT '0' COMMENT '赛季ID',
	ADD COLUMN `pvplevel` int(11) NOT NULL DEFAULT '0' COMMENT '段位';
#----------------------------------------------------------------------
	CREATE TABLE `tb_rank_crossscore` (
	  `rank` int(11) NOT NULL COMMENT '排行',
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `lastrank` int(11) NOT NULL DEFAULT '0' COMMENT '上次排行',
	  `rankvalue` bigint(20) NOT NULL DEFAULT '0' COMMENT '跨服积分',
	  PRIMARY KEY (`rank`),
	  KEY `guid_idx` (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服段位排行';
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_crosspvp` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `curcnt` int(11) NOT NULL DEFAULT '0' COMMENT '当天1v1次数',
	  `totalcnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1总次数',
	  `wincnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1胜利次数',
	  `contwincnt` int(11) NOT NULL DEFAULT '0' COMMENT '1v1连胜次数',
	  `flags` int(11) NOT NULL DEFAULT '0' COMMENT '标识',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家跨服1V1';
#----------------------------------------------------------------------
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
	  `name` varchar(32)	NOT NULL DEFAULT ''  COMMENT '玩家名字',
	  PRIMARY KEY (`seasonid`, `rank`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='赛季历史记录';
#----------------------------------------------------------------------
	SET lastVersion = 215;
	SET versionNotes = 'alter guildmem and cross fight';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<216 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_prerogative`;
	CREATE TABLE `tb_player_prerogative` (
	  `charguid` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `prerogative` int(11) 	NOT NULL DEFAULT '0' COMMENT '特权类型',
	  `param_32`	int(11) 	NOT NULL DEFAULT '0' COMMENT '参数1',
	  `param_64`	bigint(20)  NOT NULL DEFAULT '0' COMMENT '参数2',
	  PRIMARY KEY (`charguid`, `prerogative`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '特权奖励表';
#----------------------------------------------------------------------
	SET lastVersion = 216;
	SET versionNotes = 'add prerogative';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<217 THEN 
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_binghun` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `id` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂ID',
	  `state` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂状态， 1：关闭',
	  `current` int(11) NOT NULL DEFAULT '0' COMMENT '当前兵魂， 1：当前',
	  `activetime` bigint(20) NOT NULL DEFAULT '0' COMMENT '激活时间',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳', 
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兵魂';
#----------------------------------------------------------------------
	SET lastVersion = 217; 
	SET versionNotes = 'add binghun';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<218 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_extra`
	CHANGE COLUMN `func_flags` `func_flags` varchar(128) NOT NULL DEFAULT '' COMMENT '功能开启标识';
#----------------------------------------------------------------------
	SET lastVersion = 218; 
	SET versionNotes = 'Modify func_flags';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<219 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_waterdup
	ADD COLUMN `reward_rate` double NOT NULL DEFAULT '0'  COMMENT '经验副本倍率',
	ADD COLUMN `reward_exp`  double NOT NULL DEFAULT '0'  COMMENT '经验副本单倍经验';
#----------------------------------------------------------------------
	SET lastVersion = 219;
	SET versionNotes = 'add reward_rate';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<220 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_smelt` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `smelt_level` int(11) NOT NULL DEFAULT '0' COMMENT '熔炼等级',
	  `smelt_exp` int(11) NOT NULL DEFAULT '0' COMMENT '熔炼经验',
	  `smelt_flags`	bigint(20)	NOT NULL DEFAULT '0' COMMENT '熔炼品质',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家熔炼炉';
#----------------------------------------------------------------------
	SET lastVersion = 220; 
	SET versionNotes = 'add table smelt';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<221 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_extra`
	ADD COLUMN `zhuan_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '转生次数',
	ADD COLUMN `zhuan_step` bigint(20) NOT NULL DEFAULT '0' COMMENT '转生步骤';
#----------------------------------------------------------------------
	SET lastVersion = 221;
	SET versionNotes = 'add suitflag ,bless, cross arena';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<222 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_waterdup
	ADD COLUMN `history_kill`  double NOT NULL DEFAULT '0'  COMMENT '经验副本历史最高杀怪';
#----------------------------------------------------------------------
	SET lastVersion = 222;
	SET versionNotes = 'add history_kill';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<223 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_binghun`;
	CREATE TABLE `tb_player_binghun` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `id` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂ID',
	  `state` int(11) NOT NULL DEFAULT '0' COMMENT '兵魂状态， 1：关闭',
	  `current` int(11) NOT NULL DEFAULT '0' COMMENT '当前兵魂， 1：当前',
	  `activetime` bigint(20) NOT NULL DEFAULT '0' COMMENT '激活时间',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳', 
	  PRIMARY KEY (`charguid`, `id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兵魂';
#----------------------------------------------------------------------
	SET lastVersion = 223; 
	SET versionNotes = 'alter binghun';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<224 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_ride`
	ADD COLUMN `consum_zhenqi` int(11) NOT NULL DEFAULT '0' COMMENT '消耗真气 升级后清零';

#----------------------------------------------------------------------
	SET lastVersion = 224;
	SET versionNotes = 'alter tb_ride';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<225 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_refinery
	CHANGE COLUMN `cost_zhenqi` `cost_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '消耗真气',
	CHANGE COLUMN `fh_cost_zhenqi` `fh_cost_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '返还消耗真气';
	
	ALTER TABLE `tb_ride`
	CHANGE COLUMN `fh_zhenqi` `fh_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '可返还真气';
	
	ALTER TABLE `tb_player_vip`
	CHANGE COLUMN `vip_exp` `vip_exp` bigint(20) NOT NULL DEFAULT '0' COMMENT 'vip经验';

#----------------------------------------------------------------------
	SET lastVersion = 225;
	SET versionNotes = 'alter tb_ride tb_player_refinery';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<226 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_account
	ADD COLUMN `gm_flag`		int(11) 	  	NOT NULL DEFAULT '0' COMMENT 'GM帐号标识',
	ADD COLUMN `forb_type` 	 	int(11) 	  	NOT NULL DEFAULT '0' COMMENT '禁封类型',
	ADD COLUMN `lock_reason`	varchar(128) 	NOT NULL DEFAULT ''  COMMENT '禁封原因',
	ADD COLUMN `welfare`	 	int(11)	 		NOT NULL DEFAULT '0' COMMENT '福利账号状态',
	ADD COLUMN `oper` 		 	varchar(64)		NOT NULL DEFAULT ''  COMMENT '福利账号申请人',
	ADD COLUMN `oper_time` 	 	int(11)	 		NOT NULL DEFAULT '0' COMMENT '福利账号申请时间';
#----------------------------------------------------------------------
	SET lastVersion = 226;
	SET versionNotes = 'add gm flag';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<227 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_ride`
	CHANGE COLUMN `consum_zhenqi` `consum_zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '消耗真气 升级后清零';
#----------------------------------------------------------------------
	SET lastVersion = 227;
	SET versionNotes = 'alter tb_ride';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<228 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	CHANGE COLUMN `zhenqi` `zhenqi` bigint(20) NOT NULL DEFAULT '0' COMMENT '真气';
#----------------------------------------------------------------------
	SET lastVersion = 228;
	SET versionNotes = 'alter tb_ride';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<229 THEN 
#----------------------------------------------------------------------
	
#----------------------------------------------------------------------
	SET lastVersion = 229;
	SET versionNotes = 'gm account';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<230 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_vip`
	ADD COLUMN `redpacketcnt` int(11) NOT NULL DEFAULT '0' COMMENT 'VIP特权红包发送次数';
#----------------------------------------------------------------------
	SET lastVersion = 230;
	SET versionNotes = 'alter tb_player_vip';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<231 THEN 
#----------------------------------------------------------------------
	
#----------------------------------------------------------------------
	SET lastVersion = 231;
	SET versionNotes = 'super lock';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<232 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_zhuzairoad_box
    ADD COLUMN `roadlv_max` int(11) NOT NULL DEFAULT '0'  COMMENT '主宰之路挑战最高等级';
#----------------------------------------------------------------------
	SET lastVersion = 232;
	SET versionNotes = 'add roadlv_max';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<233 THEN 
#----------------------------------------------------------------------
    DROP TABLE IF EXISTS `tb_player_shenshou`;
	CREATE TABLE `tb_player_shenshou` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `shenshou_id` int(11) NOT NULL DEFAULT '0' COMMENT '神兽ID',
	  `skin_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '神兽皮肤时间',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神兽';
#----------------------------------------------------------------------
	SET lastVersion = 233; 
	SET versionNotes = 'alter shenshou';
#----------------------------------------------------------------------
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<234 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_consignment_record`
	DROP COLUMN `money_type`;
#----------------------------------------------------------------------
	ALTER TABLE `tb_consignment_items`
	DROP COLUMN `money_type`,
	DROP COLUMN `item_state`,
	DROP COLUMN `itemgid`,
	DROP COLUMN `gid`,
	CHANGE COLUMN `save_time` `save_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '到期时间';
#----------------------------------------------------------------------
	SET lastVersion = 234;
	SET versionNotes = 'alter consignment';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<235 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_extra 
	add column `lastCheckTime`  int(11) NOT NULL DEFAULT 0 ,
    add column `daily_count`  varchar(350) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '每日计数';
#----------------------------------------------------------
	SET lastVersion = 235;
	SET versionNotes = 'add count';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<236 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_homeland
    ADD COLUMN `recruit` int(11) NOT NULL DEFAULT '0'  COMMENT '招募次数';
#----------------------------------------------------------------------
	SET lastVersion = 236;
	SET versionNotes = 'Modify Homeand';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<237 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_ls_horse`;
	CREATE TABLE `tb_player_ls_horse` (
	  `charguid`         bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `lshorse_step`     int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑阶数',
	  `lshorse_process`  int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑进度',
	  `lshorse_procenum` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑进阶次数',
	  `lshorse_totalproce` int(11) NOT NULL DEFAULT '0' COMMENT '灵兽坐骑总进阶次数',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='灵兽坐骑';
#----------------------------------------------------------------------
	SET lastVersion = 237;
	SET versionNotes = 'add tb_player_lshorrse';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<238 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_homeland
    ADD COLUMN `quest_cnt` int(11) NOT NULL DEFAULT '0'  COMMENT '任务刷新次数';
#----------------------------------------------------------------------
	SET lastVersion = 238;
	SET versionNotes = 'Modify Homeand';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<239 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_forb_mac
    CHANGE COLUMN `guid` `charguid` bigint(20) NOT NULL DEFAULT '0'  COMMENT 'charguid';
#----------------------------------------------------------------------
	SET lastVersion = 239;
	SET versionNotes = 'Modify tb_forb_mac';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<240 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_extra
    CHANGE COLUMN `actcode_flags` `actcode_flags` varchar(256) NOT NULL DEFAULT ''  COMMENT '激活码标识';
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_party` (
	  `id` int(11) NOT NULL COMMENT '活动ID',
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
	  `award` int(11) NOT NULL DEFAULT '0' COMMENT '奖励标记',
	  `awardtimes` int(11) NOT NULL DEFAULT '0' COMMENT '奖励次数',
	  `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
	  `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`charguid`,`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='运营活动表';
#----------------------------------------------------------------------
	CREATE TABLE `tb_group_purchase` (
	  `id` int(11) NOT NULL DEFAULT '0' COMMENT '活动ID',
	  `cnt` int(11) NOT NULL DEFAULT '0' COMMENT '次数',
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='团购表';
#----------------------------------------------------------------------
	CREATE TABLE `tb_party_rank` (
	  `id` int(11) NOT NULL DEFAULT '0' COMMENT '活动ID',
	  `name` varchar(32)	NOT NULL DEFAULT ''  COMMENT '玩家名字',
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
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='活动排行表';
#----------------------------------------------------------------------
	SET lastVersion = 240;
	SET versionNotes = 'add party';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<241 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_shenshou 
    DROP PRIMARY KEY,
    ADD PRIMARY KEY(`charguid`, `shenshou_id`);
#----------------------------------------------------------------------
	SET lastVersion = 241;
	SET versionNotes = 'change primary Key';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<242 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_wuhuns 
    ADD COLUMN `select_id` int(11) NOT NULL DEFAULT '0' COMMENT '选中灵兽',
    ADD COLUMN `attr_num`  int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量';
#----------------------------------------------------------------------
	SET lastVersion = 242;
	SET versionNotes = 'change primary Key';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<243 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 243;
	SET versionNotes = 'add rank wuhun equips';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<244 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_vplan 
    ADD COLUMN `consume_gift` varchar(64) NOT NULL DEFAULT '0' COMMENT '消费领奖状态',
    ADD COLUMN `consume_num`  int(11) NOT NULL DEFAULT '0' COMMENT '消费量',
    ADD COLUMN `consume_time`  int(11) NOT NULL DEFAULT '0' COMMENT '消费周期时间';
#----------------------------------------------------------------------
	SET lastVersion = 244;
	SET versionNotes = 'change vplan';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<245 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_shenbing`
	ADD COLUMN `attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '神兵属性丹数量';
	ALTER TABLE `tb_player_extra`
	ADD COLUMN `lingzhen_attr_num` int(11) NOT NULL DEFAULT '0' COMMENT '灵阵属性丹数量';
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 245;
	SET versionNotes = 'alter attr_num';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<246 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_waterdup
	ADD COLUMN `buy_count` int(11) NOT NULL DEFAULT '0'  COMMENT '经验副本道具购买次数';
#----------------------------------------------------------------------
	SET lastVersion = 246;
	SET versionNotes = 'add buy_count';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<247 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_realm
	ADD COLUMN `fh_itemnum` bigint(20) NOT NULL DEFAULT '0' COMMENT '返还道具数量';
#----------------------------------------------------------------------
	SET lastVersion = 247; 
	SET versionNotes = 'add fh_itemnum';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<248 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_extra
    ADD COLUMN `footprints` int(11) NOT NULL DEFAULT '0'  COMMENT '脚印ID';
#----------------------------------------------------------------------
	SET lastVersion = 248; 
	SET versionNotes = 'add footprints';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<249 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_party
    ADD COLUMN `param3` int(11) NOT NULL DEFAULT '0' COMMENT '参数3';
#----------------------------------------------------------------------
	SET lastVersion = 249; 
	SET versionNotes = 'alter tb_player_party';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<250 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_wuhuns`
	ADD COLUMN `fh_level_item_num` bigint(20) NOT NULL DEFAULT '0' COMMENT '可返还道具当前等阶';
	
	ALTER TABLE tb_player_realm
	ADD COLUMN `fh_level_itemnum` int(11) NOT NULL DEFAULT '0' COMMENT '返还道具数量当前等阶';
	
#----------------------------------------------------------------------
	SET lastVersion = 250;
	SET versionNotes = 'alter wuhuns realm';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<251 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_group_purchase`
	ADD COLUMN `extracnt` int(11) NOT NULL DEFAULT '0' COMMENT '额外次数',
	ADD COLUMN `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
	ADD COLUMN `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2';
#----------------------------------------------------------------------
	SET lastVersion = 251;
	SET versionNotes = 'alter tb_group_purchase';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<252 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 252;
	SET versionNotes = 'add user total virtual recharge';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<253 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_party_rank`
	ADD COLUMN `param1` int(11) NOT NULL DEFAULT '0' COMMENT '参数1',
	ADD COLUMN `param2` int(11) NOT NULL DEFAULT '0' COMMENT '参数2';
	SET lastVersion = 253;
	SET versionNotes = 'alter rank';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<254 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_guild_citywar`
	ADD COLUMN `isfirst` int(11) NOT NULL DEFAULT 1 COMMENT '是否是第一次';
	SET lastVersion = 254;
	SET versionNotes = 'alter tb_guild_citywar';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<255 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_extra`
	ADD COLUMN `equipcreate_tick` int(11) NOT NULL DEFAULT '0' COMMENT '装备打造活力值在线时间';
	SET lastVersion = 255;
	SET versionNotes = 'alter tb_player_extra';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<256 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_extra`
	ADD COLUMN `huizhang_tick` int(11) NOT NULL DEFAULT '0' COMMENT '聚灵碗在线时间';
	SET lastVersion = 256;
	SET versionNotes = 'alter tb_player_extra';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<257 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 257;
	SET versionNotes = 'alter rank';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<258 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_personboss`;
	CREATE TABLE `tb_player_personboss` (
	  `charguid` bigint(20) NOT NULL DEFAULT '0' COMMENT '角色GUID',
	  `id` int(11) NOT NULL DEFAULT '0' COMMENT '个人bossID',
	  `cur_count`  int(11) NOT NULL DEFAULT '0' COMMENT '当前次数',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '更新时间',
	  PRIMARY KEY (`charguid`,`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='个人boss';

#---------------------------------------------------------------------
ALTER TABLE `tb_player_extra`
ADD COLUMN `personboss_count` int(11) NOT NULL DEFAULT '0' COMMENT '个人boss购买次数';
#----------------------------------------------------------------------
	SET lastVersion = 258; 
	SET versionNotes = 'alter personboss';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<259 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_equips`
	ADD COLUMN `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
	ADD COLUMN `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态';
	
	ALTER TABLE `tb_guild_storage`
	ADD COLUMN `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
	ADD COLUMN `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态';	
	
	ALTER TABLE `tb_consignment_items`
	ADD COLUMN `newgroup` int(11) NOT NULL DEFAULT '0' COMMENT '新套装ID',
	ADD COLUMN `newgroupbind` int(11) NOT NULL DEFAULT '0' COMMENT '新套装材料绑定状态';	
	
	SET lastVersion = 259;
	SET versionNotes = 'add newgroup';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<260 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	alter table tb_player_cd drop primary key;
	alter table tb_player_cd add primary key(charguid,type,tid);

	SET lastVersion = 260;
	SET versionNotes = 'alert tb_player_cd primary';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<261 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_guild`
	ADD COLUMN `extendnum` int(11) NOT NULL DEFAULT '0' COMMENT '扩展人数';

	SET lastVersion = 261;
	SET versionNotes = 'alert tb_guild';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<262 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_personboss`
	ADD COLUMN `first` int(11) NOT NULL DEFAULT '0' COMMENT '首通标记1,首通';
	SET lastVersion = 262;
	SET versionNotes = 'add first';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<264 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 264;
	SET versionNotes = 'edit gm';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<265 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_ridewar`;
	CREATE TABLE `tb_player_ridewar` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `ridewar_id`      int(11) 	NOT NULL DEFAULT '0' COMMENT '骑战id',
	  `ridewar_wish`    int(11) 	NOT NULL DEFAULT '0' COMMENT '骑战祝福值',
	  `ridewar_procenum`int(11)     NOT NULL DEFAULT '0' COMMENT '骑战进阶失败次数',
	  `ridewar_attrnum` int(11)     NOT NULL DEFAULT '0' COMMENT '骑战属性丹数',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '骑战表';
#----------------------------------------------------------------------
	SET lastVersion = 265;
	SET versionNotes = 'add ridewar';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<266 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 266;
	SET versionNotes = 'edit platform';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<267 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_exchange_record`
	ADD COLUMN `recharge` int(11) NOT NULL DEFAULT '1' COMMENT '是否兑换',
	DROP COLUMN `platform`,
	ADD COLUMN  `platform` VARCHAR(32)   NOT NULL DEFAULT '' COMMENT '平台';
#----------------------------------------------------------------------
	SET lastVersion = 267;
	SET versionNotes = 'edit recharge';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<268 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_ridewar`
	ADD COLUMN `ridewar_skin` int(11) NOT NULL DEFAULT '0' COMMENT '骑战当前选择id';
	SET lastVersion = 268;
	SET versionNotes = 'add ridewar_skin';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<269 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_ride_dupl`;
	CREATE TABLE `tb_player_ride_dupl` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `count`			int(11)		NOT NULL DEFAULT '0' COMMENT '今日次数',
	  `today`			int(11)		NOT NULL DEFAULT '0' COMMENT '今日层数',
	  `history`			int(11)		NOT NULL DEFAULT '0' COMMENT '历史层数',	
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '骑战副本表';
	#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_rank_ride_dupl`;
	CREATE TABLE `tb_rank_ride_dupl` (
	  `rank`			int(11)		NOT NULL DEFAULT '0' COMMENT '排名',
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `layer`			int(11)		NOT NULL DEFAULT '0' COMMENT '层数',
	  `time`			int(11)		NOT NULL DEFAULT '0' COMMENT '时间',
	  `power` 	    	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '总战斗力',
	  `name_1`			varchar(32) NOT NULL DEFAULT '0' COMMENT '队员1',
	  `name_2`			varchar(32) NOT NULL DEFAULT '0' COMMENT '队员2',
	  `name_3`			varchar(32) NOT NULL DEFAULT '0' COMMENT '队员3',
	  `name_4`			varchar(32) NOT NULL DEFAULT '0' COMMENT '队员4',
	  PRIMARY KEY (`rank`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '骑战副本排行表';
#----------------------------------------------------------------------	
	SET lastVersion = 269;
	SET versionNotes = 'add ride dupl';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<270 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	SET lastVersion = 270;
	SET versionNotes = 'alter rank';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<271 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_extra 
    add column `platform_info`  varchar(350) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '平台数据';
#----------------------------------------------------------------------
	SET lastVersion = 271;
	SET versionNotes = 'add platform';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<272 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_extra 
	add column `lastMonthCheckTime`  int(11) NOT NULL DEFAULT 0 ,
    add column `month_count`  varchar(350) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '每月计数';
#----------------------------------------------------------
	SET lastVersion = 272;
	SET versionNotes = 'add month count';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<273 THEN 
#----------------------------------------------------------------------
    DROP TABLE IF EXISTS `tb_player_boss_media`;
	CREATE TABLE `tb_player_boss_media` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `level`			int(11)		NOT NULL DEFAULT '0' COMMENT '等级',
	  `star`			int(11)		NOT NULL DEFAULT '0' COMMENT '星级',
	  `process`			int(11)		NOT NULL DEFAULT '0' COMMENT '进度',
	  `point`			int(11)		NOT NULL DEFAULT '0' COMMENT '总点数',
	  `type_1`			int(11)		NOT NULL DEFAULT '0' COMMENT '类型1',
	  `type_2`			int(11)		NOT NULL DEFAULT '0' COMMENT '类型2',
	  `type_3`			int(11)		NOT NULL DEFAULT '0' COMMENT '类型3',
	  `type_4`			int(11)		NOT NULL DEFAULT '0' COMMENT '类型4',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT 'boss徽章';
#----------------------------------------------------------
	SET lastVersion = 273;
	SET versionNotes = 'add Boss Media';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<274 THEN 
#----------------------------------------------------------
	SET lastVersion = 274;
	SET versionNotes = 'alter mail';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<275 THEN 
#----------------------------------------------------------
	ALTER TABLE `tb_guild` ADD COLUMN `statuscnt` int(11) NOT NULL DEFAULT '0' COMMENT '帮派雕像次数';
#----------------------------------------------------------
	SET lastVersion = 275;
	SET versionNotes = 'alter guild';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<276 THEN 
#----------------------------------------------------------------------
	CREATE TABLE `tb_day_history` (
	  `date_time` varchar(32) NOT NULL DEFAULT '0' COMMENT '日期',
	  `maxonline` int(20) 	NOT NULL DEFAULT '0' COMMENT '人数',
	  PRIMARY KEY (`date_time`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='最大在线表';
#----------------------------------------------------------
	SET lastVersion = 276;
	SET versionNotes = 'add platform';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************

#***************************************************************
#***************************************************************
IF lastVersion<277 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_guild_palace_sign`;
	CREATE TABLE `tb_guild_palace_sign` (
	  `id` 			int(20) 	NOT NULL DEFAULT '0' COMMENT '地宫ID',
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `gold` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名费',
	  `signtime` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名时间',
	  PRIMARY KEY  (`id`,`gid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫报名';
	
	DROP TABLE IF EXISTS `tb_guild_palace`;
	CREATE TABLE `tb_guild_palace` (
	  `id` 			int(20) 	NOT NULL DEFAULT '0' COMMENT '地宫ID',
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `signtime` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名时间',
	  PRIMARY KEY  (`id`,`gid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫城主';
	
#----------------------------------------------------------
	SET lastVersion = 277;
	SET versionNotes = 'add palace';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<278 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------
	SET lastVersion = 278;
	SET versionNotes = 'delete palace sign';
#----------------------------------------------------------
END IF;

#***************************************************************
#***************************************************************
IF lastVersion<279 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_guild_palace`;
	CREATE TABLE `tb_guild_palace` (
	  `id` 			int(20) 	NOT NULL DEFAULT '0' COMMENT '地宫ID',
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `signtime` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名时间',
	  PRIMARY KEY  (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫城主';
#----------------------------------------------------------
	SET lastVersion = 279;
	SET versionNotes = 'alter palace';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<280 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_equips`
	ADD COLUMN `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性';
	
	ALTER TABLE `tb_guild_storage`
	ADD COLUMN `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性';	
	
	ALTER TABLE `tb_consignment_items`
	ADD COLUMN `wash` varchar(64) NOT NULL DEFAULT '0' COMMENT '洗练属性';	
#----------------------------------------------------------
	SET lastVersion = 280;
	SET versionNotes = 'add equip wash';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<281 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_guild_palace_sign`;
	CREATE TABLE `tb_guild_palace_sign` (
	  `id` 			int(11) 	NOT NULL DEFAULT '0' COMMENT '地宫ID',
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `gold` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名费',
	  `signtime` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '报名时间',
	  `sign_state` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '是否返还 0 未返还',
	  PRIMARY KEY  (`id`,`gid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫报名';
	
	DROP TABLE IF EXISTS `tb_guild_palace`;
	CREATE TABLE `tb_guild_palace` (
	  `id` 			int(11) 	NOT NULL DEFAULT '0' COMMENT '地宫ID',
	  `gid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '帮派GUID',
	  `signtime` 	bigint(20) 	NOT NULL DEFAULT '0' COMMENT '城主时间',
	  PRIMARY KEY  (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='帮派地宫城主';
	
#----------------------------------------------------------
	SET lastVersion = 281;
	SET versionNotes = 'alter palace';
#----------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<282 THEN 
#----------------------------------------------------------------------
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_equips`
	ADD COLUMN `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
	ADD COLUMN `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值';
	
	ALTER TABLE `tb_guild_storage`
	ADD COLUMN `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
	ADD COLUMN `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值';
	
	ALTER TABLE `tb_consignment_items`
	ADD COLUMN `newgrouplvl` int(11) NOT NULL DEFAULT '0' COMMENT '新套装等级',
	ADD COLUMN `wash_attr` varchar(128) NOT NULL DEFAULT '0' COMMENT '洗练属性值';

	SET lastVersion = 282;
	SET versionNotes = 'add newgroup lvl wash_attr';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<283 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	ADD COLUMN `soul_hzlevel` int(11) NOT NULL DEFAULT '0' COMMENT '噬魂徽章等级';
#----------------------------------------------------------------------
	SET lastVersion = 283;
	SET versionNotes = 'alter soul_hzlevel';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<284 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_ws_offline_logic`
	ADD COLUMN `save_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '存储时间';
#----------------------------------------------------------------------
	SET lastVersion = 284;
	SET versionNotes = 'add offline logic time';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<285 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_group_charge`;
	CREATE TABLE `tb_group_charge` (
	  `id` 			int(11) 	NOT NULL DEFAULT '0' COMMENT 'ID',
	  `cnt` 		int(11) 	NOT NULL DEFAULT '0' COMMENT '首充人数',
	  `extracnt` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '额外人数',
	  PRIMARY KEY  (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='首充团购表';
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_crossboss_history`;
	CREATE TABLE `tb_crossboss_history` (
		`id` 			int(11) 		NOT NULL DEFAULT '0' COMMENT 'ID',
		`avglv` 		int(11) 		NOT NULL DEFAULT '0' COMMENT '平均等级',
		`firstname1` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '第一玩家',
		`killname1` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '击杀玩家',
		`firstname2` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '第一玩家',
		`killname2` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '击杀玩家',
		`firstname3` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '第一玩家',
		`killname3` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '击杀玩家',
		`firstname4` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '第一玩家',
		`killname4` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '击杀玩家',
		`firstname5` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '第一玩家',
		`killname5` 	varchar(32) 	NOT NULL DEFAULT '' COMMENT '击杀玩家',
	  PRIMARY KEY  (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服BOSS记录表';
#----------------------------------------------------------------------
	SET lastVersion = 285;
	SET versionNotes = 'add group charge and cross boss';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<286 THEN 
#----------------------------------------------------------------------

#----------------------------------------------------------------------
	SET lastVersion = 286;
	SET versionNotes = 'mod platform';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<287 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_zhenbaoge 
	ADD COLUMN `zhenbao_process`   int(11) NOT NULL DEFAULT '0' COMMENT '珍宝进度',
	ADD COLUMN `zhenbao_break_num` int(11) NOT NULL DEFAULT '0' COMMENT '珍宝突破次数';
#----------------------------------------------------------------------
	SET lastVersion = 287; 
	SET versionNotes = 'Add zhenbaoge zhenbao_break_num';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<288 THEN 
#----------------------------------------------------------------------
DROP TABLE IF EXISTS `tb_LastGuildWarMailTime`;
CREATE TABLE `tb_LastGuildWarMailTime` (
	`id`			int(11) 		NOT NULL DEFAULT '0' COMMENT 'id',
	`nLastSendTime`	int(11) 		NOT NULL DEFAULT '0' COMMENT '上次发送时间',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='记录上次帮派战邮件发送时间';
#----------------------------------------------------------------------
	SET lastVersion = 288; 
	SET versionNotes = 'Add LastUpdateGuildMailTime';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<289 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_wingstren`;
	CREATE TABLE `tb_wingstren` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `wing_stren_level` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '翅膀强化星级',
	  `wing_stren_process` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '翅膀强化进度',
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='翅膀强化';
#----------------------------------------------------------------------
	SET lastVersion = 289; 
	SET versionNotes = 'Add tb_wingstren';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<290 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_shengling`;
	CREATE TABLE `tb_player_shengling` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
	  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
	  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
	  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
	  `total_proce` int(11) NOT NULL DEFAULT '0'  COMMENT '总失败次数',
	  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
	
	DROP TABLE IF EXISTS `tb_player_shengling_skin`;
	CREATE TABLE `tb_player_shengling_skin` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `skin_id` int(11) NOT NULL COMMENT '皮肤ID',
	  `skin_time` bigint(20) NOT NULL DEFAULT '0' COMMENT '皮肤到期时间',
	  PRIMARY KEY (`charguid`,`skin_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='圣灵皮肤表';
#----------------------------------------------------------------------
	SET lastVersion = 290; 
	SET versionNotes = 'Add tb_player_shengling';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<291 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	ADD COLUMN `other_money` bigint(20) NOT NULL DEFAULT '0' COMMENT '非充值元宝';
#----------------------------------------------------------------------
	SET lastVersion = 291; 
	SET versionNotes = 'Add charge money';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<292 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_info`
	ADD COLUMN `HBCheatNum` int(11) NOT NULL DEFAULT '0' COMMENT '加速挂次数';
#----------------------------------------------------------------------
	SET lastVersion = 292; 
	SET versionNotes = 'Add cheat num';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<293 THEN 
#----------------------------------------------------------------------
DROP TABLE IF EXISTS `tb_festivalact`;
CREATE TABLE `tb_festivalact` (
	`id`			     int(11) 		NOT NULL DEFAULT '0' COMMENT 'id',
	`festival_param`     int(11) 		NOT NULL DEFAULT '0' COMMENT '节日活动参数',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='节日活动';
#----------------------------------------------------------------------
	SET lastVersion = 293; 
	SET versionNotes = 'Add tb_festivalact';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<294 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_crossarena_history`;
	CREATE TABLE `tb_crossarena_history` (
	  `seasonid` int(11) NOT NULL COMMENT '赛季ID',
	  `arenaid` int(11) NOT NULL DEFAULT '0' COMMENT '竞技ID',
	  `name` varchar(64) NOT NULL DEFAULT '' COMMENT '玩家名字',
	  `prof` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
	  `power` bigint(20) NOT NULL DEFAULT '0' COMMENT '战力',
	  PRIMARY KEY (`seasonid`, `arenaid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='跨服擂台表';
#----------------------------------------------------------------------
	SET lastVersion = 294; 
	SET versionNotes = 'Add tb_crossarena_history';
#----------------------------------------------------------------------
END IF;
IF lastVersion<295 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_shenbing`
	ADD COLUMN `bingling` varchar(300) NOT NULL DEFAULT '' COMMENT '兵灵';
	
	SET lastVersion = 295;
	SET versionNotes = 'alter tb_player_shenbing';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<296 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_merge`;
	CREATE TABLE `tb_merge` (
	  `srvid` 	    	int(11) 	NOT NULL DEFAULT '0' COMMENT '区服ID',
	  `mergeid` 		int(11) 	NOT NULL DEFAULT '0' COMMENT '合服ID',
	  `cnt` 			int(11) 	NOT NULL DEFAULT '0' COMMENT '合服次数',
	  PRIMARY KEY  (`srvid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='合服表';
#----------------------------------------------------------------------
	SET lastVersion = 296; 
	SET versionNotes = 'Add tb_merge';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<297 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_crossarena_xiazhu`;
	CREATE TABLE `tb_crossarena_xiazhu` (
	 `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT '玩家id',
	 `seasonid` 	    int(10) 	NOT NULL DEFAULT '0' COMMENT '赛季ID',
	 `targetguid` 		bigint(20) 	NOT NULL DEFAULT '0' COMMENT '目标玩家guid',
	 `xiazhunum` 		int(11) 	NOT NULL DEFAULT '0' COMMENT '下注金额',
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家下注信息表';
#----------------------------------------------------------------------
	SET lastVersion = 297; 
	SET versionNotes = 'Add tb_crossarena_xiazhu';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<298 THEN 

#----------------------------------------------------------------------
	SET lastVersion = 298; 
	SET versionNotes = 'alter mail';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<299 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_shenwu`;
	CREATE TABLE `tb_player_shenwu` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `shenwu_level` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '神武等级',
	  `shenwu_star` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '神武星级',
	  `shenwu_stone` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '神武成功石',
	  `shenwu_failnum` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '神武升星失败次数',
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='神武';
#----------------------------------------------------------------------
	SET lastVersion = 299; 
	SET versionNotes = 'Add tb_player_shenwu';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<300 THEN 
	ALTER TABLE `tb_player_items`
	ADD COLUMN `param4` bigint(20) NOT NULL DEFAULT '0' COMMENT '物品参数4',
	ADD COLUMN `param5` bigint(20) NOT NULL DEFAULT '0' COMMENT '物品参数5',
	ADD COLUMN `param6` varchar(64) NOT NULL DEFAULT '' COMMENT '物品参数6',
	ADD COLUMN `param7` varchar(64) NOT NULL DEFAULT '' COMMENT '物品参数7';
	
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
	  PRIMARY KEY (`charguid`, `mateguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='婚礼预约表';
	
	CREATE TABLE `tb_player_marry_invite_card` (
	  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
	  `mailGid` bigint(20) NOT NULL DEFAULT '0' COMMENT '邮件Gid',
	  `inviteTime` bigint(20) NOT NULL COMMENT '请帖的时间戳',
	  `scheduleId` int(11) NOT NULL COMMENT '预定时间配置表ID',
	  `inviteRoleName` varchar(32) NOT NULL DEFAULT '' COMMENT '邀请人名字',
	  `inviteMateName` varchar(32) NOT NULL DEFAULT '' COMMENT '邀请人配偶字',
	  `profId` int(11) NOT NULL DEFAULT '0' COMMENT '职业',
	  PRIMARY KEY (`charguid`, `mailGid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='请帖表';
	
#----------------------------------------------------------------------
	SET lastVersion = 300; 
	SET versionNotes = 'add marry';
#----------------------------------------------------------------------
END IF;
#***************************************************************
IF lastVersion<301 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_yuanling`;
	CREATE TABLE `tb_player_yuanling` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
	  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
	  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
	  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
	  `total_proce` int(11) NOT NULL DEFAULT '0'  COMMENT '总失败次数',
	  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
	
#----------------------------------------------------------------------
	SET lastVersion = 301; 
	SET versionNotes = 'Add tb_player_yuanling';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<302 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_Realm_Strenthen`;
	CREATE TABLE `tb_Realm_Strenthen` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `strenthen_id` 	int(11) 	NOT NULL DEFAULT '0' COMMENT '境界巩固id',
	  `select_id`       int(11) 	NOT NULL DEFAULT '0' COMMENT '当前选择境界模型id',
	  `progress` 	    int(11) 	NOT NULL DEFAULT '0' COMMENT '境界巩固进度',
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='境界巩固';
#----------------------------------------------------------------------
	SET lastVersion = 302; 
	SET versionNotes = 'Add tb_Realm_Strenthen';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<303 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_Realm_Strenthen`
	ADD COLUMN `break_id` int(11) NOT NULL DEFAULT '0' COMMENT '巩固突破';
#----------------------------------------------------------------------
	SET lastVersion = 303; 
	SET versionNotes = 'Add break_id';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<304 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_yuanling`
	ADD COLUMN `secs` int(11) NOT NULL DEFAULT '0' COMMENT '在线时间',
	ADD COLUMN `dianshu` int(11) NOT NULL DEFAULT '0' COMMENT '点数',
	ADD COLUMN `dunstate` int(11) NOT NULL DEFAULT '0' COMMENT '盾状态';
#----------------------------------------------------------------------
	SET lastVersion = 304; 
	SET versionNotes = 'Add yuanlingdun';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#----------------------------------------------------------------------
IF lastVersion<305 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_gm_account`;
	CREATE TABLE `tb_gm_account` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `gm_level`		int(11)		NOT NULL DEFAULT '0' COMMENT 'GM等级',
	  `oper`			varchar(32) NOT NULL DEFAULT ''	COMMENT '操作者',
	  `oper_time`		int(11)		NOT NULL DEFAULT '0' COMMENT '操作时间',
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='GM帐号表';
#----------------------------------------------------------------------
	SET lastVersion = 305; 
	SET versionNotes = 'Add tb_gm_account';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#----------------------------------------------------------------------
IF lastVersion<306 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_player_binghun`
	ADD COLUMN `shenghun` varchar(256) NOT NULL DEFAULT '' COMMENT '圣魂',
	ADD COLUMN `shenghun_hole` int(11) NOT NULL DEFAULT '0' COMMENT '圣魂孔';
#----------------------------------------------------------------------
	SET lastVersion = 306; 
	SET versionNotes = 'Add shenghun';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<307 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_ls_horse
    ADD COLUMN `lshorse_attr` int(11) NOT NULL DEFAULT '0'  COMMENT '灵兽坐骑属性丹次数';
#----------------------------------------------------------------------
	SET lastVersion = 307;
	SET versionNotes = 'Modify lshorse attrdan';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<308 THEN 
#----------------------------------------------------------------------
    ALTER TABLE tb_player_info
    ADD COLUMN `wash_lucky` int(11) NOT NULL DEFAULT '0'  COMMENT '';
#----------------------------------------------------------------------
	SET lastVersion = 308;
	SET versionNotes = 'Modify wash luck';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<309 THEN 
#----------------------------------------------------------------------
	SET lastVersion = 309;
	SET versionNotes = 'change name';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<310 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_lunpan`;
	CREATE TABLE `tb_player_lunpan` (
	  `charguid` 	    bigint(20) 	 NOT NULL DEFAULT '0' COMMENT 'guid',
	  `lunpan_attr`		varchar(128) NOT NULL DEFAULT '' COMMENT '轮盘属性',
	  `lunpan_num`      int(11)      NOT NULL DEFAULT '0'  COMMENT '轮盘今日次数', 
	  PRIMARY KEY  (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='轮盘';
#----------------------------------------------------------------------
	SET lastVersion = 310; 
	SET versionNotes = 'Add tb_player_lunpan';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<311 THEN 
#----------------------------------------------------------------------
	CREATE TABLE `tb_player_equip_pos` (
	  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
	  `pos` int(11) NOT NULL COMMENT '装备位',
	  `idx` int(11) NOT NULL COMMENT '位置',
	  `groupid` int(11) NOT NULL COMMENT '套装ID',	  
	  `lvl` int(11) NOT NULL COMMENT '套装等级',	  
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳', 	  
	  PRIMARY KEY (`charguid`, `pos`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备位套装';
	
#----------------------------------------------------------------------
	SET lastVersion = 311;
	SET versionNotes = 'add tb_player_equip_pos';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<312 THEN 
#----------------------------------------------------------------------
    CREATE TABLE `tb_player_wuxing_pro` (
	  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
	  `lv` int(11) NOT NULL DEFAULT '0' COMMENT '五行等阶',
	  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '进度', 	  
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='五行升阶信息表';
#----------------------------------------------------------------------
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
	  PRIMARY KEY (`charguid`, `itemgid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='五行物品表';
#----------------------------------------------------------------------
	SET lastVersion = 312;
	SET versionNotes = 'add wuxing';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<313 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_equip_pos`;
	CREATE TABLE `tb_player_equip_pos` (
	  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
	  `pos` int(11) NOT NULL COMMENT '装备位',
	  `idx` int(11) NOT NULL COMMENT '位置',
	  `groupid` int(11) NOT NULL COMMENT '套装ID',	  
	  `lvl` int(11) NOT NULL COMMENT '套装等级',	  
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳', 	  
	  PRIMARY KEY (`charguid`, `pos`, `idx`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='装备位套装';
	
#----------------------------------------------------------------------
	SET lastVersion = 313;
	SET versionNotes = 'alter tb_player_equip_pos';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
IF lastVersion<314 THEN 
#----------------------------------------------------------------------
	ALTER TABLE `tb_arena_att`
	ADD COLUMN `parryrate` double NOT NULL DEFAULT '0',
	ADD COLUMN `supper` double NOT NULL DEFAULT '0',
	ADD COLUMN `suppervalue` double NOT NULL DEFAULT '0';
#----------------------------------------------------------------------	
	CREATE TABLE `tb_app_hang` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0',
	  `taskid` 	bigint(20) 	NOT NULL DEFAULT '0' ,
	  `mapid`       int(11) 	NOT NULL DEFAULT '0' ,
	  `monsterid` 	    int(11) 	NOT NULL DEFAULT '0' ,
	  `start` 	    int(11) 	NOT NULL DEFAULT '0' ,
	  `end` 	    int(11) 	NOT NULL DEFAULT '0',
	  `isget` 	    int(11) 	NOT NULL DEFAULT '0',
	  `status` 	    int(11) 	NOT NULL DEFAULT '0',
	  `exp`  bigint(20) NOT NULL ,
	  `gold`  bigint(20) NOT NULL ,
	  `item` varchar(4096) NOT NULL DEFAULT '',
	  `lastchecktime` 	    int(11) 	NOT NULL DEFAULT '0',
	  PRIMARY KEY  (`charguid`, `taskid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
#----------------------------------------------------------------------
	SET lastVersion = 314;
	SET versionNotes = 'Add arena att';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<315 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_rank_ride_dupl
	ADD COLUMN `type` int(11) NOT NULL DEFAULT '21'  COMMENT '副本类型',
	drop primary key,
	add primary key(`type`, `rank`);
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_challenge_dupl`;
	CREATE TABLE `tb_player_challenge_dupl` (
	  `charguid` 	    bigint(20) 	NOT NULL DEFAULT '0' COMMENT 'guid',
	  `count`			int(11)		NOT NULL DEFAULT '0' COMMENT '今日次数',
	  `today`			int(11)		NOT NULL DEFAULT '0' COMMENT '今日层数',
	  `history`			int(11)		NOT NULL DEFAULT '0' COMMENT '历史层数',	
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '挑战副本表';
#----------------------------------------------------------------------
	SET lastVersion = 315;
	SET versionNotes = 'add challenge rank';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<316 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_extra
	ADD COLUMN `marrystren` int(11) NOT NULL DEFAULT '0'  COMMENT '婚戒强化等级',
	ADD COLUMN `marrystrenwish` int(11) NOT NULL DEFAULT '0'  COMMENT '婚戒强化祝福值';
#----------------------------------------------------------------------
	SET lastVersion = 316;
	SET versionNotes = 'add marry ring att';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<317 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_shouhun`;
	CREATE TABLE `tb_player_shouhun` (
	  `charguid` bigint(20) NOT NULL COMMENT '玩家id',
	  `shouhun_id` int(11) NOT NULL COMMENT '兽魂id',
	  `shouhun_level` int(11) NOT NULL COMMENT '兽魂等级',
	  `shouhun_star` int(11) NOT NULL COMMENT '兽魂星级',
	  `time_stamp` bigint(20) NOT NULL DEFAULT '0' COMMENT '时间戳',
	  PRIMARY KEY (`charguid`, `shouhun_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兽魂';

#----------------------------------------------------------------------
    DROP TABLE IF EXISTS `tb_player_shouhunlv`;
    CREATE TABLE `tb_player_shouhunlv` (
	  `charguid`         bigint(20) NOT NULL COMMENT '玩家id',
	  `shouhun_maxlv`    int(11) NOT NULL DEFAULT '0' COMMENT '兽魂最大等阶',
	  `shouhun_commonlv` int(11) NOT NULL DEFAULT '0' COMMENT '兽魂所有等级',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='兽魂升级表';
#----------------------------------------------------------------------
	SET lastVersion = 317;
	SET versionNotes = 'alter shouhun';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<318 THEN 
#----------------------------------------------------------------------
	DROP TABLE IF EXISTS `tb_player_zhannu`;
	CREATE TABLE `tb_player_zhannu` (
	  `charguid` bigint(20) NOT NULL COMMENT '角色GUID',
	  `level` int(11) NOT NULL DEFAULT '0' COMMENT '当前等阶',
	  `process` int(11) NOT NULL DEFAULT '0' COMMENT '进度',
	  `sel` int(11) NOT NULL DEFAULT '0' COMMENT '当前切换圣灵',
	  `proce_num` int(11) NOT NULL DEFAULT '0' COMMENT '失败次数',
	  `total_proce` int(11) NOT NULL DEFAULT '0'  COMMENT '总失败次数',
	  `attrdan` int(11) NOT NULL DEFAULT '0' COMMENT '属性丹数量',
	  PRIMARY KEY (`charguid`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生灵表';
	
#----------------------------------------------------------------------
	SET lastVersion = 318; 
	SET versionNotes = 'Add tb_player_zhannu';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<319 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_wuxing_pro
	ADD COLUMN `attrdan` int(11) NOT NULL DEFAULT '0'  COMMENT '属性丹数量';
#----------------------------------------------------------------------
	SET lastVersion = 319;
	SET versionNotes = 'add wuxing attrdan';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
IF lastVersion<320 THEN 
#----------------------------------------------------------------------
	ALTER TABLE tb_player_extra
    CHANGE COLUMN `actcode_flags` `actcode_flags` varchar(512) NOT NULL DEFAULT ''  COMMENT '激活码标识';
#----------------------------------------------------------------------
	SET lastVersion = 320;
	SET versionNotes = 'alter actcode';
#----------------------------------------------------------------------
END IF;
#***************************************************************
#***************************************************************
##++++++++++++++++++++表格修改完成++++++++++++++++++++++++++++++

IF lastVersion > lastVersion1 THEN 
	INSERT INTO tb_database_version(version, updateDate, lastSql) values(lastVersion, now(), versionNotes);
END IF;
END
;;
DELIMITER ;
call updateSql ();
DROP PROCEDURE IF EXISTS `updateSql`;

#↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
################################################################################
###############################过程修改开始#####################################
DELIMITER ;;

#***************************************************************
##版本201修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_guild_boss_select()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_guild_boss_select`;
CREATE PROCEDURE `sp_guild_boss_select`()
BEGIN
	SELECT * FROM tb_guild_boss;
END;;
-- ----------------------------
-- Procedure structure for sp_update_guild_boss()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_boss`;
CREATE PROCEDURE `sp_update_guild_boss`(IN `in_gid` bigint, IN `in_boss_time` bigint)
BEGIN
	INSERT INTO tb_guild_boss(gid, boss_time)
 	VALUES (in_gid, in_boss_time)
 	ON DUPLICATE KEY UPDATE boss_time = in_boss_time;
END;;
#***************************************************************
##版本201修改完成
#***************************************************************
#***************************************************************
##版本202修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;
CREATE PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum;
END;;
#***************************************************************
##版本202修改完成
#***************************************************************
#***************************************************************
##版本203修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_rank_shenbing()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_shenbing`;
CREATE PROCEDURE `sp_select_rank_shenbing`()
BEGIN
	SELECT * FROM tb_rank_shenbing;
END;;

-- ----------------------------
-- Procedure structure for sp_update_rank_shenbing()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_rank_shenbing`;
CREATE PROCEDURE `sp_update_rank_shenbing`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_shenbing(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END;;

-- ----------------------------
-- Procedure structure for sp_rank_shenbing()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_shenbing`;
CREATE PROCEDURE `sp_rank_shenbing`()
BEGIN
	SELECT charguid AS uid, shenbingid AS rankvalue FROM tb_player_info WHERE shenbingid > 0 ORDER BY shenbingid DESC LIMIT 100;
END;;

-- ----------------------------
-- Procedure structure for sp_select_rank_human_info_base()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_base`;
CREATE PROCEDURE `sp_select_rank_human_info_base`(IN `in_id` bigint)
BEGIN
	SELECT charguid, name, prof, level, hp, mp, power, vip_level, sex, dress, 
	arms, head, suit, weapon, hunli, tipo, shenfa, jingshen, vplan, wingid, 
	shenbingid
	FROM tb_player_info WHERE charguid = in_id;
END;;
#***************************************************************
##版本203修改完成
#***************************************************************
#***************************************************************
##版本204修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_vip_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vip_select_by_id`;
CREATE PROCEDURE `sp_player_vip_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_vip WHERE in_charguid = charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_player_vip_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update`;
CREATE PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` int, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3)
	VALUES (in_charguid,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3;
END;;

#***************************************************************
##版本204修改完成
#***************************************************************
#***************************************************************
##版本205修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_ride
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_ride`;
CREATE PROCEDURE `sp_insert_update_ride`(IN `in_charguid` bigint, IN `in_step` int, IN `in_select` int, IN `in_state` int, IN `in_process` int,
			IN `in_attrdan` int, IN `in_proce_num` int, IN `in_total_proce` int, IN `in_fh_zhenqi` int)
BEGIN
	INSERT INTO tb_ride(charguid, ride_step, ride_select, ride_state, ride_process, attrdan, proce_num, total_proce,fh_zhenqi)
	VALUES (in_charguid, in_step, in_select, in_state, in_process, in_attrdan,in_proce_num, in_total_proce,in_fh_zhenqi)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ride_step=in_step, ride_select = in_select, ride_state = in_state, ride_process = in_process, 
		attrdan=in_attrdan, proce_num=in_proce_num, total_proce=in_total_proce, fh_zhenqi=in_fh_zhenqi;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_wuhuns_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuhuns_insert_update`;
CREATE PROCEDURE `sp_player_wuhuns_insert_update`(IN `in_charguid` bigint, IN `in_wuhun_id` int, IN `in_wuhun_wish` int, IN `in_trytime` int, IN `in_cur_hunzhu` int
, IN `in_wuhun_progress` int, IN `in_feed_num` int, IN `in_wuhun_state` int, IN `in_wuhun_sp` int,IN `in_cur_shenshou` int,IN `in_shenshou_data` varchar(128),IN `in_total_proce_num` int,IN `in_fh_item_num` int)
BEGIN
  INSERT INTO tb_player_wuhuns(charguid, wuhun_id, wuhun_wish, trytime, cur_hunzhu, wuhun_progress, feed_num, wuhun_state, wuhun_sp, cur_shenshou, shenshou_data, total_proce_num, fh_item_num)
  VALUES (in_charguid, in_wuhun_id, in_wuhun_wish, in_trytime, in_cur_hunzhu, in_wuhun_progress, in_feed_num, in_wuhun_state, in_wuhun_sp, in_cur_shenshou, in_shenshou_data, in_total_proce_num, in_fh_item_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, wuhun_id=in_wuhun_id, wuhun_wish=in_wuhun_wish, trytime=in_trytime, cur_hunzhu=in_cur_hunzhu, wuhun_progress=in_wuhun_progress, feed_num=in_feed_num
  , wuhun_state=in_wuhun_state, wuhun_sp=in_wuhun_sp, cur_shenshou = in_cur_shenshou, shenshou_data = in_shenshou_data, total_proce_num = in_total_proce_num, fh_item_num = in_fh_item_num;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_refinery_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_refinery_insert_update`;
CREATE PROCEDURE `sp_player_refinery_insert_update`(IN `in_gid` bigint,  IN `in_id` varchar(256),IN `in_cost_zhenqi` int,IN `in_fh_cost_zhenqi` int)
BEGIN
	INSERT INTO tb_player_refinery(charguid, id, cost_zhenqi, fh_cost_zhenqi)
	VALUES (in_gid, in_id, in_cost_zhenqi, in_fh_cost_zhenqi) 
	ON DUPLICATE KEY UPDATE charguid=in_gid, id=in_id,cost_zhenqi=in_cost_zhenqi, fh_cost_zhenqi=in_fh_cost_zhenqi;
END ;;

#***************************************************************
##版本205修改完成
#***************************************************************
#***************************************************************
##版本206修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_homeland`;
CREATE PROCEDURE `sp_select_player_homeland`(In `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_homeland WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_homeland`;
CREATE PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
	IN `in_xunxian` int, IN `in_rob` int, IN `in_rob_cd` int, IN `in_xunxian_ref` int, IN `in_xunxian_cnt` int, IN `in_quest_ref` int)
BEGIN
	INSERT INTO tb_player_homeland(charguid, main_lv, quest_lv, xunxian_lv, rob_cnt, rob_cd, xunxian_ref, xunxian_cnt, quest_ref)
	VALUES (in_charguid, in_main, in_quest, in_xunxian, in_rob, in_rob_cd, in_xunxian_ref, in_xunxian_cnt, in_quest_ref) 
	ON DUPLICATE KEY UPDATE main_lv = in_main, quest_lv = in_quest, xunxian_lv = in_xunxian, 
		rob_cnt = in_rob, rob_cd = in_rob_cd, xunxian_ref = in_xunxian_ref, xunxian_cnt = in_xunxian_cnt, quest_ref = in_quest_ref;
END;;
-- ----------------------------
-- Procedure structure for sp_load_all_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_load_all_hl_quest`;
CREATE PROCEDURE `sp_load_all_hl_quest`()
BEGIN
	SELECT * FROM tb_homeland_quest;
END;;
-- ----------------------------
-- Procedure structure for sp_update_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_hl_quest`;
CREATE PROCEDURE `sp_update_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_power` bigint, IN `in_level` int, IN `in_name` int,
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
		status = in_status, mon_1 = in_mon_1, mon_2 = in_mon_2, mon_3 = in_mon_3, item_id = in_item_id,
		reward_type = in_reward_type, reward = in_reward, exp = in_exp, disciple_1 = in_dis_1, disciple_2 = in_dis_2, disciple_3 = in_dis_3;
END;;
-- ----------------------------
-- Procedure structure for sp_del_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_del_hl_quest`;
CREATE PROCEDURE `sp_del_hl_quest`(IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_homeland_quest WHERE gid = in_gid;
END;;
-- ----------------------------
-- Procedure structure for sp_select_player_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_hl_quest`;
CREATE PROCEDURE `sp_select_player_hl_quest`(In `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_hl_quest WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_hl_quest`;
CREATE PROCEDURE `sp_update_player_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_tid` int, 
	IN `in_need_time` int, IN `in_quality` int, IN `in_level` int,IN `in_mon_1` int, IN `in_mon_2` int, 
	IN `in_mon_3` int, IN `in_item_id` int, IN `in_reward_type` int, IN `in_reward` bigint, IN `in_exp` bigint)
BEGIN
	INSERT INTO tb_player_hl_quest(gid, charguid, tid,
	 				need_time, quality, level, mon_1, mon_2, 
	 				mon_3, item_id, reward_type, reward, exp)
	VALUES (in_gid, in_charguid, in_tid,
		in_need_time, in_quality, in_level, in_mon_1, in_mon_2,
		in_mon_3, in_item_id, in_reward_type, in_reward, in_exp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, tid = in_tid,
			need_time = in_need_time, quality = in_quality, level = in_level, mon_1 = in_mon_1, mon_2 = in_mon_2, 
			mon_3 = in_mon_3, item_id = in_item_id, reward_type = in_reward_type, reward = in_reward, exp = in_exp;
END;;
-- ----------------------------
-- Procedure structure for sp_del_player_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_del_player_hl_quest`;
CREATE PROCEDURE `sp_del_player_hl_quest`(IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_player_hl_quest WHERE gid = in_gid;
END;;
-- ----------------------------
-- Procedure structure for sp_select_player_disciple
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_disciple`;
CREATE PROCEDURE `sp_select_player_disciple`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_disciple WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_remove_disciple
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_remove_disciple`;
CREATE PROCEDURE `sp_remove_disciple`(IN `in_charguid` bigint, IN `in_status` int)
BEGIN
	DELETE FROM tb_player_disciple WHERE charguid = in_charguid AND status = in_status;
END;;
-- ----------------------------
-- Procedure structure for sp_del_disciple
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_del_disciple`;
CREATE PROCEDURE `sp_del_disciple`(IN `in_gid` bigint)
BEGIN
	DELETE FROM tb_player_disciple WHERE gid = in_gid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_disciple
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_disciple`;
CREATE PROCEDURE `sp_update_disciple`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_quality` int, IN `in_name` varchar(32),
	IN `in_skill_1` int, IN `in_skill_2` int, IN `in_skill_3` int, IN `in_level` int, IN `in_exp` int, IN `in_icon` int, IN `in_attr` int,
	IN `in_status` int)
BEGIN
	INSERT INTO tb_player_disciple(gid, charguid, quality, name, skill_1, skill_2, skill_3, level, exp, icon, attr, status)
	VALUES (in_gid, in_charguid,in_quality, in_name, in_skill_1, in_skill_2, in_skill_3, in_level, in_exp, in_icon,in_attr,in_status) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, quality = in_quality, name = in_name, skill_1 = in_skill_1, 
		skill_2 = in_skill_2, skill_3 = in_skill_3, level = in_level, exp = in_exp, icon = in_icon, attr = in_attr, status = in_status;
END;;
#***************************************************************
##版本206修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_platform_select_role_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_platform_select_role_info`;
CREATE PROCEDURE `sp_platform_select_role_info`(IN `in_account` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account;
END;;
DROP PROCEDURE IF EXISTS `sp_update_forbidden_acc_by_acc`;
CREATE PROCEDURE `sp_update_forbidden_acc_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_acc_last` int, IN `in_forb_acc_time` int)
BEGIN
	UPDATE tb_account SET  forb_acc_last = in_forb_acc_last, forb_acc_time = in_forb_acc_time
	WHERE account = in_account;
END;;
DROP PROCEDURE IF EXISTS `sp_update_forbidden_chat_by_acc`;
CREATE PROCEDURE `sp_update_forbidden_chat_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_chat_last` int, IN `in_forb_chat_time` int)
BEGIN
	UPDATE tb_account SET  forb_chat_last = in_forb_chat_last, forb_chat_time = in_forb_chat_time
	WHERE account = in_account;
END;;
#***************************************************************
##版本207修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_info_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_info_insert_update`;
CREATE PROCEDURE `sp_player_info_insert_update`(IN `in_id` bigint,  IN `in_name` varchar(32), IN `in_level` int, IN `in_exp` bigint, IN `in_vip_level` int, IN `in_vip_exp` int,
				IN `in_power` bigint, IN `in_hp` int, IN `in_mp` int, IN `in_hunli` int, IN `in_tipo` int, IN `in_shenfa` int, IN `in_jingshen` int, 
				IN `in_leftpoint` int, IN `in_totalpoint` int, IN `in_sp` int, IN `in_max_sp` int, IN `in_sp_recover` int, IN `in_bindgold` bigint, 
				IN `in_unbindgold` bigint, IN `in_bindmoney` bigint, IN `in_unbindmoney` bigint, IN `in_zhenqi` int, IN `in_soul` int, IN `in_pk_mode` int, IN `in_pk_status` int,
				IN `in_pk_flags` int,IN `in_pk_evil` int,IN `in_redname_time` bigint, IN `in_grayname_time` bigint, IN `in_pk_count` int, IN `in_yao_hun` int,
				IN `in_arms` int, IN `in_dress` int, IN `in_online_time` int, IN `in_head` int, IN `in_suit` int, IN `in_weapon` int, IN `in_drop_val` int, IN `in_drop_lv` int, 
				IN `in_killtask_count` int, IN `in_onlinetime_day` int, IN `in_honor` int, IN `in_hearthstone_time` bigint, IN `in_lingzhi` int, IN `in_jingjie_exp` int, IN `in_vplan` int,
				IN `in_blesstime` bigint,IN `in_equipval` bigint, IN `in_wuhunid` int, IN `in_shenbingid` int,IN `in_extremityval` bigint, IN `in_wingid` int,
				IN `in_blesstime2` bigint,IN `in_blesstime3` bigint, IN `in_suitflag` int, IN `in_crossscore` int, IN `in_crossexploit` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit;
END;;

-- ----------------------------
-- Procedure structure for sp_select_player_info_by_ls
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_info_by_ls`;
CREATE PROCEDURE `sp_select_player_info_by_ls`(IN `in_guid` bigint)
BEGIN
	SELECT name, level, prof, iconid, power, vip_level, head, suit, weapon, wingid, suitflag
	FROM tb_player_info 
	WHERE in_guid = charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_select_rank_human_info_base
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_base`;
CREATE PROCEDURE `sp_select_rank_human_info_base`(IN `in_id` bigint)
BEGIN
	SELECT charguid, name, prof, level, hp, mp, power, vip_level, sex, dress, 
	arms, head, suit, weapon, hunli, tipo, shenfa, jingshen, vplan, wingid, shenbingid, suitflag
	FROM tb_player_info WHERE charguid = in_id;
END;;

-- ----------------------------
-- Procedure structure for sp_select_simple_user_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_simple_user_info`;
CREATE PROCEDURE `sp_select_simple_user_info`(IN `in_guid` bigint)
BEGIN
	SELECT tb_player_info.charguid as charguid, name, prof, iconid, 
	level, power, arms, dress, head, suit, weapon, valid, 
	forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, 
	UNIX_TIMESTAMP(tb_account.last_logout) as last_logout, account, vip_level, vplan, wuhunid, shenbingid, wingid, suitflag from tb_player_info 
	left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	where tb_player_info.charguid = in_guid;
END;;

-- ----------------------------
-- Procedure structure for sp_select_ws_human_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_ws_human_info`;
CREATE PROCEDURE `sp_select_ws_human_info`(IN `in_charguid` bigint)
BEGIN
	SELECT P.charguid,P.level,P.name,P.prof,P.blesstime, M.base_map,M.game_map,P.blesstime2,P.blesstime3
	FROM tb_player_info AS P,tb_player_map_info AS M where in_charguid = P.charguid AND in_charguid = M.charguid;
END;;

#***************************************************************
##版本207修改完成
#***************************************************************
#***************************************************************
##版本208修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_homeland`;
CREATE PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
	IN `in_xunxian` int, IN `in_rob` int, IN `in_rob_cd` int, IN `in_xunxian_ref` int, IN `in_xunxian_cnt` int,
	IN `in_quest_ref` int, IN `in_buy_cnt` int)
BEGIN
	INSERT INTO tb_player_homeland(charguid, main_lv, quest_lv, xunxian_lv, rob_cnt, rob_cd, xunxian_ref, xunxian_cnt, quest_ref, buy_cnt)
	VALUES (in_charguid, in_main, in_quest, in_xunxian, in_rob, in_rob_cd, in_xunxian_ref, in_xunxian_cnt, in_quest_ref, in_buy_cnt) 
	ON DUPLICATE KEY UPDATE main_lv = in_main, quest_lv = in_quest, xunxian_lv = in_xunxian, 
		rob_cnt = in_rob, rob_cd = in_rob_cd, xunxian_ref = in_xunxian_ref, xunxian_cnt = in_xunxian_cnt, quest_ref = in_quest_ref, buy_cnt = in_buy_cnt;
END;;
#***************************************************************
##版本208修改完成
#***************************************************************
#***************************************************************
##版本209修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_vip_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update`;
CREATE PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` int, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_exp,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3)
	VALUES (in_charguid,in_vip_exp,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_exp=in_vip_exp,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3;
END;;

#***************************************************************
##版本209修改完成
#***************************************************************
#***************************************************************
##版本210修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_hl_quest`;
CREATE PROCEDURE `sp_update_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_power` bigint, IN `in_level` int, IN `in_name` varchar(32),
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
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_homeland`;
CREATE PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
	IN `in_xunxian` int, IN `in_rob` int, IN `in_rob_cd` int, IN `in_xunxian_ref` int, IN `in_xunxian_cnt` int,
	IN `in_quest_ref` int, IN `in_rob_cnt_cd` int)
BEGIN
	INSERT INTO tb_player_homeland(charguid, main_lv, quest_lv, xunxian_lv, rob_cnt, rob_cd, xunxian_ref, xunxian_cnt, quest_ref, rob_cnt_cd)
	VALUES (in_charguid, in_main, in_quest, in_xunxian, in_rob, in_rob_cd, in_xunxian_ref, in_xunxian_cnt, in_quest_ref, in_rob_cnt_cd) 
	ON DUPLICATE KEY UPDATE main_lv = in_main, quest_lv = in_quest, xunxian_lv = in_xunxian, 
		rob_cnt = in_rob, rob_cd = in_rob_cd, xunxian_ref = in_xunxian_ref, xunxian_cnt = in_xunxian_cnt, quest_ref = in_quest_ref, rob_cnt_cd = in_rob_cnt_cd;
END;;
#***************************************************************
##版本210修改完成
#***************************************************************
#***************************************************************
##版本211修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_hl_quest`;
CREATE PROCEDURE `sp_update_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_power` bigint, IN `in_level` int, IN `in_name` varchar(32),
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
END;;
#***************************************************************
##版本211修改完成
#***************************************************************
#***************************************************************
##版本212修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_mail_content_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_mail_content_insert_update`;
CREATE PROCEDURE `sp_mail_content_insert_update`(IN `in_mailgid` bigint, IN `in_refflag` tinyint, IN `in_title` varchar(50), IN `in_content` varchar(512), IN `in_sendtime` bigint, IN `in_validtime` bigint, 
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
END;;
#***************************************************************
##版本212修改完成
#***************************************************************
#***************************************************************
##版本213修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_activity_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_activity_update`;
CREATE PROCEDURE `sp_activity_update`(IN `in_charguid` bigint, IN `in_act` int, IN `in_cnt` int, IN `in_last` bigint, IN `in_flags` int, IN `in_online_time` bigint, IN `in_param` varchar(64))
BEGIN
	INSERT INTO tb_activity(charguid, activity, join_count, last_join, flags, online_time, param)
	VALUES (in_charguid, in_act, in_cnt, in_last, in_flags, in_online_time, in_param)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, activity = in_act, join_count = in_cnt, last_join = in_last, flags = in_flags, online_time = in_online_time, param = in_param;
END;;
#***************************************************************
##版本213修改完成
#***************************************************************
#***************************************************************
##版本214修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_player_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_hl_quest`;
CREATE PROCEDURE `sp_update_player_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint, IN `in_tid` int, 
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
END;;
-- ----------------------------
-- Procedure structure for sp_del_player_hl_quest
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_del_player_hl_quest`;
CREATE PROCEDURE `sp_del_player_hl_quest`(IN `in_gid` bigint, IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_hl_quest WHERE gid = in_gid and charguid = in_charguid;
END;;
#***************************************************************
##版本214修改完成
#***************************************************************
#***************************************************************
##版本215修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_guild_mems
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_guild_mems`;
CREATE PROCEDURE `sp_insert_update_guild_mems`(IN `in_charguid` bigint, IN `in_gid` bigint, IN `in_flags` bigint, IN `in_time` bigint, 
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
END;;

-- ----------------------------
-- Procedure structure for sp_dimiss_guild
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_dimiss_guild`;
CREATE PROCEDURE `sp_dimiss_guild`(IN `in_guid` bigint)
BEGIN
	DELETE FROM tb_guild WHERE gid = in_guid;
	UPDATE tb_guild_mem SET gid = 0, allcontribute = 0, loyalty = 0 WHERE gid = in_guid;
	DELETE FROM tb_guild_event WHERE guid = in_guid;
	DELETE FROM tb_guild_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_aliance_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_hell WHERE gid = in_guid;
	DELETE FROM tb_guild_storage WHERE gid = in_guid;
	DELETE FROM tb_guild_storage_op WHERE gid = in_guid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_info_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_info_insert_update`;
CREATE PROCEDURE `sp_player_info_insert_update`(IN `in_id` bigint,  IN `in_name` varchar(32), IN `in_level` int, IN `in_exp` bigint, IN `in_vip_level` int, IN `in_vip_exp` int,
				IN `in_power` bigint, IN `in_hp` int, IN `in_mp` int, IN `in_hunli` int, IN `in_tipo` int, IN `in_shenfa` int, IN `in_jingshen` int, 
				IN `in_leftpoint` int, IN `in_totalpoint` int, IN `in_sp` int, IN `in_max_sp` int, IN `in_sp_recover` int, IN `in_bindgold` bigint, 
				IN `in_unbindgold` bigint, IN `in_bindmoney` bigint, IN `in_unbindmoney` bigint, IN `in_zhenqi` int, IN `in_soul` int, IN `in_pk_mode` int, IN `in_pk_status` int,
				IN `in_pk_flags` int,IN `in_pk_evil` int,IN `in_redname_time` bigint, IN `in_grayname_time` bigint, IN `in_pk_count` int, IN `in_yao_hun` int,
				IN `in_arms` int, IN `in_dress` int, IN `in_online_time` int, IN `in_head` int, IN `in_suit` int, IN `in_weapon` int, IN `in_drop_val` int, IN `in_drop_lv` int, 
				IN `in_killtask_count` int, IN `in_onlinetime_day` int, IN `in_honor` int, IN `in_hearthstone_time` bigint, IN `in_lingzhi` int, IN `in_jingjie_exp` int, IN `in_vplan` int,
				IN `in_blesstime` bigint,IN `in_equipval` bigint, IN `in_wuhunid` int, IN `in_shenbingid` int,IN `in_extremityval` bigint, IN `in_wingid` int,
				IN `in_blesstime2` bigint,IN `in_blesstime3` bigint, IN `in_suitflag` int, IN `in_crossscore` int, IN `in_crossexploit` int, IN `in_crossseasonid` int, 
				IN `in_pvplevel` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, pvplevel)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid, in_pvplevel) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel;
END;;

-- ----------------------------
-- Procedure structure for sp_select_rank_crossscore()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_crossscore`;
CREATE PROCEDURE `sp_select_rank_crossscore`()
BEGIN
	SELECT * FROM tb_rank_crossscore;
END;;

-- ----------------------------
-- Procedure structure for sp_update_rank_crossscore()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_rank_crossscore`;
CREATE PROCEDURE `sp_update_rank_crossscore`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_lastrank` int, IN `in_rankvalue` bigint)
BEGIN
	INSERT INTO tb_rank_crossscore(rank, charguid, lastrank, rankvalue)
	VALUES (in_rank, in_charguid, in_lastrank, in_rankvalue)
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, lastrank = in_lastrank, rankvalue = in_rankvalue;
END;;

-- ----------------------------
-- Procedure structure for sp_rank_crossscore()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_crossscore`;
CREATE PROCEDURE `sp_rank_crossscore`(IN `in_curseasonid` int)
BEGIN
	SELECT charguid AS uid, pvplevel AS rankvalue FROM tb_player_info 
	WHERE pvplevel > 0 and crossscore > 0 and crossseasonid = in_curseasonid 
	ORDER BY pvplevel ASC , crossscore DESC, power DESC LIMIT 100;
END;;

-- ----------------------------
-- Procedure structure for sp_rank_pvplevel()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_pvplevel`;
CREATE PROCEDURE `sp_rank_pvplevel`(IN `in_curseasonid` int, IN `in_pvplevel` int, IN `in_limit` int)
BEGIN
	SELECT charguid, pvplevel, crossscore, power FROM tb_player_info 
	WHERE crossscore > 0 and crossseasonid = in_curseasonid and pvplevel = in_pvplevel
	ORDER BY crossscore DESC, power DESC LIMIT in_limit;
END;;

-- ----------------------------
-- Procedure structure for sp_select_all_pvphistory()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_all_pvphistory`;
CREATE PROCEDURE `sp_select_all_pvphistory`()
BEGIN
	SELECT * FROM tb_pvp_season_history;
END;;

-- ----------------------------
-- Procedure structure for sp_insert_or_update_pvphistory()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_or_update_pvphistory`;
CREATE PROCEDURE `sp_insert_or_update_pvphistory`(IN `in_seasonid` int, IN `in_rank` int, IN `in_charguid` bigint, IN `in_groupid` int,
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
END;;

-- ----------------------------
-- Procedure structure for sp_select_player_pvp_info_by_id()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_pvp_info_by_id`;
CREATE PROCEDURE `sp_select_player_pvp_info_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_crosspvp WHERE charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_insert_or_update_player_pvp_info()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_or_update_player_pvp_info`;
CREATE PROCEDURE `sp_insert_or_update_player_pvp_info`(IN `in_charguid` bigint, IN `in_curcnt` int, IN `in_totalcnt` int, IN `in_wincnt` int,
IN `in_contwincnt` int, IN `in_flags` int)
BEGIN
	INSERT INTO tb_player_crosspvp(charguid, curcnt, totalcnt, wincnt, contwincnt, flags)
	VALUES (in_charguid, in_curcnt, in_totalcnt, in_wincnt, in_contwincnt, in_flags) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, curcnt=in_curcnt, totalcnt = in_totalcnt, 
	wincnt = in_wincnt, contwincnt = in_contwincnt, flags = in_flags;
END;;


#***************************************************************
##版本215修改完成
#***************************************************************
#***************************************************************
##版本216修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_prerogative
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_prerogative`;
CREATE PROCEDURE `sp_select_player_prerogative`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_prerogative WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_prerogative
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_prerogative`;
CREATE PROCEDURE `sp_update_player_prerogative`(IN `in_charguid` bigint, IN `in_type` int, IN `in_param_32` int, IN `in_param_64` bigint)
BEGIN
	INSERT INTO tb_player_prerogative(charguid, prerogative, param_32, param_64)
	VALUES (in_charguid, in_type, in_param_32, in_param_64) 
	ON DUPLICATE KEY UPDATE param_32 = in_param_32, param_64 = in_param_64;
END;;

#***************************************************************
##版本216修改开始
#***************************************************************
#***************************************************************
##版本217修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_binghun_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_binghun_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_binghun_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_binghun` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;
-- ----------------------------
-- Procedure structure for sp_player_binghun_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_binghun_insert_update`;
CREATE PROCEDURE `sp_player_binghun_insert_update`(IN `in_charguid` bigint, IN `in_id` int, IN `in_state` int, IN `in_current` int,IN `in_activetime` bigint,IN `in_time_stamp` bigint)
BEGIN
  INSERT INTO tb_player_binghun(charguid, id, state, current,activetime,time_stamp)
  VALUES (in_charguid, in_id, in_state, in_current,in_activetime,in_time_stamp) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, id=in_id, state=in_state, current=in_current,activetime=in_activetime,time_stamp=in_time_stamp;
END;;
-- ----------------------------
-- Procedure structure for sp_player_binghun_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_binghun_select_by_id`;
CREATE PROCEDURE `sp_player_binghun_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_player_binghun WHERE charguid=in_charguid;
END;;
#***************************************************************
##版本217修改完成
#***************************************************************
#***************************************************************
##版本218修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` bigint, IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int)
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus, vitality, actcode_flags,
		vitality_num,daily_yesterday, worshipstime,zhanyinchip,baojia_level, baojia_wish,
		baojia_procenum,addicted_freetime, fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,zhuzairoad_energy,equipcreate_unlockid,
		sale_count,freeshoe_count,lingzhen_level, lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,flyshoe_tick,seven_day)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus, in_vitality, in_actcode_flags,
		in_vitality_num,in_daily_yesterday, in_worshipstime,in_zhanyinchip,in_baojia_level, in_baojia_wish,
		in_baojia_procenum,in_addicted_freetime, in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,
		in_lianti_pointid,in_huizhang_dropzhenqi,in_zhuzairoad_energy,in_equipcreate_unlockid,
		in_sale_count,in_freeshoe_count,in_lingzhen_level, in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,
		in_extremity_damage,in_flyshoe_tick,in_seven_day) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag, bag_online=in_bag_online, 
		expend_storage=in_expend_storage, storage_online=in_storage_online, babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day;
END;;
#***************************************************************
##版本218修改完成
#***************************************************************
#***************************************************************
##版本219修改开始
-- ----------------------------
-- Procedure structure for sp_update_waterdup
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_waterdup`;
CREATE PROCEDURE `sp_update_waterdup`(IN `in_charguid` bigint, IN `in_history_wave` int,
 IN `in_history_exp` bigint, IN `in_today_count` int, IN `in_reward_rate` double, IN `in_reward_exp` double)
BEGIN
	INSERT INTO tb_waterdup(charguid, history_wave, history_exp, today_count, reward_rate, reward_exp)
	VALUES (in_charguid, in_history_wave, in_history_exp, in_today_count, in_reward_rate, in_reward_exp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, history_wave = in_history_wave, 
	history_exp = in_history_exp, today_count = in_today_count, reward_rate = in_reward_rate, reward_exp = in_reward_exp;
END
;;
#***************************************************************
##版本219修改完成
#***************************************************************
#***************************************************************
##版本220修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_smelt_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_smelt_select_by_id`;
CREATE PROCEDURE `sp_player_smelt_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_smelt WHERE in_charguid = charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_smelt
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_smelt`;
CREATE PROCEDURE `sp_insert_update_smelt`(IN `in_charguid` bigint, IN `in_smelt_level` int, IN `in_smelt_exp` int,
 IN `in_smelt_flags` bigint)
BEGIN
	INSERT INTO tb_player_smelt(charguid,smelt_level,smelt_exp,smelt_flags)
	VALUES (in_charguid,in_smelt_level,in_smelt_exp,in_smelt_flags) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, smelt_level=in_smelt_level, 
	smelt_exp=in_smelt_exp, smelt_flags=in_smelt_flags;
END;;
#***************************************************************
##版本220修改完成
#***************************************************************
#***************************************************************
##版本221修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` bigint, IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int)
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus, vitality, actcode_flags,
		vitality_num,daily_yesterday, worshipstime,zhanyinchip,baojia_level, baojia_wish,
		baojia_procenum,addicted_freetime, fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,zhuzairoad_energy,equipcreate_unlockid,
		sale_count,freeshoe_count,lingzhen_level, lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,flyshoe_tick,seven_day,zhuan_id,zhuan_step)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus, in_vitality, in_actcode_flags,
		in_vitality_num,in_daily_yesterday, in_worshipstime,in_zhanyinchip,in_baojia_level, in_baojia_wish,
		in_baojia_procenum,in_addicted_freetime, in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,
		in_lianti_pointid,in_huizhang_dropzhenqi,in_zhuzairoad_energy,in_equipcreate_unlockid,
		in_sale_count,in_freeshoe_count,in_lingzhen_level, in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,
		in_extremity_damage,in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag, bag_online=in_bag_online, 
		expend_storage=in_expend_storage, storage_online=in_storage_online, babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step;
END;;
#***************************************************************
##版本221修改完成
#***************************************************************
#***************************************************************
##版本222修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_waterdup
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_waterdup`;
CREATE PROCEDURE `sp_update_waterdup`(IN `in_charguid` bigint, IN `in_history_wave` int,
 IN `in_history_exp` bigint, IN `in_today_count` int, IN `in_reward_rate` double, IN `in_reward_exp` double,
 IN `in_history_kill` int)
BEGIN
	INSERT INTO tb_waterdup(charguid, history_wave, history_exp, today_count, reward_rate, reward_exp, history_kill)
	VALUES (in_charguid, in_history_wave, in_history_exp, in_today_count, in_reward_rate, in_reward_exp, in_history_kill) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, history_wave = in_history_wave, 
	history_exp = in_history_exp, today_count = in_today_count, reward_rate = in_reward_rate, reward_exp = in_reward_exp,
	history_kill = in_history_kill;
END
;;
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_shortcut_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shortcut_delete_by_id_and_timestamp`;
CREATE  PROCEDURE `sp_player_shortcut_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_shortcuts` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;
#***************************************************************
##版本222修改完成
#***************************************************************
#***************************************************************
##版本224修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_ride
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_ride`;
CREATE PROCEDURE `sp_insert_update_ride`(IN `in_charguid` bigint, IN `in_step` int, IN `in_select` int, IN `in_state` int, IN `in_process` int,
			IN `in_attrdan` int, IN `in_proce_num` int, IN `in_total_proce` int, IN `in_fh_zhenqi` int, IN `in_consum_zhenqi` int)
BEGIN
	INSERT INTO tb_ride(charguid, ride_step, ride_select, ride_state, ride_process, attrdan, proce_num, total_proce,fh_zhenqi,consum_zhenqi)
	VALUES (in_charguid, in_step, in_select, in_state, in_process, in_attrdan,in_proce_num, in_total_proce,in_fh_zhenqi,in_consum_zhenqi)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ride_step=in_step, ride_select = in_select, ride_state = in_state, ride_process = in_process, 
		attrdan=in_attrdan, proce_num=in_proce_num, total_proce=in_total_proce, fh_zhenqi=in_fh_zhenqi, consum_zhenqi=in_consum_zhenqi;
END ;;
#***************************************************************
##版本224修改完成
#***************************************************************
#***************************************************************
##版本226修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_gm_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gm_list`;
CREATE PROCEDURE `sp_select_gm_list`()
BEGIN
	SELECT tb_account.gm_flag, tb_account.charguid, tb_account.account, tb_player_info.name 
	FROM tb_account, tb_player_info  
	WHERE tb_account.gm_flag > 0 AND tb_player_info.charguid = tb_account.charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_gm_account
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_gm_account`;
CREATE PROCEDURE `sp_update_gm_account`(IN `in_charguid` bigint, IN `in_gm` int)
BEGIN
	UPDATE tb_account SET gm_flag = in_gm WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_select_welfare_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_welfare_list`;
CREATE PROCEDURE `sp_select_welfare_list`()
BEGIN
	SELECT tb_account.*, tb_player_info.name
	FROM tb_account 
	LEFT JOIN tb_player_info
	ON tb_player_info.charguid = tb_account.charguid	
	WHERE tb_account.welfare > 0;
END;;
-- ----------------------------
-- Procedure structure for sp_update_welfare_account
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_welfare_account`;
CREATE PROCEDURE `sp_update_welfare_account`(IN `in_charguid` bigint, IN `in_welfare` int, IN `in_oper` varchar(64), IN `in_oper_time` int)
BEGIN
	UPDATE tb_account
	SET welfare = in_welfare, oper = in_oper, oper_time = in_oper_time
	WHERE charguid = in_charguid;
END;;

#***************************************************************
##版本226修改完成
#***************************************************************
#***************************************************************
##版本227修改开始
#***************************************************************
 -- ----------------------------
-- Procedure structure for sp_select_rank_human_info_base
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_human_info_base`;
CREATE PROCEDURE `sp_select_rank_human_info_base`(IN `in_id` bigint)
BEGIN
	SELECT charguid, name, prof, level, hp, mp, power, vip_level, sex, dress, 
	arms, head, suit, weapon, hunli, tipo, shenfa, jingshen, vplan, wingid, shenbingid, suitflag,crossscore
	FROM tb_player_info WHERE charguid = in_id;
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_ride
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_ride`;
CREATE PROCEDURE `sp_insert_update_ride`(IN `in_charguid` bigint, IN `in_step` int, IN `in_select` int, IN `in_state` int, IN `in_process` int,
			IN `in_attrdan` int, IN `in_proce_num` int, IN `in_total_proce` int, IN `in_fh_zhenqi` bigint, IN `in_consum_zhenqi` bigint)
BEGIN
	INSERT INTO tb_ride(charguid, ride_step, ride_select, ride_state, ride_process, attrdan, proce_num, total_proce,fh_zhenqi,consum_zhenqi)
	VALUES (in_charguid, in_step, in_select, in_state, in_process, in_attrdan,in_proce_num, in_total_proce,in_fh_zhenqi,in_consum_zhenqi)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ride_step=in_step, ride_select = in_select, ride_state = in_state, ride_process = in_process, 
		attrdan=in_attrdan, proce_num=in_proce_num, total_proce=in_total_proce, fh_zhenqi=in_fh_zhenqi, consum_zhenqi=in_consum_zhenqi;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_refinery_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_refinery_insert_update`;
CREATE PROCEDURE `sp_player_refinery_insert_update`(IN `in_gid` bigint,  IN `in_id` varchar(256),IN `in_cost_zhenqi` bigint,IN `in_fh_cost_zhenqi` bigint)
BEGIN
	INSERT INTO tb_player_refinery(charguid, id, cost_zhenqi, fh_cost_zhenqi)
	VALUES (in_gid, in_id, in_cost_zhenqi, in_fh_cost_zhenqi) 
	ON DUPLICATE KEY UPDATE charguid=in_gid, id=in_id,cost_zhenqi=in_cost_zhenqi, fh_cost_zhenqi=in_fh_cost_zhenqi;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_vip_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update`;
CREATE PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` bigint, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_exp,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3)
	VALUES (in_charguid,in_vip_exp,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_exp=in_vip_exp,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3;
END;;

#***************************************************************
##版本227修改完成
#***************************************************************
#***************************************************************
##版本228修改开始
#***************************************************************
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
				IN `in_pvplevel` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, pvplevel)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid, in_pvplevel) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel;
END;;
#***************************************************************
##版本228修改完成
#***************************************************************
#***************************************************************
##版本229修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_account_select_by_guid
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_account_select_by_guid`;
CREATE PROCEDURE `sp_account_select_by_guid`(IN `in_charguid` bigint)
BEGIN
	SELECT account, groupid, charguid, valid, forb_chat_time, forb_chat_last, forb_acc_time, forb_acc_last, adult,
		 UNIX_TIMESTAMP(last_logout) as last_logout, UNIX_TIMESTAMP(last_login) as last_login, UNIX_TIMESTAMP(create_time) as create_time,
		 gm_flag, welfare, forb_type, lock_reason
	FROM tb_account WHERE charguid = in_charguid ;
END;;
-- ----------------------------
-- Procedure structure for sp_gm_select_role_list_by_name
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_gm_select_role_list_by_name`;
CREATE PROCEDURE `sp_gm_select_role_list_by_name`(IN `in_name` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE name like in_name;
END;;
-- ----------------------------
-- Procedure structure for sp_gm_select_forb_acc_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_gm_select_forb_acc_list`;
CREATE PROCEDURE `sp_gm_select_forb_acc_list`(IN `in_cur` int)
BEGIN
	SELECT *, (forb_acc_time + forb_chat_last) AS last_time FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE forb_acc_time + forb_chat_last > in_cur;
END;;
-- ----------------------------
-- Procedure structure for sp_gm_select_forb_chat_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_gm_select_forb_chat_list`;
CREATE PROCEDURE `sp_gm_select_forb_chat_list`(IN `in_cur` int)
BEGIN
	SELECT *, (forb_chat_time + forb_chat_last) AS last_time FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE forb_chat_time + forb_chat_last > in_cur;
END;;
-- ----------------------------
-- Procedure structure for sp_gm_select_forb_mac_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_gm_select_forb_mac_list`;
CREATE PROCEDURE `sp_gm_select_forb_mac_list`(IN `in_cur` int)
BEGIN
	SELECT *, (0) AS last_time FROM tb_forb_mac left join tb_account
	on tb_forb_mac.charguid = tb_account.charguid
	left join tb_player_info
	on tb_player_info.charguid = tb_account.charguid;
END;;
#***************************************************************
##版本229修改完成
#***************************************************************
#***************************************************************
##版本230修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_vip_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_vip_insert_update`;
CREATE PROCEDURE `sp_player_vip_insert_update`(IN `in_charguid` bigint, IN `in_vip_exp` bigint, IN `in_vip_lvlreward` int, IN `in_vip_weekrewardtime` bigint,
		IN `in_vip_typelasttime1` bigint, IN `in_vip_typelasttime2` bigint, IN `in_vip_typelasttime3` bigint, IN `in_redpacketcnt` int)
BEGIN
	INSERT INTO tb_player_vip(charguid,vip_exp,vip_lvlreward,vip_weekrewardtime,vip_typelasttime1,vip_typelasttime2,vip_typelasttime3,redpacketcnt)
	VALUES (in_charguid,in_vip_exp,in_vip_lvlreward,in_vip_weekrewardtime,in_vip_typelasttime1,in_vip_typelasttime2,in_vip_typelasttime3,in_redpacketcnt) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid,vip_lvlreward=in_vip_lvlreward,vip_exp=in_vip_exp,vip_weekrewardtime=in_vip_weekrewardtime
		,vip_typelasttime1=in_vip_typelasttime1,vip_typelasttime2=in_vip_typelasttime2,vip_typelasttime3=in_vip_typelasttime3,redpacketcnt=in_redpacketcnt;
END;;

-- ----------------------------
-- Procedure structure for sp_change_pvp_lv
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_change_pvp_lv`;
CREATE PROCEDURE `sp_change_pvp_lv`(IN `in_charguid` bigint, IN `in_lv` int)
BEGIN
	UPDATE tb_player_info SET pvplevel = in_lv WHERE charguid = in_charguid;
END;;
#***************************************************************
##版本230修改完成
#***************************************************************
#***************************************************************
##版本231修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_forbidden_acc
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_forbidden_acc`;
CREATE PROCEDURE `sp_update_forbidden_acc`(IN  `in_charguid`  bigint(20), IN `in_forb_acc_last` int, IN `in_forb_acc_time` int, 
					IN `in_super` int, IN `in_reason` VARCHAR(128))
BEGIN
	UPDATE tb_account SET  forb_acc_last = in_forb_acc_last, forb_acc_time = in_forb_acc_time,
		 forb_type = in_super, lock_reason = in_reason
	WHERE charguid = in_charguid;
END;;
#***************************************************************
##版本231修改完成
#***************************************************************
#***************************************************************
##版本232修改开始
#***************************************************************
-- ----------------------------	
-- Procedure structure for sp_player_zhuzairoadbox_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhuzairoadbox_insert_update`;
CREATE PROCEDURE `sp_player_zhuzairoadbox_insert_update`(IN `in_charguid` bigint, IN `in_road_box` varchar(32), IN `in_buy_num` int, IN `in_zhuzairoad_tick` int,
IN `in_challenge_count` int, IN `in_roadlv_max` int)
BEGIN
	INSERT INTO tb_zhuzairoad_box(charguid, road_box, buy_num, zhuzairoad_tick, challenge_count, roadlv_max)
	VALUES (in_charguid, in_road_box, in_buy_num, in_zhuzairoad_tick, in_challenge_count, in_roadlv_max)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, road_box=in_road_box, buy_num=in_buy_num, zhuzairoad_tick = in_zhuzairoad_tick,
	 challenge_count = in_challenge_count, roadlv_max = in_roadlv_max;
END;;
#***************************************************************
##版本232修改完成
#***************************************************************
#***************************************************************
##版本233修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_shenshou_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenshou_select_by_id`;
CREATE PROCEDURE `sp_player_shenshou_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shenshou WHERE in_charguid = charguid;
END;;
-- ----------------------------	
-- Procedure structure for sp_player_shenshouskins_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenshouskins_insert_update`;
CREATE PROCEDURE `sp_player_shenshouskins_insert_update`(IN `in_charguid` bigint, IN `in_shenshou_id` int, IN `in_skin_time` bigint)
BEGIN
	INSERT INTO tb_player_shenshou(charguid, shenshou_id, skin_time)
	VALUES (in_charguid, in_shenshou_id, in_skin_time)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, shenshou_id=in_shenshou_id, skin_time=in_skin_time;
END;;
#***************************************************************
##版本233修改完成
#***************************************************************
#***************************************************************
##版本234修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64))
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper;
END;;
-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_consignment_record_insert_update`;
CREATE PROCEDURE `sp_consignment_record_insert_update`( IN `in_record_guid` bigint, IN `in_char_guid` bigint,
														IN `in_item_id` int, IN `in_item_count` int,
														IN `in_sale_time` bigint, IN `in_gain_money` int,
														IN `in_buy_char_name` varchar(64))
BEGIN
	INSERT INTO tb_consignment_record(record_guid, char_guid, item_id, item_count, sale_time, gain_money, buy_char_name)
	VALUES (in_record_guid, in_char_guid, in_item_id, in_item_count, in_sale_time, in_gain_money, in_buy_char_name)
	ON DUPLICATE KEY UPDATE 
	record_guid=in_record_guid, char_guid=in_char_guid, item_id=in_item_id,item_count=in_item_count,sale_time=in_sale_time,
	gain_money=in_gain_money, buy_char_name = in_buy_char_name;
END;;
#***************************************************************
##版本234修改完成
#***************************************************************
#***************************************************************
##版本235修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` bigint, IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350))
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus, vitality, actcode_flags,
		vitality_num,daily_yesterday, worshipstime,zhanyinchip,baojia_level, baojia_wish,
		baojia_procenum,addicted_freetime, fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,zhuzairoad_energy,equipcreate_unlockid,
		sale_count,freeshoe_count,lingzhen_level, lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,flyshoe_tick,seven_day,zhuan_id,zhuan_step,lastCheckTime,daily_count)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus, in_vitality, in_actcode_flags,
		in_vitality_num,in_daily_yesterday, in_worshipstime,in_zhanyinchip,in_baojia_level, in_baojia_wish,
		in_baojia_procenum,in_addicted_freetime, in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,
		in_lianti_pointid,in_huizhang_dropzhenqi,in_zhuzairoad_energy,in_equipcreate_unlockid,
		in_sale_count,in_freeshoe_count,in_lingzhen_level, in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,
		in_extremity_damage,in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag, bag_online=in_bag_online, 
		expend_storage=in_expend_storage, storage_online=in_storage_online, babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count;
END;;
#***************************************************************
##版本235修改完成
#***************************************************************
#***************************************************************
##版本236修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_homeland`;
CREATE PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
	IN `in_xunxian` int, IN `in_rob` int, IN `in_rob_cd` int, IN `in_xunxian_ref` int, IN `in_xunxian_cnt` int,
	IN `in_quest_ref` int, IN `in_rob_cnt_cd` int, IN `in_recruit` int)
BEGIN
	INSERT INTO tb_player_homeland(charguid, main_lv, quest_lv, xunxian_lv, rob_cnt, rob_cd, xunxian_ref, xunxian_cnt, quest_ref, rob_cnt_cd, recruit)
	VALUES (in_charguid, in_main, in_quest, in_xunxian, in_rob, in_rob_cd, in_xunxian_ref, in_xunxian_cnt, in_quest_ref, in_rob_cnt_cd, in_recruit) 
	ON DUPLICATE KEY UPDATE main_lv = in_main, quest_lv = in_quest, xunxian_lv = in_xunxian, 
		rob_cnt = in_rob, rob_cd = in_rob_cd, xunxian_ref = in_xunxian_ref, xunxian_cnt = in_xunxian_cnt, quest_ref = in_quest_ref,
		 rob_cnt_cd = in_rob_cnt_cd, recruit = in_recruit;
END;;
#***************************************************************
##版本236修改完成
#***************************************************************
#***************************************************************
##版本237修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_ls_horse
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_ls_horse`;
CREATE PROCEDURE `sp_select_player_ls_horse`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_ls_horse WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_player_ls_horse
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_player_ls_horse`;
CREATE PROCEDURE `sp_insert_update_player_ls_horse`(IN `in_charguid` bigint, IN `in_lshorse_step` int,
IN `in_lshorse_process` int, IN `in_lshorse_procenum` int, IN `in_lshorse_totalproce` int)
BEGIN
	INSERT INTO tb_player_ls_horse(charguid, lshorse_step, lshorse_process, lshorse_procenum, lshorse_totalproce)
	VALUES (in_charguid, in_lshorse_step, in_lshorse_process, in_lshorse_procenum, in_lshorse_totalproce) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lshorse_step = in_lshorse_step,	lshorse_process = in_lshorse_process,
	 lshorse_procenum = in_lshorse_procenum, lshorse_totalproce = in_lshorse_totalproce;
END;;

#***************************************************************
##版本237修改完成
#***************************************************************
#***************************************************************
##版本238修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_player_homeland
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_homeland`;
CREATE PROCEDURE `sp_update_player_homeland`(IN `in_charguid` bigint, IN `in_main` int, IN `in_quest` int, 
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
END;;
#***************************************************************
##版本238修改完成
#***************************************************************
#***************************************************************
##版本239修改开始
#***************************************************************
-- ----------------------------	
-- Procedure structure for sp_update_forb_mac
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_forb_mac`;
CREATE PROCEDURE `sp_update_forb_mac`(IN `in_mac` varchar(32), IN `in_guid` bigint, IN `in_skey` int, IN `in_reason` varchar(128), IN `in_locktime` int)
BEGIN
	INSERT INTO tb_forb_mac(mac, charguid, skey, reason, locktime)
	VALUES (in_mac, in_guid, in_skey, in_reason, in_locktime)
	ON DUPLICATE KEY UPDATE
	charguid = in_guid, skey = in_skey, reason = in_reason, locktime = in_locktime;
END;;
-- ----------------------------
-- Procedure structure for sp_gm_select_forb_acc_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_gm_select_forb_acc_list`;
CREATE PROCEDURE `sp_gm_select_forb_acc_list`(IN `in_cur` int)
BEGIN
	SELECT *, (forb_acc_time + forb_acc_last) AS last_time FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	WHERE forb_acc_time + forb_acc_last > in_cur;
END;;
#***************************************************************
##版本239修改完成
#***************************************************************
#***************************************************************
##版本240修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350))
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus, vitality, actcode_flags,
		vitality_num,daily_yesterday, worshipstime,zhanyinchip,baojia_level, baojia_wish,
		baojia_procenum,addicted_freetime, fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,zhuzairoad_energy,equipcreate_unlockid,
		sale_count,freeshoe_count,lingzhen_level, lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,flyshoe_tick,seven_day,zhuan_id,zhuan_step,lastCheckTime,daily_count)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus, in_vitality, in_actcode_flags,
		in_vitality_num,in_daily_yesterday, in_worshipstime,in_zhanyinchip,in_baojia_level, in_baojia_wish,
		in_baojia_procenum,in_addicted_freetime, in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,
		in_lianti_pointid,in_huizhang_dropzhenqi,in_zhuzairoad_energy,in_equipcreate_unlockid,
		in_sale_count,in_freeshoe_count,in_lingzhen_level, in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,
		in_extremity_damage,in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag, bag_online=in_bag_online, 
		expend_storage=in_expend_storage, storage_online=in_storage_online, babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count;
END;;

-- ----------------------------
-- Procedure structure for sp_player_update_party
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_update_party`;
CREATE PROCEDURE `sp_player_update_party`(IN `in_guid` bigint, IN `in_id` int, IN `in_progress` int, IN `in_award` int, 
IN `in_awardtimes` int, IN `in_param1` int, IN `in_param2` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_party(charguid, id, progress, award, awardtimes, param1, param2, time_stamp)
	VALUES (in_guid, in_id, in_progress, in_award, in_awardtimes, in_param1, in_param2, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_guid, id = in_id, progress = in_progress, 
	award = in_award, awardtimes = in_awardtimes, param1 = in_param1, 
	param2 = in_param2, time_stamp = in_time_stamp;
END;;

-- ----------------------------
-- Procedure structure for sp_player_party_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_party_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_party_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_party WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;

-- ----------------------------
-- Procedure structure for sp_select_player_party
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_party`;
CREATE PROCEDURE `sp_select_player_party`(IN `in_guid` bigint)
BEGIN
	SELECT * FROM tb_player_party WHERE charguid = in_guid;
END;;

-- ----------------------------
-- Procedure structure for sp_select_all_party_group_purchase
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_all_party_group_purchase`;
CREATE PROCEDURE `sp_select_all_party_group_purchase`()
BEGIN
	SELECT * FROM tb_group_purchase;
END;;

-- ----------------------------
-- Procedure structure for sp_update_party_group_purchase
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_party_group_purchase`;
CREATE PROCEDURE `sp_update_party_group_purchase`(IN `in_id` int, IN `in_cnt` int)
BEGIN
	INSERT INTO tb_group_purchase(id, cnt)
	VALUES (in_id, in_cnt)
	ON DUPLICATE KEY UPDATE id = in_id, cnt = in_cnt;
END;;

-- ----------------------------
-- Procedure structure for sp_select_all_party_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_all_party_rank`;
CREATE PROCEDURE `sp_select_all_party_rank`()
BEGIN
	SELECT * FROM tb_party_rank;
END;;

-- ----------------------------
-- Procedure structure for sp_update_party_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_party_rank`;
CREATE PROCEDURE `sp_update_party_rank`(IN `in_id` int, IN `in_name` varchar(32), IN `in_prof` int, IN `in_arms` int,
IN `in_dress` int, IN `in_fashionhead` int, IN `in_fashionarms` int, IN `in_fashiondress` int, IN `in_wuhunid` int, 
IN `in_wingid` int, IN `in_suitflag` int, IN `in_rank1` varchar(64), IN `in_rank2` varchar(64), IN `in_rank3` varchar(64), 
IN `in_rank4` varchar(64), IN `in_rank5` varchar(64), IN `in_rank6` varchar(64), IN `in_rank7` varchar(64), 
IN `in_rank8` varchar(64), IN `in_rank9` varchar(64), IN `in_rank10` varchar(64))
BEGIN
	INSERT INTO tb_party_rank(id, name, prof, arms, dress, fashionhead, fashionarms, fashiondress, wuhunid, 
	wingid, suitflag, rank1, rank2, rank3, rank4, rank5, rank6, rank7, rank8, rank9, rank10)
	VALUES (in_id, in_name, in_prof, in_arms, in_dress, in_fashionhead, in_fashionarms, in_fashiondress, in_wuhunid,
	in_wingid, in_suitflag, in_rank1, in_rank2, in_rank3, in_rank4, in_rank5, in_rank6, in_rank7, in_rank8,
	in_rank9, in_rank10)
	ON DUPLICATE KEY UPDATE id = in_id, name = in_name, prof = in_prof, arms = in_arms, dress = in_dress,
	fashionhead = in_fashionhead, fashionarms = in_fashionarms, fashiondress = in_fashiondress, wuhunid = in_wuhunid,
	wingid = in_wingid, suitflag = in_suitflag, rank1 = in_rank1, rank2 = in_rank2, rank3 = in_rank3, rank4 = in_rank4,
	rank5 = in_rank5, rank6 = in_rank6, rank7 = in_rank7, rank8 = in_rank8, rank9 = in_rank9, rank10 = in_rank10;
END;;

#***************************************************************
##版本240修改完成
#***************************************************************
#***************************************************************
##版本242修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_wuhuns_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuhuns_insert_update`;
CREATE PROCEDURE `sp_player_wuhuns_insert_update`(IN `in_charguid` bigint, IN `in_wuhun_id` int, IN `in_wuhun_wish` int, IN `in_trytime` int, IN `in_cur_hunzhu` int,
 	IN `in_wuhun_progress` int, IN `in_feed_num` int, IN `in_wuhun_state` int, IN `in_wuhun_sp` int,IN `in_cur_shenshou` int,IN `in_shenshou_data` varchar(128),
	IN `in_total_proce_num` int,IN `in_fh_item_num` int, IN `in_select` int, IN `in_attr_num` int)
BEGIN
  INSERT INTO tb_player_wuhuns(charguid, wuhun_id, wuhun_wish, trytime, cur_hunzhu,
   wuhun_progress, feed_num, wuhun_state, wuhun_sp, cur_shenshou, shenshou_data,
    total_proce_num, fh_item_num, select_id, attr_num)
  VALUES (in_charguid, in_wuhun_id, in_wuhun_wish, in_trytime, in_cur_hunzhu,
   in_wuhun_progress, in_feed_num, in_wuhun_state, in_wuhun_sp, in_cur_shenshou, in_shenshou_data,
   in_total_proce_num, in_fh_item_num, in_select, in_attr_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, wuhun_id=in_wuhun_id, wuhun_wish=in_wuhun_wish, trytime=in_trytime, cur_hunzhu=in_cur_hunzhu,
    wuhun_progress=in_wuhun_progress, feed_num=in_feed_num, wuhun_state=in_wuhun_state, wuhun_sp=in_wuhun_sp, cur_shenshou = in_cur_shenshou, shenshou_data = in_shenshou_data,
    total_proce_num = in_total_proce_num, fh_item_num = in_fh_item_num, select_id =in_select, attr_num = in_attr_num;
END ;;
#***************************************************************
##版本242修改完成
#***************************************************************
#***************************************************************
##版本243修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_rank_human_wuhun_equip
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_rank_human_wuhun_equip`;
CREATE PROCEDURE `sp_select_rank_human_wuhun_equip`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_equips WHERE charguid = in_charguid AND bag = 5;
END;;
#***************************************************************
##版本243修改完成
#***************************************************************
#***************************************************************
##版本244修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_player_vplan
-- ----------------------------
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
	IN `in_consume_time` int)
BEGIN
  INSERT INTO tb_player_vplan(charguid, newbie_gift_m, newbie_gift_y, daily_gift, 
  	title_m, title_y, level_gift, mail_flag, consume_gift, consume_num, consume_time)
  VALUES (in_charguid, in_newbie_gift_m, in_newbie_gift_y, in_daily_gift, 
  	in_title_m, in_title_y, in_level_gift, in_mail_flag, in_consume_gift, in_consume_num, in_consume_time)
  ON DUPLICATE KEY UPDATE newbie_gift_m = in_newbie_gift_m, newbie_gift_y = in_newbie_gift_y, daily_gift = in_daily_gift, 
  title_m = in_title_m, title_y = in_title_y, level_gift = in_level_gift, mail_flag = in_mail_flag,
  consume_gift = in_consume_gift, consume_num = in_consume_num, consume_time = in_consume_time;
END;;
#***************************************************************
##版本244修改完成
#***************************************************************
#***************************************************************
##版本245修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update`;
CREATE PROCEDURE `sp_player_shenbing_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int)
BEGIN
  INSERT INTO tb_player_shenbing(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num;
END ;;

-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350), IN `in_lingzhen_attr_num` int)
BEGIN
	INSERT INTO tb_player_extra(charguid, func_flags, expend_bag, bag_online, expend_storage, 
		storage_online, babel_count, timing_count, offmin, awardstatus, vitality, actcode_flags,
		vitality_num,daily_yesterday, worshipstime,zhanyinchip,baojia_level, baojia_wish,
		baojia_procenum,addicted_freetime, fatigue, reward_bits,huizhang_lvl,huizhang_times,
		huizhang_zhenqi,huizhang_progress,vitality_getid, achievement_flag,lianti_pointid,huizhang_dropzhenqi,zhuzairoad_energy,equipcreate_unlockid,
		sale_count,freeshoe_count,lingzhen_level, lingzhen_wish,lingzhen_procenum,item_shortcut,extremity_monster,extremity_damage,flyshoe_tick,seven_day,zhuan_id,zhuan_step,lastCheckTime,daily_count,lingzhen_attr_num)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus, in_vitality, in_actcode_flags,
		in_vitality_num,in_daily_yesterday, in_worshipstime,in_zhanyinchip,in_baojia_level, in_baojia_wish,
		in_baojia_procenum,in_addicted_freetime, in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,
		in_lianti_pointid,in_huizhang_dropzhenqi,in_zhuzairoad_energy,in_equipcreate_unlockid,
		in_sale_count,in_freeshoe_count,in_lingzhen_level, in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,
		in_extremity_damage,in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,in_lingzhen_attr_num) 
	ON DUPLICATE KEY UPDATE charguid=in_uid, func_flags=in_func_flags, expend_bag=in_expend_bag, bag_online=in_bag_online, 
		expend_storage=in_expend_storage, storage_online=in_storage_online, babel_count=in_babel_count, timing_count=in_timing_count, offmin=in_offmin, 
		awardstatus = in_awardstatus, vitality = in_vitality, actcode_flags = in_actcode_flags, 
		vitality_num = in_vitality_num, daily_yesterday = in_daily_yesterday, worshipstime = in_worshipstime,zhanyinchip = in_zhanyinchip,
		baojia_level=in_baojia_level, baojia_wish=in_baojia_wish,baojia_procenum=in_baojia_procenum,addicted_freetime=in_addicted_freetime,
		fatigue = in_fatigue, reward_bits = in_reward_bits,huizhang_lvl=in_huizhang_lvl,huizhang_times=in_huizhang_times,huizhang_zhenqi=in_huizhang_zhenqi,
		huizhang_progress=in_huizhang_progress,vitality_getid=in_vitality_getid, achievement_flag = in_achievement_flag,lianti_pointid = in_lianti_pointid,
		huizhang_dropzhenqi = in_huizhang_dropzhenqi,zhuzairoad_energy=in_zhuzairoad_energy,equipcreate_unlockid = in_equipcreate_unlockid,
		sale_count=in_sale_count,freeshoe_count=in_freeshoe_count,lingzhen_level = in_lingzhen_level,lingzhen_wish=in_lingzhen_wish,lingzhen_procenum = in_lingzhen_procenum,
		item_shortcut = in_item_shortcut,extremity_monster = in_extremity_monster,extremity_damage = in_extremity_damage,
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,lingzhen_attr_num=in_lingzhen_attr_num;
END;;
#***************************************************************
##版本245修改完成
#***************************************************************
#***************************************************************
##版本246修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_waterdup
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_waterdup`;
CREATE PROCEDURE `sp_update_waterdup`(IN `in_charguid` bigint, IN `in_history_wave` int,
 IN `in_history_exp` bigint, IN `in_today_count` int, IN `in_reward_rate` double, IN `in_reward_exp` double,
 IN `in_history_kill` int, IN `in_buy_count` int)
BEGIN
	INSERT INTO tb_waterdup(charguid, history_wave, history_exp, today_count, reward_rate, reward_exp, history_kill, buy_count)
	VALUES (in_charguid, in_history_wave, in_history_exp, in_today_count, in_reward_rate, in_reward_exp, in_history_kill, in_buy_count) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, history_wave = in_history_wave, 
	history_exp = in_history_exp, today_count = in_today_count, reward_rate = in_reward_rate, reward_exp = in_reward_exp,
	history_kill = in_history_kill, buy_count = in_buy_count;
END;;
#***************************************************************
##版本246修改完成
#***************************************************************
#***************************************************************
##版本247修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;
CREATE PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int, IN `in_fh_itemnum` bigint)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum, fh_itemnum)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum, in_fh_itemnum)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum, fh_itemnum=in_fh_itemnum;
END;;
#***************************************************************
##版本247修改完成
#***************************************************************
#***************************************************************
##版本248修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int)
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
		lingzhen_attr_num, footprints)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,
		in_lingzhen_attr_num, in_footprints) 
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
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints;
END;;
#***************************************************************
##版本248修改完成
#***************************************************************
#***************************************************************
##版本249修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_update_party
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_update_party`;
CREATE PROCEDURE `sp_player_update_party`(IN `in_guid` bigint, IN `in_id` int, IN `in_progress` int, IN `in_award` int, 
IN `in_awardtimes` int, IN `in_param1` int, IN `in_param2` int, IN`in_param3` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_party(charguid, id, progress, award, awardtimes, param1, param2, param3, time_stamp)
	VALUES (in_guid, in_id, in_progress, in_award, in_awardtimes, in_param1, in_param2, in_param3, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_guid, id = in_id, progress = in_progress, 
	award = in_award, awardtimes = in_awardtimes, param1 = in_param1, 
	param2 = in_param2, param3 = in_param3, time_stamp = in_time_stamp;
END;;
#***************************************************************
##版本249修改完成
#***************************************************************
#***************************************************************
##版本250修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_wuhuns_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuhuns_insert_update`;
CREATE PROCEDURE `sp_player_wuhuns_insert_update`(IN `in_charguid` bigint, IN `in_wuhun_id` int, IN `in_wuhun_wish` int, IN `in_trytime` int, IN `in_cur_hunzhu` int,
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
END ;;
DROP PROCEDURE IF EXISTS `sp_player_realm_insert_update`;
CREATE PROCEDURE `sp_player_realm_insert_update`(IN `in_charguid` bigint,  IN `in_realm_step` int, IN `in_realm_feed_num` int, 
	   IN `in_realm_progress` varchar(128), IN `in_wish` int, IN `in_procenum` int, IN `in_fh_itemnum` bigint, IN `in_fh_level_itemnum` bigint)
BEGIN
	INSERT INTO tb_player_realm(charguid, realm_step, realm_feed_num, realm_progress, wish, procenum, fh_itemnum,fh_level_itemnum)
	VALUES (in_charguid, in_realm_step, in_realm_feed_num, in_realm_progress, in_wish, in_procenum, in_fh_itemnum,in_fh_level_itemnum)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, realm_step=in_realm_step, realm_feed_num=in_realm_feed_num, 
	realm_progress=in_realm_progress, wish=in_wish, procenum=in_procenum, fh_itemnum=in_fh_itemnum, fh_level_itemnum=in_fh_level_itemnum;
END;;

#***************************************************************
##版本250修改完成
#***************************************************************

#***************************************************************
##版本251修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_party_group_purchase
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_party_group_purchase`;
CREATE PROCEDURE `sp_update_party_group_purchase`(IN `in_id` int, IN `in_cnt` int, IN `in_extracnt` int, IN `in_param1` int, IN `in_param2` int)
BEGIN
	INSERT INTO tb_group_purchase(id, cnt, extracnt, param1, param2)
	VALUES (in_id, in_cnt, in_extracnt, in_param1, in_param2)
	ON DUPLICATE KEY UPDATE id = in_id, cnt = in_cnt, extracnt = in_extracnt, param1 = in_param1,
	param2 = in_param2;
END;;

#***************************************************************
##版本251修改完成
#***************************************************************
#***************************************************************
##版本252修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_total_virtual_recharge
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_total_virtual_recharge`;
CREATE  PROCEDURE `sp_select_total_virtual_recharge`(IN `in_charguid` bigint)
BEGIN
	SELECT SUM(moneys) AS total_money FROM tb_virtual_recharge WHERE role_id = in_charguid GROUP BY NULL;
END;;
#***************************************************************
##版本252修改完成
#***************************************************************
#***************************************************************
##版本253修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_party_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_party_rank`;
CREATE PROCEDURE `sp_update_party_rank`(IN `in_id` int, IN `in_name` varchar(32), IN `in_prof` int, IN `in_arms` int,
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
END;;
#***************************************************************
##版本253修改完成
#***************************************************************
#***************************************************************
##版本254修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_guild_citywar
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_citywar`;
CREATE PROCEDURE `sp_update_guild_citywar`(IN `in_id` int, IN `in_atkgid` bigint, IN `in_defgid` bigint, IN `in_goduid` bigint, IN `in_contdef` int, In `in_contreward` int,
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
END;;
#***************************************************************
##版本254修改完成
#***************************************************************
#***************************************************************
##版本255修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int)
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
		lingzhen_attr_num, footprints,equipcreate_tick)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick) 
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
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints, equipcreate_tick = in_equipcreate_tick;
END;;
#***************************************************************
##版本255修改完成
#***************************************************************
#***************************************************************
##版本256修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int)
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
		lingzhen_attr_num, footprints,equipcreate_tick,huizhang_tick)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick,in_huizhang_tick) 
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
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints, equipcreate_tick = in_equipcreate_tick, huizhang_tick = in_huizhang_tick;
END;;
#***************************************************************
##版本256修改完成
#***************************************************************
#***************************************************************
##版本257修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_rank_level()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_level`;
CREATE PROCEDURE `sp_rank_level`()
BEGIN
	SELECT charguid AS uid, level AS rankvalue FROM tb_player_info ORDER BY level DESC, exp DESC, power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_ride()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_ride`;
CREATE PROCEDURE `sp_rank_ride`()
BEGIN
	SELECT charguid AS uid, ride_step AS rankvalue FROM tb_ride 
	WHERE ride_step > 0 ORDER BY ride_step DESC, ride_process DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_realm()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_realm`;
CREATE PROCEDURE `sp_rank_realm`()
BEGIN
	SELECT charguid AS uid, realm_step AS rankvalue FROM tb_player_realm 
	WHERE realm_step > 0 ORDER BY realm_step DESC, realm_progress DESC, wish DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_lingshou()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_lingshou`;
CREATE PROCEDURE `sp_rank_lingshou`()
BEGIN
	SELECT charguid AS uid, wuhun_id AS rankvalue FROM tb_player_wuhuns 
	WHERE wuhun_id > 0 ORDER BY wuhun_id DESC, wuhun_progress DESC, wuhun_wish DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_lingzhen()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_lingzhen`;
CREATE PROCEDURE `sp_rank_lingzhen`()
BEGIN
	SELECT charguid AS uid, lingzhen_level AS rankvalue FROM tb_player_extra 
	WHERE lingzhen_level > 0 ORDER BY lingzhen_level DESC, lingzhen_wish DESC, lingzhen_procenum DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_shenbing()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_shenbing`;
CREATE PROCEDURE `sp_rank_shenbing`()
BEGIN
	SELECT charguid AS uid, level AS rankvalue FROM tb_player_shenbing 
	WHERE level > 0 ORDER BY level DESC, proficiencylvl DESC, proficiency DESC, wish DESC LIMIT 100;
END;;
#***************************************************************
##版本257修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本258修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_personboss
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_personboss`;
CREATE PROCEDURE `sp_select_player_personboss`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_personboss WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_player_personboss
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_player_personboss`;
CREATE PROCEDURE `sp_insert_update_player_personboss`(IN `in_charguid` bigint, IN `in_id` int,
IN `in_cur_count` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_personboss(charguid, id, cur_count, time_stamp)
	VALUES (in_charguid, in_id, in_cur_count, in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, id = in_id,	cur_count = in_cur_count,
	 time_stamp = in_time_stamp;
END;;

-- ----------------------------
-- Procedure structure for sp_player_personboss_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_personboss_delete_by_id_and_timestamp`;
CREATE  PROCEDURE `sp_player_personboss_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_personboss` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;

-- ----------------------------
-- Procedure structure for sp_player_extra_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(
		IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int, IN `in_personboss_count` int)
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
		lingzhen_attr_num, footprints,equipcreate_tick,huizhang_tick,personboss_count)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick,in_huizhang_tick,in_personboss_count) 
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
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints, equipcreate_tick = in_equipcreate_tick, huizhang_tick = in_huizhang_tick, personboss_count = in_personboss_count;
END;;

#***************************************************************
##版本259修改完成
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint)
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind;
END ;;
-- ----------------------------
-- Procedure structure for sp_update_guild_itemop
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_itemop`;
CREATE PROCEDURE `sp_update_guild_itemop`(IN `in_aid` bigint, IN `in_gid` bigint, IN `in_opname` varchar(64), IN `in_optime` bigint, 
IN `in_optype` int, IN `in_opitem` int, IN `in_opextra` int, IN `in_newgroup` int, IN `in_newgroupbind` bigint)
BEGIN
	INSERT INTO tb_guild_storage_op(aid, gid, opname, optime, optype, opitem, opextra, newgroup, newgroupbind)
	VALUES (in_aid, in_gid, in_opname, in_optime, in_optype, in_opitem, in_opextra, in_newgroup, in_newgroupbind)
	ON DUPLICATE KEY UPDATE gid = in_gid, opname = in_opname, optime = in_optime, optype = in_optype,
	opitem = in_opitem, opextra = in_opextra,newgroup=in_newgroup,newgroupbind = in_newgroupbind;
END ;;
-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint)
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, newgroup, newgroupbind)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_newgroup, in_newgroupbind)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper,newgroup=in_newgroup,newgroupbind = in_newgroupbind;
END;;
#***************************************************************
##版本259修改完成
#***************************************************************
#***************************************************************
##版本261修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_guild
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_guild`;
CREATE PROCEDURE `sp_insert_update_guild`(IN `in_gid` bigint, IN `in_capital` double, IN `in_name` varchar(50), IN `in_notice` varchar(256), IN `in_level` int,
IN `in_flag` int, IN `in_count1` int, IN `in_count2` int, IN `in_count3` int, IN `in_create_time` bigint, IN `in_alianceid` bigint, IN `in_liveness` int,
IN `in_extendnum` int)
BEGIN
	INSERT INTO tb_guild(gid, capital, name, notice, level, flag, count1, count2, count3, create_time, alianceid, liveness, extendnum)
	VALUES (in_gid, in_capital, in_name, in_notice, in_level, in_flag, in_count1, in_count2, in_count3, in_create_time, in_alianceid, in_liveness, in_extendnum)
	ON DUPLICATE KEY UPDATE gid = in_gid, capital = in_capital, name = in_name, notice = in_notice, level = in_level, 
	flag = in_flag, count1 = in_count1, count2 = in_count2, count3 = in_count3, create_time=in_create_time, alianceid=in_alianceid, 
	liveness = in_liveness, extendnum = in_extendnum;
END;;
#***************************************************************
##版本261修改完成
#***************************************************************
#***************************************************************
##版本262修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_player_personboss
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_player_personboss`;
CREATE PROCEDURE `sp_insert_update_player_personboss`(IN `in_charguid` bigint, IN `in_id` int,
IN `in_cur_count` int, IN `in_first` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_personboss(charguid, id, cur_count, first, time_stamp)
	VALUES (in_charguid, in_id, in_cur_count, in_first, in_time_stamp) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, id = in_id,	cur_count = in_cur_count, first = in_first,
	 time_stamp = in_time_stamp;
END;;
#***************************************************************
##版本262修改完成
#***************************************************************
#***************************************************************
##版本263修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_guild_itemop
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_itemop`;
CREATE PROCEDURE `sp_update_guild_itemop`(IN `in_aid` bigint, IN `in_gid` bigint, IN `in_opname` varchar(64), IN `in_optime` bigint, 
IN `in_optype` int, IN `in_opitem` int, IN `in_opextra` int)
BEGIN
	INSERT INTO tb_guild_storage_op(aid, gid, opname, optime, optype, opitem, opextra)
	VALUES (in_aid, in_gid, in_opname, in_optime, in_optype, in_opitem, in_opextra)
	ON DUPLICATE KEY UPDATE gid = in_gid, opname = in_opname, optime = in_optime, optype = in_optype,
	opitem = in_opitem, opextra = in_opextra;
END ;;
DROP PROCEDURE IF EXISTS `sp_update_guild_item`;
CREATE PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int, IN `in_super1` varchar(64), 
IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64),
IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint)
BEGIN
	INSERT INTO tb_guild_storage(itemgid, gid, itemtid, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper,newgroup,newgroupbind)
	VALUES (in_itemgid, in_gid, in_itemtid, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper,in_newgroup,in_newgroupbind)
	ON DUPLICATE KEY UPDATE itemgid = in_itemgid, gid = in_gid, itemtid = in_itemtid, strenid = in_strenid,
	strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper, newgroup = in_newgroup, newgroupbind = in_newgroupbind;
END ;;
#***************************************************************
##版本263修改完成
#***************************************************************
#***************************************************************
##版本264修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_gm_select_role_by_name`;
CREATE PROCEDURE `sp_gm_select_role_by_name`(IN `in_name` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE name = in_name;
END ;;
#***************************************************************
##版本264修改完成
#***************************************************************
##版本265修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_ridewar_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_ridewar_select_by_id`;
CREATE PROCEDURE `sp_player_ridewar_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_ridewar WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_ridewar
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_ridewar`;
CREATE PROCEDURE `sp_insert_update_ridewar`(IN `in_charguid` bigint, IN `in_ridewar_id` int,
IN `in_ridewar_wish` int, IN `in_ridewar_procenum` int, IN `in_ridewar_attrnum` int)
BEGIN
	INSERT INTO tb_player_ridewar(charguid, ridewar_id, ridewar_wish, ridewar_procenum, ridewar_attrnum)
	VALUES (in_charguid, in_ridewar_id, in_ridewar_wish, in_ridewar_procenum, in_ridewar_attrnum) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ridewar_id = in_ridewar_id,	ridewar_wish = in_ridewar_wish,
	 ridewar_procenum = in_ridewar_procenum, ridewar_attrnum = in_ridewar_attrnum;
END;;

#***************************************************************
##版本266修改完成
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_platform_select_role_little_info`;
CREATE PROCEDURE `sp_platform_select_role_little_info`(IN `in_account` VARCHAR(32))
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account;
END;;
#***************************************************************
##版本266修改完成
#***************************************************************
#***************************************************************
##版本267修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_player_recharge
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_recharge`;
CREATE PROCEDURE `sp_update_player_recharge`(IN `in_order_id` VARCHAR(32))
BEGIN
	update tb_exchange_record set recharge = recharge + 1 where order_id = in_order_id;
END;;
-- ----------------------------
-- Procedure structure for sp_player_recharge_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_recharge_list`;
CREATE PROCEDURE `sp_player_recharge_list`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_exchange_record WHERE role_id = in_charguid AND recharge = 0;
END;;
-- ----------------------------
-- Procedure structure for sp_exchange_record_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_exchange_record_insert_update`;
CREATE PROCEDURE `sp_exchange_record_insert_update`(IN `in_order_id` varchar(32), IN `in_uid` varchar(32), IN `in_role_id` bigint, 
	IN `in_platform` int, IN `in_money` int, IN `in_coins` int, IN `in_time` int, IN `in_recharge` int)
BEGIN
  INSERT INTO tb_exchange_record(order_id, uid, role_id, platform, money, coins, time, recharge)
  VALUES (in_order_id, in_uid, in_role_id, in_platform, in_money, in_coins, in_time, in_recharge);
END;;
#***************************************************************
##版本267修改完成
#***************************************************************
#***************************************************************
##版本268修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_ridewar
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_ridewar`;
CREATE PROCEDURE `sp_insert_update_ridewar`(IN `in_charguid` bigint, IN `in_ridewar_id` int,
IN `in_ridewar_wish` int, IN `in_ridewar_procenum` int, IN `in_ridewar_attrnum` int, IN `in_ridewar_skin` int)
BEGIN
	INSERT INTO tb_player_ridewar(charguid, ridewar_id, ridewar_wish, ridewar_procenum, ridewar_attrnum, ridewar_skin)
	VALUES (in_charguid, in_ridewar_id, in_ridewar_wish, in_ridewar_procenum, in_ridewar_attrnum, in_ridewar_skin) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, ridewar_id = in_ridewar_id,	ridewar_wish = in_ridewar_wish,
	 ridewar_procenum = in_ridewar_procenum, ridewar_attrnum = in_ridewar_attrnum, ridewar_skin = in_ridewar_skin;
END;;

#***************************************************************
##版本268修改完成
#***************************************************************
#***************************************************************
##版本269修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_ride_dupl
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_ride_dupl`;
CREATE PROCEDURE `sp_select_player_ride_dupl`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_ride_dupl WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_ride_dupl
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_ride_dupl`;
CREATE PROCEDURE `sp_update_player_ride_dupl`(IN `in_charguid` bigint, IN `in_count` int, IN `in_today` int, IN `in_history` int)
BEGIN
	INSERT INTO tb_player_ride_dupl(charguid, count, today, history)
	VALUES (in_charguid, in_count, in_today, in_history) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, count = in_count, today = in_today, history = in_history;
END;;
-- ----------------------------
-- Procedure structure for sp_select_ride_dupl_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_ride_dupl_rank`;
CREATE PROCEDURE `sp_select_ride_dupl_rank`()
BEGIN
	SELECT * FROM tb_rank_ride_dupl;
END;;
-- ----------------------------
-- Procedure structure for sp_update_ride_dupl_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_ride_dupl_rank`;
CREATE PROCEDURE `sp_update_ride_dupl_rank`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_layer` int, IN `in_time` int, IN `in_power` bigint,
		 IN `in_name_1` varchar(32), IN `in_name_2` varchar(32), IN `in_name_3` varchar(32), IN `in_name_4` varchar(32))
BEGIN
	INSERT INTO tb_rank_ride_dupl(rank, charguid, layer, time, power, name_1, name_2, name_3, name_4)
	VALUES (in_rank, in_charguid, in_layer, in_time, in_power, in_name_1, in_name_2, in_name_3, in_name_4) 
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, layer = in_layer, time = in_time, power = in_power, 
		name_1 = in_name_1, name_2 = in_name_2, name_3 = in_name_3, name_4 = in_name_4;
END;;
#***************************************************************
##版本269修改完成
#***************************************************************
#***************************************************************
##版本270修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_rank_level()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_level`;
CREATE PROCEDURE `sp_rank_level`()
BEGIN
	SELECT charguid AS uid, level AS rankvalue FROM tb_player_info ORDER BY level DESC, exp DESC, power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_ride()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_ride`;
CREATE PROCEDURE `sp_rank_ride`()
BEGIN
	SELECT tb_ride.charguid AS uid, ride_step AS rankvalue FROM tb_ride left join tb_player_info
	on tb_ride.charguid = tb_player_info.charguid
	WHERE ride_step > 0 ORDER BY ride_step DESC, ride_process DESC, tb_player_info.power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_realm()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_realm`;
CREATE PROCEDURE `sp_rank_realm`()
BEGIN
	SELECT tb_player_realm.charguid AS uid, realm_step AS rankvalue FROM tb_player_realm left join tb_player_info
	on tb_player_realm.charguid = tb_player_info.charguid
	WHERE realm_step > 0 ORDER BY realm_step DESC, realm_progress DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_lingshou()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_lingshou`;
CREATE PROCEDURE `sp_rank_lingshou`()
BEGIN
	SELECT tb_player_wuhuns.charguid AS uid, wuhun_id AS rankvalue FROM tb_player_wuhuns left join tb_player_info
	on tb_player_wuhuns.charguid = tb_player_info.charguid
	WHERE wuhun_id > 0 ORDER BY wuhun_id DESC, wuhun_progress DESC, wuhun_wish DESC, tb_player_info.power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_lingzhen()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_lingzhen`;
CREATE PROCEDURE `sp_rank_lingzhen`()
BEGIN
	SELECT tb_player_extra.charguid AS uid, lingzhen_level AS rankvalue FROM tb_player_extra left join tb_player_info
	on tb_player_extra.charguid = tb_player_info.charguid
	WHERE lingzhen_level > 0 ORDER BY lingzhen_level DESC, lingzhen_wish DESC, lingzhen_procenum DESC, tb_player_info.power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_rank_shenbing()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_shenbing`;
CREATE PROCEDURE `sp_rank_shenbing`()
BEGIN
	SELECT tb_player_shenbing.charguid AS uid, tb_player_shenbing.level AS rankvalue FROM tb_player_shenbing left join tb_player_info
	on tb_player_shenbing.charguid = tb_player_info.charguid
	WHERE tb_player_shenbing.level > 0 ORDER BY tb_player_shenbing.level DESC, proficiencylvl DESC, proficiency DESC, wish DESC, tb_player_info.power DESC LIMIT 100;
END;;
#***************************************************************
##版本270修改完成
#***************************************************************
#***************************************************************
##版本271修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTIme` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int, IN `in_personboss_count` int, IN `in_platform_info` varchar(350))
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
		lingzhen_attr_num, footprints,equipcreate_tick,huizhang_tick,personboss_count,platform_info)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTIme,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick,in_huizhang_tick,in_personboss_count,in_platform_info) 
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
		flyshoe_tick = in_flyshoe_tick,seven_day=in_seven_day,zhuan_id = in_zhuan_id,zhuan_step=in_zhuan_step,lastCheckTIme = in_lastCheckTIme,daily_count=in_daily_count,
		lingzhen_attr_num=in_lingzhen_attr_num, footprints = in_footprints, equipcreate_tick = in_equipcreate_tick, huizhang_tick = in_huizhang_tick, personboss_count = in_personboss_count,
		platform_info = in_platform_info;
END;;
#***************************************************************
##版本271修改完成
#***************************************************************
#***************************************************************
##版本272修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
		IN `in_zhanyinchip` int,IN `in_baojia_level` int,IN `in_baojia_wish` int,IN `in_baojia_procenum` int,IN `in_addicted_freetime` int, 
		IN `in_fatigue` int, IN `in_reward_bits` int, IN `in_huizhang_lvl` int, IN `in_huizhang_times` int, IN `in_huizhang_zhenqi` int, 
		IN `in_huizhang_progress` varchar(100),IN `in_vitality_getid` int, IN `in_achievement_flag` bigint, IN `in_lianti_pointid` varchar(100),IN `in_huizhang_dropzhenqi` int, 
		IN `in_zhuzairoad_energy` int, IN `in_equipcreate_unlockid` varchar(300),IN `in_sale_count` int, IN `in_freeshoe_count` int,
		IN `in_lingzhen_level` int,IN `in_lingzhen_wish` int,IN `in_lingzhen_procenum` int,IN `in_item_shortcut` int,IN `in_extremity_monster` int, IN `in_extremity_damage` bigint,
		IN `in_flyshoe_tick` int, IN `in_seven_day` int, IN `in_zhuan_id` int, IN `in_zhuan_step` int, IN `in_lastCheckTime` int, IN `in_daily_count` varchar(350),
		IN `in_lingzhen_attr_num` int, IN `in_footprints` int, IN `in_equipcreate_tick` int, IN `in_huizhang_tick` int, IN `in_personboss_count` int, IN `in_platform_info` varchar(350), IN `in_lastMonthCheckTime` int, IN `in_month_count` varchar(350))
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
		lingzhen_attr_num, footprints,equipcreate_tick,huizhang_tick,personboss_count,platform_info,lastMonthCheckTime,month_count)
	VALUES (in_uid, in_func_flags, in_expend_bag, in_bag_online, in_expend_storage, 
		in_storage_online, in_babel_count, in_timing_count, in_offmin, in_awardstatus,
		in_vitality, in_actcode_flags,in_vitality_num,in_daily_yesterday, in_worshipstime,
		in_zhanyinchip,in_baojia_level, in_baojia_wish,in_baojia_procenum,in_addicted_freetime,
		in_fatigue, in_reward_bits,in_huizhang_lvl,in_huizhang_times,
		in_huizhang_zhenqi,in_huizhang_progress,in_vitality_getid, in_achievement_flag,in_lianti_pointid,in_huizhang_dropzhenqi,
		in_zhuzairoad_energy,in_equipcreate_unlockid,in_sale_count,in_freeshoe_count,in_lingzhen_level,
		in_lingzhen_wish,in_lingzhen_procenum,in_item_shortcut,in_extremity_monster,in_extremity_damage,
		in_flyshoe_tick,in_seven_day,in_zhuan_id,in_zhuan_step,in_lastCheckTime,in_daily_count,
		in_lingzhen_attr_num, in_footprints,in_equipcreate_tick,in_huizhang_tick,in_personboss_count,in_platform_info,in_lastMonthCheckTime,in_month_count) 
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
		platform_info = in_platform_info,lastMonthCheckTime = in_lastMonthCheckTime,month_count = in_month_count;
END;;
#***************************************************************
##版本272修改完成
#***************************************************************
#***************************************************************
##版本273修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_boss_media
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_boss_media`;
CREATE PROCEDURE `sp_select_boss_media`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_boss_media WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_boss_media
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_boss_media`;
CREATE PROCEDURE `sp_update_boss_media`(IN `in_charguid` bigint, IN `in_level` int, IN `in_star` int, IN `in_process` int,
				IN `in_point` int, IN `in_type_1` int, IN `in_type_2` int, IN `in_type_3` int, IN `in_type_4` int)
BEGIN
	INSERT INTO tb_player_boss_media(charguid, level, star, process, point, type_1, type_2, type_3, type_4)
	VALUES (in_charguid, in_level, in_star, in_process, in_point, in_type_1, in_type_2, in_type_3, in_type_4) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_level, star = in_star, process = in_process, 
		point = in_point, type_1 = in_type_1, type_2 = in_type_2, type_3 = in_type_3, type_4 = in_type_4;
END;;
#***************************************************************
##版本273修改完成
#***************************************************************
#***************************************************************
##版本274修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_mail_info_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_mail_info_by_id`;
CREATE PROCEDURE `sp_select_mail_info_by_id`(IN `in_charguid` bigint)
BEGIN
	DECLARE cur_time bigint DEFAULT '0';
	SET cur_time = UNIX_TIMESTAMP(now());
	
	SELECT * FROM (SELECT IFNULL(tb_mail.charguid, 0) AS guid, IFNULL(tb_mail.readflag, 0) AS readflag, IFNULL(tb_mail.deleteflag, 0) AS deleteflag, 
		IFNULL(tb_mail.recvflag, 0) AS recvflag, tb_mail_content.* FROM tb_mail RIGHT JOIN tb_mail_content 
	ON tb_mail.mailgid = tb_mail_content.mailgid AND tb_mail_content.validtime > cur_time WHERE charguid = in_charguid AND deleteflag = 0
	UNION ALL
	SELECT 0, 0, 0, 0, tb_mail_content.* FROM tb_mail_content WHERE refflag = 1 AND tb_mail_content.validtime > cur_time AND NOT EXISTS 
	(SELECT tb_mail.mailgid FROM tb_mail WHERE tb_mail_content.mailgid = tb_mail.mailgid AND charguid = in_charguid))t ORDER BY validtime DESC;
END;;

-- ----------------------------
-- Procedure structure for sp_rank_pvplevel()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_pvplevel`;
CREATE PROCEDURE `sp_rank_pvplevel`(IN `in_curseasonid` int, IN `in_pvplevel` int, IN `in_limit` int)
BEGIN
	SELECT charguid, pvplevel, crossscore, power, name, prof, level, arms, dress, head, suit, weapon, wuhunid, wingid, suitflag FROM tb_player_info 
	WHERE crossscore > 0 and crossseasonid = in_curseasonid and pvplevel = in_pvplevel
	ORDER BY crossscore DESC, power DESC LIMIT in_limit;
END;;
#***************************************************************
##版本274修改完成
#***************************************************************
#***************************************************************
##版本275修改完成
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_guild
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_guild`;
CREATE PROCEDURE `sp_insert_update_guild`(IN `in_gid` bigint, IN `in_capital` double, IN `in_name` varchar(50), IN `in_notice` varchar(256), IN `in_level` int,
IN `in_flag` int, IN `in_count1` int, IN `in_count2` int, IN `in_count3` int, IN `in_create_time` bigint, IN `in_alianceid` bigint, IN `in_liveness` int,
IN `in_extendnum` int, IN `in_statuscnt` int)
BEGIN
	INSERT INTO tb_guild(gid, capital, name, notice, level, flag, count1, count2, count3, create_time, alianceid, liveness, extendnum, statuscnt)
	VALUES (in_gid, in_capital, in_name, in_notice, in_level, in_flag, in_count1, in_count2, in_count3, in_create_time, in_alianceid, in_liveness, in_extendnum, in_statuscnt)
	ON DUPLICATE KEY UPDATE gid = in_gid, capital = in_capital, name = in_name, notice = in_notice, level = in_level, 
	flag = in_flag, count1 = in_count1, count2 = in_count2, count3 = in_count3, create_time=in_create_time, alianceid=in_alianceid, 
	liveness = in_liveness, extendnum = in_extendnum, statuscnt = in_statuscnt;
END;;
#***************************************************************
##版本275修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本276修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_platform_select_login_role_list_info`;
CREATE PROCEDURE `sp_platform_select_login_role_list_info`(IN `in_date` VARCHAR(32),IN `in_begin` int,IN `in_num` int)
BEGIN
	select *, (select count(*) from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(last_login) = TO_DAYS(in_date)) as c
from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(last_login) = TO_DAYS(in_date) limit in_begin,in_num;
END;;
DROP PROCEDURE IF EXISTS `sp_platform_select_create_role_list_info`;
CREATE PROCEDURE `sp_platform_select_create_role_list_info`(IN `in_date` VARCHAR(32),IN `in_begin` int,IN `in_num` int)
BEGIN
	select *, (select count(*) from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(create_time) = TO_DAYS(in_date)) as c
from tb_account, tb_player_info where tb_account.charguid=tb_player_info.charguid and TO_DAYS(create_time) = TO_DAYS(in_date) limit in_begin,in_num;
END;;
DROP PROCEDURE IF EXISTS `sp_select_day_history`;
CREATE PROCEDURE `sp_select_day_history`(IN `in_date` VARCHAR(32))
BEGIN
	select * from tb_day_history where TO_DAYS(date_time) = TO_DAYS(in_date);
END;;
DROP PROCEDURE IF EXISTS `sp_update_day_history`;
CREATE PROCEDURE `sp_update_day_history`(IN `in_date` VARCHAR(32),IN `in_maxonline` int)
BEGIN
	insert into tb_day_history(date_time, maxonline) values(in_date, in_maxonline) on duplicate key update maxonline=in_maxonline;
END;;
#***************************************************************
##版本276修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本277修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_guild_palace_sign
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_guild_palace_sign`;
CREATE PROCEDURE `sp_select_guild_palace_sign`()
BEGIN
	SELECT * FROM tb_guild_palace_sign;
END;;
-- ----------------------------
-- Procedure structure for sp_update_guild_palace_sign
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_palace_sign`;
CREATE PROCEDURE `sp_update_guild_palace_sign`(IN `in_id` int, IN `in_gid` bigint, IN `in_gold` bigint, IN `in_signtime` bigint)
BEGIN
	INSERT INTO tb_guild_palace_sign(id, gid, gold, signtime)
	VALUES (in_id, in_gid, in_gold, in_signtime) 
	ON DUPLICATE KEY UPDATE id = in_id, gid = in_gid, gold = in_gold, signtime = in_signtime;
END;;
-- ----------------------------
-- Procedure structure for sp_select_guild_palace
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_guild_palace`;
CREATE PROCEDURE `sp_select_guild_palace`()
BEGIN
	SELECT * FROM tb_guild_palace;
END;;
-- ----------------------------
-- Procedure structure for sp_update_guild_palace
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_palace`;
CREATE PROCEDURE `sp_update_guild_palace`(IN `in_id` int, IN `in_gid` bigint, IN `in_signtime` bigint)
BEGIN
	INSERT INTO tb_guild_palace(id, gid, signtime)
	VALUES (in_id, in_gid, in_signtime) 
	ON DUPLICATE KEY UPDATE id = in_id, gid = in_gid, signtime = in_signtime;
END;;

#***************************************************************
##版本277修改完成
#***************************************************************
#***************************************************************
##版本278修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_delete_guild_palace_sign
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_delete_guild_palace_sign`;
CREATE PROCEDURE `sp_delete_guild_palace_sign`(IN `in_id` int)
BEGIN
	delete FROM tb_guild_palace_sign where id = in_id;
END;;
#***************************************************************
##版本278修改完成
#***************************************************************
#***************************************************************
##版本280修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
 IN `in_stack_num` int, IN `in_flags` bigint,IN `in_bag` int, IN `in_strenid` int, IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int,
 IN `in_superholenum` int, IN `in_super1` varchar(64),IN `in_super2` varchar(64),IN `in_super3` varchar(64),IN `in_super4` varchar(64),
 IN `in_super5` varchar(64), IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_time_stamp` bigint,
 IN `in_newgroup` int, IN `in_newgroupbind` bigint, IN `in_wash` varchar(64))
BEGIN
	INSERT INTO tb_player_equips(charguid, item_id, item_tid, slot_id, stack_num, flags, bag, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, time_stamp, newgroup, newgroupbind, wash)
	VALUES (in_charguid, in_item_id, in_item_tid, in_slot_id, in_stack_num, in_flags, in_bag, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_time_stamp, in_newgroup, in_newgroupbind, in_wash) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, item_id=in_item_id, item_tid=in_item_tid, slot_id=in_slot_id, 
	stack_num=in_stack_num, flags=in_flags, bag=in_bag, strenid=in_strenid, strenval=in_strenval,proval=in_proval, extralv=in_extralv, 
	superholenum=in_superholenum, super1=in_super1, super2=in_super2, super3=in_super3, super4=in_super4, 
	super5=in_super5,super6=in_super6,super7=in_super7,newsuper=in_newsuper,time_stamp = in_time_stamp,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash;
END ;;
-- ----------------------------
-- Procedure structure for sp_update_guild_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_item`;
CREATE PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int, IN `in_super1` varchar(64), 
IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64),
IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint,
IN `in_wash` varchar(64))
BEGIN
	INSERT INTO tb_guild_storage(itemgid, gid, itemtid, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper,newgroup,newgroupbind,
	wash)
	VALUES (in_itemgid, in_gid, in_itemtid, in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper,in_newgroup,in_newgroupbind,
	in_wash)
	ON DUPLICATE KEY UPDATE itemgid = in_itemgid, gid = in_gid, itemtid = in_itemtid, strenid = in_strenid,
	strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper, newgroup = in_newgroup, newgroupbind = in_newgroupbind,
	wash = in_wash;
END ;;
-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
	IN `in_sale_time` bigint, IN `in_save_time` bigint, IN `in_price` int, IN `in_itemtid` int, IN `in_item_count` int, IN `in_strenid` int, 
	IN `in_strenval` int, IN `in_proval` int, IN `in_extralv` int, IN `in_superholenum` int
	, IN `in_super1` varchar(64), IN `in_super2` varchar(64), IN `in_super3` varchar(64), IN `in_super4` varchar(64),IN `in_super5` varchar(64)
	, IN `in_super6` varchar(64), IN `in_super7` varchar(64), IN `in_newsuper` varchar(64), IN `in_newgroup` int, IN `in_newgroupbind` bigint
	, IN `in_wash` varchar(64))
BEGIN
	INSERT INTO tb_consignment_items(sale_guid, char_guid, player_name, sale_time, save_time, price, 
	 itemtid, item_count, strenid, strenval, proval, extralv,
	superholenum, super1, super2, super3, super4, super5, super6, super7, newsuper, newgroup, newgroupbind,
	wash)
	VALUES (in_sale_guid, in_char_guid, in_player_name, in_sale_time, in_save_time, in_price
	, in_itemtid, in_item_count,in_strenid, in_strenval, in_proval, in_extralv,
	in_superholenum, in_super1, in_super2, in_super3, in_super4, in_super5, in_super6, in_super7, in_newsuper, in_newgroup, in_newgroupbind,
	in_wash)
	ON DUPLICATE KEY UPDATE 
	sale_guid=in_sale_guid, char_guid=in_char_guid, player_name=in_player_name,sale_time=in_sale_time,save_time=in_save_time,
	price=in_price, itemtid = in_itemtid, item_count=in_item_count, 
	strenid = in_strenid,strenval = in_strenval, proval = in_proval, extralv = in_extralv, superholenum = in_superholenum,
	super1 = in_super1, super2 = in_super2, super3 = in_super3, super4 = in_super4, super5 = in_super5,
	super6 = in_super6, super7 = in_super7, newsuper = in_newsuper,newgroup=in_newgroup,newgroupbind = in_newgroupbind,
	wash = in_wash;
END;;
#***************************************************************
##版本280修改完成
#***************************************************************
#***************************************************************
##版本281修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_guild_palace_sign
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_palace_sign`;
CREATE PROCEDURE `sp_update_guild_palace_sign`(IN `in_id` int, IN `in_gid` bigint, IN `in_gold` bigint, IN `in_signtime` bigint,IN `in_sign_state` int)
BEGIN
	INSERT INTO tb_guild_palace_sign(id, gid, gold, signtime,sign_state)
	VALUES (in_id, in_gid, in_gold, in_signtime,in_sign_state) 
	ON DUPLICATE KEY UPDATE id = in_id, gid = in_gid, gold = in_gold, signtime = in_signtime, sign_state = in_sign_state;
END;;
#***************************************************************
##版本281修改完成
#***************************************************************
#***************************************************************
##版本282修改完成
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equips_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equips_insert_update`;
CREATE PROCEDURE `sp_player_equips_insert_update`(IN `in_charguid` bigint, IN `in_item_id` bigint, IN `in_item_tid` int, IN `in_slot_id` int,
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
END ;;
-- ----------------------------
-- Procedure structure for sp_update_guild_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_item`;
CREATE PROCEDURE `sp_update_guild_item`(IN `in_itemgid` bigint, IN `in_gid` bigint, IN `in_itemtid` int, IN `in_strenid` int, 
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
END ;;
-- ----------------------------
-- Procedure structure for sp_update_consignment_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_consignment_item`;
CREATE PROCEDURE `sp_update_consignment_item`(IN `in_sale_guid` bigint, IN `in_char_guid` bigint, IN `in_player_name` varchar(64),
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
END;;
#***************************************************************
##版本282修改完成
#***************************************************************
#***************************************************************
##版本283修改开始
#***************************************************************
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
				IN `in_pvplevel` int, IN `in_soul_hzlevel` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, pvplevel, soul_hzlevel)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid, in_pvplevel, in_soul_hzlevel) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel, soul_hzlevel = in_soul_hzlevel;
END;;
#***************************************************************
##版本283修改完成
#***************************************************************
#***************************************************************
##版本284修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_ws_offlogic
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_ws_offlogic`;
CREATE PROCEDURE `sp_update_ws_offlogic`(IN `in_aid` bigint, IN `in_charguid` bigint, IN `in_type` int, 
			IN `in_param_b1` bigint, IN `in_param_b2` bigint,
	 		IN `in_param1` int, IN `in_param2` int,
	 		IN `in_param_str` varchar(32), IN `in_time` bigint)
BEGIN
	INSERT INTO tb_ws_offline_logic(aid, charguid, type, param_b1, param_b2, param1, param2, param_str, save_time)
	VALUES (in_aid, in_charguid, in_type, in_param_b1, in_param_b2, in_param1, in_param2, in_param_str, in_time) 
	ON DUPLICATE KEY UPDATE charguid=in_charguid, type=in_type, param_b1=in_param_b1, param_b2=in_param_b2,
		param1=in_param1, param2=in_param2, param_str = in_param_str, save_time = in_time;
END;;
#***************************************************************
##版本284修改完成
#***************************************************************

#***************************************************************
##版本285修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_party_group_charge
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_party_group_charge`;
CREATE PROCEDURE `sp_select_party_group_charge`()
BEGIN
	select * from tb_group_charge;
END;;

-- ----------------------------
-- Procedure structure for sp_update_party_group_charge
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_party_group_charge`;
CREATE PROCEDURE `sp_update_party_group_charge`(IN `in_id` int, IN `in_cnt` int, IN `in_extracnt` int)
BEGIN
	INSERT INTO tb_group_charge(id, cnt, extracnt)
	VALUES (in_id, in_cnt, in_extracnt) 
	ON DUPLICATE KEY UPDATE id=in_id, cnt=in_cnt, extracnt=in_extracnt;
END;;

-- ----------------------------
-- Procedure structure for sp_select_cross_boss_history
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_cross_boss_history`;
CREATE PROCEDURE `sp_select_cross_boss_history`()
BEGIN
	select * from tb_crossboss_history;
END;;

-- ----------------------------
-- Procedure structure for sp_update_cross_boss_history
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_cross_boss_history`;
CREATE PROCEDURE `sp_update_cross_boss_history`(IN `in_id` int, IN `in_avglv` int, 
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
END;;


-- ----------------------------
-- Procedure structure for sp_relation_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_relation_select_by_id`;
CREATE PROCEDURE `sp_relation_select_by_id`(IN `in_charguid` bigint)
BEGIN
  SELECT * FROM tb_relation WHERE charguid=in_charguid and relation_type <> 0 ;
END;;

#***************************************************************
##版本285修改完成
#***************************************************************

#***************************************************************
##版本286修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_platform_select_role_info`;
CREATE PROCEDURE `sp_platform_select_role_info`(IN `in_account` VARCHAR(32), IN `in_groupid` int)
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account and groupid = in_groupid;
END;;
DROP PROCEDURE IF EXISTS `sp_update_forbidden_acc_by_acc`;
CREATE PROCEDURE `sp_update_forbidden_acc_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_acc_last` int, IN `in_forb_acc_time` int, IN `in_groupid` int)
BEGIN
	UPDATE tb_account SET  forb_acc_last = in_forb_acc_last, forb_acc_time = in_forb_acc_time
	WHERE account = in_account and groupid = in_groupid;
END;;
DROP PROCEDURE IF EXISTS `sp_update_forbidden_chat_by_acc`;
CREATE PROCEDURE `sp_update_forbidden_chat_by_acc`(IN `in_account` VARCHAR(32), IN `in_forb_chat_last` int, IN `in_forb_chat_time` int, IN `in_groupid` int)
BEGIN
	UPDATE tb_account SET  forb_chat_last = in_forb_chat_last, forb_chat_time = in_forb_chat_time
	WHERE account = in_account and groupid = in_groupid;
END;;
DROP PROCEDURE IF EXISTS `sp_platform_select_role_little_info`;
CREATE PROCEDURE `sp_platform_select_role_little_info`(IN `in_account` VARCHAR(32), IN `in_groupid` int)
BEGIN
	SELECT * FROM tb_player_info left join tb_account
	on tb_player_info.charguid = tb_account.charguid
	left join tb_player_map_info
	on tb_player_map_info.charguid = tb_account.charguid
	WHERE account = in_account and groupid = in_groupid;
END;;
#***************************************************************
##版本286修改完成
#***************************************************************
#***************************************************************
##版本287修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_update_zhenbaoge
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_update_zhenbaoge`;
CREATE  PROCEDURE `sp_player_update_zhenbaoge`(IN `in_charguid` bigint, IN `in_zhenbao_id` int, IN `in_submit_once_num` int,IN `in_submit_times` int, IN `in_submit_num` int, IN `in_special_item_num1` int, 
	IN `in_special_item_num2` int, IN `in_special_item_num3` int, IN `in_zhenbao_process` int, IN `in_zhenbao_break_num` int)
BEGIN
	INSERT INTO tb_zhenbaoge(charguid, zhenbao_id, submit_once_num, submit_times, submit_num, item_num1, item_num2, item_num3, zhenbao_process, zhenbao_break_num)
	VALUES (in_charguid, in_zhenbao_id, in_submit_once_num, in_submit_times, in_submit_num, in_special_item_num1, in_special_item_num2, in_special_item_num3, in_zhenbao_process, in_zhenbao_break_num)
	ON DUPLICATE KEY UPDATE charguid = in_charguid,zhenbao_id = in_zhenbao_id, submit_once_num=in_submit_once_num, submit_times = in_submit_times, submit_num = in_submit_num, 
	item_num1 = in_special_item_num1, item_num2 = in_special_item_num2, item_num3 = in_special_item_num3, zhenbao_process = in_zhenbao_process, zhenbao_break_num = in_zhenbao_break_num;
END
;;
#***************************************************************
##版本287修改完成
#***************************************************************
#***************************************************************
##版本288修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_guild_mail_time
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_guild_mail_time`;
CREATE  PROCEDURE `sp_update_guild_mail_time`(IN `in_SendTime` BIGINT)
BEGIN
	REPLACE INTO tb_LastGuildWarMailTime(id, nLastSendTime) VALUES (1, in_SendTime);
END
;;
-- ----------------------------
-- Procedure structure for sp_select_last_guild_mail_time
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_last_guild_mail_time`;
CREATE PROCEDURE `sp_select_last_guild_mail_time`()
BEGIN
  SELECT * FROM tb_LastGuildWarMailTime;
END;;
#***************************************************************
##版本288修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本289修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_wingstren_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wingstren_select_by_id`;
CREATE PROCEDURE `sp_player_wingstren_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_wingstren WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_player_wingstren_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wingstren_insert_update`;
CREATE PROCEDURE `sp_player_wingstren_insert_update`(IN `in_charguid` bigint, IN `in_wing_stren_level` int, IN `in_wing_stren_process` int)
BEGIN
	INSERT INTO tb_wingstren(charguid, wing_stren_level, wing_stren_process)
	VALUES (in_charguid, in_wing_stren_level, in_wing_stren_process) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, wing_stren_level = in_wing_stren_level,	wing_stren_process = in_wing_stren_process;
END;;

#***************************************************************
##版本289修改完成
#***************************************************************
#***************************************************************
##版本290修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_shengling_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shengling_insert_update`;
CREATE PROCEDURE `sp_player_shengling_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_shengling(charguid, level, process, sel, proce_num, total_proce, attrdan)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num, total_proce = in_total_proce, attrdan = in_attrdan;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shengling_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shengling_select_by_id`;
CREATE PROCEDURE `sp_player_shengling_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shengling WHERE charguid=in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shenglingskins_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_insert_update`;
CREATE PROCEDURE `sp_player_shenglingskins_insert_update`(IN `in_charguid` bigint, IN `in_skin_id` int, IN `in_skin_time` bigint)
BEGIN
	INSERT INTO tb_player_shengling_skin(charguid, skin_id, skin_time)
	VALUES (in_charguid, in_skin_id, in_skin_time) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, skin_id = in_skin_id, skin_time = in_skin_time;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shenglingskins_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenglingskins_select_by_id`;
CREATE PROCEDURE `sp_player_shenglingskins_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shengling_skin WHERE charguid = in_charguid;
END ;;
#***************************************************************
##版本290修改完成
#***************************************************************
#***************************************************************
##版本291修改开始
#***************************************************************
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
				IN `in_pvplevel` int, IN `in_soul_hzlevel` int, IN `in_other_money` bigint)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, 
								pvplevel, soul_hzlevel, other_money)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid,
			in_pvplevel, in_soul_hzlevel, in_other_money) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel, soul_hzlevel = in_soul_hzlevel, other_money = in_other_money;
END;;
#***************************************************************
##版本291修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本292修改开始
#***************************************************************
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_select_ws_human_info`;
CREATE PROCEDURE `sp_select_ws_human_info`(IN `in_charguid` bigint)
BEGIN
	SELECT P.charguid,P.level,P.name,P.prof,P.blesstime, M.base_map,M.game_map,P.blesstime2,P.blesstime3,P.HBCheatNum
	FROM tb_player_info AS P,tb_player_map_info AS M where in_charguid = P.charguid AND in_charguid = M.charguid;
END;;
DROP PROCEDURE IF EXISTS `sp_update_cheat_num`;
CREATE PROCEDURE `sp_update_cheat_num`(IN `in_charguid` bigint, IN `in_HBCheatNum` int)
BEGIN
	update tb_player_info set HBCheatNum = in_HBCheatNum where in_charguid = charguid;
END;;
#***************************************************************
##版本292修改完成
#***************************************************************
#***************************************************************
##版本293修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_update_festival_activity
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_festival_activity`;
CREATE PROCEDURE `sp_update_festival_activity`(IN `in_id` bigint, IN `in_festival_param` int)
BEGIN
	INSERT INTO tb_festivalact(id, festival_param)
	VALUES (in_id, in_festival_param) 
	ON DUPLICATE KEY UPDATE id = in_id, festival_param = in_festival_param;
END ;;
-- ----------------------------
-- Procedure structure for sp_select_festival_activity
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_festival_activity`;
CREATE PROCEDURE `sp_select_festival_activity`()
BEGIN
  SELECT * FROM tb_festivalact;
END;;
#***************************************************************
##版本293修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本294修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_rank_lingshou()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_rank_lingshou`;
CREATE PROCEDURE `sp_rank_lingshou`()
BEGIN
	SELECT tb_player_wuhuns.charguid AS uid, wuhun_id AS rankvalue FROM tb_player_wuhuns left join tb_player_info
	on tb_player_wuhuns.charguid = tb_player_info.charguid
	WHERE wuhun_id > 0 ORDER BY wuhun_id DESC, cur_hunzhu DESC, wuhun_progress DESC, wuhun_wish DESC, tb_player_info.power DESC LIMIT 100;
END;;
-- ----------------------------
-- Procedure structure for sp_select_all_arena_history()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_all_arena_history`;
CREATE PROCEDURE `sp_select_all_arena_history`()
BEGIN
	SELECT * FROM tb_crossarena_history;
END;;
-- ----------------------------
-- Procedure structure for sp_update_cross_arena_history()
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_cross_arena_history`;
CREATE PROCEDURE `sp_update_cross_arena_history`(IN `in_seasonid` int, IN `in_arenaid` int, IN `in_name` varchar(64), IN `in_prof` int, IN `in_power` bigint(20))
BEGIN
  INSERT INTO tb_crossarena_history(seasonid, arenaid, name, prof, power)
  VALUES (in_seasonid, in_arenaid, in_name, in_prof, in_power) 
  ON DUPLICATE KEY UPDATE seasonid=in_seasonid, arenaid=in_arenaid, name=in_name, prof=in_prof, power=in_power;
END;;

#***************************************************************
##版本294修改完成
#***************************************************************
#***************************************************************
##版本295修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_shenbing_insert_update`;
CREATE PROCEDURE `sp_player_shenbing_insert_update`(IN `in_charguid` bigint, IN `in_level` int, IN `in_wish` int, IN `in_proficiency` int
, IN `in_proficiencylvl` int, IN `in_procenum` int, IN `in_skinlevel` int, IN `in_attr_num` int, IN `in_bingling` varchar(300))
BEGIN
  INSERT INTO tb_player_shenbing(charguid, level, wish, proficiency, proficiencylvl, procenum,skinlevel,attr_num,bingling)
  VALUES (in_charguid, in_level, in_wish, in_proficiency, in_proficiencylvl, in_procenum, in_skinlevel,in_attr_num, in_bingling) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, level=in_level, wish=in_wish, proficiency=in_proficiency, proficiencylvl=in_proficiencylvl
  , procenum=in_procenum,skinlevel = in_skinlevel,attr_num = in_attr_num,bingling = in_bingling;
END ;;
#***************************************************************
##版本295修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本296修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_shenwu_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenwu_select_by_id`;
CREATE PROCEDURE `sp_player_shenwu_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_shenwu WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_player_shenwu_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shenwu_insert_update`;
CREATE PROCEDURE `sp_player_shenwu_insert_update`(IN `in_charguid` bigint, IN `in_shenwu_level` int,
 IN `in_shenwu_star` int, IN `in_shenwu_stone` int, IN `in_shenwu_failnum` int)
BEGIN
	INSERT INTO tb_player_shenwu(charguid, shenwu_level, shenwu_star, shenwu_stone, shenwu_failnum)
	VALUES (in_charguid, in_shenwu_level, in_shenwu_star, in_shenwu_stone, in_shenwu_failnum) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shenwu_level = in_shenwu_level,	shenwu_star = in_shenwu_star, 
	shenwu_stone = in_shenwu_stone, shenwu_failnum = in_shenwu_failnum;
END;;

#***************************************************************
##版本296修改完成
#***************************************************************
#***************************************************************
##版本297修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_all_merge_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_all_merge_info`;
CREATE PROCEDURE `sp_select_all_merge_info`()
BEGIN
	SELECT * FROM tb_merge;
END;;

-- ----------------------------
-- Procedure structure for sp_select_merge_cnt
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_merge_cnt`;
CREATE PROCEDURE `sp_select_merge_cnt`()
BEGIN
	SELECT min(cnt) AS cnt FROM tb_merge;
END;;

-- ----------------------------
-- Procedure structure for sp_update_merge_info
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_merge_info`;
CREATE PROCEDURE `sp_update_merge_info`(IN `in_srvid` int, IN `in_mergeid` int, IN `in_cnt` int)
BEGIN
	INSERT INTO tb_merge(srvid, mergeid, cnt)
	VALUES (in_srvid, in_mergeid, in_cnt) 
	ON DUPLICATE KEY UPDATE srvid = in_srvid, mergeid = in_mergeid,	cnt = in_cnt;
END;;

#***************************************************************
##版本297修改完成
#***************************************************************
#***************************************************************
##版本298修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_cross_arena_xiazhu
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_cross_arena_xiazhu`;
CREATE PROCEDURE `sp_select_cross_arena_xiazhu`(IN `in_seasonid` int)
BEGIN
	SELECT * FROM tb_crossarena_xiazhu WHERE seasonid = in_seasonid;
END;;

-- ----------------------------
-- Procedure structure for sp_update_cross_arena_xiazhu
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_cross_arena_xiazhu`;
CREATE PROCEDURE `sp_update_cross_arena_xiazhu`(IN `in_charguid` bigint, IN `in_seasonid` int, IN `in_targetguid` bigint, IN `in_xiazhunum` int)
BEGIN
	INSERT INTO tb_crossarena_xiazhu(charguid, seasonid, targetguid, xiazhunum)
	VALUES (in_charguid, in_seasonid, in_targetguid, in_xiazhunum) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, seasonid = in_seasonid,	targetguid = in_targetguid, xiazhunum = in_xiazhunum;
END;;

-- ----------------------------
-- Procedure structure for sp_delete_cross_arena_xiazhu
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_delete_cross_arena_xiazhu`;
CREATE PROCEDURE `sp_delete_cross_arena_xiazhu`(IN `in_seasonid` int)
BEGIN
	DELETE FROM tb_crossarena_xiazhu WHERE seasonid = in_seasonid;
END;;

#***************************************************************
##版本298修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本299修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_mail_info_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_mail_info_by_id`;
CREATE PROCEDURE `sp_select_mail_info_by_id`(IN `in_charguid` bigint, IN `in_createtime` bigint)
BEGIN
	DECLARE cur_time bigint DEFAULT '0';
	SET cur_time = UNIX_TIMESTAMP(now());
	
	SELECT * FROM (SELECT IFNULL(tb_mail.charguid, 0) AS guid, IFNULL(tb_mail.readflag, 0) AS readflag, IFNULL(tb_mail.deleteflag, 0) AS deleteflag, 
		IFNULL(tb_mail.recvflag, 0) AS recvflag, tb_mail_content.* FROM tb_mail RIGHT JOIN tb_mail_content 
	ON tb_mail.mailgid = tb_mail_content.mailgid AND tb_mail_content.validtime > cur_time WHERE charguid = in_charguid AND deleteflag = 0
	UNION ALL
	SELECT 0, 0, 0, 0, tb_mail_content.* FROM tb_mail_content WHERE refflag = 1 AND tb_mail_content.validtime > cur_time AND tb_mail_content.sendtime > in_createtime AND NOT EXISTS 
	(SELECT tb_mail.mailgid FROM tb_mail WHERE tb_mail_content.mailgid = tb_mail.mailgid AND charguid = in_charguid))t ORDER BY validtime DESC;
END;;
#***************************************************************
##版本299修改完成
#***************************************************************
#***************************************************************
##版本300修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_marryInfo
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marryInfo_select`;
CREATE PROCEDURE `sp_player_marryInfo_select`(IN `in_charguid` bigint(20))
BEGIN
	SELECT * FROM tb_player_marry_info WHERE charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_marryInfo_replace
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marryInfo_replace`;
CREATE PROCEDURE `sp_player_marryInfo_replace`(IN `in_charguid` bigint(20), IN `in_mateguid` bigint(20), IN `in_marryState` int(11), 
											   IN `in_marryTime` bigint(20), IN `in_marryType` int(11), IN `in_marryTraveled` int(11), 
											   IN `in_marryDinnered` int(11), IN `in_marryRingCfgId` int(11), IN `in_marryIntimate` int(11))
BEGIN
	REPLACE INTO tb_player_marry_info(charguid, mateguid, marryState, marryTime, marryType, marryTraveled, marryDinnered, marryRingCfgId, marryIntimate) 
	VALUES (in_charguid, in_mateguid, in_marryState, in_marryTime, in_marryType, in_marryTraveled, in_marryDinnered, in_marryRingCfgId, in_marryIntimate);
END;;

-- ----------------------------
-- Procedure structure for sp_player_marryInfo_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marryInfo_update`;
CREATE PROCEDURE `sp_player_marryInfo_update`(IN `in_charguid` bigint(20))
BEGIN
	UPDATE tb_player_marry_info SET marryTime = 0, marryType = 0, marryTraveled = 0, marryDinnered = 0 WHERE charguid = in_charguid;
END;;



-- ----------------------------
-- Procedure structure for sp_player_marryInfo_schedule_select
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marryInfo_schedule_select`;
CREATE PROCEDURE `sp_player_marryInfo_schedule_select`()
BEGIN
	SELECT * FROM tb_player_marry_schedule;
END;;
-- ----------------------------
-- Procedure structure for sp_player_marrySchedule_replace
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marrySchedule_replace`;
CREATE PROCEDURE `sp_player_marrySchedule_replace`(IN `in_charguid` bigint, IN `in_mateguid` bigint,    
												   IN `in_roleName` varchar(32), IN `in_mateName` varchar(32), 
												   IN `in_roleProfId` int(10), IN `in_mateProfId` int(10),
												   IN `in_scheduleId` int, IN `in_scheduleTime` bigint, 
												   IN `in_invites` varchar(2048))
BEGIN
	REPLACE INTO tb_player_marry_schedule(`charguid`, `mateguid`, `roleName`, `mateName`, `roleProfId`, `mateProfId`, `scheduleId`, `scheduleTime`, invites) 
	VALUES(in_charguid, in_mateguid, in_roleName, in_mateName, in_roleProfId, in_mateProfId, in_scheduleId, in_scheduleTime, in_invites);
END;;
-- ----------------------------
-- Procedure structure for sp_player_marrySchedule_delete
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marrySchedule_clear`;
CREATE PROCEDURE `sp_player_marrySchedule_clear`(IN `in_charguid` bigint)
BEGIN
	DELETE FROM tb_player_marry_schedule WHERE charguid = in_charguid or mateguid = in_charguid;
END;;



-- ----------------------------
-- Procedure structure for tb_player_marry_invite_card
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_query`;
CREATE PROCEDURE `sp_tb_player_marry_invite_card_query`(IN `in_charguid` bigint(20))
BEGIN
	SELECT * FROM tb_player_marry_invite_card WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_tb_player_marry_invite_card_add
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_add`;
CREATE PROCEDURE `sp_tb_player_marry_invite_card_add`(IN `in_charguid` bigint(20), IN `in_mailGid` bigint(20), IN `in_inviteTime` bigint(20)
													 ,IN `in_scheduleId` int(10), IN `in_inviteRoleName` varchar(32), IN `in_inviteMateName` varchar(32)
													 ,IN `in_profId` int(10))
BEGIN
	REPLACE INTO tb_player_marry_invite_card(charguid, mailGid, inviteTime, scheduleId, inviteRoleName, inviteMateName, profId) 
	VALUES(in_charguid, in_mailGid, in_inviteTime, in_scheduleId, in_inviteRoleName, in_inviteMateName, in_profId);
END;;
-- ----------------------------
-- Procedure structure for sp_tb_player_marry_invite_card_delete
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_tb_player_marry_invite_card_delete`;
CREATE PROCEDURE `sp_tb_player_marry_invite_card_delete`(IN `in_mailGid` bigint(20))
BEGIN
	DELETE FROM tb_player_marry_invite_card WHERE mailGid = in_mailGid AND inviteTime = 0;
END;;

-- ----------------------------
-- Procedure structure for sp_player_marryInfo_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_marryInfo_update_except_type`;
CREATE PROCEDURE `sp_player_marryInfo_update_except_type`(IN `in_charguid` bigint(20), IN `in_marryTime` bigint(20), IN `in_marryTraveled` int(11), IN `in_marryDinnered` int(11))
BEGIN
	UPDATE tb_player_marry_info SET marryTime = in_marryTime, marryTraveled = in_marryTraveled, marryDinnered = in_marryDinnered WHERE charguid = in_charguid;
END;;

-- ----------------------------
-- Procedure structure for sp_player_items
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_items_insert_update`;
CREATE PROCEDURE `sp_player_items_insert_update`(IN `in_charguid` bigint(20), IN `in_item_id` bigint, IN `in_item_tid` int, 
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
END;;
#***************************************************************
##版本300修改完成
#***************************************************************
#***************************************************************
##版本301修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_yuanling_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_yuanling_insert_update`;
CREATE PROCEDURE `sp_player_yuanling_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_yuanling(charguid, level, process, sel, proce_num, total_proce, attrdan)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num, total_proce = in_total_proce, attrdan = in_attrdan;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_yuanling_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_yuanling_select_by_id`;
CREATE PROCEDURE `sp_player_yuanling_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_yuanling WHERE charguid=in_charguid;
END ;;
#***************************************************************
##版本301修改完成
#***************************************************************
#***************************************************************
##版本302修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_Realm_Strenthen_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_Realm_Strenthen_select_by_id`;
CREATE PROCEDURE `sp_Realm_Strenthen_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_Realm_Strenthen WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_realm_strenthen_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_realm_strenthen_insert_update`;
CREATE PROCEDURE `sp_realm_strenthen_insert_update`(IN `in_charguid` bigint, IN `in_strenthen_id` int,
 IN `in_select_id` int, IN `in_progress` int)
BEGIN
	INSERT INTO tb_Realm_Strenthen(charguid, strenthen_id, select_id, progress)
	VALUES (in_charguid, in_strenthen_id, in_select_id, in_progress)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, strenthen_id = in_strenthen_id,	select_id = in_select_id, 
	progress = in_progress;
END;;
#***************************************************************
##版本302修改完成
#***************************************************************
#***************************************************************
#***************************************************************
#***************************************************************
##版本303修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_realm_strenthen_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_realm_strenthen_insert_update`;
CREATE PROCEDURE `sp_realm_strenthen_insert_update`(IN `in_charguid` bigint, IN `in_strenthen_id` int,
 IN `in_select_id` int, IN `in_progress` int, IN `in_break_id` int)
BEGIN
	INSERT INTO tb_Realm_Strenthen(charguid, strenthen_id, select_id, progress, break_id)
	VALUES (in_charguid, in_strenthen_id, in_select_id, in_progress, in_break_id)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, strenthen_id = in_strenthen_id,	select_id = in_select_id, 
	progress = in_progress, break_id = in_break_id;
END;;
#***************************************************************
##版本303修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本304修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_yuanling_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_yuanling_insert_update`;
CREATE PROCEDURE `sp_player_yuanling_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int, IN `in_secs` int, IN `in_dianshu` int, IN `in_dunstate` int)
BEGIN
	INSERT INTO tb_player_yuanling(charguid, level, process, sel, proce_num, total_proce, attrdan,secs,dianshu,dunstate)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan,in_secs,in_dianshu,in_dunstate)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num
	, total_proce = in_total_proce, attrdan = in_attrdan, secs = in_secs, dianshu = in_dianshu, dunstate = in_dunstate;
END ;;
#***************************************************************
##版本304修改完成
#***************************************************************
#***************************************************************
##版本305修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_set_gm_account
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_set_gm_account`;
CREATE PROCEDURE `sp_set_gm_account`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_oper` varchar(32), IN `in_time` int)
BEGIN
	INSERT INTO tb_gm_account(charguid, gm_level, oper, oper_time)
	VALUES (in_charguid, in_lvl, in_oper, in_time)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, gm_level = in_lvl, oper = in_oper, oper_time = in_time;
END;;
-- ----------------------------
-- Procedure structure for sp_select_gm_account_list
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gm_account_list`;
CREATE PROCEDURE `sp_select_gm_account_list`()
BEGIN
	SELECT tb_gm_account.gm_level, tb_account.charguid, tb_account.account, tb_player_info.name 
	FROM tb_account, tb_player_info, tb_gm_account 
	WHERE tb_gm_account.gm_level > 0 
	AND tb_player_info.charguid = tb_account.charguid
	AND tb_gm_account.charguid = tb_account.charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_select_gm_account
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_gm_account`;
CREATE PROCEDURE `sp_select_gm_account`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_gm_account 
	WHERE charguid = in_charguid; 
END;;
#***************************************************************
##版本305修改完成
#***************************************************************
#***************************************************************
##版本306修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_binghun_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_binghun_insert_update`;
CREATE PROCEDURE `sp_player_binghun_insert_update`(IN `in_charguid` bigint, IN `in_id` int, IN `in_state` int, IN `in_current` int,
	IN `in_activetime` bigint,IN `in_time_stamp` bigint,IN `in_shenghun` varchar(256),IN `in_hole` int)
BEGIN
  INSERT INTO tb_player_binghun(charguid, id, state, current,activetime,time_stamp, shenghun, shenghun_hole)
  VALUES (in_charguid, in_id, in_state, in_current,in_activetime,in_time_stamp,in_shenghun,in_hole) 
  ON DUPLICATE KEY UPDATE charguid=in_charguid, id=in_id, state=in_state, current=in_current,
	activetime=in_activetime,time_stamp=in_time_stamp,shenghun=in_shenghun,shenghun_hole=in_hole;
END;;
#***************************************************************
#***************************************************************
##版本306修改完成
#***************************************************************
#***************************************************************
##版本307修改完成
#**************************************************************
-- ----------------------------
-- Procedure structure for sp_insert_update_player_ls_horse
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_insert_update_player_ls_horse`;
CREATE PROCEDURE `sp_insert_update_player_ls_horse`(IN `in_charguid` bigint, IN `in_lshorse_step` int,
IN `in_lshorse_process` int, IN `in_lshorse_procenum` int, IN `in_lshorse_totalproce` int, IN `in_lshorse_attr` int)
BEGIN
	INSERT INTO tb_player_ls_horse(charguid, lshorse_step, lshorse_process, lshorse_procenum, lshorse_totalproce, lshorse_attr)
	VALUES (in_charguid, in_lshorse_step, in_lshorse_process, in_lshorse_procenum, in_lshorse_totalproce, in_lshorse_attr) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lshorse_step = in_lshorse_step,	lshorse_process = in_lshorse_process,
	 lshorse_procenum = in_lshorse_procenum, lshorse_totalproce = in_lshorse_totalproce, lshorse_attr = in_lshorse_attr;
END;;
#***************************************************************
##版本307修改完成
#***************************************************************
#***************************************************************
##版本308修改开始
#***************************************************************
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
				IN `in_pvplevel` int, IN `in_soul_hzlevel` int, IN `in_other_money` bigint, IN `in_wash_luck` int)
BEGIN
	INSERT INTO tb_player_info(charguid, name, level, exp, vip_level, vip_exp,
								power, hp, mp, hunli, tipo, shenfa, jingshen, 
								leftpoint, totalpoint, sp, max_sp, sp_recover,bindgold,
								unbindgold, bindmoney, unbindmoney,zhenqi, soul, pk_mode, pk_status,
								pk_flags, pk_evil, redname_time, grayname_time, pk_count, yao_hun, 
								arms, dress, online_time, head, suit, weapon, drop_val, drop_lv, 
								killtask_count, onlinetime_day, honor,hearthstone_time,lingzhi,jingjie_exp,
								vplan, blesstime,equipval, wuhunid, shenbingid,extremityval, wingid,
								blesstime2, blesstime3, suitflag, crossscore, crossexploit, crossseasonid, 
								pvplevel, soul_hzlevel, other_money, wash_lucky)
	VALUES (in_id, in_name, in_level, in_exp, in_vip_level, in_vip_exp,
			in_power, in_hp, in_mp, in_hunli, in_tipo, in_shenfa, in_jingshen, 
			in_leftpoint, in_totalpoint, in_sp, in_max_sp, in_sp_recover, in_bindgold, 
			in_unbindgold, in_bindmoney, in_unbindmoney, in_zhenqi, in_soul, in_pk_mode, in_pk_status,
			in_pk_flags,in_pk_evil, in_redname_time, in_grayname_time, in_pk_count, in_yao_hun, in_arms, 
			in_dress, in_online_time, in_head, in_suit, in_weapon, in_drop_val, in_drop_lv, in_killtask_count,
			in_onlinetime_day, in_honor,in_hearthstone_time,in_lingzhi,in_jingjie_exp,
			in_vplan, in_blesstime,in_equipval, in_wuhunid, in_shenbingid,in_extremityval, in_wingid, 
			in_blesstime2, in_blesstime3, in_suitflag, in_crossscore, in_crossexploit, in_crossseasonid,
			in_pvplevel, in_soul_hzlevel, in_other_money, in_wash_luck) 
	ON DUPLICATE KEY UPDATE name=in_name, level=in_level, exp = in_exp, vip_level = in_vip_level, vip_exp = in_vip_exp,
		power=in_power, hp=in_hp, mp=in_mp, hunli=in_hunli, tipo=in_tipo, shenfa=in_shenfa, jingshen=in_jingshen, 
		leftpoint=in_leftpoint, totalpoint=in_totalpoint, sp = in_sp, max_sp = in_max_sp, sp_recover = in_sp_recover, bindgold=in_bindgold, 
		unbindgold=in_unbindgold, bindmoney=in_bindmoney, unbindmoney=in_unbindmoney, zhenqi=in_zhenqi, soul = in_soul, pk_mode=in_pk_mode, pk_status = in_pk_status,
		pk_flags = in_pk_flags, pk_evil = in_pk_evil, redname_time = in_redname_time, grayname_time = in_grayname_time, pk_count = in_pk_count, yao_hun=in_yao_hun,
		arms = in_arms, dress = in_dress, online_time = in_online_time, head = in_head, suit = in_suit, weapon = in_weapon, drop_val = in_drop_val, drop_lv = in_drop_lv, 
		killtask_count = in_killtask_count, onlinetime_day=in_onlinetime_day, honor = in_honor,hearthstone_time=in_hearthstone_time,lingzhi=in_lingzhi,jingjie_exp=in_jingjie_exp,vplan=in_vplan,
		blesstime = in_blesstime,equipval = in_equipval, wuhunid = in_wuhunid, shenbingid = in_shenbingid, extremityval = in_extremityval, wingid = in_wingid,
		blesstime2 = in_blesstime2, blesstime3 = in_blesstime3, suitflag = in_suitflag, crossscore = in_crossscore, crossexploit = in_crossexploit,
		crossseasonid = in_crossseasonid, pvplevel = in_pvplevel, soul_hzlevel = in_soul_hzlevel, other_money = in_other_money, wash_lucky = in_wash_luck;
END;;
#***************************************************************
##版本308修改完成
#***************************************************************
#***************************************************************
##版本309修改开始
#***************************************************************
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
END;;
-- ----------------------------
-- Procedure structure for sp_insert_update_player_ls_horse
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_change_role_name`;
CREATE PROCEDURE `sp_change_role_name`(IN `in_charguid` bigint, IN `in_name` varchar(64))
BEGIN
	UPDATE tb_player_info SET name = in_name WHERE charguid = in_charguid;
END;;
#***************************************************************
##版本309修改完成
#***************************************************************
#***************************************************************
##版本310修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_lunpan_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_lunpan_select_by_id`;
CREATE PROCEDURE `sp_player_lunpan_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT *  FROM tb_player_lunpan WHERE charguid = in_charguid;
END;;
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_lunpan_insert_update`;
CREATE PROCEDURE `sp_lunpan_insert_update`(IN `in_charguid` bigint,  IN `in_lunpan_attr` varchar(128), IN `in_lunpan_num` int)
BEGIN
	INSERT INTO tb_player_lunpan(charguid, lunpan_attr, lunpan_num)
	VALUES (in_charguid, in_lunpan_attr, in_lunpan_num)
	ON DUPLICATE KEY UPDATE charguid=in_charguid, lunpan_attr=in_lunpan_attr, lunpan_num = in_lunpan_num;
END;;
#***************************************************************
##版本310修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本311修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_equip_pos_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equip_pos_insert_update`;
CREATE PROCEDURE `sp_player_equip_pos_insert_update`(IN `in_charguid` bigint, IN `in_pos` int, IN `in_idx` int, IN `in_groupid` int, IN `in_lvl` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_equip_pos(charguid, pos,idx,groupid,lvl,time_stamp)
	VALUES (in_charguid, in_pos,in_idx,in_groupid,in_lvl,in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, pos = in_pos, idx = in_idx, groupid = in_groupid, lvl = in_lvl, time_stamp = in_time_stamp;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_equip_pos_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equip_pos_select_by_id`;
CREATE PROCEDURE `sp_player_equip_pos_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_equip_pos WHERE charguid=in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_equip_pos_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_equip_pos_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_equip_pos_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM `tb_player_equip_pos` where charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;
#***************************************************************
##版本311修改完成
#***************************************************************
#***************************************************************
##版本312修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_wuxing_pro
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_pro`;
CREATE PROCEDURE `sp_select_player_wuxing_pro`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_wuxing_pro WHERE charguid = in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_wuxing_pro_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuxing_pro_insert_update`;
CREATE PROCEDURE `sp_player_wuxing_pro_insert_update`(IN `in_charguid` bigint, IN `in_lv` int, IN `in_progress` int)
BEGIN
	INSERT INTO tb_player_wuxing_pro(charguid, lv, progress)
	VALUES (in_charguid, in_lv, in_progress)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lv = in_lv, progress = in_progress;
END ;;
-- ----------------------------
-- Procedure structure for sp_select_player_wuxing_item
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_wuxing_item`;
CREATE PROCEDURE `sp_select_player_wuxing_item`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_wuxing_item WHERE charguid = in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_wuxing_item_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_insert_update`;
CREATE PROCEDURE `sp_player_wuxing_item_insert_update`(IN `in_charguid` bigint, IN `in_itemgid` bigint, IN `in_itemtid` int, IN `in_pos` int, IN `in_type` int,
IN `in_att1` varchar(60), IN `in_att2` varchar(60), IN `in_att3` varchar(60), IN `in_att4` varchar(60), IN `in_att5` varchar(60), IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_wuxing_item(charguid, itemgid, itemtid, pos, type, att1, att2, att3, att4, att5, time_stamp)
	VALUES (in_charguid, in_itemgid,in_itemtid,in_pos,in_type,in_att1,in_att2,in_att3,in_att4,in_att5,in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, itemtid = in_itemgid, itemtid = in_itemtid, pos = in_pos, type = in_type,
	att1 = in_att1, att2 = in_att2, att3 = in_att3, att4 = in_att4, att5 = in_att5, time_stamp = in_time_stamp;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_wuxing_item_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuxing_item_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_wuxing_item_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_wuxing_item WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;
#***************************************************************
##版本312修改完成
#***************************************************************
#***************************************************************
##版本314修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_insert_update_arena_att`;
CREATE PROCEDURE `sp_insert_update_arena_att`(IN `in_charguid` bigint, IN `in_atk` double, IN `in_hp` double, IN `in_hit` double, IN `in_dodge` double, IN `in_subdef` double
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
END;;
#***************************************************************
##版本314修改完成
#**************************************************************
#***************************************************************
##版本315修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_challenge_dupl
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_challenge_dupl`;
CREATE PROCEDURE `sp_select_player_challenge_dupl`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_challenge_dupl WHERE charguid = in_charguid;
END;;
-- ----------------------------
-- Procedure structure for sp_update_player_challenge_dupl
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_player_challenge_dupl`;
CREATE PROCEDURE `sp_update_player_challenge_dupl`(IN `in_charguid` bigint, IN `in_count` int, IN `in_today` int, IN `in_history` int)
BEGIN
	INSERT INTO tb_player_challenge_dupl(charguid, count, today, history)
	VALUES (in_charguid, in_count, in_today, in_history) 
	ON DUPLICATE KEY UPDATE charguid = in_charguid, count = in_count, today = in_today, history = in_history;
END;;
-- ----------------------------
-- Procedure structure for sp_update_ride_dupl_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_update_ride_dupl_rank`;
CREATE PROCEDURE `sp_update_ride_dupl_rank`(IN `in_rank` int, IN `in_charguid` bigint, IN `in_layer` int, IN `in_time` int, IN `in_power` bigint,
		 IN `in_name_1` varchar(32), IN `in_name_2` varchar(32), IN `in_name_3` varchar(32), IN `in_name_4` varchar(32), IN `in_type` int)
BEGIN
	INSERT INTO tb_rank_ride_dupl(rank, charguid, layer, time, power, name_1, name_2, name_3, name_4, type)
	VALUES (in_rank, in_charguid, in_layer, in_time, in_power, in_name_1, in_name_2, in_name_3, in_name_4, in_type) 
	ON DUPLICATE KEY UPDATE rank = in_rank, charguid = in_charguid, layer = in_layer, time = in_time, power = in_power, 
		name_1 = in_name_1, name_2 = in_name_2, name_3 = in_name_3, name_4 = in_name_4, type = in_type;
END;;
#***************************************************************
##版本315修改完成
#***************************************************************
#***************************************************************
##版本316修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
		IN `in_storage_online` int, IN `in_babel_count` int, IN `in_timing_count` int,IN `in_offmin` int, IN `in_awardstatus` int, 
		IN `in_vitality` varchar(350), IN `in_actcode_flags` varchar(256), IN `in_vitality_num` varchar(350), IN `in_daily_yesterday` varchar(350), IN `in_worshipstime` bigint,
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
END;;
-- ----------------------------
-- Procedure structure for sp_dimiss_guild
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_dimiss_guild`;
CREATE PROCEDURE `sp_dimiss_guild`(IN `in_guid` bigint)
BEGIN
	DELETE FROM tb_guild WHERE gid = in_guid;
	UPDATE tb_guild_mem SET gid = 0, allcontribute = 0, loyalty = 0 WHERE gid = in_guid;
	DELETE FROM tb_guild_event WHERE guid = in_guid;
	DELETE FROM tb_guild_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_aliance_apply WHERE gid = in_guid;
	DELETE FROM tb_guild_storage WHERE gid = in_guid;
	DELETE FROM tb_guild_storage_op WHERE gid = in_guid;
END;;
#***************************************************************
##版本316修改完成
#***************************************************************
#***************************************************************
##版本317修改开始
#***************************************************************
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_select_player_shouhun_info_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_select_player_shouhun_info_by_id`;
CREATE PROCEDURE `sp_select_player_shouhun_info_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shouhun WHERE charguid = in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shouhun_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shouhun_insert_update`;
CREATE PROCEDURE `sp_player_shouhun_insert_update`(IN `in_charguid` bigint, IN `in_shouhun_id` int,
 IN `in_shouhun_level` int, IN `in_shouhun_star` int, IN `in_time_stamp` bigint)
BEGIN
	INSERT INTO tb_player_shouhun(charguid, shouhun_id, shouhun_level, shouhun_star, time_stamp)
	VALUES (in_charguid, in_shouhun_id, in_shouhun_level, in_shouhun_star, in_time_stamp)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shouhun_id = in_shouhun_id, shouhun_level = in_shouhun_level, 
	shouhun_star = in_shouhun_star, time_stamp = in_time_stamp;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shouhun_delete_by_id_and_timestamp
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shouhun_delete_by_id_and_timestamp`;
CREATE PROCEDURE `sp_player_shouhun_delete_by_id_and_timestamp`(IN `in_charguid` bigint, IN `in_time_stamp` bigint)
BEGIN
  DELETE FROM tb_player_shouhun WHERE charguid = in_charguid AND time_stamp <> in_time_stamp;
END;;

-- ----------------------------
-- Procedure structure for sp_player_shouhunlv_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shouhunlv_select_by_id`;
CREATE PROCEDURE `sp_player_shouhunlv_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_shouhunlv WHERE charguid = in_charguid;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_shouhunlv_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_shouhunlv_insert_update`;
CREATE PROCEDURE `sp_player_shouhunlv_insert_update`(IN `in_charguid` bigint, IN `in_shouhun_maxlv` int,
 IN `in_shouhun_commonlv` int)
BEGIN
	INSERT INTO tb_player_shouhunlv(charguid, shouhun_maxlv, shouhun_commonlv)
	VALUES (in_charguid, in_shouhun_maxlv, in_shouhun_commonlv)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, shouhun_maxlv = in_shouhun_maxlv,
	 shouhun_commonlv = in_shouhun_commonlv;
END ;;
#***************************************************************
##版本317修改完成
#***************************************************************
#***************************************************************
#***************************************************************
##版本318修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_zhannu_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhannu_insert_update`;
CREATE PROCEDURE `sp_player_zhannu_insert_update`(IN `in_charguid` bigint, IN `in_lvl` int, IN `in_process` int, IN `in_sel` int
, IN `in_proce_num` int,IN `in_total_proce` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_zhannu(charguid, level, process, sel, proce_num, total_proce, attrdan)
	VALUES (in_charguid, in_lvl, in_process, in_sel, in_proce_num, in_total_proce, in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, level = in_lvl, process = in_process, sel = in_sel, proce_num = in_proce_num, total_proce = in_total_proce, attrdan = in_attrdan;
END ;;
-- ----------------------------
-- Procedure structure for sp_player_zhannu_select_by_id
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_zhannu_select_by_id`;
CREATE PROCEDURE `sp_player_zhannu_select_by_id`(IN `in_charguid` bigint)
BEGIN
	SELECT * FROM tb_player_zhannu WHERE charguid=in_charguid;
END ;;
#***************************************************************
##版本318修改完成
#***************************************************************
#***************************************************************
##版本319修改开始
#***************************************************************
-- ----------------------------
-- Procedure structure for sp_player_wuxing_pro_insert_update
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_player_wuxing_pro_insert_update`;
CREATE PROCEDURE `sp_player_wuxing_pro_insert_update`(IN `in_charguid` bigint, IN `in_lv` int, IN `in_progress` int, IN `in_attrdan` int)
BEGIN
	INSERT INTO tb_player_wuxing_pro(charguid, lv, progress,attrdan)
	VALUES (in_charguid, in_lv, in_progress,in_attrdan)
	ON DUPLICATE KEY UPDATE charguid = in_charguid, lv = in_lv, progress = in_progress, attrdan = in_attrdan;
END ;;
#***************************************************************
##版本319修改完成
#***************************************************************
#***************************************************************
##版本320修改开始
#***************************************************************
DROP PROCEDURE IF EXISTS `sp_player_extra_insert_update`;
CREATE PROCEDURE `sp_player_extra_insert_update`(IN `in_uid` bigint,  IN `in_func_flags` varchar(128), IN `in_expend_bag` int, IN `in_bag_online` int, IN `in_expend_storage` int, 
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
END;;
#***************************************************************
##版本320修改完成
#***************************************************************
###############################过程修改完成####################################
###############################################################################
#↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
DELIMITER ;
