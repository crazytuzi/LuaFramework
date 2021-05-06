CMainMenuCtrl = class("CMainMenuCtrl", CCtrlBase)

--notice： MainMenuView的UI操作协助，非数据管理，易混淆
function CMainMenuCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Areas = {}
	self.m_AreaStatus = {}
	self.m_CallBacks = {}
	-- self.m_MainView = nil
end

-- function CMainMenuCtrl.SetMainView(self,view)
-- 	self.m_MainView = view
-- end

function CMainMenuCtrl.AddPopArea(self, iArea, UI, callback, bStatus)
	self.m_Areas[iArea] = UI
	if bStatus ~= nil then
		self.m_AreaStatus[iArea] = bStatus
	else
		self.m_AreaStatus[iArea] = true
	end
	self.m_CallBacks[iArea] = callback
end

function CMainMenuCtrl.ShowArea(self, iArea)
	if Utils.IsNil(self.m_Areas[iArea]) then
		return
	end
	if not self.m_AreaStatus[iArea] then
		self.m_Areas[iArea]:Toggle()
		if self.m_CallBacks[iArea] then
			self.m_CallBacks[iArea]()
		end
		self.m_AreaStatus[iArea] = true
	end
end

function CMainMenuCtrl.HideArea(self, iArea)
	if Utils.IsNil(self.m_Areas[iArea]) then
		return
	end
	if self.m_AreaStatus[iArea] then 
		self.m_Areas[iArea]:Toggle()
		self.m_AreaStatus[iArea] = false
		if self.m_CallBacks[iArea] then
			self.m_CallBacks[iArea]()
		end
	end
end

function CMainMenuCtrl.ShowAllArea(self)
	for iArea, ui in pairs(self.m_Areas) do
		self:ShowArea(iArea)
	end
end

function CMainMenuCtrl.HideAreas(self, tHideConfig)
	for k,iArea in pairs(tHideConfig) do
		self:HideArea(iArea)
	end
end

function CMainMenuCtrl.GetAreaStatus(self, iArea)
	return self.m_AreaStatus[iArea]
end

function CMainMenuCtrl.IsShowTaskPage(self)
	local b = false
	local oView = CMainMenuView:GetView()
	if oView and oView.m_RT and oView.m_RT.m_ExpandBox then
		if oView.m_RT.m_ExpandBox.m_CurPage == oView.m_RT.m_ExpandBox.m_TaskPage then
			b = true
		end
	end
	return b
end

function CMainMenuCtrl.SetMainViewCallback(self, cb)
	local mainView = CMainMenuView:GetView()
	if mainView then
		if mainView:GetActive() then
			cb()
		else
			mainView:SetOnShowCallback(cb)
		end
	else
		printc("mainView = nil")
		CMainMenuView:ShowView(function (oView)
			cb()
		end)
	end
end

function CMainMenuCtrl.GetMainmenuViewActive(self)
	local b = false
	local oView =  CMainMenuView:GetView()
	if oView and oView:GetActive() then
		b = true
	end
	return b
end

function CMainMenuCtrl.OpenWoldMap(self, args)
	CMapMainView:ShowView(function (oView)
		oView:ShowSpecificPage(1, args)
	end)
end

function CMainMenuCtrl.ShowMenuRBSwitchTips(self, bShow, key, tips)
	local oView = CMainMenuView:GetView()
	if oView then
		local rb = oView.m_RB
		if rb then
			rb:ShowSwitchTipsBox(bShow, key, tips)
		end
	end
end

function CMainMenuCtrl.CheckTaskScrollViewUpdateTimer(self)
	local oView = CMainMenuView:GetView()
	if oView and oView.m_LT and oView.m_LT.m_ExpandBox and oView.m_LT.m_ExpandBox.m_TaskPage then
		local isStop = false
		if oView:GetActive() == false then
			isStop = true			
		end
		if not isStop and oView.m_LT.m_ExpandBox.m_TaskPage ~= oView.m_LT.m_ExpandBox.m_CurPage then
			isStop = true			
		end
		if isStop then
			oView.m_LT.m_ExpandBox.m_TaskPage:StopUpdateTimer()
		end
	end
end

return CMainMenuCtrl