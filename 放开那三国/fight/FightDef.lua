-- FileName: FightDef.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗常量定义

--战斗资源路径
BattlePath = {
	--资源图片类型
	IMAGE_PATH = "images/battle/",
	--特效资源路径
	EFFECT_PATH = "images/battle/effect/",
	--背景图片路径
	BG_PATH = "images/battle/bg/"
}

--战斗模式
BattleModel = {
	COPY  	= 1, --副本模式
	SINGLE 	= 2, --普通战斗模式
}

--战斗等级
BattleLevel = {
	NPC    = 0,	--ncp剧情
	EASY   = 1,	--简单
	NORMAL = 2,	--普通
	HARD   = 3,	--困难
}


--战斗类型
BattleType = {
	NORMAL         = 1, --普通副本
	ELITE          = 2, --精英副本
	ACTIVITY       = 3, --活动副本
	TOWER          = 4, --试炼塔
	MYSICAL_FLOOR  = 5, --神秘层
	HERO           = 6, --武将列传
	MONEY_TREE     = 7, --摇钱树
}

--战斗施法地点
AttackPos = {
	NEAR              = 1,--近身释放（近身释放一个技能）	1
	SITU              = 2,--原地 （原地释放一个技能）
	SPECIFIED         = 3,--固定地点释放（移动到指定点释放一个弹道技能）	3
	SITU_BULLET       = 4,--原地有弹道（原地释放一个弹道技能）	4
	SITU_ROW          = 5,--固定地点同行贯穿	5
	MULTI_FAR         = 6,--多段远程	6
	SITU_STRIKE       = 7,--原地刺身,(其实就是近身冲撞)	7
	SITU_MULTI_BULLET = 8,--原地不规则弹道(就是原地释放) 	8
}

--技能类型
FuntionWay = {
	NORMAL  = 1,--物理释放
	RAGE    = 2,--怒气释放
	PASSIVE = 3,--被动技能
	AURA    = 4,--光环释放
	MULIT   = 5,--复合技能
}

--打击效果挂点
AttackEffectPos = {
	HEAD,--头上
	BODY,--身上
	FOOT,--脚下
}

--战斗卡牌显示类型
CardType = {
	NORMAL     = 1,	--普通卡牌
	BOSS       = 2, --boss大卡牌
	BLACK_BOSS = 3, --boss黑底大卡牌
	GOD_BOSS   = 4, --只有一个的boss卡牌，如摇钱树，世界boss
}

--ReactionType
ReactionType = {
	HIT   = 1, --命中
	DODGE = 2, --闪避
	FATAL = 3, --致命 (由于致命和格挡可以同时存在)
	PARRY = 4, --招架
}

--z轴
ZOrderType = {
	BG     = 0,		--背景层
	WAR	   = 50,	--阵法
	TOM	   = 80, 	--墓碑	
	E_CARD = 100,	--卡牌层
	P_CARD = 110,	--卡牌层
	FORCE  = 120,   --战斗力
	EFFECT = 200,	--特效层
	TIP    = 300,	--特效层
	UI     = 400,	--ui层
}

--特效挂点
CardEffectPos = {
	HEAD = 1,
	HERT = 2,
	FOOT = 3,
}

--buffer类型
BufferType = {
	HP = 9, 
	RAGE = 28,
}

--buffer 添加时间
BufferTimeType = {
	BEFORE	=	1,	--前
	IN		=	2,	--中
	LATER	=	3,	--后
}

--buffer 显示类型
BufferShowType = {
	ENBUFFER	=	1,	--前
	BUFFER		=	2,	--后
	DEBUFFER	=	3,	--中
	IMBUFFER	=	4,	--中
}

--敌方部队出现方式
EnemyAppearType = {
	NORMAL = 0,	--正常出现
	FLASH  = 1,	--特效闪现
	DOWN   = 2,	--主动走下来
}

--战斗动画
CardAction = {
	walk  = "walk_0",
	die   = "T007_0",
	hurt2 = "hurt2",
	hurt1 = "hurt1",
	dodge = "dodge",
}

--战斗对话时间点
FightTalkTime = {
	BEFORE = 1,
	ROUND  = 2,
	END    = 3,
}

--战斗速度开启等级
FightSpeedType = {
	SPEED_1 = 1,
	SPEED_2 = 1,
	SPEED_3 = 40,
}

FightSpeedNumType = {
	1.5,
	2,
	3,
}



