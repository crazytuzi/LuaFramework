local CParSoulChoosePlanView = class("CParSoulChoosePlanView", CViewBase)

--查看御灵方案界面
function CParSoulChoosePlanView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/ParSoulPlanChooseView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CParSoulChoosePlanView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_ChildBox = self:NewUI(3, CBox)
	self.m_SaveCurBtn = self:NewUI(4, CButton)
	self.m_AddPlanBtn = self:NewUI(5, CButton)
	self.m_Container = self:NewUI(6, CWidget)
	self:InitContent()
end

function CParSoulChoosePlanView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ChildBox:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_ChildBox, callback(self, "SetCloneChild"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "SetWrapRefreshFunc"))
	self.m_SaveCurBtn:AddUIEvent("click", callback(self, "OnSaveCurPlan"))
	self.m_AddPlanBtn:AddUIEvent("click", callback(self, "OnAddPlan"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrl"))
	self.m_UnLockAmount = self:GetUnLockAmount()
	self:Refresh()
	self.m_ScrollView:ResetPosition()
end

function CParSoulChoosePlanView.OnPartnerCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.AddSoulPlan then
		self:Refresh()
		self.m_ScrollView:ResetPosition()
	elseif oCtrl.m_EventID == define.Partner.Event.DelSoulPlan then
		self:Refresh()
		self.m_ScrollView:ResetPosition()
	elseif oCtrl.m_EventID == define.Partner.Event.UpdateSoulPlan then
		self:UpdateSoulPlan(oCtrl.m_EventData)
	end
end

function CParSoulChoosePlanView.SetParID(self, iParID)
	self.m_CurParID = iParID
end

function CParSoulChoosePlanView.SetCloneChild(self, oChild)
	oChild:SetActive(true)
	oChild.m_IconSpr = oChild:NewUI(1, CSprite)
	oChild.m_NameLabel = oChild:NewUI(2, CLabel)
	oChild.m_AttrNode = oChild:NewUI(3, CBox)
	oChild.m_AttrList = {}
	for i = 1, 6 do
		local oAttrObj = oChild.m_AttrNode:NewUI(i, CBox)
		oAttrObj.m_AttrSpr = oAttrObj:NewUI(1, CSprite)
		oAttrObj.m_LockObj = oAttrObj:NewUI(2, CObject)
		oChild.m_AttrList[i] = oAttrObj
	end
	return oChild
end

function CParSoulChoosePlanView.SetWrapRefreshFunc(self, oChild, dData)
	printc("self.m_UnLockAmount", self.m_UnLockAmount)
	if dData and dData.soul_type > 0 then
		local icon = data.partnerequipdata.ParSoulType[dData.soul_type]["icon"]
		oChild.m_IconSpr:SpriteItemShape(icon)
		oChild.m_NameLabel:SetText(dData.name)
		oChild.m_PlanID = dData.idx
		for i = 1, 6 do
			if i > self.m_UnLockAmount then
				oChild.m_AttrList[i].m_LockObj:SetActive(true)
				oChild.m_AttrList[i].m_AttrSpr:SetActive(false)
			else
				oChild.m_AttrList[i].m_LockObj:SetActive(false)
				oChild.m_AttrList[i].m_AttrSpr:SetActive(false)
			end
		end
		for _, attrObj in ipairs(dData.souls) do
			local oItem = g_ItemCtrl:GetItem(attrObj.itemid)
			local obj = oChild.m_AttrList[attrObj.pos]
			if oItem then
				obj.m_AttrSpr:SetActive(true)
				obj.m_AttrSpr:SetSpriteName("pic_parattr_"..tostring(oItem:GetValue("attr_type"))) 
			else
				obj.m_AttrSpr:SetActive(false)
			end
		end
		oChild:AddUIEvent("click",callback(self, "OnEditPlan", dData.idx))
		oChild:SetActive(true)
	else
		oChild.m_PlanID = nil
		oChild:SetActive(false)
	end
end

function CParSoulChoosePlanView.UpdateSoulPlan(self, iPlanID)
	for _, oChild in ipairs(self.m_WrapContent:GetChildList()) do
		if oChild:GetActive() and oChild.m_PlanID == iPlanID then
			local dPlanInfo = g_PartnerCtrl:GetSoulPlan(iPlanID)
			self:SetWrapRefreshFunc(oChild, dPlanInfo)
		end
	end
	if self.m_SoulPlanList then
		for i = 1, #self.m_SoulPlanList do
			if self.m_SoulPlanList[i]["idx"] == iPlanID then
				self.m_SoulPlanList[i] = g_PartnerCtrl:GetSoulPlan(iPlanID)
				break
			end
		end
	end
end

function CParSoulChoosePlanView.Refresh(self)
	self.m_SoulPlanList = g_PartnerCtrl:GetSoulPlanList()
	self.m_WrapContent:SetData(self.m_SoulPlanList, true)
end

function CParSoulChoosePlanView.GetUnLockAmount(self)
	local iGrade = g_AttrCtrl.grade
	local iAmount = 0
	for i, v in ipairs(data.partnerequipdata.ParSoulUnlock) do
		if iGrade >= v.unlock_grade then
			iAmount = iAmount + 1
		end
	end
	return iAmount
end

function CParSoulChoosePlanView.OnSaveCurPlan(self)
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

function CParSoulChoosePlanView.ConfirmRename(self, input)
	if input:GetInputLength() == 0 then 
		g_NotifyCtrl:FloatMsg("请输入方案名称")
		return
	end
	local name = input:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(name) or string.isIllegal(name) == false then 
		g_NotifyCtrl:FloatMsg("内容中包含非法文字和词汇，请重新命名")
		return
	end
	CItemTipsInputWindowView:CloseView()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner then
		local iCoreType = oPartner:GetValue("soul_type")
		local dSendList = {}
		for _, obj in ipairs(oPartner:GetValue("souls") or {}) do
			table.insert(dSendList, {itemid=obj.itemid, pos=obj.pos})
		end
		netpartner.C2GSAddParSoulPlan(name, iCoreType, dSendList)
	end
end

function CParSoulChoosePlanView.OnAddPlan(self)
	CParSoulSetPlanView:ShowView()
end

function CParSoulChoosePlanView.OnEditPlan(self, iPlanID)
	local iParID = self.m_CurParID
	CParSoulCompareView:ShowView(function (oView)
		oView:RefreshPlan(iParID, iPlanID)
	end)
end

return CParSoulChoosePlanView