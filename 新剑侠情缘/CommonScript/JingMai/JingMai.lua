
-- 在异步数据中存储的位置，不能改
local XUEWEI_BEGINE_SAVE_ID = 154;

-- 当前最大支持穴位数量，如果要扩充需要考虑存储 SAVE_GROUP_LIST 和 SAVE_GROUP_FAIL_COUNT_LIST 都要扩充
local MAX_XUEWEI_ID = 500;

-- 最大穴位等级，没法扩充了
local MAX_XUEWEI_LEVEL = 127;

-- 穴位等级存储在 UserValue 的位置，顺序很重要不要动
local SAVE_GROUP_LIST = {140};

-- 每个穴位失败次数的数据，顺序也很重要，别动
local SAVE_GROUP_FAIL_COUNT_LIST = {141};

JingMai.SAVE_GROUP_ID = 142;
JingMai.SAVE_INDEX_ID = 1;
JingMai.SAVE_INDEX_OPEN_DATE = 2;
JingMai.SAVE_INDEX_DATE = 3;
JingMai.SAVE_XUEWEI_LEVELUP_COUNT = 4;
JingMai.SAVE_XUEWEI_EXT_COUNT = 5;

JingMai.MAX_RATE = 1000000;

JingMai.nJingMaiLevelUpTime = 1 * 24 * 60 * 60
local MAX_JINGMAN_LEVEL_COUNT = 50 								-- 最前一个组最多255/5 ~= 50个,当前最大支持穴位数量，如果要扩充需要考虑存储ALL_JINGMAI_LEVEL_SAVE_GROUP_LIST
local ALL_JINGMAI_LEVEL_SAVE_GROUP_LIST = {153}; 				-- 经脉所有穴位达到一定等级后存储在 UserValue 的位置，顺序很重要不要动 每条经脉预留5个位置
local ALL_JINGMAI_LEVEL_INDEX_STEP = 1; 						-- 目前级别(全部穴位达到5级记录为1，全部等级达到10级记录为2,...)
local ALL_JINGMAI_LEVEL_TIME_STEP = 2; 							-- 请求升级的时间（0未请求）
local ALL_JINGMAI_LEVEL_MAX_STEP = 5; 							-- 预留最大的索引

local JINGMAI_LEVEL_BEGINE_SAVE_ID = 3157 						-- 在异步数据中存储的开始位置，不能改
local JINGMAI_LEVEL_END_SAVE_ID = 4158 							-- 在异步数据中存储的结束位置，不能改
----------------------------------------------------------  下面的策划配置
-- 经脉最低开启玩家等级
JingMai.nOpenLevel = 70;

-- 经脉最低开启时间轴
JingMai.szOpenTimeFrame = "OpenLevel79";

-- 使用一个资质丹给与真气数量
JingMai.nUseItemProtentialZhenQiValue = 125;

-- 开放经脉系统时，返还已经使用资质丹所得真气
-- 每使用一个资质丹给的数量
JingMai.nOpenJingMaiAwardRate = 100;

-- 重置穴位真气返还比率
JingMai.nResetZhenQiRate = 1;

-- 玩家开启经脉任务ID
JingMai.nOpenTaskId = 3206;

-- 每日穴位升级次数（成功才算次数）
JingMai.nMaxLevelupTimes = 300;

JingMai.tbUseProtntialItemRandom = {
	{200, 8},
	{400, 4},
	{1000, 1.6},
	{4600, 0.8},
	{3800, 0.4},
};

JingMai.bOpenResetJingMai = false 				-- 是否开放重置经脉
JingMai.bOpenResetXueWei = false 				-- 是否开放重置穴位
for i, tbInfo in ipairs(JingMai.tbUseProtntialItemRandom) do
	tbInfo[1] = tbInfo[1] + (JingMai.tbUseProtntialItemRandom[i - 1] or {0})[1];
end

JingMai.szJingMaiLevelTimeDes = "周天运转中，%s后可激活" 					-- 经脉升级中倒计时文本描述
JingMai.nJingMaiPreNum = 11 							-- 用来提示用的前n个

function JingMai:LoadSetting()
	self.tbXueWeiLevelupInfo = {};
	local tbFile = LoadTabFile("Setting/JingMai/XueWeiLevelup.tab", "dddsss", nil, {"TypeId", "Level", "Rate", "Cost1", "Cost2", "Cost3"});
	for _, tbRow in pairs(tbFile) do
		self.tbXueWeiLevelupInfo = self.tbXueWeiLevelupInfo or {};
		self.tbXueWeiLevelupInfo[tbRow.TypeId] = self.tbXueWeiLevelupInfo[tbRow.TypeId] or {};
		self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel = math.max(self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel or 0, tbRow.Level);

		assert(not self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level]);
		assert(self.tbXueWeiLevelupInfo[tbRow.TypeId].nMaxLevel < MAX_XUEWEI_LEVEL);

		self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level] = {
			nRate = tbRow.Rate;
			tbCost = {};
		}

		for i = 1, 3 do
			local tbCost = Lib:SplitStr(tbRow["Cost" .. i], "|");
			if tbCost and #tbCost > 1 then
				local nCostType = Player.AwardType[tbCost[1]];
				assert(nCostType and (nCostType == Player.award_type_item or nCostType == Player.award_type_money));

				for j = 2, #tbCost do
					tbCost[j] = tonumber(tbCost[j]);
					assert(tbCost[j] and tbCost[j] > 0);
				end

				table.insert(self.tbXueWeiLevelupInfo[tbRow.TypeId][tbRow.Level].tbCost, tbCost);
			end
		end
	end

	self.tbJingMaiSetting = {};
	tbFile = LoadTabFile("Setting/JingMai/JingMaiSetting.tab", "dssdsdd", nil, {"Id", "Name", "OpenTimeFrame", "MinOpenDay", "LevelName", "LevelIcon", "LevelNormalIcon"});
	for _, tbRow in ipairs(tbFile) do
		assert(not self.tbJingMaiSetting[tbRow.Id]);

		self.tbJingMaiSetting[tbRow.Id] = {
			szName = tbRow.Name;
			szOpenTimeFrame = tbRow.OpenTimeFrame;
			nMinOpenDay = tbRow.MinOpenDay;
			tbXueWei = {};
			szLevelName = tbRow.LevelName;
			nMaxLevel = 0;
			nLevelIcon = tbRow.LevelIcon;
			nLevelNormalIcon = tbRow.LevelNormalIcon;
			tbNoJoinJingMaiLevel = {};
		}
	end

	self.tbXueWeiBeenRequired = {};
	self.tbAllAttrib = {};
	self.tbAllPartnerAttrib = {};
	self.tbAllSkill = {};
	self.tbXueWeiSetting = {};
	local tbTitle = {"Id", "Name", "TypeId", "JingMaiId", "LevelupType", "NoJoinJingMaiLevel","ExtSkillId", "ExtPartnerSkillId", "ExtAttribId", "ExtAttribMaxLevel", "ExtPartnerAttribId",
					"ExtPartnerAttribMaxLevel", "Require_XueWei1", "Require_XueWei2", "Require_XueWei3", "Require_Level", "Cost1", "Cost2", "Cost3"};
	local szType = "dsddddddddddsssssss";
	tbFile = LoadTabFile("Setting/JingMai/XueWeiSetting.tab", szType, nil, tbTitle);
	for _, tbRow in ipairs(tbFile) do
		assert(self.tbXueWeiLevelupInfo[tbRow.LevelupType]);
		assert(not self.tbXueWeiSetting[tbRow.Id]);
		assert(self.tbJingMaiSetting[tbRow.JingMaiId]);
		assert(tbRow.Id <= MAX_XUEWEI_ID);

		table.insert(self.tbJingMaiSetting[tbRow.JingMaiId].tbXueWei, tbRow.Id);
		if tbRow.NoJoinJingMaiLevel == 1 then
			self.tbJingMaiSetting[tbRow.JingMaiId].tbNoJoinJingMaiLevel[tbRow.Id] = true
		end
		local tbXueWeiInfo = {
			nId = tbRow.Id;
			szName = tbRow.Name;
			nType = tbRow.TypeId;
			nJingMaiId = tbRow.JingMaiId;
			nLevelupType = tbRow.LevelupType;
			nMaxLevel = self.tbXueWeiLevelupInfo[tbRow.LevelupType].nMaxLevel + 1;
			nExtAttribId = tbRow.ExtAttribId;
			nExtSkillId = tbRow.ExtSkillId;
			nExtPartnerSkillId = tbRow.ExtPartnerSkillId;
			nExtAttribMaxLevel = tbRow.ExtAttribMaxLevel;
			nExtPartnerAttribId = tbRow.ExtPartnerAttribId;
			nExtPartnerAttribMaxLevel = tbRow.ExtPartnerAttribMaxLevel;
			tbRequireLevel = {};
			tbRequireXueWei = {};
			tbCost = {};
			tbCostZhenQi = {};
			tbFightPower = {};
		};

		if tbRow.ExtAttribId and tbRow.ExtAttribId > 0 then
			assert(not self.tbAllAttrib[tbRow.ExtAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtAttribId = %s", tbRow.Id, tbRow.ExtAttribId));
			self.tbAllAttrib[tbRow.ExtAttribId] = true;
		end

		if tbRow.ExtPartnerAttribId and tbRow.ExtPartnerAttribId > 0 then
			assert(not self.tbAllPartnerAttrib[tbRow.ExtPartnerAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtPartnerAttribId = %s", tbRow.Id, tbRow.ExtPartnerAttribId));
			self.tbAllPartnerAttrib[tbRow.ExtPartnerAttribId] = true;
		end

		if tbRow.ExtSkillId and tbRow.ExtSkillId > 0 then
			self.tbAllSkill[tbRow.ExtSkillId] = true;
		end

		for i = 1, 3 do
			local tbCost = Lib:SplitStr(tbRow["Cost" .. i], "|");
			if tbCost and #tbCost > 1 then
				local nCostType = Player.AwardType[tbCost[1]];
				assert(nCostType and (nCostType == Player.award_type_item or nCostType == Player.award_type_money));

				for j = 2, #tbCost do
					tbCost[j] = tonumber(tbCost[j]);
					assert(tbCost[j] and tbCost[j] > 0);
				end

				if tbCost[1] == "ZhenQi" then
					tbXueWeiInfo.tbCostZhenQi[1] = tbXueWeiInfo.tbCostZhenQi[1] or 0;
					tbXueWeiInfo.tbCostZhenQi[1] = tbXueWeiInfo.tbCostZhenQi[1] + tbCost[2];
				end

				table.insert(tbXueWeiInfo.tbCost, tbCost);
			end
		end

		tbXueWeiInfo.tbFightPower[1] = math.floor(0.5 * tbXueWeiInfo.tbCostZhenQi[1] / 10);

		for i = 1, self.tbXueWeiLevelupInfo[tbRow.LevelupType].nMaxLevel do
			local tbCost = self.tbXueWeiLevelupInfo[tbRow.LevelupType][i].tbCost;
			local nZhenQiCost = 0;
			for _, tbInfo in pairs(tbCost) do
				if tbInfo[1] == "ZhenQi" then
					nZhenQiCost = nZhenQiCost + tbInfo[2];
				end
			end

			tbXueWeiInfo.tbCostZhenQi[i + 1] = nZhenQiCost + tbXueWeiInfo.tbCostZhenQi[i];

			local nRate = self.tbXueWeiLevelupInfo[tbRow.LevelupType][i].nRate / self.MAX_RATE;
			local nFightPower = math.floor((0.5 * nZhenQiCost / 10) / nRate);

			tbXueWeiInfo.tbFightPower[i + 1] = nFightPower + tbXueWeiInfo.tbFightPower[i];
		end

		for i = 1, 3 do
			local nXueWeiId, nLevel = string.match(tbRow["Require_XueWei" .. i] or "", "^(%d+)|(%d+)$");
			if nXueWeiId then
				nXueWeiId = tonumber(nXueWeiId);
				nLevel = tonumber(nLevel);
				table.insert(tbXueWeiInfo.tbRequireXueWei, {nXueWeiId, nLevel});
				self.tbXueWeiBeenRequired[nXueWeiId] = self.tbXueWeiBeenRequired[nXueWeiId] or {};
				table.insert(self.tbXueWeiBeenRequired[nXueWeiId], tbRow.Id)
			end
		end

		local tbRL = Lib:SplitStr(tbRow.Require_Level, ";");
		local tbPoint = {};
		for _, szInfo in ipairs(tbRL) do
			local nX, nY = string.match(szInfo, "^(%d+)|(%d+)$");
			if nX then
				table.insert(tbPoint, {tonumber(nX), tonumber(nY)});
			end
		end

		if #tbPoint <= 0 then
			tbPoint = {{0, 0}, {10, 0}};
		end

		for i = 1, tbXueWeiInfo.nMaxLevel do
			tbXueWeiInfo.tbRequireLevel[i] = Lib.Calc:Link(i, tbPoint);
		end

		self.tbXueWeiSetting[tbRow.Id] = tbXueWeiInfo;
	end

	self.tbXueWeiLevelAttrib = {} 
	local tbParams = {"JingMaiId", "Level", "ExtAttribId", "ExtAttribLevel", "ExtPartnerAttribId", "ExtPartnerAttribLevel", "szCost"};
	tbFile = LoadTabFile("Setting/JingMai/XueWeiLevelExternAttrib.tab", "dddddds", nil, tbParams);
	for _, v in ipairs(tbFile) do
		assert(self.tbJingMaiSetting[v.JingMaiId], "XueWei Level Attrib assert fail" ..v.JingMaiId)
		self.tbXueWeiLevelAttrib[v.JingMaiId] = self.tbXueWeiLevelAttrib[v.JingMaiId] or {}
		local tbAttribInfo = {}
		local nExtAttribId = tonumber(v.ExtAttribId or 0)
		if nExtAttribId > 0 then
			--assert(not self.tbAllAttrib[nExtAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtAttribId = %s", v.JingMaiId, v.ExtAttribId));
			self.tbAllAttrib[nExtAttribId] = true;
			tbAttribInfo.nExtAttribId = nExtAttribId
		end
		local nExtAttribLevel = tonumber(v.ExtAttribLevel)
		tbAttribInfo.nExtAttribLevel = nExtAttribLevel > 0 and nExtAttribLevel or 1
		local nExtPartnerAttribId = tonumber(v.ExtPartnerAttribId or 0)
		if nExtPartnerAttribId > 0 then
			--assert(not self.tbAllPartnerAttrib[nExtPartnerAttribId], string.format("[JingMai] Attribute Id Repeat !! nXueWeiId = %s, ExtPartnerAttribId = %s", v.JingMaiId, nExtPartnerAttribId));
			tbAttribInfo.nExtPartnerAttribId = nExtPartnerAttribId
		end
		local nExtPartnerAttribLevel = tonumber(v.ExtPartnerAttribLevel)
		tbAttribInfo.nExtPartnerAttribLevel = nExtPartnerAttribLevel > 0 and nExtPartnerAttribLevel or 1

		local tbCost = Lib:GetAwardFromString(v.szCost);
		if next(tbCost) then
			tbAttribInfo.tbCost = tbCost
		end
		if next(tbAttribInfo) then
			tbAttribInfo.nLevel = v.Level

			table.insert(self.tbXueWeiLevelAttrib[v.JingMaiId], tbAttribInfo)
			table.sort(self.tbXueWeiLevelAttrib[v.JingMaiId], function (a,b) return a.nLevel < b.nLevel end)
		end
	end
	assert(Lib:CountTB(self.tbJingMaiSetting) < #ALL_JINGMAI_LEVEL_SAVE_GROUP_LIST * math.floor(255 / ALL_JINGMAI_LEVEL_MAX_STEP), string.format("JingMai Level assert fail %s %s", Lib:CountTB(self.tbJingMaiSetting), #ALL_JINGMAI_LEVEL_SAVE_GROUP_LIST))
end

JingMai:LoadSetting();

function JingMai:GetJingMaiLevelName(nJingMaiId)
	return self.tbJingMaiSetting[nJingMaiId] and self.tbJingMaiSetting[nJingMaiId].szLevelName or ""
end

function JingMai:GetMaxJingMaiLevel(nJingMaiId)
	return JingMai.tbXueWeiLevelAttrib[nJingMaiId] and #JingMai.tbXueWeiLevelAttrib[nJingMaiId] or 0
end

function JingMai:GetJingMaiLevelCost(nJingMaiId, nLevelIndex)
	local tbCost
	if self.tbXueWeiLevelAttrib[nJingMaiId] and self.tbXueWeiLevelAttrib[nJingMaiId][nLevelIndex] then
		tbCost = self.tbXueWeiLevelAttrib[nJingMaiId][nLevelIndex].tbCost
	end
	return tbCost or {}
end

function JingMai:GetJingMaiRequireLevel(nJingMaiId, nLevelIndex)
	local nLevel
	if self.tbXueWeiLevelAttrib[nJingMaiId] and self.tbXueWeiLevelAttrib[nJingMaiId][nLevelIndex] then
		nLevel = self.tbXueWeiLevelAttrib[nJingMaiId][nLevelIndex].nLevel
	end
	return nLevel
end

function JingMai:CheckJingMaiLevelCanActivation(pPlayer, nJingMaiId)
	local nLevelIndex, nRequestLevelTime = JingMai:GetJingMaiLevelData(pPlayer, nJingMaiId)
	if nRequestLevelTime and nRequestLevelTime ~= 0 and GetTime() >= nRequestLevelTime + self.nJingMaiLevelUpTime then
		return true
	end
	return false
end

function JingMai:OnServerStart()
	local tbJingMaiScriptData = ScriptData:GetValue("JingMai");
	if not tbJingMaiScriptData.bInit then
		local nFirstJingMai = self:GetNextOpenJingMai();
		local nSecondJingMai = self:GetNextOpenJingMai(nFirstJingMai);
		if self:CheckJingMaiOpen(nFirstJingMai) and self:CheckJingMaiOpen(nSecondJingMai) then
			tbJingMaiScriptData.tbOpenInfo = {};
			tbJingMaiScriptData.tbOpenInfo.nNextOpenJingMaiId = nSecondJingMai;
			tbJingMaiScriptData.tbOpenInfo.nOpenTime = GetTime() + self.tbJingMaiSetting[nSecondJingMai].nMinOpenDay * 24 * 3600;
		end

		tbJingMaiScriptData.bInit = true;
		ScriptData:SaveAtOnce("JingMai", tbJingMaiScriptData);
	end
	self.tbOpenInfo = tbJingMaiScriptData.tbOpenInfo;
end

function JingMai:UpdatePlayerAttrib(pPlayer)
	if MODULE_GAMECLIENT then
		pPlayer = me;
	end

	for nAttribGroup in pairs(self.tbAllAttrib) do
		pPlayer.RemoveExternAttrib(nAttribGroup);
	end

	if MODULE_GAMESERVER then
		for nSkillId in pairs(self.tbAllSkill) do
			pPlayer.RemoveSkillState(nSkillId);
		end
	end

	local tbXueWeiLearnedInfo, _, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(pPlayer);
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtSkillId > 0 or tbXueWei.nExtAttribId > 0 then
			if tbXueWei.nExtSkillId > 0 and MODULE_GAMESERVER then
				pPlayer.AddSkillState(tbXueWei.nExtSkillId, nLevel, 3, 10000000, 1);
			end

			if tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pPlayer.ApplyExternAttrib(tbXueWei.nExtAttribId, nAttribLevel);
			end
		end
	end

	self:UpdateXueWeiLevelAttrib(pPlayer, tbXueWeiLearnedInfo, false, tbJingMaiLevelInfo)

	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("JingMai:UpdatePlayerAttrib");
	end
end

function JingMai:GetFightPowerByAsynData(pPlayerAsync, nJingMaiId, pPlayer)
	local tbLearnInfo = self:GetLearnedXueWeiInfo(pPlayer, pPlayerAsync);
	local nFightPower = 0;
	for nXueWeiId, nLevel in pairs(tbLearnInfo) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		local bActive = true
		if nJingMaiId then
			bActive = nJingMaiId == tbXueWei.nJingMaiId
		end
		if bActive then
			nFightPower = nFightPower + tbXueWei.tbFightPower[nLevel];
		end
	end

	return nFightPower;
end

function JingMai:GetFightPower(pPlayer)
	local bHasPartnerInPos = false;
	local tbPosInfo = pPlayer.GetPartnerPosInfo();
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		if tbPosInfo[i] > 0 then
			bHasPartnerInPos = true;
			break;
		end
	end
	if not bHasPartnerInPos then
		return 0;
	end

	local tbLearnInfo = self:GetLearnedXueWeiInfo(pPlayer);
	local nFightPower = 0;
	for nXueWeiId, nLevel in pairs(tbLearnInfo) do
	    if nXueWeiId and nLevel and self.tbXueWeiSetting[nXueWeiId] and self.tbXueWeiSetting[nXueWeiId].tbFightPower and self.tbXueWeiSetting[nXueWeiId].tbFightPower[nLevel] then
		    nFightPower = nFightPower + self.tbXueWeiSetting[nXueWeiId].tbFightPower[nLevel];
		else
		    Log("EEEEEEEEEE[JingMai:GetFightPower,some null]", nXueWeiId, nLevel);
		end
	end

	return nFightPower;
end

function JingMai:GetLearnedXueWeiInfo(pPlayer, pPlayerAsync, bIgnorePartnerCheck)
	local bHasPartnerInPos = false;
	if pPlayerAsync then
		for i = 1, Partner.MAX_PARTNER_POS_COUNT do
			local nPartnerTemplateId = pPlayerAsync.GetPartnerInfo(i);
			if nPartnerTemplateId then
				bHasPartnerInPos = true;
				break;
			end
		end
	end

	if pPlayer then
		local tbPosInfo = pPlayer.GetPartnerPosInfo();
		for i = 1, Partner.MAX_PARTNER_POS_COUNT do
			if tbPosInfo[i] > 0 then
				bHasPartnerInPos = true;
				break;
			end
		end
	end

	-- 跨服状态忽略同伴检查
	if MODULE_ZONESERVER or bIgnorePartnerCheck then
		bHasPartnerInPos = true;
	end
	if not bHasPartnerInPos then
		return {}, true, {};
	end

	local tbXueWeiLearnedInfo = {};
	local tbJingMaiLevelInfo = {}
	for nJingMaiId, tbJingMai in pairs(self.tbJingMaiSetting) do
		if MODULE_ZONESERVER or TimeFrame:GetTimeFrameState(tbJingMai.szOpenTimeFrame) == 1 then

			for _, nXueWeiId in pairs(tbJingMai.tbXueWei) do
				local nLevel = 0;
				local nLevelIndex, nRequestLevelTime = 0, 0
				if pPlayer then
					nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId)
					nLevelIndex, nRequestLevelTime = self:GetJingMaiLevelData(pPlayer, nJingMaiId)
				else
					nLevel = self:GetXueWeiLevelByAsyncData(pPlayerAsync, nXueWeiId);
					nLevelIndex, nRequestLevelTime = self:GetJingMaiLevelDataByAsyncData(pPlayerAsync, nJingMaiId)
				end

				if nLevel > 0 then
					tbXueWeiLearnedInfo[nXueWeiId] = nLevel;
				end
				tbJingMaiLevelInfo[nJingMaiId] = {nLevelIndex = nLevelIndex, nRequestLevelTime = nRequestLevelTime}
			end
		end
	end
	return tbXueWeiLearnedInfo, false, tbJingMaiLevelInfo;
end

function JingMai:GetNextOpenJingMai(nJingMaiId)
	nJingMaiId = nJingMaiId or 0;

	if self.tbNextOpenJingMaiInfo then
		return self.tbNextOpenJingMaiInfo[nJingMaiId];
	end

	self.tbNextOpenJingMaiInfo = {};

	local tbAllJingMaiOpenTime = {};
	for nJingMaiId, tbJingMai in pairs(self.tbJingMaiSetting) do
		table.insert(tbAllJingMaiOpenTime, {nJingMaiId, TimeFrame:CalcTimeFrameOpenTime(tbJingMai.szOpenTimeFrame)});
	end

	table.sort(tbAllJingMaiOpenTime, function (a, b) return a[2] < b[2]; end)

	self.tbNextOpenJingMaiInfo[0] = tbAllJingMaiOpenTime[1][1];
	for i, tbInfo in ipairs(tbAllJingMaiOpenTime) do
		self.tbNextOpenJingMaiInfo[tbInfo[1]] = (tbAllJingMaiOpenTime[i + 1] or {})[1];
	end

	return self.tbNextOpenJingMaiInfo[nJingMaiId];
end

function JingMai:CombineAddInfo(...)
	local tbResult = {tbSkill = {}; tbPartnerSkill = {}; tbExtAttrib = {}; tbExtPartnerAttrib = {};};
	local tbAdd = {...}
	for _, v in pairs(tbAdd) do
		Lib:MergeTable(tbResult.tbSkill, (v.tbSkill or {}))
		Lib:MergeTable(tbResult.tbPartnerSkill, (v.tbPartnerSkill or {}))
		Lib:MergeTable(tbResult.tbExtAttrib, (v.tbExtAttrib or {}))
		Lib:MergeTable(tbResult.tbExtPartnerAttrib, (v.tbExtPartnerAttrib or {}))
	end
	return tbResult
end

function JingMai:GetXueWeiAddInfo(tbXueWeiLearnedInfo, nJingMaiId, nJingMaiLevelIndex)
	local tbXueWeiInfo = {};
	local tbLevelAttrib = self.tbXueWeiLevelAttrib[nJingMaiId] and self.tbXueWeiLevelAttrib[nJingMaiId][nJingMaiLevelIndex]
	if tbLevelAttrib then
		table.insert(tbXueWeiInfo, {nJingMaiId, nJingMaiLevelIndex})
	else
		for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
			table.insert(tbXueWeiInfo, {nXueWeiId, nLevel});
		end
	end

	table.sort(tbXueWeiInfo, function (a, b)
		return a[1] < b[1];
	end);

	local tbAddInfo = {tbSkill = {}; tbPartnerSkill = {}; tbExtAttrib = {}; tbExtPartnerAttrib = {};};
	for _, tbInfo in ipairs(tbXueWeiInfo) do
		local nXueWeiId, nLevel = unpack(tbInfo);
		local tbXueWei = tbLevelAttrib and tbLevelAttrib or self.tbXueWeiSetting[nXueWeiId];
		if not nJingMaiId or nJingMaiId == tbXueWei.nJingMaiId or tbLevelAttrib then
			if tbXueWei.nExtSkillId and tbXueWei.nExtSkillId > 0 then
				table.insert(tbAddInfo.tbSkill, {tbXueWei.nExtSkillId, nLevel, tbXueWei.nMaxLevel});
			end

			if tbXueWei.nExtPartnerSkillId and tbXueWei.nExtPartnerSkillId > 0 then
				table.insert(tbAddInfo.tbPartnerSkill, {tbXueWei.nExtPartnerSkillId, nLevel, tbXueWei.nMaxLevel});
			end

			if tbXueWei.nExtAttribId and tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = tbLevelAttrib and tbLevelAttrib.nExtAttribLevel or math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				table.insert(tbAddInfo.tbExtAttrib, {tbXueWei.nExtAttribId, nAttribLevel});
			end

			if tbXueWei.nExtPartnerAttribId and tbXueWei.nExtPartnerAttribId > 0 then
				local nAttribLevel = tbLevelAttrib and tbLevelAttrib.nExtPartnerAttribLevel or math.max(math.floor(nLevel * tbXueWei.nExtPartnerAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				table.insert(tbAddInfo.tbExtPartnerAttrib, {tbXueWei.nExtPartnerAttribId, nAttribLevel});
			end
		end
	end

	return tbAddInfo;
end

function JingMai:GetAttribInfo(tbAttribInfo)
	local tbAllAttrib = {};
	for _, tbInfo in ipairs(tbAttribInfo) do
		local nAttributeID, nLevel = unpack(tbInfo);
		local tbAttrib = KItem.GetExternAttrib(nAttributeID, nLevel);
		for nSeq, tbMagic in pairs(tbAttrib or {}) do
			tbAllAttrib[tbMagic.szAttribName] = tbAllAttrib[tbMagic.szAttribName] or {tbValue = {0, 0, 0}};
			tbAllAttrib[tbMagic.szAttribName].nSeq = nSeq
			local tbOldInfo = tbAllAttrib[tbMagic.szAttribName];
			for i = 1, 3 do
				tbOldInfo.tbValue[i] = tbOldInfo.tbValue[i] + tbMagic.tbValue[i];
			end
		end
	end
	return tbAllAttrib;
end

function JingMai:MgrPartnerAttrib(tbPartnerAttribInfo, tbAttrib)
	local tbResult = Lib:CopyTB(tbPartnerAttribInfo);
	for szType, tbInfo in pairs(tbAttrib) do
		tbResult.tbBaseAttrib[szType] = tbResult.tbBaseAttrib[szType] or {tbValue = {0, 0, 0}};
		for i = 1, 3 do
			tbResult.tbBaseAttrib[szType].tbValue[i] = tbResult.tbBaseAttrib[szType].tbValue[i] + tbInfo.tbValue[i];
		end
	end

	return tbResult;
end

function JingMai:FormatAttribSeq(tbAttrib)
	local tbSeqAttrib = {}
	for szType, tbInfo in pairs(tbAttrib or {}) do
		local tbData = {}
		tbData.szType = szType
		tbData.tbValue = tbInfo.tbValue
		tbData.nSeq = tbInfo.nSeq
		table.insert(tbSeqAttrib, tbData)
	end
	-- 按ExternAttrib表里配的顺序排序
	if #tbSeqAttrib > 1 then
		table.sort(tbSeqAttrib, function(a, b) return a.nSeq < b.nSeq end)
	end
	return tbSeqAttrib
end

function JingMai:GetXueWeiAttribDesc(tbAttrib)
	local nLine = 0;
	local szDesc = "";
	local tbSeqAttrib = JingMai:FormatAttribSeq(tbAttrib)
	for _, tbInfo in ipairs(tbSeqAttrib) do
		local szType = tbInfo.szType
		local tbValue = tbInfo.tbValue
		local szInfo, nRow = FightSkill:GetMagicDesc(szType, tbValue);
		if nRow and nRow > 0 then
			szInfo = string.gsub(szInfo, "%+%-", "%+");
			szDesc = szDesc .. szInfo .. "\n";
			nLine = nLine + 1;
		end
	end

	return szDesc, nLine;
end

function JingMai:GetAttribDesc(tbAttrib)
	tbAttrib = Lib:CopyTB(tbAttrib);
	tbAttrib = {tbBaseAttrib = tbAttrib};

	local szDesc = nil;
	local nCount = 0;

	local function fnGetDesc(tbDef)
		for nIdx, tbInfo in ipairs(tbDef) do
			local szType = tbInfo[1];
			local value = 0;
			local szShowValue = nil;

			if type(tbInfo[2]) == "string" then
				value = Partner:GetJingMaiValueBase(tbAttrib, unpack(tbInfo, 2)) or 0;
			elseif type(tbInfo[2]) == "function" then
				value, szShowValue = tbInfo[2](Partner, tbAttrib, unpack(tbInfo, 3));
				value = value or 0;
			end

			local nValue = tonumber(value);
			if nValue and math.abs(nValue) > 0.0001 then
				if not szDesc then
					szDesc = string.format("%s   +%s", szType, szShowValue or value);
				else
					szDesc = string.format("%s\n%s   +%s", szDesc, szType, szShowValue or value);
				end
				nCount = nCount + 1;
			end
		end
	end

	fnGetDesc(Partner.tbAllAttribDef);
	fnGetDesc(Partner.tbJingMaiExtAttribDef);

	return szDesc or "", nCount;
end

function JingMai:GetExtSkillInfoByAsynData(pPlayerAsync, nJingMaiId, pPlayer)
	local tbExtSkillInfo = {}
	local tbXueWeiLearnedInfo = self:GetLearnedXueWeiInfo(pPlayer, pPlayerAsync);
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtSkillId > 0 then
			local bActive = true
			if nJingMaiId then
				bActive = nJingMaiId == tbXueWei.nJingMaiId
			end
			if bActive then
				table.insert(tbExtSkillInfo, {nJingMaiId = tbXueWei.nJingMaiId, nXueWeiId = nXueWeiId, nExtSkillId = tbXueWei.nExtSkillId, nLevel = nLevel})
			end
		end
	end
	return tbExtSkillInfo
end

function JingMai:UpdateAsyncPlayerAttrib(pPlayerAsync, pNpc)
	local tbXueWeiLearnedInfo, _, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(nil, pPlayerAsync);
	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtSkillId > 0 or tbXueWei.nExtPartnerAttribId > 0 then
			if tbXueWei.nExtSkillId > 0 then
				pNpc.AddSkillState(tbXueWei.nExtSkillId, nLevel, 3, 10000000);
			end

			if tbXueWei.nExtAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pNpc.ApplyExternAttrib(tbXueWei.nExtAttribId, nAttribLevel);
			end
		end
	end
	self:UpdateXueWeiLevelAttrib(pNpc, tbXueWeiLearnedInfo, false, tbJingMaiLevelInfo)
	pNpc.RestoreHP();
end

-- 任意一条经脉可升级（不检查银两）
function JingMai:CheckJingMaiLevelUpRedPoint(pPlayer)
	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		if JingMai:CheckJingMaiLevelUp(pPlayer, nJingMaiId, false, true, true) then
			return true
		end
	end
	return false
end

-- 任意一条经脉可激活
function JingMai:CheckJingMaiActivationRedPoint(pPlayer)
	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		-- 经脉可激活
		if self:CheckJingMaiOpen(nJingMaiId) and JingMai:CheckJingMaiLevelCanActivation(pPlayer, nJingMaiId) then
			return true
		end
	end
	return false
end

-- 任意一条经脉最后一个穴位可升级
function JingMai:CheckLastLevelUpRedPoint(pPlayer, nJingMaiId)
	if not JingMai:CheckOpen(pPlayer) then
		return false;
	end
	local tbId = nJingMaiId and {[nJingMaiId] = true} or self.tbJingMaiSetting
	for nJingMaiId in pairs(tbId) do
		if self:CheckJingMaiOpen(nJingMaiId) then
			-- 最后的穴位可升级
			local nLastXueWeiId = self:GetLastXueWeiId(pPlayer, nJingMaiId)
			if nLastXueWeiId then
				local bRet, szMsg = self:CheckXueWeiLevelup(pPlayer, nLastXueWeiId, true)
				if bRet then
					return true
				end
			end
		end
	end
	return false
end

function JingMai:GetLastXueWeiId(pPlayer, nJingMaiId)
	local tbLearnInfo = self:GetLearnedXueWeiInfo(pPlayer, nil, true);
	local tbJingMai = self.tbJingMaiSetting[nJingMaiId] or {}
	local tbXueWei = tbJingMai.tbXueWei or {}
	local nLastXueWeiId = tbXueWei[1]
	for _, nXueWeiId in ipairs(tbXueWei) do
		if tbLearnInfo[nXueWeiId] then
			nLastXueWeiId = nXueWeiId
		end
	end
	return nLastXueWeiId
end

function JingMai:UpdateXueWeiLevelAttrib(pTarget, tbXueWeiLearnedInfo, bPartner, tbJingMaiLevelInfo)
	local tbAttrib = self:GetJingMaiLevelAttrib(tbXueWeiLearnedInfo, tbJingMaiLevelInfo)
	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		local tbLevelAttrib = tbAttrib[nJingMaiId] or {}
		local nExtAttribId, nAttribLevel
		if bPartner then
			nExtAttribId = tbLevelAttrib.nExtPartnerAttribId
			nAttribLevel = tbLevelAttrib.nExtPartnerAttribLevel
		else
			nExtAttribId = tbLevelAttrib.nExtAttribId
			nAttribLevel = tbLevelAttrib.nExtAttribLevel
		end
		if nExtAttribId then
			pTarget.ApplyExternAttrib(nExtAttribId, nAttribLevel);
		end
	end
end

-- 是否有周天处于运转或者可激活状态
function JingMai:HadJingMaiLevelWorking(pPlayer)
	for nJingMaiId,v in pairs(self.tbJingMaiSetting) do
		local nLevelIndex, nRequestLevelTime = self:GetJingMaiLevelData(pPlayer, nJingMaiId)
		if nRequestLevelTime and nRequestLevelTime ~= 0 then
			return true, nJingMaiId, nLevelIndex, nRequestLevelTime
		end
	end
	return false
end

-- 是否有周天处于运转状态
function JingMai:HadJingMaiLevelRunning(pPlayer)
	for nJingMaiId,v in pairs(self.tbJingMaiSetting) do
		local bRunning = self:IsJingMaiLevelRunning(pPlayer, nJingMaiId)
		if bRunning then
			return true
		end
	end
	return false
end

-- 周天是否处于运转状态
function JingMai:IsJingMaiLevelRunning(pPlayer, nJingMaiId)
	local nLevelIndex, nRequestLevelTime = self:GetJingMaiLevelData(pPlayer, nJingMaiId)
	local bRunning = (nRequestLevelTime and nRequestLevelTime > 0 and GetTime() < nRequestLevelTime + JingMai.nJingMaiLevelUpTime)
	return bRunning
end

-- 检查是否可以请求升级经脉
function JingMai:CheckJingMaiLevelUp(pPlayer, nJingMaiId, bNotCheckCost, bNotCheckRunning, bNotCheckCoin)
	local tbJingMaiSetting = self.tbJingMaiSetting[nJingMaiId]
	if not tbJingMaiSetting then
		return false, "没有相关的经脉数据？？"
	end
	local tbXueWeiLearnedInfo, _, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(pPlayer, nil, true);
	local tbLevelAttrib = self:GetXueWeiLevelAttrib(tbXueWeiLearnedInfo)
	local tbJingMaiLevelData = tbJingMaiLevelInfo[nJingMaiId] or {}
	local nNowLevelIndex = tbJingMaiLevelData.nLevelIndex or 0
	if not bNotCheckRunning then
		local bRet, nRunningJingMaiId = JingMai:HadJingMaiLevelWorking(pPlayer)
		if bRet then
			local szRunningName = JingMai:GetJingMaiLevelName(nRunningJingMaiId)
			return false, string.format("你的%s正在运转中，无法操作", szRunningName or "其他周天")
		end
	end
	local nMaxLevel = JingMai:GetMaxJingMaiLevel(nJingMaiId)
	if nNowLevelIndex >= nMaxLevel then
		return false, "已达到最大等级"
	end
	local nNextLevelIndex = nNowLevelIndex + 1
	local tbNextLevelAttrib = tbLevelAttrib[nJingMaiId] and tbLevelAttrib[nJingMaiId][nNextLevelIndex]
	if not tbNextLevelAttrib then
		local nLevel = self:GetJingMaiRequireLevel(nJingMaiId, nNextLevelIndex)
		local szJingMaiName = self.tbJingMaiSetting[nJingMaiId] and self.tbJingMaiSetting[nJingMaiId].szName
		return false, string.format("打通需要%s前%d个穴位达到%s重", szJingMaiName or "", JingMai.nJingMaiPreNum, nLevel or 0)
	end
	local nRequestLevelTime = tbJingMaiLevelData.nRequestLevelTime or 0
	if nRequestLevelTime ~= 0 then
		return false, "正在申请升级中"
	end
	local tbCost = tbNextLevelAttrib.tbCost
	if tbCost and not bNotCheckCost then
		for _, tbInfo in pairs(tbCost) do
			local nType = Player.AwardType[tbInfo[1]];
			if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
				return false, "异常配置";
			end

			if nType == Player.award_type_money then
				local bCheckMoney = not bNotCheckCoin or (tbInfo[1] ~= "Coin" and tbInfo[1] ~= "coin")
				if bCheckMoney and pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
					return false, string.format("%s不足%s", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
				end
			end

			if nType == Player.award_type_item then
				local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
				if nCount < tbInfo[3] then
					local szItemName = Item:GetItemTemplateShowInfo(tbInfo[2], pPlayer.nFaction, pPlayer.nSex)
					return false, string.format("%s不足%s", szItemName, tbInfo[3]);
				end
			end
		end
	end
	return true, nil, nNowLevelIndex, tbCost, tbJingMaiSetting.szLevelName
end

-- 返回当前经脉等级对应的属性(只有当前最高等级的属性有效)
function JingMai:GetJingMaiLevelAttrib(tbXueWeiLearnedInfo, tbJingMaiLevelInfo)
	local tbAttrib = {}
	local tbLevelAttrib = self:GetXueWeiLevelAttrib(tbXueWeiLearnedInfo)
	for nJingMaiId, tbLevelInfo in pairs(tbLevelAttrib) do
		local tbJingMaiLevelData = tbJingMaiLevelInfo[nJingMaiId] or {}
		local nNowLevelIndex = tbJingMaiLevelData.nLevelIndex or 0
		tbAttrib[nJingMaiId] = tbLevelInfo[nNowLevelIndex]
	end
	return tbAttrib
end

-- 返回当前玩家所有穴位等级可以达到的所有经脉等级属性（不考虑当前的经脉等级了）
function JingMai:GetXueWeiLevelAttrib(tbXueWeiLearnedInfo)
	local tbAllAttrib = {}
	for nJingMaiId, tbInfo in pairs(self.tbJingMaiSetting) do
		local tbLevelAttrib = self.tbXueWeiLevelAttrib[nJingMaiId] or {}
		local tbXueWei = tbInfo.tbXueWei or {}
		if next(tbXueWei) then
			local tbLevelInfo = {}
			-- 多个等级满足只取最高等级的属性
			for nLevelIndex, v in ipairs(tbLevelAttrib) do
				local bGet = true
				-- 当前经脉所有穴位等级是否都达到等级段
				for _, nXueWeiId in ipairs(tbXueWei) do
					local nLearnedLevel = tbXueWeiLearnedInfo[nXueWeiId] or 0
					if not tbInfo.tbNoJoinJingMaiLevel[nXueWeiId] and nLearnedLevel < v.nLevel then
						bGet = false
					end
				end
				if bGet then
					tbLevelInfo[nLevelIndex] = Lib:CopyTB(v)
				end
			end
			tbAllAttrib[nJingMaiId] = tbLevelInfo
		end
	end
	return tbAllAttrib
end

function JingMai:OnCreatePartnerNpc(nNpcId, bHasWaite)
	if not bHasWaite then
		-- 此时 MasterNpcId还没有设置，所以要延迟下才进行更新数据
		Timer:Register(2, function ()
			self:OnCreatePartnerNpc(nNpcId, true);
		end);
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.nMasterNpcId <= 0 then
		return;
	end

	local pMasterNpc = KNpc.GetById(pNpc.nMasterNpcId);
	if not pMasterNpc then
		return;
	end

	local nPlayerId = pMasterNpc.dwPlayerID;

	if nPlayerId <= 0 and pMasterNpc.GetPlayerIdSaveInNpc then
		nPlayerId = pMasterNpc.GetPlayerIdSaveInNpc();
	end

	if not pMasterNpc or nPlayerId <= 0 then
		return;
	end

	local tbXueWeiLearnedInfo = {};
	local tbJingMaiLevelInfo = {}
	local bRet
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not MODULE_ZONESERVER and pPlayer then
		tbXueWeiLearnedInfo, bRet, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(pPlayer);
	else
		local pAsyncData = KPlayer.GetAsyncData(nPlayerId);
		if not pAsyncData then
			return;
		end

		tbXueWeiLearnedInfo, bRet, tbJingMaiLevelInfo = self:GetLearnedXueWeiInfo(nil, pAsyncData);
	end

	for nXueWeiId, nLevel in pairs(tbXueWeiLearnedInfo or {}) do
		local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
		if tbXueWei.nExtPartnerSkillId > 0 or tbXueWei.nExtPartnerAttribId > 0 then
			if tbXueWei.nExtPartnerSkillId > 0 then
				pNpc.AddSkillState(tbXueWei.nExtPartnerSkillId, nLevel, 3, 10000000);
			end

			if tbXueWei.nExtPartnerAttribId > 0 then
				local nAttribLevel = math.max(math.floor(nLevel * tbXueWei.nExtPartnerAttribMaxLevel / tbXueWei.nMaxLevel), 1);
				pNpc.ApplyExternAttrib(tbXueWei.nExtPartnerAttribId, nAttribLevel);
			end
		end
	end
	self:UpdateXueWeiLevelAttrib(pNpc, tbXueWeiLearnedInfo, true, tbJingMaiLevelInfo)
	pNpc.RestoreHP();
end

function JingMai:OnSyncOpenInfo(tbOpenInfo)
	self.tbOpenInfo = tbOpenInfo;
end
-- int32位，每8位存一个值，最大256，这是因为和策划对过穴位等级和失败次数一般不超过256
function JingMai:GetXueWeiUserValueSaveIdx(nXueWeiId, tbSaveGroup)
	if nXueWeiId <= 0 or nXueWeiId > MAX_XUEWEI_ID then
		return;
	end

	tbSaveGroup = tbSaveGroup or SAVE_GROUP_LIST;

	local nTotalIdx = math.ceil(nXueWeiId / 4);
	local nBitIdx = nXueWeiId % 4;
	nBitIdx = nBitIdx == 0 and 4 or nBitIdx;

	local nSaveGroup = math.ceil(nTotalIdx / 255);
	if nSaveGroup > #tbSaveGroup then
		return;
	end
	nSaveGroup = tbSaveGroup[nSaveGroup];

	local nSaveIdx = nTotalIdx % 255;
	nSaveIdx = nSaveIdx == 0 and 255 or nSaveIdx;

	return nSaveGroup, nSaveIdx, nBitIdx * 8 - 8, nBitIdx * 8 - 1;
end

function JingMai:GetXueWeiLevel(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId);
	if not nSaveGroup then
		Log("[JingMai] GetXueWeiLevel ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	return Lib:LoadBits(nValue, nBitBegin, nBitEnd);
end

function JingMai:GetXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] GetXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return 0;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	return Lib:LoadBits(nValue, nBitBegin, nBitEnd);
end

function JingMai:AddXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] AddXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	local nFailTimes = Lib:LoadBits(nValue, nBitBegin, nBitEnd);

	nValue = Lib:SetBits(nValue, nFailTimes + 1, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);
end

function JingMai:ClearXueWeiFailTimes(pPlayer, nXueWeiId)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId, SAVE_GROUP_FAIL_COUNT_LIST);
	if not nSaveGroup then
		Log("[JingMai] AddXueWeiFailTimes ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);
	nValue = Lib:SetBits(nValue, 0, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);
end

function JingMai:GetRealRate(pPlayer, nXueWeiId, nRate)
	if nRate > 300000 then
		return nRate, false;
	end

	local nFailTimes = self:GetXueWeiFailTimes(pPlayer, nXueWeiId) + 1;
	local nBaseTimes = math.ceil(self.MAX_RATE / nRate);

	local nTimesRate = 1;
	if nFailTimes > nBaseTimes then
		nTimesRate = nFailTimes - nBaseTimes + 1;
	elseif nFailTimes < nBaseTimes then
		nTimesRate = (nBaseTimes - nFailTimes) * 0.5 + 0.5
	end

	local nRealRate = math.floor(nFailTimes > nBaseTimes and nRate * nTimesRate or nRate / nTimesRate);
	return math.min(math.max(nRealRate, 0), self.MAX_RATE);
end

function JingMai:GetJingMaiLevelUserValueSaveIdx(nJingMaiId, tbSaveGroup)
	tbSaveGroup = tbSaveGroup or ALL_JINGMAI_LEVEL_SAVE_GROUP_LIST;
	local nMaxJingMaiId = #tbSaveGroup * MAX_JINGMAN_LEVEL_COUNT
	if nJingMaiId <= 0 or nJingMaiId > nMaxJingMaiId then
		return;
	end
	local nSaveGroupIndex = math.ceil(nJingMaiId / MAX_JINGMAN_LEVEL_COUNT);
	local nSaveGroup = tbSaveGroup[nSaveGroupIndex];
	local nSaveIdx = nJingMaiId % MAX_JINGMAN_LEVEL_COUNT
	nSaveIdx = nSaveIdx == 0 and MAX_JINGMAN_LEVEL_COUNT or nSaveIdx;
	local nBaseSaveIdx = (nSaveIdx - 1) * ALL_JINGMAI_LEVEL_MAX_STEP;
	local nLevelSaveIdx = nBaseSaveIdx + ALL_JINGMAI_LEVEL_INDEX_STEP
	local nLevelTimeSaveIdx = nBaseSaveIdx + ALL_JINGMAI_LEVEL_TIME_STEP
	return nSaveGroup, nLevelSaveIdx, nLevelTimeSaveIdx
end

function JingMai:GetJingMaiLevelData(pPlayer, nJingMaiId)
	local nSaveGroup, nLevelSaveIdx, nLevelTimeSaveIdx = self:GetJingMaiLevelUserValueSaveIdx(nJingMaiId)
	if not nSaveGroup then
		Log("[JingMai] fnGetJingMaiLevelData ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nJingMaiId, nLevelSaveIdx or "nil", nLevelTimeSaveIdx or "nil", debug.traceback());
		return
	end
	return pPlayer.GetUserValue(nSaveGroup, nLevelSaveIdx), pPlayer.GetUserValue(nSaveGroup, nLevelTimeSaveIdx)
end

function JingMai:GetJingMaiLevelAsyncDataSaveId(nJingMaiId)
	local nBaseSaveIdx = (nJingMaiId - 1) * ALL_JINGMAI_LEVEL_MAX_STEP + JINGMAI_LEVEL_BEGINE_SAVE_ID;
	return nBaseSaveIdx + ALL_JINGMAI_LEVEL_INDEX_STEP, nBaseSaveIdx + ALL_JINGMAI_LEVEL_TIME_STEP
end

function JingMai:GetJingMaiLevelDataByAsyncData(pAsyncData, nJingMaiId)
	if nJingMaiId >= math.floor(JINGMAI_LEVEL_END_SAVE_ID / ALL_JINGMAI_LEVEL_MAX_STEP) then
		local szName = pAsyncData.GetPlayerInfo();
		Log("[JingMai] fnGetJingMaiLevelDataByAsyncData ERR ?? ", szName, nJingMaiId, debug.traceback());
		return 
	end
	local nLevelSaveIdx, nLevelTimeSaveIdx = self:GetJingMaiLevelAsyncDataSaveId(nJingMaiId) 
	local nLevelIndex = pAsyncData.GetAsyncBattleValue(nLevelSaveIdx)
	local nLevelTime = pAsyncData.GetAsyncBattleValue(nLevelTimeSaveIdx)
	return nLevelIndex, nLevelTime
end

function JingMai:SetJingMaiLevelData(pPlayer, nJingMaiId, nLevelIndex, nRequestLevelTime)
	local nSaveGroup, nLevelSaveIdx, nLevelTimeSaveIdx = self:GetJingMaiLevelUserValueSaveIdx(nJingMaiId)
	if not nSaveGroup or not self.tbJingMaiSetting[nJingMaiId] 
		or not self.tbXueWeiLevelAttrib[nJingMaiId] or (nLevelIndex and not self.tbXueWeiLevelAttrib[nJingMaiId][nLevelIndex]) then
		Log("[JingMai] fnSetJingMaiLevelData ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nJingMaiId, nLevelIndex, nRequestLevelTime, nLevelSaveIdx or "nil", nLevelTimeSaveIdx or "nil", debug.traceback());
		return
	end
	if nLevelIndex then
		pPlayer.SetUserValue(nSaveGroup, nLevelSaveIdx, nLevelIndex);
	end 
	if nRequestLevelTime then
		pPlayer.SetUserValue(nSaveGroup, nLevelTimeSaveIdx, nRequestLevelTime);
	end
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID);
	if pAsyncData then
		JingMai:__SetJingMaiLevelByAsyncData(pAsyncData, nJingMaiId, nLevelIndex, nRequestLevelTime)
	end
end

function JingMai:__SetJingMaiLevelByAsyncData(pAsyncData, nJingMaiId, nLevelIndex, nRequestLevelTime)
	local nLevelSaveIdx, nLevelTimeSaveIdx = self:GetJingMaiLevelAsyncDataSaveId(nJingMaiId)
	if nLevelIndex then
		pAsyncData.SetAsyncBattleValue(nLevelSaveIdx, nLevelIndex);
	end 
	if nRequestLevelTime then
		pAsyncData.SetAsyncBattleValue(nLevelTimeSaveIdx, nRequestLevelTime);
	end
	
end

function JingMai:SetXueWeiLevel(pPlayer, nXueWeiId, nLevel)
	local nSaveGroup, nSaveIdx, nBitBegin, nBitEnd = self:GetXueWeiUserValueSaveIdx(nXueWeiId);
	if not nSaveGroup or nLevel > MAX_XUEWEI_LEVEL or nLevel < 0 then
		Log("[JingMai] SetXueWeiLevel ERR ?? ", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, debug.traceback());
		return;
	end

	local nValue = pPlayer.GetUserValue(nSaveGroup, nSaveIdx);


	nValue = Lib:SetBits(nValue, nLevel, nBitBegin, nBitEnd);
	pPlayer.SetUserValue(nSaveGroup, nSaveIdx, nValue);

	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID);
	if pAsyncData then
		self:__SetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId, nLevel);
	end
end

function JingMai:GetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId)
	return pAsyncData.GetAsyncBattleValue(nXueWeiId + XUEWEI_BEGINE_SAVE_ID);
end

function JingMai:__SetXueWeiLevelByAsyncData(pAsyncData, nXueWeiId, nLevel)
	if not nXueWeiId or not nLevel or nLevel < 0 then
		Log("[JingMai] SetXueWeiLevelByAsyncData ERR ?? ", nXueWeiId or "nil", nLevel or "nil", debug.traceback());
		return;
	end

	local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
	if not tbXueWei or nLevel > tbXueWei.nMaxLevel then
		Log("[JingMai] SetXueWeiLevelByAsyncData ERR ?? ", nXueWeiId, nLevel, debug.traceback());
		return;
	end

	pAsyncData.SetAsyncBattleValue(nXueWeiId + XUEWEI_BEGINE_SAVE_ID, nLevel);
end

function JingMai:CostLevelupTimes(pPlayer)
	local nLocalDay = Lib:GetLocalDay(GetTime() - 4 * 3600);
	if pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE) ~= nLocalDay then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE, nLocalDay);
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT, 0);
	end

	local nTimes = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT);
	if nTimes < self.nMaxLevelupTimes then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT, nTimes + 1);
		return true;
	end

	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	if nExtCount > 0 then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT, nExtCount - 1);
		return true;
	end

	return false;
end

function JingMai:AddLevelupExtTimes(pPlayer, nTimes)
	if nTimes <= 0 then
		Log("[JingMai] AddLevelupExtTimes ERR ?? nTimes <= 0", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nTimes, debug.traceback())
		return;
	end

	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT, nExtCount + nTimes);
end

function JingMai:GetLevelupLastTimes(pPlayer)
	local nExtCount = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_EXT_COUNT);
	local nLocalDay = Lib:GetLocalDay(GetTime() - 4 * 3600);
	if pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_DATE) ~= nLocalDay then
		return nExtCount + self.nMaxLevelupTimes;
	end

	return nExtCount + self.nMaxLevelupTimes - pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_XUEWEI_LEVELUP_COUNT);
end

function JingMai:CheckJingMaiOpen(nJingMaiId)
	local tbJingMai = self.tbJingMaiSetting[nJingMaiId];
	if not tbJingMai then
		return false, "不存在的经脉";
	end

	local nTimeNow = GetTime();
	if self.tbOpenInfo then
		if nJingMaiId >= self.tbOpenInfo.nNextOpenJingMaiId and nTimeNow < self.tbOpenInfo.nOpenTime then
			return false, string.format("将在%s后开放此经脉", Lib:TimeDesc2(self.tbOpenInfo.nOpenTime - nTimeNow));
		end
	end

	local nOpenTime = TimeFrame:CalcTimeFrameOpenTime(tbJingMai.szOpenTimeFrame);
	if nTimeNow < nOpenTime then
		return false, string.format("将于%s后开放此经脉", Lib:TimeDesc2(nOpenTime - nTimeNow));
	end

	return true, "", tbJingMai;
end

function JingMai:CheckOpen(pPlayer)
	if TimeFrame:GetTimeFrameState(self.szOpenTimeFrame) ~= 1 then
		return false, "功能未开放";
	end

	if pPlayer.nLevel < self.nOpenLevel then
		return false, string.format("需要等级到%s，才能进行此操作！", self.nOpenLevel);
	end

	if Task:GetTaskFlag(pPlayer, self.nOpenTaskId) ~= 1 then
		return false, "未完成前置任务";
	end

	return true;
end

function JingMai:CheckXueWeiLevelup(pPlayer, nXueWeiId, bNotCheckCoin)
	local bRet, szMsg = self:CheckOpen(pPlayer);
	if not bRet then
		return false, szMsg;
	end

	local tbXueWei = self.tbXueWeiSetting[nXueWeiId];
	if not tbXueWei then
		return false, "不存在的穴位";
	end

	local tbJingMai = nil;
	bRet, szMsg, tbJingMai = self:CheckJingMaiOpen(tbXueWei.nJingMaiId);
	if not bRet then
		return false, szMsg;
	end

	if self:GetLevelupLastTimes(pPlayer) <= 0 then
		return false, string.format("阁下今日已成功冲穴[FFFE0D]%s[-]次，气海虚浮无法继续！", self.nMaxLevelupTimes);
	end

	for _, tbInfo in pairs(tbXueWei.tbRequireXueWei) do
		local nRequire_XueWei, nRequire_Level = unpack(tbInfo);
		local nRLevel = self:GetXueWeiLevel(pPlayer, nRequire_XueWei);
		if nRLevel < nRequire_Level then
			return false, string.format("前置穴位重数不足 %s", nRequire_Level);
		end
	end


	local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
	if not nLevel then
		return false, "数据异常";
	end

	if nLevel >= tbXueWei.nMaxLevel or not tbXueWei.tbRequireLevel[nLevel + 1] then
		return false, "已达等级上限";
	end

    --Log("[JingMai_Debug]", nLevel, tbXueWei.nMaxLevel, tbXueWei.nExtPartnerAttribMaxLevel);

	if nLevel >= tbXueWei.nExtPartnerAttribMaxLevel then
		return false, "已达等级上限";
	end

	if pPlayer.nLevel < tbXueWei.tbRequireLevel[nLevel + 1] then
		return false, string.format("需要等级达到%s级！", tbXueWei.tbRequireLevel[nLevel + 1]);
	end

	local nRate = self.MAX_RATE;
	local tbCost = tbXueWei.tbCost;
	if nLevel > 0 then
		tbCost = self.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nLevel].tbCost;
		nRate = self.tbXueWeiLevelupInfo[tbXueWei.nLevelupType][nLevel].nRate;
	end

	for _, tbInfo in pairs(tbCost) do
		local nType = Player.AwardType[tbInfo[1]];
		if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
			return false, "异常配置";
		end

		if nType == Player.award_type_money then
			-- 可以选择忽略检查银两
			local bCheckMoney = not bNotCheckCoin or (tbInfo[1] ~= "Coin" and tbInfo[1] ~= "coin")
			if bCheckMoney and pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
				return false, string.format("%s不足%s", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
			end
		end

		if nType == Player.award_type_item then
			local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
			if nCount < tbInfo[3] then
				local szItemName = Item:GetItemTemplateShowInfo(tbInfo[2], pPlayer.nFaction, pPlayer.nSex)
				return false, string.format("%s不足%s", szItemName, tbInfo[3]);
			end
		end
	end

	return true, "", tbXueWei, nLevel, tbCost, nRate;
end

function JingMai:XueWeiLevelup(pPlayer, nXueWeiId, nXueWeiLevel)
	local bRet, szMsg, tbXueWei, nLevel, tbCost, nRate = self:CheckXueWeiLevelup(pPlayer, nXueWeiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	if nLevel ~= nXueWeiLevel then
		return;
	end

	for _, tbInfo in ipairs(tbCost) do
		local nType = Player.AwardType[tbInfo[1]];
		if nType == Player.award_type_item then
			local nCount = pPlayer.ConsumeItemInBag(tbInfo[2], tbInfo[3], Env.LogWay_XueWeiLevelup);
			if nCount < tbInfo[3] then
				pPlayer.CenterMsg("扣除道具失败！");
				Log("[JingMai] XueWeiLevelup ConsumeItemInBag Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[2], tbInfo[3], nCount);
				return;
			end
		elseif nType == Player.award_type_money then
			local bResult = pPlayer.CostMoney(tbInfo[1], tbInfo[2], Env.LogWay_XueWeiLevelup);
			if not bResult then
				Log("[JingMai] XueWeiLevelup CostMoney Fail !!!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel, tbInfo[1], tbInfo[2]);
				return;
			end
		end
	end

	local bAddFailTimes = true;
	local bSuccess = false;
	local nFakeRate = nRate
	nRate = JingMai:GetRealRate(pPlayer, nXueWeiId, nRate);
	local nRandom = MathRandom(self.MAX_RATE);
	if nRandom <= nRate then
		bSuccess = true;
	end

	local nValue = Player:GetRewardValueDebt(pPlayer.dwID);
	if nRate < self.MAX_RATE and bSuccess and nValue > 0 then
		if MathRandom(100) >= 50 then
			bSuccess = false;
			bAddFailTimes = false;

			local nCostVale = 0;
			for _, tbInfo in pairs(tbCost) do
				if tbInfo[1] == "ZhenQi" then
					nCostVale = nCostVale + tbInfo[2];
				end
			end

			nCostVale = math.floor(nCostVale / 10);
			Player:CostRewardValueDebt(pPlayer.dwID, nCostVale, Env.LogWay_XueWeiLevelup);
		end
	end

	if not bSuccess then
		pPlayer.CenterMsg(string.format("很遗憾，穴位 [FFFE0D]%s[-] 冲穴失败了！", JingMai.tbXueWeiSetting[nXueWeiId].szName));
		pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId, false);
		Log("[JingMai] XueWeiLevelup Fail !", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
		if bAddFailTimes then
			self:AddXueWeiFailTimes(pPlayer, nXueWeiId);
		end
		local nFailTimes = self:GetXueWeiFailTimes(pPlayer, nXueWeiId);
		if nFailTimes > 0 then
			Achievement:SetCount(pPlayer, "Meridian_Failure_1", nFailTimes);
		end
		if nFakeRate >= 900000 then
			Achievement:SetCount(pPlayer, "Meridian_Failure", nFailTimes);
		end
		return;
	end

	bRet = self:CostLevelupTimes(pPlayer);
	if not bRet then
		pPlayer.CenterMsg("丹田气息紊乱，无法冲穴！");
		Log("[JingMai] ERR ?? XueWeiLevelup CostLevelupTimes Fail !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
		return;
	end

	self:ClearXueWeiFailTimes(pPlayer, nXueWeiId);

	self:SetXueWeiLevel(pPlayer, nXueWeiId, nLevel + 1);
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	if nLevel == 0 then
		pPlayer.CenterMsg(string.format("打通穴位 %s 成功！", JingMai.tbXueWeiSetting[nXueWeiId].szName));
	else
		pPlayer.SendBlackBoardMsg(string.format("穴位 [FFFE0D]%s[-] 冲穴成功，境界提升为 [FFFE0D]%s[-] 重！", JingMai.tbXueWeiSetting[nXueWeiId].szName, nLevel + 1));
	end
	pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId, true);
	Achievement:AddCount(pPlayer, "Meridian", 1);
	--JingMai:CheckXueWeiAchi(pPlayer)
	Log("[JingMai] XueWeiLevelup Success !", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel + 1);
end

function JingMai:OnSyncXueWeiLevelChange(nXueWeiId, bOK)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP, nXueWeiId, bOK);
end

function JingMai:OnGetProtentialItemByPartner(pPlayer, nUseItemProtentialValue)
	if not self:CheckOpen(pPlayer) then
		return;
	end

	local nItemCount = math.ceil(nUseItemProtentialValue / Partner:GetItemValue(Partner.nPartnerProtentialItem));
	if nItemCount <= 0 then
		return;
	end

	local nSaveInfo = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID);
	if nSaveInfo == 0 then
		pPlayer.SendBlackBoardMsg("当前丹田状态变为[FFFE0D]疲劳[-]状态！", true);
	end
	pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID, nSaveInfo + nItemCount);
end

function JingMai:OnUsePartnerProtentialItem(pPlayer, nCount, bNotNotify)
	if not self:CheckOpen(pPlayer) then
		return;
	end

	local nSaveInfo = pPlayer.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID);
	local nLast = math.max(nSaveInfo - nCount, 0);

	if nSaveInfo > 0 then
		pPlayer.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_ID, nLast);
		if not bNotNotify then
			pPlayer.CenterMsg(string.format("同伴使用了[FFFE0D]%s[-]个资质丹，丹田疲劳度降低[FFFE0D]%s[-]！", nCount, nCount), true);
			if nLast <= 0 then
				pPlayer.SendBlackBoardMsg("当前丹田状态变为[FFFE0D]充盈[-]状态！", true);
			end
		end
	end

	nCount = nCount - nSaveInfo;
	if nLast > 0 or nCount <= 0 then
		return;
	end

	local nZhenQiCount = 0;
	for i = 1, nCount do
		local nRandom = MathRandom(self.tbUseProtntialItemRandom[#self.tbUseProtntialItemRandom][1]);
		local nRate = self.tbUseProtntialItemRandom[1][2];
		for _, tbInfo in ipairs(self.tbUseProtntialItemRandom) do
			if tbInfo[1] >= nRandom then
				nRate = tbInfo[2];
				break;
			end
		end

		nZhenQiCount = nZhenQiCount + nRate * self.nUseItemProtentialZhenQiValue;
	end

	nZhenQiCount = math.max(math.floor(nZhenQiCount), 0);
	if nZhenQiCount <= 0 then
		return;
	end

	pPlayer.SendAward({{"ZhenQi", nZhenQiCount}}, false, false, Env.LogWay_XueWeiUseProtentialItem);
	pPlayer.CenterMsg(string.format("本次对同伴使用了[FFFE0D]%s[-]个资质丹，获得了[FFFE0D]%s[-]真气！", nCount, nZhenQiCount), true);
	Log("[JingMai] OnUsePartnerProtentialItem", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nCount);
end

function JingMai:CheckCanResetXueWei(pPlayer, nXueWeiId)
	if not self.bOpenResetXueWei then
		return false, "暂未开放重置穴位功能"
	end
	local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
	if not nLevel or nLevel <= 0 then
		return false, "无需重置";
	end

	local tbBeenRequired = self.tbXueWeiBeenRequired[nXueWeiId] or {};
	for _, nBRXueWeiId in pairs(tbBeenRequired) do
		local nBRLevel = self:GetXueWeiLevel(pPlayer, nBRXueWeiId);
		if nBRLevel and nBRLevel > 0 then
			return false, string.format("需要先重置穴位[FFFE0D]%s[-]", self.tbXueWeiSetting[nBRXueWeiId].szName);
		end
	end

	return true, "", nLevel;
end

function JingMai:GetResetXueWeiAward(tbXueWeiInfo)
	local nTotalZhenCount = 0;
	for _, tbInfo in pairs(tbXueWeiInfo) do
		local nXueWeiId, nLevel = unpack(tbInfo);
		nTotalZhenCount = nTotalZhenCount + self.tbXueWeiSetting[nXueWeiId].tbCostZhenQi[nLevel];
	end
	nTotalZhenCount = math.max(math.floor(nTotalZhenCount * self.nResetZhenQiRate), 1);
	return {{"ZhenQi", nTotalZhenCount}}, nTotalZhenCount;
end

function JingMai:ResetXueWei(pPlayer, nXueWeiId)
	local bRet, szMsg, nLevel = self:CheckCanResetXueWei(pPlayer, nXueWeiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	self:AddLevelupExtTimes(pPlayer, nLevel);
	self:ClearXueWeiFailTimes(pPlayer, nXueWeiId);
	self:SetXueWeiLevel(pPlayer, nXueWeiId, 0);
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	local tbAward, nZhenQiCount = self:GetResetXueWeiAward({{nXueWeiId, nLevel}});
	pPlayer.SendAward(tbAward, nil, true, Env.LogWay_XueWeiResetAward);
	pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", nXueWeiId);
	pPlayer.SendBlackBoardMsg(string.format("重置穴位 [FFFE0D]%s[-] 成功，获得 [FFFE0D]%s[-] 真气和 [FFFE0D]%s[-] 冲穴次数返还！", self.tbXueWeiSetting[nXueWeiId].szName, nZhenQiCount, nLevel), true);
	Log("[JingMai] ResetXueWei", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nXueWeiId, nLevel);
end

function JingMai:CheckCanResetJingMai(pPlayer, nJingMaiId)
	if not self.bOpenResetJingMai then
		return false, "未开放重置经脉功能"
	end
	local tbJingMai = self.tbJingMaiSetting[nJingMaiId];
	if not tbJingMai then
		return false, "不存在的经脉";
	end

	local szLogInfo = "";
	local tbXueWeiLearnedInfo = {};
	for _, nXueWeiId in pairs(tbJingMai.tbXueWei) do
		local nLevel = self:GetXueWeiLevel(pPlayer, nXueWeiId);
		if nLevel and nLevel > 0 then
			table.insert(tbXueWeiLearnedInfo, {nXueWeiId, nLevel});
			szLogInfo = string.format("%s%s|%s;", szLogInfo, nXueWeiId, nLevel);
		end
	end

	if #tbXueWeiLearnedInfo <= 0 then
		return false, "无需重置";
	end

	return true, "", szLogInfo, tbXueWeiLearnedInfo;
end

function JingMai:ResetJingMai(pPlayer, nJingMaiId)
	local bRet, szMsg, szLogInfo, tbXueWeiLearnedInfo = self:CheckCanResetJingMai(pPlayer, nJingMaiId);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local nTotalLevel = 0;
	for _, tbInfo in pairs(tbXueWeiLearnedInfo) do
		nTotalLevel = nTotalLevel + tbInfo[2];
		self:AddLevelupExtTimes(pPlayer, tbInfo[2]);
		self:ClearXueWeiFailTimes(pPlayer, tbInfo[1]);
		self:SetXueWeiLevel(me, tbInfo[1], 0);
		pPlayer.CallClientScript("JingMai:OnSyncXueWeiLevelChange", tbInfo[1]);
	end
	self:UpdatePlayerAttrib(pPlayer);
	FightPower:ChangeFightPower("JingMai", pPlayer);

	local tbAward, nZhenQiCount = self:GetResetXueWeiAward(tbXueWeiLearnedInfo);
	pPlayer.SendAward(tbAward, nil, true, Env.LogWay_XueWeiResetAward);
	pPlayer.SendBlackBoardMsg(string.format("重置经脉 [FFFE0D]%s[-] 成功，获得 [FFFE0D]%s[-] 真气和 [FFFE0D]%s[-] 冲穴次数返还！", self.tbJingMaiSetting[nJingMaiId].szName, nZhenQiCount, nTotalLevel), true);
	Log("[JingMai] ResetJingMai", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nJingMaiId, szLogInfo);
end

function JingMai:OnFinishTask(nTaskId)
	if nTaskId ~= self.nOpenTaskId then
		return;
	end

	me.SendBlackBoardMsg("阁下已领悟了打通经脉的法门，可通过“[FFFE0D]同伴——经脉[-]”界面查看！", true);

	local nUseItemProtentialValue = 0;
	local tbAllPartner = me.GetAllPartner();
	for _, tbPartner in pairs(tbAllPartner) do
		-- 10003 号IntValue 存储的是同伴使用资质丹数量，为了效率所以直接通过这种方式获取
		-- 具体定义位置 CommonScript/Partner/LuaPartner.lua:45
		nUseItemProtentialValue = nUseItemProtentialValue + (tbPartner.tbIntValue[10003] or 0);
	end

	me.SetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_OPEN_DATE, Lib:GetLocalDay());
	local nItemCount = math.max(math.floor(nUseItemProtentialValue / Partner:GetItemValue(Partner.nPartnerProtentialItem)), 0);
	local nZhenQi = math.floor(self.nOpenJingMaiAwardRate * nItemCount);
	if nZhenQi > 0 then
		local tbMail = {
			To = me.dwID;
			Title = "真气运行";
			Text = "      小友天资不错，这么快就领悟了[FFFE0D]经脉[-]中真气运行的法门，在此之前你的同伴使用资质丹已经在丹田中凝结了很多[FFFE0D]真气[-]，老朽就帮助你获得这些真气以便随意使用吧。";
			From = "玄天道人";
			tbAttach = {{"ZhenQi", nZhenQi}};
			nLogReazon = Env.LogWay_JingMaiOpenAward;
		};
		Mail:SendSystemMail(tbMail);
	end
	me.CallClientScript("JingMai:OnClientEnterMap");
	Log("[JingMai] OnFinishTask", me.dwID, me.szAccount, me.szName, nItemCount, nZhenQi);
end

function JingMai:CheckShowRedPoint()
	if not JingMai:CheckOpen(me) then
		return false;
	end

	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		if self:CheckJingMaiOpen(nJingMaiId) and Client:GetFlag("JingMai_" .. nJingMaiId) ~= 1 then
			return true;
		end
	end

	local nOpenDay = me.GetUserValue(self.SAVE_GROUP_ID, self.SAVE_INDEX_OPEN_DATE);
	if nOpenDay <= 0 then
		return false;
	end

	local nLocalDay = Lib:GetLocalDay();
	if nLocalDay - nOpenDay > 14 then
		return false;
	end

	local nTipDate = Client:GetFlag("JingMai");
	if nTipDate == nLocalDay then
		return false;
	end

	local bNeedTip = false;
	for nXueWeiId in pairs(self.tbXueWeiSetting) do
		if self:CheckXueWeiLevelup(me, nXueWeiId) then
			bNeedTip = true;
			break;
		end
	end

	return bNeedTip;
end

function JingMai:OnClientEnterMap()
	if self:CheckJingMaiMainPanelRP(me) then
		Ui:SetRedPointNotify("PartnerMainPanel");
	end
end

function JingMai:GetJingMaiLevelAttribInfo(pPlayer, tbJingMaiId, tbJingMaiLevelInfo)
	local tbAddAttribInfo = {}
	for nJingMaiId in pairs(tbJingMaiId or {}) do
		local nLevelIndex = 0
		if tbJingMaiLevelInfo then
			nLevelIndex = (tbJingMaiLevelInfo[nJingMaiId] or {}).nLevelIndex or 0
		else
			nLevelIndex = JingMai:GetJingMaiLevelData(pPlayer, nJingMaiId)
		end
		local tbJingMaiLevelAddAttribInfo = JingMai:GetXueWeiAddInfo(nil, nJingMaiId, nLevelIndex);
		tbAddAttribInfo = self:CombineAddInfo(tbAddAttribInfo, tbJingMaiLevelAddAttribInfo)
	end
	return tbAddAttribInfo
end