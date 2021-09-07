TipsLoadingView = TipsLoadingView or BaseClass(BaseView)

function TipsLoadingView:__init()
	self.ui_config = {"uis/views/tips/loadingtips", "LoadingTip"}
	self.view_layer = UiLayer.Pop
	self.active_close = false
	self.play_audio = true
end

function TipsLoadingView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.connect_time)

	-- 清理变量和对象
	self.character = nil
	self.switch = nil
end

function TipsLoadingView:LoadCallBack()
	self.character = self:FindVariable("character")
	self.switch = self:FindVariable("switch")
end

function TipsLoadingView:OpenCallBack()
	if self.flag == 1 then
		self.character:SetValue(Language.LoadingTipsText.ReconnectionText)
		self.switch:SetValue(true)
	else
		self.character:SetValue(Language.LoadingTipsText.LoadingText)
		self.switch:SetValue(false)
	end
end

function TipsLoadingView:SetCharacter(flag)
	self.flag = flag
end

function TipsLoadingView:CloseCallBack()
	self.duration = nil
	self.callback = nil
	self.flag = nil
	GlobalTimerQuest:CancelQuest(self.close_timer)
end

function TipsLoadingView:SetDuration(duration)
	self.duration = duration
	if self.duration then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnTimeOutClose,self), self.duration)
	end
end

function TipsLoadingView:SetCallBack(callback)
	self.callback = callback
end

function TipsLoadingView:OnTimeOutClose()
	if self.callback then
		self.callback()
	end
	self:Close()
end
