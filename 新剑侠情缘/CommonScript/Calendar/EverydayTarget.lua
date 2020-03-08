EverydayTarget.Def =
{
	SAVE_GROUP_DAY_AWARD = 80;
	-- SAVE_KEY_DAY_AWARD   = 1;
	LOGIN_TIME           = 2; 	--登录时LocalDay
	LOGIN_LEVEL          = 3; 	--登录时的等级
	GAIN_AWARD_INFO      = 4; 	--奖励领取信息
	MAX_ACTIVE_DAY_NUM   = 5; 	--满活跃的天数，成就相关
	LAST_MAX_ACTIVE_TIME = 6; 	--上次满活跃的时间，成就相关
	ACTIVE_COUNT_BEGIN   = 7; 	--具体活动活跃值记录的开始字段	
	
	REFRESH_CLOCK        = 4*3600; --每日4:00刷新
	OPEN_LEVEL           = 20; 	--开启每日奖励的等级

	SAVE_GROUP_EXT_ACT = 66;
	EXT_ACT_KEY = 51;

	--刻度-活跃值
	tbActiveScale = 
	{
		[1] = 20,
		[2] = 40,
		[3] = 60,
		[4] = 80,
		[5] = 100,
	};
	
	--22 随机银两；23 随机水晶；24藏宝图；25黄金宝箱；26元宝
	tbActiveExtraAward = { 22, 24, 23, 25, 26 };

	KIN_FOUND = 400
}

function EverydayTarget:Init()
	self.tbEverydaySetting = {};
	self.tbRewardSetting   = {};

	local tbEverydaySetting = LoadTabFile("Setting/Calendar/EverydayTarget.tab", "sdsss", nil, {"StringKey", "SaveKey", "Name", "Func", "Param"})
	assert(tbEverydaySetting, "[EverydayTarget Init] LoadTabFile Fail")

	for _, tbInfo in ipairs(tbEverydaySetting) do
		assert(not self.tbEverydaySetting[tbInfo.StringKey], "[EverydayTarget Init] Key Repeat")
		local tbSetting = { szName = tbInfo.Name, nSaveKey = tbInfo.SaveKey, szTrack = tbInfo.Func}
		tbSetting.tbParam = Lib:IsEmptyStr(tbInfo.Param) and {} or Lib:SplitStr(tbInfo.Param, "|")
		self.tbEverydaySetting[tbInfo.StringKey] = tbSetting
	end

	local tbRewardSetting = LoadTabFile(
        "Setting/Calendar/EverydayReward.tab", 
        "ddsdd", nil,
        {"MinLevel", "Scale", "RewardType", "RewardTemplateId", "RewardCount"});

	local tb1 = {};
	for k,v in pairs(tbRewardSetting) do
		tb1[v.MinLevel] = tb1[v.MinLevel] or {};
		tb1[v.MinLevel].nLevelMin = v.MinLevel;
		tb1[v.MinLevel].tbReward = tb1[v.MinLevel].tbReward or {};
		if v.RewardTemplateId ~= 0 then
			tb1[v.MinLevel].tbReward[v.Scale] = { v.RewardType, v.RewardTemplateId, v.RewardCount };
		else
			tb1[v.MinLevel].tbReward[v.Scale] = { v.RewardType, v.RewardCount };
		end
	end

	local tb2 = {}
	for k,v in pairs(tb1) do
		table.insert(tb2, v);
	end

	table.sort(tb2, function (item1, item2)
		return item1.nLevelMin < item2.nLevelMin;
	end)

	self.tbRewardSetting = tb2;

	self.tbActiveSetting = {}
	local tbKey  = {}
	for i = 1, 5 do
		tbKey["LevelMin" .. i], tbKey["LevelMax" .. i], tbKey["Times" .. i], tbKey["Count" .. i] = 1, 1, 1, 1;
	end
	local tbTemp = Lib:LoadTabFile( "Setting/Calendar/EverydayAward.tab", tbKey);
	for _, tbInfo  in pairs(tbTemp) do
		self.tbActiveSetting[tbInfo.StringKey] = tbInfo
	end
end

EverydayTarget:Init()

function EverydayTarget:GetActiveAward(pPlayer, nAwardIdx)
	local nLen   = #self.tbRewardSetting
	local nLevel = self:GetTodayLevel(pPlayer)
	if nLevel < self.Def.OPEN_LEVEL then
		return
	end

	for i = 1, nLen do
		local tbLevelReward = self.tbRewardSetting[i];
		if nLevel >= tbLevelReward.nLevelMin then
			if i == nLen or nLevel < self.tbRewardSetting[i + 1].nLevelMin then
				return tbLevelReward.tbReward[nAwardIdx];
			end
		end
	end
end

function EverydayTarget:GetTodayLevel(pPlayer)
	local nLoginLevel = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LOGIN_LEVEL)
	if pPlayer.nLevel < self.Def.OPEN_LEVEL then
		return nLoginLevel
	end

	if nLoginLevel < self.Def.OPEN_LEVEL then
		return self.Def.OPEN_LEVEL
	end

	return nLoginLevel
end

function EverydayTarget:GetCountAndValue(nLevel, szKey)
	local tbSet = self.tbActiveSetting[szKey]
	if not tbSet then
		return 0, 0
	end

	for i = 1, 999 do
		local szLevelMin = string.format("LevelMin%d", i)
		local szLevelMax = string.format("LevelMax%d", i)
		if not tbSet[szLevelMin] or not tbSet[szLevelMax] then
			break
		end

		if nLevel >= tbSet[szLevelMin] and nLevel <= tbSet[szLevelMax] then
			return tbSet["Times" .. i], tbSet["Count" .. i]
		end
	end

	return 0, 0
end

function EverydayTarget:GetTargetCurActive(pPlayer, szKey)
	local nTodayLevel    = self:GetTodayLevel(pPlayer)
	local nSaveKey       = self:GetTargetSaveKey(szKey)
	if nTodayLevel < self.Def.OPEN_LEVEL or not nSaveKey then
		return 0, 0, 0
	end

	local nCount         = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, nSaveKey)
	local nTimes, nValue = self:GetCountAndValue(nTodayLevel, szKey)

	local nTargetValue = 0
	if nCount >= nTimes then
		return nCount, nTimes, nValue
	end

	return nCount, nTimes, 0
end

function EverydayTarget:GetTargetSaveKey(szKey)
	local tbSet = self.tbEverydaySetting[szKey]
	if not tbSet then
		return
	end

	return tbSet.nSaveKey + self.Def.ACTIVE_COUNT_BEGIN - 1
end

function EverydayTarget:GetAllTargetSaveKey()
	local tbSaveKey = {}
	for szKey, tbInfo in pairs(self.tbEverydaySetting) do
		local nSaveKey = self:GetTargetSaveKey(szKey)
		table.insert(tbSaveKey, nSaveKey)
	end
	return tbSaveKey
end

function EverydayTarget:GetTotalActiveValue(pPlayer)
	local nTotal = 0
	for szKey, _ in pairs(self.tbEverydaySetting) do
		local _1, _2, nTargetValue = self:GetTargetCurActive(pPlayer, szKey)
		nTotal = nTotal + nTargetValue
	end

	local nActValue = pPlayer.GetUserValue(self.Def.SAVE_GROUP_EXT_ACT, self.Def.EXT_ACT_KEY)
	nTotal = nTotal + nActValue
	return math.min(nTotal, 100)
end

function EverydayTarget:CheckGainAward(pPlayer, nAwardIdx)
	local nActiveValue = self.Def.tbActiveScale[nAwardIdx]
	if not nActiveValue then
		Log("[EverydayTarget CheckGainAward] Get Index Error", nAwardIdx)
		return
	end

	local nGainInfo = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.GAIN_AWARD_INFO)
	nGainInfo = KLib.GetBit(nGainInfo, nAwardIdx)
	if nGainInfo == 1 then
		return false, "领取失败，已领过奖励"
	end

	local nTotalActive = self:GetTotalActiveValue(pPlayer)
	if nTotalActive < nActiveValue then
		return false, "活跃度不足，无法领取奖励"
	end

	return true
end

function EverydayTarget:SendRandomAward(nAwardIdx)
	local nItemID = self.Def.tbActiveExtraAward[nAwardIdx]
	if not nItemID then
		return
	end

	me.ItemLogWay = Env.LogWay_EverydayTargetAward;
	local nRet, szMsg, tbAllAward = Item:GetClass("RandomItemByLevel"):GetAwardByLevel(me, nItemID, "每日目标")
	me.ItemLogWay = nil;
	if nRet ~= 1 then
		Log("[EverydayTarget SendRandomAward Fail] >>>>", me.dwID, me.szName, szMsg)
	end
end

function EverydayTarget:IsHadAward(pPlayer)
    for nIdx, _ in ipairs(self.Def.tbActiveScale) do
        if self:CheckGainAward(pPlayer, nIdx) then
            return true
        end
    end
end

function EverydayTarget:CheckNewDay(pPlayer)
	local nLoginDay = pPlayer.GetUserValue(self.Def.SAVE_GROUP_DAY_AWARD, self.Def.LOGIN_TIME)
	local nLocalDay = Lib:GetLocalDay(GetTime() - self.Def.REFRESH_CLOCK)
	return nLoginDay ~= nLocalDay
end