local CChatMsgBox = class("CChatMsgBox", CBox)

function CChatMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_Msg = nil
end

function CChatMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(oMsg:GetChannelPrefixText())
	
	local sName = oMsg:GetName("name")
	self.m_NameLabel:SetText(sName)
	self.m_ID = oMsg:GetRoleInfo("pid")
	local iGrade = oMsg:GetRoleInfo("grade")
	if iGrade then
		self.m_GradeLabel:SetText(tostring(iGrade))
	else
		self.m_GradeLabel:SetText("")
	end
	self.m_IconSpr:SpriteAvatar(oMsg:GetShape())
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	self.m_IconSpr:AddUIEvent("longpress", callback(self, "OnATplayer", self.m_ID, sName))
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

function CChatMsgBox.AddChannel(self)
	if self.m_Msg then
		local sName = self.m_Msg:GetName("name")
		local channel = self.m_Msg:GetValue("channel")
		self.m_NameLabel:SetText(string.format("#ch<%d>%s", channel, sName))
	end
end

function CChatMsgBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		g_AttrCtrl:GetPlayerInfo(self.m_ID, define.PlayerInfo.Style.Default)
	end
end

function CChatMsgBox.OnATplayer(self, pid, name, box, bpress)
	if bpress then
		local str = LinkTools.GenerateATPlayerLink(pid, name)
		g_ChatCtrl:AppendInputMsg(str)
	end
end

return CChatMsgBox