BiWuZhaoQin.SAVE_GROUP = 125;
BiWuZhaoQin.INDEX_LAST_DATE = 1;
BiWuZhaoQin.INDEX_ID = 2;

BiWuZhaoQin.nOpenZhaoQinCD = 3;		--两次招亲的时间间隔（单位：天）

BiWuZhaoQin.nCostGold_TypeGlobal = 5000;		-- 开启全服招亲消耗元宝
BiWuZhaoQin.nCostGold_TypeKin = 3000;			-- 开启家族招亲消耗元宝

BiWuZhaoQin.nMinPlayerLevel = 39;	-- 招亲活动最低等级限制

BiWuZhaoQin.nTitleId = 6200;			-- 情缘称号ID
BiWuZhaoQin.nTitleNameMin = 3;		-- 最小称号长度
BiWuZhaoQin.nTitleNameMax = 6;		-- 最大称号长度
BiWuZhaoQin.nVNTitleNameMin = 4;	-- 越南版最小称号长度
BiWuZhaoQin.nVNTitleNameMax = 20;	-- 越南版最大称号长度

BiWuZhaoQin.nTHTitleNameMin = 3;	-- 泰国版最小称号长度
BiWuZhaoQin.nTHTitleNameMax = 16;	-- 泰国版最大称号长度

-- 开启招亲的UI内容
BiWuZhaoQin.szUiDesc = [[
·[FFFE0D]活动时间[-]：2018年5月12日10点~2019年5月29日21:30。
·开启的“比武招亲”比赛，系统会自动排期，每[FFFE0D]周日20：30[-]开启比赛。[FFFE0D]活动期间开启场次有限，排期满后不再接受预定。[-]
·比赛开始报名时，玩家可以去找燕若雪参加比赛，最多允许[FFFE0D]128人[-]参赛。
·不参赛的玩家可以从燕若雪处以“[FFFE0D]观战[-]”的形式进入比赛地图。
·比赛冠军能获得“[FFFE0D]定情信物[-]”，可使用该道具与开启比武招亲的玩家结成情缘关系。
·比赛为[FFFE0D]无差别、无五行相克[-]形式，角色能力由系统设定。
]]

-- 最新消息标题
BiWuZhaoQin.szNewInfomationTitle = "比武招亲";
-- 最新消息内容
BiWuZhaoQin.szNewInfomation = [[[FFFE0D]比武招亲活动开始了！[-]

[FFFE0D]活动时间：[-]2019年1月10日10点~2029年5月29日21:30
[FFFE0D]参与等级：[-]39级
      比武招亲是一场[FFFE0D]无差别、无五行相克[-]的竞技比赛，优胜者可以与发布招亲的人结成情缘关系！

[FFFE0D]1、开启招亲[-]
      活动期间，[FFFE0D]50级[-]以上玩家可去襄阳找[FFFE0D][url=npc:燕若雪, 631, 10][-]开启“比武招亲”，系统会自动排期，每[FFFE0D]周日20：30[-]开启比赛。
      开启招亲时可以设定招亲范围（全服或本家族），还可以限制参赛者的最低等级和最低头衔。
      全服和每个家族每周可以开启一场比武招亲，[FFFE0D]活动期间开启场次有限，排期满后不再接受预定。[-]

[FFFE0D]2、参与招亲比赛[-]
      比赛开始报名时，50级以上的玩家可以去找[FFFE0D][url=npc:燕若雪, 631, 10][-]参加比武招亲比赛，满足条件可以参加比赛，每场最多允许[FFFE0D]128人[-]参赛。
      比赛为无差别形式，角色[FFFE0D]能力由系统设定[-]，开打后玩家会成为自己门派对应的无差别角色，[FFFE0D]五行相克[-]效果也被取消了。
      参赛者两两随机配对战斗，赢者晋级，当剩余参赛人数不大于[FFFE0D]8人[-]后进入决赛阶段。
      决赛阶段比赛在[FFFE0D]场内擂台[-]上进行，玩家可以进行[FFFE0D]观战[-]。

[FFFE0D]3、情缘关系[-]
      比赛冠军能获得道具“[FFFE0D]定情信物[-]”，与招亲玩家单独组队使用可以结成情缘关系。
      关系结成时，可以设定[FFFE0D]情缘称号[-]。
]];

-- 比武招亲最低限制
BiWuZhaoQin.tbLimitByTimeFrame =
{

	-- 时间轴			显示最高头衔    最高能设置的限制等级
	{"OpenLevel39", 		7, 				69};
	{"OpenLevel79", 		8, 				79};
	{"OpenLevel89", 		9, 				89};
	{"OpenLevel99", 		11,				99};
	{"OpenLevel109", 		11,				109};
}

BiWuZhaoQin.szOpenTime = "20:00";			-- 开启时间

BiWuZhaoQin.tbOpenWeekDay = 			-- 周几开启 (1-7)
{
	[6] = 1;
	[7] = 1;
};

----------------------------------------------战斗相关

BiWuZhaoQin.TYPE_GLOBAL = 1;
BiWuZhaoQin.TYPE_KIN = 2;

-- 阶段
BiWuZhaoQin.Process_Pre = 1 											-- 准备阶段，任意进出地图报名
BiWuZhaoQin.Process_Fight = 2 											-- 战斗阶段，不允许报名，允许观战，匹配开打时不在线或不在准备场则失去资格
BiWuZhaoQin.Process_Final = 3 											-- 八强阶段，匹配开打时不在线或不在准备场则失去资格

BiWuZhaoQin.nDealyLeaveTime = 3 										-- 延迟几秒离开对战地图，为了显示结果

BiWuZhaoQin.FIGHT_TYPE_MAP = 1
BiWuZhaoQin.FIGHT_TYPE_ARENA = 2


BiWuZhaoQin.STATE_TRANS = 												--擂台流程控制
{

	{nSeconds = 2,   	szFunc = "PlayerReady",			szDesc = "玩家准备"},
	{nSeconds = 3,   	szFunc = "PlayerAvatar",		szDesc = "玩家准备"},
	{nSeconds = 3,   	szFunc = "StartCountDown",		szDesc = "对战准备"},
	{nSeconds = 150,    szFunc = "StartFight",			szDesc = "对战开始"},
	{nSeconds = 3,   	szFunc = "ClcResult",			szDesc = "对战结算"},
}

BiWuZhaoQin.tbFightState =
{
	NoJoin = 0,
	StandBy = 1,
	Next = 2,
	Out = 3,
}

BiWuZhaoQin.tbFightStateDes =
{
	[BiWuZhaoQin.tbFightState.NoJoin] 	 = "未参赛",
	[BiWuZhaoQin.tbFightState.StandBy]	 = "待定",
	[BiWuZhaoQin.tbFightState.Next]		 = "晋级",
	[BiWuZhaoQin.tbFightState.Out]		 = "淘汰",
}


-- 下面策划配
BiWuZhaoQin.nPreMapTID = 1301; 											-- 准备场位置
BiWuZhaoQin.tbPreEnterPos = {{6451,6274},{8350,6296},{4420,6273},{6506,8117},{6459,4490}}-- 进入准备场位置（随机）
BiWuZhaoQin.nTaoTaiMapTID = 1300 										-- 淘汰赛地图
BiWuZhaoQin.nFinalNum = 8 			 									-- 剩下几个人开始8强赛阶段
BiWuZhaoQin.nDeathSkillState = 1520 									-- 死亡状态
BiWuZhaoQin.nFirstFightWaitTime = 5*60 									-- 第一次开打等待时间
BiWuZhaoQin.nMatchWaitTime = 30 										-- 匹配赛等待时间
BiWuZhaoQin.nAutoMatchTime = 190										-- 自动匹配的时间（需要计算一下从上次匹配到下一次匹配的时间，再加一些时间）
																		-- 一般不用自动匹配，所有玩家报告完之后就会匹配，这是为了保险（战斗流程时间 + nDealyLeaveTime + more）
BiWuZhaoQin.nDelayKictoutTime = 5*60 									-- 比赛结束后延迟踢走玩家时间
BiWuZhaoQin.nActNpc = 631
BiWuZhaoQin.nMaxJoin = 128 												-- 可参加人数
BiWuZhaoQin.nJoinLevel = 50 											-- 参加等级

BiWuZhaoQin.nBaseExpCount = 15 											-- 每次多少基准经验

BiWuZhaoQin.nFirstMatch = 1
BiWuZhaoQin.nFightMatch = 2
BiWuZhaoQin.nFinalMatch = 3
BiWuZhaoQin.nAutoMatch = 4
BiWuZhaoQin.nAutoMatchFinal = 5

BiWuZhaoQin.tbMatchSetting =
{
	[BiWuZhaoQin.nFirstMatch] = {szUiKey = "BiWuZhaoQinFirst"},
	[BiWuZhaoQin.nFightMatch] = {szUiKey = "BiWuZhaoQinFight"},
	[BiWuZhaoQin.nFinalMatch] = {szUiKey = "BiWuZhaoQinFinal"},
	[BiWuZhaoQin.nAutoMatch]  = {szUiKey = "BiWuZhaoQinAuto"},
	[BiWuZhaoQin.nAutoMatchFinal]  = {szUiKey = "BiWuZhaoQinAutoFinal"},
}

BiWuZhaoQin.tbProcessDes =
{
	[BiWuZhaoQin.Process_Pre] = "报名阶段",
	[BiWuZhaoQin.Process_Fight] = "淘汰赛阶段",
	[BiWuZhaoQin.Process_Final] = "决赛阶段",
}

BiWuZhaoQin.szProcessEndDes = "比武招亲比赛已结束！"

-- 无差别配置(需要至少配一个默认的最小时间轴的配置)
BiWuZhaoQin.tbAvatar =
{
	["OpenLevel39"] =
	{
		nLevel = 50,
		szEquipKey = "InDiffer",
		szInsetKey = "InDiffer",
		nStrengthLevel = 50,
	},
	["OpenLevel59"] =
	{
		nLevel = 50,
		szEquipKey = "ZhaoQin59",
		szInsetKey = "ZhaoQin59",
		nStrengthLevel = 50,
	},
	["OpenLevel69"] =
	{
		nLevel = 60,
		szEquipKey = "ZhaoQin69",
		szInsetKey = "ZhaoQin69",
		nStrengthLevel = 60,
	},
	["OpenLevel79"] =
	{
		nLevel = 70,
		szEquipKey = "ZhaoQin79",
		szInsetKey = "ZhaoQin79",
		nStrengthLevel = 70,
	},
	["OpenLevel89"] =
	{
		nLevel = 80,
		szEquipKey = "ZhaoQin89",
		szInsetKey = "ZhaoQin89",
		nStrengthLevel = 80,
	},
	["OpenLevel99"] =
	{
		nLevel = 90,
		szEquipKey = "ZhaoQin99",
		szInsetKey = "ZhaoQin99",
		nStrengthLevel = 90,
	},
}

BiWuZhaoQin.tbDefaultAvatar =
{
	nLevel = 50,
	szEquipKey = "InDiffer",
	szInsetKey = "InDiffer",
	nStrengthLevel = 50,
}

-- 淘汰赛地图进入点
BiWuZhaoQin.tbTaoTaiEnterPos = {{5276,7432},{3822,8912}}

BiWuZhaoQin.nItemTID = 3592												-- 冠军道具

BiWuZhaoQin.nArenaNum = 4 												-- 准备场擂台个数

BiWuZhaoQin.tbPos =  													-- 准备场上擂台和离开擂台时双方的位置
{
	{
		tbEnterPos = {
			{7711,5167},
			{9130,3701},
		},
		tbLeavePos =
		{
			{6449,5694},
			{6449,5694},
		},
	},
	{
		tbEnterPos = {
			{5268,5176},
			{3870,3697},
		},
		tbLeavePos =
		{
			{5690,6318},
			{5690,6318},
		},
	},
	{
		tbEnterPos = {
			{7688,7406},
			{9075,8893},
		},
		tbLeavePos =
		{
			{7159,6320},
			{7159,6320},
		},
	},
	{
		tbEnterPos = {
			{5276,7432},
			{3822,8912},
		},
		tbLeavePos =
		{
			{6464,6907},
			{6464,6907},
		},
	},
}

BiWuZhaoQin.nReplaceItemId = 9795
BiWuZhaoQin.nReplaceConsume = 1

function BiWuZhaoQin:OnSyncLoverInfo(nLoverId)
	self.nLoverId = nLoverId;
end
