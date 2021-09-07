TipsDisconnectedView = TipsDisconnectedView or BaseClass(BaseView)

function TipsDisconnectedView:__init()
	self.ui_config = {"uis/views/tips/disconnectedtips", "DisconnectedTip"}
	self.view_layer = UiLayer.Disconnect
	self.auto_connect = true
	self.play_audio = true
	self.active_close = false
end

function TipsDisconnectedView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.connect_time)

	-- 清理变量和对象
	self.time = nil
end

function TipsDisconnectedView:LoadCallBack()
	ReportManager:Step(Report.STEP_DISCONNECT_SHOW)
	self:ListenEvent("Retry", BindTool.Bind(self.OnRetry, self))
	self:ListenEvent("Back", BindTool.Bind(self.OnBack, self))
	self.time = self:FindVariable("Time")
end

function TipsDisconnectedView:OnRetry()
	print_log("Retry connect.")
	ReportManager:Step(Report.STEP_DISCONNECT_RETRY)
	TipsCtrl.Instance:ShowLoadingTips(15, BindTool.Bind(self.Open, self), 1)
	GameNet.Instance:ResetLoginServer()
	GameNet.Instance:ResetGameServer()
	GameNet.Instance:AsyncConnectLoginServer(5)
	if nil ~= LoginCtrl.Instance then
		LoginCtrl.Instance:ClearViewScenes()
	end
	self:Close()
end

function TipsDisconnectedView:OnBack()
	print_log("Back to login.")
	self:Close()
	ReportManager:Step(Report.STEP_DISCONNECT_BACK)
	--GameRoot.Instance:Restart()
	GlobalEventSystem:Fire(LoginEventType.LOGOUT)
end

function TipsDisconnectedView:SetAutoConnect(auto_connect)
	if auto_connect ~= nil then
		self.auto_connect = auto_connect
	end
end

function TipsDisconnectedView:OpenCallBack()
	self.reconnect_time = 30
	GlobalTimerQuest:CancelQuest(self.connect_time)
	if self.auto_connect then
		self.connect_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.ConnectTimeUpdate,self), 1)
		self:ConnectTimeUpdate()
	else
		self.time:SetValue("")
	end
end

function TipsDisconnectedView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.connect_time)
	self.auto_connect = true
end

function TipsDisconnectedView:ConnectTimeUpdate()
	self.reconnect_time = self.reconnect_time - 1
	self.time:SetValue(string.format(Language.Login.ReconnectTips, self.reconnect_time))
	if self.reconnect_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.connect_time)
		self:OnRetry()
	end
end
