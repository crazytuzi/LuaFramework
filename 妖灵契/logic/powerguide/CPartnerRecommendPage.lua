local CPartnerRecommendPage = class("CPartnerRecommendPage", CBox)

function CPartnerRecommendPage.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitPage()
end

function CPartnerRecommendPage.InitPage(self)
	self.m_PartnerPart = self:NewUI(1, CBox)
	self.m_RecommendPart = self:NewUI(2, CRecommendPart)
	self.m_PartnerBox = self:NewUI(3, CBox)
	self.m_PartnerGrid = self:NewUI(4, CGrid)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_BtnGrid = self:NewUI(6, CGrid)
	self.m_RecommendPart.m_PartnerView = self
	self:InitContent()
end

function CPartnerRecommendPage.InitContent(self)
	self.m_PartnerBoxArr = {}
	local nameList = {"全部", "精英伙伴", "传说伙伴",}
	self.m_BtnGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Btn = oBox:NewUI(1, CLabel)
		oBox.m_SelectedMask = oBox:NewUI(2, CLabel)
		oBox.m_Btn:SetActive(true)
		oBox.m_SelectedMask:SetActive(false)
		if idx == 1 then
			oBox.m_Rare = 0
		else
			oBox.m_Rare = idx - 1
		end
		oBox.m_Btn:SetText(nameList[idx])
		oBox.m_SelectedMask:SetText(nameList[idx])
		oBox:AddUIEvent("click", callback(self, "OnSelectRare", oBox.m_Rare))
		return oBox
	end)
	self.m_PartnerBox:SetActive(false)

	self:OnSelectRare(0)
	self:ShowMain()
end

function CPartnerRecommendPage.HasPartner(self, partnerType)
	if self.m_PartnerDic == nil then
		self.m_PartnerDic = {}
		local partnerList = g_PartnerCtrl:GetPartners()
		for k,v in pairs(partnerList) do
			self.m_PartnerDic[v:GetValue("partner_type")] = true
		end
	end
	return self.m_PartnerDic[partnerType]
end

function CPartnerRecommendPage.ShowMain(self)
	self.m_PartnerPart:SetActive(true)
	self.m_RecommendPart:SetActive(false)
	-- self.m_ScrollView:ResetPosition()
end

function CPartnerRecommendPage.OnSelectRare(self, iRare)
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn.m_SelectedMask:SetActive(false)
		self.m_CurrentBtn.m_Btn:SetActive(true)
	end
	self.m_CurrentBtn = self.m_BtnGrid:GetChild(iRare + 1)
	self.m_CurrentBtn.m_SelectedMask:SetActive(true)
	self.m_CurrentBtn.m_Btn:SetActive(false)
	
	local partnerList = self:GetPartnerList(iRare)
	for i,v in ipairs(partnerList) do
		if self.m_PartnerBoxArr[i] == nil then
			self.m_PartnerBoxArr[i] = self:CreatePartnerBox()
			self.m_PartnerGrid:AddChild(self.m_PartnerBoxArr[i])
		end
		self.m_PartnerBoxArr[i]:SetActive(true)
		self.m_PartnerBoxArr[i]:SetData(v)
	end
	for i = #partnerList + 1, #self.m_PartnerBoxArr do
		self.m_PartnerBoxArr[i]:SetActive(false)
	end
	self.m_ScrollView:ResetPosition()
	-- g_PartnerCtrl:IsGetPartner(pid)

end

function CPartnerRecommendPage.CreatePartnerBox(self)
	local oPartnerBox = self.m_PartnerBox:Clone()
	oPartnerBox.m_PartnerSprite = oPartnerBox:NewUI(1, CSprite)
	oPartnerBox.m_Label = oPartnerBox:NewUI(2, CLabel)
	oPartnerBox.m_BgSprite = oPartnerBox:NewUI(3, CSprite)
	oPartnerBox.m_GotMark = oPartnerBox:NewUI(4, CSprite)
	oPartnerBox:AddUIEvent("click", callback(self, "ShowCommend", oPartnerBox))
	oPartnerBox.m_ParentCls = self
	function oPartnerBox.SetData(self, oData)
		oPartnerBox.m_Data = oData
		oPartnerBox.m_PartnerSprite:SpriteAvatar(oData.icon)
		oPartnerBox.m_Label:SetText(oData.name)
		oPartnerBox.m_BgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(oData.rare))
		if g_PartnerCtrl:IsGetPartner(oData.partner_type) then
			oPartnerBox.m_GotMark:SetActive(true)
		else
			oPartnerBox.m_GotMark:SetActive(false)
		end
		-- if self:HasPartner(oData.partner_type) then
			-- oPartnerBox.m_PartnerSprite:SetGrey(false)
			-- oPartnerBox.m_BgSprite:SetGrey(false)
		-- else
			-- oPartnerBox.m_PartnerSprite:SetGrey(true)
			-- oPartnerBox.m_BgSprite:SetGrey(true)
		-- end
	end

	return oPartnerBox
end

function CPartnerRecommendPage.ShowCommend(self, oPartnerBox)
	self.m_PartnerPart:SetActive(false)
	self.m_RecommendPart:SetActive(true)
	self.m_RecommendPart:SetData(oPartnerBox.m_Data)
end

function CPartnerRecommendPage.ShowPartnerCommend(self, iParID)
	local v = data.partnerdata.DATA[iParID]
	if v then
		self.m_PartnerPart:SetActive(false)
		self.m_RecommendPart:SetActive(true)
		self.m_RecommendPart:SetData(v)
	end
end

function CPartnerRecommendPage.GetPartnerList(self, key)
	local list = {}
	for parid, v in pairs(data.partnerdata.DATA) do
		if data.partnerrecommenddata.PartnerGongLue[parid] then
			if v["show_type"] == 1 then
				if key == 0 then
					table.insert(list, v)
				else
					if key == v["rare"] then
						table.insert(list, v)
					end
				end
			end
		end
	end
	
	table.sort(list, function(a, b)
		local scoreA = 0
		local scoreB = 0
		if g_PartnerCtrl:IsGetPartner(a.partner_type) then
			scoreA = scoreA + 100
		end
		if g_PartnerCtrl:IsGetPartner(b.partner_type) then
			scoreB = scoreB + 100
		end
		scoreA = scoreA + a.rare
		scoreB = scoreB + b.rare
		if scoreA ~= scoreB then
			return scoreA > scoreB
		end
		if a["partner_type"] < b["partner_type"] then
			return true
		end
		return false
	end)
	return list
end

return CPartnerRecommendPage