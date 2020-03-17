--[[
    Created by IntelliJ IDEA.
    任务集会所 新屠魔 新悬赏
    User: Hongbin Yang
    Date: 2016/10/21
    Time: 15:54
   ]]

_G.QuestAgoraVO = setmetatable({}, { __index = QuestVO })

function QuestAgoraVO:GetQuestId()
	return AgoraModel:GetCurQuest() and AgoraModel:GetCurQuest().questId;
end

-- npc对话显示奖励
function QuestAgoraVO:GetShowRewards()
	if not AgoraModel:GetCurQuest() then return; end
	local rewards = AgoraModel:GetCurQuest().rewardList;
	return rewards;
end

--获取任务配表
function QuestAgoraVO:GetCfg()
	if not self:GetQuestId() then return; end

	local cfg = t_questagora[self:GetQuestId()]
	if not cfg then
		Debug('error:cannot find agora quest in table.id:' .. self:GetQuestId())
		return nil
	end
	return cfg;
end

function QuestAgoraVO:GetTaoFaCfg()
	local agoraCFG = self:GetCfg();
	if not agoraCFG then return; end
	if agoraCFG.kind == AgoraConsts.KIND_TAOFA then
		local cfg = t_taofa[toint(agoraCFG.questGoals)]
		if not cfg then
			Debug('error:cannot find agora->taofa quest in table.id:' .. self:GetQuestId())
			return nil
		end
		return cfg;
	end
end

function QuestAgoraVO:GetNPCPos()
	if not AgoraModel:GetCurQuest() then return; end
	if self:GetCfg().kind == AgoraConsts.KIND_TAOFA then
		local info = AgoraModel:GetCurQuest();
		local name, position = AgoraUtils:GetTaoFaNPCNameAndPosition(info.taofaId, info.npcId);
		return QuestUtil:GetQuestPos(position);
	elseif self:GetCfg().kind == AgoraConsts.KIND_NPC_TALK then
		return QuestUtil:GetQuestPos(toint(self:GetCfg().postion));
	end
end

--获取任务当前的NPC ID
function QuestAgoraVO:GetCurrNPC()
	if not AgoraModel:GetCurQuest() then return; end
	if self:GetCfg().kind == AgoraConsts.KIND_TAOFA then
		local info = AgoraModel:GetCurQuest();
		return info.npcId;
	elseif self:GetCfg().kind == AgoraConsts.KIND_NPC_TALK then
		return toint(self:GetCfg().questGoals);
	end
end

-- 接受任务
function QuestAgoraVO:DoRunToNpc()
	QuestController:DoRunToNpc(self:GetNPCPos(), self:GetCurrNPC());
end

function QuestAgoraVO:EnterDungeon()
	if self:GetCfg().kind == AgoraConsts.KIND_TAOFA then
		if AgoraModel:GetCurQuest() then
			TaoFaController:ReqEnterTaoFaDungeon();
		end
	end
	return true;
end

--任务类型
function QuestAgoraVO:GetType()
	return QuestConsts.Type_Agora;
end

--获取快捷任务任务标题文本
function QuestAgoraVO:GetTitleLabel()
	local titleFormat = StrConfig["quest912"]
	local totalTimes = AgoraModel:GetDayMaxCount();
	local curTimes = AgoraModel.curTimes;
	local leftTimesStr = string.format(titleFormat, totalTimes - curTimes);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest926"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimesStr;
end

function QuestAgoraVO:GetContentLabel(fontSize)
--	local titleStr = "";
--	if AgoraModel:GetCurQuest() then
--		local info = AgoraModel:GetCurQuest()
--		local cfg = t_questagora_rewards[info.rewardId];
--		titleStr = string.format("【%s】", cfg.sign_display)
--	end
	return  self:GetGoal():GetGoalLabel();
end

function QuestAgoraVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	return string.format("<u><font size='%s' color='" .. QuestColor.COLOR_GREEN .. "'>%s</font></u>", sizeStr, str);
end

function QuestAgoraVO:OnContentClick()
	self:DoGoal();
end

-- factory method 建立任务目标
function QuestAgoraVO:CreateQuestGoal()
	local goalType = self:GetGoalType()
	local class = QuestVO.GoalClassMap[goalType]
	return class and class:new(self)
end

function QuestAgoraVO:GetGoalType()
	local type = 0;
	if AgoraModel:GetCurQuest() then
		local cfg = self:GetCfg();
		if not cfg then return; end
		type = 17000 + cfg.kind;
	else
		type = 17000;
	end
	return type
end

function QuestAgoraVO:OnTitleClick()
	AgoraView:Show()
end

-- 对应npc对话面板显示谈话内容
function QuestAgoraVO:GetNpcTalk()
	if not self:GetCfg() then return; end
	local npcID = 0;
	npcID = self:GetCurrNPC()
	local npcTalk = t_npc[npcID].talk;
	local btnLabel = "";
	local btnDisabled = true
	return npcTalk, btnLabel, btnDisabled
end

function QuestAgoraVO:GetOptions()
	if not self:GetCfg() then return; end
	local option = nil;
	if self:GetCfg().kind == AgoraConsts.KIND_TAOFA then
		-- 玩家对话选项
		local taofaCFG = self:GetTaoFaCfg();
		if not taofaCFG then return; end
		option = { label = taofaCFG.dialog }
	elseif self:GetCfg().kind == AgoraConsts.KIND_NPC_TALK then
		local cfg = self:GetCfg();
		option = { label = cfg.dialog }
	end
	return { UIData.encode(option) }
end

function QuestAgoraVO:ShowNpcDialog(npcId)
	if self:GetState() == QuestConsts.State_Finished then
		return false
	end
	local targetNPCId = self:GetCurrNPC();
	if targetNPCId ~= npcId then
		return false
	end
	UIAgoraQuestNpc:Open(npcId)
	return true
end

function QuestAgoraVO:GetState()
	if AgoraModel:GetCurQuest() then
		return QuestConsts.State_Going;
	else
		return QuestConsts.State_UnAccept;
	end
end

function QuestAgoraVO:SetState( state, showRefresh )
	self.goalList = {}
	self.goalList[1] = self:CreateQuestGoal();
	if self.state ~= state then
		self.state = state;
		for i,goalVO in pairs(self.goalList) do
			goalVO:OnStateChange();
		end
		self.playRefresh = showRefresh == nil and true or showRefresh
		self:OnStateChange();
	end
end

function QuestAgoraVO:ShowTips()
	if AgoraModel:GetCurQuest() then
		local rewardList = self:GetShowRewards();
		UIQuestTips:Show(StrConfig["quest926"], rewardList);
	end
end

function QuestAgoraVO:GetTeleportType()
	return MapConsts.Teleport_Agora;
end

-- 是否可传送
function QuestAgoraVO:CanTeleport()
	if AgoraModel:GetCurQuest() then
		return true;
	end
	return false;
end


-- 完成任务
function QuestAgoraVO:Finish()
	self:OnFinished()
end

function QuestAgoraVO:GetPlayRefresh()
	return false;
end