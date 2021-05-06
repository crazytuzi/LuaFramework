local CPartnerEquipUpStarPage = class("CPartnerEquipUpStarPage", CPageBase)

function CPartnerEquipUpStarPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerEquipUpStarPage.OnInitPage(self)
	self.m_LeftPart = self:NewUI(1, CBox)
	self.m_CostPart = self:NewUI(2, CBox)
	self.m_AttrPart = self:NewUI(3, CBox)
	self.m_UpStarBtn = self:NewUI(4, CButton)
	self.m_TipBtn = self:NewUI(5, CButton)
	self.m_LStarGrid = self:NewUI(6, CGrid)
	self.m_RStarGrid = self:NewUI(7, CGrid)
	self.m_StarSpr = self:NewUI(8, CSprite)
	self.m_RightPart = self:NewUI(9, CObject)
	self.m_NilPart = self:NewUI(10, CObject)
	self.m_FullPart = self:NewUI(11, CObject)
	self.m_StarSpr:SetActive(false)

	self:InitLeft()
	self:InitCost()
	self:InitAttr()
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "OnUpStar"))
	self.m_TipBtn:AddHelpTipClick("parequip_upstar")
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerEquipUpStarPage.InitLeft(self)
	local oPart = self.m_LeftPart
	self.m_NameLabel = oPart:NewUI(1, CLabel)
	self.m_PartnerName = oPart:NewUI(2, CLabel)
	self.m_IconSpr = oPart:NewUI(3, CSprite)
	self.m_StarGrid = oPart:NewUI(4, CGrid)
	self.m_StarSpr = oPart:NewUI(5, CSprite)
	self.m_LevelLabel = oPart:NewUI(6, CLabel)
	self.m_NameBG = oPart:NewUI(7, CSprite)
	self.m_RightBtn = oPart:NewUI(8, CButton)
	self.m_LeftBtn = oPart:NewUI(9, CButton)
	self.m_StarSpr:SetActive(false)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnClickParItem"))
	self.m_LeftBtn:AddUIEvent("click",callback(self, "OnSwitchItem", -1))
	self.m_RightBtn:AddUIEvent("click",callback(self, "OnSwitchItem", 1))
end

function CPartnerEquipUpStarPage.InitCost(self)
	local oPart = self.m_CostPart
	self.m_ItemTips = oPart:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = oPart:NewUI(2, CLabel)
	self.m_CostLabel = oPart:NewUI(3, CLabel)
end

function CPartnerEquipUpStarPage.InitAttr(self)
	self.m_AttrChangeLabel = self.m_AttrPart:NewUI(1, CLabel)
	self.m_StoneChangeLabel = self.m_AttrPart:NewUI(2, CLabel)
end

function CPartnerEquipUpStarPage.OnItemCtrlEvent(self, oCtrl)
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

function CPartnerEquipUpStarPage.SetItemData(self, oItem)
	self.m_CurItem = oItem
	self:UpdateItem(oItem)
	local bShow = oItem:GetValue("level") < define.Partner.ParEquip.MaxLevel
	self.m_UpStarBtn:SetActive(not bShow)
	self.m_CostLabel:SetActive(not bShow)
	local iStar = oItem:GetValue("star")
	self.m_RightPart:SetActive(iStar ~= 6)
	self.m_FullPart:SetActive(iStar == 6)
	self.m_NilPart:SetActive(bShow and iStar ~= 6)
	self:UpdateCost(oItem)
end


function CPartnerEquipUpStarPage.UpdateItem(self, oItem)
	local iLevel = oItem:GetValue("level")
	local iStar = oItem:GetValue("star")
	local iPos = oItem:GetValue("pos")
	local iNextStar = math.min(iStar + 1, define.Partner.ParEquip.MaxStar)
	
	self.m_LevelLabel:SetText("+"..tostring(iLevel))
	self.m_IconSpr:SpriteItemShape(CParEquipItem:GetIcon(iPos, oItem:GetValue("stone_level")))
	self.m_NameLabel:SetText(oItem:GetValue("name"))
	local oPartner = g_PartnerCtrl:GetPartner(oItem:GetValue("parid"))
	if oPartner then
		self.m_PartnerName:SetActive(true)
		self.m_PartnerName:SetText(oPartner:GetValue("name"))
		self.m_NameBG:SetHeight(self.m_PartnerName:GetHeight()+30)
	else
		self.m_PartnerName:SetActive(false)
	end
	self:UpdateStar(iStar)

	self.m_LStarGrid:Clear()
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		if iStar >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
		self.m_LStarGrid:AddChild(spr)
	end
	self.m_LStarGrid:Reposition()
	self.m_RStarGrid:Clear()
	if iNextStar ~= iStar then
		for i = 1, 6 do
			local spr = self.m_StarSpr:Clone()
			spr:SetActive(true)
			if iNextStar >= i then
				spr:SetSpriteName("pic_chouka_dianliang")
			else
				spr:SetSpriteName("pic_chouka_weidianliang")
			end
			self.m_RStarGrid:AddChild(spr)
		end
	end
	self.m_RStarGrid:Reposition()
	
	local curAttrDict = oItem:GetParEquipBaseAttr()
	local oNextItem = CItem.NewBySid(g_ItemCtrl:GetParEquipShape(iPos, iNextStar, 1))
	local nextAttrDict = oNextItem:GetParEquipBaseAttr()
	local dResultDict = {}
	for attrkey, attrvalue in pairs(curAttrDict) do
		local nextvalue = nextAttrDict[attrkey]
		local str = self:GetAttrChangeStr(attrkey, attrvalue, nextvalue)
		table.insert(dResultDict, str)
	end
	self.m_AttrChangeLabel:SetText(table.concat(dResultDict, "\n"))
	self:UpdateStone(iStar)
end

function CPartnerEquipUpStarPage.UpdateStone(self, iStar)
	-- if iStar > 5 then
	-- 	self.m_StoneChangeLabel:SetText("")
	-- else
	-- 	local str = string.format("[9e8958]解锁[a03320]%d[-]级符石的吞食", iStar+1)
	-- 	if iStar == 5 then
	-- 		str = "[9e8958]解锁[a03320]6、7[-]级符石的吞食"
	-- 	end
	-- 	self.m_StoneChangeLabel:SetText(str)
	-- end
end

function CPartnerEquipUpStarPage.GetAttrChangeStr(self, key, value, nextvalue)
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

function CPartnerEquipUpStarPage.UpdateCost(self, oItem)
	if oItem:GetValue("star") > 5 then
		return
	end
	local dUpgradeData = oItem:GetValue("upstar_item")
	local iShape = dUpgradeData["sid"]
	local iNeedAmount = dUpgradeData["amount"]
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(iShape)
	self.m_ItemTips:SetItemData(iShape, 0, nil, {isLocal = true, uiType = 1})
	self.m_ItemTips:AddUIEvent("click", callback(self, "OnClickTipItem"))
	local str = ""
	if iAmount < iNeedAmount then
		str = string.format("[a03320ff]%d[654a33ff]/%d", iAmount, iNeedAmount)
	else
		str = string.format("[654a33ff]%d/%d", iAmount, iNeedAmount)
	end
	self.m_Amount = iAmount
	self.m_NeedAmount = iNeedAmount
	self.m_NeedItemID = iShape
	self.m_AmountLabel:SetText(str)
	local iCost = oItem:GetValue("upstar_coin")
	if g_AttrCtrl.coin < iCost then
		self.m_CostLabel:SetText("#R#w1 "..string.numberConvert(iCost))
	else
		self.m_CostLabel:SetText("#w1 "..string.numberConvert(iCost))
	end
end

function CPartnerEquipUpStarPage.UpdateStar(self, iStar)
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

function CPartnerEquipUpStarPage.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipUpStarPage.OnUpStar(self)
	if self.m_Amount < self.m_NeedAmount then
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(self.m_NeedItemID, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
		return "升星道具不足"
	end
	if self.m_CurItem then
		netpartner.C2GSUpstarPartnerEquip(self.m_CurItem.m_ID)
	end
end

function CPartnerEquipUpStarPage.OnClickTipItem(self)
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
	end)
end

function CPartnerEquipUpStarPage.OnSwitchItem(self, index)
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

return CPartnerEquipUpStarPage
