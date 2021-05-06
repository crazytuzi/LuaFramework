local CPartnerUpListPart = class("CPartnerUpListPart", CBox)

--伙伴升级 升星界面

function CPartnerUpListPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AmountLabel = self:NewUI(1, CLabel)
	self.m_SortPopupBox = self:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_FilterBox = self:NewUI(3, CBox)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_WrapContent = self:NewUI(7, CWrapContent)
	self.m_GridBox = self:NewUI(8, CBox)
	self.m_GridBox:SetActive(false)
	self.m_SelDict = {}
	self:InitContent()
end

function CPartnerUpListPart.InitContent(self)
	self.m_SortKey = "level"
	self.m_FilterKey = nil
	self:InitValue()
	self:InitPopupBox()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CPartnerUpListPart.InitPopupBox(self)
	self.m_SortPopupBox:Clear()
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
	local sortlist = {"稀有度", "星级", "等级"}
	
	for k, v in ipairs(sortlist) do
		self.m_SortPopupBox:AddSubMenu(v)
	end
	self.m_RareFilterGrid = self.m_FilterBox:NewUI(1, CGrid)
	self.m_StarFilterGrid = self.m_FilterBox:NewUI(2, CGrid)
	local rarelist = {0, 4, 3, 2, 1}
	self.m_RareFilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", rarelist[idx]))
		oBtn:SetGroup(self.m_RareFilterGrid:GetInstanceID())
		return oBtn
	end)

	self.m_StarFilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", idx))
		oBtn:SetGroup(self.m_StarFilterGrid:GetInstanceID())
		return oBtn
	end)

	self.m_FilterBox:SetActive(false)
	self:ResetScrollPos()
	self.m_SortPopupBox:SetSelectedIndex(1)
	--self:OnSortChange()
end

function CPartnerUpListPart.InitValue(self)
	self.m_WrapContent:SetCloneChild(self.m_GridBox, 
		function(oChild)
			oChild.m_IconList = {}
			for i = 1, 4 do
				local box = oChild:NewUI(i, CBox)
				box.m_SelSpr = box:NewUI(1, CSprite)
				box.m_PartnerItem = box:NewUI(2, CPartnerIconItem)
				box.m_StateSpr = box:NewUI(3, CSprite)
				box.m_StateIcon = box:NewUI(4, CSprite)
				box.m_AmountLabel = box:NewUI(5, CLabel)
				box.m_SelSpr:SetActive(false)
				box.m_StateSpr:SetActive(false)
				box.m_AmountLabel:SetActive(false)
				table.insert(oChild.m_IconList, box)
			end
			return oChild
		end)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			oChild:SetActive(true)
			for i = 1, 4 do
				local box = oChild.m_IconList[i]
				if dData[i] then
					box:SetActive(true)
					local oPartner = dData[i]
					box.m_ID = dData[i].m_ID
					box.m_PartnerItem:SetPartner(oPartner)
					box:AddUIEvent("click", callback(self, "OnClick", oPartner))
					if self.m_SelDict[box.m_ID] and self.m_SelDict[box.m_ID] > 0 then
						box.m_SelSpr:SetActive(true)
					else
						box.m_SelSpr:SetActive(false)
					end
					local bValidName = CPartnerUpGradePage:IsStatuValid(oPartner)
					if bValidName ~= true then
						box.m_StateSpr:SetActive(true)
						box.m_StateIcon:SetSpriteName("text_huoban_"..bValidName)
					else
						box.m_StateSpr:SetActive(false)
					end
					self:UpdateAmount(box, oPartner)
					if i == 1 and dData[i].m_IdxRow == 1 then
						g_GuideCtrl:AddGuideUI("partner_upgrade_list_1_1_partner_btn", box)
					end
					if dData[i]:GetValue("name") == "重华" then
						g_GuideCtrl:AddGuideUI("partner_upgrade_list_302_partner_btn", box)
					elseif dData[i]:GetValue("name") == "飞龙哥" then
						g_GuideCtrl:AddGuideUI("partner_upgrade_list_1150_partner_btn", box)
					end
				else
					box.m_ID = nil
					box:SetActive(false)
				end
			end
		else
			oChild:SetActive(false)
		end
	end)
end

function CPartnerUpListPart.UpdateAmount(self, box, oPartner)
	if oPartner:IsRedBun() then
		box.m_AmountLabel:SetActive(true)
		box.m_PartnerItem.m_StarGrid:SetActive(false)
		box.m_AmountLabel:SetText(string.format("×%d", oPartner:GetValue("amount")))
	else
		box.m_PartnerItem.m_StarGrid:SetActive(true)
		box.m_AmountLabel:SetActive(false)
	end
end

function CPartnerUpListPart.SetParentView(self, parent)
	self.m_ParentView = parent
end

function CPartnerUpListPart.SetClickCallback(self, callback)
	self.m_ClickCallBack = callback
end

function CPartnerUpListPart.SetPressCallback(self, callback)
	
end

function CPartnerUpListPart.SetFilterCallback(self, callback)
	self.m_FilterCallBack = callback
end

function CPartnerUpListPart.SetType(self, itype)
	self.m_Type = itype
	self:RefreshList()
end

function CPartnerUpListPart.SetPartnerID(self, parid)
	self.m_PartnerID = parid
	self.m_CurPartnerType = nil
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	if oPartner then
		self.m_CurPartnerType = oPartner:GetValue("partner_type")
	end
	self:RefreshList()
end

function CPartnerUpListPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self:RefreshList()
	end
end

function CPartnerUpListPart.OnSortChange(self, oBox)
	local idx = self.m_SortPopupBox:GetSelectedIndex()
	local t = {"rare", "star", "grade"}
	self.m_SortKey = t[idx]
	if not self:CreateFilter() then
		self:RefreshList()
	end
end

function CPartnerUpListPart.CreateFilter(self)
	local sKey = self.m_SortKey
	self.m_FilterBox:SetActive(false)
	self.m_RareFilterGrid:SetActive(false)
	self.m_StarFilterGrid:SetActive(false)
	self.m_FilterKey = nil
	if sKey then
		if sKey == "rare" then
			self:CreateRareFilter()
			self:ResetScrollPos()
			return true
		elseif sKey == "star" then
			self:CreateStarFilter()
			self:ResetScrollPos()
			return true
		end
	end
	self:ResetScrollPos()
	return false
end

function CPartnerUpListPart.CreateRareFilter(self)
	self.m_FilterBox:SetActive(true)
	self.m_RareFilterGrid:SetActive(true)
	local defaultbtn = self.m_RareFilterGrid:GetChild(1)
	if defaultbtn then
		defaultbtn:SetSelected(true)
		self:UpdateFilter(0)
	end
end

function CPartnerUpListPart.CreateStarFilter(self)
	self.m_FilterBox:SetActive(true)
	self.m_StarFilterGrid:SetActive(true)
	local defaultbtn = self.m_StarFilterGrid:GetChild(1)
	if defaultbtn then
		defaultbtn:SetSelected(true)
		self:UpdateFilter(1)
	end
end

function CPartnerUpListPart.UpdateFilter(self, key)
	self.m_FilterKey = key
	self:RefreshList()
end

function CPartnerUpListPart.ResetScrollPos(self)
	local bshow = self.m_FilterBox:GetActive()
	if bshow then
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, -25, 440, 470) )
		
	else
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, 0, 440, 520) )
	end
	self.m_ScrollView:ResetPosition()
end

function CPartnerUpListPart.GetPartnerList(self)
	local newlist = {}
	local filterkey = self.m_FilterKey or 0
	if self.m_SortKey == "rare" then
		newlist = g_PartnerCtrl:GetPartnerByRare(filterkey)
	elseif self.m_SortKey == "star" then
		newlist = g_PartnerCtrl:GetPartnerByStar(filterkey)
	else
		newlist = g_PartnerCtrl:GetPartnerByRare(0)
	end
	newlist = self:DoTypeFilter(newlist)
	table.sort(newlist, callback(self, "SortFunc"))
	if g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBSX_MainMenu") and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HBSX_PartnerMain") then
		newlist = self:SortPartnerByGuide(newlist, 1150)
	end
	self.m_PartnerList = newlist
	return newlist
end

function CPartnerUpListPart.DoTypeFilter(self, list)
	if self.m_FilterCallBack then
		local newlist = {}
		for _, oPartner in ipairs(list) do
			if self.m_FilterCallBack(oPartner) then
				table.insert(newlist, oPartner)
			end
		end
		return newlist
	end
	return list
end

function CPartnerUpListPart.SortFunc(self, oPartner1, oPartner2)
	local pos1 = g_PartnerCtrl:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = g_PartnerCtrl:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 > pos2
	end
	local t1 = oPartner1:GetValue("partner_type")
	local t2 = oPartner2:GetValue("partner_type")
	if t1 ~= t2 then
		if t1 == self.m_CurPartnerType then
			return true
		elseif t2 == self.m_CurPartnerType then
			return false
		end
		if t1 == 1754 then
			return true
		elseif t2 == 1754 then
			return false
		end
	end
	local iPowner1 = oPartner1:GetValue("power")
	local iPowner2 = oPartner2:GetValue("power")
	if iPowner1 and iPowner2 and iPowner1 ~= iPowner2 then
		return iPowner2 > iPowner1
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CPartnerUpListPart.RefreshList(self)
	local partnerlist = self:GetPartnerList()
	local dividelist = self:GetDivideList(partnerlist)
	self.m_WrapContent:SetData(dividelist, true)
	self.m_ScrollView:ResetPosition()
	self.m_AmountLabel:SetText(string.format("数量:%d", #partnerlist))
end

function CPartnerUpListPart.GetDivideList(self, list)
	local newlist = {}
	local data = {}
	local idxRow = 1	--伙伴列表的行数
	for i, oPartner in ipairs(list) do
		oPartner.m_IdxRow = idxRow
		table.insert(data, oPartner)
		if #data > 3 then
			table.insert(newlist, data)
			data = {}
			idxRow = idxRow + 1
		end
	end
	if #data > 0 then
		table.insert(newlist, data)
	end
	return newlist
end

function CPartnerUpListPart.GetGridList(self)
	local partnerlist = self.m_PartnerList
	local newlist = {}
	for _, oPartner in ipairs(partnerlist) do
		local iAmount = oPartner:GetValue("amount")
		local selAmount = self.m_SelDict[oPartner.m_ID] or 0
		if selAmount < iAmount then
			table.insert(newlist, {oPartner, selAmount})
		end
	end
	return newlist
end

function CPartnerUpListPart.OnClick(self, oItem)
	if self.m_ClickCallBack then
		self.m_ClickCallBack(oItem)
	end
end

function CPartnerUpListPart.OnPress(self, oItem, oBtn, bPress)
	if bPress then
		if self.m_PressCallBack then
			self.m_PressCallBack(oItem)
		else
			g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {})
		end
	end
end

function CPartnerUpListPart.SetSelectedPartner(self, parid, sel)
	if not parid then
		return
	end
	if sel then
		self.m_SelDict[parid] = self.m_SelDict[parid] or 0
		self.m_SelDict[parid] = self.m_SelDict[parid] + 1
	else
		self.m_SelDict[parid] = self.m_SelDict[parid] or 0
		self.m_SelDict[parid] = math.max(self.m_SelDict[parid]-1, 0)
	end
	sel = self.m_SelDict[parid]
	local breakflag = false
	for _, itemobj in pairs(self.m_WrapContent:GetChildList()) do
		if itemobj:GetActive() then
			for i = 1, 4 do
				local icon = itemobj.m_IconList[i]
				if icon.m_ID == parid then
					if sel > 0 then
						icon.m_SelSpr:SetActive(true)
					else
						icon.m_SelSpr:SetActive(false)
					end
					breakflag = true
					break
				end
			end
			if breakflag then
				break
			end
		end
	end
end

function CPartnerUpListPart.ClearSel(self)
	self.m_SelDict = {}
end

function CPartnerUpListPart.SortPartnerByGuide(self, partnerList, partner_type)
	local t = {}
	if partnerList and next(partnerList) then
		for i, v in ipairs(partnerList) do
			if v:GetValue("partner_type") == partner_type then
				table.insert(t, 1, v)
			else
				table.insert(t, v)
			end
		end
	end
	return t
end

return CPartnerUpListPart