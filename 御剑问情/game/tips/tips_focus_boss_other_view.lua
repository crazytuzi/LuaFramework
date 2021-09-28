TipsFocusBossOtherView = TipsFocusBossOtherView or BaseClass(BaseView)

function TipsFocusBossOtherView:__init()
	self.ui_config = {"uis/views/tips/focustips_prefab", "FocusBossTips"}
	self.view_layer = UiLayer.Pop
	self.prefs_key = nil
end

function TipsFocusBossOtherView:LoadCallBack()
	self:ListenEvent("close_click",
		BindTool.Bind(self.CloseClick, self))
	self:ListenEvent("go_click",
		BindTool.Bind(self.GoClick, self))

	self.time = self:FindVariable("time")
	self.boss_icon = self:FindVariable("boss_icon")
	self.boss_desc = self:FindVariable("boss_desc")
	self.active = self:FindVariable("toggle_active")
	self.no_tip_toggle = self:FindObj("no_tip_toggle")
	self.show_icon = self:FindVariable("show_icon")
	self.title_image = self:FindVariable("title_image")
	self.bg_image = self:FindVariable("bg_image")
	self.boss_level = self:FindVariable("boss_level")
end

function TipsFocusBossOtherView:ReleaseCallBack()
	self.time = nil
	self.boss_icon = nil
	self.boss_desc = nil
	self.no_tip_toggle = nil
	self.active = nil
	self.show_icon = nil
	self.title_image = nil
	self.bg_image = nil
	self.close_callback = nil
	self.boss_level = nil
end

function TipsFocusBossOtherView:OpenCallBack()
	self.no_tip_toggle.toggle.isOn = false
	self:Flush()
end

function TipsFocusBossOtherView:CloseClick()
	self:Close()
end

function TipsFocusBossOtherView:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function TipsFocusBossOtherView:GetToggleStats()
	if self.no_tip_toggle then
		return self.no_tip_toggle.toggle.isOn or false
	end
	return false
end

function TipsFocusBossOtherView:GoClick()
	if self.ok_call_back then
		self.ok_call_back()
	end
	-- ViewManager.Instance:CloseAll()
	self:Close()
end

function TipsFocusBossOtherView:CloseCallBack()
	self.boss_id = nil
	self.ok_call_back = nil
	self.prefs_key = nil
	self.boss_type = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	local cd = self.no_tip_toggle.toggle.isOn and 7200 or 1800
	if self.close_callback then
		self.close_callback(cd)
		self.close_callback = nil
	end

	if self.no_tip_toggle.toggle.isOn then
		self.no_tip_toggle.toggle.isOn = false
	end
end

function TipsFocusBossOtherView:SetData(boss_id, boss_type, ok_callback)
	self.boss_id = boss_id
	self.ok_call_back = ok_callback
	self.boss_type = boss_type or 1
	self:Flush()
end
function TipsFocusBossOtherView:OnFlush()
	self:SetPanelValue()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time:SetValue(15)
	self.count_down = CountDown.Instance:AddCountDown(15, 1, BindTool.Bind(self.CountDown, self))
end

function TipsFocusBossOtherView:CountDown(elapse_time, total_time)
	self.time:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self:Close()
	end
end

function TipsFocusBossOtherView:SetPanelValue()
	if nil ~= self.boss_id then
		local bundle_0, asset_0 = ResPath.GetFocusBossImage(0,TIP_COLOR_IMAGE[self.boss_type])
		self.bg_image:SetAsset(bundle_0, asset_0)
		local bundle_1, asset_1 = ResPath.GetFocusBossImage(1,TIP_COLOR_TITLE[self.boss_type])
		self.title_image:SetAsset(bundle_1, asset_1)
	end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
	if monster_cfg then
		local bundle, asset = nil, nil
		bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
		self.boss_icon:SetAsset(bundle, asset)
		local des = Language.Boss.BossFocusType[self.boss_type] .. Language.Boss.BossFocusDesc1
		self.boss_desc:SetValue(des)
		self.boss_level:SetValue(monster_cfg.level)
		self.show_icon:SetValue(true)
	else
		self.show_icon:SetValue(false)
	end
	if self.boss_type == BOSS_ENTER_TYPE.CROSS_SHENWU_BOSS or self.boss_type == BOSS_ENTER_TYPE.CROSS_TIANJIANG_BOSS or self.boss_type == BOSS_ENTER_TYPE.KUA_FU_BOSS then
		self.active:SetValue(true)
	else
		self.active:SetValue(false)
	end

end