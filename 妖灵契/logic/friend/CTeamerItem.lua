local CTeamerItem = class("CTeamerItem", CBox)

function CTeamerItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_OrgLabel = self:NewUI(3, CLabel)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_ExpandBtn = self:NewUI(5, CButton)
	self.m_GradeLabel = self:NewUI(6, CLabel)
	self.m_SchoolSprite = self:NewUI(7, CSprite)
	self.m_RelationSprite = self:NewUI(8, CSprite)
	
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "AddFriend"))
end

function CTeamerItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.shape)
		self:SetGrade(frdobj.grade)
		self:SetSchool(frdobj.school)
		self:SetOrg(frdobj.orgname)
		self:SetRelation()
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetSchool()
		self:SetRelation()
		self:SetOrg()
	end
	if g_FriendCtrl:IsMyFriend(pid) then
		self.m_ExpandBtn:SetActive(false)
	else
		self.m_ExpandBtn:SetActive(true)
	end
	self.m_Button:AddUIEvent("click", callback(self, "ShowTalk", pid))
end

function CTeamerItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CTeamerItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CTeamerItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade)
	else
		self.m_GradeLabel:SetText(0)
	end
end

function CTeamerItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CTeamerItem.SetOrg(self, sOrg)
	if sOrg then
		self.m_OrgLabel:SetText(sOrg)
	else
		self.m_OrgLabel:SetText("")
	end
end

function CTeamerItem.SetRelation(self, iDegree)
	if iDegree then
		self.m_RelationSprite:SetActive(true)
	else
		self.m_RelationSprite:SetActive(false)
	end
end

function CTeamerItem.ShowTalk(self)
	if self.m_ID then
		CFriendInfoView:ShowView(function (oView)
			oView:ShowTalk(self.m_ID)
		end)
	end
end

function CTeamerItem.AddFriend(self)
	if self.m_ID then
		g_FriendCtrl:ApplyFriend(self.m_ID)
	end
end

return CTeamerItem