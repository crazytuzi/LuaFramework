TipsPowerChangeView = TipsPowerChangeView or BaseClass(BaseView)

function TipsPowerChangeView:__init()
	self.ui_config = {"uis/views/tips/powerchangetips_prefab", "PowerChangeTips"}

	self.is_playing = false
	self.time_quest = nil
	self.delay_show_quest = nil
	self.vew_cache_time = ViewCacheTime.MOST

	self.newest_value = 0

	self.inc_value_once = 0
	self.cur_show_value = 0
	self.target_show_value = 0

	self.view_layer = UiLayer.Guide
end

function TipsPowerChangeView:LoadCallBack()
	self.animator:ListenEvent("AniFinish", BindTool.Bind(self.OnAniFinish, self))
	self.power = self:FindVariable("Power")
	self.is_up = self:FindVariable("is_up")
	self.is_show_effext = self:FindVariable("ShowEffect")
	self.green_text = self:FindVariable("GreenText")
	self.red_text = self:FindVariable("RedText")
	self.up_anim = self:FindObj("UpAnim")
	self.down_anim = self:FindObj("DownAnim")
end

function TipsPowerChangeView:ReleaseCallBack()
	if nil ~= self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if nil ~= self.eff_timer then
		GlobalTimerQuest:CancelQuest(self.eff_timer)
		self.eff_timer = nil
	end

	if nil ~= self.delay_show_quest then
		GlobalTimerQuest:CancelQuest(self.delay_show_quest)
		self.delay_show_quest = nil
	end

	-- 清理变量和对象
	self.power = nil
	self.is_up = nil
	self.is_show_effext = nil
	self.green_text = nil
	self.red_text = nil
	self.up_anim = nil
	self.down_anim = nil
end

function TipsPowerChangeView:OpenCallBack()
	GlobalEventSystem:Fire(OtherEventType.POWER_CHANGE_VIEW_OPEN, true)
end

function TipsPowerChangeView:CloseCallBack()
	GlobalEventSystem:Fire(OtherEventType.POWER_CHANGE_VIEW_OPEN, false)
end

function TipsPowerChangeView:ShowView(new_value, old_value)
	self.newest_value = new_value
	-- 延迟是因为处理收到降战力然后又马上升战力（效果不好，使用最旧的值和最新的值的战力变化）
	if nil == self.delay_show_quest then
		self.delay_show_quest = GlobalTimerQuest:AddDelayTimer(function ()
			self.delay_show_quest = nil
			if self.newest_value > 0 then  --self.newest_value可能在延迟的0.2秒之内被初始化为0，所以这里判断一下
				self:DoShow(self.newest_value, old_value)
			end
		end, 0.2)
	end
end

function TipsPowerChangeView:DoShow(new_value, old_value)
	if new_value == old_value or self.is_playing then
		return
	end
	if self:IsLoaded() then
		self.animator:SetBool('DoHide', false)
		if self.up_anim.gameObject.activeInHierarchy then
			self.up_anim.animator:SetTrigger("PowerShow")
		end
		if self.down_anim.gameObject.activeInHierarchy then
			self.down_anim.animator:SetTrigger("PowerShow")
		end
	end

	if new_value > old_value then
		AudioManager.PlayAndForget("audios/sfxs/other", self.audio_config.other[1].Power_up)
	end

	self.cur_show_value = old_value
	self.target_show_value = new_value
	self.inc_value_once = math.ceil(math.abs(new_value - old_value) / 40)
	self.is_playing = true

	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateShowChange, self, new_value, old_value), 0.01)
	end
		self:Open()
	self:Flush()
end

function TipsPowerChangeView:UpdateShowChange(new_value, old_value)
	if not self:IsLoaded() or 0 == self.inc_value_once then
		return
	end

	self.is_up:SetValue(new_value > old_value)
	if new_value > old_value then
		self.green_text:SetValue(math.abs(new_value - old_value))
		self.cur_show_value = math.min(self.cur_show_value + self.inc_value_once, self.target_show_value)
		if self.cur_show_value >= self.target_show_value then
			self.inc_value_once = 0
			self:OnShowChangeComplete(new_value)
		end	
	else
		self.red_text:SetValue(math.abs(new_value - old_value))
		self.cur_show_value = math.max(self.cur_show_value - self.inc_value_once, self.target_show_value)
		if self.cur_show_value <= self.target_show_value then
			self.inc_value_once = 0
			self:OnShowChangeComplete(new_value)
		end	

	end
	
	self.power:SetValue(self.cur_show_value)
end

function TipsPowerChangeView:OnFlush()
	if nil == self.eff_timer then
		self.is_show_effext:SetValue(false)
		self.is_show_effext:SetValue(true)
		self.eff_timer = GlobalTimerQuest:AddDelayTimer(function ()
			GlobalTimerQuest:CancelQuest(self.eff_timer)
			self.eff_timer = nil
		end, 0.5)
	end
end

function TipsPowerChangeView:OnShowChangeComplete(new_value)
	if nil ~= self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.newest_value > 0 and self.newest_value ~= new_value then
		GlobalTimerQuest:AddDelayTimer(function()
			self.is_playing = false
			self:DoShow(self.newest_value, new_value)
			self.newest_value = 0
		end, 0.2)
	else
		self.is_playing = false
		self.animator:SetBool('DoHide', true)
	end
end

function TipsPowerChangeView:OnAniFinish()
	self:Close()
end