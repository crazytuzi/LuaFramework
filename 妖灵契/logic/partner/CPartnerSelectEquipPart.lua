local CPartnerSelectEquipPart = class("CPartnerSelectEquipPart", CBox)
--符文主界面 符文列表

function CPartnerSelectEquipPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TypeBox = self:NewUI(1, CBox)
	self.m_ShowGrid = self:NewUI(2, CGrid)
	self.m_TypeWrapContent = self:NewUI(3, CWrapContent)
	self.m_TypeScrollView = self:NewUI(4, CScrollView)
	self.m_OperateBtn = self:NewUI(6, CBox)
	self.m_EquipPart = self:NewUI(8, CBox)
	self.m_ListPart = self:NewUI(9, CBox)
	self.m_CurRare = 0
	self.m_CurSelBox = nil
	self.m_ChangeCb = nil
	self.m_PartnerCount = 0
	self.m_CurFilterBtn = nil
	self.m_CurListPage = "partner"
	self.m_FiltetType = "rare"
	self:InitContent()
end

function CPartnerSelectEquipPart.InitContent(self)
	self.m_OperateBtn.m_Btn = self.m_OperateBtn:NewUI(1, CButton)
	self.m_OperateBtn.m_GreyLabel = self.m_OperateBtn:NewUI(2, CLabel)
	self.m_OperateBtn.m_WhiteLabel = self.m_OperateBtn:NewUI(3, CLabel)
	self.m_OperateBtn.m_Btn:AddUIEvent("click", callback(self, "OnChangeList"))
	g_GuideCtrl:AddGuideUI("partner_equip_change_type_btn", self.m_OperateBtn.m_Btn)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_TypeBox:SetActive(false)
	self.m_EquipPart:SetActive(false)
	self:InitEquipPart()
	self:InitTypePart()
	self:ShowListPart()
	self:RefreshTypeEquip()
end

CPartnerSelectEquipPart.g_SortData = {
	{"level", "等级"}, {"res_critical_ratio", "抗暴率"},
	{"equip_star", "星级"}, {"critical_damage", "暴击伤害"}, 
	{"create_time", "上手顺序"}, {"cure_critical_ratio", "治疗暴击"},
	{"maxhp", "气血"}, {"abnormal_attr_ratio", "异常命中"},
	{"attack", "攻击"}, {"res_abnormal_ratio", "异常抵抗"}, 
	{"defense", "防御"}, {"maxhp_ratio", "气血加成"},
	{"speed", "速度"}, {"attack_ratio", "攻击加成"},
	{"critical_ratio", "暴击率"}, {"defense_ratio", "防御加成"},  
}

function CPartnerSelectEquipPart.InitEquipPart(self)
	self.m_TypeLabel = self.m_EquipPart:NewUI(1, CLabel)
	self.m_SortPopupBox = self.m_EquipPart:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_BackBtn = self.m_EquipPart:NewUI(3, CButton)
	self.m_PosFilterGrid = self.m_EquipPart:NewUI(6, CGrid)
	self.m_PosFilterBtn = self.m_EquipPart:NewUI(7, CBox)
	self.m_WearSelectBtn = self.m_EquipPart:NewUI(8, CButton)
	self.m_ScrollView = self.m_EquipPart:NewUI(9, CScrollView)
	self.m_PosFilterBox = self.m_EquipPart:NewUI(10, CBox)
	self.m_WrapContent = self.m_EquipPart:NewUI(11, CWrapContent)
	self.m_GridBox = self.m_EquipPart:NewUI(12, CBox)
	self.m_GridBox:SetActive(false)
	
	self:InitValue()
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBackType"))
	self.m_WearSelectBtn:AddUIEvent("click", callback(self, "OnWearChange"))
	self.m_WearSelectBtn:SetSelected(true)
	self.m_PosFilterBtn:SetActive(false)
	self.m_PosFilterGrid:Clear()
	for i = 1, 4 do
		local btn = self.m_PosFilterBtn:Clone()
		btn:SetActive(true)
		btn.m_TextLabel = btn:NewUI(1, CLabel)
		btn.m_SelLabel = btn:NewUI(2, CLabel)
		btn.m_TextLabel:SetText(string.number2text(i, true))
		btn.m_SelLabel:SetText(string.number2text(i, true))
		btn:AddUIEvent("click", callback(self, "UpdateFilter", i))
		btn:SetGroup(self.m_PosFilterGrid:GetInstanceID())
		self.m_PosFilterGrid:AddChild(btn)
	end
	self.m_PosFilterGrid:Reposition()
	
	self.m_SortPopupBox:Clear()
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
	self.m_SortPopupBox:SetOffsetHeight(15)
	for k, v in pairs(CPartnerSelectEquipPart.g_SortData) do
		self.m_SortPopupBox:AddSubMenu(v[2])
	end
	self.m_SortPopupBox:SetSelectedIndex(1)
end

function CPartnerSelectEquipPart.InitValue(self)
	self.m_WrapContent:SetCloneChild(self.m_GridBox, 
		function(oChild)
			oChild.m_IconList = {}
			for i = 1, 3 do
				local box = oChild:NewUI(i, CBox)
				box.m_BorderSpr = box:NewUI(1, CSprite)
				box.m_EquipItem = box:NewUI(2, CPartnerEquipItem)
				box.m_AddBtn = box:NewUI(3, CButton)
				box.m_AddBtn:AddUIEvent("click", callback(self, "OnShowGetHelp"))
				box.m_AddBtn:SetActive(false)
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
					if dData[i].m_ID == nil then
						box.m_ID = nil
						box.m_EquipItem:SetActive(false)
						box.m_AddBtn:SetActive(true)
						box:AddUIEvent("click", function () end)
					else
						local oItem = dData[i]
						box.m_ID = dData[i].m_ID
						box.m_EquipItem:SetActive(true)
						box.m_AddBtn:SetActive(false)
						box.m_EquipItem:SetItem(oItem.m_ID)
						box:AddUIEvent("click", callback(self, "OnClickItem", oItem))
						if i == 1 and dData[i].m_IdxRow == 1 then
							g_GuideCtrl:AddGuideUI("partner_equip_list_1_1_fuwen_btn", box)
						end
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

function CPartnerSelectEquipPart.InitTypePart(self)
	self.m_TypeWrapContent:SetCloneChild(self.m_TypeBox, 
		function(oChild)
			oChild = self:CreateTypeBox(oChild)
			return oChild
		end
	)
	
	self.m_TypeWrapContent:SetRefreshFunc(function(oChild, idx)
		local dData = self.m_TypeDataList[idx]
		if dData then
			oChild:SetActive(true)
			self:UpdateTypeBox(oChild, dData)
			oChild.m_Idx = idx
		else
			oChild:SetActive(false)
			oChild.m_Idx = nil
		end
	end)
end

function CPartnerSelectEquipPart.SetParentView(self, parent)
	self.m_ParentView = parent
end

function CPartnerSelectEquipPart.SetPartnerID(self, parid)
	if self.m_CurParid ~= parid then
		self.m_CurParid = parid
		self:RefreshTypeEquip()
	end
end

function CPartnerSelectEquipPart.OnCtrlItemEvent(self, oCtrl)
	local oView = CPartnerMainView:GetView()
	if oView and oView:GetActive() then
		self.m_UpdateList = false
		if not self.m_RefreshTimer then
			local function refresh()
				if Utils.IsNil(self) then
					return
				end
				self:RefreshList()
				self:UpdateTypeData()
				self.m_RefreshTimer = nil
			end
			self.m_RefreshTimer = Utils.AddTimer(refresh, 0, 0.1)
		end
	else
		self.m_UpdateList = true
	end
end

function CPartnerSelectEquipPart.DelayUpdateItem(self)
	if self.m_UpdateList then
		self:RefreshList()
		self:UpdateTypeData()
	end
	self.m_UpdateList = false
end

function CPartnerSelectEquipPart.ShowListPart(self)
	self.m_ListPart:SetActive(true)
	self.m_EquipPart:SetActive(false)
	self:RefreshTypeEquip()
	self:UpdateOperateBtn("type")
end

function CPartnerSelectEquipPart.BackListPart(self)
	self.m_ListPart:SetActive(true)
	self.m_EquipPart:SetActive(false)
	self:UpdateOperateBtn("type")
end

function CPartnerSelectEquipPart.UpdateOperateBtn(self, stype)
	if stype == "pos" then
		self.m_OperateBtn.m_GreyLabel:SetText("        /类型")
		self.m_OperateBtn.m_WhiteLabel:SetText("位置")
	else
		self.m_OperateBtn.m_GreyLabel:SetText("位置/")
		self.m_OperateBtn.m_WhiteLabel:SetText("         类型")
	end
	self.m_OperateBtn.m_Type = stype
end

function CPartnerSelectEquipPart.ShowEquipPart(self)
	self.m_ListPart:SetActive(false)
	self.m_EquipPart:SetActive(true)
	self.m_PosFilterBox:SetActive(false)
	self:ResetScrollPos()
end

function CPartnerSelectEquipPart.OnChangeList(self)
	if self.m_OperateBtn.m_Type == "type" then
		self:OpenPosEquip()
		
	else
		self:ShowListPart()
	end
end

function CPartnerSelectEquipPart.UpdateWearList(self, list)
	self.m_WearList = list
	self:RefreshList()
end

function CPartnerSelectEquipPart.ResetScrollPos(self, bshow)
	local isfiltershow = self.m_PosFilterBox:GetActive()

	if isfiltershow then
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, -25, 440, 420) )
	
	else
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(0, 0, 440, 470) )
	end
	self.m_ScrollView:ResetPosition()
end

function CPartnerSelectEquipPart.OnSortChange(self, oBox)
	local idx = self.m_SortPopupBox:GetSelectedIndex()
	self.m_SortKey = CPartnerSelectEquipPart.g_SortData[idx][1]
	self:RefreshList()
end

function CPartnerSelectEquipPart.OnOpenPartner(self)
	self.m_ParentView:ShowEquipPage()
end

function CPartnerSelectEquipPart.OnOpenWear(self)
	-- body
end

function CPartnerSelectEquipPart.OnOpenEquip(self)
	-- body
end

function CPartnerSelectEquipPart.RefreshTypeEquip(self)
	self.m_ShowGrid:Clear()
	self:GetTypeEquipList()
	self.m_TypeWrapContent:SetData(self.m_TypeIdxList, true)
	self.m_TypeScrollView:ResetPosition()
end

function CPartnerSelectEquipPart.UpdateTypeData(self)
	self:GetTypeEquipList()
	for _, oBox in ipairs(self.m_TypeWrapContent:GetChildList()) do
		if oBox:GetActive() and oBox.m_Idx then
			self:UpdateTypeBox(oBox, self.m_TypeDataList[oBox.m_Idx])
		end
	end
end

function CPartnerSelectEquipPart.GetTypeEquipList(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParid)
	local recommandList = {}
	if oPartner then
		local oRecommendData = data.partnerrecommenddata.PartnerGongLue[oPartner:GetValue("partner_type")]
		if oRecommendData then
			recommandList = oRecommendData.equip_list
		end
	end
	local list = table.values(data.partnerequipdata.EQUIPTYPE)
	local equiplist = g_ItemCtrl:GetPartnerEquip()
	local amountdict = {}
	local iswearequip = self.m_WearSelectBtn:GetSelected()
	for _, oItem in ipairs(equiplist) do
		local itype = oItem:GetValue("equip_type")
		if iswearequip and (oItem:GetValue("partner_id") ~= 0 or oItem:GetValue("in_plan") ~= 0) then
			
		else
			if not amountdict[itype] then
				amountdict[itype] = {}
				amountdict[itype]["amount"] = 1
				amountdict[itype]["type"] = {}
				amountdict[itype]["type"][oItem:GetValue("pos")] = true

			else
				amountdict[itype]["amount"] = amountdict[itype]["amount"] + 1
				amountdict[itype]["type"][oItem:GetValue("pos")] = true
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
		if dTypeObj.id == 60 then
			index = i
		end
	end
	table.remove(list, index)
	local function cmp(a, b)
		local typeA = a["id"]
		local typeB = b["id"]
		if a.m_IsRecommand ~= b.m_IsRecommand then
			return a.m_IsRecommand > b.m_IsRecommand
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

	for i, dTypeObj in ipairs(list) do
		dTypeObj.m_Idx = i
	end
	self.m_TypeDataList = list
	self.m_TypeIdxList = table.range(1, #list)
	self.m_AmountDict = amountdict
	return list, amountdict
end

function CPartnerSelectEquipPart.OpenPosEquip(self)
	self.m_EquipType = nil
	self:RefreshPosEquip(1)
end

function CPartnerSelectEquipPart.RefreshPosEquip(self, pos)
	self.m_ListPart:SetActive(false)
	self.m_EquipPart:SetActive(true)
	self:UpdateOperateBtn("pos")
	if self.m_EquipType == nil then
		self.m_TypeLabel:SetText("")
		self.m_PosFilterBox:SetActive(true)
		self:ResetScrollPos()
		local btn = self.m_PosFilterGrid:GetChild(pos)
		if btn then
			btn:ForceSelected(true)
		end
		self:UpdateFilter(pos)
	else
		if self.m_PosType == pos then
			self.m_PosType = nil
			self:RefreshList()
		else
			self:UpdateFilter(pos)
		end
	end
	
end

function CPartnerSelectEquipPart.CreateTypeBox(self, box)
	box:SetActive(true)
	box.m_Name = box:NewUI(1, CLabel)
	box.m_Desc = box:NewUI(2, CLabel)
	box.m_AmountLable = box:NewUI(3, CLabel)
	box.m_Icon = box:NewUI(4, CSprite)
	box.m_EquipBtn = box:NewUI(5, CButton)
	box.m_RecommandObj = box:NewUI(6, CObject)
	box.m_TypeLabel = box:NewUI(7, CLabel)
	box.m_GuideBtn = box:NewUI(12, CButton)
	box.m_TypeSpr = {}
	for i = 1, 4 do
		box.m_TypeSpr[i] = box:NewUI(7+i, CSprite)
		box.m_TypeSpr[i]:SetActive(false)
	end
	return box
end

function CPartnerSelectEquipPart.UpdateTypeBox(self, box, typedata)
	local amountdict = self.m_AmountDict
	box.m_Name:SetText(typedata["name"])
	local str = string.format("2件:%s\n4件:%s", typedata["two_set_desc"], typedata["four_set_desc"])
	box.m_Icon:SpriteItemShape(typedata["icon"])
	box.m_Desc:SetText(str)
	box.m_RecommandObj:SetActive(typedata.m_IsRecommand > 990)
	box.m_TypeLabel:SetActive(false)
	box:AddUIEvent("click", callback(self, "OnClickType", typedata["id"]))
	box:AddUIEvent("longpress", callback(self, "OnPress", typedata["id"]))
	if box.m_GuideBtn then
		box.m_GuideBtn.m_BoxCollider = box.m_GuideBtn:GetComponent(classtype.BoxCollider)
		if box.m_GuideBtn.m_BoxCollider.enabled and typedata.m_Idx == 1 then
		else
			box.m_GuideBtn.m_BoxCollider.enabled = false
		end
		box.m_GuideBtn:AddUIEvent("click", callback(self, "OnClickType", typedata["id"]))
	end
	box:SetGroup(self.m_ShowGrid:GetInstanceID())
	local amount = 0
	local typeList = {}
	if amountdict[typedata["id"]] then
		amount = amountdict[typedata["id"]]["amount"]
		typeList = table.keys(amountdict[typedata["id"]]["type"])
	end
	for j = 1, 4 do
		if table.index(typeList, j) then
			box.m_TypeSpr[j]:SetActive(true)
		else
			box.m_TypeSpr[j]:SetActive(false)
		end
	end
	box.m_AmountLable:SetText(amount)
	box.m_EquipBtn:SetActive(amount > 0)
	box.m_EquipBtn:AddUIEvent("click", callback(self, "OnFastEquip", typedata))
	return box
end

function CPartnerSelectEquipPart.UpdateBox(self, oBox, oPartner)
end

function CPartnerSelectEquipPart.OnSelectPartner(self, oBox)
end

function CPartnerSelectEquipPart.OnBackType(self)
	self:BackListPart()
end

function CPartnerSelectEquipPart.OnClickType(self, typeid)
	self.m_EquipType = typeid
	self.m_TypeLabel:SetText(data.partnerequipdata.EQUIPTYPE[typeid]["name"])
	self.m_PosType = nil
	self:ShowEquipPart()
	self:RefreshList()
end

function CPartnerSelectEquipPart.OnPress(self, typeid, box, press)
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

function CPartnerSelectEquipPart.OnFastEquip(self, typedata)
	local equiplist = g_ItemCtrl:GetPartnerEquip()
	local equipdict = {}
	for _, oItem in ipairs(equiplist) do
		if oItem:GetValue("equip_type") == typedata["id"] then
			if oItem:GetValue("partner_id") == 0 and oItem:GetValue("in_plan") == 0 then
				local pos = oItem:GetValue("pos")
				equipdict[pos] = equipdict[pos] or {}
				table.insert(equipdict[pos], oItem)
			end
		end
	end
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParid)
	local curinfo = oPartner:GetCurEquipInfo()
	local k = 0
	local sendlist = {}
	for i = 1, 4 do
		if equipdict[i] then
			local function cmp(a, b)
				local lSortList = {"level", "equip_star"}
				for _, key in ipairs(lSortList) do
					if a:GetValue(key) ~= b:GetValue(key) then
						return a:GetValue(key) > b:GetValue(key)
					end
				end
				return false
			end
			table.sort(equipdict[i], cmp)
			local oItem = equipdict[i][1]
			local addflag = true
			local curItem = g_ItemCtrl:GetItem(curinfo[i])
			if curItem and curItem:GetValue("equip_type") ==  typedata["id"] then
				if cmp(curItem, oItem) then
					addflag = false
				end
			end
			if addflag then
				table.insert(sendlist, oItem.m_ID)
			end
		end
	end
	if #sendlist > 0 and g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSQuickWearPartnerEquip"]) then
		netpartner.C2GSQuickWearPartnerEquip(oPartner.m_ID, sendlist)
		g_NotifyCtrl:FloatMsg("已穿戴完毕")
	end
end

function CPartnerSelectEquipPart.OnWearChange(self)
	self:RefreshList()
	self:UpdateTypeData()
end

function CPartnerSelectEquipPart.RefreshList(self)
	if self.m_EquipPart:GetActive() then
		local list = self:GetEquipList()
		list = self:SortList(list)
		if self.m_EquipType then
			table.insert(list, CItem.NewBySid(0))
		end
		list = self:GetDivideData(list)
		self.m_WrapContent:SetData(list, true)
		self.m_ScrollView:ResetPosition()
	end
end

function CPartnerSelectEquipPart.GetDivideData(self, list)
	local amount = 3
	local newlist = {}
	local data = {}
	local idxRow = 1	--符文列表的行数
	for i, oItem in ipairs(list) do
		oItem.m_IdxRow = idxRow
		table.insert(data, oItem)
		if #data > amount-1 then
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

function CPartnerSelectEquipPart.OnShowGetHelp(self)
	if self.m_EquipType then
		CPEGetWayView:ShowView(function(oView)
			oView:SetData(self.m_EquipType)
		end)
	end
end

function CPartnerSelectEquipPart.OnClickItem(self, oItem)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParid)
	local args = {
		partner = oPartner,
	}
	g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, args)
end

function CPartnerSelectEquipPart.GetEquipList(self)
	local list = g_ItemCtrl:GetPartnerEquip()
	local newlist = {}
	local iswearequip = self.m_WearSelectBtn:GetSelected()
	for _, oItem in pairs(list) do
		local addflag = true
		if self.m_EquipType then
			if self.m_EquipType ~= oItem:GetValue("equip_type") then
				addflag = false
			end
		end
		if self.m_PosType then
			if self.m_PosType ~= oItem:GetValue("pos") then
				addflag = false
			end
		end
		if iswearequip then
			if oItem:GetValue("partner_id") ~= 0 or oItem:GetValue("in_plan") ~= 0 then
				addflag = false
			end
		end
		if addflag then
			table.insert(newlist, oItem)
		end
	end
	newlist = self:DoWearFilter(newlist)
	return newlist
end

function CPartnerSelectEquipPart.DoWearFilter(self, list)
	if self.m_WearList then
		local newlist = {}
		local wearlist = table.values(self.m_WearList)
		for _, oItem in pairs(list) do
			if not table.index(wearlist, oItem.m_ID) then
				table.insert(newlist, oItem)
			end
		end
		return newlist
	else
		return list
	end
end

function CPartnerSelectEquipPart.SortList2(self, list)
	local function cmp(oItemA, oItemB)
		if table.index({"level", "equip_star", "create_time"}, self.m_SortKey) then
			if oItemA:GetValue(self.m_SortKey) ~= oItemB:GetValue(self.m_SortKey) then
				return oItemA:GetValue(self.m_SortKey) > oItemB:GetValue(self.m_SortKey)
			end
		else
			local attrA = oItemA:GetPartnerEquipAttr()
			local attrB = oItemB:GetPartnerEquipAttr()
			local attrAvalue = attrA[self.m_SortKey] or 0
			local attrBvalue = attrB[self.m_SortKey] or 0
			if attrAvalue ~= attrBvalue then
				return attrAvalue > attrBvalue
			end
		end
		local lSortList = {"equip_star", "level", "equip_type", "create_time"}
		for _, key in ipairs(lSortList) do
			if oItemA:GetValue(key) ~= oItemB:GetValue(key) then
				return oItemA:GetValue(key) > oItemB:GetValue(key)
			end
		end
		return false
	end
	table.sort(list, cmp)
	return list
end

function CPartnerSelectEquipPart.SortList(self, list)
	local sortList = {}
	for _, oItem in ipairs(list) do
		local key = nil
		if table.index({"level", "equip_star", "create_time"}, self.m_SortKey) then
			key = oItem:GetValue(self.m_SortKey)
		else
			local attr = oItem:GetPartnerEquipAttr()
			key = attr[self.m_SortKey] or 0
		end
		local t = {
			oItem,
			key,
			oItem:GetValue("equip_star"), 
			oItem:GetValue("level"), 
			oItem:GetValue("equip_type"), 
			oItem:GetValue("create_time"), 
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

function CPartnerSelectEquipPart.UpdateFilter(self, pos)
	if self.m_PosType ~= pos then
		self.m_PosType = pos
		self:RefreshList()
	end
end

function CPartnerSelectEquipPart.RegisterDrag(self, dArgs)
	local list = self.m_ShowGrid:GetChildList()
	for k, oChild in pairs(list) do
		g_UITouchCtrl:AddDragObject(oChild, dArgs)
	end
end

function CPartnerSelectEquipPart.UnRegisterDrag(self)
	local list = self.m_ShowGrid:GetChildList()
	for k, oChild in pairs(list) do
		g_UITouchCtrl:DelDragObject(oChild)
	end
end

return CPartnerSelectEquipPart