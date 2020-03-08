--任务抽取
-- {
-- 	[1] = {
-- 		nMinLevel = 1,
-- 		[1] = 
-- 		{
-- 			[1] = {Type = "Item", TemplateId = 110, Count = 3, Prob = 10},
-- 			[2] = {Type = "Gather", TemplateId = 110, Count = 3, Prob = 20},
-- 		}
-- 		[2] = ...
-- 		[3] = ...
-- }
-- 	[2] = { nMinLevel = 40}
-- 	[3] = { nMinLevel = 50}
-- }

--奖励
-- {
-- 	[1] =  {
-- 		nMinLevel = 1,
-- 		tbReward = {
--
-- 			[1] = {szType = "TongBao", nCount = 100},
-- 			[2] = {szType = "Item", nTemplateId = 120, nCount = 1},
-- 			[3] = {szType = "Item", nTemplateId = 122, nCount = 1, nProb = 30},
--		}
-- 	}
-- }

--玩家身上的数据
-- {
--  nTime = 2014540,
--  bFinish = true,
--  bGiveUp = false,
--  nLevel = 20, --接受任务时的等级

--  tbTask = {
--		[1] = {nTaskId = 1, bFinish = false, nGain = 0};
-- 		[2] = {},
-- 		...
-- 		[10] ...
-- 	}
-- }

-- 异步数据
-- {
-- 	[24] = 110 -- nTaskId, 0没有，-1已被协助完成
-- 	[25] = 
-- 	[26]
-- }

CommerceTask.HELP_IMITITY = 30; --帮忙装货增加亲密度

CommerceTask.TIME_FRAME = "OpenDay2";

function CommerceTask:LoadCommerceGather()
	local tbGahterRefresh = LoadTabFile(
		"Setting/Task/CommerceGatherRefresh.tab",
		"ddddddddddddddddddddddddd", "GatherID",
		{"GatherID",	"Clock0", "Clock1", "Clock2", "Clock3",	"Clock4", "Clock5", "Clock6", 
		"Clock7", "Clock8", "Clock9", "Clock10", "Clock11", "Clock12", "Clock13", "Clock14", 
		"Clock15", "Clock16", "Clock17", "Clock18", "Clock19", "Clock20", "Clock21", "Clock22", "Clock23"});

	self.tbGahterRefresh = tbGahterRefresh;
end
CommerceTask:LoadCommerceGather();

function CommerceTask:GetRefreshInterval(nGatherId)
	local tbSetting = self.tbGahterRefresh[nGatherId];
	if tbSetting then
		local nHour = Lib:GetLocalDayHour();
		return tbSetting["Clock"..nHour] * 60;
	else
		Log("ERROR IN CommerceTask:GetRefreshInterval(nGatherId)", nGatherId)
	end
end

function CommerceTask:ResolveGatherParam(szParam)
	local _, _, szType, nMatureId, nUnMatureId, nMatureTime = string.find(szParam, "^(.-)|(.-)|(.-)|(.-)$");
	local bMuture = szType == "m";
	nMatureId = tonumber(nMatureId);
	nMatureTime = tonumber(nMatureTime);	
	nUnMatureId = tonumber(nUnMatureId);

	return bMuture, nMatureId, nUnMatureId, nMatureTime;
end

--抽取任务
function CommerceTask:LoadCommerceTaskSetting()
	local tbTaskSetting = LoadTabFile(
		"Setting/Task/CommerceTask.tab", 
		"dddsdddsddsdd", "TaskId", 
		{"TaskId", "MinLevel", "Pool", "Type", "TemplateId", "Count", "Prob",
		"RewardType1", "RewardId1", "RewardCount1", "RewardType2", "RewardId2", "RewardCount2"});

	self.tbTaskSetting = {};
	local tb1 = {};
	for _,v in pairs(tbTaskSetting) do
		tb1[v.MinLevel] = tb1[v.MinLevel] or {};
		tb1[v.MinLevel]["nMinLevel"] = v.MinLevel;
		tb1[v.MinLevel][v.Pool] = tb1[v.MinLevel][v.Pool] or {};

		local tbFormatData = {
			nTaskId = v.TaskId,
			nMinLevel = v.MinLevel,
			nPool = v.Pool,
			szType = v.Type,
			nTemplateId = v.TemplateId,
			nCount = v.Count,
			nProb = v.Prob,

			szRewardType1 = v.RewardType1,
			nRewardId1 = v.RewardId1,
			nRewardCount1 = v.RewardCount1,
			szRewardType2 = v.RewardType2,
			nRewardId2 = v.RewardId2,
			nRewardCount2 = v.RewardCount2,
		};

		table.insert(tb1[v.MinLevel][v.Pool], tbFormatData);
		self.tbTaskSetting[v.TaskId] = tbFormatData;
	end

	local tb2 = {};
	for k,v in pairs(tb1) do
		table.insert(tb2, v);
	end

	table.sort(tb2, function (item1, item2)
		return item1.nMinLevel < item2.nMinLevel;
	end)

	self.tbTaskPickSetting = tb2;
end
CommerceTask:LoadCommerceTaskSetting();

--等级任务配置
function CommerceTask:GainLevelTask(nLevel)
	local nLen = #self.tbTaskPickSetting;
	for i = 1, nLen do
		local tbLevelTask = self.tbTaskPickSetting[i];
		if nLevel >= tbLevelTask.nMinLevel then
			if i == nLen or nLevel < self.tbTaskPickSetting[i + 1].nMinLevel then
				return tbLevelTask;
			end
		end
	end
end

function CommerceTask:GetTaskSetting(nTaskId)
	return self.tbTaskSetting[nTaskId];
end


--1 可接任务（无任务） 2.不可接任务（无任务） 3.任务进行中（有任务）  
function CommerceTask:GetCommerceTaskState(pPlayer)
	local tbCommerceData;
	if MODULE_GAMESERVER then
		tbCommerceData = self:GetTaskInfo(pPlayer);
	else
		tbCommerceData = self.tbCommerceData or {};
	end

	local nTime = tbCommerceData.nTime;
	local bFinish = tbCommerceData.bFinish;
	local bGiveUp = tbCommerceData.bGiveUp;
    local bTodayTask = not Lib:IsDiffDay(self.COMMERCE_TASK_REFRESH, nTime or 0);

	if (not nTime) or (not bTodayTask and (bFinish == true or bGiveUp == true )) then --以前的任务已经结束了 可接任务
		return 1;
	elseif bTodayTask and bGiveUp == true then -- 当天任务放弃 不可接任务
		return 2;
	elseif bTodayTask and tbCommerceData.bFinish == true then -- 当天已完成 不可接任务
		return 2, true;
	else
		return 3; --任务进行中
	end
end

function CommerceTask:IsDoingTask(pPlayer)
	return self:GetCommerceTaskState(pPlayer) == 3;
end

function CommerceTask:IsFinishTodayTask(pPlayer)
	local nState, bFinish = self:GetCommerceTaskState(pPlayer)
	return nState == 2 and bFinish
end

function CommerceTask:IsGiveupTodyTask(pPlayer)
	local nState, bFinish = self:GetCommerceTaskState(pPlayer)
	return nState == 2 and not bFinish
end

function CommerceTask:CanAcceptTask(pPlayer)
	return self:GetCommerceTaskState(pPlayer) == 1;
end

function CommerceTask:GetRemainHelpCount(tbHelp)
	local nFree = 0;
	local nHelpCount = math.floor((#tbHelp)/2)
	for i = 1, nHelpCount do
		if tbHelp[i] == 0 then
			nFree = nFree + 1;
		end
	end
	return nFree;
end

function CommerceTask:CanAskHelp(tbHelp, tbTask, nTaskId)
	local nFree = 0;
	local nSame = 0;

	local nHelpCount = math.floor((#tbHelp)/2)
	for i = 1, nHelpCount do
		local nSaveTaskId = tbHelp[i];
		if nSaveTaskId == 0 then
			nFree = nFree + 1;
		end
		if nSaveTaskId == nTaskId then
			nSame = nSame + 1;
		end
	end

	if nFree == 0 then
		return false, "剩余求助次数为0";
	end

	local nUnFinish = 0;
	for k,v in pairs(tbTask) do
		if v.nTaskId == nTaskId and  (not v.bFinish) then
			nUnFinish = nUnFinish + 1;
		end
	end

	if nUnFinish <= nSame then
		return false, "已经发布了";
	end

	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	if tbTaskSetting.szType ~= "Item" then
		return false, "道具才可以求助";
	end

	return true;
end

function CommerceTask:IsTimeFrameOpen()
	return GetTimeFrameState(self.TIME_FRAME) == 1;
end


-- ----------------------Reward--------------------------
function CommerceTask:FormatReward(szType, nTemplateId, nCount)
	local tbRet = {}
	if nTemplateId and nTemplateId ~= 0  then
		tbRet = {szType, nTemplateId, nCount};
	else
		tbRet = {szType, nCount};
	end
	return tbRet;
end


function CommerceTask:FormatItem(szType, nTemplateId, nCount)
    local szText = "";
    if nTemplateId and nTemplateId ~= 0 then
        local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);  
        szText = string.format("%s x%d", tbBaseInfo.szName, nCount);
    else
        szText = Shop:GetMoneyName(szType) .. "x" .. nCount ;
    end
    return szText;
end

--判断采集物是否在玩家任务中
function CommerceTask:GatherThingInTask(pPlayer, nTemplateId)
	if not self:IsDoingTask(pPlayer) then
		return
	end

	local tbCommerceData;

	if MODULE_GAMESERVER then
	 	tbCommerceData = self:GetTaskInfo(pPlayer);
	else
	 	tbCommerceData = self.tbCommerceData;
	end

	if tbCommerceData.tbTask then
		for k,v in pairs(tbCommerceData.tbTask) do
			local nTaskId = v.nTaskId;
			local tbSetting = self:GetTaskSetting(nTaskId);

			if not v.bFinish and tbSetting.szType == "Gather" and
			 tbSetting.nTemplateId == nTemplateId and v.nGain < tbSetting.nCount then
				return true;
			end
		end
	end
	return false;
end

function CommerceTask:IsCommerceGather(nGatherId)
	local tbSetting = self.tbCommerceSetting[nGatherId]
	return tbSetting and true or false
end

function CommerceTask:GetAllCompleteAward(pPlayer)
	return pPlayer.nLevel >= 60 and self.ALL_COMPLETE_AWARD_A60 or self.ALL_COMPLETE_AWARD_B60
end

-----------------------------任务协助相关----------------------------------
function CommerceTask:LoadContribution()
	self.tbHelpInfo = {}
	local tbSettting = LoadTabFile("Setting/Task/CommerceTaskHelp.tab", "ddd", nil, { "ItemID", "AddNum", "HelpNeedCoin" })
	for _, tbInfo in pairs(tbSettting) do
		assert(not self.tbHelpInfo[tbInfo.ItemID], "[CommerceTask LoadContribution] Error ItemID Repeat", tbInfo.ItemID)

		self.tbHelpInfo[tbInfo.ItemID] = { nAddConNum = tbInfo.AddNum, nNeedCoin = tbInfo.HelpNeedCoin }
	end
end
CommerceTask:LoadContribution()

function CommerceTask:GetAddContributionCount(nItemID)
	local tbInfo = self.tbHelpInfo[nItemID] or {}
	local nAddCount = tbInfo.nAddConNum or 0
	return nAddCount
end

function CommerceTask:GetHelpNeedCoin(nItemID)
	local tbInfo = self.tbHelpInfo[nItemID]
	if not tbInfo then
		return
	end

	local nNeed = tbInfo.nNeedCoin
	return nNeed
end

function CommerceTask:GetHelpTimes(pPlayer)
	local nVipLevel  = pPlayer.GetVipLevel()
	local nHelpTimes = 0
	local nNextVip   = 0
	for _, tbInfo in ipairs(self.tbVipHelpTimes) do
		local nLevel = tbInfo[1]
		local nTimes = tbInfo[2]
		if nLevel > nVipLevel then
			nNextVip = nLevel
			break
		end

		nHelpTimes = nTimes
	end

	return nHelpTimes, nNextVip
end
---------------------------------------------------------------------------

function CommerceTask:GetAskHelpCount(nVipLevel)
	local nCount = self.MAX_HELP_COUNT
	return nVipLevel >= self.nHelpTimesVipLv and nCount + 1 or nCount
end

function CommerceTask:GetHelpAsynSaveInfo(nIdx)
	return unpack(self.tbHelpAsynDataKey[nIdx])
end