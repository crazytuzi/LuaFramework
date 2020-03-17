--[[
    Created by IntelliJ IDEA.
    讨伐任务
    User: Hongbin Yang
    Date: 2016/10/6
    Time: 15:08
   ]]


_G.QuestTaoFaVO = setmetatable({}, { __index = QuestVO })

QuestTaoFaVO.questId = 0;
QuestTaoFaVO.npc = 0;
QuestTaoFaVO.npcPosition = 0;

function QuestTaoFaVO:GetQuestId()
	return TaoFaModel.curTaskID;
end

-- npc对话显示奖励
function QuestTaoFaVO:GetShowRewards()
	local cfg = self:GetCfg();
	if not cfg then return ""; end
	return RewardManager:Parse(cfg.reward);
end

--获取任务配表
function QuestTaoFaVO:GetCfg()
	local cfg = t_taofa[self:GetQuestId()]
	if not cfg then
		Debug('error:cannot find taofa quest in table.id:' .. self:GetQuestId())
		return nil
	end
	return cfg;
end

function QuestTaoFaVO:GenerateNPCAndPosition()
	local cfg = self:GetCfg();
	if not cfg then return; end
	local npcs = GetPoundTable(cfg.npc);
	local npcPostions = GetPoundTable(cfg.postion);
	local index = math.random(1, #npcs);
	self.npc = toint(npcs[index]);
	self.npcPosition = toint(npcPostions[index]);
end

function QuestTaoFaVO:GetNPCPos()
	return QuestUtil:GetQuestPos(self.npcPosition);
end

--获取任务当前的NPC ID
function QuestTaoFaVO:GetCurrNPC()
	return self.npc;
end

-- 接受任务
function QuestTaoFaVO:DoRunToNpc()
	QuestController:DoRunToNpc(self:GetNPCPos(), self:GetCurrNPC());
end

function QuestTaoFaVO:EnterDungeon()
	TaoFaController:ReqEnterTaoFaDungeon();
	return true;
end

--任务类型
function QuestTaoFaVO:GetType()
	return QuestConsts.Type_TaoFa;
end

--获取快捷任务任务标题文本
function QuestTaoFaVO:GetTitleLabel()
	local titleFormat = StrConfig["quest912"]
	local totalTimes = TaoFaUtil:GetDayMaxCount();
	local curTimes = TaoFaModel.curFinishedTimes;
	local leftTimesStr = string.format(titleFormat, totalTimes - curTimes);
	local txtTitle = string.format("<font size='" .. QuestColor.TITLE_FONTSIZE .. "' color='" .. QuestColor.TITLE_COLOR .. "'>   %s</font>", StrConfig["quest924"]) -- 中间的空格是留给任务图标的
	return txtTitle .. leftTimesStr;
end

function QuestTaoFaVO:GetContentLabel(fontSize)
	local label = ""
	local cfg = self:GetCfg();
	if not cfg then return ""; end
	local npcCFG = t_npc[self.npc];
	local npcName = npcCFG and npcCFG.name or "";
	label = string.format(StrConfig["quest925"], self:ParseQuestLink(npcName));
	return label
end

function QuestTaoFaVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	return string.format("<u><font size='%s' color='" .. QuestColor.COLOR_GREEN .. "'>%s</font></u>", sizeStr, str);
end

function QuestTaoFaVO:OnContentClick()
	self:DoGoal();
end

-- factory method 建立任务目标
function QuestTaoFaVO:CreateQuestGoal()
	local goalType = self:GetGoalType()
	local class = QuestVO.GoalClassMap[goalType]
	return class and class:new(self)
end

function QuestTaoFaVO:GetGoalType()
	return QuestConsts.GoalType_TaoFaQuestTalk;
end

function QuestTaoFaVO:OnTitleClick()
	UITaoFaView:Open()
end

-- 对应npc对话面板显示谈话内容
function QuestTaoFaVO:GetNpcTalk()
	local cfg = self:GetCfg()
	local npcTalk = t_npc[self.npc].talk;
	local btnLabel = "";
	local btnDisabled = true
	return npcTalk, btnLabel, btnDisabled
end

function QuestTaoFaVO:GetOptions()
	-- 玩家对话选项
	local cfg = self:GetCfg()
	local option = { label = cfg.dialog }
	return { UIData.encode(option) }
end

function QuestTaoFaVO:ShowNpcDialog(npcId)
	if self:GetState() == QuestConsts.State_Finished then
		return false
	end
	if self:GetCurrNPC() ~= npcId then
		return false
	end
	UITaoFaQuestNpc:Open(npcId)
	return true
end

function QuestTaoFaVO:OnStateChange()
	self:GenerateNPCAndPosition();
end

function QuestTaoFaVO:GetState()
	return self.state;
end

--[[function QuestTaoFaVO:GetPlayRewardEffect()
	local state = self:GetState()
	return state == QuestConsts.State_Finished;
end]]

function QuestTaoFaVO:ShowTips()
	local rewardList = self:GetShowRewards();
	UIQuestTips:Show(self:GetCfg().name, rewardList);
end

function QuestTaoFaVO:GetTeleportType()
	return MapConsts.Teleport_TaoFa;
end

-- 是否可传送
function QuestTaoFaVO:CanTeleport()
	return true;
end
function QuestTaoFaVO:GetPlayRefresh()
	return false;
end