ArenaVictoryView = ArenaVictoryView or BaseClass(BaseView)

function ArenaVictoryView:__init(instance)
	self.ui_config = {"uis/views/arena_prefab","ArenaVictory"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ArenaVictoryView:__delete()

end

function ArenaVictoryView:LoadCallBack()
	self.uplevel = self:FindVariable("uplevel")
	self.guanghui = self:FindVariable("guanghui")
	self.exp = self:FindVariable("exp")

	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
end

function ArenaVictoryView:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.uplevel = nil
	self.guanghui = nil
	self.exp = nil
end

function ArenaVictoryView:OpenCallBack()
	self:Flush()
end

function ArenaVictoryView:OnFlush()
	local result = ArenaData.Instance:GetFightResult()
	local cfg =ConfigManager.Instance:GetAutoConfig("challengefield_auto").other[1]
	local user_vo = GameVoManager.Instance:GetMainRoleVo()
	local reward_exp = (user_vo.level + 50) * cfg.win_add_exp
	local exp = CommonDataManager.ConverNum(reward_exp)
	local reward_guanghui =  cfg.win_add_guanghui
	if result then
		self.uplevel:SetValue("+" .. result.rank_up)
		self.guanghui:SetValue("+" .. reward_guanghui)
		self.exp:SetValue("+" .. exp)
	end
end

function ArenaVictoryView:OnClick()
	self:Close()
	FuBenCtrl.Instance:SendExitFBReq()
end