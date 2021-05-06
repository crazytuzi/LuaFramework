local CPartnerListPart = class("CPartnerListPart", CBox)
CPartnerListPart.g_FilterData = {
	rare = 
	{
		func_name = "GetPartnerByRare",
		name = "稀有度",
		btn_info = {
			{args={0}, text="btn_pos_all"}, {args={4}, text="btn_rare_4"},{args={3}, text="btn_rare_3"}, {args={2}, text="btn_rare_2"},
			{args={1}, text="btn_rare_1"}},
		btn_size = {58, 30},
		sort_func = "rare",
	},
	grade = 
	{
		name = "等级",
		sort_func = "grade",
	},
	star = 
	{
		func_name = "GetPartnerByStar",
		name = "星级",
		btn_info = {
			{args={5}, text="btn_star_5"},{args={4}, text="btn_star_4"}, {args={3}, text="btn_star_3"},
			{args={2}, text="btn_star_2"},{args={1}, text="btn_star_1"}},
		btn_size = {40, 26},
		sort_func = "star",
	},
	power = 
	{
		name = "战斗力",
		sort_func = "power",
	},
	time = 
	{
		name = "时间",
		sort_func = "parid",
	},
	rare2 =
	{
		func_name = "GetChipByRare",
		name = "稀有度",
		btn_info = {
			{args={0}, text="btn_pos_all"}, {args={4}, text="btn_rare_4"},{args={3}, text="btn_rare_3"}, {args={2}, text="btn_rare_2"},
			{args={1}, text="btn_rare_1"}},
		btn_size = {52, 30},
		sort_func = "SortChipByRare",
	},
	time2 =
	{
		name = "时间",
		sort_func = "SortChipByTime",
	},
	amount =
	{
		name = "数量",
		sort_func = "SortChipByAmount",
	},

}
CPartnerListPart.g_PartnerFilter = {"rare", "grade", "star", "power", "time"}
CPartnerListPart.g_ChipFilter = {"rare2", "time2", "amount"}

function CPartnerListPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PartnerBoxClone = self:NewUI(1, CBox)
	self.m_DebrisBoxClone = self:NewUI(2, CBox)
	self.m_ShowGrid = self:NewUI(3, CGrid)
	self.m_NumberLabel = self:NewUI(5, CLabel)
	self.m_FilterGrid = self:NewUI(7, CGrid)
	self.m_PartnerBtn = self:NewUI(8, CButton)
	self.m_DebrisBtn = self:NewUI(9, CButton)
	self.m_SortPopupBox = self:NewUI(10, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_WearBox = self:NewUI(11, CBox)
	self.m_EquipBtn = self:NewUI(12, CButton)
	self.m_BtnGrid = self:NewUI(13, CGrid)
	self.m_ScrollView = self:NewUI(14, CScrollView)
	self.m_EquipBG = self:NewUI(15, CSprite)
	self.m_EquipBG:SetActive(false)
	self.m_CurRare = 0
	self.m_CurSelBox = nil
	self.m_ChangeCb = nil
	self.m_PartnerCount = 0
	self.m_CurFilterBtn = nil
	self.m_CurListPage = "partner"
	self.m_SortType = nil
	self:InitContent()
end

function CPartnerListPart.InitContent(self)
	self.m_FilterGrid:InitChild(function(obj, idx)
		local oBtn = CButton.New(obj, false)
		oBtn.m_Idx = idx
		oBtn:SetGroup(self.m_FilterGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnFilterBtn"))
		return oBtn
	end)
	self.m_PartnerBoxClone:SetActive(false)
	self.m_DebrisBoxClone:SetActive(false)

	self.m_PartnerBtn:SetGroup(self.m_BtnGrid:GetInstanceID())
	self.m_DebrisBtn:SetGroup(self.m_BtnGrid:GetInstanceID())

	self.m_PartnerBtn:SetSelected(true)
	
	self.m_WearSelBtn = self.m_WearBox:NewUI(1, CSprite)
	self.m_ShowGrid:SetActive(true)
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "ShowPartner"))
	self.m_DebrisBtn:AddUIEvent("click", callback(self, "ShowDebris"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "ShowEquip"))
	
	self.m_ScrollView:AddMoveCheck("down", self.m_ShowGrid, callback(self, "ShowNextPartner"))
	
	self.m_WearSelBtn:AddUIEvent("click", callback(self, "RefreshWearEquip"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	
	self:ShowPartner()
	self:DefaultSelect()
end

function CPartnerListPart.SetParentView(self, parent)
	self.m_ParentView = parent
end

function CPartnerListPart.SetType(self, sType)
	local t = {
		main = "partner",
		awake = "partner",
		upgrade = "partner",
		upstar = "upstarpartner",
		compose = "chip",
		equip = "partner",
		lineup = "partner"
	}
	local oldtype = self.m_ParentType
	self.m_ParentType = sType
	local oldlist = t[oldtype]
	local newlist = t[sType]

	if oldlist ~= newlist then
		if newlist == "partner" or newlist == "upstarpartner" then
			self.m_PartnerBtn:SetSelected(true)
			self.m_CurListPage = "partner"
		elseif newlist == "chip" then
			self.m_DebrisBtn:SetSelected(true)
			self.m_CurListPage = "chip"
		end
	end
	local typelist = {"main", "equip", "lineup", "awake"}
	self:SetSelectBtn()
	if table.index(typelist, oldtype) and table.index(typelist, sType) then
		self:DefaultSelect()
	elseif sType == "upstar" then
		self:InitUpStarList()
	elseif sType == "upgrade" and oldtype == "upstar" then
		self:RefreshGird()
	else
		self.m_CurSelBox = nil
		self:SetFilter()
		self:SetSortPopup()
	end
end

function CPartnerListPart.SetSortPopup(self)
	self.m_SortPopupBox:Clear()
	self.m_SortPopupBox:SetCallback(callback(self, "OnSortChange"))
	for k, v in pairs(self.m_SortList) do
		local name = CPartnerListPart.g_FilterData[v]["name"]
		self.m_SortPopupBox:AddSubMenu(name)
	end
	self.m_SortPopupBox:SetSelectedIndex(1)
end

function CPartnerListPart.SetFilter(self)
	local sortlist = nil
	if self.m_CurListPage == "partner" then
		sortlist = CPartnerListPart.g_PartnerFilter
	else
		sortlist = CPartnerListPart.g_ChipFilter
	end
	self.m_SortList = sortlist
end

function CPartnerListPart.SetSelectBtn(self)
	self.m_PartnerBtn:SetActive(true)
	self.m_DebrisBtn:SetActive(false)
	self.m_EquipBtn:SetActive(false)
	self.m_WearBox:SetActive(false)
	
	if self.m_ParentType == "equip" then
		self.m_EquipBtn:SetActive(true)
		self.m_WearBox:SetActive(true)
		self:RefreshWearEquip()
	
	elseif self.m_ParentType == "main" then
		self.m_DebrisBtn:SetActive(true)
		self:RefreshWearEquip()
	
	elseif self.m_ParentType == "lineup" or self.m_ParentType == "awake" then
		self.m_PartnerBtn:SetActive(false)
		self:RefreshWearEquip()
	
	elseif self.m_ParentType == "compose" then
		self.m_DebrisBtn:SetActive(true)
	end
	self.m_BtnGrid:Reposition()
end

function CPartnerListPart.OnSortChange(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local idx = self.m_SortPopupBox:GetSelectedIndex()
	oBox:SetMainMenu(subMenu.m_Label:GetText())
	self.m_SortType = self.m_SortList[idx]
	self.m_CurSelBox = nil
	self:RefreshFilter()
end

function CPartnerListPart.RefreshFilter(self)
	local dData = CPartnerListPart.g_FilterData[self.m_SortType]
	for i, oBtn in ipairs(self.m_FilterGrid:GetChildList()) do
		oBtn:ForceSelected(false)
		oBtn:SetActive(false)
	end

	if not dData.btn_info then
		self.m_CurFilterBtn = nil
		self:ResetScrollPos(false)
		self:RefreshGird()
		return
	end
	local w, h = dData.btn_size[1], dData.btn_size[2]
	self.m_FilterGrid:SetCellSize(w+25, h)
	for i, oBtn in ipairs(self.m_FilterGrid:GetChildList()) do
		local dBtnInfo = dData.btn_info[i]
		if dBtnInfo then
			oBtn:SetActive(true)
			oBtn:SetSpriteName(dBtnInfo.text)
			oBtn:SetSelected(false)
			oBtn:SetSize(w, h)
		end
	end
	local oBtn = self.m_FilterGrid:GetChildList()[1]
	if oBtn:GetActive() then
		oBtn:SetSelected(true)
		self:OnFilterBtn(oBtn)
		self:ResetScrollPos(true)
	else
		self:ResetScrollPos(false)
	end
end

function CPartnerListPart.ResetScrollPos(self, bshow)
	local v = self.m_ScrollView:GetLocalPos()
	if self.m_IsFilterShow == nil then
		self.m_IsFilterShow = true
	end

	if bshow and self.m_IsFilterShow == false then
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(400, -20, 940, 460) )
		self.m_IsFilterShow = true
	
	elseif not bshow and self.m_IsFilterShow == true then
		self.m_ScrollView:SetBaseClipRegion( Vector4.New(400, 0, 940, 500) )
		self.m_IsFilterShow = false
	end
	self.m_FilterGrid:SetActive(self.m_IsFilterShow)
	self.m_ShowGrid:UpdateAnchors()
	self.m_ScrollView:ResetPosition()
end

function CPartnerListPart.ShowPartner(self)
	self.m_PartnerBtn:SetSelected(true)
	local t = {"compose"}
	if table.index(t, self.m_ParentType) or self.m_CurListPage ~= "partner" then
		self.m_ParentView:ShowMainPage()
	end
	self.m_CurListPage = "partner"
end

function CPartnerListPart.ShowDebris(self)
	self.m_CurListPage = "chip"
	self.m_DebrisBtn:SetSelected(true)
	self.m_ParentView:ShowComposePage()
end

function CPartnerListPart.ShowWear(self)

end

function CPartnerListPart.ShowEquip(self)
	self.m_EquipBtn:SetSelected(true)
	self.m_ParentView:ShowEquip()
end

function CPartnerListPart.DefaultSelect(self)
	local oBox = self.m_ShowGrid:GetChild(1)
	
	if oBox and not self.m_CurSelBox then
		self:OnSelectPartner(oBox)
	elseif self.m_CurSelBox then
		self:SetDefaultPartner(self.m_CurSelBox.m_PartnerID)
	else
		if self.m_ParentView and self.m_ParentView.SetNonePartner then
			self.m_ParentView:SetNonePartner()
		end
	end
end

function CPartnerListPart.SetDefaultPartner(self, parid)
	local bselect = false
	for _, oBox in pairs(self.m_ShowGrid:GetChildList()) do
		if oBox.m_PartnerID == parid and oBox:GetActive() then
			bselect = true
			self:OnSelectPartner(oBox)
			break
		end
	end
	if not bselect then
		local oBox = self.m_ShowGrid:GetChild(1)
		if oBox and oBox:GetActive() then
			self:OnSelectPartner(oBox)
		else
			self.m_CurSelBox = nil
		end
	end
	if self.m_CurSelBox then
		UITools.MoveToTarget(self.m_ScrollView, self.m_CurSelBox)
	end
end

function CPartnerListPart.SetChangeCallback(self, cb)
	self.m_ChangeCb = cb
	if self.m_CurSelBox then
		self.m_ChangeCb(self.m_CurSelBox.m_PartnerID)
	end
end

function CPartnerListPart.GetShowList(self)
	local list
	if self.m_CurFilterBtn and self.m_SortType then
		local dFilter = CPartnerListPart.g_FilterData[self.m_SortType]
		local sFuncName = dFilter.func_name
		local dBtnInfo =dFilter.btn_info[self.m_CurFilterBtn.m_Idx]
		local args = dBtnInfo.args
		list = g_PartnerCtrl[sFuncName](g_PartnerCtrl, unpack(args))
	end
	if not list then
		list = table.values(g_PartnerCtrl:GetPartners())
	end
	table.sort(list, callback(g_PartnerCtrl, "CommonSortFunc"))
	list = self:UpStarFilter(list)
	list = self:UpGradeFilter(list)
	return list
end

function CPartnerListPart.SortPartner(self, list)
	if self.m_SortType then
		local key =  CPartnerListPart.g_FilterData[self.m_SortType]["sort_func"]
		local function cmp(a, b)
			local pos1 = g_PartnerCtrl:GetFightPos(a.m_ID) or 9999
			local pos2 = g_PartnerCtrl:GetFightPos(b.m_ID) or 9999
			if pos1 ~= pos2 then
				return pos1 < pos2
			end
			if a:GetValue(key) ~= b:GetValue(key) then
				return a:GetValue(key) > b:GetValue(key)
			else
				return a:GetValue("partner_type") < b:GetValue("partner_type")
			end
		end
		table.sort(list, cmp)
	end
	return list
end

function CPartnerListPart.SortPartnerByRare(chipA, chipB)
	return chipA["rare"] < chipB["rare"]
end

function CPartnerListPart.UpStarFilter(self, partnerlist)
	if self.m_ParentType ~= "upstar" then
		return partnerlist
	end
	local list = {}
	for k, oPartner in ipairs(partnerlist) do
		local grade = oPartner:GetValue("grade")
		local star = oPartner:GetValue("star")
		if grade == data.partnerdata.UPSTAR[star]["limit_level"] and star < 5 then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CPartnerListPart.UpGradeFilter(self, partnerlist)
	if self.m_ParentType ~= "upgrade" then
		return partnerlist
	end
	local list = {}
	for k, oPartner in ipairs(partnerlist) do
		if oPartner:IsNormalType() or oPartner:IsStarType() then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CPartnerListPart.InitUpStarList(self)
	if self.m_ParentType ~= "upstar" then
		return
	end
	self:RefreshPartnerGrid()
end

function CPartnerListPart.GetChipList(self)
	local list = {}
	if self.m_CurFilterBtn and self.m_SortType then
		local dFilter = CPartnerListPart.g_FilterData[self.m_SortType]
		local sFuncName = dFilter.func_name
		local dBtnInfo =dFilter.btn_info[self.m_CurFilterBtn.m_Idx]
		local args = dBtnInfo.args
		list = g_PartnerCtrl[sFuncName](g_PartnerCtrl, unpack(args))
	end
	if not list then
		list = g_PartnerCtrl:GetChipByRare(0)
	end
	return list
end

function CPartnerListPart.SortChip(self, list)
	if self.m_SortType then
		local func_name = CPartnerListPart.g_FilterData[self.m_SortType]["sort_func"]
		table.sort(list, self[func_name])
	end
	return list
end

function CPartnerListPart.SortChipByNormal(chipA, chipB)
	local composeA = (chipA:GetValue("amount") / chipA:GetValue("compose_amount")) >= 1
	local composeB = (chipB:GetValue("amount") / chipA:GetValue("compose_amount")) >= 1
	if composeA ~= composeB then
		if composeA then
			return true
		else
			return false
		end
	end
	return nil
end

function CPartnerListPart.SortChipByRare(chipA, chipB)
	local x = CPartnerListPart.SortChipByNormal(chipA, chipB)
	if x ~= nil then
		return x
	else
		if chipA:GetValue("rare") ~= chipB:GetValue("rare") then
			return chipA:GetValue("rare") > chipB:GetValue("rare")
		else
			return chipA:GetValue("partner_type") < chipB:GetValue("partner_type")
		end
	end
end

function CPartnerListPart.SortChipByAmount(chipA, chipB)
	local x = CPartnerListPart.SortChipByNormal(chipA, chipB)
	if chipA:GetValue("amount") ~= chipB:GetValue("amount") then
		return chipA:GetValue("amount") > chipB:GetValue("amount")
	else
		return CPartnerListPart.SortChipByRare(chipA, chipB)
	end
end

function CPartnerListPart.SortChipByTime(chipA, chipB)
	local x = CPartnerListPart.SortChipByNormal(chipA, chipB)
	if x ~= nil then
		return x
	else
		return chipA:GetValue("create_time") > chipB:GetValue("create_time")
	end
end

function CPartnerListPart.RefreshDebrisGrid(self)
	self:UnRegisterDrag()
	self.m_ShowGrid:Clear()
	self.m_CurSelBox = nil
	local list = self:GetChipList()
	list = self:SortChip(list)
	self.m_ShowGrid.m_Type = "chip"
	for i, dChildInfo in pairs(list) do
		local oBox=self.m_DebrisBoxClone:Clone()
		oBox:SetActive(true)
		oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_MaxDebrisLabel = oBox:NewUI(3, CLabel)
		oBox.m_CompoundLabel = oBox:NewUI(4, CLabel)
		oBox.m_BorderSpr = oBox:NewUI(5, CSprite)
		oBox.m_ChipSpr = oBox:NewUI(6, CSprite)
		oBox.m_AvatarSpr:SpriteAvatar(dChildInfo:GetValue("icon"))
		
		oBox.m_PartnerID = dChildInfo:GetValue("sid")
		oBox.m_NameLabel:SetText(dChildInfo:GetValue("name"))
		g_PartnerCtrl:ChangeRareBorder(oBox.m_BorderSpr, dChildInfo:GetValue("rare"))
		self:ChangeChipSpr(oBox.m_ChipSpr, dChildInfo:GetValue("rare"))
		oBox.m_MaxDebrisLabel:SetText(string.format("%d/%d", dChildInfo:GetValue("amount"), dChildInfo:GetValue("compose_amount")))
		if dChildInfo:GetValue("amount") >= dChildInfo:GetValue("compose_amount") then
			oBox.m_CompoundLabel:SetActive(true)
		else
			oBox.m_CompoundLabel:SetActive(false)
		end
		oBox:SetGroup(self.m_ShowGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnSelectPartner"))
		self.m_ShowGrid:AddChild(oBox)
	end
	self.m_ScrollView:ResetPosition()
	self.m_ShowGrid:Reposition()
	self:DefaultSelect()
	self.m_NumberLabel:SetText("数量："..tostring(self.m_ShowGrid:GetCount()))
end

function CPartnerListPart.ChangeChipSpr(self, spr, rare)
	local filename = define.Partner.CardColor[rare] or "hui"
	spr:SetSpriteName("pic_suipian_"..filename.."se")
end

function CPartnerListPart.RefreshPartnerGrid(self)
	self:UnRegisterDrag()
	local list = self:GetShowList()
	list = self:SortPartner(list)
	self.m_DataList = list
	if self.m_ShowGrid.m_Type ~= "partner" then
		self.m_ShowGrid:Clear()
	end
	self.m_ShowGrid.m_Type = "partner"
	local size = 0
	for i, oPartner in ipairs(list) do
		if i > 20 then
			break
		else
			local oBox = self.m_ShowGrid:GetChild(i)
			if oBox then
				oBox:SetActive(true)
			else
				oBox = self:CreatePartnerBox()
				self.m_ShowGrid:AddChild(oBox)
			end
			oBox.m_PartnerID = oPartner.m_ID
			self:UpdateBox(oBox, oPartner)
			self:UpdateEquip(oBox, oPartner)
			size = size + 1
		end
	end
	self.m_ListIndex = size
	for i = size+1, self.m_ShowGrid:GetCount() do
		local oBox = self.m_ShowGrid:GetChild(i)
		if oBox then
			oBox:SetActive(false)
		else
			break
		end
	end
	self.m_ScrollView:ResetPosition()
	self.m_ShowGrid:Reposition()
	self.m_NumberLabel:SetText("数量："..tostring(#list))
	if self.m_ParentType == "lineup" then
		local dArgs = self.m_ParentView.m_LineupPage:GetDragArgs()
		self:RegisterDrag(dArgs)
		self.m_CurSelBox = nil
	end
	self:DefaultSelect()
end

function CPartnerListPart.CreatePartnerBox(self)
	local oBox = self.m_PartnerBoxClone:Clone()
	oBox:SetActive(true)
	oBox.m_AvatarSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(4, CSprite)
	oBox.m_StarSpr = oBox:NewUI(5, CSprite)
	oBox.m_StarGrid = oBox:NewUI(6, CGrid)
	oBox.m_StateLabel = oBox:NewUI(7, CLabel)
	oBox.m_LockSpr = oBox:NewUI(8, CSprite)
	oBox.m_EquipBox = oBox:NewUI(9, CBox)
	oBox.m_PowerLabel = oBox:NewUI(10, CLabel)
	oBox.m_BorderSpr = oBox:NewUI(11, CSprite)
	oBox.m_EquipGrid = oBox.m_EquipBox:NewUI(1, CGrid)
	oBox.m_EquipItem = oBox.m_EquipBox:NewUI(2, CPartnerEquipItem)
	oBox.m_EquipItem:SetActive(false)
	oBox.m_StarSpr:SetActive(false)
	oBox:SetGroup(self.m_ShowGrid:GetInstanceID())
	oBox:AddUIEvent("click", callback(self, "OnSelectPartner"))
	return oBox
end

function CPartnerListPart.ShowNextPartner(self)
	if self.m_ShowGrid.m_Type ~= "partner" then
		return
	end
	self.m_ShowGrid.m_Type = "partner"
	local size = self.m_ListIndex
	local list = {}
	local newitem = {}
	for i = self.m_ListIndex+1, self.m_ListIndex+20 do
		local oPartner = self.m_DataList[i]
		if not oPartner then
			break
		end
		local oBox = self.m_ShowGrid:GetChild(i)
		if oBox then
			oBox:SetActive(true)
		else
			oBox = self:CreatePartnerBox()
			table.insert(newitem, oBox)
			self.m_ShowGrid:AddChild(oBox)
		end
		oBox.m_PartnerID = oPartner.m_ID
		self:UpdateBox(oBox, oPartner)
		self:UpdateEquip(oBox, oPartner)
		size = size + 1
	end
	self.m_ListIndex = size
	if self.m_ParentType == "lineup" then
		local dArgs = self.m_ParentView.m_LineupPage:GetDragArgs()
		for k, oChild in pairs(newitem) do
			g_UITouchCtrl:AddDragObject(oChild, dArgs)
		end
	end
end

function CPartnerListPart.RefreshWearEquip(self)
	if self.m_CurListPage == "partner" and self.m_ShowGrid.m_Type == "partner" then
		for _, oBox in pairs(self.m_ShowGrid:GetChildList()) do
			local oPartner = g_PartnerCtrl:GetPartner(oBox.m_PartnerID)
			self:UpdateEquip(oBox, oPartner)
		end
	end
	if self.m_WearBox:GetActive() and self.m_WearSelBtn:GetSelected() then
		self.m_EquipBG:SetActive(true)
	else
		self.m_EquipBG:SetActive(false)
	end
end

function CPartnerListPart.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:UpdateChip(oCtrl.m_EventData)
	end
end

function CPartnerListPart.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.FightChange then
		self:RefreshGird()
	
	elseif oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:UpdatePartner(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Partner.Event.DelPartner then
		self:DelPartner(oCtrl.m_EventData)
	end
end

function CPartnerListPart.DelPartner(self, dellist)
	if self.m_CurListPage ~= "partner" then
		return
	end
	local delboxlist = {}
	for i, oBox in pairs(self.m_ShowGrid:GetChildList()) do
		if table.index(dellist, oBox.m_PartnerID) then
			table.insert(delboxlist, oBox)
		end
	end
	for i, oBox in pairs(delboxlist) do
		self.m_ShowGrid:RemoveChild(oBox)
	end
	local newlist = {}
	for _, oPartner in ipairs(self.m_DataList) do
		if not table.index(dellist, oPartner.m_ID) then
			table.insert(newlist, oPartner)
		end
	end
	self.m_DataList = newlist
	
	if self.m_CurSelBox then
		if table.index(dellist, self.m_CurSelBox.m_PartnerID) then
			self:DefaultSelect()
		end
	end
end

function CPartnerListPart.UpdatePartner(self, parid)
	if self.m_CurListPage ~= "partner" then
		return
	end
	for i, oBox in pairs(self.m_ShowGrid:GetChildList()) do
		if oBox.m_PartnerID == parid then
			local oPartner = g_PartnerCtrl:GetPartner(parid)
			self:UpdateBox(oBox, oPartner)
			break
		end
	end
end

function CPartnerListPart.UpdateBox(self, oBox, oPartner)
	if self.m_CurListPage ~= "partner" then
		return
	end
	local dModelInfo = oPartner:GetValue("model_info")
	oBox.m_AvatarSpr:SpriteAvatar(oPartner:GetValue("icon"))
	oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
	oBox.m_GradeLabel:SetText("lv."..tostring(oPartner:GetValue("grade")))
	oBox.m_PowerLabel:SetText(string.format("战斗力:%d", oPartner:GetValue("power")))
	local iPos = g_PartnerCtrl:GetFightPos(oPartner.m_ID)
	if iPos == 1 then
		oBox.m_StateLabel:SetActive(true)
		oBox.m_StateLabel:SetText("主战")
	elseif iPos then
		oBox.m_StateLabel:SetActive(true)
		oBox.m_StateLabel:SetText("助战")
	else
		oBox.m_StateLabel:SetActive(false)
		oBox.m_StateLabel:SetText("")
	end
	g_PartnerCtrl:ChangeRareBorder(oBox.m_BorderSpr, oPartner:GetValue("rare"))
	if oPartner:IsLock() then
		oBox.m_LockSpr:SetActive(true)
	else
		oBox.m_LockSpr:SetActive(false)
	end
	oBox.m_StarGrid:Clear()
	local iStar = oPartner:GetValue("star")
	for i= 1, iStar do
		local oSpr = oBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		oBox.m_StarGrid:AddChild(oSpr)
	end
end

function CPartnerListPart.UpdateChip(self, oItem)
	if self.m_CurListPage ~= "chip" then
		return
	end
	local chiptype = oItem:GetValue("sid")
	for i, oBox in pairs(self.m_ShowGrid:GetChildList()) do
		if oBox.m_PartnerID == chiptype then
			self:UpdateChipBox(oBox, chiptype)
			break
		end
	end
end

function CPartnerListPart.UpdateChipBox(self, oBox, chiptype)
	local dChildInfo = g_PartnerCtrl:GetSingleChipInfo(chiptype)
	oBox.m_NameLabel:SetText(dChildInfo:GetValue("name"))
	oBox.m_MaxDebrisLabel:SetText(string.format("%d/%d", dChildInfo:GetValue("amount"), dChildInfo:GetValue("compose_amount")))
	if dChildInfo:GetValue("amount") >= dChildInfo:GetValue("compose_amount") then
		oBox.m_CompoundLabel:SetActive(true)
	else
		oBox.m_CompoundLabel:SetActive(false)
	end
end

function CPartnerListPart.UpdateEquip(self, oBox, oPartner)
	if self.m_WearBox:GetActive() and self.m_WearSelBtn:GetSelected() then
		oBox.m_EquipBox:SetActive(true)
	else
		oBox.m_EquipBox:SetActive(false)
		return
	end
	
	oBox.m_EquipGrid:Clear()
	local equipdict = oPartner:GetCurEquipInfo()
	for i = 1, 6 do
		local equipinfo = equipdict[i]
		local box = oBox.m_EquipItem:Clone()
		box:SetActive(true)
		if equipinfo then
			box:SetItem(equipinfo)
		else
			box:SetItem(nil, i)
		end
		oBox.m_EquipGrid:AddChild(box)
	end
end

function CPartnerListPart.OnSelectPartner(self, oBox)
	oBox:SetSelected(true)
	self.m_CurSelBox = oBox
	if self.m_ChangeCb then
		self.m_ChangeCb(oBox.m_PartnerID)
	end
end

function CPartnerListPart.OnFilterBtn(self, oBtn)
	oBtn:SetSelected(true)
	self.m_CurFilterBtn = oBtn
	self.m_CurSelBox = nil
	self:RefreshGird()
end

function CPartnerListPart.RefreshGird(self)
	if self.m_CurListPage == "partner" then
		self:RefreshPartnerGrid()
	else
		self:RefreshDebrisGrid()
	end
end

function CPartnerListPart.RegisterDrag(self, dArgs)
	local list = self.m_ShowGrid:GetChildList()
	for k, oChild in pairs(list) do
		g_UITouchCtrl:AddDragObject(oChild, dArgs)
	end
end

function CPartnerListPart.UnRegisterDrag(self)
	local list = self.m_ShowGrid:GetChildList()
	for k, oChild in pairs(list) do
		g_UITouchCtrl:DelDragObject(oChild)
	end
end

return CPartnerListPart