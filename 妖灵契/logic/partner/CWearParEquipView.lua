local CWearParEquipView = class("CWearParEquipView", CViewBase)

function CWearParEquipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParEquipWearView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CWearParEquipView.OnCreateView(self)
	self.m_EquipPart = self:NewUI(1, CBox)
	self.m_ComparePart = self:NewUI(2, CBox)
	self.m_SelectPart = self:NewUI(3, CBox)
	self:InitContent()
end

function CWearParEquipView.InitContent(self)
	self:InitPart(self.m_EquipPart)
	self:InitPart(self.m_ComparePart)
	self:InitSelect()
end

function CWearParEquipView.InitSelect(self)
	self.m_ScrollView = self.m_SelectPart:NewUI(1, CScrollView)
	self.m_WrapContent = self.m_SelectPart:NewUI(2, CWrapContent)
	self.m_ItemObj = self.m_SelectPart:NewUI(3, CBox)
	self.m_ItemObj:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_ItemObj, callback(self, "SetWrapCloneChild"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "SetWrapRefreshFunc"))
end

function CWearParEquipView.SetItem(self, oItem)
	self:UpdateItemInfo(oItem, self.m_EquipPart)
	self.m_CurID = oItem.m_ID
	self.m_CurParID = oItem:GetValue("parid")
	self:RrefreshList()
end

function CWearParEquipView.InitPart(self, oPart)
	oPart.m_BG = oPart:NewUI(1, CSprite)
	oPart.m_NameLabel = oPart:NewUI(2, CLabel)
	oPart.m_AttrBox = oPart:NewUI(3, CBox)
	oPart.m_SubGrid = oPart:NewUI(4, CGrid)
	oPart.m_LockBtn = oPart:NewUI(5, CButton)
	oPart.m_UnLockBtn = oPart:NewUI(6, CButton)
	oPart.m_ParEquip = oPart:NewUI(7, CParEquipItem)
	oPart.m_WearBtn = oPart:NewUI(8, CButton)
	oPart.m_MainGrid = oPart:NewUI(9, CGrid)
	oPart.m_WearBtn:AddUIEvent("click", callback(self, "OnWearParEquip"))
	oPart.m_AttrBox:SetActive(false)
end

function CWearParEquipView.SetWrapCloneChild(self, oChild)
	oChild.m_NameLabel = oChild:NewUI(1, CLabel)
	oChild.m_ParEquipItem = oChild:NewUI(2, CParEquipItem)
	oChild.m_SelSpr = oChild:NewUI(3, CSprite)
	oChild.m_ParSpr = oChild:NewUI(4, CSprite)
	oChild:SetActive(true)
	oChild:AddUIEvent("click", callback(self, "OnSelectItem"))
	return oChild
end

function CWearParEquipView.SetWrapRefreshFunc(self, oChild, oItem)
	if oItem then
		oChild.m_NameLabel:SetText("等级："..tostring(oItem:GetValue("level")))
		oChild.m_ParEquipItem:SetItemData(oItem)
		oChild.m_ParEquipItem.m_LevelLabel:SetActive(false)
		oChild.m_SelSpr:SetActive(self.m_CompareID == oItem.m_ID)
		oChild.m_ID = oItem.m_ID
		local iParID = oItem:GetValue("parid")
		if iParID == 0 then
			oChild.m_ParSpr:SetActive(false)
		else
			local oPartner = g_PartnerCtrl:GetPartner(iParID)
			if oPartner then
				oChild.m_ParSpr:SetActive(true)
				oChild.m_ParSpr:SpriteWarAvatar(oPartner:GetShape())
			else
				oChild.m_ParSpr:SetActive(false)
			end
		end

		oChild:SetActive(true)
	else
		oChild:SetActive(false)
	end
end


function CWearParEquipView.IsValidOpen(cls, iItemID)
	local oCurItem = g_ItemCtrl:GetItem(iItemID)
	local dItemList = g_ItemCtrl:GetPartnerEquip()
	local dSortList = {}
	if oCurItem then
		for _, oItem in ipairs(dItemList) do
			if oItem:GetValue("pos") == oCurItem:GetValue("pos") and oItem.m_ID ~= oCurItem.m_ID then
				return true
			end
		end
	end
	g_NotifyCtrl:FloatMsg("无可进行更换的符文")
	return false
end

function CWearParEquipView.RrefreshList(self)
	local oCurItem = g_ItemCtrl:GetItem(self.m_CurID)
	local dItemList = g_ItemCtrl:GetPartnerEquip()
	local dSortList = {}
	for _, oItem in ipairs(dItemList) do
		if oItem:GetValue("pos") == oCurItem:GetValue("pos") and oItem.m_ID ~= oCurItem.m_ID then
			local dSortObj = {
				oItem,
				oItem:GetValue("star"),
				oItem:GetValue("level"),
				oItem:GetValue("stone_level"),
				oItem:GetValue("parid"),
				oItem.m_ID,
			}
			table.insert(dSortList, dSortObj)
		end
	end
	table.sort(dSortList, function (a, b)
		for i = 2, 6 do
			if a[i] ~= b[i] then
				return a[i] > b[i]
			end
		end
		return false
	end)
	local dResultList = {}
	for _, dSortObj in ipairs(dSortList) do
		table.insert(dResultList, dSortObj[1])
	end
	if dResultList[1] then
		self.m_CompareID = dResultList[1].m_ID
		self.m_CompareParID = dResultList[1]:GetValue("parid")
		local oCompareItem = g_ItemCtrl:GetItem(self.m_CompareID)
		self:UpdateItemInfo(oCompareItem, self.m_ComparePart)
	end
	self.m_WrapContent:SetData(dResultList, true)
end

function CWearParEquipView.UpdateItemInfo(self, oItem, oPart)
	if not oItem then
		return
	end
	local iType = 2
	if self.m_EquipPart == oPart then
		iType = 1
	end
	oPart.m_NameLabel:SetText(oItem:GetValue("name"))
	oPart.m_LockBtn:SetActive(false)
	oPart.m_UnLockBtn:SetActive(false)
	oPart.m_ParEquip:SetItemData(oItem)
	local mainattr = self:GetAttrList(oItem:GetValue("attr"))
	oPart.m_MainGrid:Clear()
	local curMainAttr = nil
	local curSubAttr = nil
	if iType == 2 then
		curMainAttr = self.m_AttrData[1]
		curSubAttr = self.m_AttrData[2]
	end
	for _, attrlist in ipairs(mainattr) do
		local box = oPart.m_AttrBox:Clone()
		box:SetActive(true)
		box.m_Name = box:NewUI(1, CLabel)
		box.m_Value = box:NewUI(2, CLabel)
		box.m_ChangeSpr = box:NewUI(3, CSprite, false)
		box.m_Name:SetText("[51E414]"..attrlist[1])
		box.m_Value:SetText("[51E414]"..attrlist[2])
		if iType == 2 and curMainAttr then
			box.m_ChangeSpr:SetActive(false)
			for _, obj in ipairs(curMainAttr) do
				if obj[3] == attrlist[3] then
					if obj[4] > attrlist[4] then
						box.m_ChangeSpr:SetActive(true)
						box.m_ChangeSpr:SetSpriteName("pic_xiajiang")
					elseif obj[4] < attrlist[4] then
						box.m_ChangeSpr:SetActive(true)
						box.m_ChangeSpr:SetSpriteName("pic_tisheng")
					end
				end
			end
		end
		oPart.m_MainGrid:AddChild(box)
	end
	oPart.m_MainGrid:Reposition()

	local subattr =self:GetStoneAttr(oItem)
	oPart.m_SubGrid:Clear()
	if #subattr == 0 then
		subattr ={{"吞食符石可增加符石属性", ""}}
	end
	for _, attrlist in ipairs(subattr) do
		local box = oPart.m_AttrBox:Clone()
		box:SetActive(true)
		box.m_Name = box:NewUI(1, CLabel)
		box.m_Value = box:NewUI(2, CLabel)
		box.m_ChangeSpr = box:NewUI(3, CSprite, false)
		box.m_Name:SetText("[51E414]"..attrlist[1])
		box.m_Value:SetText("[51E414]"..attrlist[2])
		if iType == 2 and curSubAttr and attrlist[3] then
			box.m_ChangeSpr:SetActive(false)
			for _, obj in ipairs(curSubAttr) do
				if obj[3] == attrlist[3] then
					if obj[4] > attrlist[4] then
						box.m_ChangeSpr:SetActive(true)
						box.m_ChangeSpr:SetSpriteName("pic_xiajiang")
					elseif obj[4] < attrlist[4] then
						box.m_ChangeSpr:SetActive(true)
						box.m_ChangeSpr:SetSpriteName("pic_tisheng")
					end
				end
			end
		end
		oPart.m_SubGrid:AddChild(box)
	end
	oPart.m_SubGrid:Reposition()
	if oPart == self.m_EquipPart then
		self.m_AttrData = {mainattr, subattr}
	end
end

function CWearParEquipView.GetAttrList(self, info)
	info = loadstring("return "..info)()
	local attrlist = {}
	if info and table.count(info) > 0 then
		for key, value in pairs(info) do
			local attrname = data.partnerequipdata.EQUIPATTR[key]["name"]
			local attrvalue = ""
			if string.endswith(key, "_ratio") or key == "critical_damage" then
				attrvalue = self:GetPrintPecent(value)
			else
				attrvalue = value
			end
			table.insert(attrlist, {attrname, attrvalue, key, value})
		end
	end
	return attrlist
end

function CWearParEquipView.GetStoneAttr(self, oItem)
	local dStoneInfo = oItem:GetValue("stone_info") or {}
	local dAttrDict = {}
	for _, dStone in ipairs(dStoneInfo) do
		for _, dApply in ipairs(dStone.apply_info) do
			dAttrDict[dApply.key] = dAttrDict[dApply.key] or 0
			dAttrDict[dApply.key] = dAttrDict[dApply.key] + dApply.value
		end
	end
	local d = data.partnerequipdata.EQUIPATTR
	local attrlist = {}
	for key, value in pairs(dAttrDict) do
		local attrname = d[key]["name"]
		local attrvalue = nil
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			attrvalue = self:GetPrintPecent(value)
		else
			attrvalue = value
		end
		table.insert(attrlist, {attrname, attrvalue, key, value})
	end
	return attrlist
end

function CWearParEquipView.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CWearParEquipView.OnSelectItem(self, oBox)
	local oItem = g_ItemCtrl:GetItem(oBox.m_ID)
	if oItem then
		self:UpdateItemInfo(oItem, self.m_ComparePart)
		self.m_CompareID = oItem.m_ID
		self.m_CompareParID =  oItem:GetValue("parid")
	end
	for _, obj in pairs(self.m_WrapContent:GetChildList()) do
		obj.m_SelSpr:SetActive(obj.m_ID == self.m_CompareID)
	end
end

function CWearParEquipView.OnWearParEquip(self)
	local oItem = g_ItemCtrl:GetItem(self.m_CurID)
	if self.m_CurID and self.m_CompareID then
		local iPos = oItem:GetValue("pos")
		if self.m_CompareParID ~= 0 then
			netpartner.C2GSSwapPartnerEquipByPos(self.m_CurParID, self.m_CompareParID, iPos, iPos)
		else
			netpartner.C2GSUsePartnerItem(self.m_CompareID, self.m_CurParID, 1)
		end
	end
	self:OnClose()
end

return CWearParEquipView