local CPartnerEquipStonePage = class("CPartnerEquipStonePage", CPageBase)

function CPartnerEquipStonePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerEquipStonePage.OnInitPage(self)
	self.m_LeftPart = self:NewUI(1, CBox)
	self.m_StoneScrollView = self:NewUI(2, CScrollView)
	self.m_StoneGrid = self:NewUI(3, CGrid)
	self.m_StoneItem = self:NewUI(4, CBox)
	self.m_ComposeBtn = self:NewUI(5, CButton)
	self.m_TipBtn = self:NewUI(6, CButton)
	self.m_RightPart = self:NewUI(7, CBox)
	self.m_StoneItem:SetActive(false)
	self:InitLeft()
	self:InitRight()
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnCompose"))
	self.m_TipBtn:AddHelpTipClick("parequip_stone")
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerEquipStonePage.InitLeft(self)
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
	self.m_StarSpr:SetActive(false)
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnClickParItem"))
end

function CPartnerEquipStonePage.InitRight(self)
	local oPart = self.m_RightPart
	self.m_LeftScrollView = oPart:NewUI(3, CScrollView)
	self.m_LeftGrid = oPart:NewUI(4, CGrid)
	self.m_ProgressItem = oPart:NewUI(5, CBox)
	self.m_AttrLabel = oPart:NewUI(10, CLabel)
	self.m_ProgressItem:SetActive(false)
end

function CPartnerEquipStonePage.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerEquip then
		if self.m_CurItem.m_ID == oCtrl.m_EventData then
			local oItem = g_ItemCtrl:GetItem(oCtrl.m_EventData)
			self.m_UpdateFlag = true
			self:SetItemData(oItem)
			self.m_UpdateFlag = false
		end
	
	elseif oCtrl.m_EventID == define.Item.Event.AddItem or
		oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if oCtrl.m_EventData:IsPartnerStone() then
			self:UpdateStoneProgreee(self.m_CurItem)
		end
	end
end

function CPartnerEquipStonePage.SetItemData(self, oItem)
	self.m_CurItem = oItem
	self.m_EquipPos = oItem:GetValue("pos")
	self:UpdateItem(oItem)
	
	self:UpdateStoneProgreee(oItem)
	self:UpdateStoneList(oItem)
end

function CPartnerEquipStonePage.UpdateItem(self, oItem)
	self:UpdateStar(oItem:GetValue("star"))
	self.m_LevelLabel:SetText("+"..tostring(oItem:GetValue("level")))

	self.m_IconSpr:SpriteItemShape(CParEquipItem:GetIcon(oItem:GetValue("pos"), oItem:GetValue("stone_level")))
	self.m_NameLabel:SetText(oItem:GetValue("name"))
	local oPartner = g_PartnerCtrl:GetPartner(oItem:GetValue("parid"))
	if oPartner then
		self.m_PartnerName:SetActive(true)
		self.m_PartnerName:SetText(oPartner:GetValue("name"))
		self.m_NameBG:SetHeight(self.m_PartnerName:GetHeight()+30)
	else
		self.m_PartnerName:SetActive(false)
	end
end

function CPartnerEquipStonePage.UpdateStar(self, iStar)
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

function CPartnerEquipStonePage.UpdateStoneProgreee(self, oItem)
	local dData = data.partnerequipdata.ParEquip2Stone
	local iStar = oItem:GetValue("star")
	local dUnLockList = dData[iStar]["unlock_stone"]
	if not self.m_LeftGrid.m_InitGrid then
		self.m_LeftGrid.m_InitGrid = true
		for i = 1, 7 do
			local oBox = self:CreateProgressItem()
			self.m_LeftGrid:AddChild(oBox)
		end
	end
	self.m_StoneScrollView:ResetPosition()
	local dStoneList = oItem:GetValue("stone_info") or {}
	local dLv2Stone = {}
	for _, dStone in ipairs(dStoneList) do
		dLv2Stone[dStone.pos] = dStone
	end
	for i = 1, 7 do
		local oBox = self.m_LeftGrid:GetChild(i)
		if oBox then
			self:UpdateProgressItem(oBox, i, table.index(dUnLockList, i), dLv2Stone[i])
			oBox.m_ID = oItem.m_ID
		end
	end
	self:UpdateAttr(oItem)
end


function CPartnerEquipStonePage.CreateProgressItem(self)
	local oBox = self.m_ProgressItem:Clone()
	oBox:SetActive(true)
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_Slider = oBox:NewUI(3, CSlider)
	oBox.m_AddBtn = oBox:NewUI(4, CButton)
	oBox.m_FullBtn = oBox:NewUI(5, CButton)
	oBox.m_LockBtn = oBox:NewUI(6, CSprite)
	oBox.m_EffectObj = oBox:NewUI(7, CUIEffect)
	oBox.m_EffectNode = oBox:NewUI(8, CObject)
	oBox.m_AmountLabel = oBox:NewUI(9, CLabel)
	oBox.m_EffectObj:SetActive(false)
	return oBox
end

function CPartnerEquipStonePage.UpdateProgressItem(self, oBox, iLevel, bUnLock, dStone)
	local iPos = self.m_CurItem:GetValue("pos")
	local iShape = 300000 + iPos * 10000 + iLevel
	local dStoneData = data.itemdata.PAR_STONE[iShape]
	local dParStone2Count = data.partnerequipdata.ParStone2Count
	if not dStoneData then
		return
	end
	oBox.m_IconSpr:SpriteItemShape(dStoneData.icon)
	oBox.m_NameLabel:SetText(dStoneData.name)
	oBox.m_AddBtn:SetActive(false)
	oBox.m_FullBtn:SetActive(false)
	oBox.m_LockBtn:SetActive(false)
	oBox.m_EffectObj:Above(oBox.m_EffectNode)
	local iHaveAmount = g_ItemCtrl:GetBagItemAmountBySid(iShape)
	oBox.m_AmountLabel:SetText(tostring(iHaveAmount))
	oBox.m_AddBtn:UITweenEnabled(false)
	if dStone and bUnLock then
		local iAmount = #dStone.sids
		local iNeedAmount = dParStone2Count[iLevel]["inlay_count"]
		if oBox.m_LastValue and iAmount > oBox.m_LastValue then
			self:DoEffect(oBox)
		end
		oBox.m_Slider:SetValue(iAmount / iNeedAmount)
		oBox.m_LastValue = iAmount
		oBox.m_Slider:SetSliderText(string.format("%d/%d", iAmount, iNeedAmount))
		oBox.m_FullBtn:SetActive(iAmount >= iNeedAmount)
		oBox.m_AddBtn:SetActive(iAmount < iNeedAmount)
		if iAmount < iNeedAmount and iHaveAmount > 0 then
			oBox.m_AddBtn:UITweenEnabled(true)
			oBox.m_AddBtn:UITweenPlay()
		end
	elseif bUnLock then
		oBox.m_Slider:SetValue(0)
		oBox.m_LastValue = 0
		oBox.m_Slider:SetSliderText("--/"..tostring(dParStone2Count[iLevel]["inlay_count"]))
		oBox.m_AddBtn:SetActive(true)
		if iHaveAmount > 0 then
			oBox.m_AddBtn:UITweenEnabled(true)
			oBox.m_AddBtn:UITweenPlay()
		end
	else
		oBox.m_LockBtn:SetActive(true)
		oBox.m_Slider:SetValue(0)
		oBox.m_Slider:SetSliderText("--/--")
		local d = data.partnerequipdata.ParEquip2Stone
		local iStar = 6
		for i = 1, 6 do
			if d[i]["unlock_stone"][iLevel] then
				iStar = i
				break
			end
		end
		oBox.m_LockBtn:AddUIEvent("click", function ()
			g_NotifyCtrl:FloatMsg(string.format("符文达到%d星可解锁该符石的强化", iStar))
		end)
	end
	oBox.m_IconSpr:AddUIEvent("click", function ()
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(iShape, nil, {})
			oView:ForceShowFindWayBox(true)
		end)
	end)
	oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnInlayPartnerStone", iShape))
end

function CPartnerEquipStonePage.DoEffect(self, oBox)
	if not self.m_UpdateFlag then
		return
	end
	local function f()
		local function delay(obj)
			obj.m_EffectObj:SetActive(false)
			obj.m_EffectTimer = nil
		end
		oBox.m_EffectObj:SetActive(true)
		oBox.m_EffectTimer = Utils.AddTimer(objcall(oBox, delay), 0, 1.5)
	end
	oBox.m_EffectObj:SetActive(false)
	if oBox.m_EffectTimer then
		Utils.DelTimer(oBox.m_EffectTimer)
		Utils.AddTimer(f, 0 ,0)
	else
		f()
	end

end

function CPartnerEquipStonePage.DelayUpStoneList(self)
	if self.m_DealyTimer then
		return
	end
	local function delay(obj)
		obj:UpdateStoneList()
		obj.m_DealyTimer = nil
	end
	self.m_DealyTimer = Utils.AddTimer(objcall(self, delay), 0, 0.2)
end

function CPartnerEquipStonePage.UpdateStoneList(self)
	self:RefreshList()
end

function CPartnerEquipStonePage.RefreshList(self)
	local itemList = self:GetStoneList()
	self.m_StoneGrid:Clear()
	for _, oItem in ipairs(itemList) do
		local oBox = self:CreateStoneItem()
		self:UpdateStoneItem(oBox, oItem)
		self.m_StoneGrid:AddChild(oBox)
	end
	self.m_StoneGrid:Reposition()
	self.m_StoneScrollView:ResetPosition()
end

function CPartnerEquipStonePage.GetStoneList(self)
	local itemList = g_ItemCtrl:GetPartnerStone()
	local resultList = {}
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("equip_pos") == self.m_EquipPos then
			table.insert(resultList, oItem)
		end
	end
	table.sort(resultList, function (a, b)
		if a:GetValue("level") ~= b:GetValue("level") then
			return a:GetValue("level") < b:GetValue("level")
		end
		return a.m_ID < b.m_ID
	end)
	return resultList
end

function CPartnerEquipStonePage.CreateStoneItem(self)
	local oBox = self.m_StoneItem:Clone()
	oBox.m_SelSpr = oBox:NewUI(1, CSprite)
	oBox.m_AmountLabel = oBox:NewUI(3, CLabel)
	oBox.m_IconSpr = oBox:NewUI(4, CSprite)
	oBox.m_SelSpr:SetActive(false)
	oBox:SetActive(true)
	return oBox
end

function CPartnerEquipStonePage.UpdateStoneItem(self, oBox, oItem)
	oBox.m_AmountLabel:SetText(tostring(oItem:GetValue("amount")))
	oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
	oBox:AddUIEvent("click", callback(self, "OnClickLeftItem", oItem))
end

function CPartnerEquipStonePage.UpdateAttr(self, oItem)
	local dStoneInfo = oItem:GetValue("stone_info")
	local dAttrDict = {}
	for _, dStone in ipairs(dStoneInfo) do
		for _, dApply in ipairs(dStone.apply_info) do
			dAttrDict[dApply.key] = dAttrDict[dApply.key] or 0
			dAttrDict[dApply.key] = dAttrDict[dApply.key] + dApply.value
		end
	end
	local d = data.partnerequipdata.EQUIPATTR
	local strList = {}
	for attrkey, attrvalue in pairs(dAttrDict) do
		local str = d[attrkey]["name"].."+"
		if string.endswith(attrkey, "_ratio") or attrkey == "critical_damage" then
			local value = math.floor(attrvalue/10)/10
			if math.isinteger(value) then
				attrvalue = string.format("%d%%", value)
			else
				attrvalue = string.format("%.1f%%", value)
			end
		else
			attrvalue = tostring(attrvalue)
		end
		table.insert(strList, str..attrvalue)
	end
	self.m_AttrLabel:SetText(table.concat(strList, "、"))
end

function CPartnerEquipStonePage.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipStonePage.OnClickLeftItem(self, oItem, oBox)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItem:GetValue("sid"), {widget = oBox}, nil)
	end
end

function CPartnerEquipStonePage.OnCompose(self)
	local iPos = self.m_CurItem:GetValue("pos") or 1
	CPartnerStoneComposeView:ShowView(function (oView)
		oView:InitStoneType(iPos)
	end)
end

function CPartnerEquipStonePage.OnInlayPartnerStone(self, iShape)
	local itemList = g_ItemCtrl:GetItemIDListBySid(iShape)
	if itemList[1] then
		netpartner.C2GSInlayPartnerStone(self.m_CurItem.m_ID, itemList[1])
	else
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(iShape, nil, {showQuickBuy = true})
			oView:ForceShowFindWayBox(true)
		end)
	end
end

function CPartnerEquipStonePage.OnSwitchItem(self, index)
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

return CPartnerEquipStonePage
