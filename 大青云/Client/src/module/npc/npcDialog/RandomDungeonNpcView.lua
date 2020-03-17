--[[
奇遇任务 NPC对话面板
2015年7月29日16:48:04
haohu
]]
--------------------------------------------------------------

_G.UIRandomDungeonNpc = UINpcDialogBase:new("UIRandomDungeonNpc")

--打开面板
--@param npcId NPCID
function UIRandomDungeonNpc:Open(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end
	self:SendNPCGossipMsg(npcId)
	self.npc = npc
	self:Show()
end

function UIRandomDungeonNpc:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = self.npc:GetCfg()
	if cfg then
		objSwf.labelNpcName.text = cfg.name
	end
	--draw 3D
	self:DrawNpc()
	--显示对话	--显示列表
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then
		Error( "you are not in random dungeon" )
	end
	local txtTalk = randomDungeon:GetDialog()
	local options = randomDungeon:GetOptions()
	objSwf.tfTalk.text = txtTalk
	local uiList = objSwf.optionList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack( options ) )
	uiList:invalidateData()
	self.timerKey = TimerManager:RegisterTimer( function()
		if self.timerKey then
			local randomDungeon = RandomQuestModel:GetDungeon()
			if randomDungeon then
				if t_consts[90].val2 then
					local playerinfo = MainPlayerModel.humanDetailInfo;
					if playerinfo.eaLevel >= t_consts[90].val2 then
						randomDungeon:TalkToNpc( nil )
					end
				end
			end
			TimerManager:UnRegisterTimer(self.timerKey);
			self.timerKey = nil;
		end
	end, 1000, 0 );
end

function UIRandomDungeonNpc:OnItemClick(e)
	local randomDungeon = RandomQuestModel:GetDungeon()
	if not randomDungeon then
		Error( "you are not in random dungeon" )
	end
	randomDungeon:TalkToNpc( e.item.answer )
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIRandomDungeonNpc:ListNotificationInterests()
	return {
		NotifyConsts.RandomDungeonStep,
		NotifyConsts.RandomDungeonSubject,
		NotifyConsts.RandomDungeonQuestionState,
	}
end

--处理消息
function UIRandomDungeonNpc:HandleNotification(name, body)
	if name == NotifyConsts.RandomDungeonStep then
		self:UpdateShow()
	elseif name == NotifyConsts.RandomDungeonSubject then
		self:UpdateShow()
	elseif name == NotifyConsts.RandomDungeonQuestionState then
		self:UpdateShow()
	end
end

