--[[
奇遇任务 NPC对话面板

haohu
]]
--------------------------------------------------------------

_G.UIRandomQuestNpc = UINpcDialogBase:new("UIRandomQuestNpc")

--打开面板
--@param npcId NPCID
function UIRandomQuestNpc:Open(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end
	self:SendNPCGossipMsg(npcId)
	self.npc = npc
	self:Show()
end

function UIRandomQuestNpc:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg = self.npc:GetCfg()
	if cfg then
		objSwf.labelNpcName.text = cfg.name
	end
	--draw 3D
	self:DrawNpc()
	--显示任务
	local randomQuestVO = RandomQuestModel:GetQuest()
	if not randomQuestVO then
		self:Hide()
	end
	local npcTalk = randomQuestVO:GetNpcTalk()
	local options = randomQuestVO:GetOptions()
	objSwf.tfTalk.text = npcTalk
	local uiList = objSwf.optionList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack( options ) )
	uiList:invalidateData()
	self.timerKey = TimerManager:RegisterTimer( function()
		if self.timerKey then
			if t_consts[90].val2 then
				local playerinfo = MainPlayerModel.humanDetailInfo;
				if playerinfo.eaLevel >= t_consts[90].val2 then
					self:OnItemClick(nil);
				end
			end
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end
	end, 500, 0 );
end

--点击奖励Item
function UIRandomQuestNpc:OnItemClick(e)
	if self:DoQuest() then
		self:Hide()
	end
end

--执行任务处理
function UIRandomQuestNpc:DoQuest()
	local randomQuestVO = RandomQuestModel:GetQuest()
	if not randomQuestVO then return end
	local questState = randomQuestVO:GetState()
	if questState == QuestConsts.State_CanFinish then
		return randomQuestVO:SendSubmit()
	end
	return false
end