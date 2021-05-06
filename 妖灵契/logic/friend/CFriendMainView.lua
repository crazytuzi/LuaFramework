local CFriendMainView = class("CFriendMainView", CViewBase)

function CFriendMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Friend/FriendMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOout"
	--self.m_GroupName = "main"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CFriendMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_FriendPage = self:NewPage(2, CFriendPage)
	self.m_CloseBtn = self:NewUI(4, CButton)

	self.m_FrdBtnBox = self:NewUI(5, CBox)
	self.m_MailBtnBox = self:NewUI(6, CBox)
	self.m_MailPage = self:NewPage(7, CMailPage)
	self.m_MailAmount = self:NewUI(8, CLabel)
	self.m_InfoBtnBox = self:NewUI(9, CBox)

	self.m_InfoPage = self:NewPage(10, CInfoEditPage)
	self:InitContent()
end

function CFriendMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FrdBtnBox:SetGroup(self:GetInstanceID())
	self.m_MailBtnBox:SetGroup(self:GetInstanceID())
	self.m_InfoBtnBox:SetGroup(self:GetInstanceID())
	
	self.m_FrdBtnBox:AddUIEvent("click", callback(self, "ShowFriendPage"))
	self.m_MailBtnBox:AddUIEvent("click", callback(self, "ShowMailPage"))
	self.m_InfoBtnBox:AddUIEvent("click", callback(self, "OpenInfoPage"))

	self:UpdateMailAmount()
	g_MailCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMailEvent"))
	self.m_FrdBtnBox:SetSelected(true)
	self:ShowSubPage(self.m_FriendPage)
	self:OnDefaultTalk()
end

function CFriendMainView.OnShowView(self)
	self:OnDefaultTalk()
	self:StartOpenEffect()
end

function CFriendMainView.OnMailEvent(self, oCtrl)
	self:UpdateMailAmount()
end

function CFriendMainView.UpdateMailAmount(self)
	local amount = g_MailCtrl:GetUnOpenMailAmount()
	if amount > 0 then
		self.m_MailAmount:SetActive(true)
		if amount > 99 then
			self.m_MailAmount:SetText("99+")
		else
			self.m_MailAmount:SetText(amount)
		end
	else
		self.m_MailAmount:SetActive(false)
	end
end

function CFriendMainView.OnDefaultTalk(self)
	local pid = g_TalkCtrl:GetRecentTalk()
	if pid then
		self:ShowTalk(pid)
		self.m_FrdBtnBox:SetSelected(true)
	elseif g_FriendCtrl:GetApplyAmount() > 0 then
		self.m_FrdBtnBox:SetSelected(true)
		self:ShowFriendPage()
	else
		if g_MailCtrl:GetUnOpenMailAmount() > 0 then
			self.m_MailBtnBox:SetSelected(true)
			self:ShowMailPage()
		
		elseif self.m_CurPage == self.m_MailPage then
			self:ShowMailPage()
		end
	end
end

function CFriendMainView.ShowFriendPage(self)
	self:ShowSubPage(self.m_FriendPage)
end

function CFriendMainView.ShowMailPage(self)
	self:ShowSubPage(self.m_MailPage)
	self.m_MailPage:OnShowPage()
end

function CFriendMainView.ShowTalk(self, pid)
	self:ShowSubPage(self.m_FriendPage)
	self.m_FriendPage:ChooseItem(pid)
	self.m_FriendPage:OnOpenTalk(pid)
end

function CFriendMainView.OpenInfoPage(self)
	netfriend.C2GSTakeDocunment(g_AttrCtrl.pid)
	if self.m_InfoPage.m_IsInit then
		self:ShowSubPage(self.m_InfoPage)
	end
end

function CFriendMainView.ShowInfoPage(self, ...)
	self:ShowSubPage(self.m_InfoPage)
	self.m_InfoPage:SetData(...)
end

function CFriendMainView.CloseView(self)
	if self.m_FriendPage then
		self.m_FriendPage:SaveMsgRecord()
		self.m_FriendPage:ClearOpenTalkMsg()
	end
	CViewBase.CloseView(self)
end


return CFriendMainView