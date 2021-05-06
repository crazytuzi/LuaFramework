local CPartnerEquipUpGradePart = class("CPartnerEquipUpGradePart", CBox)

function CPartnerEquipUpGradePart.ctor(self, obj)
	CBox.ctor(self, obj)
end

function CPartnerEquipUpGradePart.InitPart(self)
	self.m_AttrPart = self:NewUI(1, CBox)
	self.m_CostPart = self:NewUI(2, CBox)
	
	self.m_UpGradeBtn = self:NewUI(3, CButton)
	self.m_FastUpGradeBtn = self:NewUI(4, CButton)
	self.m_UpStarPart = self:NewUI(5, CObject)
	self.m_UpStarBtn = self:NewUI(6, CButton)
	--self.m_TipBtn = self:NewUI(6, CButton)
	self.m_NotEnough = false
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "OnUpGrade"))
	self.m_FastUpGradeBtn:AddUIEvent("click", callback(self, "OnFastUpGrade"))
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "OnShowUpStarPage"))
	self:InitCost()
	self:InitAttr()
	--self.m_TipBtn:AddHelpTipClick("parequip_upgrade")
	g_GuideCtrl:AddGuideUI("partner_equip_strong_page_upgrade", self.m_UpGradeBtn)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_InitPart = true
end

function CPartnerEquipUpGradePart.InitCost(self)
	local oPart = self.m_CostPart
	self.m_ItemTips = oPart:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = oPart:NewUI(2, CLabel)
	self.m_CostLabel = oPart:NewUI(3, CLabel)
end

function CPartnerEquipUpGradePart.InitAttr(self)
	self.m_AttrChangeLabel = self.m_AttrPart:NewUI(1, CLabel)
	self.m_GradeChangeLabel = self.m_AttrPart:NewUI(2, CLabel)
end

function CPartnerEquipUpGradePart.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		if self.m_CurItem and self.m_CurItem.m_ID == oCtrl.m_EventData.m_ID then
			self:SetItemData(oCtrl.m_EventData)
		end
	else
		if self.m_CurItem then
			self:UpdateCost(self.m_CurItem)
		end
	end
end

function CPartnerEquipUpGradePart.SetItemData(self, oItem)
	if oItem then
		self.m_CurItem = oItem
		self:UpdateItem(oItem)
		self:UpdateCost(oItem)
		self.m_CostPart:SetActive(oItem:GetValue("level") < define.Partner.ParEquip.MaxLevel)
		self.m_UpStarPart:SetActive(oItem:GetValue("level") >= define.Partner.ParEquip.MaxLevel)
		self.m_UpStarBtn:SetActive(oItem:GetValue("star") < define.Partner.ParEquip.MaxStar)
	else

	end
end

function CPartnerEquipUpGradePart.UpdateItem(self, oItem)
	local iLevel = oItem:GetValue("level")
	local iStar = oItem:GetValue("star")
	local iPos = oItem:GetValue("pos")
	local iNextLevel = math.min(iLevel + 1, define.Partner.ParEquip.MaxLevel)
	local str = string.format("当前级别：%d                下一级别：%d", iLevel, iNextLevel)
	if iNextLevel == iLevel then
		str = string.format("当前级别：%d", iLevel)
	end
	self.m_GradeChangeLabel:SetText(str)
	local oPartner = g_PartnerCtrl:GetPartner(oItem:GetValue("parid"))
	local curAttrDict = oItem:GetParEquipBaseAttr()
	local oNextItem = CItem.NewBySid(g_ItemCtrl:GetParEquipShape(iPos, iStar, iNextLevel))
	local nextAttrDict = oNextItem:GetParEquipBaseAttr()
	local dResultDict = {}
	for attrkey, attrvalue in pairs(curAttrDict) do
		local nextvalue = nextAttrDict[attrkey]
		local str = self:GetAttrChangeStr(attrkey, attrvalue, nextvalue)
		table.insert(dResultDict, str)
	end
	self.m_AttrChangeLabel:SetText(table.concat(dResultDict, "\n"))
end

function CPartnerEquipUpGradePart.GetAttrChangeStr(self, key, value, nextvalue)
	local attrname = data.partnerequipdata.EQUIPATTR[key]["name"]
	if string.endswith(key, "_ratio") or key == "critical_damage" then
		value = math.floor(value/10)/10
		value = string.format("%.1f%%", value)
		nextvalue = math.floor(nextvalue/10)/10
		nextvalue = string.format("%.1f%%", nextvalue)
	else
		value = tostring(value)
		nextvalue = tostring(nextvalue)
	end
	local resultStr = string.format("%-12s%-20s%-16s", attrname, value, nextvalue)
	return resultStr
end

function CPartnerEquipUpGradePart.UpdateCost(self, oItem)
	local dUpgradeData = oItem:GetValue("upgrade_item")
	local iShape = dUpgradeData["sid"]
	local iNeedAmount = dUpgradeData["amount"]
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(iShape)
	self.m_NeedItemID = iShape
	self.m_ItemTips:SetItemData(iShape, 0, nil, {isLocal = true, uiType = 1})
	self.m_ItemTips:AddUIEvent("click", callback(self, "OnClickTipItem"))
	local str = ""
	if iAmount < iNeedAmount then
		self.m_NotEnough = true
		str = string.format("[a03320ff]%d[654a33ff]/%d", iAmount, iNeedAmount)
	else
		self.m_NotEnough = false
		str = string.format("[654a33ff]%d/%d", iAmount, iNeedAmount)
	end
	self.m_AmountLabel:SetText(str)
	local iCost = oItem:GetValue("upgrade_coin")
	if g_AttrCtrl.coin < iCost then
		self.m_CostLabel:SetText("#R#w1 "..string.numberConvert(iCost))
	else
		self.m_CostLabel:SetText("#w1 "..string.numberConvert(iCost))
	end
end

function CPartnerEquipUpGradePart.UpdateStar(self, iStar)
	self.m_StarGrid:Clear()
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		if iStar >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
		self.m_StarGrid:AddChild(spr)
	end
	self.m_StarGrid:Reposition()
end

function CPartnerEquipUpGradePart.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipUpGradePart.OnUpGrade(self)
	if self.m_CurItem then
		if self.m_NotEnough then
			Utils.AddTimer(function ()
				CItemTipsSimpleInfoView:ShowView(function (oView)
					oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
					oView:ForceShowFindWayBox(true)
				end)
			end, 0, 0)
			g_NotifyCtrl:FloatMsg(string.format("%s不足", DataTools.GetItemData(self.m_NeedItemID).name))
		else
			netpartner.C2GSStrengthPartnerEquip(self.m_CurItem.m_ID)
		end
	end
end

function CPartnerEquipUpGradePart.OnFastUpGrade(self)
	if self.m_CurItem then
		if self.m_NotEnough then
			Utils.AddTimer(function ()
				CItemTipsSimpleInfoView:ShowView(function (oView)
					oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
					oView:ForceShowFindWayBox(true)
				end)
			end, 0, 0)
			g_NotifyCtrl:FloatMsg(string.format("%s不足", DataTools.GetItemData(self.m_NeedItemID).name))
		else
			netpartner.C2GSStrengthPartnerEquip(self.m_CurItem.m_ID, 1)
		end
	end
end

function CPartnerEquipUpGradePart.OnShowUpStarPage(self)
	self.m_ParentView:ShowUpStarPart()
end

function CPartnerEquipUpGradePart.OnClickTipItem(self)
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
	end)
end

function CPartnerEquipUpGradePart.OnSwitchItem(self, index)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurItem:GetValue("parid"))
	if oPartner then
		local equipInfo = oPartner:GetCurEquipInfo()
		local iCurID = nil
		local dList = {}
		for i = 1, 4 do
			if equipInfo[i] then
				table.insert(dList, equipInfo[i])
				if equipInfo[i] == self.m_CurItem.m_ID then
					iCurID = #dList
				end
			end
		end
		local iTargetID = nil
		if index == -1 then
			if iCurID == 1 then
				iTargetID = dList[#dList]
			else
				iTargetID = dList[iCurID-1]
			end
		else
			if iCurID == #dList then
				iTargetID = dList[1]
			else
				iTargetID = dList[iCurID+1]
			end
		end
		local oTargetItem = g_ItemCtrl:GetItem(iTargetID)
		self:SetItemData(oTargetItem)
		self.m_ParentView:UpdateItem(oTargetItem)
	end
end

return CPartnerEquipUpGradePart
