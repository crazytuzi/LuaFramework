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

CREATE TABLE `alliance_battlelog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `round` int(10) unsigned DEFAULT '1' COMMENT '轮次',
  `defId` int(10) unsigned DEFAULT NULL COMMENT '防守方',
  `attId` int(10) unsigned NOT NULL COMMENT '攻击方',
  `attName` varchar(100) NOT NULL COMMENT '攻击方名称',
  `defName` varchar(100) DEFAULT NULL COMMENT '防守方名称',
  `attAid` varchar(50) DEFAULT NULL COMMENT '攻击方军团id',
  `defAid` varchar(50) DEFAULT NULL COMMENT '防守方军团id',
  `attAName` varchar(100) NOT NULL COMMENT '攻方军团名',
  `defAName` varchar(100) NOT NULL COMMENT '防方军团名',
  `attKills` varchar(1000) DEFAULT NULL COMMENT '攻方杀敌',
  `defKills` varchar(1000) DEFAULT NULL COMMENT '防方杀笨笨',
  `pos` varchar(50) NOT NULL COMMENT '战斗比赛组',
  `victor` int(10) unsigned NOT NULL COMMENT '胜利者',
  `placeOid` varchar(50) NOT NULL DEFAULT '0' COMMENT '发生战斗时据点占领者',
  `placeId` varchar(50) NOT NULL DEFAULT '0' COMMENT '战斗地点',
  `aPrevPlace` varchar(50) NOT NULL DEFAULT '0' COMMENT '攻方上一据点',
  `dPrevPlace` varchar(50) NOT NULL DEFAULT '0' COMMENT '防方上一据点',
  `type` tinyint(4) DEFAULT NULL COMMENT '发生的事件',
  `report` text COMMENT '详细战报',
  `aHeroAccessoryInfo` varchar(500) DEFAULT NULL COMMENT '攻方英雄与配件信息',
  `dHeroAccessoryInfo` varchar(500) DEFAULT NULL COMMENT '防方英雄与配件信息',
  `baseblood` int(10) unsigned DEFAULT NULL COMMENT '主基地耐久',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `bid` (`bid`,`round`,`pos`),
  KEY `defid` (`defId`),
  KEY `attid` (`attId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='军团跨服战战报';

CREATE TABLE `alliance_member_roundinfo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bkey` varchar(50) NOT NULL,
  `point` int(11) NOT NULL DEFAULT '0' COMMENT '结算时的积分',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bkey` (`bkey`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='用户每场的信息';

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

CREATE TABLE `alliance_roundinfo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bkey` varchar(50) NOT NULL,
  `zid` int(10) unsigned NOT NULL COMMENT '服id',
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `point` int(11) NOT NULL DEFAULT '0' COMMENT '结算时的积分',
  `kills` varchar(2000) DEFAULT NULL COMMENT '击杀情况',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bkey_aid` (`bkey`,`aid`),
  KEY `bkey` (`bkey`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='军团每场的信息';


-- 跨服军团站
-- 2015-4-13
-- lmh

ALTER TABLE `alliance_members` ADD `usegems` INT( 10 ) NOT NULL DEFAULT '0' AFTER `gems` ;

-- 世界大战
-- 2015-4-23
-- hwm
CREATE TABLE `worldwar_battlelog` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`bkey` VARCHAR(50) NOT NULL,
	`bid` VARCHAR(50) NOT NULL,
	`round` INT(10) UNSIGNED NULL DEFAULT '1' COMMENT '轮次',
	`winerId` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT '胜利者id',
	`wLevel` INT(10) NOT NULL,
	`wNickname` VARCHAR(50) NOT NULL,
	`wPic` INT(10) NOT NULL DEFAULT '0',
	`wZid` INT(10) NOT NULL,
	`wRank` INT(10) NOT NULL DEFAULT '1',
	`wAName` VARCHAR(100) NULL DEFAULT NULL COMMENT '胜利者军团名',
	`wFc` INT(10) NOT NULL DEFAULT '0',
	`wPoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '商店积分',
	`wScore` INT(10) NOT NULL DEFAULT '0' COMMENT '排行积分',
	`wStrategy` VARCHAR(50) NOT NULL DEFAULT '{}' COMMENT '策略',
	`loserId` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT '失败者id',
	`lLevel` INT(10) NULL DEFAULT NULL,
	`lNickname` VARCHAR(50) NULL DEFAULT NULL,
	`lPic` INT(10) NULL DEFAULT '0',
	`lZid` INT(10) NOT NULL,
	`lRank` INT(10) NULL DEFAULT '1',
	`lFc` INT(10) NULL DEFAULT '0',
	`lAName` VARCHAR(100) NULL DEFAULT NULL COMMENT '失败者军团名',
	`lPoint` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '商店积分',
	`lScore` INT(10) NOT NULL DEFAULT '0' COMMENT '排行积分',
	`landformInfo` VARCHAR(50) NULL DEFAULT NULL,
	`battleWiners` VARCHAR(50) NULL DEFAULT NULL,
	`lStrategy` VARCHAR(50) NOT NULL DEFAULT '{}' COMMENT '策略',
	`report1` TEXT NULL COMMENT '详细战报1',
	`report2` TEXT NULL COMMENT '详细战报2',
	`report3` TEXT NULL COMMENT '详细战报3',
	`updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `bkey` (`bkey`),
	INDEX `bid_wid` (`bid`, `winerId`, `round`),
	INDEX `bid_lid` (`bid`, `loserId`, `round`)
)
COMMENT='军团跨服战战报'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
ROW_FORMAT=COMPACT
AUTO_INCREMENT=1;

CREATE TABLE `worldwar_bid` (
	`bid` VARCHAR(50) NOT NULL,
	`matchType` TINYINT(3) UNSIGNED NOT NULL,
	`st` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	`et` INT(10) UNSIGNED NOT NULL,
	`sround` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1' COMMENT '积分赛当前进行的轮次',
	`tround` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1' COMMENT '淘汰赛当前进行的轮次',
	`landform` VARCHAR(1000) NULL DEFAULT NULL COMMENT '淘汰赛随机地形',
	`updated_at` INT(10) NOT NULL DEFAULT '0',
	UNIQUE INDEX `bid_type` (`bid`, `matchType`),
	INDEX `st_et` (`st`, `et`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

CREATE TABLE `worldwar_eliminate_battlelog` (
	`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`bkey` VARCHAR(50) NOT NULL,
	`info` TEXT NOT NULL,
	`updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	INDEX `bkey` (`bkey`)
)
COMMENT='战斗记录'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
ROW_FORMAT=COMPACT
AUTO_INCREMENT=1;

CREATE TABLE `worldwar_elite` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`uid` INT(11) NOT NULL,
	`bid` VARCHAR(50) NOT NULL,
	`zid` INT(10) NOT NULL,
	`level` INT(10) NOT NULL,
	`nickname` VARCHAR(50) NOT NULL,
	`pic` INT(10) NOT NULL DEFAULT '0',
	`rank` INT(10) NOT NULL DEFAULT '1',
	`fc` INT(10) NOT NULL DEFAULT '0',
	`aname` VARCHAR(50) NULL DEFAULT '',
	`point` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '商店积分',
	`score` INT(10) UNSIGNED NOT NULL DEFAULT '1000' COMMENT '积分赛积分',
	`pointlog` VARCHAR(500) NULL DEFAULT NULL COMMENT '积分log',
	`status` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`binfo` VARCHAR(10000) NOT NULL,
	`landform` VARCHAR(20) NULL DEFAULT NULL COMMENT '地形',
	`strategy` VARCHAR(50) NOT NULL DEFAULT '{}' COMMENT '策略',
	`heroAccessoryInfo` VARCHAR(500) NOT NULL,
	`round` INT(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT '淘汰赛轮次',
	`sround` INT(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT '积分赛轮次',
	`ranking` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '名次',
	`pos` VARCHAR(32) NULL DEFAULT NULL COMMENT '上一场匹配的位置',
	`log` VARCHAR(500) NULL DEFAULT NULL COMMENT '对阵log',
	`winStreak` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '连胜次数',
	`maxWinStreak` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '最大连胜次数',
	`winNum` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '积分赛胜利次数',
	`loseNum` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '积分赛失败次数',
	`eliminateFlag` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '淘汰赛标识',
	`apply_at` INT(10) NOT NULL,
	`battle_at` INT(10) NOT NULL DEFAULT '0',
	`updated_at` INT(10) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `uid_bid` (`bid`, `uid`),
	INDEX `score` (`score`),
	INDEX `sround` (`sround`),
	INDEX `bid_sround` (`bid`, `sround`),
	INDEX `eliminateFlag` (`eliminateFlag`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1;


CREATE TABLE `worldwar_master` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`uid` INT(11) NOT NULL,
	`bid` VARCHAR(50) NOT NULL,
	`zid` INT(10) NOT NULL,
	`level` INT(10) NOT NULL,
	`nickname` VARCHAR(50) NOT NULL,
	`pic` INT(10) NOT NULL DEFAULT '0',
	`rank` INT(10) NOT NULL DEFAULT '1',
	`fc` INT(10) NOT NULL DEFAULT '0',
	`aname` VARCHAR(50) NULL DEFAULT '',
	`point` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '商店积分',
	`score` INT(10) UNSIGNED NOT NULL DEFAULT '1000' COMMENT '积分赛积分',
	`pointlog` VARCHAR(500) NULL DEFAULT NULL COMMENT '积分log',
	`status` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
	`binfo` VARCHAR(10000) NOT NULL,
	`landform` VARCHAR(20) NULL DEFAULT NULL COMMENT '地形',
	`strategy` VARCHAR(50) NOT NULL DEFAULT '{}' COMMENT '策略',
	`heroAccessoryInfo` VARCHAR(500) NOT NULL,
	`round` INT(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT '淘汰赛轮次',
	`sround` INT(10) UNSIGNED NOT NULL DEFAULT '1' COMMENT '积分赛轮次',
	`ranking` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '名次',
	`pos` VARCHAR(32) NULL DEFAULT NULL COMMENT '上一场匹配的位置',
	`log` VARCHAR(500) NULL DEFAULT NULL COMMENT '对阵log',
	`winStreak` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '连胜次数',
	`maxWinStreak` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '最大连胜次数',
	`winNum` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '积分赛胜利次数',
	`loseNum` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0' COMMENT '积分赛失败次数',
	`eliminateFlag` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '淘汰赛标识',
	`apply_at` INT(10) NOT NULL,
	`battle_at` INT(10) NOT NULL DEFAULT '0',
	`updated_at` INT(10) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	UNIQUE INDEX `uid_bid` (`bid`, `uid`),
	INDEX `score` (`score`),
	INDEX `sround` (`sround`),
	INDEX `bid_sround` (`bid`, `sround`),
	INDEX `eliminateFlag` (`eliminateFlag`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1;

-- 修改战力字段长度
-- hwm
-- 2015-7-31 10:51
ALTER TABLE `alliance`  CHANGE COLUMN `fight` `fight` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `level`;
ALTER TABLE `alliance_members`  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `rank`;
ALTER TABLE `battle`  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `rank`;
ALTER TABLE `worldwar_battlelog`
  CHANGE COLUMN `wFc` `wFc` BIGINT NOT NULL DEFAULT '0' AFTER `wAName`,
  CHANGE COLUMN `lFc` `lFc` BIGINT NULL DEFAULT '0' AFTER `lRank`;
ALTER TABLE `worldwar_master`  CHANGE COLUMN `fc` `fc` BIGINT NOT NULL DEFAULT '0' AFTER `rank`;
ALTER TABLE `worldwar_elite`  CHANGE COLUMN `fc` `fc` BIGINT NOT NULL DEFAULT '0' AFTER `rank`;

-- 个人跨服战优化
-- hwm
-- 20160405
CREATE TABLE `battle_bid` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `bid` VARCHAR(50) NOT NULL COMMENT '跨服战标识',
  `landform` VARCHAR(3000) NOT NULL DEFAULT "" COMMENT '随机地形',
  `updated_at` INT(10) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `bid` (`bid`)
)
COMMENT='个人跨服战综合表' COLLATE='utf8_general_ci' ENGINE=InnoDB AUTO_INCREMENT=1;

ALTER TABLE `battlelog` ADD COLUMN `landform` TINYINT UNSIGNED NOT NULL DEFAULT '0' AFTER `bkey`;

ALTER TABLE `battle` ADD COLUMN `bet` varchar(500) DEFAULT NULL AFTER `log`;

ALTER TABLE `worldwar_elite` ADD COLUMN `eliminateTroopsFlag` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '淘汰赛设兵标识';
ALTER TABLE `worldwar_master` ADD COLUMN `eliminateTroopsFlag` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '淘汰赛设兵标识';

-- 军团跨服战优化
-- hwm
-- 20160621
ALTER TABLE `alliance_members` ADD COLUMN `role` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' AFTER `uid`;

-- 军团跨服战旗帜
-- hwm
-- 20170317
ALTER TABLE `alliance` ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '[]' COMMENT '军团旗帜' AFTER `name`;

-- 世界大战头像框、挂件
-- chenyunhe
-- 20170607
ALTER TABLE `worldwar_elite` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `worldwar_elite` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

ALTER TABLE `worldwar_master` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `worldwar_master` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;

ALTER TABLE `worldwar_battlelog` ADD COLUMN `wbPic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `wPic`;
ALTER TABLE `worldwar_battlelog` ADD COLUMN `waPic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `wbPic`;

ALTER TABLE `worldwar_battlelog` ADD COLUMN `lbPic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `lPic`;
ALTER TABLE `worldwar_battlelog` ADD COLUMN `laPic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `lbPic`;


ALTER TABLE `battle` ADD COLUMN `bpic` VARCHAR(20)  DEFAULT '' COMMENT '头像框' AFTER `pic`;
ALTER TABLE `battle` ADD COLUMN `apic` VARCHAR(20)  DEFAULT '' COMMENT '挂件' AFTER `bpic`;




-- 跨服区域战
-- hwm

CREATE TABLE `areawar_alliance` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主id',
  `bid` varchar(50) NOT NULL COMMENT '跨服战标识',
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `zid` int(10) unsigned NOT NULL COMMENT '服id',
  `commander` varchar(100) NOT NULL DEFAULT '' COMMENT '军团长名',
  `fight` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '战力',
  `ladderpoint` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '天梯分',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '军团名称',
  `point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获得的总积分',
  `round` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '轮次',
  `st` int(10) unsigned NOT NULL COMMENT '起始时间',
  `et` int(10) unsigned NOT NULL COMMENT '结束时间',
  `pos` varchar(32) NOT NULL DEFAULT '' COMMENT '上一轮位置',
  `servers` varchar(100) NOT NULL COMMENT '包含的服',
  `log` varchar(500) NOT NULL DEFAULT '' COMMENT '对阵log',
  `apply_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '报名时间',
  `battle_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '上次战斗时间',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_aid_zid` (`bid`,`aid`,`zid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `areawar_apply` (
  `zid` int(10) NOT NULL,
  `aid` int(10) NOT NULL,
  `bid` varchar(100) NOT NULL,
  `st` int(11) NOT NULL DEFAULT '0',
  `et` int(11) NOT NULL DEFAULT '0',
  `commander` varchar(100) NOT NULL DEFAULT '',
  `fight` bigint(20) NOT NULL,
  `score` int(11) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL,
  `servers` varchar(500) NOT NULL DEFAULT '',
  `apply_at` int(11) NOT NULL,
  `updated_at` int(11) NOT NULL,
  PRIMARY KEY (`zid`,`aid`,`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `areawar_battlelog` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(100) NOT NULL,
  `btype` varchar(10) NOT NULL,
  `attzid` int(11) unsigned NOT NULL DEFAULT '0',
  `attaid` int(11) unsigned NOT NULL DEFAULT '0',
  `attuid` int(11) unsigned NOT NULL DEFAULT '0',
  `defzid` int(11) unsigned NOT NULL DEFAULT '0',
  `defaid` int(11) unsigned NOT NULL DEFAULT '0',
  `defuid` int(11) unsigned NOT NULL DEFAULT '0',
  `attsn` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `defsn` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `attname` varchar(100) NOT NULL,
  `defname` varchar(100) NOT NULL,
  `attaname` varchar(100) NOT NULL DEFAULT '',
  `defaname` varchar(100) NOT NULL,
  `win` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `occupy` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `report` TEXT NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `attzid` (`bid`,`attzid`,`attaid`,`attuid`),
  KEY `defzid` (`bid`,`defzid`,`defaid`,`defuid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `areawar_bid` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `round_a` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'a组轮次',
  `round_b` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'b组轮次',
  `servers` varchar(100) NOT NULL COMMENT '包含的服',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid` (`bid`),
  KEY `st_et` (`st`,`et`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `areawar_members` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `aid` int(11) unsigned NOT NULL,
  `zid` int(10) unsigned NOT NULL,
  `uid` int(11) unsigned NOT NULL,
  `role` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `gems` int(10) unsigned NOT NULL DEFAULT '0',
  `usegems` int(10) NOT NULL DEFAULT '0',
  `carrygems` int(10) unsigned NOT NULL DEFAULT '0',
  `nickname` varchar(100) NOT NULL DEFAULT '',
  `pic` int(10) unsigned NOT NULL DEFAULT '0',
  `level` int(10) unsigned NOT NULL DEFAULT '1',
  `rank` int(10) unsigned NOT NULL DEFAULT '1',
  `fc` int(10) unsigned NOT NULL DEFAULT '0',
  `aname` varchar(50) NOT NULL DEFAULT '',
  `point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `donate` int(10) NOT NULL DEFAULT '0' COMMENT '功勋值',
  `b1` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '冶炼',
  `b2` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '指挥',
  `b3` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '采集',
  `b4` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '统计',
  `binfo` varchar(10000) DEFAULT '',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_uid_aid_zid` (`bid`,`uid`,`aid`,`zid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


-- wht
-- 天梯榜需要字段
ALTER TABLE `battle` ADD `aid` int(11) unsigned NOT NULL DEFAULT '0' AFTER `fc` ;
ALTER TABLE `worldwar_elite` ADD `aid` int(11) unsigned NOT NULL DEFAULT '0' AFTER `fc` ;
ALTER TABLE `worldwar_master` ADD `aid` int(11) unsigned NOT NULL DEFAULT '0' AFTER `fc` ;

-- 天梯榜开关
CREATE TABLE `skyladder_status` (
  `id` varchar(100) NOT NULL,
  `cubid` int(11) unsigned NOT NULL,
  `lsbid` int(11) unsigned NOT NULL,
  `status` int(1) unsigned NOT NULL,
  `fin` varchar(50) NOT NULL,
  `season` int(11) unsigned NOT NULL,
  `over` int(1) unsigned NOT NULL,
  `overtime` int(11) unsigned NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 历史信息表
CREATE TABLE `skyladder_list` (
  `bid` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `used` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 个人积分表
CREATE TABLE `skyladder_personinfo` (
  `id` int(11) unsigned NOT NULL,
  `bid` int(11) unsigned NOT NULL,
  `pf` varchar(100) DEFAULT NULL,
  `zid` int(4) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `fc` int(11) unsigned NOT NULL,
  `point1` int(11) NOT NULL,
  `point2` int(11) NOT NULL,
  `point3` int(11) NOT NULL,
  `point4` int(11) NOT NULL,
  `pic` int(11) unsigned NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 军团积分表
CREATE TABLE `skyladder_allianceinfo` (
  `id` int(11) unsigned NOT NULL,
  `bid` int(11) unsigned NOT NULL,
  `pf` varchar(100) NOT NULL,
  `zid` int(4) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `fc` int(11) unsigned NOT NULL,
  `point1` int(11) NOT NULL,
  `point2` int(11) NOT NULL,
  `point3` int(11) NOT NULL,
  `point4` int(11) NOT NULL,
  `pic` int(11) unsigned NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 个人log
CREATE TABLE `skyladder_personlog` (
  `id` int(11) unsigned NOT NULL,
  `bid` int(11) unsigned NOT NULL,
  `zid` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 军团log
CREATE TABLE `skyladder_alliancelog` (
  `id` int(11) unsigned NOT NULL,
  `bid` int(11) unsigned NOT NULL,
  `zid` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 天梯榜 历史信息表
CREATE TABLE `skyladder_historydata` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` int(11) unsigned NOT NULL,
  `season` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid` (`bid`)
) ENGINE=InnoDB AUTO_INCREMENT=5462 DEFAULT CHARSET=utf8;

-- 天梯榜 军团战参战成员
CREATE TABLE `skyladder_memlist` (
  `id` int(10) unsigned NOT NULL,
  `bid` int(11) unsigned NOT NULL,
  `zid` int(11) unsigned NOT NULL,
  `info` mediumtext NOT NULL,
  `updated_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`,`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `skyladder_allianceinfo`  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0';
ALTER TABLE `skyladder_personinfo`  CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0';


-- 天梯榜优化 结算保存表
-- wht
-- 2016-04-26
CREATE TABLE `skyladder_update` (
  `id` varchar(150) NOT NULL,
  `bid` int(11) NOT NULL DEFAULT '0',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `skyladder_status` ADD COLUMN `nextready` int(10) unsigned NOT NULL DEFAULT '0' AFTER `overtime`;
ALTER TABLE `skyladder_status` ADD COLUMN `nextreadytime` int(10) unsigned NOT NULL DEFAULT '0' AFTER `nextready`;

ALTER TABLE `areawar_members`
	CHANGE COLUMN `fc` `fc` BIGINT UNSIGNED NOT NULL DEFAULT '0' AFTER `rank`;


ALTER TABLE `skyladder_personinfo`
  ADD COLUMN `bpic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '头像框' AFTER `pic`,
  ADD COLUMN `apic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '挂件' AFTER `bpic`,
  ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '' AFTER `apic`;

ALTER TABLE `skyladder_allianceinfo`
  ADD COLUMN `bpic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '头像框' AFTER `pic`,
  ADD COLUMN `apic` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '挂件' AFTER `bpic`,
  ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '' AFTER `apic`;

  ALTER TABLE `skyladder_status`
	ADD COLUMN `currst` INT(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT '当前赛季起始时间' AFTER `nextreadytime`;
  
  ALTER TABLE `battle`
	ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '[]' COMMENT '军团旗帜' AFTER `aname`;

ALTER TABLE `areawar_alliance`
  ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '[]' COMMENT '军团旗帜' AFTER `name`;
ALTER TABLE `areawar_apply`
  ADD COLUMN `logo` VARCHAR(100) NOT NULL DEFAULT '[]' COMMENT '军团旗帜' AFTER `name`;


-- 跨服活动排行榜
-- lm
-- 2018-03-20
CREATE TABLE IF NOT EXISTS `crossrank` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zoneid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '服',
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家uid',
  `nickname` varchar(100) NOT NULL DEFAULT 'nickname' COMMENT '玩家名称',
  `st` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '活动开始时间',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `aid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '军团id',
  `alliancename` varchar(100) NOT NULL DEFAULT '0' COMMENT '军团名字',
  `acname` varchar(64) NOT NULL DEFAULT '' COMMENT '活动名字',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上榜时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;



-- 跨服战资比拼
-- 2018-03-14
-- chenyunhe
CREATE TABLE `zzbp` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `groupid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '当前属于哪一组',
  `zid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '服务器编号',
  `uid` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '玩家id',
  `nickname` varchar(100) NOT NULL COMMENT '玩家名称',
  `level` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '玩家等级',
  `score` int(10) unsigned NOT NULL DEFAULT 0 COMMENT '获得积分',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `groupid_zid_uid` (`groupid`,`zid`,`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- 跨服战世界大战部队字段加长
ALTER TABLE `worldwar_master`
  CHANGE COLUMN `binfo` `binfo` VARCHAR(20000) NOT NULL AFTER `status`;

ALTER TABLE `worldwar_elite`
  CHANGE COLUMN `binfo` `binfo` VARCHAR(20000) NOT NULL AFTER `status`;

-- 跨服召回码(召回玩家活动 活跃玩家生成的召回码)
-- 2018-05-31
-- chenyunhe
CREATE TABLE `recallcode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '服',
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家uid',
  `name` varchar(100) NOT NULL,
  `code` varchar(50) NOT NULL,
  `updated_at` int(11) NOT NULL DEFAULT '0',
  `st` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_zid` (`uid`,`zid`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='活跃用户的召回码(一个邀请码对应一个uid)';

-- 召回玩家充值记录
-- chenyunhe
-- 2018-05-31
CREATE TABLE IF NOT EXISTS `recalluser` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '服',
  `uid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '玩家uid',
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT '玩家名称',
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `bzid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '绑定玩家所在服',
  `buid` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '绑定玩家uid',
  `bname` varchar(100) NOT NULL DEFAULT '' COMMENT '玩家名称',
  `st` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '活动开始时间',
  `gem` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '充值钻石',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='流失用户的数据';


-- 远洋征战
-- hwm 
-- 2018-07-31
CREATE TABLE `oceanexp_battlelog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `brkey` varchar(50) NOT NULL,
  `zkey` varchar(20) NOT NULL DEFAULT '' COMMENT '头像',
  `cycle` tinyint(3) unsigned DEFAULT '1' COMMENT '小回合',
  `winnerId` int(10) unsigned DEFAULT NULL COMMENT '胜利者id',
  `wNickname` varchar(50) NOT NULL,
  `wPic` int(10) NOT NULL DEFAULT '0',
  `wbPic` varchar(20) DEFAULT '' COMMENT '头像',
  `waPic` varchar(20) DEFAULT '' COMMENT '头像',
  `wZid` int(10) NOT NULL,
  `wtid` tinyint(10) unsigned DEFAULT '1' COMMENT '胜利方的队伍id',
  `loserId` int(10) unsigned DEFAULT NULL COMMENT '失败者id',
  `lNickname` varchar(50) DEFAULT NULL,
  `lPic` int(10) DEFAULT '0',
  `lbPic` varchar(20) DEFAULT '' COMMENT 'å¤´åƒæ¡†',
  `laPic` varchar(20) DEFAULT '' COMMENT 'æŒ‚ä»¶',
  `lZid` int(10) NOT NULL,
  `ltid` tinyint(10) unsigned DEFAULT '1' COMMENT '失败方的队伍id',
  `report` text COMMENT '详细战报',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `bid_wid` (`brkey`,`winnerId`),
  KEY `bid_lid` (`brkey`,`loserId`),
  KEY `bid_round_zkey` (`brkey`,`zkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='军团跨服战战报';


CREATE TABLE `oceanexp_bid` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `round` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '当前已进行到第几轮',
  `servers` varchar(100) NOT NULL DEFAULT '[]' COMMENT '对应的游戏服',
  `st` int(10) unsigned NOT NULL DEFAULT '0',
  `et` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid` (`bid`),
  KEY `st_et` (`st`,`et`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `oceanexp_members` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL COMMENT '跨服战标识',
  `uid` int(10) unsigned NOT NULL,
  `nickname` varchar(100) NOT NULL DEFAULT 'nickname',
  `pic` int(10) unsigned NOT NULL DEFAULT '0',
  `bpic` varchar(20) DEFAULT '' COMMENT 'å¤´åƒæ¡†',
  `apic` varchar(20) DEFAULT '' COMMENT 'æŒ‚ä»¶',
  `level` int(10) unsigned NOT NULL DEFAULT '1',
  `rank` int(10) unsigned NOT NULL DEFAULT '1',
  `fc` bigint(20) unsigned NOT NULL DEFAULT '0',
  `job` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `zid` int(10) unsigned NOT NULL,
  `round` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '轮次',
  `feat` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '名次',
  `point` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `binfo` varchar(20000) NOT NULL COMMENT '部队信息',
  `log` varchar(500) NOT NULL DEFAULT '[]' COMMENT '记录参赛轮次,比分',
  `battr` varchar(500) NOT NULL DEFAULT '[]',
  `battle_at` int(10) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid` (`uid`,`zid`,`bid`),
  KEY `bid` (`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='远洋征战-成员表';

CREATE TABLE `oceanexp_team` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `zid` int(10) unsigned NOT NULL,
  `fc` bigint(20) unsigned NOT NULL DEFAULT '0',
  `flag` varchar(200) NOT NULL DEFAULT '[]' COMMENT '状态1,2,3',
  `morale` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '士气',
  `formation` varchar(50) NOT NULL DEFAULT '[]' COMMENT '阵形',
  `team0` varchar(50) NOT NULL DEFAULT '[]',
  `team1` varchar(500) NOT NULL DEFAULT '[]' COMMENT '队伍2的成员id',
  `team2` varchar(500) NOT NULL DEFAULT '[]' COMMENT '队伍3的成员id',
  `team3` varchar(500) NOT NULL DEFAULT '[]' COMMENT '队伍4的成员id',
  `team4` varchar(500) NOT NULL DEFAULT '[]' COMMENT '队伍5的成员id',
  `team5` varchar(500) NOT NULL DEFAULT '[]' COMMENT '队伍6的成员id',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '状态1,2,3',
  `log` varchar(500) NOT NULL DEFAULT '[]' COMMENT '记录参赛轮次,比分',
  `pos` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_zid` (`bid`,`zid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `oceanexp_teamlog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bkey` varchar(50) NOT NULL,
  `report` varchar(5000) DEFAULT '',
  `updated_at` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid` (`bkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 伟大航线
-- hwm
-- 2018-11-13
CREATE TABLE `greatroute_alliance` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主id',
  `bid` varchar(50) NOT NULL COMMENT '航线战标识',
  `zid` int(10) unsigned NOT NULL COMMENT '服id',
  `aid` int(10) unsigned NOT NULL COMMENT '军团id',
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '军团等级',
  `fc` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '军团战力',
  `num` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '军团成员数',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '军团名称',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获得的总积分',
  `st` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '起始时间',
  `et` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '结束时间',
  `apply_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '报名时间',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_zid_aid` (`bid`,`zid`,`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `greatroute_user` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bid` varchar(50) NOT NULL,
  `zid` int(10) unsigned NOT NULL,
  `aid` int(11) unsigned NOT NULL,
  `uid` int(11) unsigned NOT NULL,
  `pic` int(10) unsigned NOT NULL DEFAULT '0',
  `bpic` varchar(20) DEFAULT '' COMMENT '挂件',
  `apic` varchar(20) DEFAULT '' COMMENT '头像框',
  `nickname` varchar(100) NOT NULL DEFAULT '' COMMENT '玩家名',
  `aname` varchar(50) NOT NULL DEFAULT '' COMMENT '军团名',
  `level` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '等级',
  `fc` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '战力',
  `score` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获得的总积分',
  `troops` varchar(500) NOT NULL DEFAULT '{}' COMMENT '部队信息',
  `binfo` varchar(10000) DEFAULT '{}' COMMENT '部队战斗信息',
  `updated_at` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bid_zid_aid_uid` (`bid`,`zid`,`aid`,`uid`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

