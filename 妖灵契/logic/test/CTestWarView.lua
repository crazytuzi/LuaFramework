local CTestWarView = class("CTestWarView", CViewBase)

function CTestWarView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Test/TestWarView.prefab", ob)
	-- self.m_GroupName = "main"
end

function CTestWarView.OnCreateView(self)
	self.m_PauseBtn = self:NewUI(1, CButton)
	self.m_NextBtn = self:NewUI(2, CButton)
	self.m_ExitBtn = self:NewUI(3, CButton)
	self.m_TipsLabel = self:NewUI(4, CLabel)
	self.m_InputLabel = self:NewUI(5, CInput)
	self.m_Pausing = true
	self:InitContent()
end

function CTestWarView.InitContent(self)
	self.m_PauseBtn:AddUIEvent("click", callback(self, "OnPause"))
	self.m_NextBtn:AddUIEvent("click", callback(self, "OnNext"))
	self.m_ExitBtn:AddUIEvent("click", callback(self, "OnExit"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
end

function CTestWarView.OnPause(self)
	if self.m_Pausing then
		self.m_Pausing = false
		g_WarCtrl.m_CanMoveNext = true
		self.m_PauseBtn:SetText("暂停")
	else
		self.m_Pausing = true
		g_WarCtrl.m_CanMoveNext = false
		self.m_PauseBtn:SetText("继续")
	end
	g_WarCtrl.m_NextStep = 0
	self:Refresh()
end

function CTestWarView.OnNext(self)
	local count = tonumber(self.m_InputLabel:GetText()) or 0
	g_WarCtrl.m_NextStep = g_WarCtrl.m_NextStep + count
	self:Refresh()
end

function CTestWarView.Refresh(self)
	self.m_TipsLabel:SetText("倒数步数：" .. g_WarCtrl.m_NextStep)
end

function CTestWarView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.OnTestStep then
		self:Refresh()
	elseif oCtrl.m_EventID == define.War.Event.EndWar then
		self:CloseView()
	end
end

function CTestWarView.OnExit(self)
	g_WarCtrl.m_IsTestMode = false
	self:CloseView()
end

return CTestWarView