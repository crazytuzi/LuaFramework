--[[
新悬赏任务 NPC对话面板

haohu
]]
--------------------------------------------------------------

_G.UIAgoraQuestNpc = UINpcDialogBase:new("UIAgoraQuestNpc")

--打开面板
--@param npcId NPCID
function UIAgoraQuestNpc:Open(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end

	self.npc = npc
	self:Show()
end

function UIAgoraQuestNpc:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	local cfg = self.npc:GetCfg()
	if cfg then
		objSwf.labelNpcName.text = cfg.name
	end
	--draw 3D
	self:DrawNpc()
	--显示任务
	local agoraQuestVO = QuestModel:GetAgoraQuest();
	if not agoraQuestVO then
		self:Hide()
	end
	local npcTalk = agoraQuestVO:GetNpcTalk()
	local options = agoraQuestVO:GetOptions()
	objSwf.tfTalk.text = npcTalk
	local uiList = objSwf.optionList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack( options ) )
	uiList:invalidateData()
end

--点击奖励Item
function UIAgoraQuestNpc:OnItemClick(e)
	if self:DoQuest() then
		self:SendNPCGossipMsg(self.npc.npcId)
		self:Hide()
	end
end

--执行任务处理
function UIAgoraQuestNpc:DoQuest()
	local agoraQuestVO = QuestModel:GetAgoraQuest();
	if not agoraQuestVO then return end
	local questState = agoraQuestVO:GetState()
	if questState == QuestConsts.State_Going then
		return agoraQuestVO:EnterDungeon();
	end
	return false
end