local CParSoulChangeTypeView = class("CParSoulChangeTypeView", CViewBase)

function CParSoulChangeTypeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerSoulChangeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CParSoulChangeTypeView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_ItemGird = self:NewUI(2, CGrid)
	self.m_CloneBox = self:NewUI(3, CBox)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self:InitContent()
end

function CParSoulChangeTypeView.InitContent(self)
	self.m_CloneBox:SetActive(false)
	--self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
end

function CParSoulChangeTypeView.SelectCoreType(self, iParID)
	self.m_CurParID = iParID
	self:UpdateCore()
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnSelectCoreType", iParID))
end

function CParSoulChangeTypeView.SelectPlanCoreType(self, cb)
	self.m_CurParID = nil
	self:UpdateCore()
	self.m_PlanCallBack = cb
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnSelectPlanCoreType"))
end

function CParSoulChangeTypeView.UpdateCore(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local recommandList = {}
	local bShowNice = false
	if oPartner then
		local oRecommendData = data.partnerrecommenddata.PartnerGongLue[oPartner:GetValue("partner_type")]
		if oRecommendData then
			recommandList = oRecommendData.equip_list
		end
		local bShowNice = true
	end
	local dData = data.partnerequipdata.ParSoulType
	local dKeyList = table.keys(dData)
	table.sort(dKeyList, function (a, b)
		local indexA = table.index(recommandList, a) or 99
		local indexB = table.index(recommandList, b) or 99
		if indexA < indexB then
			return true
		elseif indexA > indexB then
			return false
		else
			return a < b
		end
	end)

	for i, k in ipairs(dKeyList) do
		local d = dData[k]
		if d then
			local oBox = self.m_CloneBox:Clone()
			oBox:SetActive(true)
			oBox.m_UnSelectSpr = oBox:NewUI(1, CSprite)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_IconSprite = oBox:NewUI(3, CSprite)
			oBox.m_NameLabel = oBox:NewUI(4, CLabel)
			oBox.m_DescLabel = oBox:NewUI(5, CLabel)
			oBox.m_NiceSpr = oBox:NewUI(6, CSprite)
			oBox.m_NiceSpr:SetActive(i < 3 and bShowNice)
			oBox.m_UnSelectSpr:SetActive(true)
			oBox.m_SelectSpr:SetActive(false)
			oBox.m_Sid = k
			oBox.m_IconSprite:SpriteItemShape(d.icon)
			oBox.m_NameLabel:SetText(d.name)
			oBox.m_DescLabel:SetText(d["skill_desc"])
			self.m_ItemGird:AddChild(oBox)
			oBox:AddUIEvent("click", callback(self, "OnClickItem"))
		end
	end
	self.m_ItemGird:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CParSoulChangeTypeView.OnClickItem(self, oBox)
	if self.m_CurBox then
		self.m_CurBox.m_UnSelectSpr:SetActive(true)
		self.m_CurBox.m_SelectSpr:SetActive(false)
	end
	self.m_CurBox = oBox
	self.m_CurBox.m_UnSelectSpr:SetActive(false)
	self.m_CurBox.m_SelectSpr:SetActive(true)
end

function CParSoulChangeTypeView.OnSelectCoreType(self, iParID)
	if not self.m_CurBox then
		g_NotifyCtrl:FloatMsg("请选择核心类型")
		return
	end
	netpartner.C2GSUsePartnerSoulType(self.m_CurBox.m_Sid, {}, iParID)
	self:CloseView()
end

function CParSoulChangeTypeView.OnSelectPlanCoreType(self)
	if not self.m_CurBox then
		g_NotifyCtrl:FloatMsg("请选择核心类型")
		return
	end
	if self.m_PlanCallBack then
		self.m_PlanCallBack(self.m_CurBox.m_Sid)
	end
	self:CloseView()
end

return CParSoulChangeTypeView