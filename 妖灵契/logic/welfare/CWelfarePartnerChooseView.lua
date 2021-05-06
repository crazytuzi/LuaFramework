local CWelfarePartnerChooseView = class("CWelfarePartnerChooseView", CPartnerChooseView)

function CWelfarePartnerChooseView.InitContent(self)
	self.m_PartnerList = {}
	self.m_PartnerList[0] = {}
	for k,v in pairs(data.partnerdata.DATA) do
		if self.m_PartnerList[v.rare] == nil then
			self.m_PartnerList[v.rare] = {}
		end
		table.insert(self.m_PartnerList[v.rare], v)
		table.insert(self.m_PartnerList[0], v)
	end
	for k,v in pairs(self.m_PartnerList) do
		table.sort(v, callback(self, "SortFunc"))
	end
	
	CPartnerChooseView.InitContent(self)
end

function CWelfarePartnerChooseView.UpdateCard(self, obj, oPartner)
	if oPartner then
		obj:SetActive(true)
		obj.m_Texture:SetActive(false)
		obj.m_Texture:LoadCardPhoto(oPartner.icon, function () obj.m_Texture:SetActive(true) end)
		obj.m_AwakeSpr:SetActive(false)
		obj.m_RareLabel:SetLocalPos(Vector3.New(-38, 75, 0))
		obj.m_LockSpr:SetActive(false)
		obj.m_GradeLabel:SetText("1")
		local iRare = oPartner.rare + 2
		obj.m_OutBorderSpr:SetSpriteName("pic_card_out"..tostring(iRare))
		obj.m_InBorderSpr:SetSpriteName("pic_card_in"..tostring(iRare))
		obj.m_AwakeSpr:SetSpriteName("pic_card_awake"..tostring(iRare))
		obj.m_RareSpr:SetSpriteName("pic_card_rare"..tostring(iRare))
		obj.m_RareLabel:SetText(g_PartnerCtrl:GetRareText(iRare))
		obj.m_NameLabel:SetText(oPartner.name)
		local iStar = g_WelfareCtrl.m_BackList[oPartner.partner_type] or  1		
		for i = 1, 5 do
			if iStar >= i then
				obj.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
			else
				obj.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
			end
		end
		obj.m_ID = oPartner.partner_type
		obj:AddUIEvent("click", callback(self, "OnClickPartner", obj.m_ID))
	else
		obj.m_ID = nil
		obj:SetActive(false)
	end
end


function CWelfarePartnerChooseView.UpdateFilter(self, iKey)
	self.m_FilterKey = iKey
	self:RefreshContent()
end

function CWelfarePartnerChooseView.GetPartnerList(self)
	local newlist = {}
	local filterkey = self.m_FilterKey or 0

	for i,v in ipairs(self.m_PartnerList[filterkey]) do
		if g_WelfareCtrl:IsGotPartner(v.partner_type) then
			table.insert(newlist, v)
		end
	end

	self.m_AmountLabel:SetText("数量："..tostring(#newlist))
	newlist = self:GetDivideList(newlist)
	return newlist
end

function CWelfarePartnerChooseView.SortFunc(self, oPartner1, oPartner2)
	if oPartner1.rare ~= oPartner2.rare then
		return oPartner1.rare > oPartner2.rare
	end
	return oPartner1.partner_type < oPartner2.partner_type
end

function CWelfarePartnerChooseView.OnClickPartner(self, iParterID)
	if self.m_ConfirmCb then
		self.m_ConfirmCb(iParterID)
	end
	self:OnClose()
end

return CWelfarePartnerChooseView