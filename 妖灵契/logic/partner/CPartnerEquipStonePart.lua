local CPartnerEquipStonePart = class("CPartnerEquipStonePart", CPageBase)

function CPartnerEquipStonePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerEquipStonePart.InitPart(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ProgressItem = self:NewUI(3, CBox)
	self.m_ComposeBtn = self:NewUI(4, CButton)
	self.m_AttrLabel = self:NewUI(5, CLabel)
	--self.m_TipBtn = self:NewUI(6, CButton)
	self.m_ProgressItem:SetActive(false)
	self.m_ComposeBtn:AddUIEvent("click", callback(self, "OnCompose"))
	--self.m_TipBtn:AddHelpTipClick("parequip_stone")
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_InitPart = true
end


function CPartnerEquipStonePart.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerEquip then
		if self.m_CurItem and self.m_CurItem.m_ID == oCtrl.m_EventData then
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

function CPartnerEquipStonePart.SetItemData(self, oItem)
	if oItem then
		self.m_CurItem = oItem
		self.m_EquipPos = oItem:GetValue("pos")
		self:UpdateItem(oItem)
		self:UpdateStoneProgreee(oItem)
	end
end

function CPartnerEquipStonePart.UpdateItem(self, oItem)

end

function CPartnerEquipStonePart.UpdateStar(self, iStar)
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

function CPartnerEquipStonePart.UpdateStoneProgreee(self, oItem)
	local dData = data.partnerequipdata.ParEquip2Stone
	local iStar = oItem:GetValue("star")
	local dUnLockList = dData[iStar]["unlock_stone"]
	if not self.m_Grid.m_InitGrid then
		self.m_Grid.m_InitGrid = true
		for i = 1, 7 do
			local oBox = self:CreateProgressItem()
			self.m_Grid:AddChild(oBox)
		end
		self.m_ScrollView:ResetPosition()
	end
	
	local dStoneList = oItem:GetValue("stone_info") or {}
	local dLv2Stone = {}
	for _, dStone in ipairs(dStoneList) do
		dLv2Stone[dStone.pos] = dStone
	end
	for i = 1, 7 do
		local oBox = self.m_Grid:GetChild(i)
		if oBox then
			self:UpdateProgressItem(oBox, i, table.index(dUnLockList, i), dLv2Stone[i])
			oBox.m_ID = oItem.m_ID
		end
	end
	self:UpdateAttr(oItem)
end


function CPartnerEquipStonePart.CreateProgressItem(self)
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

function CPartnerEquipStonePart.UpdateProgressItem(self, oBox, iLevel, bUnLock, dStone)
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
			oView:SetInitBox(iShape, nil, {showQuickBuy = true})
			oView:ForceShowFindWayBox(true)
		end)
	end)
	oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnInlayPartnerStone", iShape))
end

function CPartnerEquipStonePart.DoEffect(self, oBox)
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


function CPartnerEquipStonePart.CreateStoneItem(self)
	local oBox = self.m_StoneItem:Clone()
	oBox.m_SelSpr = oBox:NewUI(1, CSprite)
	oBox.m_AmountLabel = oBox:NewUI(3, CLabel)
	oBox.m_IconSpr = oBox:NewUI(4, CSprite)
	oBox.m_SelSpr:SetActive(false)
	oBox:SetActive(true)
	return oBox
end

function CPartnerEquipStonePart.UpdateStoneItem(self, oBox, oItem)
	oBox.m_AmountLabel:SetText(tostring(oItem:GetValue("amount")))
	oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
	oBox:AddUIEvent("click", callback(self, "OnClickLeftItem", oItem))
end

function CPartnerEquipStonePart.UpdateAttr(self, oItem)
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

function CPartnerEquipStonePart.OnClickParItem(self)
	if self.m_CurItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(self.m_CurItem, {})
	end
end

function CPartnerEquipStonePart.OnClickLeftItem(self, oItem, oBox)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItem:GetValue("sid"), {widget = oBox}, nil)
	end
end

function CPartnerEquipStonePart.OnCompose(self)
	local iPos = self.m_CurItem:GetValue("pos") or 1
	CPartnerStoneComposeView:ShowView(function (oView)
		oView:InitStoneType(iPos)
	end)
end

function CPartnerEquipStonePart.OnInlayPartnerStone(self, iShape)
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

function CPartnerEquipStonePart.OnSwitchItem(self, index)
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

return CPartnerEquipStonePart
