ContentSystem = BaseClass(LuaUI)

function ContentSystem:__init(...)
	self.URL = "ui://m2d8gld1dj4d1s";
	self:__property(...)
	self:Config()
end

function ContentSystem:SetProperty(...)
	
end

function ContentSystem:Config()
	
end

function ContentSystem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ChatNew","ContentSystem");

	self.msgText = self.ui:GetChild("msgText")
	self.mark = self.ui:GetChild("mark")

	self.type = 2 --0:左 1:右 2:系统
end

function ContentSystem.Create(ui, ...)
	return ContentSystem.New(ui, "#", {...})
end


function ContentSystem:SetData(chatVo)
	self.msgText.onClickLink:Clear()
	self.msgText.onClick:Clear()

	self.chatVo = chatVo
	self.msgText.text = getRichTextContent(chatVo.content)

	if self.chatVo.type == ChatNewModel.Channel.System then --系统
		if self.chatVo.isOperateMsg then
			self.mark.url = "Icon/Chat/9"
		else
			self.mark.url = "Icon/Chat/6"
		end
	elseif self.chatVo.type == ChatNewModel.Channel.World then --世界
		self.mark.url = "Icon/Chat/5"
	elseif self.chatVo.type == ChatNewModel.Channel.Near then --附近
		self.mark.url = "Icon/Chat/4"
	elseif self.chatVo.type == ChatNewModel.Channel.Family then --家族
		self.mark.url = "Icon/Chat/2"
	elseif self.chatVo.type == ChatNewModel.Channel.Team then --队伍
		self.mark.url = "Icon/Chat/7"
	elseif self.chatVo.type == ChatNewModel.Channel.Trumpet then --喇叭
		self.mark.url = "Icon/Chat/8"
	end

	if self.chatVo.hasLink then
		self.msgText.onClick:Add(self.OnClickTxtHandler, self)
		self.msgText.onClickLink:Add(self.OnClickLinkHandler, self)
	end

	self.clickTxtX = 0
	self.clickTxtY = 0
end

function ContentSystem:OnClickLinkHandler(e)
	local strInfo = StringSplit(e.data, "_")
	local hType = tonumber(strInfo[1])
	local id = tonumber(strInfo[2])
	local pId = tonumber(strInfo[3])
	ChatNewModel:GetInstance():DispatchEvent(ChatNewConst.ClickLink, {hType, id, pId, self.clickTxtX, self.clickTxtY})
end

function ContentSystem:OnClickTxtHandler(e)
	local data = e.data
	local pos = self.ui:LocalToGlobal(Vector2.New(data.x, data.y))

	self.clickTxtX = pos.x
	self.clickTxtY = pos.y
end

function ContentSystem:GetHeight()
	return self.msgText.y + self.msgText.textHeight + 10
end

function ContentSystem:__delete()
end