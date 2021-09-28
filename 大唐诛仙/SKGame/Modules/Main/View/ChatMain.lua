ChatMain =BaseClass(LuaUI)

ChatMain.RecordMax = 300

function ChatMain:__init( ... )
	self.URL = "ui://0042gnitom7mbn"
	self:__property(...)
	self:Config()
	self:AddEvent()
end
function ChatMain:SetProperty( ... )
end
function ChatMain:Config()
	if not self.reloginHandle then
		self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function ()
			if self.msgList then
				self.msgList:RemoveChildrenToPool()
			end
		end)
	end
end

-- Register UI classes to lua
function ChatMain:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","ChatMain");

	self.bg = self.ui:GetChild("bg")
	self.lin = self.ui:GetChild("lin")
	self.msgList = self.ui:GetChild("msgList")
	self.btnExtend = self.ui:GetChild("BtnExtend")
	self.btnAuto = self.ui:GetChild("BtnAuto")
	self.btnEmail = self.ui:GetChild("BtnEmail")
	self.mailRed = self.ui:GetChild("mailRed")
	self.mailRed.y = self.mailRed.y + 48
	self.btnEmail:AddChild(self.mailRed)
	self.btenVoiceWorld = self.ui:GetChild("BtenVoiceWorld")
	self.expandControl = self.ui:GetTransition("ExpandControl")
	self.btnRenshu = self.ui:GetChild("BtnRenshu")
	self.btn_siliaoTip = self.ui:GetChild("btn_siliaoTip")  --私聊提示按钮++++

	
	self.btn_siliaoTip.visible = false  --私聊++++++
	--标识是否已展开
	self.isExtend = false

	self.model = ChatNewModel:GetInstance()
	--主界面的聊天item
	self.mainChatItem = UIPackage.GetItemURL("Main","MainChatItem")
	--初始化先清掉
	self.msgList:RemoveChildrenToPool()

	self.chatData = {}
	-- self.btnAutoClickCount = 0
	self:SetMailTips(LoginModel:GetInstance():GetHaveNewMail() == 1)
	self:InitEvent()
end

function ChatMain:InitEvent()
	--聊天窗口 
	self.msgList.onClick:Add(self.ClickBackList,self)
	--邮件窗口
	self.btnEmail.onClick:Add(function ()
		self:SetMailTips(false)
		EmailController:GetInstance():Open()
	end)
	--监听后端发来的信息
	self.handler=self.model:AddEventListener(ChatNewConst.ReceiveMsg,function ( data )
		self:SendMessageCallBack(data)
	end)
	self.hanlder1 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED, function(data)
		self:SetMailTips(LoginModel:GetInstance():GetHaveNewMail() == 1)
	end)
	--展开
	self.btnExtend.onClick:Add(self.ClickBackExtend,self)
	-- 自动战斗
	self.btnAuto.onClick:Add(self.AutoFight,self)
	self.btnRenshu.onClick:Add(self.OnRenshuCLick, self)
	self.btn_siliaoTip.onClick:Add(function ()         --s私聊提示 按钮+++++++++++
		FriendController:GetInstance():IsFriendChat(self.chatData)
		MainUIModel:GetInstance().isClickPrivateChat = 1
		if self.btn_siliaoTip then
			self.btn_siliaoTip.visible = false
		end
		GlobalDispatcher:DispatchEvent(EventName.IsClickPrivate)
	end)

end

function ChatMain:AddEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.FriendChat , function()
		if self.btn_siliaoTip.visible == false then
			self.btn_siliaoTip.visible = true
			self.btn_siliaoTip:GetChild("numSiliao").text = 1
			self.model.chatNum = 1
		else
			self.btn_siliaoTip:GetChild("numSiliao").text = tonumber(self.btn_siliaoTip:GetChild("numSiliao").text) + 1
			self.model.chatNum = self.model.chatNum + 1
		end
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function()
		self.btn_siliaoTip.visible = false
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.IsClickPrivate, function ()
		if MainUIModel:GetInstance().isClickPrivateChat == 0 then
			self.btn_siliaoTip.visible = true
		else
			self.btn_siliaoTip.visible = false
		end
	end)
end


-- 设置邮件提示
function ChatMain:SetMailTips(bool)
	self.mailRed.visible = (bool == true)
end

function ChatMain:AutoFight()
	local scene = SceneController:GetInstance():GetScene()
	local isTower = SceneModel:GetInstance():IsTower()
	TaskModel:GetInstance():BreakAuto()
	if scene then
		local autoFight = scene:GetAutoFightCtr()
		if autoFight:IsAutoFighting() then
			autoFight:Stop(true)
			if isTower then
				TowerModel:GetInstance().autoAttack = false
			end
		else
			autoFight:Start(true)
			if isTower then
				TowerModel:GetInstance().autoAttack = true
			else
				TaskModel:GetInstance():ContinueAuto()
			end
		end
	end
end

--展开 - 缩放
function ChatMain:ClickBackExtend()
	self.isExtend = not self.isExtend
	if self.isExtend then
		self.expandControl:Play()
	else
		self.expandControl:PlayReverse()
	end
end



function ChatMain:RemoveEvent()
	self.model:RemoveEventListener(self.handler)
end

--服务器同意发送聊天信息返回
function ChatMain:SendMessageCallBack(msg)
	--收集自己说过的历史信息
	--table.insert(self.model.player_message_sended_list_,self.prepare_send_massege_)
	self:AddOneMsgToMessageList(msg)
end

function ChatMain:AddOneMsgToMessageList( msg )
	local chtaItem = self.msgList:AddItemFromPool(self.mainChatItem)

	local tf = chtaItem:GetChild("text")
		tf.width = tf.initWidth 
	local icon = chtaItem:GetChild("icon")
	icon.url = ""
	local Channel = ChatNewModel.Channel
	if msg.type ==	Channel.System then --系统
		if msg.isOperateMsg then
			icon.url = "Icon/Chat/9"
		else
			icon.url = "Icon/Chat/6"
		end
	elseif msg.type ==	Channel.World then --世界 
		icon.url = "Icon/Chat/5"
	elseif msg.type ==	Channel.Near then --附近 
		icon.url = "Icon/Chat/4"
	elseif msg.type ==	Channel.Family then --家族 
		icon.url = "Icon/Chat/2"
	elseif msg.type ==	Channel.Clan then --clan 
		icon.url = "Icon/Chat/10"
	elseif msg.type ==	Channel.Team then --队伍 
		icon.url = "Icon/Chat/7"
	elseif msg.type ==	Channel.Trumpet then --喇叭 
		icon.url = "Icon/Chat/8"
	elseif msg.type == Channel.Self then --私聊
		icon.url = "Icon/Chat/1"
	end
	local size = tf.textFormat.size + 2 
	if msg.sendPlayerName == nil or msg.sendPlayerName == "" then --系统f
		local str = StringFormat("[color=#60bdf2][/color]{0}", msg.content2) 
		tf.text = string.gsub(UBBParserExtension:Parse( str ), "<img ", "<img width="..size.." height="..size.." ")
	else
		if msg.type == Channel.Self then
			if ChatNewModel:GetInstance():IsMainPlayerSay(msg) then
				local str = StringFormat("[color=#8a8cf4]我悄悄对[color=#60bdf2][{0}][/color]说: {1}[/color]", msg.toPlayerName, msg.content2)
				tf.text = string.gsub(UBBParserExtension:Parse( str ), "<img ", "<img width="..size.." height="..size.." ")
			else
				local str = StringFormat("[color=#60bdf2][{0}][/color][color=#8a8cf4]悄悄对你说: {1}[/color]", msg.sendPlayerName, msg.content2) 
				tf.text = string.gsub(UBBParserExtension:Parse( str ), "<img ", "<img width="..size.." height="..size.." ")
				self.chatData = {}
				self.chatData.sendPlayerLevel = msg.sendPlayerLevel
				self.chatData.sendPlayerCareer = msg.sendPlayerCareer
				self.chatData.sendPlayerId = msg.sendPlayerId
				self.chatData.online = 1
				self.chatData.sendPlayerName = msg.sendPlayerName
				self.chatData.sendPlayerId = msg.sendPlayerId ------------------------------
			end
			
		else
			local str = StringFormat("[color=#60bdf2][{0}][/color]  {1}", msg.sendPlayerName, msg.content2)  
			tf.text = string.gsub(UBBParserExtension:Parse( str ), "<img ", "<img width="..size.." height="..size.." ")
		end
	end
	tf.width = tf.textWidth
	self.msgList.scrollPane:ScrollBottom(true)

	if self.msgList.numItems > ChatMain.RecordMax then
		self.msgList:RemoveChildToPoolAt(0)
	end
end

function ChatMain:ByStrGetLen()
	-- body
end

function ChatMain:ClickBackList(contenxt)
	GlobalDispatcher:DispatchEvent(EventName.WoldChat)
end

-- Combining existing UI generates a class
function ChatMain.Create( ui, ...)
	return ChatMain.New(ui, "#", {...})
end

-- Dispose use ChatMain obj:Destroy()
function ChatMain:__delete()
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	self.msgList.onClick:Remove(self.ClickBackList,self)
	
	self.btnExtend.onClick:Remove(self.ClickBackExtend,self)
	self.btnAuto.onClick:Remove(self.AutoFight,self)
	self.bg = nil
	self.lin = nil
	self.msgList = nil
	self.btnExtend = nil
	self.btnAuto = nil
	self.btnEmail = nil
	self.btenVoiceWorld = nil
	self.expandControl = nil
	self:RemoveEvent()
end

function ChatMain:SetIsTianti(isTianti)
	self.btnExtend.visible = not isTianti
	self.btnAuto.visible = not isTianti
	self.btnEmail.visible = not isTianti
	self.btnRenshu.visible = isTianti
end

function ChatMain:OnRenshuCLick()
	UIMgr.Win_Confirm("认输确认", StringFormat("是否认输？"), "确定", "取消",
		function ()
			TiantiController:GetInstance():C_GiveUp()
		end,
	nil)
end