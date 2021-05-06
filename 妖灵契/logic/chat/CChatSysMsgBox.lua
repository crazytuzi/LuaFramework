local CChatSysMsgBox = class("CChatSysMsgBox", CBox)

function CChatSysMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MsgLabel = self:NewUI(1, CLabel)
	self.m_Msg = nil
end

function CChatSysMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(oMsg:GetChannelPrefixText())
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-23, 0))
	self.m_Msg = oMsg
end

return CChatSysMsgBox