local CPartnerUpGradePage = class("CPartnerUpGradePage", CPageBase)
CPartnerUpGradePage.ITEM_SHAPE = 14001

function CPartnerUpGradePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerUpGradePage.OnInitPage(self)
	self.m_ExpSlider = self:NewUI(3, CSlider)
	self.m_TipBtn = self:NewUI(4, CButton)
	self.m_UpGradeBtn = self:NewUI(5, CButton)
	self.m_GradeChangeLabel = self:NewUI(7, CLabel)
	self.m_ExpLabel = self:NewUI(8, CLabel)
	self.m_AttrPart = self:NewUI(9, CBox)
	self.m_UseItem = self:NewUI(10, CSprite)
	self.m_AmountLabel = self:NewUI(11, CLabel)
	self.m_Up5GradeBtn = self:NewUI(12, CButton)
	self.m_UpGradeBtn:AddUIEvent("click", callback(self, "OnUpGrade", 1))
	self.m_Up5GradeBtn:AddUIEvent("click", callback(self, "OnUpGrade", 5))
	g_GuideCtrl:AddGuideUI("partner_upgrade_5_btn", self.m_Up5GradeBtn)
	self:InitAttrPart()
	self.m_TipBtn:AddHelpTipClick("partner_upgrade")
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
end

function CPartnerUpGradePage.InitAttrPart(self)
	self.m_AttrList = {}
	local list = {"maxhp", "defense", "attack"}
	for i, name in ipairs(list) do
		self.m_AttrList[name] = self.m_AttrPart:NewUI(i*2-1, CLabel)
		self.m_AttrList["next_"..name] = self.m_AttrPart:NewUI(i*2, CLabel)
	end
end

function CPartnerUpGradePage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self.m_CacheData = {}
			self:UpdatePartner()
		end
	end
end

function CPartnerUpGradePage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
end

function CPartnerUpGradePage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	self:UpdateExp(oPartner)
	self:UpdateCost(oPartner)
	self:UpdateAttr(oPartner)
end

function CPartnerUpGradePage.UpdateExp(self, oPartner)
	local curexp = oPartner:GetCurExp()
	local needexp = oPartner:GetNeedExp()
	self.m_ExpSlider:SetValue(curexp / needexp)
	self.m_ExpLabel:SetText(string.format("%d/%d", curexp, needexp))
	local iGrade = oPartner:GetValue("grade")
	local str = string.format("当前级别:%d                   下一级别:%d", iGrade, iGrade+1)
	self.m_GradeChangeLabel:SetText(str)
	local iValue = data.globaldata.GLOBAL["partner_item_exp"]["value"]
	self.m_NeedAmount = math.max((needexp - curexp) / iValue, 1)
end

function CPartnerUpGradePage.UpdateAttr(self, oPartner)
	self.m_CacheData = self.m_CacheData or {}
	local dict = self.m_CacheData[oPartner.m_ID] or {}
	local list = {"maxhp", "attack", "defense"}
	for i, name in ipairs(list) do
		self.m_AttrList[name]:SetText(tostring(oPartner:GetValue(name)))
		self.m_AttrList["next_"..name]:SetText(dict[name] or "")
	end
	if not dict["maxhp"] then
		netpartner.C2GSOpenPartnerUI(oPartner.m_ID, 1)
	end
end

function CPartnerUpGradePage.UpdateAttrResult(self, iParID, dApplyList)
	local dict = {}
	for _, dAttr in ipairs(dApplyList) do
		dict[dAttr.key] = dAttr.value
	end
	self.m_CacheData = self.m_CacheData or {}
	self.m_CacheData[iParID] = dict
	
	if self.m_CurParID == iParID then
		local list = {"maxhp", "attack", "defense"}
		for i, name in ipairs(list) do
			self.m_AttrList["next_"..name]:SetText(tostring(dict[name]))
		end
	end
end

function CPartnerUpGradePage.UpdateCost(self, oPartner)
	local iAmount = g_ItemCtrl:GetBagItemAmountBySid(CPartnerUpGradePage.ITEM_SHAPE)
	local str = string.format("%d", iAmount)
	self.m_AmountLabel:SetText(str)
	local d = DataTools.GetItemData(CPartnerUpGradePage.ITEM_SHAPE)
	self.m_UseItem:SpriteItemShape(d.icon)
	self.m_UseItem:AddUIEvent("click", callback(self, "OnClickUseItem"))
end

function CPartnerUpGradePage.OnClickUseItem(self)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(CPartnerUpGradePage.ITEM_SHAPE, 
		{widget = self.m_UseItem, openView = self.m_ParentView}, nil, {showQuickBuy = true})
end

function CPartnerUpGradePage.OnUpGrade(self, iType)
	if not self.m_CurParID then
		return
	end

	if iType == 1 then
		netpartner.C2GSUpGradePartner(self.m_CurParID, 1)
	else
		netpartner.C2GSUpGradePartner(self.m_CurParID, 5)
	end
end

function CPartnerUpGradePage.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
			local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
			if not oPartner then
				return
			end
			self:UpdateCost(oPartner)
	end
end

return CPartnerUpGradePage