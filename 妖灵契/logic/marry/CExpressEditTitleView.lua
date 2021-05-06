local CExpressEditTitleView = class("CExpressEditTitleView", CViewBase)

function CExpressEditTitleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressEditTitleView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressEditTitleView.OnCreateView(self)
	self.m_OkBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_Input = self:NewUI(3, CInput)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_ClearBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CExpressEditTitleView.InitContent(self)
	self.m_NameLabel:SetText(string.format("%s的", g_MarryCtrl.m_LoverName))
	self.m_Input:SetText(g_MarryCtrl.m_PostFix)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancel"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClear"))
end

function CExpressEditTitleView.OnClickOk(self)
	local sText = self.m_Input:GetText()
	local len = #CMaskWordTree:GetCharList(sText)
	if sText == "" or sText == nil then
		g_NotifyCtrl:FloatMsg("请输入内容")
	elseif len > 4 then
		g_NotifyCtrl:FloatMsg("输入内容中超出4字符")
	elseif g_MaskWordCtrl:IsContainMaskWord(sText) then
		g_NotifyCtrl:FloatMsg("输入内容中含有屏蔽字")
	elseif not string.isIllegal(sText) then
		g_NotifyCtrl:FloatMsg("含有特殊字符，请重新输入")
	elseif g_AttrCtrl.goldcoin < g_MarryCtrl.m_ChangeTitleCost then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	else
		nethuodong.C2GSChangeLoversTitle(sText)
		self:OnClose()
	end
end

function CExpressEditTitleView.OnClear(self)
	self.m_Input:SetText("")
end

function CExpressEditTitleView.OnClickCancel(self)
	self:OnClose()
end

return CExpressEditTitleView