Require("CommonScript/Help/StrongerDefine.lua")
Player.Stronger = Player.Stronger or {}
local Stronger = Player.Stronger

Stronger.nRecommendRequestInvterval = 5*60;

Stronger.panelCfg = LoadTabFile("Setting/Help/StrongerPanel.tab", "dddssssddss", nil, {"BaseId","SubId","DetailId","Name","Desc","Icon","IconAtlas","Stars", "Level", "TimeFrame","Action"})

local szLevelPrefix = "StLevel"
local szQualityPrefix = "StQuality"
local szFPPrefix = "FP"
local tbEquipPartSuffix = {"Helm", "Armor", "Belt", "Weapon", "Boots", "Cuff", "Amulet", "Ring", "Necklace", "Pendant"};
local tbHorsePartSuffix = {"Horse", "Rein", "Saddle", "Pedal"};
local tbNormalPartSuffix = {"1", "2", "3", "4"};

local tbEquipLevelIdx = {}
local tbEquipFPIdx = {}
for _, szSuffix in ipairs( tbEquipPartSuffix ) do
	table.insert(tbEquipLevelIdx, string.format("%s_%s", szLevelPrefix, szSuffix))
	table.insert(tbEquipFPIdx, string.format("%s_%s", szFPPrefix, szSuffix))
end
local tbEquipLevelFPIdx = Lib:MergeTable(Lib:CopyTB(tbEquipLevelIdx), tbEquipFPIdx)

local tbHorseLevelIdx = {}
local tbHorseFPIdx = {}
for _, szSuffix in ipairs( tbHorsePartSuffix ) do
	table.insert(tbHorseLevelIdx, string.format("%s_%s", szLevelPrefix, szSuffix))
	table.insert(tbHorseFPIdx, string.format("%s_%s", szFPPrefix, szSuffix))
end
local tbHorseLevelFPIdx = Lib:MergeTable(Lib:CopyTB(tbHorseLevelIdx), tbHorseFPIdx)

local tbNormalLevelIdx = {}
local tbNormalQualityIdx = {}
local tbNormalFPIdx = {}
for _, szSuffix in ipairs( tbNormalPartSuffix ) do
	table.insert(tbNormalLevelIdx, string.format("%s_%s", szLevelPrefix, szSuffix))
	table.insert(tbNormalQualityIdx, string.format("%s_%s", szQualityPrefix, szSuffix))
	table.insert(tbNormalFPIdx, string.format("%s_%s", szFPPrefix, szSuffix))
end
local tbNormalLevelFPIdx = Lib:MergeTable(Lib:CopyTB(tbNormalLevelIdx), tbNormalFPIdx)
local tbNormalLevelQualityFPIdx = Lib:MergeTable(Lib:MergeTable(Lib:CopyTB(tbNormalLevelIdx), tbNormalQualityIdx), tbNormalFPIdx)

Stronger.RecommendFP = LoadTabFile("Setting/Help/RecommendFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendStrenthenFP = LoadTabFile("Setting/Help/RecommendStrenthenFP.tab", "dddddddddddddddddddddd", "Level", {"Level", "FightPower", unpack(tbEquipLevelFPIdx)})
Stronger.RecommendStoneFP = LoadTabFile("Setting/Help/RecommendStoneFP.tab", "dddddddddddddddddddddd", "Level", {"Level", "FightPower", unpack(tbEquipLevelFPIdx)})
Stronger.RecommendEquipFP = LoadTabFile("Setting/Help/RecommendEquipFP.tab", "dddddddddddd", "Level", {"Level", "FightPower", unpack(tbEquipFPIdx)})
Stronger.RecommendHorseFP = LoadTabFile("Setting/Help/RecommendHorseFP.tab", "dddddddddd", "Level", {"Level", "FightPower", unpack(tbHorseLevelFPIdx)})
Stronger.RecommendPartnerFP = LoadTabFile("Setting/Help/RecommendPartnerFP.tab", "dddddddddd", "Level", {"Level", "FightPower", unpack(tbNormalLevelFPIdx)})
Stronger.RecommendPartnerCardFP = LoadTabFile("Setting/Help/RecommendPartnerCardFP.tab", "dddddddddd", "Level", {"Level", "FightPower", unpack(tbNormalLevelFPIdx)})
Stronger.RecommendZhenYuanFP = LoadTabFile("Setting/Help/RecommendZhenYuanFP.tab", "dddd", "Level", {"Level", "FightPower", szLevelPrefix, szQualityPrefix})
Stronger.RecommendJingMaiFP = LoadTabFile("Setting/Help/RecommendJingMaiFP.tab", "dddddddddddddd", "Level", {"Level", "FightPower", unpack(tbNormalLevelQualityFPIdx)})
Stronger.RecommendZhenFaFP = LoadTabFile("Setting/Help/RecommendZhenFaFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendSkillBookFP = LoadTabFile("Setting/Help/RecommendSkillBookFP.tab", "dddddddddd", "Level", {"Level", "FightPower", unpack(tbNormalLevelFPIdx)})
Stronger.RecommendJueXueFP = LoadTabFile("Setting/Help/RecommendJueXueFP.tab", "dd", "Level", {"Level", "FightPower"})
Stronger.RecommendSkillFP = LoadTabFile("Setting/Help/RecommendSkillFP.tab", "dd", "Level", {"Level", "FightPower"})

Stronger.RecommendDetail =
{
	[Stronger.Type.Strengthen] = Stronger.RecommendStrenthenFP or {},
	[Stronger.Type.Stone] = Stronger.RecommendStoneFP or {},
	[Stronger.Type.Refine] = Stronger.RecommendEquipFP or {},
	[Stronger.Type.Horse] = Stronger.RecommendHorseFP or {},
	[Stronger.Type.Partner] = Stronger.RecommendPartnerFP or {},
	[Stronger.Type.PartnerCard] = Stronger.RecommendPartnerCardFP or {},
	[Stronger.Type.ZhenYuan] = Stronger.RecommendZhenYuanFP or {},
	[Stronger.Type.JingMai] = Stronger.RecommendJingMaiFP or {},
	[Stronger.Type.ZhenFa] = Stronger.RecommendZhenFaFP or {},
	[Stronger.Type.SkillBook] = Stronger.RecommendSkillBookFP or {},
	[Stronger.Type.JueXue] = Stronger.RecommendJueXueFP or {},
	[Stronger.Type.SkillPoint] = Stronger.RecommendSkillFP or {},
}

Stronger.StateColor =
{
	["急需提升"] = {r = 255, g = 50, b = 50},
	["勉勉强强"] = {r = 0, g = 244, b = 255},
	["成绩平平"] = {r = 255, g = 164, b = 0},
	["出类拔萃"] = {r = 114, g = 255, b = 0},
	["出神入化"] = {r = 255, g = 248, b = 0},
}

Stronger.nCurFightPower = Stronger.nCurFightPower or 0
Stronger.detailFightPower = Stronger.detailFightPower or {}
Stronger.tbRecommend = Stronger.tbRecommend or {}


if not version_tx then
	Stronger.tbMarkSprite =
	{
		Smark = "Smark",
		Amark = "Amark",
		Bmark = "Bmark",
		Cmark = "Cmark",
	}
else
	Stronger.tbMarkSprite =
	{
		Smark = "Amark4",
		Amark = "Amark3",
		Bmark = "Amark2",
		Cmark = "Amark1",
	}
end

function Stronger:Init()
	self.baseList = {}
	self.subList = {}
	self.detailList = {}

	for _,cfg in ipairs(Stronger.panelCfg) do
		if cfg.DetailId and cfg.DetailId > 0 then
			local  subId  = 1
			if cfg.SubId and cfg.SubId > 0  then
				subId = cfg.SubId
			end

			self.detailList[cfg.BaseId] = self.detailList[cfg.BaseId] or {}
			self.detailList[cfg.BaseId][subId] = self.detailList[cfg.BaseId][subId] or {}
			self.detailList[cfg.BaseId][subId][cfg.DetailId] = cfg
		elseif cfg.SubId and cfg.SubId > 0 then
			self.subList[cfg.BaseId] = self.subList[cfg.BaseId] or {}
			self.subList[cfg.BaseId][cfg.SubId] = cfg
		else
			self.baseList[cfg.BaseId] = cfg
		end
	end

	local tbStoneTypeCfg = LoadTabFile("Setting/Help/RecommendStoneType.tab", "ddddddddd", nil, {"Level", "EquipPos", "StoneId1", "StoneId2", "StoneId3", "StoneId4", "StoneId5", "StoneId6", "StoneId7"});
	self.RecommendStoneType = {}
	for _, tbCfg in ipairs( tbStoneTypeCfg ) do
		self.RecommendStoneType[tbCfg.Level] = self.RecommendStoneType[tbCfg.Level] or {}
		self.RecommendStoneType[tbCfg.Level][tbCfg.EquipPos] = tbCfg;
	end
end

function Stronger:SyncFightPower(nCurFightPower, detailList)
	self.nCurFightPower = nCurFightPower
	self.detailFightPower = detailList

	UiNotify.OnNotify(UiNotify.emNOTIFY_FIGHT_POWER_CHANGE)
end

function Stronger:RecommendRequest()
	if TimeFrame:GetTimeFrameState(Stronger.RECOMMEND_TIMEFRAME) ~= 1 then
		return
	end

	local nNow = GetTime();
	if self.nLastRecommendRequest and self.nLastRecommendRequest + self.nRecommendRequestInvterval > nNow then
		return
	end

	self.nLastRecommendRequest = nNow
	RemoteServer.StrongerRecommendRequest();
end

function Stronger:SyncRecommendData(tbTotal, tbModule)
	self.tbTotal = tbTotal;
	self.tbModule = tbModule;
	UiNotify.OnNotify(UiNotify.emNOTIFY_FIGHT_POWER_RECOMMEND)
end

function Stronger:CheckRecoomendData()
	if TimeFrame:GetTimeFrameState(Stronger.RECOMMEND_TIMEFRAME) ~= 1 then
		return true
	end

	if not self.tbTotal or not self.tbModule then
		self:RecommendRequest()
		return true
	end
end

function Stronger:GetDefaultRecommendFP()
	local _, nRecommendPower = Stronger:GetPlayerJudge(me.nLevel,  Stronger:GetPlayerFightPower())
	return 1, nRecommendPower;
end

function Stronger:GetRecommendFP()
	if self:CheckRecoomendData() then
		return self:GetDefaultRecommendFP()
	end

	local nRank, nFP, _, bFirstRank = self:GetRecommendData(self.nCurFightPower, self.tbTotal)
	if not nRank or nRank <= 0  then
		self:RecommendRequest();
		return self:GetDefaultRecommendFP()
	end

	if bFirstRank then
		return self:GetDefaultRecommendFP()
	end

	return nRank, nFP
end

function Stronger:GetDefaultRecommendDataByType(nType, nLevel)
	local nRecommendFP = 0;
	local nRecommendRank = 1;
	local tbRecommendData = {
			nTotalFPAvg = 0,
			tbOtherTotalAvg = {},
			tbDetailAvg = {},
			nCount = 0,
		}

	local tbCfg = self.RecommendDetail[nType][nLevel]
	local pfnProcess = self.tbDefaultProcess[nType]
	if not tbCfg or not pfnProcess then
		return nRecommendRank, nRecommendFP, tbRecommendData
	end

	nRecommendFP = tbCfg.FightPower
	tbRecommendData.nTotalFPAvg = nRecommendFP

	pfnProcess(tbCfg, tbRecommendData)

	return nRecommendRank, nRecommendFP, tbRecommendData;
end

function Stronger:GetRecommendDataByType(nType)
	if self:CheckRecoomendData() then
		return self:GetDefaultRecommendDataByType(nType, me.nLevel)
	end

	if not self.tbModule[nType] or Lib:CountTB(self.tbModule[nType]) <= 0 then
		return self:GetDefaultRecommendDataByType(nType, me.nLevel)
	end

	local nRank, nFP, tbInfo, bFirstRank = self:GetRecommendData(self.detailFightPower[nType] or 0, self.tbModule[nType])
	if not nRank or nRank <= 0  then
		self:RecommendRequest();
		return self:GetDefaultRecommendDataByType(nType, me.nLevel)
	end

	if bFirstRank then
		return self:GetDefaultRecommendDataByType(nType, me.nLevel)
	end

	return nRank, nFP, tbInfo
end

function Stronger:GetRecommendData(nFP, tbDataList)
	local nMaxRank = -1;
	local nMaxFP = 0;
	local nHaveMaxRank  = 9999;
	local nHaveMaxRankFP = 0;
	local bFirstRank = false
	for nRank, data in pairs( tbDataList ) do
		local nRankFP
		if type(data) == "number" then
			nRankFP = data
		else
			nRankFP = data.nTotalFPAvg;
		end

		if nRank <= nHaveMaxRank then
			nHaveMaxRank = nRank
			nHaveMaxRankFP = nRankFP
		end

		if nFP < nRankFP and nRank > nMaxRank then
			nMaxRank = nRank;
			nMaxFP = nRankFP
		end
	end

	if nMaxRank == -1 and nHaveMaxRank == 1 then
		nMaxRank = nHaveMaxRank;
		nMaxFP = nHaveMaxRankFP;
		bFirstRank = true
	end

	return nMaxRank, nMaxFP, tbDataList[nMaxRank], bFirstRank
end

function Stronger:GetMyDataByType(nType)
	local pProcess = self.tbMyProcess[nType]
	if pProcess then
		return pProcess(nType)
	end
end

function Stronger:GetRecommendStoneByPos(nPos)
	if not me then
		return
	end

	local nLevel = me.nLevel;
	local nMaxMatchLevel = -1;
	local tbPosCfg
	for nNeedLevel, tbCfg in pairs( self.RecommendStoneType ) do
		if nNeedLevel > nMaxMatchLevel and nLevel >= nNeedLevel then
			nMaxMatchLevel = nNeedLevel;
			tbPosCfg = tbCfg[nPos]
		end
	end

	return tbPosCfg
end

function Stronger:GetPlayerFightPower()
	return self.nCurFightPower
end

function Stronger:GetFightPowerByType(nType)
	return self.detailFightPower[nType] or 0
end

function Stronger:GetPlayerJudge(nLevel, nFightPower)
	local cfg = self.RecommendFP[nLevel]
	local nRecommend = 0
	local judgeDesc = Stronger.tbMarkSprite["Cmark"]
	if not cfg then
		return judgeDesc, nRecommend
	end

	nRecommend = cfg.FightPower

	if nFightPower >= nRecommend then
		judgeDesc = Stronger.tbMarkSprite["Smark"]
	elseif nFightPower >= nRecommend*0.8 then
		judgeDesc = Stronger.tbMarkSprite["Amark"]
	elseif nFightPower >= nRecommend*0.6 then
		judgeDesc = Stronger.tbMarkSprite["Bmark"]
	end

	return judgeDesc, nRecommend
end

function Stronger:GetDetailFightPowerJudge(nType, nLevel, nFightPower)
	local nRecommend = 0
	local judgeDesc = "急需提升"

	local cfg = self.RecommendDetail[nType][nLevel]
	if not cfg then
		return judgeDesc, nRecommend
	end

	nRecommend = cfg.FightPower

	if nFightPower >= nRecommend then
		judgeDesc = "出神入化"
	elseif nFightPower >= nRecommend*0.7 then
		judgeDesc = "出类拔萃"
	elseif nFightPower >= nRecommend*0.5 then
		judgeDesc = "成绩平平"
	elseif nFightPower >= nRecommend*0.3 then
		judgeDesc = "勉勉强强"
	end

	return judgeDesc, Stronger.StateColor[judgeDesc], nRecommend
end

function Stronger:CheckVisible()
	local nTimeNow = GetTime();
	local nOpenTime = TimeFrame:CalcTimeFrameOpenTime("OpenLevel129");
	--129级上限开放后补不显示变强

	return nTimeNow < nOpenTime;
end

function Stronger:OnLeaveGame()
	self.nCurFightPower = nil
	self.detailFightPower = nil
	self.tbTotal = nil;
	self.tbModule = nil;
	self.nLastRecommendRequest = nil;
end

local function GetStrengthenDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	local tbStrengthen = me.GetStrengthen()
	for _, nEquipPos in ipairs( Stronger.tbRecommendEquipPos ) do
		local nStrenLevel = tbStrengthen[nEquipPos+1] or 0
		local nValue = 0;
		if nStrenLevel > 0 then
			nValue = Strengthen.tbStrengthenLevel[nStrenLevel]["FightPower" .. Strengthen.tbPosPrefixName[nEquipPos] ];
		end
		tbDetailAvg[nEquipPos] = tbDetailAvg[nEquipPos] or {}
		tbDetailAvg[nEquipPos].nFP = (tbDetailAvg[nEquipPos].nFP or 0) + nValue;
		tbDetailAvg[nEquipPos].nLvl = (tbDetailAvg[nEquipPos].nLvl or 0) + nStrenLevel;
	end

	return tbOtherTotalAvg, tbDetailAvg
end

local function GetStoneDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	for _, nEquipPos in ipairs( Stronger.tbRecommendEquipPos ) do
		local tbInsetInfo = me.GetInsetInfo(nEquipPos);
		local nFP = 0;
		local nLvl = 0;
		for _, nStoneTemplateId in pairs(tbInsetInfo) do
			if nStoneTemplateId and nStoneTemplateId ~= 0 then
				nFP = nFP + StoneMgr:GetStoneFightPower(nStoneTemplateId);
				nLvl = nLvl + StoneMgr:GetStoneLevel(nStoneTemplateId)
			end
		end
		tbDetailAvg[nEquipPos] = tbDetailAvg[nEquipPos] or {}
		tbDetailAvg[nEquipPos].nFP = (tbDetailAvg[nEquipPos].nFP or 0) + nFP;
		tbDetailAvg[nEquipPos].nLvl = (tbDetailAvg[nEquipPos].nLvl or 0) + nLvl;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetRefineDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};

	for _, nEquipPos in ipairs( Stronger.tbRecommendEquipPos ) do
		local pEquip = me.GetEquipByPos(nEquipPos);
		local nValue = (pEquip and pEquip.nFightPower) or 0
		tbDetailAvg[nEquipPos] = (tbDetailAvg[nEquipPos] or 0) + nValue;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetHorseDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	for _, nEquipPos in ipairs( Stronger.tbHorseEquipPos ) do
		local pEquip = me.GetEquipByPos(nEquipPos);
		local nFP = (pEquip and pEquip.nFightPower) or 0
		local nLvl = (pEquip and pEquip.nLevel) or 0
		tbDetailAvg[nEquipPos] = tbDetailAvg[nEquipPos] or {}
		tbDetailAvg[nEquipPos].nFP = (tbDetailAvg[nEquipPos].nFP or 0) + nFP;
		tbDetailAvg[nEquipPos].nLvl = (tbDetailAvg[nEquipPos].nLvl or 0) + nLvl;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetPartnerDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};

	local tbPartnerIdList = me.GetPartnerPosInfo();
	local tbPartnerInfoList = {};
	for _, nId in pairs( tbPartnerIdList ) do
		local tbInfo = me.GetPartnerInfo(nId)
		table.insert(tbPartnerInfoList, tbInfo);
	end

	--根据战力和品质排序
	table.sort(tbPartnerInfoList, function (tbA, tbB)
		if tbA.nFightPower == tbB.nFightPower then
			if tbA.nQualityLevel == tbB.nQualityLevel then
				if tbA.nLevel == tbB.nLevel then
					return tbA.nNpcTemplateId < tbB.nNpcTemplateId
				else
					return tbA.nLevel > tbB.nLevel
				end
			else
				return tbA.nQualityLevel < tbB.nQualityLevel
			end
		end

		return tbA.nFightPower > tbB.nFightPower
	end)

	for nIndex, tbPartner in ipairs( tbPartnerInfoList ) do
		if tbPartner then
			tbDetailAvg[nIndex] = tbDetailAvg[nIndex] or {}
			tbDetailAvg[nIndex].nFP = (tbDetailAvg[nIndex].nFP or 0) + tbPartner.nFightPower;
			tbDetailAvg[nIndex].nLvl = (tbDetailAvg[nIndex].nLvl or 0) + tbPartner.nQualityLevel;
		end
	end

	return tbOtherTotalAvg, tbDetailAvg
end

local function GetPartnerCardDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};

	local tbCarInfoList = PartnerCard:GetOnPosCardInfo(me)
	local tbPartnerPosFP = {};
	for nCardPos, tbCardInfo in pairs( tbCarInfoList ) do
		local nPartnerPos = PartnerCard:GetPartnerPosByCardPos(nCardPos);
		local nFP = PartnerCard:GetCardFightPowerById(tbCardInfo.nCardId, tbCardInfo.nLevel)
		tbPartnerPosFP[nPartnerPos] = (tbPartnerPosFP[nPartnerPos] or 0) + nFP
	end

	local tbPartnerPosList = {};
	for _, nFP in pairs( tbPartnerPosFP ) do
		table.insert(tbPartnerPosList, nFP)
	end

	--根据战力从高到低划分
	table.sort(tbPartnerPosList, function ( a, b )
		return a > b
	end)

	for nIdx, nFP in ipairs( tbPartnerPosList ) do
		tbDetailAvg[nIdx] = (tbDetailAvg[nIdx] or 0) + nFP;
	end

	return tbOtherTotalAvg, tbDetailAvg
end

local function GetZhenYuanDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};

	local pEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN);
	if pEquip then
		tbOtherTotalAvg.nLvl = (tbOtherTotalAvg.nLvl or 0) + pEquip.nLevel;
		tbOtherTotalAvg.nQuality = (tbOtherTotalAvg.nQuality or 0) + pEquip.nQuality;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetJingMaiDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	for nJingMaiId, _ in pairs(JingMai.tbJingMaiSetting) do

		local nFP = JingMai:GetFightPowerByAsynData(nil,nJingMaiId, me);
		local nLvl, _ = JingMai:GetJingMaiLevelData(me, nJingMaiId)
		local tbExtSkillInfo = JingMai:GetExtSkillInfoByAsynData(nil,nJingMaiId, me);
		local nQuality = 0;
		for _, tbSkillInfo in pairs( tbExtSkillInfo ) do
			nQuality = nQuality + tbSkillInfo.nLevel;
		end
		if nQuality > 0 then
			nQuality = math.ceil(nQuality/Lib:CountTB(tbExtSkillInfo));
		end
		tbDetailAvg[nJingMaiId] = tbDetailAvg[nJingMaiId] or {}
		tbDetailAvg[nJingMaiId].nFP = (tbDetailAvg[nJingMaiId].nFP or 0) + nFP;
		tbDetailAvg[nJingMaiId].nLvl = (tbDetailAvg[nJingMaiId].nLvl or 0) + nLvl;
		tbDetailAvg[nJingMaiId].nQuality = (tbDetailAvg[nJingMaiId].nQuality or 0) + nQuality;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetSkillBookDetailData()
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	local tbSkillBookList = {}
	for nEquipPos=Item.EQUIPPOS_SKILL_BOOK,Item.EQUIPPOS_SKILL_BOOK_End do
		local pEquip = me.GetEquipByPos(nEquipPos);
		table.insert(tbSkillBookList, {nFP = (pEquip and pEquip.nFightPower) or 0,
						nLvl = (pEquip and pEquip.nQuality) or 0})
	end
	table.sort(tbSkillBookList, function ( a, b )
		if a.nFP == b.nFP then
			return a.nLvl > b.nLvl;
		end
		return a.nFP > b.nFP;
	end)
	for nPos, tbInfo in ipairs( tbSkillBookList ) do
		tbDetailAvg[nPos] = tbDetailAvg[nPos] or {}
		tbDetailAvg[nPos].nFP = (tbDetailAvg[nPos].nFP or 0) + tbInfo.nFP;
		tbDetailAvg[nPos].nLvl = (tbDetailAvg[nPos].nLvl or 0) + tbInfo.nLvl;
	end
	return tbOtherTotalAvg, tbDetailAvg
end

local function GetDefaultDetailData(nType)
	if not me then
		return
	end
	local tbOtherTotalAvg = {}
	local tbDetailAvg = {};
	local nFP = Stronger:GetFightPowerByType(nType)
	return tbOtherTotalAvg, tbDetailAvg, nFP
end

Stronger.tbMyProcess =
{
	[Stronger.Type.Strengthen] = GetStrengthenDetailData;
	[Stronger.Type.Stone] = GetStoneDetailData;
	[Stronger.Type.Refine] = GetRefineDetailData;
	[Stronger.Type.Horse] = GetHorseDetailData;
	[Stronger.Type.Partner] = GetPartnerDetailData;
	[Stronger.Type.PartnerCard] = GetPartnerCardDetailData;
	[Stronger.Type.ZhenYuan] = GetZhenYuanDetailData;
	[Stronger.Type.JingMai] = GetJingMaiDetailData;
	[Stronger.Type.ZhenFa] = GetDefaultDetailData;
	[Stronger.Type.SkillBook] = GetSkillBookDetailData,
	[Stronger.Type.JueXue] = GetDefaultDetailData,
	[Stronger.Type.SkillPoint] = GetDefaultDetailData,
}


local function GetEquipLevelFPDefaultData(tbCfg, tbInfo)
	for nIdx, szSuffix in ipairs( tbEquipPartSuffix ) do
		local nEquipPos = nIdx-1;
		local szLevelKey = string.format("%s_%s", szLevelPrefix, szSuffix)
		local szFPKey = string.format("%s_%s", szFPPrefix, szSuffix)
		tbInfo.tbDetailAvg[nEquipPos] = tbInfo.tbDetailAvg[nEquipPos] or {}
		tbInfo.tbDetailAvg[nEquipPos].nFP = tbCfg[szFPKey] or 0;
		tbInfo.tbDetailAvg[nEquipPos].nLvl = tbCfg[szLevelKey] or 0;
	end
end

local function GetEquipFPDefaultData(tbCfg, tbInfo)
	for nIdx, szSuffix in ipairs( tbEquipPartSuffix ) do
		local nEquipPos = nIdx-1;
		local szFPKey = string.format("%s_%s", szFPPrefix, szSuffix)
		tbInfo.tbDetailAvg[nEquipPos] = tbCfg[szFPKey] or 0;
	end
end

local function GetHorseLevelFPDefaultData(tbCfg, tbInfo)
	for nIdx, szSuffix in ipairs( tbHorsePartSuffix ) do
		local nEquipPos = Stronger.tbHorseEquipPos[nIdx];
		local szLevelKey = string.format("%s_%s", szLevelPrefix, szSuffix)
		local szFPKey = string.format("%s_%s", szFPPrefix, szSuffix)
		tbInfo.tbDetailAvg[nEquipPos] = tbInfo.tbDetailAvg[nEquipPos] or {}
		tbInfo.tbDetailAvg[nEquipPos].nFP = tbCfg[szFPKey] or 0;
		tbInfo.tbDetailAvg[nEquipPos].nLvl = tbCfg[szLevelKey] or 0;
	end
end

local function GetZhenYuanDefaultData(tbCfg, tbInfo)
	tbInfo.tbOtherTotalAvg.nLvl = tbCfg[szLevelPrefix] or 0;
	tbInfo.tbOtherTotalAvg.nQuality = tbCfg[szQualityPrefix] or 0;
end

local function GetNormalLevelFPDefaultData(tbCfg, tbInfo)
	for nIdx, szSuffix in ipairs( tbNormalPartSuffix ) do
		local szLevelKey = string.format("%s_%s", szLevelPrefix, szSuffix)
		local szFPKey = string.format("%s_%s", szFPPrefix, szSuffix)
		tbInfo.tbDetailAvg[nIdx] = tbInfo.tbDetailAvg[nIdx] or {}
		tbInfo.tbDetailAvg[nIdx].nFP = tbCfg[szFPKey] or 0;
		tbInfo.tbDetailAvg[nIdx].nLvl = tbCfg[szLevelKey] or 0;
	end
end

local function GetGetNormalLevelQualityFPDefaultData(tbCfg, tbInfo)
	for nIdx, szSuffix in ipairs( tbNormalPartSuffix ) do
		local szLevelKey = string.format("%s_%s", szLevelPrefix, szSuffix)
		local szQualityKey = string.format("%s_%s", szQualityPrefix, szSuffix)
		local szFPKey = string.format("%s_%s", szFPPrefix, szSuffix)
		tbInfo.tbDetailAvg[nIdx] = tbInfo.tbDetailAvg[nIdx] or {}
		tbInfo.tbDetailAvg[nIdx].nFP = tbCfg[szFPKey] or 0;
		tbInfo.tbDetailAvg[nIdx].nLvl = tbCfg[szLevelKey] or 0;
		tbInfo.tbDetailAvg[nIdx].nQuality = tbCfg[szQualityKey] or 0;
	end
end

local function GetDefaultData(tbCfg, tbInfo)
end

Stronger.tbDefaultProcess =
{
	[Stronger.Type.Strengthen] = GetEquipLevelFPDefaultData;
	[Stronger.Type.Stone] = GetEquipLevelFPDefaultData;
	[Stronger.Type.Refine] = GetEquipFPDefaultData;
	[Stronger.Type.Horse] = GetHorseLevelFPDefaultData;
	[Stronger.Type.Partner] = GetNormalLevelFPDefaultData;
	[Stronger.Type.PartnerCard] = GetNormalLevelFPDefaultData;
	[Stronger.Type.ZhenYuan] = GetZhenYuanDefaultData;
	[Stronger.Type.JingMai] = GetGetNormalLevelQualityFPDefaultData;
	[Stronger.Type.ZhenFa] = GetDefaultData;
	[Stronger.Type.SkillBook] = GetNormalLevelFPDefaultData,
	[Stronger.Type.JueXue] = GetDefaultData,
	[Stronger.Type.SkillPoint] = GetDefaultData,
}

Stronger:Init()
