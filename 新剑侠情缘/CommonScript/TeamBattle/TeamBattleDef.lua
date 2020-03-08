TeamBattle.SAVE_GROUP = 45;
TeamBattle.SAVE_DATE = 1;
TeamBattle.SAVE_USE_COUNT = 2;
TeamBattle.SAVE_HONOR = 3;

TeamBattle.SAVE_LAST_WEEK_DATE = 4;
TeamBattle.SAVE_LAST_WEEK_USE_COUNT = 5;

TeamBattle.SAVE_MONTHLY_INFO = 6;
TeamBattle.SAVE_MONTHLY_INFO_OLD = 7;
TeamBattle.SAVE_QUARTERLY_INFO = 8;
TeamBattle.SAVE_QUARTERLY_INFO_OLD = 9;
TeamBattle.SAVE_YEAR_INFO = 10;
TeamBattle.SAVE_YEAR_INFO_OLD = 11;
TeamBattle.SAVE_MONTHLY_TIP = 12;
TeamBattle.SAVE_QUARTERLY_TIP = 13;
TeamBattle.SAVE_YEAR_TIP = 14;

TeamBattle.TYPE_NORMAL = 1;
TeamBattle.TYPE_MONTHLY = 2;
TeamBattle.TYPE_QUARTERLY = 3;
TeamBattle.TYPE_YEAR = 4;

TeamBattle.szLeagueOpenTimeFrame = "OpenLevel109";

-- 月度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nMonthlyOpenWeek = 1;		--当月第几周
TeamBattle.nMonthlyOpenWeekDay = 3;		--周几
TeamBattle.nMonthlyOpenHour = 21;		--当日小时
TeamBattle.nMonthlyOpenMin = 0;			--当日分钟

-- 季度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nQuarterlyOpenMonth = 3;		--本季度第几个月
TeamBattle.nQuarterlyOpenWeek = -1;		--本月第几周
TeamBattle.nQuarterlyOpenWeekDay = 3;	--本周几
TeamBattle.nQuarterlyOpenHour = 21;		--当日小时
TeamBattle.nQuarterlyOpenMin = 0;		--当日分钟

-- 年度赛开启时间，此处用于各种判断，不用做真正开启时间
TeamBattle.nYearOpenMonth = 4;			--几月份
TeamBattle.nYearOpenWeek = -1;			--第几周
TeamBattle.nYearOpenWeekDay = 3;		--周几
TeamBattle.nYearOpenHour = 21;			--几点
TeamBattle.nYearOpenMin = 0;			--几分

TeamBattle.nMonthlyAddTitle = 7700;
TeamBattle.nQuarterlyAddTitle = 7701;
TeamBattle.nYearAddTitle = 7702;

TeamBattle.nFloor2Num = 32;			--2层队伍数量

TeamBattle.PRE_MAP_ID = 1040;		--准备场地图ID
TeamBattle.TOP_MAP_ID = 1047;		--七层地图ID
TeamBattle.TOP_MAP_ID_CROSS = 1057;		--八层地图ID

TeamBattle.tbTopPoint =
{
	{1794, 4044},
	{1804, 2505},
}

TeamBattle.nAddImitity = 20;		--结束后好友增加亲密度
TeamBattle.nTopMapTime = 20 * 60;	--顶层停留最大时间
TeamBattle.nPreMapTime = 5 * 60;	--准备场等待时间
TeamBattle.nMinLevel = 30;			--最小参与等级
TeamBattle.nMinTeamCount = 4;		--最小开启队伍数量
TeamBattle.nFightTime = 220;		--每轮耗时
TeamBattle.nTeamMemeber = 3;		--每个队伍玩家数量
TeamBattle.nMaxFightTimes = 5;		--战斗场次数
TeamBattle.nMaxFloor = 7;			--最大层数
TeamBattle.nMaxFloor_Cross = 8;			--跨服通天塔最大层数
TeamBattle.nTryStartCount = 3;		--最大尝试开启次数，不足16个队伍则再次等待一段时间后尝试开启，最大次数尝试后还是失败，则直接失败
TeamBattle.nDeathSkillState = 1520;	--死亡后状态

TeamBattle.nMaxTimes = 3;
TeamBattle.tbRefreshDay = {3, 6, 7};

TeamBattle.szCrossOpenTimeFrame = "OpenLevel89";

TeamBattle.szStartNotifyInfo = "通天塔的入口已打开，众侠士可前往挑战";
TeamBattle.szTopWorldNotify = "「%s」成功登顶通天塔第七层！";
TeamBattle.szTopWorldNotify_Cross = "「%s」成功登顶跨服通天塔第八层！";
TeamBattle.szTopKinNotify = "恭喜本家族成员「%s」成功登顶通天塔第七层！";
TeamBattle.szTopKinNotify_Cross = "恭喜本家族成员「%s」成功登顶跨服通天塔第八层！";
TeamBattle.szCloseNotify = "通天塔活动结束了！";

TeamBattle.tbLeagueTopWorldNotify =
{
	[TeamBattle.TYPE_MONTHLY] = "「%s」成功登顶月度通天塔第八层！";
	[TeamBattle.TYPE_QUARTERLY] = "「%s」成功登顶季度通天塔第八层！";
	[TeamBattle.TYPE_YEAR] = "「%s」成功登顶年度通天塔第八层！";
}

TeamBattle.tbLeagueTopKinNotify =
{
	[TeamBattle.TYPE_MONTHLY] = "恭喜本家族成员「%s」成功登顶月度通天塔第八层！";
	[TeamBattle.TYPE_QUARTERLY] = "恭喜本家族成员「%s」成功登顶季度通天塔第八层！";
	[TeamBattle.TYPE_YEAR] = "恭喜本家族成员「%s」成功登顶年度通天塔第八层！";
}

TeamBattle.tbLeagueCloseNotify = {
	[TeamBattle.TYPE_MONTHLY] = "月度通天塔结束了！";
	[TeamBattle.TYPE_QUARTERLY] = "季度通天塔结束了！";
	[TeamBattle.TYPE_YEAR] = "年度通天塔结束了！";
}

TeamBattle.szTopNotifyCrossWin = "「%s」带领小队，在跨服通天塔中击败了来自 %s 服的「%s」小队，荣登第八层";
TeamBattle.szTopNotifyCrossLost = "「%s」带领的小队，被 %s 服的「%s」小队击败，未能登顶八层";

-- 亲密度
TeamBattle.tbAddImityInfo = {
	[0] = 40,
	[1] = 60,
	[2] = 80,
	[3] = 100,
	[4] = 120,
	[5] = 150,
};

TeamBattle.TeamBattlePanelDescribe =
{
	["Describe"] = [[·3人组队，3 对 3的小队竞技
·从通天塔的底层开始，每轮会随机匹配同处于本层的另一个队伍来进行挑战
·每轮挑战分上、下两个半场，最终累计击败对方人数最多的队伍为胜
·胜者队可以进入更高一层，再与同层的其他队伍匹配对战
·负者队继续留在本层，再与同层的其他队伍匹配对战
·整个通天塔共5轮，全胜队伍有望进入到塔顶第七层！获得通天塔最高荣誉！
]],
}

-- 准备场出生点，可以配多个，随机取用
TeamBattle.tbPreMapBeginPos =
{
	{6374, 6891};
	{6403, 4430};
	{6403, 4430};
}

-- 战斗场地图配置,随机取用
TeamBattle.tbFightMapBeginPoint =
{
	[1] = {--一层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1041, 			{{7960, 6783}, {2698, 5581}}, 		{{7905, 2076}, {2698, 3408}}},
	};
	[2] = {--二层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1042, 			{{8283, 6090}, {3155, 3250}}, 		{{8277, 2106}, {3081,5504}}},
	};
	[3] = {--三层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1043, 			{{6432, 5391}, {1340, 4845}}, 		{{6439, 1985}, {1402, 2526}}},
	};
	[4] = {--四层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1044, 			{{7540, 6009}, {2274, 5082}}, 		{{7393, 1689}, {2311, 2921}}},
	};
	[5] = {--五层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1045, 			{{7864, 6297}, {2691, 5381}}, 		{{7711, 2269}, {2720, 3155}}},
	};
	[6] = {--六层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1046, 			{{8365, 6431}, {3260, 5244}}, 		{{8323, 1810}, {3304, 3066}}},
	};
	[7] = {--七层
		--地图ID 	1队：   休息点			出生点 		2队：  休息点		出生点
		{1056, 			{{8365, 6431}, {3260, 5244}}, 		{{8323, 1810}, {3304, 3066}}},
	};
}

TeamBattle.nAwardItemId = 2418;
TeamBattle.nAwardItemNeedHonor = 800;

-- 各层奖励
TeamBattle.tbAwardInfo =
{
	[1] = {
		{"BasicExp", 100 * 5};
		nTeamBattleHonor = 1000 * 5,
	};
	[2] = {
		{"BasicExp", 120 * 5};
		nTeamBattleHonor = 1100 * 5,
	};
	[3] = {
		{"BasicExp", 140 * 5};
		nTeamBattleHonor = 1200 * 5,
	};
	[4] = {
		{"BasicExp", 150 * 5};
		nTeamBattleHonor = 1500 * 5,
	};
	[5] = {
		{"BasicExp", 160 * 5};
		nTeamBattleHonor = 1800 * 5,
	};
	[6] = {
		{"BasicExp", 180 * 5};
		nTeamBattleHonor = 2100 * 5,
	};
	[7] = {
		--{"BasicExp", 200 * 5};
		{"Item", 994205, 1};  --洗髓经残卷
		nTeamBattleHonor = 2400 * 5,
	};
	[8] = {
		--{"BasicExp", 220 * 5};
		{"Item", 994205, 1};  --洗髓经残卷
		nTeamBattleHonor = 3000 * 5,
	};
}

-- 月度赛增加亲密度
TeamBattle.nLeagueAddImity = 100;

-- 联赛奖励内容
TeamBattle.tbLeagueAward = {
	[TeamBattle.TYPE_MONTHLY] = {
		[1] = {{"BasicExp", 100 * 5}, {"Energy", 1500 * 5}},
		[2] = {{"BasicExp", 120 * 5}, {"Energy", 1800 * 5}},
		[3] = {{"BasicExp", 140 * 5}, {"Energy", 2000 * 5}},
		[4] = {{"BasicExp", 150 * 5}, {"Energy", 2500 * 5}},
		[5] = {{"BasicExp", 160 * 5}, {"Energy", 3000 * 5}},
		[6] = {{"BasicExp", 180 * 5}, {"Energy", 4000 * 5}},
		[7] = {{"BasicExp", 200 * 5}, {"Energy", 5000 * 5}},
		[8] = {{"BasicExp", 220 * 5}, {"Energy", 7000 * 5}},
	};
	[TeamBattle.TYPE_QUARTERLY] = {
		[1] = {{"BasicExp", 100 * 5}, {"Energy", 3000 * 5}},
		[2] = {{"BasicExp", 120 * 5}, {"Energy", 3500 * 5}},
		[3] = {{"BasicExp", 140 * 5}, {"Energy", 4000 * 5}},
		[4] = {{"BasicExp", 150 * 5}, {"Energy", 5000 * 5}},
		[5] = {{"BasicExp", 160 * 5}, {"Energy", 6000 * 5}},
		[6] = {{"BasicExp", 180 * 5}, {"Energy", 8000 * 5}},
		[7] = {{"BasicExp", 200 * 5}, {"Energy", 10000 * 5}},
		[8] = {{"BasicExp", 220 * 5}, {"Energy", 15000 * 5}},
	};
	[TeamBattle.TYPE_YEAR] = {
		[1] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[2] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[3] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[4] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[5] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[6] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[7] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
		[8] = {{"BasicExp", 100 * 5}, {"Energy", 1000 * 5}},
	};
};

TeamBattle.tbStartFailMailInfo = {
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔开启失败", "      很遗憾，由于本场月度通天塔竞技比赛晋级玩家不足，导致不能正常举行比赛。现已为您准备了月度通天塔的最高奖励作为补偿，请查收。\n      望少侠再度征战通天塔，下一次能遇到旗鼓相当的对手，勇夺殊荣！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔开启失败", "      很遗憾，由于本场季度通天塔竞技比赛晋级玩家不足，导致不能正常举行比赛。现已为您准备了季度通天塔的最高奖励作为补偿，请查收。\n      望少侠再度征战通天塔，下一次能遇到旗鼓相当的对手，勇夺殊荣！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔开启失败", "      很遗憾，由于本场年度通天塔竞技比赛晋级玩家不足，导致不能正常举行比赛。现已为您准备了年度通天塔的最高奖励作为补偿，请查收。\n      望少侠再度征战通天塔，下一次能遇到旗鼓相当的对手，勇夺殊荣！"},
};

TeamBattle.tbSpaceTipsMailInfo = {
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔参与失败", "      很遗憾，由于您在月度通天塔竞技比赛中，未能组满队伍，导致不能正常参与比赛。现已为您准备了月度通天塔的基础奖励，请查收。\n      望少侠下次准备充分，携手队友，再度征战通天塔！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔参与失败", "      很遗憾，由于您在季度通天塔竞技比赛中，未能组满队伍，导致不能正常参与比赛。现已为您准备了季度通天塔的基础奖励，请查收。\n      望少侠下次准备充分，携手队友，再度征战通天塔！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔参与失败", "      很遗憾，由于您在年度通天塔竞技比赛中，未能组满队伍，导致不能正常参与比赛。现已为您准备了年度通天塔的基础奖励，请查收。\n      望少侠下次准备充分，携手队友，再度征战通天塔！"},
}

TeamBattle.tbAwardMailInfo =
{
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔挑战奖励", "      恭喜你在本次月度通天塔中登上%s层，获得如下奖励。"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔挑战奖励", "      恭喜你在本次季度通天塔中登上%s层，获得如下奖励。"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔挑战奖励", "      恭喜你在本次年度通天塔中登上%s层，获得如下奖励。"},
}

TeamBattle.nPreTipTime = 2 * 24 * 3600;			-- 开赛前提示，提前时间

-- 开赛前提示邮件
TeamBattle.tbLeagueTipMailInfo =
{
	[TeamBattle.TYPE_MONTHLY] = {"月度通天塔参赛通知", "      您已获得本次月度通天塔竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"},
	[TeamBattle.TYPE_QUARTERLY] = {"季度通天塔参赛通知", "      您已获得本次季度通天塔竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"},
	[TeamBattle.TYPE_YEAR] = {"年度通天塔参赛通知", "      您已获得本次年度通天塔竞技的参赛资格，比赛时间为[EACC00]%s[-]，请您务必准时参加。届时会有更丰厚的奖励以及更高的荣誉等着您！"},
}

-- 非程序勿动
TeamBattle.tbTipSaveValue =
{
	[TeamBattle.TYPE_MONTHLY] = TeamBattle.SAVE_MONTHLY_TIP,
	[TeamBattle.TYPE_QUARTERLY] = TeamBattle.SAVE_QUARTERLY_TIP,
	[TeamBattle.TYPE_YEAR] = TeamBattle.SAVE_YEAR_TIP,
}

TeamBattle.szStartMsg = "根据你队实力，本次从第%s层开始";
TeamBattle.szJoinMsg = "现在是%s层，开打了！";
TeamBattle.szWinMsg = "挑战成功，登上第%s层！";
TeamBattle.szFailMsg = "遗憾落败，继续留在第%s层！";
TeamBattle.szTopMsg = "恭喜你们本次通天塔登上了第%s层！";

TeamBattle.STATE_TRANS =  --战场流程控制
{
	{nSeconds = 5,   	szFunc = "WaitePlayer",		szDesc = "等待开始"},
	{nSeconds = 5,   	szFunc = "ShowTeamInfo",	szDesc = "等待开始"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待开始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "上半场"},
	{nSeconds = 20,   	szFunc = "MidRest",			szDesc = "中场休息"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待开始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "下半场"},
	{nSeconds = 20,   	szFunc = "ClcResult",		szDesc = "等待匹配"},
}

TeamBattle.STATE_TRANS_CROSS =  --战场流程控制
{
	{nSeconds = 10,   	szFunc = "WaitePlayer",		szDesc = "等待开始"},
	{nSeconds = 5,   	szFunc = "ShowTeamInfo",	szDesc = "等待开始"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待开始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "上半场"},
	{nSeconds = 20,   	szFunc = "MidRest",			szDesc = "中场休息"},
	{nSeconds = 4,   	szFunc = "PreStart",		szDesc = "等待开始"},
	{nSeconds = 86,   	szFunc = "StartFight",		szDesc = "下半场"},
	{nSeconds = 20,   	szFunc = "ClcResult",		szDesc = "等待匹配"},
}

TeamBattle.emMsgNotTeamCaptain		= 1;
TeamBattle.emMsgNotNeedTeam			= 2;
TeamBattle.emMsgNeedTeam			= 3;
TeamBattle.emMsgTeamMemeberErr		= 4;
TeamBattle.emMsgMemberOffline		= 5;
TeamBattle.emMsgMemberMinLevel		= 6;
TeamBattle.emMsgMemberSafeMap		= 7;
TeamBattle.emMsgMemberAloneState	= 8;
TeamBattle.emMsgMinLevel			= 9;
TeamBattle.emMsgSafeMap				= 10;
TeamBattle.emMsgAloneState			= 11;
TeamBattle.emMsgHasNoBattle			= 12;
TeamBattle.emMsgTimesErr			= 13;
TeamBattle.emMsgMemberTimesErr		= 14;
TeamBattle.emMsgHasFight			= 15;
TeamBattle.emMsgMemberNotSafePoint	= 16;
TeamBattle.emMsgNotSafePoint		= 17;
TeamBattle.emMsgSystemSwitch		= 18;
TeamBattle.emMsgMemberSystemSwitch	= 19;
TeamBattle.emMsgLeagueTicket		= 20;
TeamBattle.emMsgMemberLeagueTicket	= 21;
TeamBattle.emMsgMemberHasLeagueTicket	= 22;

TeamBattle.tbMsg =
{
	[TeamBattle.emMsgNotTeamCaptain]		= "不是队长，无法操作！";
	[TeamBattle.emMsgNotNeedTeam]			= "组队状态，无法单人报名！";
	[TeamBattle.emMsgNeedTeam]				= "没有队伍，无法组队报名！";
	[TeamBattle.emMsgTeamMemeberErr]		= "组队模式最多只允许%s人报名！";
	[TeamBattle.emMsgMemberOffline]			= "有队员不在线，无法报名！";
	[TeamBattle.emMsgMemberMinLevel]		= "「%s」等级不足%s，无法报名！";
	[TeamBattle.emMsgMemberSafeMap]			= "「%s」所在地图无法报名！";
	[TeamBattle.emMsgMemberAloneState]		= "「%s」正在参与其它活动，无法报名！";
	[TeamBattle.emMsgMinLevel]				= "等级不足%s，无法参加！";
	[TeamBattle.emMsgSafeMap]				= "当前地图无法报名！";
	[TeamBattle.emMsgAloneState]			= "你正在参与其它活动，等结束后再来报名！";
	[TeamBattle.emMsgHasNoBattle]			= "活动未开启！";
	[TeamBattle.emMsgTimesErr]				= "你可参与次数不足！";
	[TeamBattle.emMsgLeagueTicket]			= "你没有参赛资格！";
	[TeamBattle.emMsgMemberTimesErr]		= "「%s」可参与次数不足！";
	[TeamBattle.emMsgMemberLeagueTicket]	= "「%s」尚未获取系列赛资格，无法参加。";
	[TeamBattle.emMsgMemberHasLeagueTicket]	= "「%s」拥有系列赛资格，无法参加跨服通天塔。";
	[TeamBattle.emMsgHasFight]				= "本次通天塔已开启，请等下次再来";
	[TeamBattle.emMsgMemberNotSafePoint]	= "「%s」不在安全区，无法报名！";
	[TeamBattle.emMsgNotSafePoint]			= "你不在安全区，无法报名";
	[TeamBattle.emMsgSystemSwitch]			= "你当前状态不允许报名";
	[TeamBattle.emMsgMemberSystemSwitch]	= "「%s」当前状态不允许报名";
}

-- 通天塔奖励配置
TeamBattle.tbReward =
{

	{"Item", 1346, 1},
	{"Item", 1736, 1},
	{"Contrib", 0},

}

-- 是否不开放年度通天塔
TeamBattle.bNotOpenYear = true

TeamBattle.nDelayLimitFloorFight = 25
TeamBattle.nDelayStartCrossFight = 10
TeamBattle.nDelayCrossFight = 3

function TeamBattle:RefreshTimes(pPlayer)
	local nUsedTimes = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT);
	local nLastWeekUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_USE_COUNT);
	local nSaveDate = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_DATE);
	local nWeek = Lib:GetLocalWeek();

	if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_DATE) ~= nWeek - 1 then
		nLastWeekUseCount = self.nMaxTimes;

		if nSaveDate == nWeek - 1 then
			nLastWeekUseCount = nUsedTimes;
		elseif nSaveDate > 0 and nSaveDate < nWeek - 1 then
			nLastWeekUseCount = 0;
		end
		if MODULE_GAMESERVER then
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_USE_COUNT, nLastWeekUseCount);
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_LAST_WEEK_DATE, nWeek - 1);
		end
	end

	if nSaveDate ~= nWeek then
		if MODULE_GAMESERVER then
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_DATE, nWeek);
			pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT, 0);
		end
		nUsedTimes = 0;
	end

	return nUsedTimes, nLastWeekUseCount;
end

function TeamBattle:GetLastTimes(pPlayer)
	local nCostTimes, nLastWeekUseCount = self:RefreshTimes(pPlayer);
	local nMaxTimes = 0;
	local nWeekDay = Lib:GetLocalWeekDay();
	for _, nWDay in pairs(self.tbRefreshDay) do
		if nWDay <= nWeekDay then
			nMaxTimes = nMaxTimes + 1;
		end
	end

	local nLastWeekMaxTimes = math.min(self.nMaxTimes, #self.tbRefreshDay);

	-- 开了攻城战后会周六少开一场
	if GetTimeFrameState("OpenDomainBattle") == 1 then
		nMaxTimes = nMaxTimes - 1;
		nLastWeekMaxTimes = nLastWeekMaxTimes - 1;

		-- 恰好是周日开启攻城战的时间轴，本周六已过，此时攻城战不开，那么本周六还是正常开，所以还有3场
		if nWeekDay == 7 then
			local nOpenTime = CalcTimeFrameOpenTime("OpenDomainBattle");
			local nOpenDay = Lib:GetLocalDay(nOpenTime);
			if nOpenDay == Lib:GetLocalDay() then
				nMaxTimes = nMaxTimes + 1;
			end
		elseif nWeekDay < 6 then
			nMaxTimes = nMaxTimes + 1;
		end
	end

	nMaxTimes = math.min(nMaxTimes, self.nMaxTimes);

	local nLastTimes = nMaxTimes - nCostTimes;
	nLastTimes = math.max(nLastTimes, 0);


	return nLastTimes, nMaxTimes, math.max(nLastWeekMaxTimes - nLastWeekUseCount, 0);
end

function TeamBattle:CostTimes(pPlayer)
	self:RefreshTimes(pPlayer);
	local nCurUseCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT);
	pPlayer.SetUserValue(self.SAVE_GROUP, self.SAVE_USE_COUNT, math.max(nCurUseCount + 1, 1));
	self:OnPlayedTeamBattle(pPlayer)	
end

function TeamBattle:OnPlayedTeamBattle(pPlayer)
	Achievement:AddCount(pPlayer, "TeamBattle_1", 1);
	TeacherStudent:CustomTargetAddCount(pPlayer, "Tower", 1)
end

function TeamBattle:SendMsgCode(player, nCode, ...)
	local pPlayer = player;
	if type(player) == "number" then
		pPlayer = KPlayer.GetPlayerObjById(player);
	end
	if not pPlayer then
		return;
	end

	if type(nCode) == "string" then
		pPlayer.CenterMsg(nCode)
		return
	end

	pPlayer.CallClientScript("TeamBattle:MsgCode", nCode, ...);
end

function TeamBattle:CheckTicket(pPlayer, nType, nTime)
	nTime = nTime or GetTime();
	local nNextOpenTime = self:GetNextOpenTime(nType, nTime);
	if nType == self.TYPE_MONTHLY then
		local nCheckMonth = Lib:GetLocalMonth(nNextOpenTime);
		nCheckMonth = nCheckMonth - 1;
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_MONTHLY_INFO) == nCheckMonth or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_MONTHLY_INFO_OLD) == nCheckMonth then

			return true;
		end
	elseif nType == self.TYPE_QUARTERLY then
		local nLocalSeason = Lib:GetLocalSeason(nNextOpenTime);
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_QUARTERLY_INFO) == nLocalSeason or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_QUARTERLY_INFO_OLD) == nLocalSeason then

			return true;
		end
	elseif nType == self.TYPE_YEAR then
		local nLocalYear = Lib:GetLocalYear(nNextOpenTime);
		nLocalYear = nLocalYear - 1;
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_YEAR_INFO) == nLocalYear or
			pPlayer.GetUserValue(self.SAVE_GROUP, self.SAVE_YEAR_INFO_OLD) == nLocalYear then

			return true;
		end
	end

	return false;
end

function TeamBattle:GetNextOpenTime(nType, nTime)
	if not MODULE_ZONESERVER and GetTimeFrameState(TeamBattle.szLeagueOpenTimeFrame) ~= 1 then
		return nil;
	end

	local nNow = nTime or GetTime();
	if nType == self.TYPE_MONTHLY then
		local nOpenTime = Lib:GetTimeByWeekInMonth(nNow, TeamBattle.nMonthlyOpenWeek, TeamBattle.nMonthlyOpenWeekDay, TeamBattle.nMonthlyOpenHour, TeamBattle.nMonthlyOpenMin, 0);
		if nOpenTime < nNow then
			local tbTime = os.date("*t", nOpenTime);
			tbTime.month = tbTime.month + 1;
			if tbTime.month > 12 then
				tbTime.month = 1;
				tbTime.year = tbTime.year + 1;
			end

			nOpenTime = os.time(tbTime);
			nOpenTime = Lib:GetTimeByWeekInMonth(nOpenTime, TeamBattle.nMonthlyOpenWeek, TeamBattle.nMonthlyOpenWeekDay, TeamBattle.nMonthlyOpenHour, TeamBattle.nMonthlyOpenMin, 0);
		end

		return nOpenTime;
	elseif nType == self.TYPE_QUARTERLY then
		local tbTime = os.date("*t", nNow);
		local nOpenMonth = math.ceil(tbTime.month / 3) * 3;
		if nOpenMonth ~= tbTime.month then
			tbTime.month = nOpenMonth;
			tbTime.day = 1;
			tbTime.hour = 0;
			tbTime.min = 0;
		end

		local nTime = os.time(tbTime);
		local nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nQuarterlyOpenWeek, TeamBattle.nQuarterlyOpenWeekDay, TeamBattle.nQuarterlyOpenHour, TeamBattle.nQuarterlyOpenMin, 0);
		if nOpenTime < nNow then
			tbTime.month = nOpenMonth + 3;
			if tbTime.month > 12 then
				tbTime.year = tbTime.year + 1;
				tbTime.month = 3;
			end
		end

		nTime = os.time(tbTime);
		nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nQuarterlyOpenWeek, TeamBattle.nQuarterlyOpenWeekDay, TeamBattle.nQuarterlyOpenHour, TeamBattle.nQuarterlyOpenMin, 0);
		assert(nOpenTime > nNow);

		return nOpenTime;
	elseif nType == self.TYPE_YEAR then
		local tbTime = os.date("*t", nNow);
		tbTime.month = TeamBattle.nYearOpenMonth;
		tbTime.day = 1;
		tbTime.hour = 0;
		tbTime.min = 0;

		local nTime = os.time(tbTime);
		local nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nYearOpenWeek, TeamBattle.nYearOpenWeekDay, TeamBattle.nYearOpenHour, TeamBattle.nYearOpenMin, 0);
		if nOpenTime < nNow then
			tbTime.year = tbTime.year + 1;
		end

		nTime = os.time(tbTime);
		nOpenTime = Lib:GetTimeByWeekInMonth(nTime, TeamBattle.nYearOpenWeek, TeamBattle.nYearOpenWeekDay, TeamBattle.nYearOpenHour, TeamBattle.nYearOpenMin, 0);
		assert(nOpenTime > nNow);

		return nOpenTime;
	end
end