local COrgChangeNameView = class("COrgChangeNameView", CViewBase)

function COrgChangeNameView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgChangeNameView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgChangeNameView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConfirmBtn = self:NewUI(3, CButton)
	self.m_NameInputLabel = self:NewUI(4, CInput)
	-- self.m_TipsLabel = self:NewUI(5, CLabel)

	self.m_MaxNameLen = g_OrgCtrl:GetRule().max_name_len
	self.m_minNameLen = g_OrgCtrl:GetRule().min_name_len
	self:InitContent()
end

function COrgChangeNameView.InitContent(self)
	self.m_NameInputLabel:SetText("")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
end

function COrgChangeNameView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgName then
		self:CloseView()
	end
end

function COrgChangeNameView.OnConfirm(self)
	local orgName = self.m_NameInputLabel:GetText()
	local len = #CMaskWordTree:GetCharList(orgName)

	if len < self.m_minNameLen or len > self.m_MaxNameLen then
		g_NotifyCtrl:FloatMsg(string.format("名字长度为%d~%d汉字", self.m_minNameLen, self.m_MaxNameLen))
	elseif g_MaskWordCtrl:IsContainMaskWord(orgName) then
		g_NotifyCtrl:FloatMsg("名字存在敏感词，请重新输入")
	elseif not string.isIllegal(orgName) then
		g_NotifyCtrl:FloatMsg("名字存在特殊字符，请重新输入")
	elseif data.globalcontroldata.GLOBAL_CONTROL.org.open_grade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(data.globalcontroldata.GLOBAL_CONTROL.org.open_grade .. "级开启该功能")
	else
		netorg.C2GSOrgRename(orgName)
	end
end

return COrgChangeNameView