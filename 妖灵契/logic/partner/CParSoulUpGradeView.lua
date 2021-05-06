local CParSoulUpGradeView = class("CParSoulUpGradeView", CViewBase)

function CParSoulUpGradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerSoulUpGradeView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_RowAmount = 3
end

function CParSoulUpGradeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TipBtn = self:NewUI(2, CButton)
	self.m_SelectPart = self:NewUI(3, CBox)
	self.m_RightPart = self:NewUI(4, CBox)
	self.m_SelectList = {}
	self:InitContent()
end

function CParSoulUpGradeView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddHelpTipClick("parsoul_upgrade")
	self:InitSelect()
	self:InitRight()
	self:InitConfig()
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CParSoulUpGradeView.InitSelect(self)
	local oPart = self.m_SelectPart
	self.m_AmountLabel = oPart:NewUI(1, CLabel)
	self.m_FilterBtn = oPart:NewUI(2, CButton)
	self.m_ScrollView = oPart:NewUI(3, CScrollView)
	self.m_WrapContent = oPart:NewUI(4, CWrapContent)
	self.m_GridBox = oPart:NewUI(5, CBox)
	self.m_GridBox:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_GridBox, callback(self, "SetWrapCloneChild"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "SetWrapRefreshFunc"))
	self.m_FilterBtn:AddUIEvent("click", callback(self, "OnFilter"))
end

function CParSoulUpGradeView.SetWrapCloneChild(self, oChild)
	oChild.m_IconList = {}
	for i = 1, 3 do
		local box = oChild:NewUI(i, CBox)
		box.m_BorderSpr = box:NewUI(1, CSprite)
		box.m_SoulItem = box:NewUI(2, CParSoulItem)
		box.m_SelSpr = box:NewUI(3, CSprite)
		table.insert(oChild.m_IconList, box)
	end
	oChild:SetActive(true)
	return oChild
end

function CParSoulUpGradeView.SetWrapRefreshFunc(self, oChild, dData)
	if dData then
		oChild:SetActive(true)
		for i = 1, 3 do
			local box = oChild.m_IconList[i]
			if dData[i] then
				box:SetActive(true)
				local oItem = dData[i]
				box.m_ID = dData[i].m_ID
				box.m_SoulItem:SetActive(true)
				box.m_SoulItem:SetItem(oItem.m_ID)
				if table.index(self.m_SelectList, oItem.m_ID) then
					box.m_SelSpr:SetActive(true)
				else
					box.m_SelSpr:SetActive(false)
				end
				box:AddUIEvent("click", callback(self, "OnClickItem", oItem))
				box:AddUIEvent("longpress", callback(self, "OnPress", oItem))
			else
				box.m_ID = nil
				box:SetActive(false)
			end
		end
	else
		oChild:SetActive(false)
	end
end

function CParSoulUpGradeView.InitRight(self)
	local oPart = self.m_RightPart
	self.m_ParSoulItem = oPart:NewUI(1, CParSoulItem)
	self.m_GradeChangeLabel = oPart:NewUI(2, CLabel)
	self.m_NameLabel = oPart:NewUI(3, CLabel)
	self.m_AttrGrid = oPart:NewUI(4, CGrid)
	self.m_AttrBox = oPart:NewUI(5, CBox)
	self.m_ConfirmBtn = oPart:NewUI(6, CButton)
	self.m_ExpSlider = oPart:NewUI(7, CSlider)
	self.m_AddSlider = oPart:NewUI(8,CSlider)
	self.m_ExpLabel = oPart:NewUI(9, CLabel)
	self.m_ExpEffectObj = oPart:NewUI(10, CUIEffect)
	self.m_EffectNode = oPart:NewUI(11, CObject)
	self.m_CostLabel = oPart:NewUI(12, CLabel)
	self.m_ExpEffectObj:SetActive(false)
	self.m_ExpEffectObj:Above(self.m_EffectNode)
	self.m_AttrBox:SetActive(false)
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnUpGrade"))
end

function CParSoulUpGradeView.InitConfig(self)
	self.m_ExpConfig = {}
	for _, v in ipairs(data.partnerequipdata.ParSoulUpGrade) do
		self.m_ExpConfig[v.quality] = self.m_ExpConfig[v.quality] or {}
		self.m_ExpConfig[v.quality][v.level] = {v.base_exp, v.upgrade_exp}
	end
end

function CParSoulUpGradeView.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerSoul then
		if self.m_CurItem.m_ID == oCtrl.m_EventData then
			local oItem = g_ItemCtrl:GetItem(oCtrl.m_EventData)
			self:SetItem(oItem)
			self:DoExpEffect()
		end
	end
end

function CParSoulUpGradeView.SetItem(self, oItem)
	self.m_CurItem = oItem
	self.m_CoreType = oItem:GetValue("soul_type")
	self.m_SelectList = {}
	self:RefreshItemPart()
	self.m_ParSoulItem:SetItem(oItem.m_ID)
	self.m_NameLabel:SetText(oItem:GetValue("name"))

	self:UpdateExp()
	self:UpdateCost(0)
end

function CParSoulUpGradeView.DoExpEffect(self)
	self.m_ExpEffectObj:SetActive(true)
	if self.m_ExpEffectTimer then
		Utils.DelTimer(self.m_ExpEffectTimer)
	end
	local function delay()
		if not Utils.IsNil(self) then
			self.m_ExpEffectObj:SetActive(false)
		end
	end
	self.m_ExpEffectTimer = Utils.AddTimer(delay, 0, 1.5)
end

function CParSoulUpGradeView.RefreshItemPart(self)
	local itemList = self:GetParSoulList()
	self.m_AmountLabel:SetText("数量："..tostring(#itemList))
	itemList = self:GetDivideList(itemList)
	self.m_WrapContent:SetData(itemList, true)
	self.m_ScrollView:ResetPosition()
end

function CParSoulUpGradeView.GetParSoulList(self)
	local itemList = g_ItemCtrl:GetParSoulList()
	local resultList = {}
	local iCurID = self.m_CurItem.m_ID
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("parid") == 0 and oItem.m_ID ~= iCurID and oItem:GetValue("lock") == 0 and oItem:GetValue("plan") == 0 then
			table.insert(resultList, oItem)
		end
	end
	resultList = self:SortItem(resultList)
	return resultList
end

function CParSoulUpGradeView.SortItem(self, list)
	local sortList = {}
	for _, oItem in ipairs(list) do
		local t = {
			oItem,
			oItem:GetValue("soul_quality"), 
			oItem:GetValue("level"), 
			oItem.m_ID, 
		}
		table.insert(sortList, t)
	end
	local function cmp(listA, listB)
		for i = 2, 4 do
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

function CParSoulUpGradeView.GetDivideList(self, itemList)
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

function CParSoulUpGradeView.UpdateSel(self)
	for _, boxList in pairs(self.m_WrapContent:GetChildList()) do
		for _, oBox in ipairs(boxList.m_IconList) do
			if table.index(self.m_SelectList, oBox.m_ID) then
				oBox.m_SelSpr:SetActive(true)
			else
				oBox.m_SelSpr:SetActive(false)
			end
		end
	end
end

function CParSoulUpGradeView.UpdateGrade(self, iLevel, iNextLevel)
	local sCurgrade = "当前级别："..tostring(iLevel)
	local sNextgrade = ""
	if iNextLevel then
		sNextgrade = "下一级别："..tostring(iNextLevel)
	end
	local str = string.format("%-30s%s", sCurgrade, sNextgrade)
	self.m_GradeChangeLabel:SetText(str)
end

function CParSoulUpGradeView.UpdateAttr(self, iLevel, iNextLevel)
	local sAttr = self.m_CurItem:GetValue("attr")
	local sRatioAttr = self.m_CurItem:GetValue("attr_ratio")
	local dCurAttr = loadstring("return "..string.gsub(sAttr, "level", iLevel))() or {}
	local dRatio = loadstring("return "..string.gsub(sRatioAttr, "level", iLevel))() or {}
	table.update(dCurAttr, dRatio)

	local dNextAttr = {}
	if iNextLevel then
		dNextAttr = loadstring("return "..string.gsub(sAttr, "level", iNextLevel))() or {}
		local dRatio = loadstring("return "..string.gsub(sRatioAttr, "level", iNextLevel))() or {}
		table.update(dNextAttr, dRatio)
	end
	self.m_AttrGrid:Clear()
	local dConfig = data.partnerequipdata.EQUIPATTR
	for k, v in pairs(dCurAttr) do
		local name = dConfig[k]["name"]
		local curValue = v
		local nextValue = dNextAttr[k]
		local oBox = self.m_AttrBox:Clone()
		oBox.m_CurLabel = oBox:NewUI(1, CLabel)
		oBox.m_NextLabel = oBox:NewUI(2, CLabel)
		if not nextValue then
			oBox.m_NextLabel:SetActive(false)
			nextValue = 0
		end
		if string.endswith(k, "_ratio") or k == "critical_damage" then
			curValue = name.."："..self:GetPrintPecent(curValue)
			nextValue = name.."："..self:GetPrintPecent(nextValue)
		else
			curValue = name.."："..tostring(curValue)
			nextValue = name.."："..tostring(nextValue)
		end
		oBox.m_CurLabel:SetText(curValue)
		oBox.m_NextLabel:SetText(nextValue)
		oBox:SetActive(true)
		self.m_AttrGrid:AddChild(oBox)
	end
	self.m_AttrGrid:Reposition()
end

function CParSoulUpGradeView.UpdateExp(self)
	local oItem = self.m_CurItem
	local iLevel = oItem:GetValue("level")
	local iCurLevelExp, iNeedExp = self:GetUpGradeExp(oItem)
	self.m_ReachLevel = iLevel
	if iLevel == 15 then
		self:UpdateGrade(iLevel)
		self:UpdateAttr(iLevel)
		self.m_ExpLabel:SetText("御灵已满级")
		self.m_AddSlider:SetValue(0)
		self.m_ExpSlider:SetValue(1)
		return
	end
	self.m_ExpSlider:SetValue(iCurLevelExp / iNeedExp)
	if not next(self.m_SelectList) then
		self:UpdateGrade(iLevel)
		self:UpdateAttr(iLevel)
		self.m_AddSlider:SetValue(0)
		self.m_CostLabel:SetText("#w1 0")
		self.m_ExpLabel:SetText(string.format("%d/%d", iCurLevelExp, iNeedExp))
		return
	end

	local iReachLevel, iEatExp = self:GetReachLevel(oItem)
	self.m_ReachLevel = iReachLevel
	self.m_AddSlider:SetValue((iEatExp+iCurLevelExp) / iNeedExp)
	self.m_ExpLabel:SetText(string.format("%d/%d(+%d)", iCurLevelExp, iNeedExp, iEatExp))
	self:UpdateGrade(iLevel, iReachLevel)
	self:UpdateAttr(iLevel, iReachLevel)
	self:UpdateCost(iEatExp)
end

function CParSoulUpGradeView.UpdateCost(self, iExp)
	local sCalc = data.globaldata.GLOBAL["parsoul_upgrade_coin"]["value"]
	sCalc = string.replace(sCalc, "exp", tostring(iExp))
	local func = loadstring("return "..sCalc) 
	local iCost = func() or 0
	if g_AttrCtrl.coin >= iCost then
		self.m_CostLabel:SetText("#w1 "..string.numberConvert(iCost))
	else
		self.m_CostLabel:SetText("#R#w1 "..string.numberConvert(iCost))
	end
end

function CParSoulUpGradeView.GetSumEatExp(self)
	local iSumExp = 0
	for _, iItemID in ipairs(self.m_SelectList) do
		local oItem = g_ItemCtrl:GetItem(iItemID)
		if oItem then
			iSumExp = iSumExp + self:GetEatExp(oItem)
		end
	end
	return iSumExp
end

function CParSoulUpGradeView.GetEatExp(self, oItem)
	local iQuality =oItem:GetValue("soul_quality")
	local iLevel = oItem:GetValue("level")
	if self.m_ExpConfig[iQuality] and self.m_ExpConfig[iQuality][iLevel] then
		return self.m_ExpConfig[iQuality][iLevel][1]
	else
		return 0
	end
end

function CParSoulUpGradeView.GetUpGradeExp(self, oItem)
	local iQuality =oItem:GetValue("soul_quality")
	local iLevel = oItem:GetValue("level")
	local iExp = 0
	for i = 1, iLevel-1 do
		iExp = iExp + self.m_ExpConfig[iQuality][i][2]
	end
	local iFullExp = oItem:GetValue("exp")
	local iNeedExp = self.m_ExpConfig[iQuality][iLevel][2]
	return iFullExp - iExp, iNeedExp
end

function CParSoulUpGradeView.GetReachLevel(self, oItem)
	local iQuality =oItem:GetValue("soul_quality")
	local iLevel = oItem:GetValue("level")
	if iLevel == 15 then
		return 15, 0
	else
		local iEatExp = self:GetSumEatExp()
		local iCurExp = oItem:GetValue("exp") + iEatExp
		local iReachExp = 0
		for i = 1, 15 do
			iReachExp = iReachExp + self.m_ExpConfig[iQuality][i][2]
			if iCurExp < iReachExp then
				return i, iEatExp
			end
		end
		if iCurExp >= iReachExp then
			return 15, iEatExp
		end
	end
	return iLevel, 0
end

function CParSoulUpGradeView.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CParSoulUpGradeView.OnSortChange(self, oBox)
	self:RefreshItemPart()
end

function CParSoulUpGradeView.OnClickItem(self, oItem)
	local index = table.index(self.m_SelectList, oItem.m_ID)
	if index then
		table.remove(self.m_SelectList, index)
		self:UpdateSel()
		self:UpdateExp()
	else
		if oItem:GetValue("soul_quality") > 3 then
			local windowConfirmInfo = {
				msg = "橙色和红色品质的御灵为稀有御灵，是否继续添加用于吞食？",
				okCallback = function () 
					self:OnAddItem(oItem.m_ID)
				end,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			self:OnAddItem(oItem.m_ID)
		end
	end
end

function CParSoulUpGradeView.OnPress(self, oItem, oBox, press)
	if press then
		if oItem then
			g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {})
		end
	end
end

function CParSoulUpGradeView.OnAddItem(self, iItemID)
	if #self.m_SelectList >= 50 then
		g_NotifyCtrl:FloatMsg("一次只能吞食50个御灵")
		return
	end
	if self.m_ReachLevel == 15 then
		g_NotifyCtrl:FloatMsg("经验已达到最大")
		return
	end
	table.insert(self.m_SelectList, iItemID)
	self:UpdateSel()
	self:UpdateExp()
end

function CParSoulUpGradeView.OnFilter(self)
	CParSoulFilterView:ShowView(function(oView)
		oView:SetOkCallBack(callback(self, "BatSelectCb"))
	end)
end

function CParSoulUpGradeView.BatSelectCb(self, dSelectList)
	if dSelectList[4] or dSelectList[5] then
		local windowConfirmInfo = {
			msg = "橙色和红色品质的御灵为稀有御灵，是否继续添加用于吞食？",
			okCallback = function () 
				self:DoBatFilter(dSelectList)
			end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:DoBatFilter(dSelectList)
	end
	
end

function CParSoulUpGradeView.DoBatFilter(self, dSelectList)
	local oItem = self.m_CurItem
	local iQuality = oItem:GetValue("soul_quality")
	local iLevel = oItem:GetValue("level")
	local iMaxExp = 0
	for i = 1, 14 do
		iMaxExp = iMaxExp + self.m_ExpConfig[iQuality][i][2]
	end
	local iRestExp = iMaxExp - oItem:GetValue("exp")
	local iExp = 0
	local itemList = self:GetParSoulList()
	self.m_SelectList = {}
	local iAmount = 0
	for _, oItem in ipairs(itemList) do
		if iExp >= iRestExp then
			break
		end
		if iAmount >= 50 then
			break
		end
		if dSelectList[oItem:GetValue("soul_quality")] then
			iExp = iExp + self:GetEatExp(oItem)
			table.insert(self.m_SelectList, oItem.m_ID)
			iAmount = iAmount + 1
		end
	end
	self:UpdateSel()
	self:UpdateExp()
end

function CParSoulUpGradeView.OnUpGrade(self)
	if next(self.m_SelectList) then
		local resultList = table.slice(self.m_SelectList, 1, 50)
		if #self.m_SelectList > 50 then
			g_NotifyCtrl:FloatMsg("一次只能吞食50个御灵")
		end
		netpartner.C2GSUpgradePartnerSoul(self.m_CurItem.m_ID, resultList)
	else
		g_NotifyCtrl:FloatMsg("你未选择吞食的御灵")
	end
end

return CParSoulUpGradeView