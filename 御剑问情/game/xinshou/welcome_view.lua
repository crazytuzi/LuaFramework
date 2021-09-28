WelcomeView = WelcomeView or BaseClass(BaseView)

function WelcomeView:__init()
	self.ui_config = {"uis/views/welcomeview_prefab","WelcomeView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function WelcomeView:ReleaseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function WelcomeView:LoadCallBack()
	-- self:ListenEvent("close_view",
	-- 	BindTool.Bind(self.HandleClose, self))
	self.time = self:FindVariable("Time")
	self:ListenEvent("OnStartGame",
		BindTool.Bind(self.OnStartGame, self))
	self:SetAutoTalkTime()
end

-- function WelcomeView:HandleClose()
-- 	self:Close()
-- 	MainUICtrl.Instance:SetIsAutoTaskState(true)
-- 	TaskCtrl.Instance:DoTask()
-- end

function WelcomeView:OnStartGame()
	self:Close()
	-- MainUICtrl.Instance:SetIsAutoTaskState(true)
	TaskCtrl.Instance:DoTask()
end

function WelcomeView:OpenCallBack()
	TaskCtrl.Instance:SetAutoTalkState(false)
end

-- 设置倒计时
function WelcomeView:SetAutoTalkTime()
	self.auto_talk = false
	self.time:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(5, TEXT_COLOR.WHITE)))
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(5, 1, BindTool.Bind(self.CountDown, self))
end

-- 倒计时函数
function WelcomeView:CountDown(elapse_time, total_time)
	self.time:SetValue(string.format(Language.Task.AutoGoOn, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.WHITE)))
	if elapse_time >= total_time then
		self:Close()
		-- MainUICtrl.Instance:SetIsAutoTaskState(true)
		-- TaskCtrl.Instance:DoTask()
		-- TaskCtrl.Instance:SetAutoTalkState(true)
	end
end