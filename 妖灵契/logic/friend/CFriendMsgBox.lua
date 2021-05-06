local CFriendMsgBox = class("CFriendMsgBox", CBox)

function CFriendMsgBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_Msg = nil
end

function CFriendMsgBox.SetMsg(self, oMsg)
	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(sText)
	
	self.m_ID = oMsg.m_ID
	
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	local shape = g_AttrCtrl.model_info.shape
	if frdobj and frdobj.shape then
		shape = frdobj.shape
	end
	
	self.m_IconSpr:SpriteAvatar(shape)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

function CFriendMsgBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		g_AttrCtrl:GetPlayerInfo(self.m_ID, define.PlayerInfo.Style.Default)
	end
end
return CFriendMsgBox