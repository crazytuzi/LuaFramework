local CFriendItem = class("CFriendItem", CBox)
	
function CFriendItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_SchoolSpr = self:NewUI(5, CSprite)
	self.m_GradeLabel = self:NewUI(6, CLabel)
	self.m_AmountLable = self:NewUI(7, CButton)
	self.m_RelationSprite = self:NewUI(8, CSprite)
	self.m_RelationSprite:AddUIEvent("click", callback(self, "OnShowInfo"))
end

function CFriendItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.shape)
		self:SetGrade(frdobj.grade)
		self:SetMsgAmount(g_TalkCtrl:GetNotify(pid))
		self:SetSchool(frdobj.school)
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetMsgAmount(g_TalkCtrl:GetNotify(pid))
	end
	self:SetOnlineState()
end

function CFriendItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CFriendItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CFriendItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(string.format("Lv：%d", iGrade))
	else
		self.m_GradeLabel:SetText(0)
	end
end

function CFriendItem.SetSchool(self, iSchool)
	self.m_SchoolSpr:SpriteSchool(iSchool)
end

function CFriendItem.SetMsgAmount(self, iAmount)
	if iAmount > 0 then
		self.m_AmountLable:SetActive(true)
		self.m_AmountLable:SetText(iAmount)
	else
		self.m_AmountLable:SetActive(false)
	end
end

function CFriendItem.SetOnlineState(self)
	if g_FriendCtrl:GetOnlineState(self.m_ID) then
		self.m_HeadSprite:SetGrey(false)
	else
		self.m_HeadSprite:SetGrey(true)
	end
end

function CFriendItem.SetGroup(self, iInstanceID)
	self.m_Button:SetGroup(iInstanceID)
end

function CFriendItem.OpenFriend(self)
	printc("OpenFriend")
end

function CFriendItem.OnShowInfo(self)
	if self.m_ID then
		g_AttrCtrl:GetPlayerInfo(self.m_ID, define.PlayerInfo.Style.Default)
	end
end

return CFriendItem