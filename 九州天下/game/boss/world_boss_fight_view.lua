require("game/boss/world_boss_info_view")

WorldBossFightView = WorldBossFightView or BaseClass(BaseView)

function WorldBossFightView:__init()
	self.ui_config = {"uis/views/bossview","WorldBossFightView"}
	self.view_layer = UiLayer.MainUI
	self.is_safe_area_adapter = true
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
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function WorldBossFightView:CloseCallBack()
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