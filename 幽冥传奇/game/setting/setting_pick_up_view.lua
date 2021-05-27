SettingView = SettingView or BaseClass(BaseView)

function SettingView:PickUpInit()
	self.layout_pick_up_top = self.node_t_list["layout_pick_up_top"]
	self.layout_pick_up_top.node:retain()
	self.layout_pick_up_top.node:removeFromParent()
	self.node_t_list.scroll_index4.node:addChild(self.layout_pick_up_top.node)
	self.layout_pick_up_top.node:release()

	for i = 1, self.PICK_OPTION_COUNT do
		XUI.AddClickEventListener(self.node_t_list["layout_pick_option" .. i].node, BindTool.Bind(self.OnClickPickUpSetting, self, i))
		self.node_t_list["layout_pick_option".. i].lbl_set_name.node:setString(Language.Setting.PickUpOptionNames[i])
	end

	self:InitPickUpData()
	self:RefreshCheckBoxPickUp()
	self.node_t_list["btn_pick_coin"].node:addClickEventListener(BindTool.Bind(self.OnClickPickCoin, self))
	self.node_t_list["btn_pick_equip"].node:addClickEventListener(BindTool.Bind(self.OnClickPickEquip, self))
	self.node_t_list["btn_pick_lv_dan"].node:addClickEventListener(BindTool.Bind(self.OnClickPickLvDan, self))

	self.node_t_list["layout_pick_up"].node:setVisible(true)
end

function SettingView:PickUpDelete()
	-- body
end

-- 挂机设置项
function SettingView:OnClickPickUpSetting(index)
	local img_hook =  self.node_t_list["layout_pick_option" .. index].img_setting_hook1.node

	index = index + 7
	local flag = not img_hook:isVisible()
	img_hook:setVisible(flag)
	self.guaji_set_flag[33 - index] = flag and 1 or 0
	
	local data = bit:b2d(self.guaji_set_flag)
	SettingData.Instance:SetDataByIndex(HOT_KEY.GUAJI_SETTING, data)
	GlobalEventSystem:Fire(SettingEventType.GUAJI_SETTING_CHANGE, index, flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.GUAJI_SETTING, data)
end

function SettingView:PickUpFlush(param_t, index)
	self:RefreshCheckBoxPickUp()
end

function SettingView:RefreshCheckBoxPickUp()
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.GUAJI_SETTING)
	if data ~= nil then
		self.guaji_set_flag = bit:d2b(data)
		for i = 1, self.PICK_OPTION_COUNT do
			self.node_t_list["layout_pick_option"..i].img_setting_hook1.node:setVisible(1 == self.guaji_set_flag[33 - i - 7])
		end
	end
	self.node_t_list["btn_pick_coin"].node:setTitleText(Language.Setting.PickUpMoneyList[self.money_select + 1])
	self.node_t_list["btn_pick_equip"].node:setTitleText(self.pick_eqlv_data[self.pick_eq_select + 1])
	self.node_t_list["btn_pick_lv_dan"].node:setTitleText(Language.Setting.PickLevelDanList[self.level_dan_select + 1])

end

function SettingView:OnClickPickCoin()
	self.select_setting_view:SetDataAndOpen(Language.Setting.PickUpMoneyList, function (index)
		self.money_select = index
		self.node_t_list["btn_pick_coin"].node:setTitleText(Language.Setting.PickUpMoneyList[self.money_select + 1])
	end)
end

function SettingView:OnClickPickEquip()
	self.select_setting_view:SetDataAndOpen(self.pick_eqlv_data, function (index)
		self.pick_eq_select = index
		self.node_t_list["btn_pick_equip"].node:setTitleText(self.pick_eqlv_data[self.pick_eq_select + 1])
	end)
end

function SettingView:OnClickPickLvDan()
	self.select_setting_view:SetDataAndOpen(Language.Setting.PickLevelDanList, function (index)
		self.level_dan_select = index
		self.node_t_list["btn_pick_lv_dan"].node:setTitleText(Language.Setting.PickLevelDanList[self.level_dan_select + 1])
	end)
end
