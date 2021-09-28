TianshenhutiBossComeWarning = TianshenhutiBossComeWarning or BaseClass(BaseView)

function TianshenhutiBossComeWarning:__init()
    self.ui_config = {"uis/views/tianshenhutiview_prefab", "BossComeWarning"}
   	--需要立即销毁
	self.vew_cache_time = 0
end

function TianshenhutiBossComeWarning:__delete()

end

function TianshenhutiBossComeWarning:CloseCallBack()
	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function TianshenhutiBossComeWarning:ReleaseCallBack()
	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function TianshenhutiBossComeWarning:LoadCallBack()

end

function TianshenhutiBossComeWarning:OpenCallBack()
	if self.close_timer == nil then
		self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.Close, self), 4)
	end
end

function TianshenhutiBossComeWarning:OnFlush(param_list)

end