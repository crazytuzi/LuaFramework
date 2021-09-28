BossSkillWarningView = BossSkillWarningView or BaseClass(BaseView)

function BossSkillWarningView:__init()
	self.ui_config = {"uis/views/tips/bossskillwarning_prefab", "BossSkillWarning"}
	self.view_layer = UiLayer.Pop
	self.type = 0
end

function BossSkillWarningView:__delete()
end

function BossSkillWarningView:LoadCallBack()
	self.res = self:FindVariable("Res")

end

function BossSkillWarningView:ReleaseCallBack()
	self.res = nil
end


function BossSkillWarningView:OpenCallBack()
	if nil == self.close_timer and self.type == 0 then
		self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.Close, self), 4)
	end
	self:Flush()
end

function BossSkillWarningView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "branch_fb_type" then
			self.type = v[1]
			if self.close_timer then
				GlobalTimerQuest:CancelQuest(self.close_timer)
				self.close_timer = nil
			end
		end
	end
	local res = "word_boss_dazhao"
	if self.type == DailyTaskFbData.FB_TYPE.STATUE then
		res = "word_boss_kill_tip1"
	elseif self.type == DailyTaskFbData.FB_TYPE.XIXUE then
		res = "word_boss_kill_tip2"
	elseif self.type == DailyTaskFbData.FB_TYPE.SHENZHU then
		res = "word_boss_kill_tip3"
	end
	self.res:SetAsset("uis/views/tips/bossskillwarning_atlas", res)
end

function BossSkillWarningView:CloseCallBack()
	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
	self.type = 0
end