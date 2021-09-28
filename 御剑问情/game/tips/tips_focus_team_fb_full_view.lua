TipsFocusTeamFbFullView = TipsFocusTeamFbFullView or BaseClass(BaseView)

function TipsFocusTeamFbFullView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusTeamFbTips"}
	self.view_layer = UiLayer.Pop
end

function TipsFocusTeamFbFullView:LoadCallBack()
	self:ListenEvent("close_click",
		BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",
		BindTool.Bind(self.GoClick, self))
	self.time = self:FindVariable("time")
end

function TipsFocusTeamFbFullView:ReleaseCallBack()
	self.time = nil
end

function TipsFocusTeamFbFullView:OpenCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusTeamFbFullView:CloseClick()
	self:Close()
end

function TipsFocusTeamFbFullView:GoClick()
	local fb_info = ScoietyData.Instance:GetTeamInfo()
	local team_type = fb_info.team_type or 0
	if team_type == FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND then
		TeamFbData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.TeamTowerDefendInvite)
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team)
	elseif team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_exp)
	elseif team_type == FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB then
		TeamFbData.Instance:SetDefaultChoose(ScoietyData.InviteOpenType.EquipTeamFbNew)
		ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team)
	end
	self:Close()
end

function TipsFocusTeamFbFullView:CloseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TipsFocusTeamFbFullView:OnFlush()

end

function TipsFocusTeamFbFullView:CountDown(elapse_time, total_time)
	self.time:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end