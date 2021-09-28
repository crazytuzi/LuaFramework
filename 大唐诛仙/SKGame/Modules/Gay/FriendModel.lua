FriendModel = BaseClass(LuaModel)

function FriendModel:__init( ... )
	self:Reset()
	self:AddEvent()
end

function FriendModel:Reset()
	self.friendList = {}           --好友列表
	self.recommendList = {}        --推荐列表
	self.applyList = {}            --申请列表
	self.chatList = {}             --私聊列表 
	self.redList = {}              --红点列表------------------------------
	self.redListMo = {}			   --红点列表陌生人
	self.recentChatList = {}       --最近聊天列表
	self.offlineList = {}

	self.historyInput = {} 

	self.selectInd = 1
	self.isFriend = false
	self.maxRecord = 50
	self.sesstionIds = {}
	self.channelId = 0
end

function FriendModel:AddEvent()
	
	self.handler0 = self:AddEventListener(FriendConst.PrivateChatRed, function(chatVo)   --私聊红点—————————————
		--table.insert(self.redList, chatVo.sendPlayerId)
		local isfri = false
		for i,v in ipairs(self.friendList) do
			if chatVo.sendPlayerId  == v.playerId then
				isfri = true
			end
		end
		local isIn = false
		if not isfri then
			for i,v in ipairs(self.redListMo) do
				if v == chatVo.sendPlayerId then
					isIn = true
					break
				end
			end
			if not isIn then
				table.insert(self.redListMo, chatVo.sendPlayerId)
			end
		else
			for i,v in ipairs(self.redList) do
				if v == chatVo.sendPlayerId then
					isIn = true
					break
				end
			end
			if not isIn then
				table.insert(self.redList, chatVo.sendPlayerId)
			end
		end
	end)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		self:Reset()
	end)
 end 

function FriendModel:GetInstance()
	if FriendModel.inst == nil then
		FriendModel.inst = FriendModel.New()
	end
	return FriendModel.inst
end	

function FriendModel:GetTips()
	local tipStr = ""
	local cfgData = GetCfgData("game_exception"):Get(1806)
	local data = cfgData.exceptionMsg
	if data then
		tipStr = data
	end
	return tipStr
end

function FriendModel:OffLineAddChat()
	local chatData = {}
	local toPlayerId = SceneModel:GetInstance():GetMainPlayer().playerId  --收到私聊消息 toplayerId  是主角Id
	if not toPlayerId then return end
	for i,v in ipairs(self.offlineList) do
	 	chatData.sendPlayerId = v.sendPlayerId
	 	chatData.sendPlayerCareer = v.sendPlayerCareer
	 	chatData.sendPlayerName = v.sendPlayerName
	 	chatData.sendPlayerLevel = v.sendPlayerLevel
	 	chatData.sendPlayerVip = v.sendPlayerVip
	 	chatData.toPlayerId = toPlayerId
	 	chatData.type = 4
	 	for k,info in pairs(v.chatInfos) do
	 		chatData.content = info.content
	 		chatData.param = info.param
	 		chatData.cerateTime = info.cerateTime
	 		if chatData.content then
				ChatNewModel:GetInstance():ParseChatData(chatData)
	 		end
	 	end
	end

end

function FriendModel:AddChatVo(chatVo)
	local sesstionId  = self:GetSesstionId(chatVo.sendPlayerId, chatVo.toPlayerId)
	if not self.chatList[sesstionId] then
		self.chatList[sesstionId] = {}
		local isfri = false
		for i,v in ipairs(self.friendList) do
			if chatVo.sendPlayerId  == v.playerId then
				isfri = true
			end
		end
		if not isfri then
			table.insert(self.recentChatList, chatVo)
		end
	end
	table.insert(self.chatList[sesstionId], chatVo)

	if #self.chatList[sesstionId] > self.maxRecord then
		table.remove(self.chatList[sesstionId], 1)
	end
	self:DispatchEvent(FriendConst.ReceivePriMsg, chatVo)
	local playerId = SceneModel:GetInstance():GetMainPlayer().playerId
	if playerId and chatVo.sendPlayerId then
		if chatVo.sendPlayerId ~= playerId then
			GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.social , state = true})
			self:DispatchEvent(FriendConst.PrivateChatRed, chatVo)
			MainUIModel:GetInstance().isClickPrivateChat = 0
			GlobalDispatcher:DispatchEvent(EventName.FriendChat)
			GlobalDispatcher:DispatchEvent(EventName.IsClickPrivate)
		end
	end
end

function FriendModel:AddHistoryInput(str)          --添加历史消息===
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

function FriendModel:GetChatList(player1, player2)
	local sesstionId  = self:GetSesstionId(player1, player2)
	if not self.chatList[sesstionId] then
		self.chatList[sesstionId] = {}
	end
	return self.chatList[sesstionId]

end

--获取会话Id
function FriendModel:GetSesstionId(player1, player2)
	local key1 = player1 .."_"..player2
	local key2 = player2 .."_"..player1

	local sesstionId = nil
	for i = 1, #self.sesstionIds do
		if self.sesstionIds[i][1] == key1 or self.sesstionIds[i][1] == key2 or 
		   self.sesstionIds[i][2] == key1 or self.sesstionIds[i][2] == key2  then
		   sesstionId = i
		end
	end
	
	if not sesstionId then
		table.insert(self.sesstionIds, {key1, key2})
		sesstionId = #self.sesstionIds
	end

	return tostring(sesstionId)
end

function FriendModel:IsMainPlayerSay(chatVo)
	return chatVo.sendPlayerId == SceneModel:GetInstance():GetMainPlayer().playerId
end


--获取好友列表
function FriendModel:GetFriendList()

	local friList = {} 
	for i,v in ipairs(self.friendList) do
		table.insert(friList, v)
	end
	return friList
end

function FriendModel:IsFriend(playerId)
	local friList = self:GetFriendList()
	local isFri = false
	if friList then
		for i,v in ipairs(friList) do
			if playerId == v.playerId then
				isFri = true
				break
			end
		end
	end
	return isFri
end

function FriendModel:__delete()                                --清除
	self:RemoveEventListener(self.handler0)       --私聊红点——————————————
	self:RemoveEventListener(self.handler1)
	self.selectInd = 1
	self.friendList = nil
	self.applyList = nil
	self.recommendList = nil
	FriendModel.inst = nil
end