-- 关卡类型
PersonalFuben.PERSONAL_LEVEL_NORMAL		= 1;			-- 普通
PersonalFuben.PERSONAL_LEVEL_ELITE		= 2;			-- 精英

PersonalFuben.PERSONAL_MAX_REVIVE_TIMES		= 500;		-- 当前关卡中最多付费重生次数

PersonalFuben.PERSONAL_SWEEP_DEALY_TIME = 5;			-- 每次扫荡耗时
PersonalFuben.PERSONAL_SWEEP_MIN_LEVEL = 14;			-- 扫荡最低等级限制
PersonalFuben.PERSONAL_SWEEP_COST_GOLD = 1;				-- 扫荡消耗元宝
PersonalFuben.PERSONAL_SWEEP_COST_ITEM = 1345;				-- 扫荡券道具 ID

PersonalFuben.LIFE_LIMITE = 40;							-- 血量大于 80%
PersonalFuben.TIME_LIMITE = 120;						-- 剩余时间大于 210s

PersonalFuben.Partner_Exp_Rate = 100;					-- 每消耗一点体力 同伴增加经验数量

PersonalFuben.NoviceLevel = 4;							-- 新手等级

PersonalFuben.ReviveTime = 5;							-- 复活时间

PersonalFuben.ResetTimesCost = {30, 50};
PersonalFuben.nMaxResetTimes = #PersonalFuben.ResetTimesCost;

PersonalFuben.tbTypeToSpr =
{
	[0] = "FubenNameBackground_01",
	[1] = "FubenNameBackground_01",
	[2] = "FubenNameBackground_02",
	[3] = "FubenNameBackground_03",
};

PersonalFuben.tbLoseItemRandomCount =
{
	[PersonalFuben.PERSONAL_LEVEL_NORMAL] = {2, 4},			-- 普通关卡奖励随机 2-4 次
	[PersonalFuben.PERSONAL_LEVEL_ELITE] = {3, 5},			-- 精英关卡奖励 4-8 次
};


PersonalFuben.tbErr =
{
	Times_Err     = 1;	-- 关卡可进入次数不足
	SweepItem_Err = 3;	-- 扫荡券不足
	Gold_Err      = 4;	-- 元宝不足
	VipLevel_Err  = 5;	-- vip等级不够
}

PersonalFuben.tbStarAwardNum = {7, 14, 21};

PersonalFuben.tbErrCode = {};
for szInfo, nErrCode in pairs(PersonalFuben.tbErr) do
	PersonalFuben.tbErrCode[nErrCode] = szInfo;
end

function PersonalFuben:Load()
	self.tbAllFubenInfo = {};
	local tbFileDef = {
		{"nFubenIndex", 		"d"},
		{"szFubenTitle", 		"s"},
		{"szDesc", 				"s"},
		{"nNormalRecommendEdge","d"},
		{"nEliteRecommendEdge", "d"},
		{"nTimeLimite", 		"d"},
		{"szNormalTime", 		"s"},
		{"szEliteTime", 		"s"},
		{"nNeedLevel", 			"d"},
		{"nMapTemplateId", 		"d"},
		{"nNormalGatherPoint", 	"d"},
		{"nEliteGatherPoint", 	"d"},
		{"nNormalFreeTimes", 	"d"},
		{"nEliteFreeTimes", 	"d"},
		{"szLeaveFubenPos",		"s"},
	};

	local tbFileInfo = {};
	local szType = "";
	for _, tbInfo in ipairs(tbFileDef) do
		table.insert(tbFileInfo, tbInfo[1]);
		szType = szType .. tbInfo[2];
	end

	local tbFile = LoadTabFile("Setting/Fuben/PersonalFuben/PersonalFubenInfo.tab", szType, nil, tbFileInfo);
	for _, tbInfo in pairs(tbFile) do
		if self.tbAllFubenInfo[tbInfo.nFubenIndex] then
			assert(false, "Setting/Fuben/PersonalFuben/PersonalFubenInfo.tab tbInfo.nFubenIndex is error !! >>" .. tbInfo.nFubenIndex);
			return;
		end

		tbInfo.tbSection = {};

		tbInfo.tbRecommendEdge = {};
		tbInfo.tbRecommendEdge[self.PERSONAL_LEVEL_NORMAL] = tbInfo.nNormalRecommendEdge;
		tbInfo.nNormalRecommendEdge = nil;
		tbInfo.tbRecommendEdge[self.PERSONAL_LEVEL_ELITE] = tbInfo.nEliteRecommendEdge;
		tbInfo.nEliteRecommendEdge = nil;

		tbInfo.tbFreeTimesInfo = {};
		tbInfo.tbFreeTimesInfo[self.PERSONAL_LEVEL_NORMAL] = tbInfo.nNormalFreeTimes;
		tbInfo.nNormalFreeTimes = nil;
		tbInfo.tbFreeTimesInfo[self.PERSONAL_LEVEL_ELITE] = tbInfo.nEliteFreeTimes;
		tbInfo.nEliteFreeTimes = nil;

		tbInfo.tbGatherPoint = {};
		tbInfo.tbGatherPoint[self.PERSONAL_LEVEL_NORMAL] = tbInfo.nNormalGatherPoint;
		tbInfo.nNormalGatherPoint = nil;
		tbInfo.tbGatherPoint[self.PERSONAL_LEVEL_ELITE] = tbInfo.nEliteGatherPoint;
		tbInfo.nEliteGatherPoint = nil;

		tbInfo.tbStarTimeLimite = {};
		local nTime1, nTime2 = string.match(tbInfo.szNormalTime, "^(%d+)|(%d+)$");
		tbInfo.tbStarTimeLimite[self.PERSONAL_LEVEL_NORMAL] = {tonumber(nTime1), tonumber(nTime2)};
		tbInfo.szNormalTime = nil;

		local nTime1, nTime2 = string.match(tbInfo.szEliteTime, "^(%d+)|(%d+)$");
		tbInfo.tbStarTimeLimite[self.PERSONAL_LEVEL_ELITE] = {tonumber(nTime1), tonumber(nTime2)};
		tbInfo.szEliteTime = nil;

		local nMapId, nPosX, nPosY = string.match(tbInfo.szLeaveFubenPos, "^(%d+)|(%d+)|(%d+)$");
		if nMapId then
			nMapId = tonumber(nMapId);
			nPosX = tonumber(nPosX);
			nPosY = tonumber(nPosY);
			tbInfo.tbLeaveFubenPos = {nMapId, nPosX, nPosY};
		end
		tbInfo.szLeaveFubenPos = nil;

		self.tbAllFubenInfo[tbInfo.nFubenIndex] = tbInfo;
	end

	self.tbAllSectionInfo = {};
	self.tbAllSectionInfo[self.PERSONAL_LEVEL_NORMAL] = {};
	self.tbAllSectionInfo[self.PERSONAL_LEVEL_ELITE] = {};

	self:LoadSection(self.PERSONAL_LEVEL_NORMAL, "Setting/Fuben/PersonalFuben/NormalSection.tab");
	self:LoadSection(self.PERSONAL_LEVEL_ELITE, "Setting/Fuben/PersonalFuben/EliteSection.tab");

	self:LoadSectionSetting(self.tbAllSectionInfo, "Setting/Fuben/PersonalFuben/SectionSetting.tab");
end

function PersonalFuben:LoadSection(nFubenLevel, szPath)
	local tbMainSectionInfo = self.tbAllSectionInfo[nFubenLevel];
	local tbFile = LoadTabFile(szPath, "dddsssddsd", nil, {"nSectionIdx", "nSubSectionIdx", "nFubenIndex",
															"szTitle", "szUiTypeName", "szUiAtlas",
															"nType", "bFFHideUi", "ExtPosition",
															"nNeedTaskId"});

	for _, tbInfo in pairs(tbFile or {}) do
		local tbFubenInfo = self.tbAllFubenInfo[tbInfo.nFubenIndex];
		if not tbFubenInfo then
			Lib:LogTB(tbInfo);
			assert(false, "Fuben Section Setting ERR !!");
		end

		tbFubenInfo.tbSection[nFubenLevel] = {nSectionIdx = tbInfo.nSectionIdx, nSubSectionIdx = tbInfo.nSubSectionIdx};

		tbMainSectionInfo[tbInfo.nSectionIdx] = tbMainSectionInfo[tbInfo.nSectionIdx] or {};

		local tbSection = tbMainSectionInfo[tbInfo.nSectionIdx];
		tbSection.nMaxSubSectionIdx = math.max(tbSection.nMaxSubSectionIdx or 0, tbInfo.nSubSectionIdx);
		tbSection.tbSectionInfo = tbSection.tbSectionInfo or {};
		tbSection.tbSectionInfo[tbInfo.nSubSectionIdx] = tbSection.tbSectionInfo[tbInfo.nSubSectionIdx] or {};

		local tbSubSection = tbSection.tbSectionInfo[tbInfo.nSubSectionIdx];
		tbSubSection.szTitle = tbInfo.szTitle;
		tbSubSection.szUiTypeName = tbInfo.szUiTypeName;
		tbSubSection.szUiAtlas = tbInfo.szUiAtlas;
		tbSubSection.nFubenIndex = tbInfo.nFubenIndex;
		tbSubSection.nType = tbInfo.nType;
		tbSubSection.bFFHideUi = tbInfo.bFFHideUi;
		tbSubSection.nNeedTaskId = tbInfo.nNeedTaskId;

		if tbInfo.ExtPosition and tbInfo.ExtPosition ~= "" then
			local tbPos = Lib:SplitStr(tbInfo.ExtPosition, "|");
			tbSubSection.tbExtPosition = {};
			tbSubSection.tbExtPosition.nMapTemplateId = tonumber(tbPos[1]);
			tbSubSection.tbExtPosition.nX = tonumber(tbPos[2]);
			tbSubSection.tbExtPosition.nY = tonumber(tbPos[3]);
			tbSubSection.tbExtPosition.nDistance = tonumber(tbPos[4]);
			tbSubSection.tbExtPosition.nTaskId = tonumber(tbPos[5]);

			assert(tbSubSection.tbExtPosition.nMapTemplateId and tbSubSection.tbExtPosition.nX and tbSubSection.tbExtPosition.nY and tbSubSection.tbExtPosition.nDistance and tbSubSection.tbExtPosition.nTaskId);
		end
	end
end

function PersonalFuben:LoadSectionSetting(tbAllSectionInfo, szPath)
	local tbFile = LoadTabFile(szPath, "dddsssssss", "nSectionIdx", {"nSectionIdx", "nNormalNeedLevel", "nEliteNeedLevel", "szTitle", "szNormalAward_1", "szNormalAward_2", "szNormalAward_3", "szEliteAward_1", "szEliteAward_2", "szEliteAward_3"});

	for nSectionIdx, tbInfo in pairs(tbFile) do
		tbAllSectionInfo[self.PERSONAL_LEVEL_NORMAL][tbInfo.nSectionIdx] = tbAllSectionInfo[self.PERSONAL_LEVEL_NORMAL][tbInfo.nSectionIdx] or {};
		local tbNormalSection = tbAllSectionInfo[self.PERSONAL_LEVEL_NORMAL][tbInfo.nSectionIdx];

		tbAllSectionInfo[self.PERSONAL_LEVEL_ELITE][tbInfo.nSectionIdx] = tbAllSectionInfo[self.PERSONAL_LEVEL_ELITE][tbInfo.nSectionIdx] or {};
		local tbEliteSection = tbAllSectionInfo[self.PERSONAL_LEVEL_ELITE][tbInfo.nSectionIdx] or {};

		tbNormalSection.szTitle = tbInfo.szTitle;
		tbNormalSection.nNeedLevel = tbInfo.nNormalNeedLevel;

		tbEliteSection.szTitle = tbInfo.szTitle;
		tbEliteSection.nNeedLevel = tbInfo.nEliteNeedLevel;

		tbNormalSection.tbAllAward = {};
		tbEliteSection.tbAllAward = {};
		for i = 1, 3 do
			tbNormalSection.tbAllAward[i] = Lib:GetAwardFromString(tbInfo["szNormalAward_" .. i]);
			tbEliteSection.tbAllAward[i] = Lib:GetAwardFromString(tbInfo["szEliteAward_" .. i]);
		end
	end
end

PersonalFuben:Load();

function PersonalFuben:GetPersonalFubenInfo(nFubenIndex)
	return self.tbAllFubenInfo[nFubenIndex];
end

function PersonalFuben:GetMaxSectionCount(nFubenLevel)
	return #(self.tbAllSectionInfo[nFubenLevel] or {});
end

function PersonalFuben:GetSectionInfo(nSectionIdx, nFubenLevel)
	return (self.tbAllSectionInfo[nFubenLevel] or {})[nSectionIdx];
end

function PersonalFuben:GetSectionIdx(nFubenIndex, nFubenLevel)
	if not nFubenIndex or nFubenIndex == 0 then
		return 0, 0;
	end

	local tbFubenInfo = self:GetPersonalFubenInfo(nFubenIndex);
	if not tbFubenInfo or not tbFubenInfo.tbSection[nFubenLevel] then
		Log(string.format("PersonalFuben:GetSectionIdx ?? tbFubenInfo or tbFubenInfo.tbSection[nFubenLevel] is nil !! nFubenIndex = %d, nFubenLevel = %d", nFubenIndex, nFubenLevel));
		return;
	end

	return tbFubenInfo.tbSection[nFubenLevel].nSectionIdx, tbFubenInfo.tbSection[nFubenLevel].nSubSectionIdx;
end

function PersonalFuben:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
	if not tbSection then
		return;
	end

	return tbSection.tbSectionInfo[nSubSectionIdx].nFubenIndex;
end

function PersonalFuben:GetSectionName(nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
	if not tbSection or not tbSection.tbSectionInfo or not tbSection.tbSectionInfo[nSubSectionIdx] then
		return;
	end

	return tbSection.tbSectionInfo[nSubSectionIdx].szTitle;
end

function PersonalFuben:GetNextFubenSection(nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
	if not tbSection then
		Log("PersonalFuben:GetNextFubenSection ERR ?? tbSection is nil !!");
		return;
	end

	nSubSectionIdx = nSubSectionIdx + 1;
	if nSubSectionIdx > tbSection.nMaxSubSectionIdx then
		nSectionIdx = nSectionIdx + 1;
		nSubSectionIdx = 1;
	end

	return nSectionIdx, nSubSectionIdx;
end

function PersonalFuben:GetRevivePrice(nFubenIndex, nFubenLevel, nReviveCount)
	local tbSetting = self:GetPersonalFubenInfo(nFubenIndex);
	if not tbSetting then
		Log("[PersonalFuben] PersonalFuben:GetRevivePrice ERR ?? tbSetting is nil !!", nFubenIndex, nFubenLevel);
		return false, "对应关卡不存在，无法重生！";
	end

	if nReviveCount >= self.PERSONAL_MAX_REVIVE_TIMES then
		return false, "重生已达最大次数，无法重生！";
	end

	return 10 * (nReviveCount + 1);
end

function PersonalFuben:GetTimeLimite(nFubenIndex, nFubenLevel)
	local tbFubenInfo = PersonalFuben:GetPersonalFubenInfo(nFubenIndex);
	return unpack(tbFubenInfo.tbStarTimeLimite[nFubenLevel]);
end

function PersonalFuben:SetPersonalFubenData(tbData)
	if MODULE_GAMESERVER then
		return;
	end

	local tbPersonalFubenData = me.GetScriptTable("PersonalFuben");
	for k, v in pairs(tbData) do
		tbPersonalFubenData[k] = v;
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_SECTION_PANEL, "UpdatePersonalFubenInfo");
end

function PersonalFuben:GetPersonalFubenData(pPlayer)
	local tbPersonalFubenData = pPlayer.GetScriptTable("PersonalFuben");
	tbPersonalFubenData.tbTimesInfo = tbPersonalFubenData.tbTimesInfo or {};
	tbPersonalFubenData.nDate = tbPersonalFubenData.nDate or 0;

	local nToday = Lib:GetLocalDay();
	if tbPersonalFubenData.nDate < nToday then
		tbPersonalFubenData.tbTimesInfo = {};
		tbPersonalFubenData.nDate = nToday;
	end

	return tbPersonalFubenData;
end

function PersonalFuben:GetPlayerFubenRecord(pPlayer)
	local tbPersonalFubenData = self:GetPersonalFubenData(pPlayer);
	local tbMaxRecord = Lib:InitTable(tbPersonalFubenData, "tbRecord", "tbMaxRecord");
	local tbMaxFubenInfo = Lib:InitTable(tbPersonalFubenData, "tbRecord", "tbMaxFubenInfo");

	tbMaxRecord[self.PERSONAL_LEVEL_ELITE] = tbMaxRecord[self.PERSONAL_LEVEL_ELITE] or 0;
	tbMaxRecord[self.PERSONAL_LEVEL_NORMAL] = tbMaxRecord[self.PERSONAL_LEVEL_NORMAL] or 0;

	tbMaxFubenInfo[self.PERSONAL_LEVEL_NORMAL] = tbMaxFubenInfo[self.PERSONAL_LEVEL_NORMAL] or {nSectionIdx = 1, nSubSectionIdx = 1};
	tbMaxFubenInfo[self.PERSONAL_LEVEL_ELITE] = tbMaxFubenInfo[self.PERSONAL_LEVEL_ELITE] or {nSectionIdx = 1, nSubSectionIdx = 1};

	return tbPersonalFubenData.tbRecord;
end

-- 记录当前关卡最高星级，当前通关最高关卡
function PersonalFuben:SetRecord(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, nStarLevel)
	local tbRecord = self:GetPlayerFubenRecord(pPlayer);
	local tbStarInfo = Lib:InitTable(tbRecord, "tbStarInfo", nFubenLevel, nSectionIdx);
	local nLastStar = self:GetFubenStarLevel(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	tbStarInfo[nSubSectionIdx] = math.max(nLastStar, nStarLevel);
	if tbStarInfo[nSubSectionIdx] == 3 then
		tbStarInfo[nSubSectionIdx] = nil;
		if Lib:CountTB(tbStarInfo) <= 0 then
			tbRecord.tbStarInfo[nFubenLevel][nSectionIdx] = nil;
		end
	end

	tbRecord.tbMaxRecord = tbRecord.tbMaxRecord or {};
	tbRecord.tbMaxRecord[nFubenLevel] = tbRecord.tbMaxRecord[nFubenLevel] or 0;
	tbRecord.tbMaxRecord[nFubenLevel] = math.max(tbRecord.tbMaxRecord[nFubenLevel], nSectionIdx * 100 + nSubSectionIdx);

	if MODULE_GAMESERVER then
		pPlayer.CallClientScriptWhithPlayer("PersonalFuben:SetRecord", nSectionIdx, nSubSectionIdx, nFubenLevel, tbStarInfo[nSubSectionIdx] or 3);
	else
		if nLastStar == 0 and nStarLevel > 0 then
			local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
			local tbSubSection = (tbSection or {}).tbSectionInfo;
			if tbSubSection and tbSubSection[nSubSectionIdx] and
				tbSubSection[nSubSectionIdx].bFFHideUi and tbSubSection[nSubSectionIdx].bFFHideUi == 1 then

				Ui:CloseWindow("FubenSectionPanel");
			end

			Guide.tbNotifyGuide:CheckStartFubenGuide(nSectionIdx, nSubSectionIdx)
		end
	end

	return nLastStar < 3 and nStarLevel >= 3;
end

function PersonalFuben:SetStarAwardFlag(pPlayer, nSectionIdx, nFubenLevel, nIndex)
	local tbRecord = self:GetPlayerFubenRecord(pPlayer);
	local nFlagIdx = self:GetStarFlagIdx(nSectionIdx, nFubenLevel, nIndex);
	tbRecord.tbStarAward = tbRecord.tbStarAward or {};
	tbRecord.tbStarAward[nFlagIdx] = 1;

	if MODULE_GAMESERVER then
		pPlayer.CallClientScriptWhithPlayer("PersonalFuben:SetStarAwardFlag", nSectionIdx, nFubenLevel, nIndex);
	end
end

function PersonalFuben:GetStarFlagIdx(nSectionIdx, nFubenLevel, nIndex)
	return nIndex + (nFubenLevel * 10) + (nSectionIdx * 1000);
end

function PersonalFuben:GetAllSectionStarAllLevel(pPlayer)
    local nTotalStart = PersonalFuben:GetAllSectionStarLevel(pPlayer, PersonalFuben.PERSONAL_LEVEL_NORMAL);
    local nTotalStart1 = PersonalFuben:GetAllSectionStarLevel(pPlayer, PersonalFuben.PERSONAL_LEVEL_ELITE);
    return nTotalStart + nTotalStart1;
end

function PersonalFuben:GetAllSectionStarLevel(pPlayer, nFubenLevel)
	local nTotal = 0;
    for i = 1, 100 do
    	local nSNumber = self:GetSectionTotalStarLevel(pPlayer, i, nFubenLevel);
    	if nSNumber <= 0 then
    		break;
    	end

    	nTotal = nTotal + nSNumber;
    end

    return nTotal;
end

function PersonalFuben:GetSectionTotalStarLevel(pPlayer, nSectionIdx, nFubenLevel)
	local nTotalStar = 0;
	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel) or {};
	for nSubSectionIdx, _ in pairs(tbSection.tbSectionInfo or {}) do
		nTotalStar = nTotalStar + self:GetFubenStarLevel(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	end

	return nTotalStar;
end

function PersonalFuben:GetFubenStarLevel(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbRecord = self:GetPlayerFubenRecord(pPlayer);
	local nCurIdx = nSectionIdx * 100 + nSubSectionIdx;

	if not tbRecord.tbStarInfo or not tbRecord.tbStarInfo[nFubenLevel] then
		return 0;
	end

	if nCurIdx > tbRecord.tbMaxRecord[nFubenLevel] then
		return 0;
	end

	if not tbRecord.tbStarInfo[nFubenLevel][nSectionIdx] or not tbRecord.tbStarInfo[nFubenLevel][nSectionIdx][nSubSectionIdx] then
		return 3;
	end

	return tbRecord.tbStarInfo[nFubenLevel][nSectionIdx][nSubSectionIdx] or 0;
end

function PersonalFuben:GetTimesInfo(nFubenIndex, nFubenLevel)
	local tbSetting = self:GetPersonalFubenInfo(nFubenIndex) or {};
	tbSetting.tbFreeTimesInfo = tbSetting.tbFreeTimesInfo or {};
	return tbSetting.tbFreeTimesInfo[nFubenLevel] or 0;
end

function PersonalFuben:GetFubenTimesData(pPlayer, nFubenIndex, nFubenLevel)
	local tbPersonalFubenData = self:GetPersonalFubenData(pPlayer);
	local tbFubenData = Lib:InitTable(tbPersonalFubenData, "tbTimesInfo", nFubenIndex, nFubenLevel);

	if not tbFubenData.nLastAvailable then
		tbFubenData.nLastAvailable = self:GetTimesInfo(nFubenIndex, nFubenLevel);
	end

	tbFubenData.nResetTimes = tbFubenData.nResetTimes or 0;
	return tbFubenData;
end

function PersonalFuben:TryCostFubenTimes(pPlayer, nFubenIndex, nFubenLevel, nCostTimes)
	nCostTimes = nCostTimes or 1;

	local tbFubenData = self:GetFubenTimesData(pPlayer, nFubenIndex, nFubenLevel);
	if tbFubenData.nLastAvailable < nCostTimes then
		return false, "剩余次数不足，扣除失败！", self.tbErr.Times_Err;
	end

	tbFubenData.nLastAvailable = tbFubenData.nLastAvailable - nCostTimes;
	PersonalFuben:SyncFubenTimes(pPlayer, nFubenIndex, nFubenLevel);
	return true;
end

function PersonalFuben:SyncFubenTimes(pPlayer, nFubenIndex, nFubenLevel)
	if not MODULE_GAMESERVER then
		return;
	end

	local tbFubenData = self:GetFubenTimesData(pPlayer, nFubenIndex, nFubenLevel);
	pPlayer.CallClientScript("PersonalFuben:OnSyncFubenTimes", nFubenIndex, nFubenLevel, tbFubenData.nLastAvailable, tbFubenData.nResetTimes);
end

-- 此处为共用检查，一般为一些硬性条件，比如前置关卡，等级限制之类的，通过此处检查，一般ui可显示为玩家可进入关卡
function PersonalFuben:CanCreateFubenCommon(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
	if not tbSection then
		return false, "此章节暂未开放";
	end

	local tbSubSection = tbSection.tbSectionInfo[nSubSectionIdx];
	if not tbSubSection then
		return false, "无对应章节！";
	end

	if pPlayer.nLevel < (tbSection.nNeedLevel or 99) then
		return false, string.format("角色等级 [FFFE0D]%s[-] 级才能解锁该章节", tbSection.nNeedLevel or 99);
	end

	local nFubenIndex = self:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not nFubenIndex then
		return false, "无此对应关卡！";
	end

	local tbSetting = self:GetPersonalFubenInfo(nFubenIndex);
	if not tbSetting then
		return false, "无此类型关卡！";
	end

	local nMapTemplateId = tbSetting.nMapTemplateId;
	local tbFubenSetting = Fuben.tbFubenSetting[nMapTemplateId];
	if not nMapTemplateId or not Fuben.tbFubenTemplate[nMapTemplateId] or not tbFubenSetting then
		return false, "关卡配置错误！";
	end

	if not pPlayer.bIgnoreFubenTask and tbSubSection.nNeedTaskId > 0 and Task:GetTaskFlag(pPlayer, tbSubSection.nNeedTaskId) ~= 1 then
		local tbTask = Task:GetTask(tbSubSection.nNeedTaskId) or {szTaskTitle = "???"};
		return false, string.format("请先完成主线任务 %s", tbTask.szTaskTitle);
	end

	if pPlayer.nLevel < tbSetting.nNeedLevel then
		return false, string.format("角色等级需要达到 [FFFE0D]%d[-] 级才能解锁该章节 ", tbSetting.nNeedLevel);
	end

	return true, "", tbSetting, nFubenIndex;
end

function PersonalFuben:CheckPosition(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	if MODULE_GAMESERVER then
		if pPlayer.nState == Player.emPLAYER_STATE_ALONE then
			local tbFubenData = self:GetCurrentFubenData(pPlayer);
			if Lib:CountTB(tbFubenData) ~= 0 then
				return false;
			end
		end
	else
		local tbFuben = Fuben:GetFubenInstance(me);
		if tbFuben and tbFuben.bClose == 0 then
			return false;
		end
	end

	if Fuben.tbSafeMap[pPlayer.nMapTemplateId] then
		return true;
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode == 0 then
		return true;
	end

	local tbSection = self:GetSectionInfo(nSectionIdx, nFubenLevel);
	if not tbSection or not tbSection.tbSectionInfo[nSubSectionIdx] then
		return false;
	end

	local tbExtPosition = tbSection.tbSectionInfo[nSubSectionIdx].tbExtPosition;
	if not tbExtPosition or tbExtPosition.nMapTemplateId ~= pPlayer.nMapTemplateId then
		return false;
	end

	local tbCurTask = Task:GetPlayerTaskInfo(pPlayer, tbExtPosition.nTaskId);
	if not tbCurTask then
		return false;
	end

	local _, nX, nY = pPlayer.GetWorldPos();
	local divX, divY = nX - tbExtPosition.nX, nY - tbExtPosition.nY;
	return divX * divX + divY * divY <= tbExtPosition.nDistance * tbExtPosition.nDistance;
end

function PersonalFuben:CheckCanCreateFuben(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local bRet, szMsg, tbSetting, nFubenIndex = self:CanCreateFubenCommon(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not bRet then
		return false, szMsg;
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_PersonalFuben) then
		return false, "当前状态不允许进入活动";
	end

	if not PersonalFuben:CheckPosition(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel) then
			return false, "只有在主城、忘忧岛、野外地图安全区范围内方可开启关卡";
		end

	local pPlayerNpc = pPlayer.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "当前状态不能参加";
	end

	local bRet, szMsg = pPlayer.CheckNeedArrangeBag();
	if bRet then
		return false, szMsg;
	end

	local tbTimesData = self:GetFubenTimesData(pPlayer, nFubenIndex, nFubenLevel);
	if tbTimesData.nLastAvailable <= 0 then
		return false, string.format("该关卡今日的参与次数已经耗尽啦！请明日再来！"), self.tbErr.Times_Err;
	end

	return true, "", tbSetting.nMapTemplateId, Fuben.tbFubenSetting[tbSetting.nMapTemplateId];
end

function PersonalFuben:CheckMultiSweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel)
	local bRet, szMsg, nFubenIndexOrErrCode, pItem, nNeedGold, nAvailableTimes, bUseGold = self:CheckCanSweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel);
	if not bRet then
		return false, szMsg, nFubenIndexOrErrCode;
	end

	return false, "功能已关闭";
end

function PersonalFuben:CheckCanSweep(pPlayer, nSectionIdx, nSubSectionIdx, nFubenLevel, bNotCheckBag)
	return false, "功能已关闭";
end

function PersonalFuben:CalcFubenStarLevel(nFubenIndex, nFubenLevel, tbClientData)
	return 3;
end

function PersonalFuben:GetCurFubenInstance()
	return Fuben.tbFubenInstance[me.nMapId];
end

function PersonalFuben:OnLeaveSucess()
	if MODULE_GAMESERVER then
		return;
	end

	Ui:CloseWindow("LoadingTips");
	self:CloseUI();
end

function PersonalFuben:ProcessErr(pPlayer, nErrCode, tbParam)
	if not nErrCode or not self.tbErrCode[nErrCode] then
		return;
	end

	tbParam = tbParam or {};
	if tbParam.nSectionIdx and tbParam.nSubSectionIdx and tbParam.nFubenLevel then
		tbParam.nFubenIndex = self:GetFubenIndex(tbParam.nSectionIdx, tbParam.nSubSectionIdx, tbParam.nFubenLevel);
	end
	if nErrCode == self.tbErr.Gold_Err then
		pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
		return false;
	elseif nErrCode == self.tbErr.SweepItem_Err then
		local nSweepTimes = tbParam.nSweepTimes or 1;
		local nCost = self.PERSONAL_SWEEP_COST_GOLD * nSweepTimes;

		local function fnSweep()
			if me.GetMoney("Gold") < nCost then
				me.CenterMsg("元宝不足！");
				me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
				return;
			end

			if MODULE_GAMESERVER then
				if nSweepTimes <= 1 then
					c2s:TrySweep(tbParam.nSectionIdx, tbParam.nSubSectionIdx, tbParam.nFubenLevel);
				else
					c2s:TryMultiSweep(tbParam.nSectionIdx, tbParam.nSubSectionIdx, tbParam.nFubenLevel);
				end
				return;
			end

			Ui:OpenWindow("ShowAward")
			if nSweepTimes <= 1 then
				RemoteServer.TrySweep(tbParam.nSectionIdx, tbParam.nSubSectionIdx, tbParam.nFubenLevel);
			else
				RemoteServer.TryMultiSweep(tbParam.nSectionIdx, tbParam.nSubSectionIdx, tbParam.nFubenLevel);
			end
		end

		local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
		local szMsgBoxKey = nSweepTimes > 1 and "MultiSweepUseGold" or "OnceSweepUseGold"
		pPlayer.MsgBox(string.format("扫荡券不足，是否消耗%s %s 元宝进行扫荡？", nCost, szMoneyEmotion), {{"确认", fnSweep, self, true}, {"取消"}}, szMsgBoxKey);
	elseif nErrCode == self.tbErr.VipLevel_Err then
		pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
		return false;
	else
		return false;
	end

	return true;
end

function PersonalFuben:SetIgnoreFubenTask()
	me.bIgnoreFubenTask = true;
	if MODULE_GAMESERVER then
		me.CallClientScript("PersonalFuben:SetIgnoreFubenTask");
	end
end

function PersonalFuben:UnlockFuben()
	local nMainSection = 7;
	local nMaxSubSectionIdx = 7;
	local nCMS, nCSS = 1, 1;

	self:SetIgnoreFubenTask();
	while nCMS and nCSS and nMainSection * 100 + nMaxSubSectionIdx > nCMS * 100 + nCSS do
		if not self:CanCreateFubenCommon(me, nCMS, nCSS, PersonalFuben.PERSONAL_LEVEL_NORMAL) or
			self:GetFubenStarLevel(me, nCMS, nCSS, PersonalFuben.PERSONAL_LEVEL_NORMAL) < 1 then

			self:SetRecord(me, nCMS, nCSS, PersonalFuben.PERSONAL_LEVEL_NORMAL, 1);
			self:SetRecord(me, nCMS, nCSS, PersonalFuben.PERSONAL_LEVEL_ELITE, 1);
		end

		nCMS, nCSS = self:GetNextFubenSection(nCMS, nCSS, PersonalFuben.PERSONAL_LEVEL_NORMAL);
	end
end

function PersonalFuben:GetAwardInfo(tbLocalAward)
	local tbAllAward = {};
	for _, tbAward in pairs(tbLocalAward) do
		for szType, tbInfo in pairs(tbAward) do
			if szType == "tbItem" then
				for nItemId, nItemCount in pairs(tbInfo) do
					table.insert(tbAllAward, {"item", nItemId, nItemCount});
				end
			elseif szType == "tbWithSubTypeAward" then
				for szMainType, tbAllSubInfo in pairs(tbInfo) do
					local tbSubCount = {};
					for _, tbSubInfo in pairs(tbAllSubInfo) do
						tbSubCount[tbSubInfo[1]] = tbSubCount[tbSubInfo[1]] or 0;
						tbSubCount[tbSubInfo[1]] = tbSubCount[tbSubInfo[1]] + tbSubInfo[2];
					end

					for SubType, nCount in pairs(tbSubCount) do
						table.insert(tbAllAward, {szMainType, SubType, nCount});
					end
				end
			else
				local nType = Player.AwardType[szType] or Player.award_type_unkonw;
				if nType == Player.award_type_exp or
					nType == Player.award_type_money or
					nType == Player.award_type_basic_exp then

					local nTotal = 0;
					for _, nCount in pairs(tbInfo) do
						nTotal = nTotal + nCount;
					end

					table.insert(tbAllAward, {szType, nTotal});
				else
					for _, nCount in pairs(tbInfo) do
						table.insert(tbAllAward, {szType, nCount});
					end
				end
			end
		end
	end

	return tbAllAward;
end

