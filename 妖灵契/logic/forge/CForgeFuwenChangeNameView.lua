local CForgeFuwenChangeNameView = class("CForgeFuwenChangeNameView", CViewBase)

function CForgeFuwenChangeNameView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeFuwenChangeNameView.prefab", cb)
	--界面设置
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CForgeFuwenChangeNameView.OnCreateView(self)
	self.m_InputOne = self:NewUI(1, CInput)
	self.m_InputTwo = self:NewUI(2, CInput)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self:InitContent()
end

function CForgeFuwenChangeNameView.InitContent(self)
	self.m_InputOne:SetText("")
	self.m_InputTwo:SetText("")
	self.m_CancelBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CForgeFuwenChangeNameView.OnConfirm(self)
	local t = {}
	local nameOne = self.m_InputOne:GetText()
	local nameTwo = self.m_InputTwo:GetText()
	local nameLen = #CMaskWordTree:GetCharList(nameOne)
	if nameLen > 4 then
		g_NotifyCtrl:FloatMsg("方案1命名超出4个字符")
		return
	end
	nameLen = #CMaskWordTree:GetCharList(nameTwo)
	if nameLen > 4 then
		g_NotifyCtrl:FloatMsg("方案2命名超出4个字符")
		return
	end

	if nameOne ~= "" then
		local d  = {plan = 1, name = nameOne}
		table.insert(t, d)
	end
	
	if nameTwo ~= "" then		
		local d  = {plan = 2, name = nameTwo}
		table.insert(t, d)		
	end
	if next(t) then
		netitem.C2GSReNameFuWen(t)
	end
	self:CloseView()
end

return CForgeFuwenChangeNameView