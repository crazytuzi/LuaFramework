local COrgInfoBox = class("COrgInfoBox", CBox)

function COrgInfoBox.ctor(self, cb)
	CBox.ctor(self, cb)
	self:InitContent()
end

function COrgInfoBox.InitContent(self)
	self.m_AvatarSprite = self:NewUI(1, CSprite)
	self.m_NameBtn = self:NewUI(2, CLabel)
	self.m_GradeLabel = self:NewUI(3, CLabel)
	self.m_SchoolSprite = self:NewUI(4, CSprite)
	self.m_PowerLabel = self:NewUI(5, CLabel)
	self.m_Title = self:NewUI(6, CLabel)
	self.m_NameBtn:AddUIEvent("click", callback(self, "OnClickName"))
end

function COrgInfoBox.OnClickName(self)
	if self.m_Data.pid ~= g_AttrCtrl.pid then
		g_AttrCtrl:GetPlayerInfo(self.m_Data.pid, define.PlayerInfo.Style.WithoutPK)
	end
end

function COrgInfoBox.SetData(self, oData)
	self.m_Data = oData
	self.m_AvatarSprite:SetSpriteName(tostring(oData.shape))
	self.m_NameBtn:SetText("[u]" .. oData.name)
	self.m_GradeLabel:SetText(tostring(oData.grade))
	self.m_SchoolSprite:SpriteSchool(oData.school)
	self.m_PowerLabel:SetText(tostring(oData.power))
	self.m_Title:SetText(g_OrgCtrl:GetPosition(oData.position).pos)
end

return COrgInfoBox