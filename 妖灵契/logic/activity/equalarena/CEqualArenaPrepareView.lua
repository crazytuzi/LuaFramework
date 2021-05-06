local CEqualArenaPrepareView = class("CEqualArenaPrepareView", CViewBase)

function CEqualArenaPrepareView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/EqualArena/EqualArenaPrepareView.prefab", ob)
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
	-- self.m_OpenEffect = "Scale"
end

function CEqualArenaPrepareView.OnCreateView(self)
	self.m_SelectPage = self:NewPage(1, CEqualArenaSelectPage)
	self.m_CombinePage = self:NewPage(2, CEqualArenaCombinePage)
	self:InitContent()
end

function CEqualArenaPrepareView.InitContent(self)
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualEvent"))
end

function CEqualArenaPrepareView.ShowSelectPage(self)
	self:ShowSubPage(self.m_SelectPage)
end

function CEqualArenaPrepareView.ShowCombinePage(self)
	self:ShowSubPage(self.m_CombinePage)
end

function CEqualArenaPrepareView.OnEqualEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.OnCombineStart then
		self:ShowCombinePage()
		local oView = CNotifyView:GetView()
		if oView then
			oView:HideHint()
		end
	elseif oCtrl.m_EventID == define.EqualArena.Event.OnCloseEqualArenaUI then
		self:CloseView()
	end
end

return CEqualArenaPrepareView
