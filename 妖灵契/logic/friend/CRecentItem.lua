local CRecentItem = class("CRecentItem", CBox)

function CRecentItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_LastLabel = self:NewUI(3, CLabel)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_ExpandBtn = self:NewUI(5, CButton)
	self.m_MsgAmountBtn = self:NewUI(6, CButton)
	self.m_SchoolSprite = self:NewUI(7, CSprite)
	self.m_RelationSprite = self:NewUI(8, CSprite)
	self.m_GradeLabel = self:NewUI(9, CLabel)

	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OpenFriend"))
end

function CRecentItem.SetMsgAmount(self, iAmount)
	if iAmount >0 then
		self.m_MsgAmountBtn:SetActive(true)
		self.m_MsgAmountBtn:SetText(string.format("%d", iAmount))
	else
		self.m_MsgAmountBtn:SetActive(false)
	end
end

function CRecentItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.shape)
		self:SetGrade(frdobj.grade)
		self:SetSchool(frdobj.school)
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetSchool()
	end
	self:SetLastMsg()
end

function CRecentItem.SetLastMsg(self)
	local msg = g_TalkCtrl:GetLastMsg(self.m_ID)
	if msg then
		self.m_LastLabel:SetText(msg:GetText())
	else
		self.m_LastLabel:SetText("")
	end
end


function CRecentItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CRecentItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CRecentItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade)
	else
		self.m_GradeLabel:SetText(0)
	end
end

function CRecentItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CRecentItem.SetRelation(self)
	-- body
end


function CRecentItem.OpenFriend(self)
	
end

return CRecentItem