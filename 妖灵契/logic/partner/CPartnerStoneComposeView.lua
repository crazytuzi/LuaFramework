CPartnerStoneComposeView = class("CPartnerStoneComposeView", CViewBase)

function CPartnerStoneComposeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerStoneComposeView.prefab", cb)
	self.m_ExtendClose = "Black"
	--self.m_GroupName = "main"
end

function CPartnerStoneComposeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_PopupBox = self:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_Grid = self:NewUI(4, CGrid)
	self.m_StoneItem = self:NewUI(5, CBox)
	self.m_ComposePart = self:NewUI(6, CBox)
	self.m_TipBtn = self:NewUI(7, CButton)
	self:InitContent()
end

function CPartnerStoneComposeView.InitContent(self)
	self:InitComposePart()
	self:InitPopupBox()
	self.m_StoneItem:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TipBtn:AddHelpTipClick("parstone_compose")
	self:RefreshList()
end

function CPartnerStoneComposeView.InitComposePart(self)
	local oPart = self.m_ComposePart
	self.m_ComposeItemList = {}
	for i = 1, 3 do
		self.m_ComposeItemList[i] = oPart:NewUI(i, CBox)
		self:InitComposeItem(self.m_ComposeItemList[i])
	end
	self.m_ResultItem = oPart:NewUI(4, CBox)
	self:InitComposeItem(self.m_ResultItem)
	self.m_ComposeBtn = oPart:NewUI(5, CButton)
	self.m_FastComposeBtn = oPart:NewUI(6, CButton)
	self.m_FastAmountLabel = oPart:NewUI(7, CLabel)
	self:ClearComposeItem()
	self:ClearResultItem()
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnCompose"))
	self.m_FastComposeBtn:AddUIEvent("click", callback(self, "OnFastCompose"))
end

function CPartnerStoneComposeView.InitComposeItem(self, oBox)
	oBox.m_NameLabel = oBox:NewUI(3, CLabel)
	oBox.m_IconSpr = oBox:NewUI(4, CSprite)
end

function CPartnerStoneComposeView.InitPopupBox(self)
	self.m_PopupBox:SetCallback(callback(self, "OnFilterChange"))
	local dTypeList = {"破坏符石", "圣灵符石", "光辉符石", "禁忌符石"}
	for k, v in ipairs(dTypeList) do
		self.m_PopupBox:AddSubMenu(v)
	end
	self.m_PopupBox:SetMainMenu("破坏符石")
	self.m_PopupBox:SetSelectedIndex(1)
end

function CPartnerStoneComposeView.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshList()
	end
end

function CPartnerStoneComposeView.InitStoneType(self, iType, iLevel)
	local dTypeList = {"破坏符石", "圣灵符石", "光辉符石", "禁忌符石"}
	self.m_PopupBox:SetMainMenu(dTypeList[iType])
	self.m_PopupBox:SetSelectedIndex(iType)
	self:OnFilterChange()
	if iLevel then
		self:SelectTargetLevel(iLevel)
	else
		self:DefaultSelect()
	end
end

function CPartnerStoneComposeView.RefreshList(self)
	local itemList = self:GetStoneList()
	self.m_Grid:Clear()
	for _, oItem in ipairs(itemList) do
		local oBox = self:CreateStoneItem()
		self:UpdateStoneItem(oBox, oItem)
		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CPartnerStoneComposeView.DefaultSelect(self)
	local oTarget = nil
	for _, oChild in ipairs(self.m_Grid:GetChildList()) do
		if not oTarget and oChild.m_Amount > 2 then
			oTarget = oChild
		end
	end
	if not oTarget then
		oTarget = self.m_Grid:GetChild(1)
	end
	if oTarget then
		local oItem = g_ItemCtrl:GetItem(oTarget.m_ID)
		if oItem then
			self:OnClickLeftItem(oItem)
		end
	end
end

function CPartnerStoneComposeView.SelectTargetLevel(self, iLevel)
	local oTarget = nil
	for _, oChild in ipairs(self.m_Grid:GetChildList()) do
		oChild.m_SelSpr:SetActive(false)
		if not oTarget and oChild.m_Level == iLevel then
			oTarget = oChild
		end
	end
	if oTarget then
		local oItem = g_ItemCtrl:GetItem(oTarget.m_ID)
		if oItem then
			self:OnClickLeftItem(oItem)
		end
	else
		self:OnClickLeftItem()
	end
end

function CPartnerStoneComposeView.GetStoneList(self)
	local itemList = g_ItemCtrl:GetPartnerStone()
	local resultList = {}
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("equip_pos") == self.m_EquipPos then
			table.insert(resultList, oItem)
		end
	end
	table.sort(resultList, function (a, b)
		if a:GetValue("level") ~= b:GetValue("level") then
			return a:GetValue("level") < b:GetValue("level")
		end
		return a.m_ID < b.m_ID
	end)
	return resultList
end

function CPartnerStoneComposeView.CreateStoneItem(self)
	local oBox = self.m_StoneItem:Clone()
	oBox.m_SelSpr = oBox:NewUI(1, CSprite)
	oBox.m_AmountLabel = oBox:NewUI(3, CLabel)
	oBox.m_IconSpr = oBox:NewUI(4, CSprite)
	oBox.m_SelSpr:SetActive(false)
	oBox:SetActive(true)
	return oBox
end

function CPartnerStoneComposeView.UpdateStoneItem(self, oBox, oItem)
	oBox.m_ID = oItem.m_ID
	oBox.m_Amount = oItem:GetValue("amount")
	oBox.m_Level = oItem:GetValue("level")
	oBox.m_AmountLabel:SetText(tostring(oItem:GetValue("amount")))
	oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
	oBox:AddUIEvent("click", callback(self, "OnClickLeftItem", oItem))
	oBox:AddUIEvent("longpress", callback(self, "OnPressStoneItem", oItem))
end

function CPartnerStoneComposeView.ClearComposeItem(self)
	for i = 1, 3 do
		local oItem = self.m_ComposeItemList[i]
		oItem.m_IconSpr:SetActive(false)
		oItem.m_NameLabel:SetText("")
		oItem.m_ID = nil
	end
	self.m_ID = nil
	self:ClearResultItem()
	self.m_FastAmountLabel:SetText("")
end

function CPartnerStoneComposeView.ClearResultItem(self)
	self.m_ResultItem.m_IconSpr:SetActive(false)
	self.m_ResultItem.m_NameLabel:SetText("")
end

function CPartnerStoneComposeView.UpdateComposeItem(self, oItem, iAmount)
	for i = 1, 3 do
		local oBox = self.m_ComposeItemList[i]
		if iAmount >= i then
			oBox.m_IconSpr:SetActive(true)
			oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
			oBox.m_NameLabel:SetText(oItem:GetValue("name"))
			oBox.m_ID = oItem.m_ID
		else
			oBox.m_IconSpr:SetActive(false)
			oBox.m_NameLabel:SetText("")
			oBox.m_ID = nil
		end
		oBox:AddUIEvent("click", callback(self, "OnShowTips"))
	end
	local iPos = oItem:GetValue("equip_pos")
	local iLevel = oItem:GetValue("level")
	if iLevel > 6 then
		self:ClearResultItem()
		return
	end
	self.m_FastAmountLabel:SetText(string.format("可合成：%d", math.floor(iAmount/3)))
	local iShape = 300000 + iPos * 10000 + iLevel + 1
	local oFakeItem = CItem.NewBySid(iShape)
	self.m_ResultItem.m_IconSpr:SetActive(true)
	self.m_ResultItem.m_IconSpr:SpriteItemShape(oFakeItem:GetValue("icon"))
	self.m_ResultItem.m_NameLabel:SetText(oFakeItem:GetValue("name"))
	self.m_ResultItem:AddUIEvent("click", function ()
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(iShape, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
	end)
end

function CPartnerStoneComposeView.SetResult(self, iShape)
	self:ClearComposeItem()
	local oItem = CItem.NewBySid(iShape)
	self.m_ResultItem.m_IconSpr:SetActive(true)
	self.m_ResultItem.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
	self.m_ResultItem.m_NameLabel:SetText(oItem:GetValue("name"))
end

function CPartnerStoneComposeView.SetSelItem(self, iItemID)
	for _, oChild in ipairs(self.m_Grid:GetChildList()) do
		oChild.m_SelSpr:SetActive(oChild.m_ID == iItemID)
	end
end

function CPartnerStoneComposeView.OnFilterChange(self)
	local idx = self.m_PopupBox:GetSelectedIndex()
	if self.m_EquipPos ~= idx then
		self.m_EquipPos = idx
		self:RefreshList()
		self:ClearComposeItem()
		self:DefaultSelect()
	end
end

function CPartnerStoneComposeView.OnClickLeftItem(self, oItem)
	if not oItem then
		self:ClearComposeItem()
		self:ClearResultItem()
		return
	end
	local iAmount = oItem:GetValue("amount")
	if iAmount > 0 then
		self:UpdateComposeItem(oItem, iAmount)
		self.m_ID = oItem:GetValue("sid")
		self:SetSelItem(oItem.m_ID)
	end
end

function CPartnerStoneComposeView.OnPressStoneItem(self, oItem, oBox, bPress)
	if bPress then
		if oItem then
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItem:GetValue("sid"), {widget = oBox}, nil)
		end
	end
end

function CPartnerStoneComposeView.OnShowTips(self, oBox)
	if oBox.m_ID then
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(self.m_ID, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
	end
end

function CPartnerStoneComposeView.OnCompose(self)
	if self.m_ID then
		netpartner.C2GSComposePartnerStone(self.m_ID)
	end
end

function CPartnerStoneComposeView.OnFastCompose(self)
	if self.m_ID then
		netpartner.C2GSComposePartnerStone(self.m_ID, 1)
	end
end

return CPartnerStoneComposeView