local CPartnerEquipListPart = class("CPartnerEquipListPart", CBox)

--强化符文，合成符文界面 符文列表

function CPartnerEquipListPart.ctor(self, obj)
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

function CPartnerEquipListPart.InitContent(self)
	self.m_SortKey = "level"
	self.m_FilterKey = nil
	self:InitValue()
	self:InitPopupBox()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
end

function CPartnerEquipListPart.InitPopupBox(self)
	self.m_SortPopupBox:Clear()
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
	local sortlist = {"星级", "等级", "类型", "位置"}
	
	if self.m_Type == 2 then
		sortlist = {"星级", "等级", "类型", "位置"}
	elseif self.m_Type == 1 then
		self.m_SortKey = "level"
	end
	for k, v in ipairs(sortlist) do
		self.m_SortPopupBox:AddSubMenu(v)
	end

	self.m_PosFilterGrid = self.m_FilterBox:NewUI(1, CGrid)
	self.m_StarFilterGrid = self.m_FilterBox:NewUI(2, CGrid)
	self.m_FilterBox:SetActive(false)

	self.m_PosFilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", idx))
		oBtn:SetGroup(self.m_PosFilterGrid:GetInstanceID())
		return oBtn
	end)

	self.m_StarFilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", idx))
		oBtn:SetGroup(self.m_StarFilterGrid:GetInstanceID())
		return oBtn
	end)

	self.m_PosFilterGrid:SetActive(false)
	self.m_StarFilterGrid:SetActive(false)
	self:ResetScrollPos()
end

function CPartnerEquipListPart.InitValue(self)
	self.m_WrapContent:SetCloneChild(self.m_GridBox, 
		function(oChild)
			oChild.m_IconList = {}
			for i = 1, 3 do
				local box = oChild:NewUI(i, CBox)
				box.m_BorderSpr = box:NewUI(1, CSprite)
				box.m_EquipItem = box:NewUI(2, CPartnerEquipItem)
				box.m_SelSpr = box:NewUI(3, CSprite)
				
				if box.m_AmountLabel then
					box.m_AmountLabel:SetActive(false)
				end
				box.m_SelSpr:SetActive(false)
				box.m_LockSpr = box:NewUI(4, CSprite, false)
				box.m_WearSpr = box:NewUI(5, CSprite, false)
				box.m_AmountLabel = box:NewUI(6, CLabel, false)
				table.insert(oChild.m_IconList, box)
			end
			return oChild
		end)
	
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			oChild:SetActive(true)
			for i = 1, 3 do
				local box = oChild.m_IconList[i]
				if dData[i] then
					box:SetActive(true)
					local oItem = dData[i]
					box.m_ID = dData[i].m_ID
					box.m_EquipItem:SetItem(oItem.m_ID)
					box:AddUIEvent("click", callback(self, "OnClick", oItem))
					box:AddUIEvent("longpress", callback(self, "OnPress", oItem))
					if self.m_SelDict[box.m_ID] then
						box.m_SelSpr:SetActive(true)
					else
						box.m_SelSpr:SetActive(false)
					end
					self:UpdateAmount(box, oItem)
					if i == 1 and dData[i].m_IdxRow == 1 then
						g_GuideCtrl:AddGuideUI("partner_equip_strong_1_1_fuwen_btn", box)
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

function CPartnerEquipListPart.SetParentView(self, parent)
	self.m_ParentView = parent
end

function CPartnerEquipListPart.SetClickCallback(self, callback)
	self.m_ClickCallBack = callback
end

function CPartnerEquipListPart.SetPressCallback(self, callback)
	
end

function CPartnerEquipListPart.SetType(self, itype)
	--1 强化装备选择 2 合成装备选择
	self.m_Type = itype
	self:InitPopupBox()
	self:RefreshList()
end

function CPartnerEquipListPart.SetItemID(self, itemid)
	self.m_ItemID = itemid
	if not self.m_RefreshTimer then
		local function refresh(obj)
			obj:RefreshList()
			obj.m_RefreshTimer = nil
		end
		self.m_RefreshTimer = Utils.AddTimer(objcall(self, refresh), 0, 0.1)
	end
end

function CPartnerEquipListPart.OnCtrlItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		if not self.m_RefreshTimer then
			local function refresh(obj)
				obj:RefreshList()
				obj.m_RefreshTimer = nil
			end
			self.m_RefreshTimer = Utils.AddTimer(objcall(self, refresh), 0, 0.1)
		end
	end
end

function CPartnerEquipListPart.OnSortChange(self, oBox)
	local idx = self.m_SortPopupBox:GetSelectedIndex()
	local t = {"equip_star", "level", "equip_type", "pos"}
	self.m_SortKey = t[idx]
	if not self:CreateFilter() then
		self:RefreshList()
	end
end

function CPartnerEquipListPart.CreateFilter(self)
	local sKey = self.m_SortKey
	self.m_FilterBox:SetActive(false)
	self.m_PosFilterGrid:SetActive(false)
	self.m_StarFilterGrid:SetActive(false)
	self.m_FilterKey = nil
	if sKey then
		if sKey == "pos" then
			self:CreatePosFilter()
			self:ResetScrollPos()
			return true
		elseif sKey == "equip_star" then
			self:CreateStarFilter()
			self:ResetScrollPos()
			return true
		end
	end
	self:ResetScrollPos()
	return false
end

function CPartnerEquipListPart.CreatePosFilter(self)
	self.m_FilterBox:SetActive(true)
	self.m_PosFilterGrid:SetActive(true)
	local defaultbtn = self.m_PosFilterGrid:GetChildList()[1]
	if defaultbtn then
		defaultbtn:SetSelected(true)
		self:UpdateFilter(1)
	end
end

function CPartnerEquipListPart.CreateStarFilter(self)
	self.m_FilterBox:SetActive(true)
	self.m_StarFilterGrid:SetActive(true)
	local defaultbtn = self.m_StarFilterGrid:GetChildList()[1]
	if defaultbtn then
		defaultbtn:SetSelected(true)
		self:UpdateFilter(1)
	end
end

function CPartnerEquipListPart.UpdateFilter(self, key)
	self.m_FilterKey = key
	self:RefreshList()
end

function CPartnerEquipListPart.ResetScrollPos(self)
	local bshow = self.m_FilterBox:GetActive()
	if bshow then
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, -25, 430, 450) )
		
	else
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, 0, 430, 500) )
	end
	self.m_ScrollView:ResetPosition()
end

function CPartnerEquipListPart.GetEquipList(self)
	local itemlist = {}
	if self.m_Type == 1 then
		itemlist = g_ItemCtrl:GetPartnerEquip(true)
	else
		itemlist = g_ItemCtrl:GetPartnerEquip(false)
	end
	
	local poskey = self.m_FilterKey
	local newlist = {}
	if self.m_FilterKey then
		for _, oItem in pairs(itemlist) do
			if self.m_SortKey == "pos" and oItem:GetValue("pos") == poskey then
				table.insert(newlist, oItem)
			elseif self.m_SortKey == "equip_star" and oItem:GetValue("equip_star") == poskey then
				table.insert(newlist, oItem)
			end
		end
	else
		newlist = itemlist
	end
	newlist = self:DoTypeFilter(newlist)
	if self.m_Type == 1 then
		newlist = self:SortList(newlist)
	else
		newlist = self:SortList2(newlist)
	end
	self.m_EquipList = newlist
	return newlist
end

function CPartnerEquipListPart.DoTypeFilter(self, list)
	if not self.m_Type then
		return list
	end
	local newlist = {}
	if self.m_Type == 1 then
		for _, oItem in ipairs(list) do
			if oItem:GetValue("partner_id") == 0 and oItem:GetValue("lock") == 0 
				and oItem.m_ID ~= self.m_ItemID and oItem:GetValue("in_plan") == 0 then
				table.insert(newlist, oItem)
			end
		end
	end
	
	if self.m_Type == 2 then
		local curItem = g_ItemCtrl:GetItem(self.m_ItemID)
		for _, oItem in ipairs(list) do
			if oItem:GetValue("partner_id") == 0 and oItem:GetValue("lock") == 0 
				and oItem:GetValue("in_plan") == 0 then
				if curItem and curItem:GetValue("pos") == oItem:GetValue("pos") then
					table.insert(newlist, oItem)
				elseif not curItem then
					table.insert(newlist, oItem)
				end
			end
		end
	end
	
	return newlist
end

function CPartnerEquipListPart.SortFunc(self, a, b)
	local key = self.m_SortKey
	if a:GetValue(key) < b:GetValue(key) then
		return true
	end
	if a:GetValue(key) == b:GetValue(key) then
		if a.m_ID < b.m_ID then
			return true
		end
	end
	return false
end

function CPartnerEquipListPart.SortList(self, list)
	local sortList = {}
	for _, oItem in ipairs(list) do
		local key = nil
		if table.index({"level", "equip_star", "pos", "equip_type"}, self.m_SortKey) then
			key = oItem:GetValue(self.m_SortKey)
		end
		local t = {
			oItem,
			key,
			oItem:GetValue("equip_star"), 
			oItem:GetValue("level"), 
			oItem:GetValue("pos"), 
			oItem.m_ID, 
			oItem:GetValue("equip_type") == 60, 
		}
		table.insert(sortList, t)
	end
	local function cmp(listA, listB)
		local keyA = listA[2]
		local keyB = listB[2]
		if keyA ~= keyB then
			return keyA < keyB
		end
		if listA[7] ~= listB[7] then
			if listA[7] then
				return true
			elseif listB[7] then
				return false
			end
		end
		for i = 3, 6 do
			if listA[i] ~= listB[i] then
				return listA[i] < listB[i]
			end
		end
		return false
	end
	table.sort(sortList, cmp)
	list = {}
	for _, t in ipairs(sortList) do
		table.insert(list, t[1])
	end
	return list
end

function CPartnerEquipListPart.SortList2(self, list)
	local sortList = {}
	for _, oItem in ipairs(list) do
		local key = nil
		if table.index({"level", "equip_star", "pos", "equip_type"}, self.m_SortKey) then
			key = oItem:GetValue(self.m_SortKey)
		end
		local t = {
			oItem,
			key,
			oItem:GetValue("equip_star"), 
			oItem:GetValue("level"), 
			oItem:GetValue("pos"), 
			oItem.m_ID, 
		}
		table.insert(sortList, t)
	end
	local function cmp(listA, listB)
		local keyA = listA[2]
		local keyB = listB[2]
		if keyA ~= keyB then
			return keyA > keyB
		end
		for i = 3, 6 do
			if listA[i] ~= listB[i] then
				if i == 5 then
					return listA[i] < listB[i]
				else
					return listA[i] > listB[i]
				end
			end
		end
		return false
	end
	table.sort(sortList, cmp)
	list = {}
	for _, t in ipairs(sortList) do
		table.insert(list, t[1])
	end
	return list
end

function CPartnerEquipListPart.UpdateAmount(self, oBox, oItem)
	if not oBox.m_AmountLabel then
		return
	end
	if oItem:IsExpPartnerEquip() then
		oBox.m_AmountLabel:SetActive(true)
		oBox.m_AmountLabel:SetText(string.format("×%d", oItem:GetValue("amount")))
	else
		oBox.m_AmountLabel:SetActive(false)
	end

end

function CPartnerEquipListPart.RefreshList(self)
	local itemlist = self:GetEquipList()
	local dividelist = self:GetDivideList(itemlist)
	self.m_WrapContent:SetData(dividelist, true)
	self.m_ScrollView:ResetPosition()
	self.m_AmountLabel:SetText(string.format("数量:%d", #itemlist))
end

function CPartnerEquipListPart.GetDivideList(self, list)
	local newlist = {}
	local data = {}
	local idxRow = 1	--符文列表的行数
	for i, oItem in ipairs(list) do
		oItem.m_IdxRow = idxRow
		table.insert(data, oItem)
		if #data > 2 then
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

function CPartnerEquipListPart.GetGridList(self)
	local itemlist = self.m_EquipList
	local newlist = {}
	for _, oItem in ipairs(itemlist) do
		if not self.m_SelDict[oItem.m_ID] then
			table.insert(newlist, oItem)
		elseif oItem:IsExpPartnerEquip() then
			table.insert(newlist, oItem)
		end
	end
	return newlist
end

function CPartnerEquipListPart.OnClick(self, oItem)
	if self.m_ClickCallBack then
		self.m_ClickCallBack(oItem)
	end
end

function CPartnerEquipListPart.UpdateWear(self, spr, iWear)
	if spr then
		spr:SetActive(iWear ~= 0)
	end
end

function CPartnerEquipListPart.UpdateLock(self, spr, iLock)
	if spr then
		spr:SetActive(iLock == 1)
	end
end

function CPartnerEquipListPart.OnPress(self, oItem, oBtn, bPress)
	if bPress then
		if self.m_PressCallBack then
			self.m_PressCallBack(oItem)
		else
			g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, {})
		end
	end
end

function CPartnerEquipListPart.SetSelectedEquip(self, itemid, sel)
	if not itemid then
		return
	end
	self.m_SelDict[itemid] = sel
	local breakflag = false
	for _, itemobj in pairs(self.m_WrapContent:GetChildList()) do
		if itemobj:GetActive() then
			for i = 1, 3 do
				local icon = itemobj.m_IconList[i]
				if icon.m_ID == itemid and icon:GetActive() == true then
					if sel then
						icon.m_SelSpr:SetActive(true)
					else
						icon.m_SelSpr:SetActive(false)
					end
					breakflag = true
					break
				end
			end
		end
		if breakflag then
			break
		end
	end
end

function CPartnerEquipListPart.ClearSel(self)
	self.m_SelDict = {}
end

return CPartnerEquipListPart