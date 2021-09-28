ArenaLoseView = ArenaLoseView or BaseClass(BaseView)

function ArenaLoseView:__init(instance)
	self.ui_config = {"uis/views/arena_prefab","ArenaLose"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ArenaLoseView:__delete()

end

function ArenaLoseView:LoadCallBack()
	self.uplevel = self:FindVariable("uplevel")
	self.guanghui = self:FindVariable("guanghui")
	self.exp = self:FindVariable("exp")

	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
end

function ArenaLoseView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.uplevel = nil
	self.guanghui = nil
	self.exp = nil
end

function ArenaLoseView:OpenCallBack()
	self:Flush()
end

function ArenaLoseView:OnFlush()
	-- if self.timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- end
	-- self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:OnClick() end, 5)
	local result = ArenaData.Instance:GetFightResult()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local user_vo = GameVoManager.Instance:GetMainRoleVo()
	local reward_exp = (user_vo.level + 50) * cfg.lose_add_exp
	local reward_guanghui =  cfg.lose_add_guanghui
	if result then
		self.uplevel:SetValue("+" .. result.rank_up)
		self.guanghui:SetValue("+" .. reward_guanghui)
		self.exp:SetValue("+" .. reward_exp)
	end
end

function ArenaLoseView:OnClick()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end