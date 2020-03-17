--[[
	任务集会所 新屠魔 新悬赏
	yanghongbin
]]

_G.AgoraModel = Module:new();

AgoraModel.questList = {};
AgoraModel.curQuest = nil;
AgoraModel.curTimes = 0;
AgoraModel.autoRefreshStamp = 0;
AgoraModel.isFreeRefresh = false;
AgoraModel.auto = true;
AgoraModel.firstAuto = false;
function AgoraModel:GetCurQuest()
	return self.curQuest;
end

function AgoraModel:SetCurTimes(times)
	self.curTimes = times;
end

function AgoraModel:SetAutoRefreshStamp(stamp)
	self.autoRefreshStamp = stamp;
end

function AgoraModel:SetIsFreeRefresh(value)
	self.isFreeRefresh = (value == 1);
end

function AgoraModel:UpdateQuestList(msgList)
	self.questList = {};
	local hasAutoIndex = -1;
	for i = 1, #msgList do
		local msgQuest = msgList[i];
		local vo = {};
		vo.questIndex = msgQuest.quest_idx;
		vo.questId = msgQuest.quest_id;
		vo.goalCount = msgQuest.goals_count;
		vo.state = msgQuest.state;
		vo.taofaId = msgQuest.taofa_id;
		if not vo.npcId or vo.npcId <= 0 then --讨伐的NPC
			local cfgItem = t_questagora[vo.questId];
			if cfgItem and cfgItem.kind == AgoraConsts.KIND_TAOFA then
				local taofaCfgItem = t_taofa[vo.taofaId]
				if taofaCfgItem then
					local npcArr = GetPoundTable(taofaCfgItem.npc);
					vo.npcId = toint(npcArr[math.random(1, #npcArr)]);
				end
			end
		end
		if vo.state == QuestConsts.State_UnAccept and not AgoraModel:GetCurQuest() then
			if AgoraModel.auto then
				hasAutoIndex = vo.questIndex;
			end
		end
		vo.acceptLv = msgQuest.level;
		vo.rewardId = msgQuest.reward_id;
		vo.rewardStr = AgoraUtils:GetRewardStrFromTable(vo.rewardId, vo.acceptLv, t_questagora[vo.questId].quality);
		vo.rewardType = t_questagora_rewards[vo.rewardId].sign;
		vo.rewardList = RewardManager:Parse(vo.rewardStr);
		table.push(self.questList, vo);
	end
	table.sort(self.questList, function(A, B)
		return A.questIndex < B.questIndex;
	end)
	self:UpdateCurQuest();
	self:UpdateQuestUIShow();
	self:sendNotification(NotifyConsts.AgoraUpdateAll);

	if hasAutoIndex >= 0 and not AgoraModel.firstAuto then
		AgoraController:ReqAcceptQuestAgora(hasAutoIndex)
	end
end

function AgoraModel:UpdateQuest(msgVO)
	local vo = nil;
	local auto = false;
	for k, v in pairs(self.questList) do
		if v.questIndex == msgVO.quest_idx then
			v.goalCount = msgVO.goals_count;
			local oldState = v.state;
			v.state = msgVO.state;
			if oldState == QuestConsts.State_UnAccept and v.state == QuestConsts.State_Going then
				if AgoraModel.auto and QuestModel:GetAgoraQuest() then
					auto = true;
				end
			end
			v.taofaId = msgVO.taofa_id;
			v.rewardId = msgVO.reward_id;
			vo = v;
		end
	end
	if msgVO.state == QuestConsts.State_Finished then
		AgoraRewardView:Show(msgVO.quest_id, vo.rewardStr);
		self.curTimes = self.curTimes + 1;
		--		QuestGuideManager:DoIdleQuest();
	end

	self:UpdateCurQuest();
	self:UpdateQuestUIShow();
	if vo then
		self:sendNotification(NotifyConsts.AgoraUpdateItem, { item = vo });
	end
	if auto and AgoraModel.firstAuto then
		local quest = QuestModel:GetAgoraQuest();
		quest:OnContentClick();
	end
	AgoraModel.firstAuto = true;
end

function AgoraModel:AbandonQuest()
	if self.curQuest then
		self.curQuest.state = QuestConsts.State_UnAccept;
	end
	self:sendNotification(NotifyConsts.AgoraAbandonItem, { item = self.curQuest });
	self:UpdateCurQuest();
	self:UpdateQuestUIShow();
	self:sendNotification(NotifyConsts.AgoraUpdateItem, { item = nil });
end

function AgoraModel:UpdateCurQuest()
	self.curQuest = nil;
	for k, v in pairs(self.questList) do
		if v.state == QuestConsts.State_Going then
			self.curQuest = v;
			break;
		end
	end
end

function AgoraModel:GetCurFinishedCount()
	local count = 0;
	for k, v in pairs(self.questList) do
		if v.state == QuestConsts.State_Finished then
			count = count + 1;
		end
	end
	return count;
end

function AgoraModel:GetRefreshNeedCount()
	return t_questagora_consts[1].quest_limit;
end

function AgoraModel:GetDayMaxCount()
	return t_questagora_consts[1].limit_day + VipController:GetAgoraAddTimes();
end

function AgoraModel:UpdateQuestUIShow()
	local state = -1;
	local goalCount = 0;
	if self.curQuest then
		state = QuestConsts.State_Going;
		goalCount = self.curQuest.goalCount;
	else
		state = QuestConsts.State_UnAccept;
	end

	if self.curTimes < self:GetDayMaxCount() then
		if not QuestModel:GetAgoraQuest() then
			QuestModel:AddAgoraQuest(state, goalCount)
		else
			QuestModel:UpdateAgoraQuest(state, goalCount)
		end
	else
		QuestModel:RemoveAgoraQuest()
	end
end

function AgoraModel:GetDayLeftCount()
	return self:GetDayMaxCount() - self.curTimes;
end
