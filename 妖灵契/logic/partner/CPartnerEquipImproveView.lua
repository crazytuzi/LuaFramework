CPartnerEquipImproveView = class("CPartnerEquipImproveView", CViewBase)

function CPartnerEquipImproveView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerEquipImproveView.prefab", cb)
	self.m_ExtendClose = "Black"
	--self.m_GroupName = "main"
end

function CPartnerEquipImproveView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TabGrid = self:NewUI(3, CGrid)

	self.m_UpGradePage = self:NewPage(5, CPartnerEquipUpGradePage)
	self.m_UpStarPage = self:NewPage(6, CPartnerEquipUpStarPage)
	self.m_StonePage = self:NewPage(7, CPartnerEquipStonePage)
	self:InitContent()
end

function CPartnerEquipImproveView.InitContent(self)
	self.m_TabGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn:SetGroup(self.m_TabGrid:GetInstanceID())
		return oBtn
	end)
	self.m_UpGradeBtn = self.m_TabGrid:GetChild(1)
	self.m_UpStarBtn = self.m_TabGrid:GetChild(2)
	self.m_StoneBtn = self.m_TabGrid:GetChild(3)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "ShowUpGradePage"))
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "ShowUpStarPage"))
	self.m_StoneBtn:AddUIEvent("click", callback(self, "ShowStonePage"))
end

function CPartnerEquipImproveView.SetItemData(self, oItem)
	self.m_CurItem = oItem
	self:ShowUpGradePage()
	self:UpdateRedSpr()
end

function CPartnerEquipImproveView.UpdateItem(self, oItem)
	self.m_CurItem = oItem
	self:UpdateRedSpr()
end

function CPartnerEquipImproveView.UpdateRedSpr(self)
	local oItem = self.m_CurItem
	if oItem then
		if oItem:IsPartnerEquipCanUpGrade() and not self.m_UpGradeBtn:GetSelected() then
			self.m_UpGradeBtn:AddEffect("RedDot")
		else
			self.m_UpGradeBtn:DelEffect("RedDot")
		end
		if oItem:IsPartnerEquipCanUpStar() and not self.m_UpStarBtn:GetSelected() then
			self.m_UpStarBtn:AddEffect("RedDot")
		else
			self.m_UpStarBtn:DelEffect("RedDot")
		end
		if oItem:GetParEquipUpStoneResult() and not self.m_StoneBtn:GetSelected() then
			self.m_StoneBtn:AddEffect("RedDot")
		else
			self.m_StoneBtn:DelEffect("RedDot")
		end
	end
end

function CPartnerEquipImproveView.ShowUpGradePage(self)
	self.m_UpGradeBtn:SetSelected(true)
	self:ShowSubPage(self.m_UpGradePage)
	self.m_CurPage = self.m_UpGradePage
	self.m_CurPage:SetItemData(self.m_CurItem)
end

function CPartnerEquipImproveView.ShowUpStarPage(self)
	self.m_UpStarBtn:SetSelected(true)
	self:ShowSubPage(self.m_UpStarPage)
	self.m_CurPage = self.m_UpStarPage
	self.m_CurPage:SetItemData(self.m_CurItem)
end

function CPartnerEquipImproveView.ShowStonePage(self)
	self.m_StoneBtn:SetSelected(true)
	self:ShowSubPage(self.m_StonePage)
	self.m_CurPage = self.m_StonePage
	self.m_CurPage:SetItemData(self.m_CurItem)
end

return CPartnerEquipImproveView