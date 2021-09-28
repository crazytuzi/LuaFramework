KaifuActivityPanelSixteen = KaifuActivityPanelSixteen or BaseClass(BaseRender)

function KaifuActivityPanelSixteen:__init()
	self.left_day = self:FindVariable("LeftDay")
	self.left_hour = self:FindVariable("LeftHour")
	self.left_minute = self:FindVariable("LeftMinute")
	self.left_second = self:FindVariable("LeftSecond")
	self.model_display = self:FindObj("ModelDisplay")		-- 3D模型显示
	self.model_name = self:FindVariable("modelName")

	self:ListenEvent("ClickChange", BindTool.Bind(self.ClickChange, self))
end

function KaifuActivityPanelSixteen:__delete()
	if self.model then
		self.model:ClearModel()
		self.model:DeleteMe()
		self.model = nil
	end
end

function KaifuActivityPanelSixteen:OpenCallBack()
    self:InitData()
end

function KaifuActivityPanelSixteen:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KaifuActivityPanelSixteen:InitData()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	self:SetTime(time_tab)

	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(rareChange_time, 1, function ()
			time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
            self:SetTime(time_tab)
        end)

	self:FlushModel()
end

function KaifuActivityPanelSixteen:SetTime(time_tab)
	self.left_day:SetValue(time_tab.day)
	if time_tab.hour < 10 then
		self.left_hour:SetValue("0" .. time_tab.hour) 
	else
		self.left_hour:SetValue(time_tab.hour) 
	end
	if time_tab.min < 10 then
		self.left_minute:SetValue("0" .. time_tab.min) 
	else
		self.left_minute:SetValue(time_tab.min) 
	end
	if time_tab.s < 10 then
		self.left_second:SetValue("0" .. time_tab.s) 
	else
		self.left_second:SetValue(time_tab.s) 
	end
end

function KaifuActivityPanelSixteen:OnFlush()

end

function KaifuActivityPanelSixteen:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	local cfg = TreasureData.Instance:GetSingleXunBaoZhenXiCfg(11032)
	self.model_name:SetValue(cfg.item_name)
	local asset, bundle = ResPath.GetGoddessModel(11032)

	self.model:SetMainAsset(asset, bundle, complete_callback)
	self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.RARE_CHANGE], tonumber(bundle), DISPLAY_PANEL.FULL_PANEL)
end

function KaifuActivityPanelSixteen:ClickChange()
	self:CloseCallBack()
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.Treasure,TabIndex.treasure_exchange)
end