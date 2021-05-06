local CPartnerUpStarResult = class("CPartnerUpStarResult", CViewBase)

function CPartnerUpStarResult.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/UpStarResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CPartnerUpStarResult.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSpr = self:NewUI(2, CSprite)
	self.m_StarGrid = self:NewUI(3, CGrid)
	self.m_StarGrid2 = self:NewUI(4, CGrid)
	self.m_StarSpr = self:NewUI(5, CSprite)
	self.m_MaxGradeLabel = self:NewUI(6, CLabel)
	self.m_HPLabel = self:NewUI(7, CLabel)
	self.m_HPLabel2 = self:NewUI(8, CLabel)
	self.m_DefenseLabel = self:NewUI(9, CLabel)
	self.m_DefenseLabel2 = self:NewUI(10, CLabel)
	self.m_AttackLabel = self:NewUI(11, CLabel)
	self.m_AttackLabel2 = self:NewUI(12, CLabel)
	self.m_ConfirmBtn = self:NewUI(13, CButton)
	self:InitContent()
end

function CPartnerUpStarResult.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_StarGrid:Clear()
	self.m_StarGrid2:Clear()
	self.m_StarSpr:SetActive(false)
	
	for i = 1, 5 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		self.m_StarGrid:AddChild(spr)
		local spr2 = self.m_StarSpr:Clone()
		spr2:SetActive(true)
		self.m_StarGrid2:AddChild(spr2)
	end
	self.m_StarGrid:Reposition()
	self.m_StarGrid2:Reposition()
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPartnerUpStarResult.UpdateResult(self, data)
	self.m_ID = data.parid
	for i, spr in ipairs(self.m_StarGrid:GetChildList()) do
		if i <= data.old_star then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end

	for i, spr in ipairs(self.m_StarGrid2:GetChildList()) do
		if i <= data.new_star then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ID)
	self.m_IconSpr:SpriteAvatar(oPartner:GetIcon())
	--self.m_MaxGradeLabel:SetText(tostring(data.max_grade))
	self:UpdateAttr(data.old_apply, data.new_apply)
end

function CPartnerUpStarResult.UpdateAttr(self, oldList, newList)
	for _, oApply in ipairs(oldList) do
		local obj = nil
		if oApply.key == "maxhp" then
			obj = self.m_HPLabel
		elseif oApply.key == "attack" then
			obj = self.m_AttackLabel
		elseif oApply.key == "defense" then
			obj = self.m_DefenseLabel
		end
		if obj then
			obj:SetText(tostring(oApply.value))
		end
	end

		for _, oApply in ipairs(newList) do
		local obj = nil
		if oApply.key == "maxhp" then
			obj = self.m_HPLabel2
		elseif oApply.key == "attack" then
			obj = self.m_AttackLabel2
		elseif oApply.key == "defense" then
			obj = self.m_DefenseLabel2
		end
		if obj then
			obj:SetText(tostring(oApply.value))
		end
	end
end

return CPartnerUpStarResult