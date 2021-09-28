ChatNewPanel = BaseClass(BaseView)

function ChatNewPanel:__init( ... )
	self.id = "ChatNewPanel"
	local ui = UIPackage.CreateObject("ChatNew", "ChatNewPanel")
	self.ui = ui
	self.closeBtn = ui:GetChild("closeBtn")
	self.micBtn = ui:GetChild("micBtn")
	self.inputCom = ui:GetChild("inputCom")
	self.addBtn = ui:GetChild("addBtn")
	self.sendBtn = ui:GetChild("sendBtn")
	self.GouText = ui:GetChild("GouText")
	self.system = ui:GetChild("system")
	self.world = ui:GetChild("world")
	self.near = ui:GetChild("near")
	self.family = ui:GetChild("family")
	self.clan = ui:GetChild("clan")
	self.team = ui:GetChild("team")
	self.trumpet = ui:GetChild("trumpet")
	self.keyBtn = ui:GetChild("keyBtn")
	self.micStateBar = ui:GetChild("micStateBar")
	self.cancelAudioTips = ui:GetChild("cancelAudioTips")
	self.playingAudioTips = ui:GetChild("playingAudioTips")
	self.privateChatBtn = ui:GetChild("privateChatBtn")  --私聊提示+++++++++
	
	self.privateChatBtn.visible = false
	self.inputTxt = self.inputCom:GetChild("input")
	self.playingMc = self.playingAudioTips:GetChild("n3")

	local model = ChatNewModel:GetInstance()
	self.model = model
	self.leftPoolMax = model.recordMax
	self.leftPoolItemList = {}

	self.rightPoolMax = model.recordMax
	self.rightPoolItemList = {}

	self.systemPoolMax = model.recordMax
	self.systemPoolItemList = {}

	self.channelBtns = {}
--------------------------------
	self.index = 1
	self.locationY = 0
	self.curShowChannel = nil
	self.curChannelData = nil
--------------------------------
	self.curChannelId = -1

	self.chatData = {}

	self.curInputType = 1 -- 1:文字 ~1:语音

	self.includeEquip = false
	self.replaceEuipStr = {}
	self.equipParams = {}

	self.isCenter = false -- 居中打开
	self.useFade = true -- 开启打开淡化效果
	self:SetXY(0, 2)
	
	self:SetInputType(1)
	self:SetRecordAudioState(false)
	self:SetPlayingAudioState(false)

	self:AddEvent()
	self:ShowChannelBtns()

	self.typeSelectPanel = nil

	self.isInited = true
	
	if MainUIModel:GetInstance().isClickPrivateChat == 0 then
		self.privateChatBtn.visible = true
		local numSiliao = self.privateChatBtn:GetChild("btn_siliao")
		if not numSiliao then return end
		numSiliao:GetChild("numSiliaoTxt").text = model.chatNum
	end
end

function ChatNewPanel:__delete()
	if self.channelBtns then
		for i,v in ipairs(self.channelBtns) do
			v:Destroy()
		end
	end
	self.channelBtns = nil
	self:RemoveEvent()
	self:DestoryLeftPool()
	self:DestoryRightPool()
	self:DestorySystemPool()
	if self.typeSelect then
		self.typeSelect:Destroy()
	end
	self.typeSelect = nil
	if self.typeSelectPanel then
		UIMgr.HidePopup(self.typeSelectPanel.ui)
		self.typeSelectPanel:Destroy()
	end
	self.typeSelectPanel = nil
	self.equipParams = nil
	self.channelHeight = nil
end

function ChatNewPanel:ShowChannelBtns()
	local data = {
	{"系统", ChatNewModel.Channel.System},
	{"世界", ChatNewModel.Channel.World},
	{"附近", ChatNewModel.Channel.Near},
	{"家族", ChatNewModel.Channel.Family},
	{"都护府", ChatNewModel.Channel.Clan},
	{"队伍", ChatNewModel.Channel.Team},
	{"广播", ChatNewModel.Channel.Trumpet},
	}
	local w = 108
	local h = 80
	local x = 5
	local y = 13
	for i = 1, #data do
		local channelBtn = ChannelBtn.New()
		channelBtn:Set(data[i][1], data[i][2], x, y, self.ui)
		y = y + h
		if channelBtn.channelId == self.model.curChannel then
			channelBtn:Select()
		end
		table.insert(self.channelBtns, channelBtn)
	end
end

function ChatNewPanel:SetRecordAudioState(isRecord)
	if isRecord then
		self.cancelAudioTips.visible = true
	else
		self.cancelAudioTips.visible = false
	end
end

function ChatNewPanel:SetPlayingAudioState(isPlay)
	if isPlay then
		self.playingAudioTips.visible = true
	else
		self.playingAudioTips.visible = false
	end
end

function ChatNewPanel:SetInputType(iType)
	if iType == 1 then --文字
		self.micStateBar.visible = false
		self.keyBtn.visible = false
		self.curInputType = 1
	else --语音
		self.micStateBar.visible = true
		self.keyBtn.visible = true
		self.curInputType = 2
	end
	self:SendState()
end

function ChatNewPanel:AddEvent()
	self.micBtn.onClick:Add(function()
		--self:SetInputType(2)
	end, self)

	self.keyBtn.onClick:Add(function()
		--self:SetInputType(1)
	end, self)

	self.micStateBar.onClick:Add(function()

	end, self)

	self.closeBtn.onClick:Add(function()
		ChatNewController:GetInstance():Close()
	end, self)

	self.sendBtn.onClick:Add(function()
		self:SendMsg()
	end, self)

	self.addBtn.onClick:Add(function()
		self:SelectPanelToggle()
	end, self)
	self.closeCallback = function ()
		if self.typeSelectPanel then
			UIMgr.HidePopup(self.typeSelectPanel.ui)
		end
		self.typeSelectPanel = nil
	end

	self.privateChatBtn:GetChild("btn_siliao").onClick:Add(function ()
		MainUIModel:GetInstance().isClickPrivateChat = 1
		GlobalDispatcher:DispatchEvent(EventName.IsClickPrivate)
		self.privateChatBtn.visible = false
		--FriendController:GetInstance():Open()
		FriendController:GetInstance():IsFriendChat(self.model.chatPanelData)
	end)
	self.privateChatBtn:GetChild("btnClose").onClick:Add(function ()
		self.privateChatBtn.visible = false
	end)
	-- self.micBtn.onClick:Add(function()
	-- 	MicroPhoneInput.getInstance():StartRecord()
	-- 	DelayCall(function()
	-- 		local data = MicroPhoneInput.getInstance():GetClipData()
	-- 		ChatNewController:GetInstance():C_PostVoice(data)

	-- 		DelayCall(function()
	-- 			ChatNewController:GetInstance():C_GetVoice()
	-- 		end, 2)

	-- 	end, 1)
	-- end, self)

	self.selectHandler = self.model:AddEventListener(ChatNewConst.SelectChannel, function (data) self:OnChangeChannel(data) end)
	self.selectFaceHandler = self.model:AddEventListener(ChatNewConst.SelectFace, function (data) self:OnSelectFace(data) end)
	self.selectEquipHandler = self.model:AddEventListener(ChatNewConst.SelectEquip, function (data) self:OnSelectEquip(data) end)
	self.selectHistoryHandler = self.model:AddEventListener(ChatNewConst.SelectHistory, function (data) self:OnSelectHistory(data) end)
	self.receiveHandler = self.model:AddEventListener(ChatNewConst.ReceiveMsg, function (data) self:OnReceiveMsg(data) end)

	self.handler0 = GlobalDispatcher:AddEventListener(EventName.IsClickPrivate, function ()
		local numSiliao = self.privateChatBtn:GetChild("btn_siliao")
		if not numSiliao then return end
		if MainUIModel:GetInstance().isClickPrivateChat == 0 then
			self.privateChatBtn.visible = true
			numSiliao:GetChild("numSiliaoTxt").text = self.model.chatNum
		else
			self.privateChatBtn.visible = false
			numSiliao:GetChild("numSiliaoTxt").text = " "
		end
	end)
end

function ChatNewPanel:RemoveEvent()
	self.model:RemoveEventListener(self.selectHandler)
	self.model:RemoveEventListener(self.selectFaceHandler)
	self.model:RemoveEventListener(self.selectEquipHandler)
	self.model:RemoveEventListener(self.selectHistoryHandler)
	self.model:RemoveEventListener(self.receiveHandler)
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

function ChatNewPanel:SelectPanelToggle()
	local closeFunc = function()
		self.typeSelectPanel = nil
	end
	closeFunc()
	self.typeSelectPanel = TypeSelectPanel.New()
	self.typeSelectPanel:ToShow()
	UIMgr.ShowPopup(self.typeSelectPanel, false, 0, -40, closeFunc)   --LSB+=
end

function ChatNewPanel:SendMsg()
	--开启GM调试入口
	if self.inputTxt.text == "@gm_debug_skgame" then -- 开启GM调试
		DebugMgr:GetInstance()
		return
	end

	if SceneModel:GetInstance():GetMainPlayer().level < 10 then
		Message:GetInstance():TipsMsg("达到10级就可以发言啦")
		return
	end

	if self.curChannelId == ChatNewModel.Channel.System then
		Message:GetInstance():TipsMsg("无法发送系统消息")
		return
	elseif self.curChannelId == ChatNewModel.Channel.Self then  --+++
		return
	elseif self.curChannelId == ChatNewModel.Channel.Trumpet then
		if not self.model:HasTrumpet() then
			UIMgr.Win_Confirm("温馨提示", "喇叭不足，是否前往购买？", "确定", "取消", function()--确定
				MallController:GetInstance():OpenMallPanel(nil, 0, 3)				
			end,
			function()	--取消
			
			end)
			return
		end
	elseif self.curChannelId == ChatNewModel.Channel.World then
		if SceneModel:GetInstance():GetMainPlayer().level < 20 then
			Message:GetInstance():TipsMsg("20级开放世界聊天频道")
			return
		end
	end

	if self.includeEquip then
		if self.inputTxt.text ~= "" then
			if string.utf8len(self.inputTxt.text) <= 48 then
				ChatNewController:GetInstance():C_Chat(self.curChannelId, self.inputTxt.text, nil, self.equipParams)
			else
				Message:GetInstance():TipsMsg("超过48个字符限制")
			end
		else
			Message:GetInstance():TipsMsg("不能发送空消息")
		end
	else
		if self.inputTxt.text ~= "" then
			if string.utf8len(self.inputTxt.text) <= 48 then
				ChatNewController:GetInstance():C_Chat(self.curChannelId, self.inputTxt.text, nil, nil)
				self.model:AddHistoryInput(self.inputTxt.text)       --历史消息++++++++
			else
				Message:GetInstance():TipsMsg("超过48个字符限制")
			end
		else
			Message:GetInstance():TipsMsg("不能发送空消息")
		end
	end
	self.inputTxt.text = ""
	self.includeEquip = false
	self.equipParams = {}
	self.replaceEuipStr = {}
end

function ChatNewPanel:OnSelectHistory(data)
	self.inputTxt.text = self.inputTxt.text..data
end

function ChatNewPanel:OnSelectEquip(data)
	self.includeEquip = true
	self.inputTxt.text = self.inputTxt.text.."{"..#self.replaceEuipStr.."}"
	table.insert(self.replaceEuipStr, "["..data.name.."]")
	local mainPlayerId = 0
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayer and mainPlayer.playerId then
		mainPlayerId = mainPlayer.playerId
	end
	table.insert(self.equipParams, {ChatVo.ParamType.Equipment, mainPlayerId, data.id, data.equipId})
end

function ChatNewPanel:OnSelectFace(data)
	self:AppendTxt(data)
end

function ChatNewPanel:OnReceiveMsg(data)
	local chatVo = data
	if chatVo.type ~= self.curChannelId then return end
	self:AddMsg(chatVo.type, chatVo)
	if chatVo.type == ChatNewModel.Channel.Self then
		self.chatData = {}
		self.chatData.sendPlayerLevel = data.sendPlayerLevel
		self.chatData.sendPlayerCareer = data.sendPlayerCareer
		self.chatData.sendPlayerId = data.sendPlayerId
		self.chatData.online = 1
		self.chatData.sendPlayerName = data.sendPlayerName
		self.chatData.sendPlayerId = data.sendPlayerId ------------------------------
	end
	-----------------------------DDDDD
end

function ChatNewPanel:OnChangeChannel(channelId)
	if self.curChannelId == channelId then return end
	local model = self.model
	model.curChannel = channelId
	self.system.visible = false
	self.world.visible = false
	self.near.visible = false
	self.family.visible = false
	self.clan.visible = false
	self.team.visible = false
	self.trumpet.visible = false
	self:ClearContent()
	self.curChannelId = channelId

	if channelId == ChatNewModel.Channel.System then --系统
		self.system.visible = true
		self.curChannelData = model:GetSystemMsg()
		self.curShowChannel = self.system

	elseif channelId == ChatNewModel.Channel.World then --世界
		self.world.visible = true
		self.curChannelData = model:GetWorldMsg()
		self.curShowChannel = self.world

	elseif channelId == ChatNewModel.Channel.Near then --附近
		self.near.visible = true
		self.curChannelData = model:GetNearMsg()
		self.curShowChannel = self.near

	elseif channelId == ChatNewModel.Channel.Family then --家族
		self.family.visible = true
		self.curChannelData = model:GetFamilyMsg()
		self.curShowChannel = self.family
	elseif channelId == ChatNewModel.Channel.Clan then --clan
		self.clan.visible = true
		self.curChannelData = model:GetClanMsg()
		self.curShowChannel = self.clan

	elseif channelId == ChatNewModel.Channel.Team then --队伍
		self.team.visible = true
		self.curChannelData = model:GetTeamMsg()
		self.curShowChannel = self.team
		
	elseif channelId == ChatNewModel.Channel.Trumpet then --喇叭
		self.trumpet.visible = true
		self.curChannelData = model:GetTrumpetMsg()
		self.curShowChannel = self.trumpet
	end
	self.index = 1
	self.locationY = 0
	self:LoadChatInfo()
	self:SendState()
	------------------------------DDDDDD
end

function ChatNewPanel:LoadChatInfo()
	if self.curChannelData then
		for i,v in ipairs(self.curChannelData) do
			local item = self:GetItem(self.curChannelData[i])
			if item.type == 1 then
				item.ui.x = 46
			else
				item.ui.x = 0
			end
			item.ui.y = self.locationY
			self.curShowChannel:AddChild(item.ui)
			self.locationY = self.locationY + item:GetHeight()
			self.index = self.index + 1
			self.curShowChannel.scrollPane:ScrollBottom(false)
		end
	end
end

function ChatNewPanel:SendState()
	if self.curInputType == 1 then
		self.sendBtn.alpha = 1
		self.addBtn.alpha = 1
		self.sendBtn.touchable = true
		self.addBtn.touchable = true

		if self.curChannelId == ChatNewModel.Channel.System then
			self.sendBtn.alpha = 0.5
		-- elseif self.curChannelId == ChatNewModel.Channel.Trumpet then
		-- 	if self.model:HasTrumpet() then
		-- 		self.sendBtn.alpha = 1
		-- 	else
		-- 		self.sendBtn.alpha = 1
		else
			self.sendBtn.alpha = 1
		end
	else
		self.sendBtn.alpha = 0.5
		self.addBtn.alpha = 0.5
		self.sendBtn.touchable = false
		self.addBtn.touchable = false
	end
end

function ChatNewPanel:ClearContent()
	while self.system.numChildren > 0 do
		self.system:RemoveChildAt(0)
	end
	while self.world.numChildren > 0 do
		self.world:RemoveChildAt(0)
	end
	while self.near.numChildren > 0 do
		self.near:RemoveChildAt(0)
	end
	while self.family.numChildren > 0 do
		self.family:RemoveChildAt(0)
	end
	while self.clan.numChildren > 0 do
		self.clan:RemoveChildAt(0)
	end
	while self.system.numChildren > 0 do
		self.system:RemoveChildAt(0)
	end
	while self.team.numChildren > 0 do
		self.team:RemoveChildAt(0)
	end
	while self.trumpet.numChildren > 0 do
		self.trumpet:RemoveChildAt(0)
	end
end
------------DDDDDDDDDDDDD
function ChatNewPanel:AppendTxt(str)
	self.inputTxt.text = self.inputTxt.text..str
end

function ChatNewPanel:AddMsg(channelId, chatVo)
	if self.curChannelId ~= channelId then return end ---DDDDDDDDDDDD
	local item = self:GetItem(chatVo)
	item.ui.y = self.locationY --DDDDDDDDDDD
	if item.type == 1 then
		item.ui.x = 46
	else
		item.ui.x = 0
	end
	-- if channelPanel.numChildren <= 0 then -------------------------------------------------------LLLLLLLLLL
	-- 	UIMgr.Win_Alter("消息", "聊天面板内容为空", "确认")
	-- end
	self.curShowChannel:AddChild(item.ui)
	self.locationY = self.locationY + item:GetHeight()
	self.curShowChannel.scrollPane:ScrollBottom(true)
end

function ChatNewPanel:GetItem(chatVo)
	local item = nil
	if chatVo.isFromPlayer then
		if self.model:IsMainPlayerSay(chatVo) then
			item = self:GetRightItemFromPool()
		else
			item = self:GetLeftItemFromPool()
		end
	else
		item = self:GetSystemItemFromPool()
	end
	item:SetData(chatVo)
	return item
end

function ChatNewPanel:GetLeftItemFromPool()
	for i = 1, #self.leftPoolItemList do
		if self.leftPoolItemList[i].ui.parent == nil then
			return self.leftPoolItemList[i]
		end
	end
	if #self.leftPoolItemList <= self.leftPoolMax then
		local item = ContentLeft.New()
		table.insert(self.leftPoolItemList, item)
		return item
	else
		return self.leftPoolItemList[1]
	end
end

function ChatNewPanel:DestoryLeftPool()
	if self.leftPoolItemList then
		for i = 1, #self.leftPoolItemList do
			self.leftPoolItemList[i]:Destroy()
		end
	end
	self.leftPoolItemList = nil
	self.poolItemList = nil
end

function ChatNewPanel:GetRightItemFromPool()
	for i = 1, #self.rightPoolItemList do
		if self.rightPoolItemList[i].ui.parent == nil then
			return self.rightPoolItemList[i]
		end
	end
	if #self.rightPoolItemList <= self.rightPoolMax then
		local item = ContentRight.New()
		table.insert(self.rightPoolItemList, item)
		return item
	else
		return self.rightPoolItemList[1]
	end
end

function ChatNewPanel:DestoryRightPool()
	if self.rightPoolItemList then
		for i = 1, #self.rightPoolItemList do
			self.rightPoolItemList[i]:Destroy()
		end
	end
	self.rightPoolItemList=nil
	self.poolItemList = nil
end

function ChatNewPanel:GetSystemItemFromPool()
	for i = 1, #self.systemPoolItemList do
		if self.systemPoolItemList[i].ui.parent == nil then
			return self.systemPoolItemList[i]
		end
	end
	if #self.systemPoolItemList <= self.systemPoolMax then
		local item = ContentSystem.New()
		table.insert(self.systemPoolItemList, item)
		return item
	else
		return self.systemPoolItemList[1]
	end
end

function ChatNewPanel:DestorySystemPool()
	if self.systemPoolItemList then
		for i = 1, #self.systemPoolItemList do
			self.systemPoolItemList[i]:Destroy()
		end
	end
	self.systemPoolItemList = nil
	self.poolItemList = nil
end
