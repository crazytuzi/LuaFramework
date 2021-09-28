MsgUI =BaseClass(LuaUI)

function MsgUI:__init( ... )
	self.URL = "ui://0tyncec1rdc8br";
	self:__property(...)
	self:Config()
end
function MsgUI:SetProperty( ... )
end
function MsgUI:Config()
end
function MsgUI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","MsgUI");
	self.rollMsgUI = self.ui:GetChild("rollMsgUI")
	self.tipsMsgUI = self.ui:GetChild("tipsMsgUI")
	self.trumpetMsgUI = self.ui:GetChild("trumpetMsgUI")
	self.rollMsgUI = RollMsgUI.Create(self.rollMsgUI)
	self.rollMsgUI:SetVisible(false)
	self.tipsMsgUI = TipsMsgUI.Create(self.tipsMsgUI)
	self.trumpetMsgUI = TrumpetMsgUI.Create(self.trumpetMsgUI)
	self.trumpetMsgUI:SetVisible(false)
end

--滚动消息
function MsgUI:RollMsg(msg)
	if self.rollMsgUI then
		self.rollMsgUI:AddMsg(msg)
	end
end

--Tips消息
function MsgUI:TipsMsg(msg)
	if self.tipsMsgUI then
		self.tipsMsgUI:AddMsg(msg)
	end
end

--喇叭消息
function MsgUI:TrumpetMsg(msg)
	if self.trumpetMsgUI then
		self.trumpetMsgUI:AddMsg(msg)
	end
end

function MsgUI.Create( ui, ...)
	return MsgUI.New(ui, "#", {...})
end

function MsgUI:__delete()
	if self.rollMsgUI then
		self.rollMsgUI:Destroy()
	end
	if self.tipsMsgUI then
		self.tipsMsgUI:Destroy()
	end
	if self.trumpetMsgUI then
		self.trumpetMsgUI:Destroy()
	end
	self.rollMsgUI = nil
	self.tipsMsgUI = nil
	self.trumpetMsgUI = nil
end