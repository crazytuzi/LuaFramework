RegistModules("ChatNew/ChatNewConst")
RegistModules("ChatNew/ChatNewModel")
RegistModules("ChatNew/ChatNewView")

RegistModules("ChatNew/Vo/ChatVo")
RegistModules("ChatNew/Vo/NoticVo")

RegistModules("ChatNew/View/HistorySay")
RegistModules("ChatNew/View/SelectBtn")
RegistModules("ChatNew/View/TypeSelectCom")
RegistModules("ChatNew/View/TypeSelectPanel")
RegistModules("ChatNew/View/ContentRight") 
RegistModules("ChatNew/View/ContentLeft") 
RegistModules("ChatNew/View/ContentSystem") 
RegistModules("ChatNew/View/ChatInput") 
RegistModules("ChatNew/View/ChannelBtn")
RegistModules("ChatNew/View/ChatNewPanel")

ChatNewController =BaseClass(LuaController)

function ChatNewController:GetInstance()
	if ChatNewController.inst == nil then
		ChatNewController.inst = ChatNewController.New()
	end
	return ChatNewController.inst
end

function ChatNewController:__init()
	self.model = ChatNewModel:GetInstance()
	self.view = nil
	self:InitEvent()
	self:RegistProto()
end

function ChatNewController:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	ChatNewController.inst = nil
end

function ChatNewController:InitEvent()
	self.woldChatHandler = GlobalDispatcher:AddEventListener(EventName.WoldChat, function () self:Open() end)
	self.clickLinkHandler = ChatNewModel:GetInstance():AddEventListener(ChatNewConst.ClickLink, function (data) self:OnClickLink(data) end)

	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
			self.model:ReSet()
			if self.view then
				self.view:Destroy()
				self.view = ChatNewView.New()
			end
		end)
	end

end

function ChatNewController:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.woldChatHandler)

	ChatNewModel:GetInstance():RemoveEventListener(self.clickLinkHandler)
end

-- 协议注册
function ChatNewController:RegistProto()
	self:RegistProtocal("S_Chat")
	self:RegistProtocal("S_SynNotic")
	self:RegistProtocal("S_ShowEquipment")
	self:RegistProtocal("S_GetVoice")
	--离线消息列表++L
	self:RegistProtocal("S_GetOfflineInfo")
end

function ChatNewController:OnClickLink(data)
	local hType = data[1]
	local id = data[2]
	local pId = data[3]
	local x = data[4]
	local y = data[5]
	if hType == ChatVo.ParamType.Player then
		local data = {}
		data.playerId = tonumber(pId)
		local PFType = PlayerFunBtn.Type
		data.funcIds = {PFType.CheckPlayerInfo, PFType.AddFriend, PFType.Chat, PFType.InviteTeam, PFType.EnterTeam}
		GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
	elseif hType == ChatVo.ParamType.Item then
		local vo = GoodsVo.New()
		vo:SetCfg(GoodsVo.GoodType.item, id)
		CustomTipLayer.Show(vo, true)
	elseif hType == ChatVo.ParamType.Equipment and pId ~= nil and id ~= nil then
		self:C_ShowEquipment(pId, id)
	elseif hType == ChatVo.ParamType.Team then -- 加入队伍
		ZDCtrl:GetInstance():C_ApplyJoinTeam(id)
	elseif hType == ChatVo.ParamType.Family then --打开家族
		if FamilyModel:GetInstance():GetFamilyId() == 0 then
			FamilyCtrl:GetInstance():OpenInvite()
		else
			Message:GetInstance():TipsMsg("已加入家族")
		end
	end
end

function ChatNewController:S_GetOfflineInfo(buff)       --离线消息列表
	local msg = self:ParseMsg(chat_pb.S_GetOfflineInfo(), buff)
	FriendModel:GetInstance().offlineList = {}
	if msg.offlines and #msg.offlines > 0 then
		SerialiseProtobufList( msg.offlines, function ( item )      --已领取奖励id列表
			table.insert(FriendModel:GetInstance().offlineList, item)
		end )
		FriendModel:GetInstance():OffLineAddChat()
	end
end

function ChatNewController:C_GetOfflineInfo()			--获取离线消息列表+++L
	self:SendEmptyMsg(chat_pb, "C_GetOfflineInfo")
end

function ChatNewController:S_Chat(buff)
	local msg = self:ParseMsg(chat_pb.S_Chat(), buff)
	local chatVo = self.model:ParseChatData(msg)
	if chatVo and chatVo.type == ChatNewModel.Channel.Trumpet then
		local str = "[color=#60bdf2]["..chatVo.sendPlayerName.."][/color]:"..chatVo.content2
		Message:GetInstance():TrumpetMsg(str)
	end
end

function ChatNewController:S_SynNotic(buff)
	local msg = self:ParseMsg(chat_pb.S_SynNotic(), buff)
	local noticContent = self.model:ParseNoticData(msg)
	if noticContent then
		Message:GetInstance():RollMsg(noticContent)
	end
end

function ChatNewController:S_ShowEquipment(buff)
	local msg = self:ParseMsg(equipment_pb.S_ShowEquipment(), buff)
	local data = msg.showEquipment
	local vo = EquipInfo.New(data)
	CustomTipLayer.Show(vo:ToGoodsVo(), true, nil, vo)
end

function ChatNewController:C_ShowEquipment(showPlayerId, playerEquipmentId)
	local msg = equipment_pb.C_ShowEquipment()
	msg.showPlayerId = showPlayerId
	msg.playerEquipmentId = playerEquipmentId
	self:SendMsg("C_ShowEquipment", msg)
end

--聊天
--@param type 消息类型(类型说明 1:世界,2:工会,3:组队,4:私人,5:系统,6:附近,7:喇叭) 
--@param content 消息内容
--@param toPlayerId 接受者玩家ID (仅用于私聊) 
--@param params 参数[列表] 
function ChatNewController:C_Chat(type, content, toPlayerId, params)
	local msg = chat_pb.C_Chat()
	msg.type = type
	msg.content = filterSensitive(content)
	if toPlayerId then
		msg.toPlayerId = toPlayerId
	end
	if params then
		local paramStr = "{"
		for i = 1, #params do
			paramStr = paramStr.."{"
			paramStr = paramStr..params[i][1]..","
			paramStr = paramStr..params[i][2]..","
			paramStr = paramStr..params[i][3]..","
			paramStr = paramStr..params[i][4]
			paramStr = paramStr.."}"
		end
		paramStr = paramStr.."}"
		msg.param = paramStr
	end
	self:SendMsg("C_Chat", msg)
end

ChatNewController.ChatId = ""
function ChatNewController:S_GetVoice(buff)
	local msg = self:ParseMsg(chat_pb.S_GetVoice(), buff)
	local data = msg.voice
	print(tostring(data))
	Util.SetVoiceData(data)
end
function ChatNewController:C_GetVoice()
	local msg = chat_pb.C_GetVoice()
	msg.id = ChatNewController.ChatId
	self:SendMsg("C_GetVoice", msg)
end
function ChatNewController:C_PostVoice()
	local msg = chat_pb.C_PostVoice()
	msg.id = 'chat'..os.time()
	local data = Util.GetVoiceData()
	msg.voice = tostring(data)
	ChatNewController.ChatId = msg.id
	print(ChatNewController.ChatId, msg.voice, tostring(msg.voice), data)
	self:SendMsg("C_PostVoice", msg)
end


function ChatNewController:Open()
	if self.view == nil then
		self.view = ChatNewView.New()
	end
	self.view:OpenChatNewPanel()
end

function ChatNewController:Test()
	DelayCall(function() 
		self:AddOperationMsgByCfg(1140101, 3)
		self:Test()
	-- end, Mathf.Random(1, 3))
	end, 1)
end

function ChatNewController:AddMsg(channelId, content)
	if self.view then
		self.view:AddMsg(channelId, content)
	end
end 

function ChatNewController:AddChannelMsg(channelId, content)
	local chatVo = ChatVo.New()
	chatVo.content = content
	chatVo.content2 = content
	chatVo.type = channelId
	chatVo.hasLink = false
	chatVo.isFromPlayer = false
	chatVo.isOperateMsg = true
	self.model:AddOperateMsg(chatVo)
end

function ChatNewController:AddOperationMsg(content)
	local chatVo = ChatVo.New()
	chatVo.content = content
	chatVo.content2 = content
	chatVo.type = ChatNewModel.Channel.System
	chatVo.hasLink = false
	chatVo.isFromPlayer = false
	chatVo.isOperateMsg = true
	self.model:AddOperateMsg(chatVo)
end

function ChatNewController:AddEnemyMsg(enemyName, mapName)
	local chatVo = ChatVo.New()
	local msg = "[color=#fd852d]仇敌[color={0}][{1}][/color]正在: [color={2}]{3}[/color][/color]"
	local str1 = StringFormat(msg, ChatVo.RareColor2[6], enemyName, ChatVo.RareColor2[12], mapName )
	local str2 = StringFormat(msg, ChatVo.RareColor[6], enemyName, ChatVo.RareColor[12], mapName )
	chatVo.content = str1
	chatVo.content2 = str2
	chatVo.type = 5
	chatVo.hasLink = false
	chatVo.isFromPlayer = false
	chatVo.isOperateMsg = true
	self.model:AddOperateMsg(chatVo)
end

function ChatNewController:AddOperationMsgByCfg(itemId, num)
	local content1 = ""
	local content2 = ""
	local cfg = GetCfgData("item"):Get(itemId)
	local msg = "您获得了[color={0}][{1}][/color]x{2}"
	if cfg then
		content1 = StringFormat(msg, GoodsVo.RareColor2[cfg.rare], cfg.name, num)
		content2 = StringFormat(msg, GoodsVo.RareColor[cfg.rare], cfg.name, num)
	else
		cfg = GetCfgData("equipment"):Get(itemId)
		if cfg then
			content1 = StringFormat(msg, GoodsVo.RareColor2[cfg.rare], cfg.name, num)
			content2 = StringFormat(msg, GoodsVo.RareColor[cfg.rare], cfg.name, num)
		end
	end

	if content1 == "" or content2 == "" then return end

	local chatVo = ChatVo.New()
	chatVo.content = content1
	chatVo.content2 = content2
	chatVo.type = ChatNewModel.Channel.System
	chatVo.hasLink = false
	chatVo.isFromPlayer = false
	chatVo.isOperateMsg = true
	self.model:AddOperateMsg(chatVo)
end

function ChatNewController:DestroyChatNewPanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
end

function ChatNewController:Close()
	if self.view then 
		self.view:Close()
	end
end