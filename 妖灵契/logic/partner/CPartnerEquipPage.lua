local CPartnerEquipPage = class("CPartnerEquipPage", CPageBase)

function CPartnerEquipPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerEquipPage.OnInitPage(self)
	self.m_EmptyLabel = self:NewUI(2, CLabel)
	self.m_LeftPart = self:NewUI(3, CBox)
	self.m_TipsBtn = self:NewUI(4, CButton)
	self.m_EmptyPart = self:NewUI(5, CObject)
	self.m_UpGradeBtn = self:NewUI(6, CButton)
	self.m_UpStarBtn = self:NewUI(7, CButton)
	self.m_UpStoneBtn = self:NewUI(8, CButton)
	self.m_UpGradePart = self:NewUI(9, CPartnerEquipUpGradePart)
	self.m_UpStarPart = self:NewUI(10, CPartnerEquipUpStarPart)
	self.m_UpStonePart = self:NewUI(11, CPartnerEquipStonePart)
	self.m_UpGradePart.m_ParentView = self
	self.m_RowAmount = 3
	self:InitLeftPart()
	self:InitSideBtn()
	self.m_TipsBtn:AddHelpTipClick("partner_equip")
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
end

function CPartnerEquipPage.InitLeftPart(self)
	local oPart = self.m_LeftPart
	self.m_CurEquipBox = oPart:NewUI(1, CBox)
	self.m_AttrGrid = oPart:NewUI(2, CGrid)
	self.m_AttrBox = oPart:NewUI(3, CBox)
	self.m_GradeLabel = oPart:NewUI(4, CLabel)
	self.m_IconBG = oPart:NewUI(5, CSprite)
	self.m_StarGrid = oPart:NewUI(6, CGrid)
	self.m_StarBox = oPart:NewUI(7,CBox)
	self.m_RareSpr = oPart:NewUI(8, CSprite)
	
	self.m_AwakeSpr = oPart:NewUI(9, CObject)
	self.m_ChangeEquipBtn = oPart:NewUI(10, CButton)
	self.m_StarBox:SetActive(false)
	self:InitEquipGrid()
	self:InitAttr()
	self.m_ChangeEquipBtn:AddUIEvent("click", callback(self, "OnChangeEquipPlan"))
end

function CPartnerEquipPage.InitSideBtn(self)
	self.m_UpGradeBtn:SetGroup(self.m_UpGradeBtn:GetInstanceID())
	self.m_UpStarBtn:SetGroup(self.m_UpGradeBtn:GetInstanceID())
	self.m_UpStoneBtn:SetGroup(self.m_UpGradeBtn:GetInstanceID())
	self.m_UpGradeBtn:SetSelected(true)
	self.m_UpGradePart:SetActive(true)
	self.m_UpStarPart:SetActive(true)
	self.m_UpStonePart:SetActive(true)
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "SwitchPart"))
	self.m_UpStarBtn:AddUIEvent("click", callback(self, "SwitchPart"))
	self.m_UpStoneBtn:AddUIEvent("click", callback(self, "SwitchPart"))
	self:SwitchPart()
end

function CPartnerEquipPage.InitEquipGrid(self)
	local grid = self.m_CurEquipBox
	self.m_EquipDict = {}
	local dPos2UnLockLevel = data.partnerequipdata.ParEquipUnlock
	for i = 1, 4 do
		local equipbox = grid:NewUI(i, CBox)
		equipbox.m_Item = equipbox:NewUI(1, CParEquipItem)
		equipbox.m_Item:AddUIEvent("longpress", callback(self, "OnClickEquip", equipbox.m_Item, i))
		equipbox.m_Item:AddUIEvent("click", callback(self, "OnAddEquip", i, false))
		equipbox.m_AddBtn = equipbox:NewUI(2, CButton)
		equipbox.m_SelSpr = equipbox:NewUI(3, CSprite)
		equipbox.m_PosLabel = equipbox:NewUI(4, CLabel)
		equipbox.m_LockLabel = equipbox:NewUI(5, CLabel)
		equipbox.m_LockLabel:SetText(tostring(dPos2UnLockLevel[i]["unlock_grade"]))
		equipbox:AddUIEvent("click", callback(self, "OnBtnClick", "OnAddEquip", i, false))
		self.m_EquipDict[i] = equipbox
		if i == 1 or i == 2 then
			g_GuideCtrl:AddGuideUI(string.format("partner_equip_left_pos_%d_fuwen_btn", i), equipbox.m_Item)
			g_GuideCtrl:AddGuideUI(string.format("partner_equip_left_pos_%d_add_btn", i), equipbox)	
		end
	end
end

function CPartnerEquipPage.InitAttr(self)
	self.m_AttrLabelList = {}
	for i = 1, 10 do
		self.m_AttrLabelList[i] = self.m_AttrBox:NewUI(i, CLabel)
		self.m_AttrLabelList[i]:SetColor(Color.New(255/255, 255/255, 255/255, 255/255))
	end
end

function CPartnerEquipPage.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self:SetPartnerID(self.m_CurParID)
		end
	end
end

function CPartnerEquipPage.OnItemCtrlEvent(self, oCtrl)
	local t = {
		define.Item.Event.RefreshBagItem,
		define.Item.Event.RefreshSpecificItem,
		define.Item.Event.RefreshPartnerEquip,
		define.Item.Event.DelItem,
		define.Item.Event.AddItem,
	}
	if table.index(t, oCtrl.m_EventID) then
		
	end
end

function CPartnerEquipPage.SetPartnerID(self, iParID)
	self.m_CurParID = iParID
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	self:UpdatePartner()
	self:UpdateEquip()
	self:UpdateAttrGrid()
end

function CPartnerEquipPage.UpdateView(self)
	
end

function CPartnerEquipPage.SwitchPart(self)
	self.m_UpGradePart:SetActive(false)
	self.m_UpStarPart:SetActive(false)
	self.m_UpStonePart:SetActive(false)
	if self.m_UpGradeBtn:GetSelected() then
		self.m_CurPart = self.m_UpGradePart
		self.m_UpGradePart:SetActive(true)
	elseif self.m_UpStarBtn:GetSelected() then
		self.m_CurPart = self.m_UpStarPart
		self.m_UpStarPart:SetActive(true)
	elseif self.m_UpStoneBtn:GetSelected() then
		self.m_CurPart = self.m_UpStonePart
		self.m_UpStonePart:SetActive(true)
	end

	if self.m_CurPart and not self.m_CurPart.m_InitPart then
		self.m_CurPart:InitPart()
	end
	self:OnAddEquipNotSwitch(self.m_LastPos or 1, true)
end

function CPartnerEquipPage.ShowUpGradePart(self, oItem)
	self.m_UpGradeBtn:SetSelected(true)
	self:SwitchPart()
	if oItem and self.m_CurPart and self.m_CurPart.SetItemData then
		self.m_CurPart:SetItemData(oItem)
	end
end

function CPartnerEquipPage.ShowUpStarPart(self, oItem)
	self.m_UpStarBtn:SetSelected(true)
	self:SwitchPart()
	if oItem and self.m_CurPart and self.m_CurPart.SetItemData then
		self.m_CurPart:SetItemData(oItem)
	end
end

function CPartnerEquipPage.ShowUpStonePart(self, pos)
	self.m_UpStoneBtn:SetSelected(true)
	self:SwitchPart()
	if pos then
		self:OnAddEquip(pos, true)
	end
end

function CPartnerEquipPage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		--self:ShowUI(false)
		return
	end
	--self:ShowUI(true)
	self.m_IconBG:SpriteAvatarBig(oPartner:GetIcon())
	g_PartnerCtrl:ChangeRareBorder(self.m_RareSpr, oPartner:GetValue("rare"))
	self.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
	self:UpdateStar(oPartner:GetValue("star"))
	self.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
	self:UpdateAttrGrid()
end

function CPartnerEquipPage.UpdateStar(self, iStar)
	if self.m_StarGrid:GetCount() <= 0 then
		self.m_StarGrid:Clear()
		for i = 1, 5 do
			local box = self.m_StarBox:Clone()
			box.m_GreyStar = box:NewUI(1, CSprite)
			box.m_Star = box:NewUI(2, CSprite)
			box.m_Star:SetActive(iStar >= i)
			box.m_GreyStar:SetActive(true)
			box:SetActive(true)
			self.m_StarGrid:AddChild(box)
		end
		self.m_StarGrid:Reposition()
	else
		for i = 1, 5 do
			local box = self.m_StarGrid:GetChild(i)
			box.m_Star:SetActive(iStar >= i)
		end
	end
end

function CPartnerEquipPage.UpdateEquip(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local info = oPartner:GetCurEquipInfo()
	local bShowRedSpr = false
	if g_PartnerCtrl:IsFight(oPartner.m_ID) then
		bShowRedSpr = true
	end
	local iGrade = g_AttrCtrl.grade
	local dPos2UnLockLevel = data.partnerequipdata.ParEquipUnlock
	for i, itemobj in pairs(self.m_EquipDict) do
		itemobj.m_LockLabel:SetActive(false)
		itemobj.m_PosLabel:SetActive(true)
		if info[i] then
			itemobj.m_Item:SetActive(true)
			itemobj.m_Item:SetItem(info[i])
			itemobj.m_PosLabel:SetActive(false)
			itemobj.m_AddBtn:SetActive(false)
			itemobj.m_ID = info[i]
			itemobj.m_Item:DelEffect("RedDot")
			if bShowRedSpr then
				local oItem = g_ItemCtrl:GetItem(info[i])
				if (oItem:IsHasParEquipUpGradeRedPoint() or oItem:IsHasParEquipUpStarRedPoint() or oItem:IsParEquipCanUpStone()) then
					itemobj.m_Item:AddEffect("RedDot")
				end
			end
		else
			if iGrade < dPos2UnLockLevel[i]["unlock_grade"] then
				itemobj.m_LockLabel:SetActive(true)
				itemobj.m_PosLabel:SetActive(false)
			end
			itemobj.m_ID = nil
			itemobj.m_Item:SetActive(false)
			itemobj.m_AddBtn:SetActive(false)
		end
	end
	self:OnAddEquip(self.m_LastPos or 1, true)
	self:ChangePart()
end

function CPartnerEquipPage.UpdateAttrGrid(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local info = oPartner:GetCurEquipInfo()

	local itemlist = {}
	for k, itemid in pairs(info) do
		table.insert(itemlist, itemid)
	end
	local attrdict = g_ItemCtrl:GetEquipListAttr(itemlist)
	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio", 
	"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}
	
	local oriattr = oPartner:GetOriAttr()
	if oriattr then
		local ratiolist = {"defense", "attack", "maxhp"}
		for _, attrkey in pairs(ratiolist) do
			if attrdict[attrkey.."_ratio"]["value"] > 0 then
				attrdict[attrkey]["value"] = attrdict[attrkey]["value"] + oriattr[attrkey]*attrdict[attrkey.."_ratio"]["value"]/10000
			end
		end
	end
	local resetlabel = self.m_AttrParID ~= self.m_CurParID
	for i, key in pairs(t) do
		local attrobj = attrdict[key]
		if resetlabel then
			self.m_AttrLabelList[i].m_PreNum = nil
		end
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			local num = math.floor(attrobj["value"]/10)/10
			self:DoSetTextEffect(self.m_AttrLabelList[i], num, true)
		else
			local num = attrobj["value"]
			self:DoSetTextEffect(self.m_AttrLabelList[i], num)
		end
	end
	self.m_AttrParID = self.m_CurParID
end

function CPartnerEquipPage.UpdateRedSpr(self)
	local oItem = g_ItemCtrl:GetItem(self.m_CurItemID)
	if oItem then
		if oItem:IsPartnerEquipCanUpGrade() and not self.m_UpGradeBtn:GetSelected() then
			self.m_UpGradeBtn:AddEffect("RedDot", 25)
		else
			self.m_UpGradeBtn:DelEffect("RedDot")
		end
		if oItem:IsPartnerEquipCanUpStar() and not self.m_UpStarBtn:GetSelected() then
			self.m_UpStarBtn:AddEffect("RedDot", 25)
		else
			self.m_UpStarBtn:DelEffect("RedDot")
		end
		if oItem:GetParEquipUpStoneResult() and not self.m_UpStoneBtn:GetSelected() then
			self.m_UpStoneBtn:AddEffect("RedDot", 25)
		else
			self.m_UpStoneBtn:DelEffect("RedDot")
		end
	else
		self.m_UpGradeBtn:DelEffect("RedDot")
		self.m_UpStarBtn:DelEffect("RedDot")
		self.m_UpStoneBtn:DelEffect("RedDot")
	end
end

function CPartnerEquipPage.DoSetTextEffect(self, oLabel, num, ispecent)
	if not oLabel.m_PreNum then
		self:SetLabelText(oLabel, num, ispecent)
		oLabel.m_PreNum = num
	elseif num == oLabel.m_PreNum then
		return 
	else
		local color = "#R"
		if num > oLabel.m_PreNum then
			color = "#G"
		end
		local detal = (num - oLabel.m_PreNum) / 20
		if oLabel.m_EffectTimer then
			Utils.DelTimer(oLabel.m_EffectTimer)
		end
		local starnum = oLabel.m_PreNum
		local idx = 0
		local function update()
			if Utils.IsNil(self) then
				return
			end
			idx = idx + 1
			if idx >= 20 then
				oLabel.m_PreNum = num
				self:SetLabelText(oLabel, num, ispecent)
			else
				local curnum = starnum + detal * idx
				self:SetLabelText(oLabel, curnum, ispecent, color)
				return true
			end
		end
		oLabel.m_EffectTimer = Utils.AddTimer(update, 0.05, 0.05)
	end
end

function CPartnerEquipPage.SetLabelText(self, oLabel, num, ispecent, color)
	color = color or "[654A33]"
	if ispecent then
		if math.isinteger(num) then
			oLabel:SetText(string.format("%s%d%%", color, num))
		else
			oLabel:SetText( string.format("%s%.1f%%", color, num) )
		end
	else
		if num > 0 and num < 1 then
			oLabel:SetText(string.format("%s1", color))
		else
			oLabel:SetText(string.format("%s%d", color, num))
		end
	end
end

function CPartnerEquipPage.OnClickItem(self, oItem)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local args = {
		partner = oPartner,
	}
	g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, args)
end

function CPartnerEquipPage.OnBtnClick(self, funcName, ...)
	local idx = nil
	if funcName == "OnClickEquip" then
		idx = select(2, ...)
	end
	if self[funcName] then
		self[funcName](self, ...)
	end
end

function CPartnerEquipPage.OnClickEquip(self, itemobj, i, oBox, bpress)
	if bpress then
		local oItem = g_ItemCtrl:GetItem(itemobj.m_ItemID)
		if oItem then
			local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
			local args = {
				partner = oPartner,
				widget = self.m_IconBG,
				side = enum.UIAnchor.Side.Right,
				offset = Vector2.New(-50, 0),
			}
			if oItem:GetValue("pos") > 3 then
				args = {
				partner = oPartner,
				widget = self.m_IconBG,
				side = enum.UIAnchor.Side.Left,
				offset = Vector2.New(50, 0),
			}
			end
			g_WindowTipCtrl:SetWindowItemTipsPartnerEquipInfo(oItem, args)
			self:OnAddEquip(oItem:GetValue("pos"))
		end
	end
end

function CPartnerEquipPage.OnAddEquip(self, iPos, bHideBuy)
	self:UpdateSel(iPos)
	local itemID = self.m_EquipDict[iPos].m_ID
	local oItem = g_ItemCtrl:GetItem(itemID)
	self.m_CurItemID = itemID
	self:UpdateRedSpr()
	if oItem then
		self.m_CurPart:SetActive(true)
		self.m_EmptyPart:SetActive(false)
		self.m_CurPart:SetItemData(oItem)
		oItem.m_ParEquipUpGradeRedFlag = true
		oItem.m_ParEquipUpStarRedFlag = true
		oItem.m_ParEquipUpStoneRedFlag = true
		g_PartnerCtrl:DelayEvent(define.Partner.Event.UpdateRedPoint, self.m_CurParID)
		self:ChangePart()
	else
		if not bHideBuy and not self.m_EquipDict[iPos].m_LockLabel:GetActive() then
			self:OnBuyParEquip(iPos)
		end
		self.m_CurPart:SetActive(false)
		if self.m_EquipDict[iPos].m_LockLabel:GetActive() then
			local sText = self.m_EquipDict[iPos].m_LockLabel:GetText()
			self.m_EmptyLabel:SetText("主角"..sText.."级解锁")
		else
			self.m_EmptyLabel:SetText("未穿戴符文")
		end
		self.m_EmptyPart:SetActive(true)
	end
end

function CPartnerEquipPage.ChangePart(self)
	local oItem = g_ItemCtrl:GetItem(self.m_CurItemID)
	if oItem and oItem:GetValue("level") == define.Partner.ParEquip.MaxLevel and oItem:GetValue("star") < define.Partner.ParEquip.MaxStar then
		if self.m_CurPart ~= self.m_UpStarPart and self.m_CurPart ~= self.m_UpStonePart then
			self.m_UpStarBtn:SetSelected(true)
			self:SwitchPart()
		end
	end
end

function CPartnerEquipPage.OnAddEquipNotSwitch(self, iPos, bHideBuy)
	self:UpdateSel(iPos)
	local itemID = self.m_EquipDict[iPos].m_ID
	local oItem = g_ItemCtrl:GetItem(itemID)
	self.m_CurItemID = itemID
	self:UpdateRedSpr()
	if oItem then
		self.m_CurPart:SetActive(true)
		self.m_EmptyPart:SetActive(false)
		self.m_CurPart:SetItemData(oItem)
		oItem.m_ParEquipUpGradeRedFlag = true
		oItem.m_ParEquipUpStarRedFlag = true
		oItem.m_ParEquipUpStoneRedFlag = true
		g_PartnerCtrl:DelayEvent(define.Partner.Event.UpdateRedPoint, self.m_CurParID)
	else
		if not bHideBuy and not self.m_EquipDict[iPos].m_LockLabel:GetActive() then
			self:OnBuyParEquip(iPos)
		end
		self.m_CurPart:SetActive(false)
		if self.m_EquipDict[iPos].m_LockLabel:GetActive() then
			local sText = self.m_EquipDict[iPos].m_LockLabel:GetText()
			self.m_EmptyLabel:SetText("主角"..sText.."级解锁")
		else
			self.m_EmptyLabel:SetText("未穿戴符文")
		end
		self.m_EmptyPart:SetActive(true)
	end
end

function CPartnerEquipPage.UpdateSel(self, iPos)
	self.m_LastPos = iPos
	for i = 1, 4 do
		self.m_EquipDict[i].m_SelSpr:SetActive(i == iPos)
	end
end

function CPartnerEquipPage.OnBuyParEquip(self, iPos)
	local iPos = iPos or 1
	local iShape = g_ItemCtrl:GetParEquipShape(iPos, 1, 1)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local dPos2UnLockLevel = data.partnerequipdata.ParEquipUnlock
	if g_AttrCtrl.grade < dPos2UnLockLevel[iPos]["unlock_grade"] then
		g_NotifyCtrl:FloatMsg(string.format("主角达到%d级时解锁", dPos2UnLockLevel[iPos]["unlock_grade"]))
		return
	end
	local info = nil
	if oPartner then
		info = oPartner:GetCurEquipInfo()
	end
	local d = DataTools.GetItemData(iShape)
	CBaseBuyItemView:ShowView(function (oView)
		oView:SetInfo(iShape, 1, d.buy_price , g_AttrCtrl.coin)
		oView:SetBuyCb(callback(self, "OnClickBuy", info, iPos))
		if info and not info[iPos] then
			oView.m_BuyBtn:SetText("购买并佩戴")
		else
			oView.m_BuyBtn:SetText("购买")
		end
	end)
end

function CPartnerEquipPage.OnClickBuy(self, info, iPos, iAmount)
	if iAmount > 0 then
		local func = nil
		if not info or info[iPos] then
			func = function () netpartner.C2GSBuyPartnerBaseEquip(iPos) end
		else
			func = function () netpartner.C2GSBuyPartnerBaseEquip(iPos, self.m_CurParID) end
		end
		func()
	end
end

function CPartnerEquipPage.OnFastSell(self)
	local itemList = g_ItemCtrl:GetPartnerEquip()
	local resultList = {}
	for _, oItem in ipairs(itemList) do
		if oItem:GetValue("parid") == 0 and 
			oItem:GetValue("lock") == 0 and
			oItem:GetValue("star") == 1 and
			oItem:GetValue("level") == 1 then
			table.insert(resultList, oItem.m_ID)
		end
	end
	if #resultList > 0 then
		local windowConfirmInfo = {
			msg				= "是否一键出售所有1星1级符文？",
			okCallback		= function ()				
				netpartner.C2GSRecyclePartnerEquipList(resultList)
			end,
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	else
		g_NotifyCtrl:FloatMsg("未找到可一键出售的符文")
	end
end

function CPartnerEquipPage.OnChangeEquipPlan(self)
	local bShow = false
	for _, oPartner in ipairs(g_PartnerCtrl:GetPartnerByRare(0)) do
		if oPartner.m_ID ~= self.m_CurParID then
			local t = oPartner:GetValue("equip_list")
			if t and #t > 0 then
				bShow = true
				break
			end
		end
	end
	if not bShow then
		g_NotifyCtrl:FloatMsg("无可一键替换的伙伴")
		return
	end
	CReplaceParEquipView:ShowView(function (oView)
		oView:SetPartner(self.m_CurParID)
	end)
end

function CPartnerEquipPage.OnFilter(self, parList)
	local newlist = {}
	for _, oPartner in ipairs(parList) do
		if oPartner.m_ID ~= self.m_CurParID then
			table.insert(newlist, oPartner)
		end
	end
	return newlist
end

function CPartnerEquipPage.OnShowCompareView(self, iParID)
	CPartnerPlanCompareView:ShowView(function (oView)
		oView:SetPartnerID(self.m_CurParID, iParID)
	end)
end


return CPartnerEquipPage