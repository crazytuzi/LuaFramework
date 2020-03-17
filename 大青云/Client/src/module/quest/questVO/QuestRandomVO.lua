--[[
奇遇任务
2015年7月29日18:08:30
haohu
]]
------------------------------------------------------------------------

_G.QuestRandomVO = setmetatable( {}, {__index = QuestVO} )

QuestRandomVO.maxGoalsCount = 0;
QuestRandomVO.monsterID = 0;
QuestRandomVO.monsterPos = 0;

-- npc对话显示奖励
function QuestRandomVO:GetShowRewards()
	local cfg = self:GetCfg();
	if not cfg then return ""; end
	local rewards = {};
	if cfg.exp_reward > 0 then
		table.push(rewards, enAttrType.eaExp .. "," .. cfg.exp_reward);
	end
	if cfg.money_reward > 0 then
		table.push(rewards, enAttrType.eaBindGold .. "," .. cfg.money_reward);
	end
	if cfg.other_rewards1 ~= "" then
		table.push(rewards, cfg.other_rewards1);
	end
	if cfg.other_rewards2 ~= "" then
		table.push(rewards, cfg.other_rewards2);
	end
	if cfg.other_rewards3 ~= "" then
		table.push(rewards, cfg.other_rewards3);
	end
	if cfg.other_rewards4 ~= "" then
		table.push(rewards, cfg.other_rewards4);
	end
	if #rewards <= 0 then
		return "";
	end
	return RewardManager:Parse(table.concat(rewards, "#"));
end

--获取任务配表
function QuestRandomVO:GetCfg()
	local cfg = t_questrandom[self:GetId()]
	if not cfg then
		Debug( 'error:cannot find random quest in table.id:'..self:GetId() )
		return nil
	end
	return cfg;
end

-- flag : max goals count
function QuestRandomVO:ParseFlag( flag )
	self.maxGoalsCount = toint(flag);
end

function QuestRandomVO:SetGoalInfo(info)
	self.monsterID = info.current_goalsId;
	for k, v in pairs(t_questrandomgruop) do
		if v.questgoals == self.monsterID .. "," .. self.maxGoalsCount then
			self.monsterPos = toint(v.guideParam);
			break;
		end
	end

	local goal = self:GetGoal()
	goal:SetGoalInfo(info)
end

function QuestRandomVO:GetMonsterID()
	return self.monsterID;
end

function QuestRandomVO:GetMonsterCount()
	return self.maxGoalsCount;
end

function QuestRandomVO:GetMonsterPos()
	return self.monsterPos;
end

--获取任务当前的NPC ID
--[[function QuestRandomVO:GetCurrNPC()
	local cfg = self:GetCfg()
	return cfg and cfg.finishNpc
end]]

--获取任务完成点
--[[function QuestRandomVO:GetFinishPoint()
	local cfg = self:GetCfg()
	return cfg and QuestUtil:GetQuestPos( cfg.pos )
end]]

-- 交任务
function QuestRandomVO:Submit()
	self:SendSubmit();
end

--[[function QuestRandomVO:ReqFinish()
	local func = function()
		RandomQuestController:ReqRandomQuestReward( self.questId )
		--当前是翻牌奖励状态
		RandomQuestModel:SetIsRandomReward(true)
	end
	RandomDungeonRaffle:Open(self.questId,func)
end]]

-- 发送交任务
function QuestRandomVO:SendSubmit()
	self:OnTitleClick();
end

--任务类型
function QuestRandomVO:GetType()
	return QuestConsts.Type_Random;
end

function QuestRandomVO:GetPlayRefresh()
	return false;
end

--获取快捷任务任务标题文本
function QuestRandomVO:GetTitleLabel()
	local titleFormat = StrConfig["quest923"]
	local totalTimes = RandomQuestConsts:GetRoundsPerDay();
	local curTimes = QuestModel.randomQuestFinishedCount;
	return string.format(titleFormat, QuestColor.TITLE_COLOR, QuestColor.TITLE_FONTSIZE, curTimes, totalTimes);
end

function QuestRandomVO:GetContentLabel(fontSize)
	local state = self:GetState()
	local label = ""
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end
	local sizeStr = tostring(fontSize)
	if state == QuestConsts.State_UnAccept then
		local goalVO = self:GetGoal()
		if goalVO then
			label = goalVO:GetLabelContent()
		end
	elseif state == QuestConsts.State_Going then
		local goalVO = self:GetGoal()
		if goalVO then
			label = goalVO:GetGoalLabel( fontSize )
		end
	elseif state == QuestConsts.State_CanFinish then
		label = self:ParseQuestLink(StrConfig['quest16']);
--	elseif state == QuestConsts.State_Finished then
--		label = StrConfig['quest16']
	end
	return label
end

function QuestRandomVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", sizeStr, str );
end

function QuestRandomVO:OnContentClick()
	if self:IsAccept() then
		self:Proceed()
	else
		self:DoGoal();
	end
end

-- factory method 建立任务目标
function QuestRandomVO:CreateQuestGoal()
	local goalType = self:GetGoalType()
	local class = QuestVO.GoalClassMap[ goalType ]
	return class and class:new( self )
end

function QuestRandomVO:GetGoalType()
	if self:IsAccept() then
		return 2100 + self:GetCfg().kind;
	else
		return 2100;
	end
end

function QuestRandomVO:IsAccept()
	if self:GetId() ~= QuestModel.noneRandomQuestID then
		return true;
	else
		return false
	end
end

function QuestRandomVO:OnTitleClick()
	if self:IsAccept() then
		FuncManager:OpenFunc(FuncConsts.QuestRandom, false, self:GetId());
	else
		FuncManager:OpenFunc(FuncConsts.QuestRandom, false);
	end
end

-- 独有节点数组(在内容节点之上)
--[[function QuestRandomVO:CreateUpperNodes()
	-- 等级任务显示奖励节点
	local nodes = {}
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes
end]]

-- 对应npc对话面板显示谈话内容
--[[function QuestRandomVO:GetNpcTalk()
	local cfg = self:GetCfg()
	local npcTalk     = cfg.dailog
	local btnLabel    = StrConfig['quest8']
	local btnDisabled = false
	return npcTalk, btnLabel, btnDisabled
end]]

--[[function QuestRandomVO:GetOptions()
	-- 玩家对话选项
	local cfg = self:GetCfg()
	local option = { label = cfg.answer }
	return { UIData.encode( option ) }
end]]

--[[function QuestRandomVO:ShowNpcDialog(npcId)
	if self:GetState() == QuestConsts.State_Finished then
		return false
	end
	if self:GetCurrNPC() ~= npcId then
		return false
	end
	UIRandomQuestNpc:Open( npcId )
	return true
end]]

function QuestRandomVO:GetState()
	return self.state;
end

function QuestRandomVO:GetPlayRewardEffect()
	local state = self:GetState()
	return state == QuestConsts.State_Finished
end

function QuestRandomVO:ShowTips()
	if self:IsAccept() then
		local rewardList = self:GetShowRewards();
		UIQuestTips:Show(self:GetCfg().name, rewardList);
	end
end

function QuestRandomVO:Finish()
	self:SetState( QuestConsts.State_Finished )
	self:OnFinished()
end

function QuestRandomVO:GetTeleportType()
	return MapConsts.Teleport_RandomQuest
end

-- 是否可传送
function QuestRandomVO:CanTeleport()
	return self:IsAccept() and self:GetState() == QuestConsts.State_Going;
end

function QuestRandomVO:OnStateChange()
	if self:GetState() == QuestConsts.State_CanFinish then
		if not UIHoneView:IsShow() then
			self:OnTitleClick();
		end
	end
end
