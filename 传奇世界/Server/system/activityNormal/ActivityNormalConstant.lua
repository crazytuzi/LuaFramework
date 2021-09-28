--活跃度积分对应掉落ID
ACTIVENESS_DROPID = {
	[25] = 598,
	[50] = 477,
	[75] = 479,
	[100] = 478,
	[125] = 599,
}

ACTIVENESS_TYPE = {
	WORLD_BOSS = 1,		--世界BOSS
	ENVOY = 2,			--勇闯炼狱
	LOUXIA = 3,			--落霞夺宝
	MON_ATTACK = 4,		--怪物攻城
	GIVE_WINE = 5,		--王城赐福
	TULONG = 6,			--屠龙传说
	TOWER = 7,			--通天塔
	GUARD = 8,			--多人守卫
	DIGMINE = 9,		--冒险挖矿
	PRECIOUS = 10,		--远古宝藏
	DART = 11,			--护送镖车
	ZHAOLIN = 12,		--王城诏令
	XUANSHUANG = 13,	--悬赏任务
	XUANSHUANG_SEND = 14,--悬赏发布
	BIND_INGOT = 15,	--绑元购物
	INGOT = 16,			--元宝购物
	MANOR_WAR = 17,		--领地争夺战
	CENTER_WAR = 18,	--中州争夺战
	SHA_WAR = 19,		--沙城争夺战
	P3V3 = 20,			--3V3竞技场
	FLOWER = 21,		--送花
	ADORE = 22,			--膜拜沙城主
	FACTION_BOSS = 23,	--行会BOSS
	FACTION_DART = 25,	--行会物资
	INVADE = 26,		--山贼入侵
	GOU_HUO = 27,		--行会篝火
	FACTION_TASK = 28,	--行会任务
	SMELT = 101,		--熔炼装备
	KILL_MONSTER = 102,	--野外杀怪
	KILL_ELITE = 103,	--猎杀精英
	DART_INFO = 104,	--镖车物资
	MIXIANZHEN = 105,	--迷仙阵
	PVP = 200,			--公平竞技场
}
ACTIVENESS_TYPE_NAME = {
	[ACTIVENESS_TYPE.WORLD_BOSS]		= "世界BOSS",
	[ACTIVENESS_TYPE.ENVOY]				= "勇闯炼狱",
	[ACTIVENESS_TYPE.LOUXIA]			= "落霞夺宝",
	[ACTIVENESS_TYPE.MON_ATTACK]		= "怪物攻城",
	[ACTIVENESS_TYPE.GIVE_WINE]			= "王城赐福",
	[ACTIVENESS_TYPE.TULONG]			= "屠龙传说",
	[ACTIVENESS_TYPE.TOWER]				= "通天塔",
	[ACTIVENESS_TYPE.GUARD]				= "多人守卫",
	[ACTIVENESS_TYPE.DIGMINE]			= "冒险挖矿",
	[ACTIVENESS_TYPE.PRECIOUS]			= "远古宝藏",
	[ACTIVENESS_TYPE.DART]				= "护送镖车",
	[ACTIVENESS_TYPE.ZHAOLIN]			= "王城诏令",
	[ACTIVENESS_TYPE.XUANSHUANG]		= "悬赏任务",
	[ACTIVENESS_TYPE.XUANSHUANG_SEND]	= "悬赏发布",
	[ACTIVENESS_TYPE.BIND_INGOT]		= "绑元购物",
	[ACTIVENESS_TYPE.INGOT]				= "元宝购物",
	[ACTIVENESS_TYPE.MANOR_WAR]			= "领地争夺战",
	[ACTIVENESS_TYPE.CENTER_WAR]		= "中州争夺战",
	[ACTIVENESS_TYPE.SHA_WAR]			= "沙城争夺战",
	[ACTIVENESS_TYPE.P3V3]				= "3V3竞技场",
	[ACTIVENESS_TYPE.FLOWER]			= "送花",
	[ACTIVENESS_TYPE.ADORE]				= "膜拜沙城主",
	[ACTIVENESS_TYPE.FACTION_BOSS]		= "行会BOSS",
	[ACTIVENESS_TYPE.FACTION_DART]		= "行会物资",
	[ACTIVENESS_TYPE.INVADE]			= "山贼入侵",
	[ACTIVENESS_TYPE.GOU_HUO]			= "行会篝火",
	[ACTIVENESS_TYPE.FACTION_TASK]		= "行会任务",
	[ACTIVENESS_TYPE.SMELT]				= "熔炼装备",
	[ACTIVENESS_TYPE.KILL_MONSTER]		= "野外杀怪",
	[ACTIVENESS_TYPE.KILL_ELITE]		= "猎杀精英",
	[ACTIVENESS_TYPE.DART_INFO]			= "镖车物资",
	[ACTIVENESS_TYPE.MIXIANZHEN]		= "迷仙阵",
	[ACTIVENESS_TYPE.PVP]				= "公平竞技场",
}

ACTIVITY_NORMAL_ID = {
	WORLD_BOSS = 1,		--世界BOSS
	ENVOY = 2,			--勇闯炼狱
	LUOXIA = 3,			--落霞夺宝
	MON_ATTACK = 4,		--怪物攻城
	GIVE_WINE = 5,		--王城赐福
	MANOR_WAR = 6,		--领地争夺
	CENTER_WAR = 7,		--中州争夺
	SHA_WAR = 8,		--沙城争夺
	FACTION_DART = 9,	--行会物资
	GOU_HUO = 10,		--行会篝火
	INVADE = 11,		--山贼入侵
	TREASURE = 12,		--全民宝地
	PVP = 13,			--公平竞技场
}

ACTIVITY_NORMAL_ERR_CODE = {
	CAN_JOIN = 0,		--可以参加
	CLOSE = 1,			--活动未开启
	LEVEL = 2,			--等级不足
	NO_FACTION = 3,		--没有行会
	FACTION_LEVEL = 4,	--行会等级不足
}

ACTIVITY_NORMAL_GET_FIND_REWARE_TIPS = 1 --获取找回奖励提示
ACTIVITY_NORMAL_GET_ALL_FIND_REWARE_TIPS = 2 --一键获取找回奖励提示
ACTIVITY_EMAIL_GET_FIND_REWARE_TIPS = 3 --获取找回奖励通过邮件发送提示