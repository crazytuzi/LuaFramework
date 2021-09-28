--TaskConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskConstant.lua
 --* Author:  seezon
 --* Modified: 2014年4月9日
 --* Purpose: 任务常量定义
 -------------------------------------------------------------------*/
TASK_OPEN_FALG = true
FIRST_MAIN_TASK_ID = 10000
TASK_OPEN_WING_ID = 51005	--开启光翼的任务ID
TASK_OPEN_RIDE_ID = 10039 	--开启坐骑的任务ID
TASK_OPEN_MEDAL_ID = 10081 	--开启勋章的任务ID
TASK_OPEN_MOUNT_ID = 100000 --开启灵兽功能的任务ID

--日常任务相关
TASK_DAILY_MAX_TIME = 15		--日常任务的环数
TASK_DAILY_ACTIVE_LEVEL = g_configMgr:getNewFuncLevel(11)	--日常任务激活等级
TASK_FINISH_DAILY_NEED_INGOT = 10	--日常任务直接完成消耗元宝
TASK_MAX_BRACH_NUM = 10	--最多可接的支线任务数量

TASK_DAILY_FINISH_BY_INGOT_EXP = 300000

TASK_DAILY_PRIZE_RATE = {1,1.06,1.12,1.19,1.26,1.34,1.42,1.51,1.6,1.7,1.8,1.91,2.02,2.14,2.27}


SUCCESS = 0
--头顶任务信息临时定义，以后可以放到所以头顶图标的枚举
DialogIcon = {
	Task1           = 0x01, --已完成任务
	Task2           = 0x02, --未完成任务
}

--任务类型
TaskType = {
	Main           = 1, --主线任务
	Daily           = 2, --日常任务
	Hunter           = 3, --怪物猎人任务
	Branch           = 4, --支线任务
	
-- 悬赏任务20160106
	Reward				= 5, --悬赏任务
	Shared			= 6,--共享任务
--行会公共任务
	Faction		= 7,	--行会公共任务
}

--任务状态
TaskStatus = {
	Active		= 1,--任务激活
	Done		= 2,--任务完成，还没交
	Finished	= 3,--任务提交
	Accept		= 4,--可接
	Fail		= 5,--失败
}

--任务操作行为
TaskOp = {
	op1			= 1,--显示任务信息(主线任务)
	op2			= 2,--接受任务(主线任务)
	op3			= 3,--完成任务(主线任务)
	op4			= 4,--显示任务信息(怪物猎人任务)
	op5			= 5,--完成任务(怪物猎人任务)
	op6			= 6,--显示接受任务信息(支线任务)
	op7			= 7,--显示完成任务信息(支线任务)
	op8			= 8,--显示未完成任务信息(支线任务)
	op9			= 9,--接受任务(支线任务)
	op10		= 10,--完成任务(支线任务)
	op11		= 11,--显示当前等级不足不可接某任务（主线，非按钮）
}

--任务日志状态
TaskRecordState = {
	Accept		= 1,--接任务
	Finish		= 2,--完成任务
	FinishAll	= 3,--完成全部任务（日常独有）
}

--任务完成类型
TaskFinishType = {
	AutoFinish		= 1,--自动完成
	NpcFinish		= 2,--NPC完成
}

--一键完成日常任务的类型
FinishDailyTaskType = {
	finishCur			= 1,--完成当前任务
	finishAll			= 2,--完成所有日常任务
}

--王城诏令触发拼战的环数
CompetitionLoop = {4,8,12}

--任务目标映射
TARGET_ID_EQUIPSTRENGTH			= 1	--装备强化
TARGET_ID_EQUIPINHERIT			= 2	--装备传承
TARGET_ID_EQUIPDECOMPOSE			= 5	--装备熔炼
TARGET_ID_SKILLLEVELUP			= 6	--技能升级
TARGET_ID_WINGPROMOTE				= 8	--光翼进阶
TARGET_ID_DAILYSIGN				= 10	--每日签到
TARGET_ID_DONEDAILYTASK			= 11	--完成日常任务
TARGET_ID_JOINARENA				= 13	--参加竞技场
TARGET_ID_JOINCOPY				= 14	--参加副本
TARGET_ID_ADDFRIEND				= 15	--添加好友
TARGET_ID_CREATETEAM				= 16	--创建队伍
TARGET_ID_GIVEFLOWER				= 17	--送花
TARGET_ID_KILLWORLDBOSS			= 18	--击杀世界BOSS
TARGET_ID_LOTTERY					= 19	--完成一次抽奖
TARGET_ID_USEINGOT				= 20	--在商城购买1次元宝道具
TARGET_ID_USEBINDINGOT			= 21	--在商城购买1次礼金道具
TARGET_ID_USEMAT			= 22	--使用物品
TARGET_ID_LEVELUP			= 23	--升级
TARGET_ID_TASKUPSTAR			= 25	--日常任务奖励升星
TARGET_ID_GETACTIVEREWARD		= 26	--领取活跃度奖励
TARGET_ID_USETITLE		= 28	--穿戴称号
TARGET_ID_GETMAT		= 29	--收集某种物品(不消耗)
TARGET_ID_USESKILL		= 30	--使用技能
TARGET_ID_GIVEITEM		= 32	--提交某个物品(消耗)

TARGET_ID_EQUIPBAPTIZE		= 33	--装备洗炼
TARGET_ID_PUBLISHREWARD		= 34	--发布悬赏任务
TARGET_ID_ACCEPTREWARD		= 35	--接取悬赏任务
TARGET_ID_FINISHREWARD		= 36	--接取悬赏任务
TARGET_ID_ENTERCOPY			= 38	--参加副本（只参加）
TARGET_ID_ADORE				= 39	--膜拜
TARGET_ID_UPMEDAL			= 40	--升级勋章
TARGET_ID_BUYMYSGOOD		= 41	--购买神秘商店物品
TARGET_ID_BUYMYSPOS			= 42	--开启神秘商店的格子
TARGET_ID_BLESSWEAPON		= 43	--祝福武器
TARGET_ID_JOINFAC			= 44	--加入行会
TARGET_ID_KILLOTHER			= 45	--击杀玩家
TARGET_ID_DART				= 46	--运镖
TARGET_ID_KILLDART			= 47	--劫镖
TARGET_ID_UPSKILL			= 48	--升级技能
TARGET_ID_DRINK				= 49	--仙翁赐酒
TARGET_ID_STONE				= 50	--挖矿
TARGET_ID_YANHUO			= 51	--焰火屠魔
									--52前台占用
TARGET_ID_NPCUSEGOT			= 53	--NPC使用道具
TARGET_ID_KillSINGLEMONSTER	= 54	--触发式单人杀怪护送
TARGET_ID_CHANGEMODE	= 55	--变身对话护送
TARGET_ID_PERSONALESCORT	= 56	--个人护送
TARGET_ID_MONSTERUSEGOT		= 57	--野怪使用道具
TARGET_ID_SHABAKE		= 58	--模拟沙巴克
TARGET_ID_COMPOUND		= 59	--装备合成
TARGET_ID_PICKREWARD	= 60	--领取悬赏任务奖励
TARGET_ID_ENTERPREBOOK	= 61	--副本预体验


--任务目标映射
TaskTargetTypeMap = {
	[TARGET_ID_EQUIPSTRENGTH]= "TEquipStrength",
	[TARGET_ID_EQUIPINHERIT]= "TEquipInherit",
	[TARGET_ID_EQUIPDECOMPOSE]= "TEquipDecompose",
	[TARGET_ID_SKILLLEVELUP]= "TSkillLevelUp",
	[TARGET_ID_WINGPROMOTE]= "TWingPromote",
	[TARGET_ID_DAILYSIGN]= "TDailySign",
	[TARGET_ID_DONEDAILYTASK]= "TDoneDailyTask",
	[TARGET_ID_JOINARENA]= "TJoinArena",
	[TARGET_ID_JOINCOPY]= "TJoinCopy",
	[TARGET_ID_ADDFRIEND]= "TAddFriend",
	[TARGET_ID_CREATETEAM]= "TCreateTeam",
	[TARGET_ID_GIVEFLOWER]= "TGiveFlower",
	[TARGET_ID_KILLWORLDBOSS]= "TKillWorldBoss",
	[TARGET_ID_LOTTERY]= "TLottery",
	[TARGET_ID_USEINGOT]= "TUseIngot",
	[TARGET_ID_USEBINDINGOT]= "TUseBindIngot",
	[TARGET_ID_USEMAT]= "TUseMat",
	[TARGET_ID_LEVELUP] = "TLevelUp",
	[TARGET_ID_TASKUPSTAR] = "TUpStarTask",
	[TARGET_ID_GETACTIVEREWARD] = "TGetActiveReWard",
	[TARGET_ID_USETITLE] = "TUseTile",
	[TARGET_ID_GETMAT] = "TGetMat",
	[TARGET_ID_USESKILL] = "TUseSkill",
	[TARGET_ID_GIVEITEM] = "TGiveItem",
	[TARGET_ID_EQUIPBAPTIZE] = "TEquipBaptize",
	[TARGET_ID_PUBLISHREWARD] = "TPubliseReward",
	[TARGET_ID_ACCEPTREWARD] = "TAcceptReward",
	[TARGET_ID_FINISHREWARD] = "TFinishReward",
	[TARGET_ID_ENTERCOPY] = "TEnterCopy",
	[TARGET_ID_ADORE] = "TAdore",
	[TARGET_ID_UPMEDAL] = "TUpmedal",
	[TARGET_ID_BUYMYSGOOD] = "TBuyMysGood",
	[TARGET_ID_BUYMYSPOS] = "TBuyMysPos",
	[TARGET_ID_BLESSWEAPON] = "TBlessWeapon",
	[TARGET_ID_JOINFAC] = "TJoinFac",
	[TARGET_ID_KILLOTHER] = "TKillOther",
	[TARGET_ID_DART] = "TDart",
	[TARGET_ID_KILLDART] = "TKillDart",
	[TARGET_ID_UPSKILL] = "TUpSkill",
	[TARGET_ID_DRINK] = "TDrink",
	[TARGET_ID_STONE] = "TStone",
	[TARGET_ID_YANHUO] = "TYanhuo",
	[TARGET_ID_PERSONALESCORT] = "TPersonalEscort",
	[TARGET_ID_NPCUSEGOT] = "TNPCUseGot",
	[TARGET_ID_KillSINGLEMONSTER] = "TSingleKillMonster",
	[TARGET_ID_MONSTERUSEGOT] = "TMonsterUseGot",
	[TARGET_ID_CHANGEMODE] = "TChangeMode",
	[TARGET_ID_COMPOUND] = "TEquipCompound",
	[TARGET_ID_PICKREWARD] = "TPickReward",
	[TARGET_ID_ENTERPREBOOK] = "TEnterPreBook",
}

--------------TASK_TIPS---------------
TASK_ERR_TASK_EXSIT = -1	--任务已经存在了
TASK_ERR_BAG_NOT_ENOUGH = -2	--奖励包裹不够，不能完成任务
TASK_ERR_FLYSHOE_NOT_ENOUGH = -3	--没有小飞鞋
TASK_ERR_CFG_ERR = -4	--配置错误
TASK_ERR_MAIN_LEVEL_NOT_ENOUGH = -5	--等级不够不能接支线任务
TASK_ERR_ACCEPT_SECOND = -40	--无法重复接取密令
TASK_ERR_ACCEPT = -99	--包裹满了无法接取主线任务

--日常相关
TASK_ERR_ALREADY_MAX_STAR = -41	--任务奖励已经最高星级，不能升星
TASK_ERR_REWARD_NOTIFY = -64	--任务完成，获得XX金币，XX经验
TASK_ERR_FINISH_DAIY = -65	--完成XX环任务，自动接取XX环任务
TASK_ERR_FINISH_ALL_DAIY = -66	--完成所有环任务
--------------TASK_TIPS---------------

TASK_ERR_EQUIP_STRENGTH_NOTIFY1 = -45	--XXX（玩家名）玩家小试牛刀，将XXX升级到20级，大家恭喜他吧。
TASK_ERR_EQUIP_STRENGTH_NOTIFY2 = -46	--XXX（玩家名）玩家初露锋芒，将XXX升级到25级，大家恭喜他吧。
TASK_ERR_EQUIP_STRENGTH_NOTIFY3 = -47	--XXX（玩家名）玩家霸气威武，将XXX升级到30级，大家恭喜他吧。