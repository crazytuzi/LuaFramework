require("game/boss/world_boss_info_view")

WorldBossFightView = WorldBossFightView or BaseClass(BaseView)

function WorldBossFightView:__init()
	self.ui_config = {"uis/views/bossview_prefab","WorldBossFightView"}
	self.view_layer = UiLayer.MainUI
	self.is_safe_area_adapter = true

	self.is_open_info_view = false
end

function WorldBossFightView:__delete()

end

function WorldBossFightView:ReleaseCallBack()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
	self:RemoveDelayTime()

	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	self.show_panel = nil
end

function WorldBossFightView:LoadCallBack()
	self.info_view = WorldBossInfoView.New(self:FindObj("InfoPanel"))
	self.show_panel = self:FindVariable("ShowPanel")
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush()
end

function WorldBossFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function WorldBossFightView:OpenCallBack()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self.main_role_revive = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind(self.MainRoleRevive, self))
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function WorldBossFightView:CloseCallBack()
	if self.main_role_revive then
		GlobalEventSystem:UnBind(self.main_role_revive)
		self.main_role_revive = nil
	end
	self:RemoveDelayTime()
end

function WorldBossFightView:MainRoleRevive()
	self:RemoveDelayTime()
	--钻石复活才自动挂机
	if ReviveData.Instance:GetLastReviveType() == REALIVE_TYPE.REALIVE_TYPE_HERE_ICON then
		-- 延迟是因为主角复活后有可能坐标还没有reset
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto) end, 0.5)
	end
end

function WorldBossFightView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function WorldBossFightView:PortraitToggleChange(state)
	self.show_panel:SetValue(state)
end

function WorldBossFightView:OnFlush()
	self.info_view:Flush()
end

function WorldBossFightView:SetCanRoll(index)
	if self.info_view then
		self.info_view:SetCanRoll(index)
	end
end

function WorldBossFightView:SetRollResult(point, index)
	if self.info_view then
		self.info_view:SetRollResult(point, index)
	end
end

function WorldBossFightView:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	if self.info_view then
		self.info_view:SetRollTopPointInfo(boss_id, hudun_index, top_roll_point, top_roll_name)
	end
end