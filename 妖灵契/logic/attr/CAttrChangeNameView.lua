local CAttrChangeNameView = class("CAttrChangeNameView", CViewBase)

function CAttrChangeNameView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrChangeNameView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_Timer = nil
end

function CAttrChangeNameView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_NameInputLabel = self:NewUI(4, CInput)
	self.m_TipsLabel = self:NewUI(5, CLabel)

	self.m_MinNameChar = 2
	self.m_MaxNameChar = 6
	self.m_TempName = g_AttrCtrl.name
	self.m_RenameItemId = tonumber(data.globaldata.GLOBAL.rename_role_item.value)
	self.m_Item = CItem.NewBySid(self.m_RenameItemId)

	self:InitContent()
end

function CAttrChangeNameView.InitContent(self)
	self.m_NameInputLabel:SetText("")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemNotify"))
	self:RefreshCost()
end

function CAttrChangeNameView.RefreshCost(self)
	if g_ItemCtrl:GetBagItemAmountBySid(self.m_RenameItemId) > 0 then
		self.m_TipsLabel:SetText("本次修改角色名消耗改名卡X1")
	else
		self.m_TipsLabel:SetText(string.format("本次修改角色名消耗#w2%s", self.m_Item:GetValue("buy_price")))
	end
end

function CAttrChangeNameView.OnItemNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		-- printc("OnItemNotify")
		self:RefreshCost()
	end
end

function CAttrChangeNameView.OnConfirm(self)
	local name = self.m_NameInputLabel:GetText()
	
	local nameLen = #CMaskWordTree:GetCharList(name)
	if nameLen < self.m_MinNameChar or nameLen > self.m_MaxNameChar then
		g_NotifyCtrl:FloatMsg("角色名字为2-6个字")
	elseif g_MaskWordCtrl:IsContainMaskWord(name) then
		g_NotifyCtrl:FloatMsg("名字中包含屏蔽字")
	elseif not string.isIllegal(name) then
		g_NotifyCtrl:FloatMsg("含有特殊字符，请重新输入")
	elseif g_ItemCtrl:GetBagItemAmountBySid(self.m_RenameItemId) <= 0 and self.m_Item:GetValue("buy_price") > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	else
		netplayer.C2GSRename(name)
	end
end

function CAttrChangeNameView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change and self.m_TempName ~= g_AttrCtrl.name then
		self:OnClose()
	end
end

return CAttrChangeNameView