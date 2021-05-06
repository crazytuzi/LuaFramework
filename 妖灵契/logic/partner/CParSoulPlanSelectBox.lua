local CParSoulPlanSelectBox = class("CParSoulPlanSelectBox", CBox)

function CParSoulPlanSelectBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_RowAmount = 3
	self.m_ItemPart = self:NewUI(1, CBox)
	self.m_TypePart = self:NewUI(2, CBox)
	self:InitItemPart()
	self:InitTypePart()
	self:ShowTypePart()
end

CParSoulPlanSelectBox.g_SortData = {
	{"soul_quality", "品质"}, {"res_critical_ratio", "抗暴率"},
	{"level", "等级"}, {"critical_damage", "暴击伤害"}, 
	{"create_time", "上手顺序"}, {"cure_critical_ratio", "治疗暴击"},
	{"maxhp", "气血"}, {"abnormal_attr_ratio", "异常命中"},
	{"attack", "攻击"}, {"res_abnormal_ratio", "异常抵抗"}, 
	{"defense", "防御"}, {"maxhp_ratio", "气血加成"},
	{"speed", "速度"}, {"attack_ratio", "攻击加成"},
	{"critical_ratio", "暴击率"}, {"defense_ratio", "防御加成"},  
}

CParSoulPlanSelectBox.WearSel = true
function CParSoulPlanSelectBox.InitItemPart(self)
	local oPart = self.m_ItemPart
	self.m_SortPopupBox = oPart:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_BackTypeBtn = oPart:NewUI(3, CButton)
	self.m_WearBtn = oPart:NewUI(4, CButton)
	self.m_ItemScrollView = oPart:NewUI(5, CScrollView)
	self.m_ItemWrapContent = oPart:NewUI(6, CWrapContent)
	self.m_GridBox = oPart:NewUI(7, CBox)
	self.m_GridBox:SetActive(false)
	self.m_ItemWrapContent:SetCloneChild(self.m_GridBox, callback(self, "SetItemWrapCloneChild"))
	self.m_ItemWrapContent:SetRefreshFunc(callback(self, "SetItemWrapRefreshFunc"))
	self.m_BackTypeBtn:AddUIEvent("click", callback(self, "ShowTypePart"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_SortPopupBox:Clear()
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
	self.m_SortPopupBox:SetOffsetHeight(15)
	for k, v in pairs(CParSoulPlanSelectBox.g_SortData) do
		self.m_SortPopupBox:AddSubMenu(v[2])
	end
	self.m_SortPopupBox:SetSelectedIndex(1)
	self.m_WearBtn:AddUIEvent("click", callback(self, "OnChangeWear"))
	self.m_WearBtn:SetSelected(CParSoulPlanSelectBox.WearSel)
end

function CParSoulPlanSelectBox.InitTypePart(self)
	local oPart = self.m_TypePart
	self.m_TypeScrollView = oPart:NewUI(1, CScrollView)
	self.m_TypeWrapContent = oPart:NewUI(2, CWrapContent)
	self.m_TypeSoulBox = oPart:NewUI(3, CBox)
	self.m_TypeSoulBox:SetActive(false)
	self.m_TypeWrapContent:SetCloneChild(self.m_TypeSoulBox, callback(self, "SetTypeWrapCloneChild"))
	self.m_TypeWrapContent:SetRefreshFunc(callback(self, "SetTypeWrapRefreshFunc"))
end

function CParSoulPlanSelectBox.SetItemWrapCloneChild(self, oChild)
	oChild.m_IconList = {}
	for i = 1, 3 do
		local box = oChild:NewUI(i, CBox)
		box.m_BorderSpr = box:NewUI(1, CSprite)
		box.m_SoulItem = box:NewUI(2, CParSoulItem)
		box.m_AddBtn = box:NewUI(3, CButton)
		box.m_InPlanSpr = box:NewUI(4, CSprite)
		box.m_AddBtn:AddUIEvent("click", callback(self, "OnShowGetHelp"))
		box.m_AddBtn:SetActive(false)
		box.m_InPlanSpr:SetActive(false)
		table.insert(oChild.m_IconList, box)
	end
	oChild:SetActive(true)
	return oChild
end

function CParSoulPlanSelectBox.SetItemWrapRefreshFunc(self, oChild, dData)
	if dData then
		oChild:SetActive(true)
		for i = 1, 3 do
			local box = oChild.m_IconList[i]
			if dData[i] then
				box:SetActive(true)
				box.m_InPlanSpr:SetActive(false)
				if dData[i].m_ID == nil then
					box.m_ID = nil
					box.m_SoulItem:SetActive(false)
					box.m_AddBtn:SetActive(true)
				else
					local oItem = dData[i]
					box.m_ID = dData[i].m_ID
					box.m_SoulItem:SetActive(true)
					box.m_AddBtn:SetActive(false)
					box.m_SoulItem:SetItem(oItem.m_ID)
					if oItem:GetValue("parid") == 0 and oItem:GetValue("plan") == 1 then
						box.m_InPlanSpr:SetActive(true)
					end
					box:AddUIEvent("click", callback(self, "OnClickItem", oItem))
				end
			else
				box.m_ID = nil
				box:SetActive(false)
			end
		end
	else
		oChild:SetActive(false)
	end
end

function CParSoulPlanSelectBox.SetTypeWrapCloneChild(self, oBox)
	oBox:SetActive(true)
	oBox.m_Name = oBox:NewUI(1, CLabel)
	oBox.m_Desc = oBox:NewUI(2, CLabel)
	oBox.m_AmountLable = oBox:NewUI(3, CLabel)
	oBox.m_Icon = oBox:NewUI(4, CSprite)
	oBox.m_EquipBtn = oBox:NewUI(5, CButton)
	oBox.m_RecommandObj = oBox:NewUI(6, CObject)
	oBox.m_GuideBtn = oBox:NewUI(7, CButton)
	return oBox
end

function CParSoulPlanSelectBox.SetTypeWrapRefreshFunc(self, oChild, idx)
	local dData = self.m_TypeDataList[idx]
	if dData then
		oChild:SetActive(true)
		self:UpdateTypeBox(oChild, dData)
		oChild.m_Idx = idx
		if idx == 1 then
			g_GuideCtrl:AddGuideUI("partner_soul_type_1_box_btn", oChild)
			g_GuideCtrl:AddGuideUI("partner_soul_type_1_fast_bg", oChild.m_GuideBtn)
			g_GuideCtrl:AddGuideUI("partner_soul_type_1_fast_equip_btn", oChild.m_EquipBtn)
		end
	else
		oChild:SetActive(false)
		oChild.m_Idx = nil
	end
end

function CParSoulPlanSelectBox.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshPartnerSoul then
		self:OnDealyUpdate()
	end
end

function CParSoulPlanSelectBox.SetPartnerID(self, iParID)
	if self.m_CurParID ~= iParID then
		self.m_CurParID = iParID
		self:ShowTypePart()
	end
end

function CParSoulPlanSelectBox.SetGetFunc(self, cb)
	self.m_GetParentFunc = cb
end

function CParSoulPlanSelectBox.GetReplaceFunc(self, cb)
	self.m_ReplaceFunc = cb
end

function CParSoulPlanSelectBox.SetFastEquipFunc(self, cb)
	self.m_FastEquipFunc = cb
end

function CParSoulPlanSelectBox.GetTypeEquipList(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)

	local recommandList = {}
	local iSoulType = nil
	if oPartner then
		local oRecommendData = data.partnerrecommenddata.PartnerGongLue[oPartner:GetValue("partner_type")]
		if oRecommendData then
			recommandList = oRecommendData.equip_list
		end
		iSoulType = oPartner:GetValue("soul_type")
	end
	local list = table.values(data.partnerequipdata.ParSoulType)
	local equiplist = g_ItemCtrl:GetParSoulList()
	local amountdict = {}
	local iswearequip = self.m_WearBtn:GetSelected()
	for _, oItem in ipairs(equiplist) do
		local itype = oItem:GetValue("soul_type")
		if iswearequip and oItem:GetValue("parid") ~= 0 then
			
		else
			if not amountdict[itype] then
				amountdict[itype] = {}
				amountdict[itype]["amount"] = 1

			else
				amountdict[itype]["amount"] = amountdict[itype]["amount"] + 1
			end
		end
	end
	local index = nil
	for i, dTypeObj in ipairs(list) do
		local j = table.index(recommandList, dTypeObj.id)
		if j then
			dTypeObj.m_IsRecommand = 999 - j
		else
			dTypeObj.m_IsRecommand = 0
		end
	end
	list = self:SortTypeList(list, iSoulType, amountdict)
	for i, dTypeObj in ipairs(list) do
		dTypeObj.m_Idx = i
	end
	self.m_TypeDataList = list
	self.m_TypeIdxList = table.range(1, #list)
	self.m_AmountDict = amountdict
	return list
end

function CParSoulPlanSelectBox.SortTypeList(self, list, iSoulType, amountdict)
	local function cmp(a, b)
		local typeA = a["id"]
		local typeB = b["id"]
		if a.m_IsRecommand ~= b.m_IsRecommand then
			return a.m_IsRecommand > b.m_IsRecommand
		end
		if a["id"] == iSoulType then
			return true
		end
		if b["id"] == iSoulType then
			return false
		end
		if amountdict[typeA] and not amountdict[typeB] then
			return true
		elseif not amountdict[typeA] and amountdict[typeB] then
			return false
		end
		if a["id"] < b["id"] then
			return true
		end
		return false
	end
	table.sort(list, cmp)
	return list
end

function CParSoulPlanSelectBox.UpdateTypeBox(self, box, typedata)
	box.m_Name:SetText(typedata["name"])
	box.m_Icon:SpriteItemShape(typedata["icon"])
	box.m_Desc:SetText(typedata["skill_desc"])
	box.m_RecommandObj:SetActive(typedata.m_IsRecommand > 990)
	box:AddUIEvent("click", callback(self, "OnClickType", typedata["id"]))
	box:AddUIEvent("longpress", callback(self, "OnPress", typedata["id"]))
	box:SetGroup(self.m_TypeWrapContent:GetInstanceID())
	local amount = 0
	local typeList = {}
	local amountdict = self.m_AmountDict
	if amountdict[typedata["id"]] then
		amount = amountdict[typedata["id"]]["amount"]

	end
	box.m_AmountLable:SetText(amount)
	box.m_EquipBtn:SetActive(true)
	box.m_EquipBtn:AddUIEvent("click", callback(self, "OnFastEquip", typedata["id"]))
	return box
end

function CParSoulPlanSelectBox.RefreshTypePart(self)
	self:GetTypeEquipList()
	self.m_TypeWrapContent:SetData(self.m_TypeIdxList, true)
	self.m_TypeScrollView:ResetPosition()
end

function CParSoulPlanSelectBox.ShowTypePart(self)
	self.m_ItemPart:SetActive(false)
	self.m_TypePart:SetActive(true)
	self:RefreshTypePart()
end

function CParSoulPlanSelectBox.ShowItemPart(self)
	self.m_ItemPart:SetActive(true)
	self.m_TypePart:SetActive(false)
end

function CParSoulPlanSelectBox.OnDealyUpdate(self)
	if self.m_DealyTimer then
		return
	end
	local function delay(obj)
		obj:RefreshItemPart()
		obj:RefreshTypePart()
		obj.m_DealyTimer = nil
	end
	self.m_DealyTimer = Utils.AddTimer(objcall(self, delay), 0, 0.2)
end

function CParSoulPlanSelectBox.RefreshItemPart(self)
	local itemList = self:GetParSoulList()
	itemList = self:GetDivideList(itemList)
	self.m_ItemWrapContent:SetData(itemList, true)
	self.m_ItemScrollView:ResetPosition()
end

function CParSoulPlanSelectBox.GetParSoulList(self)
	local itemList = g_ItemCtrl:GetParSoulList()
	local resultList = {}
	local iswearequip = self.m_WearBtn:GetSelected()
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("soul_type") == self.m_CoreType then
			if not iswearequip or oItem:GetValue("parid") == 0 then
				table.insert(resultList, oItem)
			end
		end
	end
	resultList = self:SortItem(resultList)
	table.insert(resultList, CItem.NewBySid(0))
	return resultList
end

function CParSoulPlanSelectBox.SortItem(self, list)
	local sortList = {}
	for _, oItem in ipairs(list) do
		local key = nil
		if table.index({"level", "soul_quality"}, self.m_SortKey) then
			key = oItem:GetValue(self.m_SortKey)
		else
			local attr = oItem:GetParSoulAttr()
			key = attr[self.m_SortKey] or 0
		end
		local t = {
			oItem,
			key,
			oItem:GetValue("soul_quality"), 
			oItem:GetValue("level"), 
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
		for i = 3, 5 do
			if listA[i] ~= listB[i] then
				return listA[i] > listB[i]
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

function CParSoulPlanSelectBox.GetDivideList(self, itemList)
	local newlist = {}
	local data = {}
	for i, oItem in ipairs(itemList) do
		table.insert(data, oItem)
		if #data >= self.m_RowAmount then
			table.insert(newlist, data)
			data = {}
		end
	end
	if #data > 0 then
		table.insert(newlist, data)
	end
	return newlist
end

function CParSoulPlanSelectBox.OnSortChange(self, oBox)
	local idx = self.m_SortPopupBox:GetSelectedIndex()
	self.m_SortKey = CPartnerSelectEquipPart.g_SortData[idx][1]
	self:RefreshItemPart()
end

function CParSoulPlanSelectBox.OnChangeWear(self)
	CParSoulPlanSelectBox.WearSel = self.m_WearBtn:GetSelected()
	self:RefreshItemPart()
end

function CParSoulPlanSelectBox.OnClickType(self, typeid)
	self.m_CoreType = typeid
	self:ShowItemPart()
	self:RefreshItemPart()
end

function CParSoulPlanSelectBox.OnShowGetHelp(self)
	if self.m_CoreType then
		CPEGetWayView:ShowView(function(oView)
			oView:SetData(self.m_CoreType)
		end)
	end
end

function CParSoulPlanSelectBox.OnPress(self, typeid, box, press)
	local oView = CGuideView:GetView()
	if oView then
		return
	end
	if press then
		CPEGetWayView:ShowView(function(oView)
			oView:SetData(typeid)
		end)
	end
end

function CParSoulPlanSelectBox.OnFastEquip(self, iCoreType)
	local itemList = g_ItemCtrl:GetParSoulList()
	local resultList = {}
	local iswearequip = self.m_WearBtn:GetSelected()
	local type2name = data.partnerequipdata.ParSoulAttr
	
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("soul_type") == iCoreType and oItem:GetValue("parid") == 0 and oItem:GetValue("plan") == 0 then
			local iAttrType = oItem:GetValue("attr_type")
			local dAttrData = oItem:GetParSoulAttr()
			local preObj = resultList[iAttrType]
			if preObj and preObj[2] >= dAttrData[type2name[iAttrType]["name"]] then

			else
				resultList[iAttrType] = {oItem, dAttrData[type2name[iAttrType]["name"]], oItem:GetValue("level"), oItem:GetValue("soul_quality")}
			end
			
		end
	end
	local dSendList = {}
	local iAmount = self:GetLockAmount()
	local dPosDict = self.m_GetParentFunc():GetCurSoulList()
	local dSendPos = {}
	for i = 1, iAmount do
		local iItemID = dPosDict[i]
		if iItemID then
			local oItem = g_ItemCtrl:GetItem(iItemID)
			local dAttrData = oItem:GetParSoulAttr()
			local iAttrType = oItem:GetValue("attr_type")
			if oItem:GetValue("soul_type") ~= iCoreType then
				break
			end
			if resultList[iAttrType] and resultList[iAttrType][2] > dAttrData[type2name[iAttrType]["name"]] then
				table.insert(dSendList, {pos=i, itemid = resultList[iAttrType][1].m_ID})
				table.insert(dSendPos, i)
			end
		end
	end
	local dPosList = self:GetPosList(iAmount, iCoreType, resultList)
	local typeSortList = self:SortAttrType(type2name, resultList)
	local idx = 0
	local equipList = {}
	for _, iAttrType in ipairs(typeSortList) do
		if resultList[iAttrType] and idx < 6 then
			table.insert(equipList, resultList[iAttrType][1])
			idx = idx + 1
		end
	end
	idx = 1
	for k, v in pairs(equipList) do
		if dPosList[idx] then
			table.insert(dSendList, {pos=dPosList[idx], itemid = v.m_ID})
			idx = idx + 1
		else
			break
		end
	end
	if #dSendList == 0 then
		g_NotifyCtrl:FloatMsg("已穿戴完毕")
	end
	self.m_GetParentFunc():OnFastEquip(iCoreType, dSendList)
end

function CParSoulPlanSelectBox.GetPosList(self, iAmount, iCoreType, resultList)
	local dPosDict = self.m_GetParentFunc():GetCurSoulList()
	local dPosList = {}
	for i = 1, iAmount do
		local iItemID = dPosDict[i]
		if iItemID then
			local oItem = g_ItemCtrl:GetItem(iItemID)
			if oItem:GetValue("soul_type") == iCoreType then
				resultList[oItem:GetValue("attr_type")] = nil
			else
				table.insert(dPosList, i)
			end
		else
			table.insert(dPosList, i)
		end
	end
	return dPosList
end

function CParSoulPlanSelectBox.SortAttrType(self, type2name, resultList)
	local typeSortList = {}
	for i, _ in ipairs(type2name) do
		local idx = nil
		if resultList[i] then
			for j, attrtype in ipairs(typeSortList) do
				if resultList[i][3] > resultList[attrtype][3] then
					idx = j
					break
				elseif resultList[i][3] == resultList[attrtype][3] and resultList[i][4] > resultList[attrtype][4] then
					idx = j
					break
				end
			end
			if idx then
				table.insert(typeSortList, idx, i)
			else
				table.insert(typeSortList, i)
			end
		end
	end
	return typeSortList
end

function CParSoulPlanSelectBox.GetLockAmount(self)
	local iGrade = g_AttrCtrl.grade
	local iAmount = 0
	for i, v in ipairs(data.partnerequipdata.ParSoulUnlock) do
		if iGrade >= v.unlock_grade then
			iAmount = iAmount + 1
		end
	end
	return iAmount
end

function CParSoulPlanSelectBox.OnClickItem(self, oItem)
	if oItem then
		local args = {
			equiplist = self.m_GetParentFunc():GetCurSoulList(),
			callback = callback(self.m_GetParentFunc(), "ReplaceSoul"),
		}
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, args)
	end
end

return CParSoulPlanSelectBox