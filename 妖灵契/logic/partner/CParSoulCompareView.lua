local CParSoulCompareView = class("CParSoulCompareView", CViewBase)

function CParSoulCompareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParSoulCompareView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CParSoulCompareView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_AttrGrid = self:NewUI(2, CGrid)
	self.m_AttrBox = self:NewUI(3, CBox)
	self.m_LeftPart = self:NewUI(4, CBox)
	self.m_RightPart = self:NewUI(5, CBox)
	self.m_ConfirmBtn = self:NewUI(6, CButton)
	self.m_ModifyBtn = self:NewUI(7, CButton)
	self.m_DelBtn = self:NewUI(8, CButton)
	self:InitContent()
end

function CParSoulCompareView.InitContent(self)
	self.m_AttrBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ModifyBtn:AddUIEvent("click", callback(self, "OnModifyPlan"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDelPlan"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self:InitPart()
end

function CParSoulCompareView.InitPart(self)
	local dList = {self.m_LeftPart, self.m_RightPart}
	for _, oPart in ipairs(dList) do
		oPart.m_SoulItemList = {}
		for i = 1, 6 do
			local oBox = oPart:NewUI(i, CBox)
			oBox.m_SoulItem = oBox:NewUI(1, CParSoulItem)
			oBox.LockLabel = oBox:NewUI(3, CLabel)
			oBox.m_AttrLabel = oBox:NewUI(4, CLabel)
			oBox.m_SoulItem:AddUIEvent("click", callback(self, "OnClickSoul"))
			oPart.m_SoulItemList[i] = oBox
		end
		oPart.m_CoreLabel = oPart:NewUI(7, CLabel)
		oPart.m_PlanLabel = oPart:NewUI(8, CLabel)
		oPart.m_CoreTexture = oPart:NewUI(9, CTexture)
		oPart.m_DescLabel = oPart:NewUI(10, CLabel)
	end
end

function CParSoulCompareView.RefreshPlan(self, iParID, iPlanID)
	self.m_CurParID = iParID
	self.m_RPlanID = iPlanID
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	self.m_LPlan = {
		name = "当前方案",
		soul_type = oPartner:GetValue("soul_type"),
		souls = oPartner:GetValue("souls"),
	}

	self.m_RPlan = g_PartnerCtrl:GetSoulPlan(iPlanID)
	self:UpdatePart(self.m_LeftPart, self.m_LPlan)
	self:UpdatePart(self.m_RightPart, self.m_RPlan)
	self:UpdateAttrUI()
end

function CParSoulCompareView.UpdatePart(self, oPart, dData)
	local d = data.partnerequipdata.ParSoulType[dData.soul_type]
	oPart.m_CoreLabel:SetText(d.name)
	oPart.m_CoreTexture:LoadPartnerEquip(d["icon"], 
		objcall(oPart, function (obj) obj.m_CoreTexture:SetActive(true) end))
	oPart.m_PlanLabel:SetText(dData.name)
	oPart.m_DescLabel:SetText("核心效果\n       "..d["skill_desc"])
	local dSoulList = {}
	for _, v in ipairs(dData.souls) do
		dSoulList[v.pos] = v.itemid
	end
	local dLockData = data.partnerequipdata.ParSoulUnlock
	local iGrade = g_AttrCtrl.grade
	for i = 1, 6 do
		local iItemID = dSoulList[i]
		local oBox = oPart.m_SoulItemList[i]
		oBox.m_SoulItem.m_ID = nil
		oBox:AddUIEvent("click", function () end)
		if iGrade < dLockData[i]["unlock_grade"] then
			oBox.LockLabel:SetActive(true)
			oBox.LockLabel:SetText(tostring(dLockData[i]["unlock_grade"]))
			oBox.m_SoulItem:SetActive(false)
			oBox.m_AttrLabel:SetText("")
		else
			oBox.LockLabel:SetActive(false)
			if iItemID then
				oBox.m_SoulItem:SetActive(true)
				oBox.m_SoulItem:SetItem(iItemID)
				oBox.m_SoulItem.m_ID = iItemID
				oBox.m_AttrLabel:SetText(self:GetSoulAttr(iItemID))
			else
				oBox.m_SoulItem:SetActive(false)
				oBox.m_AttrLabel:SetText("")
			end
		end
	end
end

function CParSoulCompareView.GetSoulAttr(self, iItemID)
	local oItem = g_ItemCtrl:GetItem(iItemID)
	local dAttrData = oItem:GetParSoulAttr()
	local dAttr2Name = data.partnerequipdata.EQUIPATTR
	local attrlist = {}
	for key, value in pairs(dAttrData) do
		local attrname = dAttr2Name[key]["name"]
		local attrvalue = ""
		if string.endswith(key, "_ratio") or key == "critical_damage" then
			attrvalue = self:GetPrintPecent(value)
		else
			attrvalue = tostring(value)
		end
		table.insert(attrlist, attrname.."+"..attrvalue)
	end
	return table.concat(attrlist, "、")
end

function CParSoulCompareView.UpdateAttrUI(self)
	local curattr = self:GetAttrDict(self.m_LPlan)
	local planattr = self:GetAttrDict(self.m_RPlan)

	self.m_AttrGrid:Clear()
	local t = {"maxhp", "attack", "defense", "speed", "critical_ratio", "res_critical_ratio",
		"critical_damage", "cure_critical_ratio", "abnormal_attr_ratio", "res_abnormal_ratio"}

	for _, key in pairs(t) do
		local attrobj = curattr[key]
		local planobj = planattr[key]
		local oBox = self.m_AttrBox:Clone()
		oBox:SetActive(true)
		oBox.m_AttrName = oBox:NewUI(1, CLabel)
		oBox.m_LAttrValue = oBox:NewUI(2, CLabel)
		oBox.m_ChangeSpr = oBox:NewUI(3, CSprite)
		oBox.m_RAttrValue = oBox:NewUI(4, CLabel)
		oBox.m_ChangeLabel = oBox:NewUI(5, CLabel)
		
		oBox.m_AttrName:SetText(attrobj["name"])
		
		local lstr, rstr, delta, deltastr = self:GetPrintStr(key, attrobj["value"], planobj["value"])
		oBox.m_LAttrValue:SetText(lstr)
		oBox.m_RAttrValue:SetText(rstr)
		
		if delta > 0 then
			oBox.m_ChangeSpr:SetSpriteName("pic_tisheng")
			oBox.m_ChangeLabel:SetText(string.format("[229A6EFF](+%s)", deltastr))
		elseif delta < 0 then
			oBox.m_ChangeSpr:SetSpriteName("pic_xiajiang")
			oBox.m_ChangeLabel:SetText(string.format("#R(-%s)", deltastr))
		else
			oBox.m_ChangeSpr:SetFlip("pic_tisheng")
			oBox.m_ChangeLabel:SetActive(false)
		end
		self.m_AttrGrid:AddChild(oBox)
	end
	self.m_AttrGrid:Reposition()
end


function CParSoulCompareView.GetAttrDict(self, info)
	local itemlist = {}
	for k, obj in pairs(info.souls) do
		table.insert(itemlist, obj.itemid)
	end
	local attrdict = g_ItemCtrl:GetSoulListAttr(itemlist)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local oriattr = oPartner:GetOriAttr()
	if oriattr then
		local ratiolist = {"defense", "attack", "maxhp"}
		for _, attrkey in pairs(ratiolist) do
			if attrdict[attrkey.."_ratio"]["value"] > 0 then
				attrdict[attrkey]["value"] = attrdict[attrkey]["value"] + oriattr[attrkey]*attrdict[attrkey.."_ratio"]["value"]/10000
			end
		end
	end
	return attrdict
end

function CParSoulCompareView.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CParSoulCompareView.GetPrintStr(self, key, lvalue, rvalue)
	local lstr = ""
	local rstr = ""
	local delta = 0
	local deltastr = ""
	if string.endswith(key, "_ratio") or key == "critical_damage" then
		lvalue = math.floor(lvalue/10)/10
		rvalue = math.floor(rvalue/10)/10
		printc(lvalue, rvalue)
		if math.isinteger(lvalue) then
			lstr = string.format("%d%%", lvalue)
		else
			lstr = string.format("%.1f%%", lvalue)
		end
		
		if math.isinteger(rvalue) then
			rstr = string.format("%d%%", rvalue)
		else
			rstr = string.format("%.1f%%", rvalue)
		end
		
		delta = rvalue - lvalue
		if math.isinteger(delta) then
			deltastr = string.format("%d%%", math.abs(delta))
		else
			deltastr = string.format("%.1f%%", math.abs(delta))
		end
	
	else
		if lvalue > 0 and lvalue < 1 then
			lvalue = 1
		else
			lvalue = math.floor(lvalue)
		end
		
		if rvalue > 0 and rvalue < 1 then
			rvalue = 1
		else
			rvalue = math.floor(rvalue)
		end
		lstr = string.format("%d", lvalue)
		rstr = string.format("%d", rvalue)
		
		delta = rvalue - lvalue
		deltastr = string.format("%d", math.abs(delta))
	end
	return lstr, rstr, delta, deltastr
end

function CParSoulCompareView.OnShowSoulList(self, oBox)
	
end

function CParSoulCompareView.OnClickSoul(self, oBox)
	local oItem = g_ItemCtrl:GetItem(oBox.m_ID)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {})
	end
end

function CParSoulCompareView.OnModifyPlan(self)
	CParSoulSetPlanView:ShowView(function(oView)
		oView:OnEditPlan(self.m_RPlanID)
	end)
	self:OnClose()
end

function CParSoulCompareView.OnDelPlan(self)
	local windowConfirmInfo = {
		msg				= "你确定要删除此方案吗？",
		okCallback		= function ()
			netpartner.C2GSDelParSoulPlan(self.m_RPlanID)
			self:OnClose()
		end,
		okStr = "是",
		cancelStr = "否",			
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CParSoulCompareView.OnConfirm(self)
	netpartner.C2GSParSoulPlanUse(self.m_RPlanID, self.m_CurParID)
	self:OnClose()
end

return CParSoulCompareView