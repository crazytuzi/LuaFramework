local CPartnerEquipUpGradePage = class("CPartnerEquipUpGradePage", CPageBase)

function CPartnerEquipUpGradePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerEquipUpGradePage.OnInitPage(self)
	self.m_LeftPart = self:NewUI(1, CBox)
	self.m_CostPart = self:NewUI(2, CBox)
	self.m_AttrPart = self:NewUI(3, CBox)
	self.m_UpGradeBtn = self:NewUI(4, CButton)
	self.m_FastUpGradeBtn = self:NewUI(5, CButton)
	self.m_TipBtn = self:NewUI(6, CButton)
	self.m_UpStarPart = self:NewUI(8, CObject)
	self.m_UpStarBtn = self:NewUI(9, CButton)

	self.m_NotEnough = false
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "OnUpGrade"))
	self.m_FastUpGradeBtn:AddUIEvent("click", callback(self, "OnFastUpGrade"))
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "OnShowUpStarPage"))
	self:InitLeft()
	self:InitCost()
	self:InitAttr()
	self.m_TipBtn:AddHelpTipClick("parequip_upgrade")
	g_GuideCtrl:AddGuideUI("partner_equip_strong_page_upgrade", self.m_UpGradeBtn)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerEquipUpGradePage.InitLeft(self)
	local oPart = self.m_LeftPart
	self.m_NameLabel = oPart:NewUI(1, CLabel)
	self.m_PartnerName = oPart:NewUI(2, CLabel)
	self.m_IconSpr = oPart:NewUI(3, CSprite)
	self.m_StarGrid = oPart:NewUI(4, CGrid)
	self.m_StarSpr = oPart:NewUI(5, CSprite)
	self.m_LevelLabel = oPart:NewUI(6, CLabel)
	self.m_NameBG = oPart:NewUI(7, CLabel)
	self.m_TipLabel = oPart:NewUI(8, CLabel)
	self.m_RightBtn = oPart:NewUI(9, CButton)
	self.m_LeftBtn = oPart:NewUI(10, CButton)

	--self.m_TipLabel:SetActive(false)
	self.m_LevelLabel:SetActive(false)
	self.m_StarSpr:SetActive(false)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnClickParItem"))
	self.m_LeftBtn:AddUIEvent("click",callback(self, "OnSwitchItem", -1))
	self.m_RightBtn:AddUIEvent("click",callback(self, "OnSwitchItem", 1))
end

function CPartnerEquipUpGradePage.InitCost(self)
	local oPart = self.m_CostPart
	self.m_ItemTips = oPart:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = oPart:NewUI(2, CLabel)
	self.m_CostLabel = oPart:NewUI(3, CLabel)
end

function CPartnerEquipUpGradePage.InitAttr(self)
	self.m_AttrChangeLabel = self.m_AttrPart:NewUI(1, CLabel)
	self.m_GradeChangeLabel = self.m_AttrPart:NewUI(2, CLabel)
end

function CPartnerEquipUpGradePage.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		if self.m_CurItem.m_ID == oCtrl.m_EventData.m_ID then
			self:SetItemData(oCtrl.m_EventData)
			self.m_ParentView:UpdateItem(oCtrl.m_EventData)
		end
	else
		if self.m_CurItem then
			self:UpdateCost(self.m_CurItem)
		end
	end

end

function CPartnerEquipUpGradePage.SetItemData(self, oItem)
	self.m_CurItem = oItem
	self:UpdateItem(oItem)
	self:UpdateCost(oItem)
	self.m_CostPart:SetActive(oItem:GetValue("level") < define.Partner.ParEquip.MaxLevel)
	self.m_UpStarPart:SetActive(oItem:GetValue("level") >= define.Partner.ParEquip.MaxLevel)
end

function CPartnerEquipUpGradePage.UpdateItem(self, oItem)
	local iLevel = oItem:GetValue("level")
	local iStar = oItem:GetValue("star")
	local iPos = oItem:GetValue("pos")
	local iNextLevel = math.min(iLevel + 1, define.Partner.ParEquip.MaxLevel)
	local str = string.format("当前级别：%d                下一级别：%d", iLevel, iNextLevel)
	if iNextLevel == iLevel then
		str = string.format("当前级别：%d", iLevel)
	end
	self.m_GradeChangeLabel:SetText(str)
	self.m_LevelLabel:SetText("+"..tostring(iLevel))
	self.m_IconSpr:SpriteItemShape(CParEquipItem:GetIcon(iPos, oItem:GetValue("stone_level")))
	self.m_NameLabel:SetText(oItem:GetValue("name"))

	local oPartner = g_PartnerCtrl:GetPartner(oItem:GetValue("parid"))
	if oPartner then
		self.m_PartnerName:SetActive(true)
		self.m_PartnerName:SetText(oPartner:GetValue("name"))
		self.m_NameBG:SetHeight(self.m_PartnerName:GetHeight()+30)
		local equipInfo = oPartner:GetCurEquipInfo()
		local bShow = table.count(equipInfo) > 1
		self.m_LeftBtn:SetActive(bShow)
		self.m_RightBtn:SetActive(bShow)
	else
		self.m_PartnerName:SetActive(false)
	end

	self:UpdateStar(iStar)
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

function CPartnerEquipUpGradePage.GetAttrChangeStr(self, key, value, nextvalue)
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

function CPartnerEquipUpGradePage.UpdateCost(self, oItem)
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

function CPartnerEquipUpGradePage.UpdateStar(self, iStar)
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

function CPartnerEquipUpGradePage.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipUpGradePage.OnUpGrade(self)
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

function CPartnerEquipUpGradePage.OnFastUpGrade(self)
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

function CPartnerEquipUpGradePage.OnShowUpStarPage(self)
	self.m_ParentView:ShowUpStarPage()
end

function CPartnerEquipUpGradePage.OnClickTipItem(self)
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
	end)
end

function CPartnerEquipUpGradePage.OnSwitchItem(self, index)
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

return CPartnerEquipUpGradePage
