--[[
奇遇任务 NPC对话面板

haohu
]]
--------------------------------------------------------------

_G.UITaoFaQuestNpc = UINpcDialogBase:new("UITaoFaQuestNpc")
UITaoFaQuestNpc.autoTimerKey = nil;
--打开面板
--@param npcId NPCID
function UITaoFaQuestNpc:Open(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end
	self:SendNPCGossipMsg(npcId)
	self.npc = npc
	self:Show()
end

function UITaoFaQuestNpc:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg = self.npc:GetCfg()
	if cfg then
		objSwf.labelNpcName.text = cfg.name
	end
	--draw 3D
	self:DrawNpc()
	--显示任务
	local taofaQuestVO = QuestModel:GetTaoFaQuest();
	if not taofaQuestVO then
		self:Hide()
	end
	local npcTalk = taofaQuestVO:GetNpcTalk()
	local options = taofaQuestVO:GetOptions()
	objSwf.tfTalk.text = npcTalk
	local uiList = objSwf.optionList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack( options ) )
	uiList:invalidateData()
	TimerManager:UnRegisterTimer(self.autoTimerKey)
	self.autoTimerKey = nil;
	local sec = 8;
	self.autoTimerKey = TimerManager:RegisterTimer(function(curTimes)
		if curTimes >= sec then
			TimerManager:UnRegisterTimer(self.autoTimerKey)
			self.autoTimerKey = nil;
			self:OnItemClick();
		end
	end, 1000, 8)
end

--点击奖励Item
function UITaoFaQuestNpc:OnItemClick(e)
	if self:DoQuest() then
		self:Hide()
	end
end

function UITaoFaQuestNpc:OnSubHide()
	TimerManager:UnRegisterTimer(self.autoTimerKey)
	self.autoTimerKey = nil;
end

--执行任务处理
function UITaoFaQuestNpc:DoQuest()
	local taofaQuestVO = QuestModel:GetTaoFaQuest();
	if not taofaQuestVO then return end
	local questState = taofaQuestVO:GetState()
	if questState == QuestConsts.State_Going then
		return taofaQuestVO:EnterDungeon();
	end
	return false
end