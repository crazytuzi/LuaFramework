
ChatNewModel =BaseClass(LuaModel)

ChatNewModel.Channel = {
	System = 5, 	--系统
	World = 1, 		--世界
	Near = 6, 		--附近
	Family = 2, 	--家族
	Team = 3, 		--队伍
	Self = 4, 		--私人
	Trumpet = 7, 	--喇叭
	Clan = 8, 		--clan
}
local Channel = ChatNewModel.Channel
ChatNewModel.ChannelColor = {
	[1] = "#e6d097",
	[2] = "#c66a8a",
	[3] = "#60bdf3",
	[4] = "#8a8cf4",
	[5] = "#fd852d",
	[6] = "#adbecf",
	[7] = "#fff556",
	[8] = "#8a66f9",
}

function ChatNewModel:GetInstance()
	if ChatNewModel.inst == nil then
		ChatNewModel.inst = ChatNewModel.New()
	end
	return ChatNewModel.inst
end

function ChatNewModel:__init()
	self.curChannel = Channel.System
	self.recordMax = 50

	self:ReSet()

	UBBParserExtension:SetEmojiPkgName("ChatNew")
	for k,v in pairs( ChatNewConst.TAGS ) do
		if v then 
			UBBParserExtension:AddParserKeyOnEmoj( v,":" )
		end 
	end

	self.trumpetCostId = 0
	local cfg = GetCfgData("constant"):Get(22)
	if cfg then
		self.trumpetCostId = cfg.value
	end
end
function ChatNewModel:ReSet()
	self.systemMsgList = {}
	self.worldMsgList = {}
	self.nearMsgList = {}
	self.familyMsgList = {}
	self.clanMsgList={}
	self.teamMsgList = {}
	self.trumpetMsgList = {}
	self.privateList = {} --++++++++

	self.historyInput = {}

	self.chatPanelData = {}
	self.chatNum = 1
end

function ChatNewModel:__delete()
	self.systemMsgList = nil
	self.worldMsgList = nil
	self.nearMsgList = nil
	self.familyMsgList = nil
	self.clanMsgList=nil
	self.teamMsgList = nil
	self.trumpetMsgList = nil
	self.privateList = nil--+++++++++
	self.historyInput = nil

	ChatNewModel.inst = nil
end

function ChatNewModel:HasTrumpet()
	if self.trumpetCostId == 0 then
		return false
	end
	if PkgModel:GetInstance():GetTotalByBid(self.trumpetCostId) > 0 then
		return true
	end
	return false
end

function ChatNewModel:GetHistoryInput()
	return self.historyInput
end

function ChatNewModel:GetSystemMsg()
	return self.systemMsgList
end

function ChatNewModel:GetWorldMsg()
	return self.worldMsgList
end

function ChatNewModel:GetNearMsg()
	return self.nearMsgList
end

function ChatNewModel:GetFamilyMsg()
	return self.familyMsgList
end
function ChatNewModel:GetClanMsg()
	return self.clanMsgList
end


function ChatNewModel:GetTeamMsg()
	return self.teamMsgList
end

function ChatNewModel:GetTrumpetMsg()
	return self.trumpetMsgList
end

function ChatNewModel:GetPrivateMsg()   --++++++
	return self.privateList
end

function ChatNewModel:IsMainPlayerSay(chatVo)
	local rtnIsMainPlayer = false
	if chatVo and chatVo.sendPlayerId then
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayer and mainPlayer.playerId then
			if chatVo.sendPlayerId == mainPlayer.playerId then
				rtnIsMainPlayer = true
			end
		end
	end
	return rtnIsMainPlayer
end

function ChatNewModel:ParseChatData(data)
	local chatVo = ChatVo.New(data)
	if chatVo.type == Channel.Self then
		FriendModel:GetInstance():AddChatVo(chatVo)
		self:AddPrivateMsg(chatVo)
		return
	end
	if chatVo.type == Channel.World then
		self:AddWorldMsg(chatVo)
	elseif chatVo.type == Channel.System then
		self:AddSystemMsg(chatVo)
	elseif chatVo.type == Channel.Near then
		self:AddNearMsg(chatVo)
	elseif chatVo.type == Channel.Family then
		self:AddFamilyMsg(chatVo)
	elseif chatVo.type == Channel.Team then
		self:AddTeamMsg(chatVo)
	elseif chatVo.type == Channel.Trumpet then
		self:AddTrumpetMsg(chatVo)
	elseif chatVo.type == Channel.Clan then
		self:AddClanMsg(chatVo)
	end
	return chatVo
end

function ChatNewModel:AddOperateMsg(chatVo)
	if chatVo.isOperateMsg then
		self:AddSystemMsg(chatVo)
	else
		self:AddWorldMsg(chatVo)
	end
end

function ChatNewModel:AddTeamMsg(chatVo)
	table.insert(self.teamMsgList, chatVo)
	if #self.teamMsgList > self.recordMax then
		table.remove(self.teamMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddFamilyMsg(chatVo)
	table.insert(self.familyMsgList, chatVo)
	if #self.familyMsgList > self.recordMax then
		table.remove(self.familyMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddClanMsg( chatVo )
	table.insert(self.clanMsgList, chatVo)
	if #self.clanMsgList > self.recordMax then
		table.remove(self.clanMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddNearMsg(chatVo)
	table.insert(self.nearMsgList, chatVo)
	if #self.nearMsgList > self.recordMax then
		table.remove(self.nearMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddSystemMsg(chatVo)
	table.insert(self.systemMsgList, chatVo)
	if #self.systemMsgList > self.recordMax then
		table.remove(self.systemMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddWorldMsg(chatVo)
	table.insert(self.worldMsgList, chatVo)
	if #self.worldMsgList > self.recordMax then
		table.remove(self.worldMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddTrumpetMsg(chatVo)
	table.insert(self.trumpetMsgList, chatVo)
	if #self.trumpetMsgList > self.recordMax then
		table.remove(self.trumpetMsgList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
end

function ChatNewModel:AddPrivateMsg(chatVo)  --++++++
	table.insert(self.privateList, chatVo)
	if #self.privateList > self.recordMax then
		table.remove(self.privateList, 1)
	end
	self:DispatchEvent(ChatNewConst.ReceiveMsg, chatVo)
	if chatVo.type == Channel.Self then
		self.chatPanelData = {}
		self.chatPanelData.sendPlayerLevel = chatVo.sendPlayerLevel
		self.chatPanelData.sendPlayerCareer = chatVo.sendPlayerCareer
		self.chatPanelData.sendPlayerId = chatVo.sendPlayerId
		self.chatPanelData.online = 1
		self.chatPanelData.sendPlayerName = chatVo.sendPlayerName
		self.chatPanelData.sendPlayerId = chatVo.sendPlayerId ------------------------------
	end
end

function ChatNewModel:AddHistoryInput(str)
	for i = 1, #self.historyInput do
		if str == self.historyInput[i] then
			return
		end
	end
	table.insert(self.historyInput, str)
	if #self.historyInput > 10 then
		table.remove(self.historyInput, 1)
	end
end
	
function ChatNewModel:ParseNoticData(data)
	local noticVo = NoticVo.New(data)
	if noticVo.type == Channel.World then
		self:AddWorldMsg(noticVo)
	elseif noticVo.type == Channel.System then
		self:AddSystemMsg(noticVo)
	elseif noticVo.type == Channel.Near then
		self:AddNearMsg(noticVo)
	elseif noticVo.type == Channel.Family then
		self:AddFamilyMsg(noticVo)
	elseif noticVo.type == Channel.Team then
		self:AddTeamMsg(noticVo)
	elseif noticVo.type == Channel.Self then
		self:AddPrivateMsg(noticVo)
	elseif noticVo.type == Channel.Clan then
		self:AddClanMsg(noticVo)
	end

	if noticVo.isRollMsg then
		return noticVo.content2
	end
end