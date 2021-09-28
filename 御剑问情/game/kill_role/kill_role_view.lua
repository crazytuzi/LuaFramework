KillRoleView = KillRoleView or BaseClass(BaseView)

function KillRoleView:__init(instance)
	self.ui_config = {"uis/views/killroleview_prefab","KillRoleView"}
	self.be_kill_role_vo = {}
	self.close_delay_time = 5
end

function KillRoleView:LoadCallBack()
	self.main_role_list = {
		level = self:FindVariable("MainRoleLevel"),
		name = self:FindVariable("MainRoleName"),
		fight_power = self:FindVariable("MainRoleFightPower"),
		icon = self:FindVariable("MainRolePortraitIcon"),
		iamge = self:FindObj("MainRolePortraitIamge"),
		raw_image = self:FindObj("MainRoleRawPortrait"),
	}

	self.be_kill_role_list = {
		level = self:FindVariable("RoleLevel"),
		name = self:FindVariable("RoleName"),
		fight_power = self:FindVariable("RoleFightPower"),
		icon = self:FindVariable("RolePortraitIcon"),
		iamge = self:FindObj("RolePortraitIamge"),
		raw_image = self:FindObj("RoleRawPortrait"),
	}
end

function KillRoleView:ReleaseCallBack()
	-- 清理变量
	self.main_role_list = {}
	self.be_kill_role_list = {}
	self.be_kill_role_vo = {}
end

function KillRoleView:OpenCallBack()
	self.close_delay_time = 5
	self:Flush()
end

function KillRoleView:CloseCallBack()
	self:RemoveCountDown()
end

function KillRoleView:SetBeKillRoleVo(be_kill_role_vo)
	self.be_kill_role_vo = be_kill_role_vo or {}
end

function KillRoleView:SetMainRoleInfo()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self:SetInfo(game_vo, self.main_role_list)
end

function KillRoleView:SetBekillRoleInfo()
	self:SetInfo(self.be_kill_role_vo, self.be_kill_role_list)
end

function KillRoleView:SetInfo(role_vo, var_list)
	if nil == next(role_vo) then
		self:Close()
		return
	end

	local game_vo = role_vo
	var_list.level:SetValue(game_vo.level)
	var_list.name:SetValue(game_vo.name)
	if nil ~= game_vo.capability then
		var_list.fight_power:SetValue(game_vo.capability + game_vo.other_capability)
	else
		var_list.fight_power:SetValue(game_vo.total_capability)
	end

	 CommonDataManager.SetAvatar(game_vo.role_id, var_list.raw_image, var_list.iamge, var_list.icon, game_vo.sex, PlayerData.Instance:GetRoleBaseProf(game_vo.prof), true)
end

function KillRoleView:SetCloseDelay()
	self:RemoveCountDown()
	self.delay_close = GlobalTimerQuest:AddRunQuest(
		function ()
			self:Close()
		end, self.close_delay_time)
end

function KillRoleView:RemoveCountDown()
	if nil ~= self.delay_close then
		GlobalTimerQuest:CancelQuest(self.delay_close)
		self.delay_close = nil
	end
end

function KillRoleView:OnFlush()
	self:SetMainRoleInfo()
	self:SetBekillRoleInfo()
	self:SetCloseDelay()
end