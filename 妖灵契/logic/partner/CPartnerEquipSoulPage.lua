local CPartnerEquipSoulPage = class("CPartnerEquipSoulPage", CPageBase)

function CPartnerEquipSoulPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end
CPartnerEquipSoulPage.SOUL_PLAN_OPEN = true
function CPartnerEquipSoulPage.OnInitPage(self)
	self.m_LeftPart = self:NewUI(3, CBox)
	self.m_SelectPart = self:NewUI(4, CParSoulSelectBox)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	self:InitLeft()
end

function CPartnerEquipSoulPage.InitLeft(self)
	local oPart = self.m_LeftPart
	self.m_TipBtn = oPart:NewUI(1, CButton)
	self.m_CurSoulBox = oPart:NewUI(2, CBox)
	self.m_CoreLabel = oPart:NewUI(3, CLabel)
	self.m_CoreClickBox = oPart:NewUI(4, CBox)
	self.m_CoreTexture = oPart:NewUI(5, CTexture)
	self.m_AddCoreBtn = oPart:NewUI(6, CButton)
	self.m_AddTipLabel = oPart:NewUI(7, CLabel)
	self.m_SoulPlanBtn = oPart:NewUI(8, CButton)
	self.m_SoulItemList = {}
	for i = 1, 6 do
		local oBox = self.m_CurSoulBox:NewUI(i, CBox)
		oBox.m_SoulItem = oBox:NewUI(1, CParSoulItem)
		oBox.m_AddSpr = oBox:NewUI(2, CSprite)
		oBox.LockLabel = oBox:NewUI(3, CLabel)
		oBox.m_AttrLabel = oBox:NewUI(4, CLabel)
		oBox.m_SoulItem:AddUIEvent("click", callback(self, "OnClickSoul", oBox))
		self.m_SoulItemList[i] = oBox
	end
	self.m_TipBtn:AddHelpTipClick("partner_soul")
	self.m_AddCoreBtn:AddUIEvent("click", callback(self, "OnShowSelectCore"))
	self.m_CoreClickBox:AddUIEvent("click", callback(self, "OnShowSelectCore"))
	self.m_SoulPlanBtn:AddUIEvent("click", callback(self, "OnShowChoosePlan"))
	self.m_SoulPlanBtn:SetActive(CPartnerEquipSoulPage.SOUL_PLAN_OPEN)
end

function CPartnerEquipSoulPage.OnItemCtrlEvent(self, oCtrl)

end

function CPartnerEquipSoulPage.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self.m_UpdateFlag = true
			self:UpdatePartner()
			self.m_UpdateFlag = false
		end
	end
end

function CPartnerEquipSoulPage.SetPartnerID(self, iParID)
	self.m_CurParID = iParID
	self.m_SelectPart:SetPartnerID(iParID)
	self:UpdatePartner()
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	if oPartner then
		oPartner.m_ParSoulRedFlag = true
		g_PartnerCtrl:DelayEvent(define.Partner.Event.UpdateRedPoint, iParID)
	end
end

function CPartnerEquipSoulPage.UpdatePartner(self)
	self:UpdateSoul()
	self:UpdateSoulType()
end

function CPartnerEquipSoulPage.UpdateSoul(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local dSoulList = oPartner:GetParSoulList()
	local dLockData = data.partnerequipdata.ParSoulUnlock
	local iGrade = g_AttrCtrl.grade
	self:DoFlashEffect()
	for i = 1, 6 do
		local iItemID = dSoulList[i]
		local oBox = self.m_SoulItemList[i]
		oBox.m_SoulItem.m_ID = nil
		oBox:AddUIEvent("click", function () end)
		if iGrade < dLockData[i]["unlock_grade"] then
			oBox.LockLabel:SetActive(true)
			oBox.LockLabel:SetText(tostring(dLockData[i]["unlock_grade"]))
			oBox.m_SoulItem:SetActive(false)
			oBox.m_AddSpr:SetActive(false)
			oBox.m_AttrLabel:SetText("")
		else
			oBox.LockLabel:SetActive(false)
			if iItemID then
				oBox.m_SoulItem:SetActive(true)
				oBox.m_AddSpr:SetActive(false)
				oBox.m_SoulItem:SetItem(iItemID)
				oBox.m_SoulItem.m_ID = iItemID
				oBox.m_AttrLabel:SetText(self:GetSoulAttr(iItemID))
			else
				oBox.m_SoulItem:SetActive(false)
				oBox.m_AddSpr:SetActive(false)
				oBox.m_AttrLabel:SetText("")
				oBox:AddUIEvent("click", callback(self, "OnShowSoulList", true))
			end
		end
	end
end

function CPartnerEquipSoulPage.GetSoulAttr(self, iItemID)
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

function CPartnerEquipSoulPage.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CPartnerEquipSoulPage.UpdateSoulType(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local iSoulType = oPartner:GetValue("soul_type")
	local dTypeData = data.partnerequipdata.ParSoulType[iSoulType]
	if dTypeData then
		self.m_CoreTexture:SetActive(false)
		self.m_AddTipLabel:SetText("点击切换\n核心效果")
		self.m_AddCoreBtn:SetActive(false)
		self.m_CoreTexture:LoadPartnerEquip(dTypeData["icon"], 
			objcall(self, function (obj) obj.m_CoreTexture:SetActive(true) end))
		self.m_CoreLabel:SetText("        "..dTypeData["skill_desc"])
	else
		self.m_CoreTexture:SetActive(false)
		self.m_CoreLabel:SetText("无")
		self.m_AddTipLabel:SetText("点击添加\n御灵核心")
		self.m_AddCoreBtn:SetActive(true)
	end
	if self.m_UpdateFlag and dTypeData and iSoulType ~= self.m_LastSoulType then
		self.m_SelectPart:OnClickType(iSoulType)
	end
	self.m_LastSoulType = iSoulType
end

function CPartnerEquipSoulPage.DoFlashEffect(self, iPos)
	if self.m_FlashTimer then
		Utils.DelTimer(self.m_FlashTimer)
	end
	if not iPos then
		return
	end
	local idx = 0
	local function flash(obj)
		local btn = obj.m_SoulItemList[iPos].m_AddSpr
		btn:SetActive(not  btn:GetActive())
		idx = idx + 1
		if idx == 4 then
			btn:SetActive(false)
			return false
		end
		return true
	end
	self.m_FlashTimer = Utils.AddTimer(objcall(self, flash), 0.5, 0)
end

function CPartnerEquipSoulPage.OnShowSelectCore(self)
	CParSoulChangeTypeView:ShowView(function (oView)
		oView:SelectCoreType(self.m_CurParID)
	end)
end

function CPartnerEquipSoulPage.OnClickSoul(self, oItemObj, oBox)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	local oItem = g_ItemCtrl:GetItem(oBox.m_ID)
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {partner = oPartner})
	end
	for i = 1, 6 do
		self.m_SoulItemList[i].m_AddSpr:SetActive(false)
	end
	oItemObj.m_AddSpr:SetActive(true)
end

function CPartnerEquipSoulPage.OnShowSoulList(self, b, oBox)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local iSoulType = oPartner:GetValue("soul_type")
	self.m_SelectPart:OnClickType(iSoulType)
	for i = 1, 6 do
		self.m_SoulItemList[i].m_AddSpr:SetActive(false)
	end
	oBox.m_AddSpr:SetActive(true)
end

function CPartnerEquipSoulPage.OnShowChoosePlan(self)
	CParSoulChoosePlanView:ShowView(function (oView)
		oView:SetParID(self.m_CurParID)
	end)
end

return CPartnerEquipSoulPage