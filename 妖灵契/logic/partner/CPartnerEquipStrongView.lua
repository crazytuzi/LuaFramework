local CPartnerEquipStrongView = class("CPartnerEquipStrongView", CViewBase)

function CPartnerEquipStrongView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerEquipStrongView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
	self.m_MaxAmount = 6
end

function CPartnerEquipStrongView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_EquipList = self:NewUI(2, CPartnerEquipListPart)
	self.m_EquipList:SetClickCallback(callback(self, "OnClickItem"))
	self.m_EquipList:SetType(1)
	self.m_EquipPart = self:NewUI(3, CBox)
	self.m_LockWidget = self:NewUI(4, CWidget)
	self.m_TipBtn = self:NewUI(5, CButton)
	self:InitEquipPart()
	self.m_LockWidget:SetActive(false)
	self.m_TipBtn:AddHelpTipClick("PartnerEquipStrongView")
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	CPartnerPlanCompareView:CloseView()
end

function CPartnerEquipStrongView.InitEquipPart(self)
	local equippart = self.m_EquipPart
	self.m_EquipItem = equippart:NewUI(1, CBox)
	self.m_CurTexture = self.m_EquipItem:NewUI(2, CTexture)
	self.m_CurStarGrid = self.m_EquipItem:NewUI(3, CGrid)
	self.m_CurStarSpr = self.m_EquipItem:NewUI(4, CSprite)
	self.m_CurStarSpr:SetActive(false)

	self.m_GradeChangeSpr = equippart:NewUI(2, CSprite)
	self.m_EffectNode = equippart:NewUI(3, CObject)
	self.m_ItemBox = equippart:NewUI(4, CBox)
	self.m_GradeChangeLabel = equippart:NewUI(5, CLabel)
	self.m_ExpSlider = equippart:NewUI(6, CSlider)
	self.m_ExpLabel = equippart:NewUI(7, CLabel)
	self.m_ConfirmBtn = equippart:NewUI(8, CButton)
	self.m_CostLabel = equippart:NewUI(9, CLabel)
	self.m_ExpEffectObj = equippart:NewUI(10, CUIEffect)
	self.m_MainAttrGrid = equippart:NewUI(11, CGrid)
	self.m_EatExpLabel = equippart:NewUI(12, CLabel)
	self.m_AddAllBtn = equippart:NewUI(14, CButton)
	self.m_AddSlider = equippart:NewUI(15, CSlider)
	
	self.m_MainAttrTitle = equippart:NewUI(16, CLabel)
	self.m_SubAttrBox = equippart:NewUI(17, CBox)
	self.m_MainAttrBox = equippart:NewUI(18, CBox)
	self.m_ExpEffectNode = equippart:NewUI(19, CObject)
	self.m_SubAttrTitle = equippart:NewUI(20, CLabel)
	self.m_SubAttrGrid = equippart:NewUI(21, CGrid)
	
	self:InitItemBox()
	self.m_CurParID = nil
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddAllBtn:AddUIEvent("click", callback(self, "OnAddAll"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnStrength"))
	self.m_ExpEffectObj:SetActive(false)
	self.m_ExpEffectObj:Above(self.m_ExpEffectNode)
	g_GuideCtrl:AddGuideUI("partner_equip_strong_ok_btn", self.m_ConfirmBtn)
end

function CPartnerEquipStrongView.InitItemBox(self)
	self.m_ItemDict = {}
	for i = 1, self.m_MaxAmount do
		local itemobj = self.m_ItemBox:NewUI(i, CBox)
		itemobj:SetActive(true)
		itemobj.m_EquipItem = itemobj:NewUI(2, CPartnerEquipItem)
		itemobj.m_EquipItem:AddUIEvent("click", callback(self, "DropItem", i))
		itemobj.m_EquipItem:SetActive(false)
		self.m_ItemDict[i] = itemobj
	end
end

function CPartnerEquipStrongView.OnItemCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerEquip then
		if self.m_ItemID == oCtrl.m_EventData then
			if not self.m_IsDoEffect then
				self:DoEffect()
			end
		end
	end
end

function CPartnerEquipStrongView.SetPartnerID(self, parid)
	self.m_CurParID = parid
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	if oPartner then
		self.m_EquipDict = oPartner:GetCurEquipInfo()
	else
		self.m_EquipDict = {}
	end
end

function CPartnerEquipStrongView.ClearItem(self)
	for idx = 1, self.m_MaxAmount do
		self.m_ItemDict[idx].m_ID = nil
		self.m_ItemDict[idx].m_EquipItem:SetActive(false)
		self.m_ItemDict[idx].m_EquipItem:SetLocalPos(Vector3.New(0, 0, 0))
		self.m_ItemDict[idx].m_EquipItem:SetLocalScale(Vector3.New(1, 1, 1))
	end
end

function CPartnerEquipStrongView.DoEffect(self)
	self.m_LockWidget:SetActive(true)
	self.m_EffectNode:SetActive(false)
	self.m_IsDoEffect = true
	if not self.m_WinEffect then
		self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1154/Prefabs/ui_eff_1154_bao.prefab", self:GetLayer(), false)
		self.m_WinEffect:SetParent(self.m_EffectNode.m_Transform)
	end
	self:DoMoveEffect()
end

function CPartnerEquipStrongView.DoMoveEffect(self)
	local moveList = {}
	local targetPos = self.m_EffectNode:GetLocalPos()

	for i = 1, self.m_MaxAmount do
		local selectBox = self.m_ItemDict[i]
		if selectBox.m_ID then
			local effectobj = CEffect.New("Effect/UI/ui_eff_1154/Prefabs/ui_eff_1154_tuowei.prefab", self:GetLayer(), false)
			effectobj:SetParent(selectBox.m_EquipItem.m_Transform)
			selectBox.m_EquipItem.m_EffectObj = effectobj
			table.insert(moveList, {selectBox.m_EquipItem, targetPos - selectBox:GetLocalPos()})
		end
	end
	
	local iStart = 0
	local iEnd = 20
	local function update()
		if Utils.IsNil(self) then
			return
		end
		for _, objList in ipairs(moveList) do
			local obj, targetPos = objList[1], objList[2]
			local vPos = obj:GetLocalPos()
			local nPos = Vector3.Lerp(vPos, targetPos, 1/(iEnd - iStart))
			obj:SetLocalPos(nPos)
			local k = 0.2 + 0.8 * (iEnd - iStart)/iEnd
			obj:SetLocalScale(Vector3.New(k, k, k))
		end
		iStart = iStart + 1
		if iStart == 20 then
			self.m_LockWidget:SetActive(false)
			self.m_EffectNode:SetActive(true)
			self:ClearEffect()
			self:SetItemID(self.m_ItemID)
			self.m_IsDoEffect = false
			return
		end
		return true
	end
	if self.m_MoveEffectTimer then
		Utils.DelTimer(self.m_MoveEffectTimer)
	end
	self.m_MoveEffectTimer = Utils.AddTimer(update, 0.02, 0.02)
end

function CPartnerEquipStrongView.ClearEffect(self)
	for i = 1, self.m_MaxAmount do
		local selectBox = self.m_ItemDict[i]
		if selectBox.m_EquipItem.m_EffectObj then
			selectBox.m_EquipItem.m_EffectObj:Destroy()
			selectBox.m_EquipItem.m_Effect = nil
		end
	end
end

function CPartnerEquipStrongView.SetItemID(self, itemid)
	self.m_ItemID = itemid
	self:ClearItem()
	self.m_EquipList:ClearSel()
	self.m_EquipList:SetItemID(itemid)
	local oItem = g_ItemCtrl:GetItem(itemid)
	if not oItem then
		return
	end
	if self.m_IsDoEffect then
		if oItem:GetValue("level") <= self.m_CurLv then
			self.m_IsDoEffect = false
		else
			self:DoExpEffect()
		end
	end

	self:SetCurItem(itemid)
	self.m_GradeChangeLabel:SetText(string.format("LV:%d", oItem:GetValue("level")))
	self.m_GradeChangeSpr:SetActive(false)
	local info = self:GetEquipExp(oItem:GetValue("level"), oItem:GetValue("equip_star"))
	self.m_NeedExp = info["upgrade_exp"]
	self.m_TotalExp = oItem:GetValue("exp")
	self.m_CurExp = self:GetEquipCurExp(oItem)
	self.m_CurLv = oItem:GetValue("level")
	self.m_ExpSlider:SetValue(self.m_CurExp / self.m_NeedExp)
	self.m_AddSlider:SetValue(0)
	self.m_ExpLabel:SetText(string.format("%d/%d", self.m_CurExp , self.m_NeedExp))
	self.m_EatExpLabel:SetText("")

	self.m_FullExp = self:GetFullExp(oItem:GetValue("equip_star"))
	self.m_MaxEatExp = math.max(0, self.m_FullExp-self.m_CurExp)
	self.m_EatExp = 0
	self:UpdateAttr(0, 0)
	self:UpdateCost()
end

function CPartnerEquipStrongView.SetCurItem(self, itemid)
	local oItem = g_ItemCtrl:GetItem(itemid)
	if oItem then
		self.m_CurTexture:SetActive(false)
		self.m_CurTexture:LoadPartnerEquip(oItem:GetValue("icon"), function () self.m_CurTexture:SetActive(true) end)
		self.m_CurStarGrid:Clear()
		for i = 1, oItem:GetValue("equip_star") do
			local spr = self.m_CurStarSpr:Clone()
			spr:SetActive(true)
			self.m_CurStarGrid:AddChild(spr)
		end
		self.m_CurStarGrid:Reposition()
	end
	
	
end

function CPartnerEquipStrongView.OnLeftSwitch(self)
	local targetID = nil
	for i = 1, 6 do
		local itemid = self.m_EquipDict[i]
		if itemid and itemid == self.m_ItemID then
			if targetID then
				break
			end
		elseif itemid then
			targetID = itemid
		end
	end
	if targetID then
		self:SetItemID(targetID)
	end
end

function CPartnerEquipStrongView.OnRightSwitch(self)
	local targetID = nil
	for i = 6, 1, -1 do
		local itemid = self.m_EquipDict[i]
		if itemid and itemid == self.m_ItemID then
			if targetID then
				break
			end
		elseif itemid then
			targetID = itemid
		end
	end
	if targetID then
		self:SetItemID(targetID)
	end
end

function CPartnerEquipStrongView.OnAddAll(self)
	local oItem = g_ItemCtrl:GetItem(self.m_ItemID)
	if oItem:GetValue("level") == 15 then
		g_NotifyCtrl:FloatMsg("符文已强化至满级")
		return
	end
	
	local restamount = self.m_MaxAmount
	for i = 1, self.m_MaxAmount do
		if self.m_ItemDict[i].m_ID then
			restamount = restamount - 1
		end
	end
	if restamount == 0 then
		g_NotifyCtrl:FloatMsg("已添加到最大符文数量，无法继续添加符文")
		return
	end
	
	local list = self.m_EquipList:GetGridList()
	local inplanlist = {}
	local flag = 0
	for _, oItem in ipairs(list) do
		if self.m_TotalExp + self.m_EatExp >= self.m_FullExp then
			g_NotifyCtrl:FloatMsg("经验已达最大")
			break
		end
		if oItem:GetValue("equip_star") > 2 and oItem:GetValue("equip_type") ~= 60 then
			flag = flag + 1
		elseif oItem:IsExpPartnerEquip() then
			local iExpEquipAmount = oItem:GetValue("amount")
			local iEmptyAmount = 0
			for i = 1, self.m_MaxAmount do
				if not self.m_ItemDict[i].m_ID then
					iEmptyAmount = iEmptyAmount + 1
				elseif self.m_ItemDict[i].m_ID == oItem.m_ID then
					iExpEquipAmount = iExpEquipAmount - 1
				end
			end
			iEmptyAmount = math.min(iEmptyAmount, iExpEquipAmount)
			for i = 1, self.m_MaxAmount do
				if iEmptyAmount > 0 and not self.m_ItemDict[i].m_ID then
					self:PutItem(i, oItem)
					iEmptyAmount = iEmptyAmount - 1
					flag = - 9999
				end
			end
		else
			for i = 1, self.m_MaxAmount do
				if not self.m_ItemDict[i].m_ID then
					if oItem:GetValue("in_plan") == 1 then
						table.insert(inplanlist, i)
					end
					self:PutItem(i, oItem)
					flag = -9999
					break
				end
			end
		end
		if flag == -9999 then
			local iBreak = true
			for i = 1, self.m_MaxAmount do
				if not self.m_ItemDict[i].m_ID then
					iBreak = false
				end
			end
			if iBreak then
				break
			end
		end
	end
	if flag > 0 then
		g_NotifyCtrl:FloatMsg("一键添加仅可添加经验符文和1~2星的常规符文")
	end
	if #inplanlist > 0 then
		local function cancelCallback()
			for _, idx in ipairs(inplanlist) do
				self:DropItem(idx)
			end
		end
		local windowConfirmInfo = {
			msg				= "符文存在于伙伴的其他方案当中，是否将该符文吞食",
			okCallback 		= function() end,
			okStr           = "确认",
			cancelCallback  = cancelCallback,
		}
		
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end

function CPartnerEquipStrongView.RefreshExp(self)
	local oItem = g_ItemCtrl:GetItem(self.m_ItemID)
	self.m_EatExp = self:GetEatExp()
	self.m_ExpLabel:SetText(string.format("%d/%d（+%d）", self.m_CurExp , self.m_NeedExp, self.m_EatExp))
	local level = oItem:GetValue("level")
	local reachlevel = self:GetReachLevel()
	self.m_GradeChangeSpr:SetActive(false)
	if level == reachlevel then
		self.m_GradeChangeLabel:SetText(string.format("LV:%d", level))
	else
		self.m_GradeChangeSpr:SetActive(true)
		self.m_GradeChangeLabel:SetText(string.format("LV:%d         LV:%d", oItem:GetValue("level"), reachlevel))
	end
	self.m_AddSlider:SetValue((self.m_CurExp+self.m_EatExp) / self.m_NeedExp)
	self:UpdateAttr(oItem:GetValue("level"), reachlevel)
	self:UpdateCost()
end

function CPartnerEquipStrongView.GetEquipCurExp(self, oItem)
	local level = oItem:GetValue("level")
	local star = oItem:GetValue("equip_star")
	local sum = 0
	for i = 0, level-1 do
		local info = self:GetEquipExp(i, star)
		if info then
			sum = sum + info["upgrade_exp"]
		end
	end
	return oItem:GetValue("exp") - sum
end

function CPartnerEquipStrongView.GetEquipExp(self, level, star)
	local updatedata = data.partnerequipdata.UPGRADE
	for _, dict in pairs(updatedata) do
		if dict["star"] == star and dict["level"] == level then
			return dict
		end
	end
	return {}
end

function CPartnerEquipStrongView.GetEatExp(self)
	local sum = 0
	for i = 1, self.m_MaxAmount do
		if self.m_ItemDict[i].m_ID then
			local oItem = g_ItemCtrl:GetItem(self.m_ItemDict[i].m_ID)
			local info = self:GetEquipExp(oItem:GetValue("level"), oItem:GetValue("equip_star"))
			if oItem then
				if oItem:GetValue("equip_type") == 60 then
					sum = sum + info["eat_exp_fuwen"]
				else
					sum = sum + info["eat_exp"]
				end
			end
		end
	end
	return math.min(self.m_MaxEatExp, sum)
end

function CPartnerEquipStrongView.GetFullExp(self, star)
	local sum = 0
	for i = 0, 15 do
		local info = self:GetEquipExp(i, star)
		sum = sum + info["upgrade_exp"]
	end
	return sum
end

function CPartnerEquipStrongView.GetReachLevel(self)
	local eatexp = self.m_EatExp
	local curexp = self.m_CurExp
	local oItem = g_ItemCtrl:GetItem(self.m_ItemID)
	local level = oItem:GetValue("level")
	local star = oItem:GetValue("equip_star")
	eatexp = eatexp - (self.m_NeedExp - self.m_CurExp)
	if eatexp < 0 then
		return level
	else
		for i = level+1, 15 do
			local info = self:GetEquipExp(i, star)
			if eatexp - info["upgrade_exp"] < 0 then
				return i
			else
				eatexp = eatexp - info["upgrade_exp"]
			end
		end
		return 15
	end
end

function CPartnerEquipStrongView.UpdateAttr(self, level, reachlevel)
	local oItem = g_ItemCtrl:GetItem(self.m_ItemID)
	local mainattr = oItem:GetValue("main_apply")
	local curattrstr = self:GetAttrStr(mainattr)
	self.m_LastCurAttr = self.m_LastCurAttr or {}

	self.m_MainAttrTitle:SetActive(true)
	self.m_MainAttrBox:SetActive(false)
	self.m_SubAttrBox:SetActive(false)
	if level == reachlevel then
		if self.m_EatExp == 0 then
			self:SetMainAttrGrid(curattrstr, nil, self.m_LastCurAttr)
		else
			self:SetMainAttrGrid(curattrstr, curattrstr, self.m_LastCurAttr)
		end
	else
		local upgradeadd = oItem:GetValue("upgrade_add")
		local func = loadstring("return "..upgradeadd) 
		local upgradedict = func()
		for k, v in pairs(upgradedict) do
			upgradedict[k] = v * (reachlevel - level)
		end
		
		local upgradeadd2 = oItem:GetValue("upgrade_add2")
		local func2 = loadstring("return "..upgradeadd2) 
		local upgradedict2 = func2()
		for k, v in pairs(upgradedict2) do
			upgradedict2[k] = v * (reachlevel - level)
		end

		local newattr = {}
		for i, attrobj in ipairs(mainattr) do
			local key = attrobj["key"]
			local dict = {}
			dict["key"] = key
			local tempupgradedict = upgradedict2
			if i == 1 then
				tempupgradedict = upgradedict
			end
			if tempupgradedict[key] then
				dict["value"] = attrobj["value"] + tempupgradedict[key]
			else
				dict["value"] = attrobj["value"]
			end
			table.insert(newattr, dict)
		end
		local upattrstr = self:GetAttrStr(newattr)
		self:SetMainAttrGrid(curattrstr, upattrstr)
	end

	local subattr = oItem:GetValue("sub_apply")
	self.m_SubAttrTitle:SetActive(true)
	self.m_SubAttrGrid:SetActive(true)
	self.m_SubAttrGrid:Clear()
	self.m_LastSubAttr = self.m_LastSubAttr or {}
	local subattrstr = self:GetAttrStr(subattr)

	for i, data in ipairs(subattrstr) do
		local box = self.m_SubAttrBox:Clone()
		self:InitSubAttrBox(box)
		box:SetActive(true)
		self:SetAttrBox(box, data, self:GetLastAttrStr(data[1], self.m_LastSubAttr))
		self.m_SubAttrGrid:AddChild(box)
	end
	self.m_SubAttrGrid:Reposition()
	self.m_LastCurAttr = curattrstr
	self.m_LastSubAttr = subattrstr
end

function CPartnerEquipStrongView.GetLastAttrStr(self, name, lLastList)
	for _, dLast in ipairs(lLastList) do
		if dLast[1] == name then
			return dLast
		end
	end
end

function CPartnerEquipStrongView.SetMainAttrGrid(self, lAttr, lUpAttr, lLastAttr)
	lUpAttr = lUpAttr or {}
	lLastAttr = lLastAttr or {}
	self.m_MainAttrGrid:Clear()
	for i, dAttr in ipairs(lAttr) do
		local box = self.m_MainAttrBox:Clone()
		box:SetActive(true)
		self:InitMainAttrBox(box)
		self:SetAttrBox(box, dAttr, lLastAttr[i])
		if lUpAttr[i] then
			box.m_UpLabel:SetText(lUpAttr[i][2])
			box.m_UpSpr:SetActive(true)
			box.m_UpLabel:SetActive(true)
		else
			box.m_UpSpr:SetActive(false)
			box.m_UpLabel:SetActive(false)
		end
		self.m_MainAttrGrid:AddChild(box)
	end
	self.m_MainAttrGrid:Reposition()
end

function CPartnerEquipStrongView.GetAttrStr(self, attrlist)
	local strlist = {}
	local attrdata = data.partnerequipdata.EQUIPATTR
	for _, attrobj in ipairs(attrlist) do
		local name = attrdata[attrobj["key"]]["name"]
		local str = nil
		if string.endswith(attrobj["key"], "ratio") or attrobj["key"] == "critical_damage" then
			local value = math.floor(attrobj["value"]/10)/10
			if math.isinteger(value) then
				str = string.format("+%d%%", value)
			else
				str = string.format("+%.1f%%", value)
			end
		else
			str = string.format("+%d", attrobj["value"])
		end
		table.insert(strlist, {name, str})
	end
	return strlist
end

function CPartnerEquipStrongView.SetAttrBox(self, box, data, dLastData)
	box.m_AttrName:SetText(data[1])
	 --self.m_IsDoEffect = true
	if self.m_IsDoEffect then
		if dLastData then
			if data[2] == dLastData[2] then
				box.m_AttrValue:SetText(data[2])
			else
				self:DoTextEffect(box.m_AttrValue, data[2], dLastData[2])
			end
		else
			self:DoTextEffect(box.m_AttrValue, data[2], nil)
		end
	else
		box.m_AttrValue:SetText(data[2])
	end
end

function CPartnerEquipStrongView.DoExpEffect(self)
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

function CPartnerEquipStrongView.DoTextEffect(self, oLabel, sCur, sLast)
	local ispecent = string.find(sCur, "%%")
	sLast = sLast or ""
	sCur = sCur or ""
	local iLast = tonumber(sLast) or 0
	local iCur = tonumber(sCur) or 0
	if ispecent then
		iLast = tonumber(string.sub(sLast, 1, string.len(sLast)-1)) or 0
		iCur = tonumber(string.sub(sCur, 1, string.len(sCur)-1)) or 0
	end
	local color = "#R"
	if iCur > iLast then
		color = "#G"
	elseif iCur == iLast then
		color = nil 
	end
	local detal = (iCur - iLast) / 20
	if oLabel.m_EffectTimer then
		Utils.DelTimer(oLabel.m_EffectTimer)
	end
	local starnum = iLast
	local idx = 0
	local function update()
		if Utils.IsNil(self) or Utils.IsNil(oLabel) then
			return
		end
		idx = idx + 1
		if idx >= 20 then
			oLabel:SetText(sCur)
		else
			local curnum = starnum + detal * idx
			self:SetLabelText(oLabel, curnum, ispecent, color)
			return true
		end
	end
	oLabel.m_EffectTimer = Utils.AddTimer(update, 0.05, 0.05)
end

function CPartnerEquipStrongView.SetLabelText(self, oLabel, num, ispecent, color)
	color = color or "[654A33]"
	if ispecent then
		if math.isinteger(num) then
			oLabel:SetText(string.format("%s+%d%%", color, num))
		else
			oLabel:SetText( string.format("%s+%.1f%%", color, num) )
		end
	else
		if num > 0 and num < 1 then
			oLabel:SetText(string.format("%s+1", color))
		else
			oLabel:SetText(string.format("%s+%d", color, num))
		end
	end
end

function CPartnerEquipStrongView.InitMainAttrBox(self, box)
	box.m_UpSpr = box:NewUI(1, CSprite)
	box.m_UpLabel = box:NewUI(2, CLabel)
	box.m_AttrName = box:NewUI(3, CLabel)
	box.m_AttrValue = box:NewUI(4, CLabel)
end

function CPartnerEquipStrongView.InitSubAttrBox(self, box)
	box.m_AttrName = box:NewUI(1, CLabel)
	box.m_AttrValue = box:NewUI(2, CLabel)
end

function CPartnerEquipStrongView.UpdateIcon(self)

end

function CPartnerEquipStrongView.UpdateCost(self)
	local cost = 0
	for i = 1, self.m_MaxAmount do
		if self.m_ItemDict[i].m_ID then
			local oItem = g_ItemCtrl:GetItem(self.m_ItemDict[i].m_ID)
			local info = self:GetEquipExp(oItem:GetValue("level"), oItem:GetValue("equip_star"))
			cost = cost + info["upgrade_cost"]
		end
	end
	self.m_CostValue = cost
	if g_AttrCtrl.coin < cost then
		self.m_CostLabel:SetText(string.format("#R需要#w1%s", string.numberConvert(cost)))
	else
		self.m_CostLabel:SetText(string.format("[8A6029]需要#w1%s[-]", string.numberConvert(cost)))
	end
end

function CPartnerEquipStrongView.PutItem(self, idx, oItem)
	if self.m_TotalExp + self.m_EatExp >= self.m_FullExp then
		g_NotifyCtrl:FloatMsg("经验已达最大")
		return
	end
	local curItem = g_ItemCtrl:GetItem(self.m_ItemID)
	if curItem:GetValue("level") == 15 then
		g_NotifyCtrl:FloatMsg("符文已强化至满级")
		return
	end
	
	self.m_ItemDict[idx].m_ID = oItem.m_ID
	--self.m_ItemDict[idx].m_EmptySpr:SetActive(false)
	self.m_ItemDict[idx].m_EquipItem:SetActive(true)
	self.m_ItemDict[idx].m_EquipItem:SetItem(oItem.m_ID)
	self:RefreshExp()
	self.m_EquipList:SetSelectedEquip(oItem.m_ID, true)
end

function CPartnerEquipStrongView.DropItem(self, idx)
	local bSelFlag = false
	for i = 1, self.m_MaxAmount do
		if i ~= idx and self.m_ItemDict[i].m_ID == self.m_ItemDict[idx].m_ID then
			bSelFlag = true
		end
	end
	self.m_EquipList:SetSelectedEquip(self.m_ItemDict[idx].m_ID, bSelFlag)
	self.m_ItemDict[idx].m_ID = nil
	self.m_ItemDict[idx].m_EquipItem:SetActive(false)
	self:RefreshExp()
end

function CPartnerEquipStrongView.OnClickItem(self, oItem)
	local iExpEquipAmount = 0
	for i = 1, self.m_MaxAmount do
		if self.m_ItemDict[i].m_ID == oItem.m_ID then
			if oItem:IsExpPartnerEquip() then
				iExpEquipAmount = iExpEquipAmount + 1
			else
				self:DropItem(i)
				return
			end
		end
	end
	if iExpEquipAmount >= oItem:GetValue("amount") then
		return
	end
	for i = 1, self.m_MaxAmount do
		if not self.m_ItemDict[i].m_ID then
			if oItem:GetValue("in_plan") == 1 then
				local windowConfirmInfo = {
					msg				= "该符文存在于伙伴的其他方案当中，是否将该符文吞食",
					okCallback 		= callback(self, "PutItem", i, oItem),
					okStr           = "确认",
					cancelCallback  = function() end,
				}
				g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			else
				self:PutItem(i, oItem)
			end
			return
		end
	end
	g_NotifyCtrl:FloatMsg("已添加到最大符文数量，无法继续添加符文")
end

function CPartnerEquipStrongView.OnStrength(self)
	local costlist = {}
	for i = 1, self.m_MaxAmount do
		if self.m_ItemDict[i].m_ID then
			table.insert(costlist, self.m_ItemDict[i].m_ID)
		end
	end
	if self.m_CostValue and g_AttrCtrl.coin < self.m_CostValue then
		g_WindowTipCtrl:ShowNoGoldTips(1)
		return
	end
	
	if not self:ShowConfirmTip(self.m_ItemID, costlist) then
		self:ConfirmStrength(self.m_ItemID, costlist)
	end
	
end

function CPartnerEquipStrongView.ConfirmStrength(self, iItemID, costList)
	if #costList > 0 then
		netpartner.C2GSStrengthPartnerEquip(iItemID, costList)
	else
		g_NotifyCtrl:FloatMsg("无法强化")
	end
end

function CPartnerEquipStrongView.ShowConfirmTip(self, iItemID, costList)
	local linkList = {}
	for _, id in ipairs(costList) do
		local oItem = g_ItemCtrl:GetItem(id)
		if oItem and oItem:GetValue("equip_star") > 4 and oItem:GetValue("equip_type") ~= 60 then
			local sText = oItem:GetValue("name")
			table.insert(linkList, LinkTools.GeneratePartnerEquipLink(id, g_AttrCtrl.pid, sText))
		end
	end
	
	if #linkList > 0 then
		local str = string.format("吞食目标中%s较为稀有，作为素材使用后将会消失，是否继续吞食？", table.concat(linkList, "、"))
		local windowConfirmInfo = {
			msg				= str,
			okCallback 		= callback(self, "ConfirmStrength", iItemID, costList),
			okStr			= "确认",
			cancelCallback  = function() end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		return true
	else
		return false
	end
end

return CPartnerEquipStrongView