--SwornBrosConstant.lua
SWORN_MIN_LEVEL = 40	-- min level of swearing
SWORN_SCENE_TRANSNPC = 10480 -- jinlan shizhe
SWORN_SCENE_START_NPC = 10481	
SWORN_SCENE_ID = 2115	-- map id
SWORN_SCENE_INIT_X = 7
SWORN_SCENE_INIT_Y = 20
SWORN_ITEM_ID = 1439	--jinlan pu
SWORN_ITEM_NUM = 1
SWORN_COST_TYPE = 701
SWORN_BROTHERS_MINNUM = 2
SWORN_BROTHERS_MAXNUM = 4
SWORN_MAX_ACTIVE_SKILL = 2
SWORN_RELATION_MIN_BROS = 2
SWORN_LEAVE_TIME_INTERVAL = 3600*24
--SWORN_LEAVE_TIME_INTERVAL = 30

SWORN_TIMER_PERIOD = 5000
SWORN_INIT_SKILL_POINT = 1
SWORN_RELATION_DAILY_MAX = 1500

--DEBUG MARCOS
RELATION_RATE = 1.0

SwornActiveSkill = 
{
	TRANS_ID = 10049,
	GATHER_ID = 10050,
}

--结义相关错误码
SwornBrosErrCode = 
{
	SUCCEED = 0,	
	NO_TEAM = 1,			--未组队
	NO_ENOUGH_LEVEL = 2,	--等级不够
	INCORRECT_NPC = 3,		--错误的NPC
	DIFF_SWORN_BROS = 4,	--不同的结义
	FAIL_TO_ENTER = 5,		--进入失败
	REJECT_SWORN = 6,		--拒绝结义
	NO_SWORN_ITEM = 7,		--没有金兰谱
	SWORN_MAX_NUM = 8,	  	--超过最大人数
	SWORN_MIN_NUM = 9,		--少于最小人数
	NOT_LEADER = 10,		--不是队长
	INEXISTENT_SWORN = 11,	--不存在的结义
	NOT_SWORN = 12,			--没有结义
	INVALID_TARGET = 13,	--错误的目标
	NO_SKILL_POINT = 14,	--没有技能点
	NO_PREV_SKILL = 15,		--前置技能未学习
	SKILL_LEARNED = 16,		--技能已学习
	INVALID_SKILL = 17,		--不存在的技能
	CANT_TRANSMIT = 18,		--无法传送至目标
	INVALID_GATHER = 19,	--不存在的召唤
	NO_PSV_SKILL = 20,		--没有学习任何技能
	NOT_BIG_BROTHER = 21,	--不是带头大哥
	TOO_QUICK_TO_JOIN = 22,	--刚刚割袍断义过
	NO_NEW_MEMBER = 23,		--当前成员已结义 请加入新成员
}
--结义信息类型
SwornInfoType = 
{
	BASIC = 1,
	SKILL = 2,
}
-- 结义操作类型
SwornActionType = 
{
	KICK = 1,
	LEAVE = 2,
	HINT = 3,
	DISMISS = 4,
}
--结义被动技能操作
SwornPsvSkillOpType = 
{
	LEARN = 1,
	RESET = 2,
}

SwornAtvOperateType = 
{
	None = 0,
	Transmit = 1,		-- 传送
	ReqGather = 2,		-- 请求召唤
	AgreeGather = 3,	-- 同意被召唤
}

SwornTimerStatus = 
{
	INVALID = 0,
	RUNNING = 1,
	PAUSED = 2,
}
