ContentRight = BaseClass(LuaUI)

function ContentRight:__init(...)
	self.URL = "ui://m2d8gld1cdsbq";
	self:__property(...)
	self:Config()
end

function ContentRight:SetProperty(...)
	
end

function ContentRight:Config()
	
end

function ContentRight:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","ContentRight");

	self.msgBg = self.ui:GetChild("msgBg")
	self.nameText = self.ui:GetChild("nameText")
	self.playerIcon = self.ui:GetChild("playerIcon")
	self.msgText = self.ui:GetChild("msgText")
	self.vip = self.ui:GetChild("vip")
	self.infoClick = self.ui:GetChild("infoClick")

   	self.lvTxt = self.playerIcon:GetChild("title"):GetChild("title")
   	self.icon = self.playerIcon:GetChild("icon"):GetChild("icon")

   	self.type = 1 --0:左 1:右 2:系统
end

function ContentRight.Create(ui, ...)
	return ContentRight.New(ui, "#", {...})
end

function ContentRight:SetData(chatVo)
	self.msgText.onClickLink:Clear()
	self.msgText.onClick:Clear()
	self.playerIcon.onClick:Clear()

	self.chatVo = chatVo
	self.nameText.text = chatVo.sendPlayerName

	local size = self.msgText.textFormat.size + 2
	self.msgText.text = string.gsub(getRichTextContent(chatVo.content), "<img ", "<img width="..size.." height="..size.." ")

	self.lvTxt.text = chatVo.sendPlayerLevel
	self.icon.url ="Icon/Head/r1"..chatVo.sendPlayerCareer

	if chatVo.sendPlayerVip ~= nil and chatVo.sendPlayerVip > 0 then
		if chatVo.sendPlayerVip == 1 then
			self.vip.url = "Icon/Vip/vip1"
		elseif chatVo.sendPlayerVip == 2 then
			self.vip.url = "Icon/Vip/vip2"
		elseif chatVo.sendPlayerVip == 3 then
			self.vip.url = "Icon/Vip/vip3"
		end
		self.nameText.x = self.vip.x - 10 - self.nameText.width
	end

	if self.chatVo.hasLink then
		self.msgText.onClickLink:Add(self.OnClickLinkHandler, self)
		self.msgText.onClick:Add(self.OnClickTxtHandler, self)
	end
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayer and mainPlayer.playerId and mainPlayer.playerId ~= self.chatVo.sendPlayerId then
		self.infoClick.onClick:Add(self.OnClickHandler, self)
	end

	self.msgBg.width = self.msgText.textWidth + 30
	self.msgBg.x = 397 - self.msgBg.width
	self.msgBg.height = self.msgText.textHeight + 22

	self.msgText.x = 376 - self.msgText.textWidth

	self.clickTxtX = 0
	self.clickTxtY = 0
end

function ContentRight:GetHeight()
	return self.msgBg.y + self.msgBg.height + 10
end

function ContentRight:OnClickHandler(e)
	local data = {}
	data.playerId = self.chatVo.sendPlayerId
	local PFType = PlayerFunBtn.Type
	data.funcIds = {PFType.CheckPlayerInfo, PFType.AddFriend, PFType.Chat, PFType.InviteTeam, PFType.EnterTeam}
	GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
end

function ContentRight:OnClickTxtHandler(e)
	local data = e.data
	local pos = self.ui:LocalToGlobal(Vector2.New(data.x, data.y))

	self.clickTxtX = pos.x
	self.clickTxtY = pos.y
end

function ContentRight:OnClickLinkHandler(e)
	local strInfo = StringSplit(e.data, "_")
	local hType = tonumber(strInfo[1])
	local id = tonumber(strInfo[2])
	local pId = tonumber(strInfo[3])
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.ClickLink, {hType, id, pId, self.clickTxtX, self.clickTxtY})
end

function ContentRight:__delete()
	self.msgText.onClickLink:Clear()
end