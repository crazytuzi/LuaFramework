local COrgEmailPart = class("COrgEmailPart", CBox)

function COrgEmailPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self:InitContent()
end

function COrgEmailPart.InitContent(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_SubmitBtn = self:NewUI(3, CButton)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSumbit"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
end

function COrgEmailPart.ShowEdit(self)
	self:SetActive(true)
	self.m_Input:SetText("")
end

function COrgEmailPart.OnClose(self)
	self:SetActive(false)
end

function COrgEmailPart.OnSumbit(self)
	local sText = self.m_Input:GetText()
	local len = #CMaskWordTree:GetCharList(sText)

	if sText == "" then
		g_NotifyCtrl:FloatMsg("请输入内容")
	elseif len > g_OrgCtrl:GetRule().mail_len then
		g_NotifyCtrl:FloatMsg(string.format("长度超出%s汉字", g_OrgCtrl:GetRule().mail_len))
	elseif g_MaskWordCtrl:IsContainMaskWord(sText) then
		g_NotifyCtrl:FloatMsg("内容存在敏感词，请重新输入")
	else
		netorg.C2GSOrgSendMail(sText)
	end
	
end

function COrgEmailPart.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.OnSendMailResult and oCtrl.m_EventData == 1 then
		self:OnClose()
	end
end

return COrgEmailPart