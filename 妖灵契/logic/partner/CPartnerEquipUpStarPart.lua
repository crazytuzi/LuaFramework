local CPartnerEquipUpStarPart = class("CPartnerEquipUpStarPart", CBox)

function CPartnerEquipUpStarPart.ctor(self, obj)
	CBox.ctor(self, obj)
end

function CPartnerEquipUpStarPart.InitPart(self)
	self.m_CostPart = self:NewUI(1, CBox)
	self.m_AttrPart = self:NewUI(2, CBox)
	self.m_UpStarBtn = self:NewUI(3, CButton)
	self.m_LStarGrid = self:NewUI(4, CGrid)
	self.m_RStarGrid = self:NewUI(5, CGrid)
	self.m_StarSpr = self:NewUI(6, CSprite)
	self.m_RightPart = self:NewUI(7, CObject)
	self.m_NilPart = self:NewUI(8, CObject)
	self.m_FullPart = self:NewUI(9, CObject)
	self.m_StarSpr:SetActive(false)
	--self.m_TipBtn = self:NewUI(5, CButton)
	self:InitCost()
	self:InitAttr()
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "OnUpStar"))
	--self.m_TipBtn:AddHelpTipClick("parequip_upstar")
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_InitPart = true
end

function CPartnerEquipUpStarPart.InitCost(self)
	local oPart = self.m_CostPart
	self.m_ItemTips = oPart:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = oPart:NewUI(2, CLabel)
	self.m_CostLabel = oPart:NewUI(3, CLabel)
end

function CPartnerEquipUpStarPart.InitAttr(self)
	self.m_AttrChangeLabel = self.m_AttrPart:NewUI(1, CLabel)
	self.m_StoneChangeLabel = self.m_AttrPart:NewUI(2, CLabel)
end

function CPartnerEquipUpStarPart.OnItemCtrlEvent(self, oCtrl)
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

function CPartnerEquipUpStarPart.SetItemData(self, oItem)
	if oItem then
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
end


function CPartnerEquipUpStarPart.UpdateItem(self, oItem)
	local iLevel = oItem:GetValue("level")
	local iStar = oItem:GetValue("star")
	local iPos = oItem:GetValue("pos")
	local iNextStar = math.min(iStar + 1, define.Partner.ParEquip.MaxStar)
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

function CPartnerEquipUpStarPart.UpdateStone(self, iStar)
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

function CPartnerEquipUpStarPart.GetAttrChangeStr(self, key, value, nextvalue)
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

function CPartnerEquipUpStarPart.UpdateCost(self, oItem)
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

function CPartnerEquipUpStarPart.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipUpStarPart.OnUpStar(self)
	if self.m_Amount < self.m_NeedAmount then
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
			oView:ForceShowFindWayBox(true)
		end)
		return "升星道具不足"
	end
	if self.m_CurItem then
		netpartner.C2GSUpstarPartnerEquip(self.m_CurItem.m_ID)
	end
end

function CPartnerEquipUpStarPart.OnClickTipItem(self)
	CItemTipsSimpleInfoView:ShowView(function (oView)
		oView:SetInitBox(self.m_NeedItemID, nil, {showQuickBuy = true})
		oView:ForceShowFindWayBox(true)
	end)
end

function CPartnerEquipUpStarPart.OnSwitchItem(self, index)
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

return CPartnerEquipUpStarPart
