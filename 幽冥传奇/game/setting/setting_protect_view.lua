SettingView = SettingView or BaseClass(BaseView)

function SettingView:ProtectInit()
	self.layout_guaji_top = self.node_tree.layout_protect_set.layout_guaji_top
	self.layout_guaji_down = self.node_tree.layout_protect_set.layout_guaji_down

	local path_ball = ResPath.GetSetting("bg_3")
	local path_progress = ResPath.GetSetting("prog_104")
	local path_progress_bg = ResPath.GetSetting("prog_104_progress")

	local ph_hp_auto = self.ph_list.ph_hp_auto
	self.slider_hp = XUI.CreateSlider(ph_hp_auto.x, ph_hp_auto.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_hp:setMaxPercent(99)
	self.layout_guaji_top.node:addChild(self.slider_hp, 100)
	self.slider_hp:addSliderEventListener(BindTool.Bind(self.OnHpSliderEvent, self))

	local ph_mp_auto = self.ph_list.ph_mp_auto
	self.slider_mp = XUI.CreateSlider(ph_mp_auto.x, ph_mp_auto.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_mp:setMaxPercent(99)
	self.layout_guaji_top.node:addChild(self.slider_mp, 100)
	self.slider_mp:addSliderEventListener(BindTool.Bind(self.OnMPSliderEvent, self))

	local ph_hp_auto_run = self.ph_list.ph_hp_auto_run
	self.slider_hp_run = XUI.CreateSlider(ph_hp_auto_run.x, ph_hp_auto_run.y, path_ball, path_progress_bg, path_progress, true)
	self.slider_hp_run:setMaxPercent(99)
	self.layout_guaji_top.node:addChild(self.slider_hp_run, 100)
	self.slider_hp_run:addSliderEventListener(BindTool.Bind(self.OnHPRunSliderEvent, self))

	for i = 1, self.GJ_OPTION_COUNT do
		XUI.AddClickEventListener(self.node_t_list["layout_gj_option" .. i].node, BindTool.Bind(self.OnClickGuijiSetting, self, i))
		self.node_t_list["layout_gj_option".. i].lbl_set_name.node:setString(Language.Setting.GjOptionNames[i])
	end

	self:RefreshCheckBoxGuaJi()
	self.node_t_list.btn_healing_hp.node:addClickEventListener(BindTool.Bind(self.OnClickHealingHp, self))
	self.node_t_list.btn_healing_mp.node:addClickEventListener(BindTool.Bind(self.OnClickHealingMp, self))
	self.node_t_list.btn_delivery_stone.node:addClickEventListener(BindTool.Bind(self.OnClickDeliveryStone, self))
end

function SettingView:ProtectDelete()
	-- body
end

-- 挂机设置项
function SettingView:OnClickGuijiSetting(index)
	local img_hook =  self.node_t_list["layout_gj_option" .. index].img_setting_hook1.node

	local flag = not img_hook:isVisible()
	img_hook:setVisible(flag)
	self.guaji_set_flag[33 - index] = flag and 1 or 0
	
	local data = bit:b2d(self.guaji_set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.GUAJI_SETTING, data)
	GlobalEventSystem:Fire(SettingEventType.GUAJI_SETTING_CHANGE, index, flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.GUAJI_SETTING, data)
end

function SettingView:OnHpSliderEvent(sender, percent)
	self.hp_percent = math.floor(percent)
	self.node_t_list.lbl_hp_per.node:setString(self.hp_percent .. "%")
end

function SettingView:OnMPSliderEvent(sender, percent)
	self.mp_percent = math.floor(percent)
	self.node_t_list.lbl_mp_per.node:setString(self.mp_percent .. "%")
end

function SettingView:OnHPRunSliderEvent(sender, percent)
	self.hp_run_percent = math.floor(percent)
	self.node_t_list.lbl_hprun_per.node:setString(self.hp_run_percent .. "%")
end

function SettingView:ProtectOnFlush(param_t, index)
	self:RefreshCheckBoxGuaJi()
end

function SettingView:RefreshCheckBoxGuaJi()
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	if data ~= nil then
		self.guaji_set_flag = bit:d2b(data)
		for i = 1, self.GJ_OPTION_COUNT do
			self.node_t_list["layout_gj_option"..i].img_setting_hook1.node:setVisible(1 == self.guaji_set_flag[33 - i])
		end
	end

	self.slider_hp:setPercent(self.hp_percent)
	self.node_t_list.lbl_hp_per.node:setString(self.hp_percent .. "%")
	self.slider_mp:setPercent(self.mp_percent)
	self.node_t_list.lbl_mp_per.node:setString(self.mp_percent .. "%")
	self.slider_hp_run:setPercent(self.hp_run_percent)
	self.node_t_list.lbl_hprun_per.node:setString(self.hp_run_percent .. "%")

	self.node_t_list.btn_healing_hp.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DRUG_T[self.hp_select + 1]))
	self.node_t_list.btn_healing_mp.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DRUG_T[self.mp_select + 1]))
	self.node_t_list.btn_delivery_stone.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DELIVERY_T[self.run_select + 1]))
end

function SettingView:OnClickHealingHp()
	local data = {}
	for k,v in pairs(SettingData.DRUG_T) do
		table.insert(data, ItemData.Instance:GetItemName(v))
	end
	self.select_setting_view:SetDataAndOpen(data, function (index)
		if ItemData.Instance:CheckItemIsLimitUseByIdAndPlayTip(SettingData.DRUG_T[index + 1]) then return end
		self.hp_select = index
		self.node_t_list.btn_healing_hp.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DRUG_T[self.hp_select + 1]))
	end)
end

function SettingView:OnClickHealingMp()
	local data = {}
	for k,v in pairs(SettingData.DRUG_T) do
		table.insert(data, ItemData.Instance:GetItemName(v))
	end
	self.select_setting_view:SetDataAndOpen(data, function (index)
		if ItemData.Instance:CheckItemIsLimitUseByIdAndPlayTip(SettingData.DRUG_T[index + 1]) then return end
		self.mp_select = index
		self.node_t_list.btn_healing_mp.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DRUG_T[self.mp_select + 1]))
	end)
end

function SettingView:OnClickDeliveryStone()
	local data = {}
	for k,v in pairs(SettingData.DELIVERY_T) do
		table.insert(data, ItemData.Instance:GetItemName(v))
	end
	self.select_setting_view:SetDataAndOpen(data, function (index)
		self.run_select = index
		self.node_t_list.btn_delivery_stone.node:setTitleText(ItemData.Instance:GetItemName(SettingData.DELIVERY_T[self.run_select + 1]))
	end)
end
