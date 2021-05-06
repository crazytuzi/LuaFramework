local CChatNormalMsgPage = class("CChatNormalMsgPage", CPageBase)

function CChatNormalMsgPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatNormalMsgPage.OnInitPage(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_MsgBox = self:NewUI(2, CBox)
	self:InitContent()
end

function CChatNormalMsgPage.InitContent(self)
	self.m_MsgBox:SetActive(false)
	self:UpdateGrid()
	g_LinkInfoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLinkCtrlEvent"))
end

function CChatNormalMsgPage.OnShowPage(self)
	self:UpdateGrid()
end

function CChatNormalMsgPage.OnLinkCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Link.Event.UpdateNormalMsg then
		self:UpdateGrid()
	end
end

function CChatNormalMsgPage.UpdateGrid(self)
	self.m_Grid:Clear()
	local msglist = g_LinkInfoCtrl:GetNormalMsg()
	for _, msg in ipairs(msglist) do
		local box = self.m_MsgBox:Clone()
		box:SetActive(true)
		box.m_Input = box:NewUI(1, CInput)
		box.m_Label = box:NewUI(2, CLabel)
		box.m_EditBtn = box:NewUI(3, CButton)
		box.m_SaveBtn = box:NewUI(4, CButton)
		box.m_CancelBtn = box:NewUI(5, CButton)
		box.m_Label:SetText(msg)
		box.m_Input:SetText(msg)
		box.m_Label:AddUIEvent("click", callback(self, "OnClickMsg", msg))
		box.m_EditBtn:AddUIEvent("click", callback(self, "OnEditMsg", box))
		box.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveMsg", box))
		box.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelMsg", box, msg))
		box.m_SaveBtn:SetActive(false)
		box.m_CancelBtn:SetActive(false)
		self.m_Grid:AddChild(box)
	end
end

function CChatNormalMsgPage.OnEditMsg(self, box)
	box.m_Input:SetActive(true)
	box.m_Label:SetActive(false)
	box.m_Input:SetFocus()
	box.m_EditBtn:SetActive(false)
	box.m_SaveBtn:SetActive(true)
	box.m_CancelBtn:SetActive(true)
end

function CChatNormalMsgPage.OnSaveMsg(self, box)
	box.m_Input:SetActive(false)
	box.m_Label:SetActive(true)
	box.m_EditBtn:SetActive(true)
	box.m_SaveBtn:SetActive(false)
	box.m_CancelBtn:SetActive(false)
	local list = {}
	for _, oChild in ipairs(self.m_Grid:GetChildList()) do
		local str = oChild.m_Input:GetText()
		if str == "" then
			g_NotifyCtrl:FloatMsg("输入的内容不能为空")
			return
		end
		table.insert(list, str)
	end
	netlink.C2GSEditCommonChat(list)
end

function CChatNormalMsgPage.OnCancelMsg(self, box, msg)
	box.m_Input:SetActive(false)
	box.m_Label:SetActive(true)
	box.m_EditBtn:SetActive(true)
	box.m_SaveBtn:SetActive(false)
	box.m_CancelBtn:SetActive(false)
	box.m_Input:SetText(msg)
end

function CChatNormalMsgPage.OnClickMsg(self, msg)
	self.m_ParentView:Send(msg)
end

return CChatNormalMsgPage