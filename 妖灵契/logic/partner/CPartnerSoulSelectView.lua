local CPartnerSoulSelectView = class("CPartnerSoulSelectView", CViewBase)

function CPartnerSoulSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/ParSoulSelectView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CPartnerSoulSelectView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ItemBox = self:NewUI(3, CBox)
	self.m_ItemBox:SetActive(false)
	self:InitContent()
end

function CPartnerSoulSelectView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPartnerSoulSelectView.SetPartner(self, iParID, itemID)
	self.m_ParID = iParID
	self.m_ItemID = itemID
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	if not oPartner then
		return
	end
	local dSoulList = oPartner:GetParSoulList()
	self.m_Grid:Clear()
	for i = 1, 6 do
		if dSoulList[i] then
			local oBox = self.m_ItemBox:Clone()
			oBox:SetActive(true)
			oBox.m_SoulItem = oBox:NewUI(1, CParSoulItem)
			oBox.m_AttrLabel = oBox:NewUI(4, CLabel)
			oBox.m_SoulItem:AddUIEvent("click", callback(self, "OnClickPos", i))
			oBox.m_SoulItem:SetItem(dSoulList[i])
			oBox.m_AttrLabel:SetText(self:GetSoulAttr(dSoulList[i]))
			self.m_Grid:AddChild(oBox)
		end
	end
	self.m_Grid:Reposition()
end

function CPartnerSoulSelectView.SetSoulPlan(self, iItemID, dSoulList)
	self.m_ItemID = iItemID
	self.m_Grid:Clear()
	for i = 1, 6 do
		if dSoulList[i] then
			local oBox = self.m_ItemBox:Clone()
			oBox:SetActive(true)
			oBox.m_SoulItem = oBox:NewUI(1, CParSoulItem)
			oBox.m_AttrLabel = oBox:NewUI(4, CLabel)
			oBox.m_SoulItem:AddUIEvent("click", callback(self, "OnClickPlanPos", i))
			oBox.m_SoulItem:SetItem(dSoulList[i])
			oBox.m_AttrLabel:SetText(self:GetSoulAttr(dSoulList[i]))
			self.m_Grid:AddChild(oBox)
		end
	end
	self.m_Grid:Reposition()
end

function CPartnerSoulSelectView.SetCallBack(self, cb)
	self.m_ClickCallBack = cb
end

function CPartnerSoulSelectView.GetSoulAttr(self, iItemID)
	local oItem = g_ItemCtrl:GetItem(iItemID)
	local dAttrData = oItem:GetParSoulAttr()
	local dAttr2Name = data.partnerequipdata.EQUIPATTR
	local attrlist = {}
	for key, value in pairs(dAttrData) do
		local attrname = dAttr2Name[key]["name"]
		local attrvalue = ""
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			attrvalue = self:GetPrintPecent(value)
		else
			attrvalue = tostring(value)
		end
		table.insert(attrlist, attrname.."+"..attrvalue)
	end
	return table.concat(attrlist, "、")
end

function CPartnerSoulSelectView.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CPartnerSoulSelectView.OnClickPos(self, iPos)
	netpartner.C2GSUsePartnerSoul(self.m_ParID, self.m_ItemID, iPos)
	self:OnClose()
end

function CPartnerSoulSelectView.OnClickPlanPos(self, iPos)
	if self.m_ClickCallBack then
		self.m_ClickCallBack(self.m_ItemID, iPos)
	end
	self:OnClose()
end

return CPartnerSoulSelectView
