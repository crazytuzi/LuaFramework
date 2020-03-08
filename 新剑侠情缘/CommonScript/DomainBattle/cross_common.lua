Require("CommonScript/DomainBattle/define.lua");

DomainBattle.tbCross = DomainBattle.tbCross or {};
DomainBattle.tbCrossDef = DomainBattle.tbCrossDef or {};
local tbCross = DomainBattle.tbCross
local tbCrossDef = DomainBattle.tbCrossDef
local tbDefine = DomainBattle.define

local preEnv;
if tbCrossDef then --调试需要
	preEnv = _G;	--保存旧的环境
	setfenv(1, tbCrossDef)
end

szOpenFrame = "OpenCrossDomainBattle"
nOpenWeekDay = 7 --每隔2周的周日开启
tbAidSignUpTime = {"10:00", "20:50"} --助战报名开启时间段
nMinLevel = 20
nKinCount = 5 --每个服最多几个家族参与
nAidCount = 10 --每个家族最多助战人数
nMapExsitTime = 40*60 --动态地图存在时间(秒)
nPillarInvincibleBuffId = 4903
nPillarInvincibleTime = 10
nPillarAddScoreInterval = 10
nThroneLockBuffId = 4902
nMaxKingPlayer = 40 --王城每个家族最多人数

nMaxSyncTopKin = 10
nMaxSyncTopPlayer = 10

nHonor2Box = 800 --每800积分换一个宝箱
nAwardBoxId = 7435 --宝箱id

tbStatuePos = {15, 18041, 11277, 0}

tbQualifiedScore = --本服资格积分
{
	[tbDefine.tbDomainType.nCity] = 10,
	[tbDefine.tbDomainType.nTown] = 5,
	[tbDefine.tbDomainType.nVillage] = 3,
}

tbAidHonorLevel = --助战头衔限制
{
	["OpenLevel109"] = 8,
	["OpenLevel119"] = 9,
	["OpenLevel129"] = 12,
	["OpenLevel139"] = 12,
	["OpenLevel149"] = 15,
}

tbNpcTimeFrameLevel =
{
	["OpenLevel109"] = 105,
	["OpenLevel119"] = 115,
	["OpenLevel129"] = 125,
	["OpenLevel139"] = 135,
	["OpenLevel149"] = 145,
	["OpenLevel159"] = 155,
	["OpenLevel169"] = 165,
};

tbSiegeBuffLevel =
{
	["OpenLevel59"] = 1,
	["OpenLevel69"] = 2,
	["OpenLevel79"] = 3,
	["OpenLevel89"] = 4,
	["OpenLevel99"] = 5,
	["OpenLevel109"] = 6,
	["OpenLevel119"] = 7,
	["OpenLevel129"] = 8,
	["OpenLevel139"] = 9,
	["OpenLevel149"] = 10,
}

tbPillarWarningHp =
{
	{nPercent=99, szMsg="正在被攻击"},
	{nPercent=70, szMsg="损毁严重"},
	{nPercent=40, szMsg="即将倒塌"},
}

tbMapType =
{
	Outer = 1,
	Inner = 2,
	King = 3,
}

tbMapInfoList =
{
	[tbMapType.King] =
	{
		szName = "临安王城",
		nTemplateId = 8000,
		nType = tbMapType.King,
	},

	[tbMapType.Inner] =
	{
		szName = "临安内城",
		nTemplateId = 8001,
		nType = tbMapType.Inner,
	},

	[tbMapType.Outer] =
	{
		szName = "临安外城",
		nTemplateId = 8002,
		nType = tbMapType.Outer,
	}
}

tbBattleApplyIds =
{	--[道具id] = {"触发函数名", 召唤npcid, 默认朝向}
	[2502] = {"UseItemCallDialogNpc", 2848, 16, "攻城车"};	--召唤的变身对话npcid和朝向,Class 需要是 DomainBattleChange, true是攻城车
	[2503] = {"UseItemCallDialogNpc", 2849, 16, "劲弩车"};	--劲弩车
	[2504] = {"UseItemCallDialogNpc", 2850, 16, "铁炮车"};	--铁炮车
	[2505] = {"UseItemCallAttackNpc", 2851, 16, "神射手", 150};	--，召唤的攻击NpcId，最后参数是击杀对应积分
	[2506] = {"UseItemCallAttackNpc", 2852, 40, "鼓舞旗", 200};	--
};

tbPlayerAward =
{
	{nRankEnd = 1,		tbAward = {{"CrossDomainHonor", 3200}, {"BasicExp", 180}}},
	{nRankEnd = 2,		tbAward = {{"CrossDomainHonor", 3000}, {"BasicExp", 170}}},
	{nRankEnd = 3,		tbAward = {{"CrossDomainHonor", 2800}, {"BasicExp", 160}}},
	{nRankEnd = 10,		tbAward = {{"CrossDomainHonor", 2600}, {"BasicExp", 150}}},
	{nRankEnd = 20,		tbAward = {{"CrossDomainHonor", 2400}, {"BasicExp", 140}}},
	{nRankEnd = 30,		tbAward = {{"CrossDomainHonor", 2200}, {"BasicExp", 130}}},
	{nRankEnd = 50,		tbAward = {{"CrossDomainHonor", 2000}, {"BasicExp", 120}}},
	{nRankEnd = 70,		tbAward = {{"CrossDomainHonor", 1800}, {"BasicExp", 110}}},
	{nRankEnd = 90,		tbAward = {{"CrossDomainHonor", 1600}, {"BasicExp", 105}}},
	{nRankEnd = 100,	tbAward = {{"CrossDomainHonor", 1400}, {"BasicExp", 100}}},
}

tbKinRankAward =
{
	[1] =	50000000,
	[2] =	30000000,
	[3] =	30000000,
	[4] =	25000000,
	[5] =	25000000,
	[6] =	20000000,
	[7] =	20000000,
	[8] =	20000000,
	[9] =	20000000,
	[10] =	20000000,
	[11] =	18000000,
	[12] =	18000000,
	[13] =	18000000,
	[14] =	18000000,
	[15] =	18000000,
	[16] =	15000000,
	[17] =	15000000,
	[18] =	15000000,
	[19] =	15000000,
	[20] =	15000000,
}

tbKinAward =
{
	["OpenLevel119"] =
	{
		{szDesc="初级魂石·完颜洪烈（真）",	nId=4053,	nFactor = 0.5/12,	nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·虞允文",			nId=7377,	nFactor = 2.5/12,	nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·空相",				nId=7741,	nFactor = 1.5/12,	nValue=1350000},
		{szDesc="初级魂石·王腾",				nId=7648,	nFactor = 1/12,		nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·王云潇",			nId=7649,	nFactor = 0.5/12,	nValue=1350000},
		{szDesc="初级魂石·惊雪",				nId=7650,	nFactor = 0.5/12,	nValue=1350000},
		{szDesc="元气精华（5000）",			nId=7394,	nFactor = 0.5/12,	nValue=500000},
		{szDesc="帝皇令",					nId=1396,	nFactor = 1/12,		nValue=3000000},
		-- {szDesc="传说令",					nId=1397,	nFactor = 0.0/12,	nValue=3600000},
		{szDesc="完颜洪烈(SSS)",				nId=4056,	nFactor = 2.5/12,	nValue=18000000, Guarantee = 1},
		{szDesc="完颜洪烈本命武器",			nId=4057,	nFactor = 1.5/12,	nValue=10000000},
	},
	["OpenLevel129"] =
	{
		{szDesc="初级魂石·完颜洪烈（真）",	nId=4053,	nFactor = 0.5/12,	nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·虞允文",			nId=7377,	nFactor = 2.5/12,	nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·空相",				nId=7741,	nFactor = 1.5/12,	nValue=1350000},
		{szDesc="初级魂石·王腾",				nId=7648,	nFactor = 1/12,		nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·王云潇",			nId=7649,	nFactor = 0.5/12,	nValue=1350000},
		{szDesc="初级魂石·惊雪",				nId=7650,	nFactor = 0/12,		nValue=1350000},
		{szDesc="元气精华（5000）",			nId=7394,	nFactor = 0.5/12,	nValue=500000},
		{szDesc="帝皇令",					nId=1396,	nFactor = 0.5/12,	nValue=3000000},
		{szDesc="传说令",					nId=1397,	nFactor = 3/12,		nValue=3600000,	Guarantee = 1,	SilverBoard = 1},
		{szDesc="完颜洪烈(SSS)",				nId=4056,	nFactor = 1.5/12,	nValue=18000000},
		{szDesc="完颜洪烈本命武器",			nId=4057,	nFactor = 0.5/12,	nValue=10000000},
	},
	["OpenLevel139"] =
	{
		{szDesc="初级魂石·完颜洪烈（真）",	nId=4053,	nFactor = 0/12,		nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·虞允文",			nId=7377,	nFactor = 2/12,		nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·空相",				nId=7741,	nFactor = 1/12,		nValue=1350000},
		{szDesc="初级魂石·王腾",				nId=7648,	nFactor = 0.5/12,	nValue=4050000,	Guarantee = 1},
		{szDesc="初级魂石·王云潇",			nId=7649,	nFactor = 0.5/12,	nValue=1350000},
		{szDesc="初级魂石·惊雪",				nId=7650,	nFactor = 0/12,		nValue=1350000},
		{szDesc="初级魂石·方公望",			nId=9974,	nFactor = 2/12,		nValue=4050000,	Guarantee = 1},
		{szDesc="元气精华（5000）",			nId=7394,	nFactor = 0.5/12,	nValue=500000},
		{szDesc="帝皇令",					nId=1396,	nFactor = 0.5/12,	nValue=3000000},
		{szDesc="传说令",					nId=1397,	nFactor = 3/12,		nValue=3600000,	Guarantee = 1,	SilverBoard = 1},
		{szDesc="完颜洪烈(SSS)",				nId=4056,	nFactor = 1.5/12,	nValue=18000000},
		{szDesc="完颜洪烈本命武器",			nId=4057,	nFactor = 0.5/12,	nValue=10000000},
	},
}

tbStateCfg =
{
	--{nTime=阶段持续时间，szOnStartFun=阶段开始时调用函数，szOnEndFun=阶段结束时调用函数, szDesc=描述}
	{nTime=60*5, szOnStartFun="StartPrepare", 		szOnEndFun="", 				szDesc="准备阶段"},
	{nTime=60*10, szOnStartFun="StartBattle", 		szOnEndFun="", 				szDesc="战斗阶段"},
	{nTime=60*10, szOnStartFun="StartInnerCity", 	szOnEndFun="EndInnerCity", 	szDesc="内城争夺"},
	{nTime=60*10, szOnStartFun="", 					szOnEndFun="", 				szDesc="战斗阶段"},
	{nTime=60*1, szOnStartFun="StartAward", 		szOnEndFun="EndBattle", 	szDesc="结束战斗"},
}

if preEnv then
	preEnv.setfenv(1, preEnv); --恢复全局环境
end

tbCrossDef.tbMapTemplateId2Info = {}
for _, tbMapInfo in ipairs( tbCrossDef.tbMapInfoList ) do
	tbCrossDef.tbMapTemplateId2Info[tbMapInfo.nTemplateId] = tbMapInfo
end

function tbCross:GetCrossOpenDay()
	return Lib:GetLocalDay(self:GetCrossOpenTime())
end

function tbCross:GetAidMinHonorLevel()
	return tbCrossDef.tbAidHonorLevel[Lib:GetMaxTimeFrame(tbCrossDef.tbAidHonorLevel)] or 999
end

function tbCross:IsStartAidSignUp()
	return self.bAidSignUp
end

function tbCross:IsCanAid(pPlayer)
	if not self:IsStartAidSignUp() then
		return false
	end

	if pPlayer.nLevel < tbCrossDef.nMinLevel then
		return false
	end

	local nMinHonorLevel = self:GetAidMinHonorLevel()
	if not nMinHonorLevel or pPlayer.nHonorLevel < nMinHonorLevel then
		return false
	end

	return true
end

function tbCross:IsDomainMap(nMapTemplateId)
	return tbCrossDef.tbMapTemplateId2Info[nMapTemplateId] ~= nil
end

function tbCross:IsOuterMap(nMapTemplateId)
	local tbOuterInfo = tbCrossDef.tbMapInfoList[tbCrossDef.tbMapType.Outer]
	return tbOuterInfo.nTemplateId == nMapTemplateId
end

function tbCross:CheckCrossDay()
	if not MODULE_ZONESERVER then
		if GetTimeFrameState(tbCrossDef.szOpenFrame) ~= 1 then
			return false
		end
	end

	if Activity:__IsActInProcessByType("WuLinDaHuiAct") then
		return false
	end

	if KinEncounter:IsOpenToday() then
		return false
	end

	--检查是否跨服攻城战开战的日期
	local nOpenTime = self:GetCrossOpenTime();

	if Lib:GetLocalDay(nOpenTime) ~= Lib:GetLocalDay() then
		return false
	end

	local nNow = Lib:GetLocalDayTime()

	return nNow < Lib:ParseTodayTime("21:40")
end

--本周是否开启跨服攻城战
function tbCross:CheckCrossWeek()
	if not MODULE_ZONESERVER then
		if GetTimeFrameState(tbCrossDef.szOpenFrame) ~= 1 then
			return false
		end
	end

	if Activity:__IsActInProcessByType("WuLinDaHuiAct") then
		return false
	end

	--检查是否跨服攻城战开战的日期
	local nOpenTime = self:GetCrossOpenTime();
	if KinEncounter:WillOpen(nOpenTime) then
		return false
	end

	return Lib:GetLocalWeek(nOpenTime) == Lib:GetLocalWeek()
end
