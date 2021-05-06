local CParSoulSetPlanView = class("CParSoulSetPlanView", CViewBase)

--御灵方案修改界面
function CParSoulSetPlanView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParSoulSetPlanView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CParSoulSetPlanView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LeftPart = self:NewUI(2, CBox)
	self.m_SelectPart = self:NewUI(3, CParSoulPlanSelectBox)
	self:InitContent()
end

function CParSoulSetPlanView.InitContent(self)
	self.m_SelectPart:SetGetFunc(callback(self, "GetSelfView"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitLeft()
end

function CParSoulSetPlanView.InitLeft(self)
	local oPart = self.m_LeftPart
	self.m_TipBtn = oPart:NewUI(1, CButton)
	self.m_CurSoulBox = oPart:NewUI(2, CBox)
	self.m_CoreLabel = oPart:NewUI(3, CLabel)
	self.m_CoreClickBox = oPart:NewUI(4, CBox)
	self.m_CoreTexture = oPart:NewUI(5, CTexture)
	self.m_AddCoreBtn = oPart:NewUI(6, CButton)
	self.m_AddTipLabel = oPart:NewUI(7, CLabel)
	self.m_ConfirmBtn = oPart:NewUI(8, CButton)
	self.m_PlanNameLabel = oPart:NewUI(9, CLabel)
	self.m_EditBtn = oPart:NewUI(10, CButton)
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
	--self.m_TipBtn:AddHelpTipClick("partner_soul")
	self.m_AddCoreBtn:AddUIEvent("click", callback(self, "OnShowSelectCore"))
	self.m_CoreClickBox:AddUIEvent("click", callback(self, "OnShowSelectCore"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnAddSoulPlan"))
	self.m_EditBtn:AddUIEvent("click", callback(self, "OnRename"))
	self.m_WearDict = {}
	self.m_CoreType = nil
	self:UpdateSoul()
end

function CParSoulSetPlanView.OnEditPlan(self, iPlanID)
	self.m_PlanID = iPlanID
	local dPlan = g_PartnerCtrl:GetSoulPlan(iPlanID)
	self.m_WearDict = {}
	for _, obj in ipairs(dPlan.souls) do
		self.m_WearDict[obj.pos] = obj.itemid
	end
	self.m_CoreType = dPlan.soul_type
	self.m_NameText = dPlan.name
	self.m_PlanNameLabel:SetText(dPlan.name)
	self:UpdateSoulType()
	self:UpdateSoul()
end

function CParSoulSetPlanView.OnAddPartnerPlan(self, iParID)
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	if oPartner then
		self.m_WearDict = {}
		local dSoulList = oPartner:GetValue("souls") or {}
		for _, obj in ipairs(dSoulList) do
			self.m_WearDict[obj.pos] = obj.itemid
		end
		self.m_CoreType = oPartner:GetValue("soul_type")
		self:UpdateSoulType()
		self:UpdateSoul()
	end
end

function CParSoulSetPlanView.UpdateSoul(self)
	local dSoulList = {} --oPartner:GetParSoulList()
	local dLockData = data.partnerequipdata.ParSoulUnlock
	local iGrade = g_AttrCtrl.grade
	self.m_UnLockAmount = 6
	for i = 1, 6 do
		local iItemID = self.m_WearDict[i]
		local oBox = self.m_SoulItemList[i]
		oBox.m_SoulItem.m_ID = nil
		oBox:AddUIEvent("click", function () end)
		if iGrade < dLockData[i]["unlock_grade"] then
			self.m_UnLockAmount = self.m_UnLockAmount - 1
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

function CParSoulSetPlanView.GetSelfView(self)
	return self
end

function CParSoulSetPlanView.GetCurSoulList(self)
	return self.m_WearDict or {}
end

function CParSoulSetPlanView.ReplaceSoul(self, oItem)
	if not self.m_CoreType then
		g_NotifyCtrl:FloatMsg("请先添加御灵核心")
		return
	end
	if oItem:GetValue("soul_type") ~= self.m_CoreType then
		g_NotifyCtrl:FloatMsg("请穿戴当前核心的御灵")
		return
	end

	
	local iPos = nil
	local iAttrType = oItem:GetValue("attr_type")
	for i = 1, self.m_UnLockAmount do
		local iItemID = self.m_WearDict[i]
		if iItemID then
			printc(iItemID, oItem.m_ID)
			if iItemID == oItem.m_ID then
				self.m_WearDict[i] = nil
				self:UpdateSoul()
				return
			end
			local oWearItem = g_ItemCtrl:GetItem(iItemID)
			if oWearItem and oWearItem:GetValue("attr_type") == iAttrType then
				g_NotifyCtrl:FloatMsg("同属性类型的御灵仅可穿一件")
				return
			end
		end
	end
	
	for i = 1, self.m_UnLockAmount do
		if not self.m_WearDict[i] then
			iPos = i
			break
		end
	end
	if iPos then
		self.m_WearDict[iPos] = oItem.m_ID
		self:UpdateSoul()
	else
		CPartnerSoulSelectView:ShowView(function (oView)
			oView:SetSoulPlan(oItem.m_ID, self.m_WearDict)
			oView:SetCallBack(callback(self, "UpdateSoulPos"))
		end)
		g_NotifyCtrl:FloatMsg("当前核心御灵已满")
	end
end

function CParSoulSetPlanView.UpdateSoulPos(self, iItemID, iPos)
	self.m_WearDict[iPos] = iItemID
	self:UpdateSoul()
end

function CParSoulSetPlanView.GetSoulAttr(self, iItemID)
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

function CParSoulSetPlanView.GetPrintPecent(self, value)
	local value = math.floor(value/10)/10
	local str = ""
	if math.isinteger(value) then
		str = string.format("%d%%", value)
	else
		str = string.format("%.1f%%", value)
	end	
	return str
end

function CParSoulSetPlanView.UpdateSoulType(self)
	local iSoulType = self.m_CoreType
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
end

function CParSoulSetPlanView.OnClickSoul(self, oItemObj, oBox)
	local oItem = g_ItemCtrl:GetItem(oBox.m_ID)
	if oItem then
			local args = {
			equiplist = self.m_WearDict,
			callback = callback(self, "ReplaceSoul"),
		}
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, args)
	end
	for i = 1, 6 do
		self.m_SoulItemList[i].m_AddSpr:SetActive(false)
	end
	oItemObj.m_AddSpr:SetActive(true)
end


function CParSoulSetPlanView.OnShowSelectCore(self)
	CParSoulChangeTypeView:ShowView(function (oView)
		oView:SelectPlanCoreType(callback(self, "OnUpdateCoreType"))
	end)
end

function CParSoulSetPlanView.OnUpdateCoreType(self, iCoreType)
	if self.m_CoreType ~= iCoreType then
		self.m_CoreType = iCoreType
		self:UpdateSoulType()
		self.m_WearDict = {}
		self:UpdateSoul()
	end
end

function CParSoulSetPlanView.OnShowSoulList(self, b, oBox)
	if self.m_CoreType then
		self.m_SelectPart:OnClickType(self.m_CoreType)
	end
	for i = 1, 6 do
		self.m_SoulItemList[i].m_AddSpr:SetActive(false)
	end
	oBox.m_AddSpr:SetActive(true)
end

function CParSoulSetPlanView.OnFastEquip(self, iCoreType, dSoulList)
	if self.m_CoreType ~= iCoreType then
		self.m_WearDict = {}
	end
	self.m_CoreType = iCoreType
	self:UpdateSoulType()
	for _, v in ipairs(dSoulList) do
		self.m_WearDict[v.pos] = v.itemid
	end
	self:UpdateSoul()
end

function CParSoulSetPlanView.OnRename(self)
	local windowInputInfo = {
		des				= "输入方案名（最多6个字）",
		title			= "御灵方案",
		inputLimit		= 12,
		wordLimit = 6,
		okCallback		= function (input)
		 	self:ConfirmRename(input)
		end,
		cancelCallback  = function() end,
		isclose         = false,
		defaultText		= ""
	}
	
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function CParSoulSetPlanView.ConfirmRename(self, input)
	if input:GetInputLength() == 0 then 
		g_NotifyCtrl:FloatMsg("还未输入方案名")
		return
	end 
	local name = input:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("内容中包含非法文字和词汇，请重新命名")
		return
	end
	self.m_NameText = name
	self.m_PlanNameLabel:SetText(name)
	CItemTipsInputWindowView:CloseView()
end

function CParSoulSetPlanView.OnAddSoulPlan(self)
	local sName = self.m_NameText or ""
	if sName == "" then
		g_NotifyCtrl:FloatMsg("请输入方案名称")
		return
	end
	if not self.m_CoreType then
		g_NotifyCtrl:FloatMsg("请先添加御灵核心")
		return
	end
	local dSendList = {}
	for k, v in pairs(self.m_WearDict) do
		table.insert(dSendList, {pos=k, itemid=v})
	end
	if self.m_PlanID then
		netpartner.C2GSModifyParSoulPlan(self.m_PlanID, sName, self.m_CoreType, dSendList)
	else
		netpartner.C2GSAddParSoulPlan(sName, self.m_CoreType, dSendList)
	end
	self:OnClose()
end

return CParSoulSetPlanView