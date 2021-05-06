local CExpandYwBossPage = class("CExpandYwBossPage", CPageBase)

function CExpandYwBossPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandYwBossPage.OnInitPage(self)
	self.m_QuitBtn = self:NewUI(1, CButton)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_CountLabel = self:NewUI(3, CLabel)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self.m_ShowBox = self:NewUI(5, CBox)
	self.m_HideBtn = self:NewUI(6, CButton)
	self.m_HideBox = self:NewUI(7, CBox)
	self.m_OpenBtn = self:NewUI(8, CButton)
	self.m_Timer = nil
	self.m_ConditionLabelList = {}
	self:InitContent()
end

function CExpandYwBossPage.InitContent(self)
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitFb"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	self:RefreshAll(true)
end

function CExpandYwBossPage.OnQuitFb(self)
	local args = 
	{
		msg = "确定要退出副本吗？",
		okCallback= function ( )
			nethuodong.C2GSLeaveLegendFB()
		end,
		cancelCallback = function ()
		end,
		okStr = "是",
		cancelStr = "否",
		countdown = 10,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)

end

function CExpandYwBossPage.OnShowPage(self)
	self:RefreshUI()
	self:RefreshAll(true)
end

function CExpandYwBossPage.RefreshUI(self)
	local d = g_TaskCtrl:GetCaiQuanFuBenTask()
	if not d then
		return
	end
	local dData = d.m_SData
	self.m_CountLabel:SetText(string.getstringdark(dData.detaildesc))
	self:ShowTimeBox(g_TimeCtrl:GetTimeS() + dData.time)
end

function CExpandYwBossPage.ShowTimeBox(self, iTime)
	self.m_EndTime = iTime
	if not self.m_TimeTimer then
		self.m_TimeTimer = Utils.AddTimer(callback(self, "OnTimeUpdate"), 0.1, 0)
	end
end

function CExpandYwBossPage.OnTimeUpdate(self)
	local seconds = self.m_EndTime - g_TimeCtrl:GetTimeS()
	self.m_TimeLabel:SetText(string.getstringdark("剩余时间：#R"..g_TimeCtrl:GetLeftTime(seconds)))
	if seconds >= 0 then
		return true
	else
		self:CloseTimeBox()
		return false
	end
end

function CExpandYwBossPage.CloseTimeBox(self)
	if self.m_TimeTimer ~= nil then
		Utils.DelTimer(self.m_TimeTimer)
		self.m_TimeTimer = nil
	end
end

function CExpandYwBossPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
end

function CExpandYwBossPage.Destroy(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CPageBase.Destroy(self)
end

function CExpandYwBossPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end	
end

function CExpandYwBossPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

return CExpandYwBossPage