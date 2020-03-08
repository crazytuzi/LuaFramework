function KinDinnerParty:LoadTaskSetting()
	local tbTaskSetting = LoadTabFile(
		"Setting/Task/KinDPTask.tab", 
		"dddsdddsddsdd", "TaskId", 
		{"TaskId", "MinLevel", "Pool", "Type", "TemplateId", "Count", "Prob",
		"RewardType1", "RewardId1", "RewardCount1", "RewardType2", "RewardId2", "RewardCount2"});

	self.tbTaskSetting = {};
	for _,v in pairs(tbTaskSetting) do
		self.tbTaskSetting[v.TaskId] = {
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
		}
	end
end
KinDinnerParty:LoadTaskSetting()

function KinDinnerParty:LoadCommerceGather()
	local tbGahterRefresh = LoadTabFile(
		"Setting/Task/KinDPGatherRefresh.tab",
		"ddddddddddddddddddddddddd", "GatherID",
		{"GatherID",	"Clock0", "Clock1", "Clock2", "Clock3",	"Clock4", "Clock5", "Clock6", 
		"Clock7", "Clock8", "Clock9", "Clock10", "Clock11", "Clock12", "Clock13", "Clock14", 
		"Clock15", "Clock16", "Clock17", "Clock18", "Clock19", "Clock20", "Clock21", "Clock22", "Clock23"});

	self.tbGahterRefresh = tbGahterRefresh;
end
KinDinnerParty:LoadCommerceGather();

function KinDinnerParty:GetRefreshInterval(nGatherId)
	local tbSetting = self.tbGahterRefresh[nGatherId];
	if tbSetting then
		local nHour = Lib:GetLocalDayHour();
		return tbSetting["Clock"..nHour] * 60;
	else
		Log("ERROR IN KinDinnerParty:GetRefreshInterval(nGatherId)", nGatherId)
	end
end

function KinDinnerParty:ResolveGatherParam(szParam)
	local _, _, szType, nMatureId, nUnMatureId, nMatureTime = string.find(szParam, "^(.-)|(.-)|(.-)|(.-)$");
	local bMuture = szType == "m";
	nMatureId = tonumber(nMatureId);
	nMatureTime = tonumber(nMatureTime);	
	nUnMatureId = tonumber(nUnMatureId);

	return bMuture, nMatureId, nUnMatureId, nMatureTime;
end

function KinDinnerParty:GetTaskSetting(nTaskId)
	return self.tbTaskSetting[nTaskId];
end

--判断采集物是否在玩家任务中
function KinDinnerParty:GatherThingInTask(pPlayer, nTemplateId)
	if not self:IsDoingTask(pPlayer) then
		return
	end

	local tbTask;

	if MODULE_GAMESERVER then
	 	tbTask = self:GetTaskInfo(pPlayer);
	else
	 	tbTask = self.tbTask;
	end

	for k,v in pairs(tbTask.tbTask or {}) do
		local nTaskId = v.nTaskId;
		local tbSetting = self:GetTaskSetting(nTaskId);

		if not v.bFinish and tbSetting.szType == "Gather" and
		 tbSetting.nTemplateId == nTemplateId and v.nGain < tbSetting.nCount then
			return true;
		end
	end
	return false;
end

--1 可接任务（无任务） 2.不可接任务（无任务） 3.任务进行中（有任务）  
function KinDinnerParty:GetTaskState(pPlayer)
	local tbTask;
	if MODULE_GAMESERVER then
		--tbTask = self:GetTaskInfo(pPlayer);
		tbTask = self.tbTask or {};
	else
		tbTask = self.tbTask or {};
	end

	if tbTask and tbTask.tbTask and not tbTask.bGiveUp and not tbTask.bFinished then
		return 3
	else
		return 2
	end
end

function KinDinnerParty:IsDoingTask(pPlayer)
	return self:GetTaskState(pPlayer) == 3
end

function KinDinnerParty:IsFinishedTask(pPlayer)
	local tbTask;
	if MODULE_GAMESERVER then
		tbTask = self:GetTaskInfo(pPlayer);
	else
		tbTask = self.tbTask or {};
	end
	for _, tb in ipairs(tbTask.tbTask) do
		if not tb.bFinish then
			return false
		end
	end
	return true
end

function KinDinnerParty:IsKinDPTask(nTaskId)
    if not nTaskId then
        return
    end

    local tbInfo = Task.tbDailyTaskSettings[Task.emDAILY_KIN_DP]
    if nTaskId == tbInfo.nTaskId then
        return true
    end
end

function KinDinnerParty:FormatReward(szType, nTemplateId, nCount)
	local tbRet = {}
	if nTemplateId and nTemplateId ~= 0  then
		tbRet = {szType, nTemplateId, nCount};
	else
		tbRet = {szType, nCount};
	end
	return tbRet;
end


function KinDinnerParty:FormatItem(szType, nTemplateId, nCount)
    local szText = "";
    if nTemplateId and nTemplateId ~= 0 then
        local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId);  
        szText = string.format("%s x%d", tbBaseInfo.szName, nCount);
    else
        szText = Shop:GetMoneyName(szType) .. "x" .. nCount ;
    end
    return szText;
end

function KinDinnerParty:CanAskHelp(tbHelps, tbTask, nTaskId)
	if tbHelps[nTaskId] ~= nil then
		return false, "已经发布了"
	end

	local tbTaskSetting = self:GetTaskSetting(nTaskId);
	if tbTaskSetting.szType ~= "Item" then
		return false, "道具才可以求助";
	end

	for _, tb in ipairs(tbTask) do
		if tb.nTaskId == nTaskId then
			if tb.bFinish then
				return false, "已收集完毕"
			end
			break
		end
	end

	return true;
end

function KinDinnerParty:LoadContribution()
	self.tbHelpInfo = {}
	local tbSettting = LoadTabFile("Setting/Task/KinDPTaskHelp.tab", "ddd", nil, { "ItemID", "AddNum", "HelpNeedCoin" })
	for _, tbInfo in pairs(tbSettting) do
		assert(not self.tbHelpInfo[tbInfo.ItemID], "[KinDinnerParty LoadContribution] Error ItemID Repeat", tbInfo.ItemID)

		self.tbHelpInfo[tbInfo.ItemID] = { nAddConNum = tbInfo.AddNum, nNeedCoin = tbInfo.HelpNeedCoin }
	end
end
KinDinnerParty:LoadContribution()

function KinDinnerParty:GetAddContributionCount(nItemID)
	local tbInfo = self.tbHelpInfo[nItemID] or {}
	local nAddCount = tbInfo.nAddConNum or 0
	return nAddCount
end

function KinDinnerParty:GetHelpNeedCoin(nItemID)
	local tbInfo = self.tbHelpInfo[nItemID]
	if not tbInfo then
		return
	end

	local nNeed = tbInfo.nNeedCoin
	return nNeed
end