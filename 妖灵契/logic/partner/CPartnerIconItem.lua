local CPartnerIconItem = class("CPartnerIconItem", CBox)

function CPartnerIconItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BoderSpr = self:NewUI(1, CSprite)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_StarGrid = self:NewUI(3, CGrid)
	self.m_StarSpr = self:NewUI(4, CSprite)
	self.m_AwakeSpr = self:NewUI(5, CSprite)
	self.m_GradeLabel = self:NewUI(6, CLabel, false)
	self.m_StarSpr:SetActive(false)

	self:InitContent()
end

function CPartnerIconItem.InitContent(self)
	self.m_StarGrid:Clear()
	for i = 1, 5 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		self.m_StarGrid:AddChild(spr)
	end
	self.m_StarGrid:Reposition()
end

function CPartnerIconItem.SetPartner(self, oPartner)
	self.m_ID = oPartner.m_ID
	if oPartner then
		self:ShowUI(true)
		self:UpdateShape(oPartner:GetIcon())
		self:UpdateStar(oPartner:GetValue("star"))
		self:UpdateBorder(oPartner:GetValue("rare"))
		self:UpdateAwake(oPartner:GetValue("awake"))
		self:UpdateGrade(oPartner:GetValue("grade"))
	else
		self:ShowUI(false)
	end
end

function CPartnerIconItem.ShowUI(self, bshow)
	self.m_Icon:SetActive(bshow)
	self.m_StarGrid:SetActive(bshow)
end

function CPartnerIconItem.UpdateShape(self, shape)
	if self.m_Icon:GetWidth() < 80 then
		self.m_Icon:SpriteAvatar(shape)
	else
		self.m_Icon:SpriteAvatarBig(shape)
	end
end

function CPartnerIconItem.UpdateGrade(self, grade)
	if self.m_GradeLabel then
		self.m_GradeLabel:SetText(string.format("%d", grade))
	end
end

function CPartnerIconItem.UpdateStar(self, star)
	for i, spr in ipairs(self.m_StarGrid:GetChildList()) do
		if star >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end


function CPartnerIconItem.UpdateBorder(self, rare)
	g_PartnerCtrl:ChangeRareBorder(self.m_BoderSpr, rare)
end

function CPartnerIconItem.UpdateAwake(self, awake)
	self.m_AwakeSpr:SetActive(awake == 1)
end

return CPartnerIconItem