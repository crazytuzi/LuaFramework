LoginGift7View = LoginGift7View or BaseClass(BaseView)

local DISPLAYNAME = {
	[100101] = "login_gift_seven_day_wuqi_panel_3",
	[100201] = "login_gift_seven_day_wuqi_panel_2",
}
local SMALEDISPLAYNAME = {
	[100101] = "seven_day_wuqi_model_panel_1",
	[100201] = "seven_day_wuqi_model_panel_2",
	[100301] = "seven_day_wuqi_model_panel_3",
	[100401] = "seven_day_wuqi_model_panel_4",
}

local GODDESS_TOGGLE_INDEX2 = 2		-- 女神标签2
local GODDESS_TOGGLE_INDEX = 4		-- 女神标签

function LoginGift7View:__init()
	self.ui_config = {"uis/views/7logingift_prefab","7LoginGift"}
	self.pre_back_ground_bundle = "uis/rawimages/zero_gift_bg_02"
	self.pre_back_ground_asset = "zero_gift_bg_02.png"

	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_list = {}
	self.login_bt_list = {}
end

function LoginGift7View:__delete()

end

function LoginGift7View:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.LoginGift7View)
	end

	for i=1,6 do
		if self.item_list[i] ~= nil then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end

	for i=1,7 do
		if self.login_bt_list[i] ~= nil then
			self.login_bt_list[i]:DeleteMe()
			self.login_bt_list[i] = nil
		end

		if nil ~= self["model" .. i] then
			self["model" .. i]:DeleteMe()
			self["model" .. i] = nil
		end
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if nil ~= self.stone_model then
		self.stone_model:DeleteMe()
		self.stone_model = nil
	end

	-- 清理变量和对象
	self.login_daycount = nil
	self.get_num = nil
	self.receive_name = nil
	self.is_model = nil
	self.display_image = nil
	self.word_bg = nil
	self.word_item_desc = nil
	self.show_block = nil
	self.show_item_eff = nil
	self.model_bg_effect = nil
	self.show_partical_eff = nil
	self.show_normal_display = nil
	self.button_click = nil

	self.day_gitf_list = nil
	self.login_bt_list = nil
	self.gift_event = nil
	self.icon_list = nil
	for i=1,7 do
		self["display" .. i] = nil
		self["desc" .. i] = nil
	end

	self.receive_bt_obj = nil
	self.receive_bt = nil
	self.display = nil
	self.stone_display = nil
	self.reward_btn = nil
	self.btn_close = nil
	self.equip_bg_effect_obj = nil
	self.receive_bt_text = nil
	self.show_equip_effect = nil
end

function LoginGift7View:LoadCallBack()
	self.login_daycount = self:FindVariable("login_daycount")
	self.get_num = self:FindVariable("get_num")
	self.receive_name = self:FindVariable("receive_name")
	self.is_model = self:FindVariable("is_model")
	self.display_image = self:FindVariable("display_image")
	self.word_bg = self:FindVariable("word_bg")
	self.word_item_desc = self:FindVariable("word_item_desc")
	self.show_block = self:FindVariable("show_block")
	self.show_item_eff = self:FindVariable("ShowEffect")
	self.model_bg_effect = self:FindObj("EffectModel")
	self.show_partical_eff = self:FindVariable("show_partical_eff")
	self.show_normal_display = self:FindVariable("show_normal_display")
	self.show_equip_effect = self:FindVariable("ShowEquipEffect")
	self.button_click = self:FindVariable("Touch")

	self:ListenEvent("Closen", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("ReceiveAward", BindTool.Bind(self.ReceiveAward,self))

	for i=1,7 do
		self:ListenEvent("Event_"..i, BindTool.Bind2(self.ToggleEvent,self,i))
	end

	self.item_list = {}
	for i=1,6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	end

	self.cur_chosen_gift = 0
	self.gift_event = {}
	self.login_bt_list = {}
	self.day_gitf_list = {}
	self.icon_list = {}
	for i=1,7 do
		self.day_gitf_list[i] = self:FindVariable("day_gitf0"..i)
		self.login_bt_list[i] = LoginButtonItem.New(self:FindObj("GiftEvent"..i))
		self.gift_event[i] = self:FindObj("GiftEvent"..i)
		self.icon_list[i] = self:FindVariable("icon_" .. i)

		self["display" .. i] = self:FindObj("Display" .. i)
		self["model" .. i] = RoleModel.New("seven_day_mount_model_panel")
		self["model" .. i]:SetDisplay(self["display" .. i].ui3d_display)
		self["desc" .. i] = self:FindVariable("desc_" .. i)
	end

	self.receive_bt_obj = self:FindObj("ReceiveBt")
	self.receive_bt_text = self:FindObj("ReceiveBtText")
	-- self.bt_text = self:FindVariable("RecieveBtText")
	self.receive_bt = self:FindVariable("ReceiveButton")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("login_gift_seven_day_mount_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.stone_display = self:FindObj("DisplayStone")
	self.stone_model = RoleModel.New("login_gift_seven_day_stone_panel")
	self.stone_model:SetDisplay(self.stone_display.ui3d_display)

	--需要引导的按钮
	self.reward_btn = self:FindObj("RewardBtn")
	self.btn_close = self:FindObj("BtnClose")

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.LoginGift7View, BindTool.Bind(self.GetUiCallBack, self))
end

function LoginGift7View:SetModelDisplay(bundle, asset, display_type, model_type)

	if display_type == 1 then
		self.is_model:SetValue(false)
		self.display_image:SetAsset(bundle,asset)
	elseif display_type == 0 then
		self.is_model:SetValue(true)
		self.model:ClearModel()
		--不显示装备特效
		self.show_equip_effect:SetValue(false)
		--强制清除足迹
		local num = self.display.transform.childCount
		for i=1,num-1,1 do
			 GameObject.Destroy(self.model_display:GetChild(i))
		end
		self.model:SetFootResid(nil)
		if model_type == DISPLAY_TYPE.FOOTPRINT then
			self.model:SetPanelName("login_gift_seven_day_foot_panel")
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetFootResid(asset)
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		elseif model_type == DISPLAY_TYPE.XIAN_NV then
			self.model:SetPanelName("login_gift_seven_day_goddess_panel")
			self.model:SetMainAsset(bundle,asset)
			self.model:SetTrigger("show_idle_1")
		elseif model_type == DISPLAY_TYPE.MOUNT then
			self.model:SetPanelName("login_gift_seven_day_mount_panel")
			self.model:SetMainAsset(bundle,asset)
			self.model:SetTrigger("rest")
		elseif model_type == DISPLAY_TYPE.WING then
			self.model:SetPanelName("login_gift_seven_day_wing_panel")
			self.model:SetMainAsset(bundle,asset)
		elseif model_type == DISPLAY_TYPE.WEAPON then
			-- self.model:SetPanelName(self:SetSpecialModle(asset))
			-- self.model:SetMainAsset(bundle, asset, function ()
			-- 	self.model:SetBool("action", true)
			-- end)
			self.model:SetPanelName(self:SetSpecialModle(asset))
			self.model:SetMainAsset(bundle,asset)
		elseif model_type == DISPLAY_TYPE.GATHER then
			self.show_equip_effect:SetValue(true)
			self.model:SetPanelName("login_gift_seven_day_shenzhuang_panel")
			self.model:SetMainAsset(bundle,asset)
		elseif model_type == 0 then
			self.model:SetPanelName("login_gift_seven_day_stone_panel")
			if self.cur_chosen_gift == 6 then
				self.stone_model:SetMainAsset(bundle, asset)
			else
				self.model:SetMainAsset(bundle,asset)
			end
		end
	end
	self.show_normal_display:SetValue(self.cur_chosen_gift == 6)
	if model_type ~= DISPLAY_TYPE.FOOTPRINT then
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	end
end

function LoginGift7View:OpenCallBack()
	self.cur_chosen_gift = LoginGift7Data.Instance:GetGiftInfo().account_total_login_daycount
	if self.cur_chosen_gift > 7 then
		self.cur_chosen_gift = 7
	end
	-- 从女神面板跳转过来
	if self:GetShowIndex() == TabIndex.seven_login_goddess then
		self.cur_chosen_gift = GODDESS_TOGGLE_INDEX
	end

	if self:GetShowIndex() == TabIndex.seven_login_goddess_2 then
		self.cur_chosen_gift = GODDESS_TOGGLE_INDEX2
	end
	self.temp_day = self.cur_chosen_gift

	for i=1,self.cur_chosen_gift do
		self:FlushRewardState(i)
	end

	for i=1,7 do
		self.login_bt_list[self.cur_chosen_gift]:ShowHighLight(false)
	end

	if nil ~= self.gift_event[self.cur_chosen_gift] then
		self.gift_event[self.cur_chosen_gift].toggle.isOn = true
		self.login_bt_list[self.cur_chosen_gift]:ShowHighLight(true)
	end

	self.login_daycount:SetValue(self.cur_chosen_gift)
	self.get_num:SetValue(LoginGift7Data.Instance:GetGiftRewardByDay(self.cur_chosen_gift))
	local gift_data = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item

	self.show_partical_eff:SetValue(true)

	if self.cur_chosen_gift == 7 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", gift_data.show_item)
		bundle, asset = ResPath.GetWeaponShowModel("100" .. main_role_vo.prof .. num_str)
	end

	self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)

	local login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	local logingift7_cfg = LoginGift7Data.Instance:GetGiftRewardCfg()
	local data = {}
	for i=1,7 do
		data = LoginGift7Data.Instance:GetDataByDay(i)
		self.day_gitf_list[i]:SetValue(data.reward_text)
		if login_day_list[i] == 1 then
			self.login_bt_list[i]:ShowRedPoint(true)
		else
			self.login_bt_list[i]:ShowRedPoint(false)
		end

		local bundle, asset = ResPath.GetSevenDayGift(data.day_picture)
		self.icon_list[i]:SetAsset(bundle, asset)
		self["desc" .. i]:SetValue(data.reward_text)
		local cfg = {}
		local gift_data = LoginGift7Data.Instance:GetDataByDay(i)
		if i == 7 then
			cfg = LoginGift7Data.Instance:GetWeaponTransform()
		else
			cfg.position = Vector3(logingift7_cfg[i].position_x, logingift7_cfg[i].position_y, logingift7_cfg[i].position_z)
			cfg.rotation = Vector3(1, 1, 1)
			cfg.scale = Vector3(gift_data.scale, gift_data.scale, gift_data.scale)
		end
		self["model" .. i]:SetTransform(cfg)
	end

	local reward_list = LoginGift7Data.Instance:GetRewardList(self.cur_chosen_gift)
	local gift_item_id = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id
	for i=1,6 do
		if reward_list[i] then
			if i == 1 then
				self.item_list[i]:SetActivityEffect()
			end
			self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
			if i == 1 then
				self.item_list[i]:IsDestoryActivityEffect(false)
				self.item_list[i]:SetActivityEffect()
			else
				self.item_list[i]:IsDestoryActivityEffect(true)
				self.item_list[i]:SetActivityEffect()
			end
		else
			self.item_list[i]:SetParentActive(false)
		end
	end

	if self:CurDayIsReceive(self.cur_chosen_gift) then
		self:SetToggleNextOn()
	else
		self.gift_event[self.cur_chosen_gift].toggle.isOn = true
		self.login_bt_list[self.cur_chosen_gift]:ShowHighLight(true)
	end

	self.receive_name:SetValue(LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).show_dec1)

	local bundle, asset = ResPath.GetSevenDayGift("word_" .. self.cur_chosen_gift)
	self.word_bg:SetAsset(bundle, asset)

	local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. self.cur_chosen_gift)
	self.word_item_desc:SetAsset(bundle, asset)

	if gift_data.can_spin then
		self.show_block:SetValue(gift_data.can_spin == 0)
	end

	self.show_item_eff:SetValue(self.cur_chosen_gift ~= 6)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	for i = 1, 7 do
		local gift_data = LoginGift7Data.Instance:GetDataByDay(i)
		local bundle = gift_data.path
		local asset = gift_data.show_item
		local is_ignore_cfg = false

		if i == 7 then
			local num_str = string.format("%02d", gift_data.show_item)
			bundle, asset = ResPath.GetWeaponShowModel("100" .. main_role_vo.prof .. num_str)
		end

		local scale = gift_data.scale
		if gift_data.show_model == DISPLAY_TYPE.FOOTPRINT then
			local main_role = Scene.Instance:GetMainRole()
			self["model" .. i]:SetPanelName("seven_day_foot_model_panel")
			self["model" .. i]:SetRoleResid(main_role:GetRoleResId())
			self["model" .. i]:SetFootResid(asset)
			self["model" .. i]:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		elseif gift_data.show_model == DISPLAY_TYPE.XIAN_NV then
			if i == 2 then
				self["model" .. i]:SetPanelName("seven_day_goddess_model_panel1")
			elseif i == 4 then
				self["model" .. i]:SetPanelName("seven_day_goddess_model_panel2")
			end
			self["model" .. i]:SetMainAsset(bundle,asset)
			self["model" .. i]:SetTrigger("show_idle_1")
		elseif gift_data.show_model == DISPLAY_TYPE.MOUNT then
			self["model" .. i]:SetPanelName("seven_day_mount_model_panel")
			self["model" .. i]:SetMainAsset(bundle,asset)
			self["model" .. i]:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			--self["model" .. i]:SetTrigger("rest")
		elseif gift_data.show_model == DISPLAY_TYPE.WING then
			self["model" .. i]:SetPanelName("seven_day_wing_model_panel")
			self["model" .. i]:SetMainAsset(bundle,asset)
		elseif gift_data.show_model == DISPLAY_TYPE.WEAPON then
			self["model" .. i]:SetPanelName(self:SetSpecialModle(asset, "smale"))
			self["model" .. i]:SetMainAsset(bundle, asset, function ()
				self["model" .. i]:SetBool("action", true)
			end)
		elseif gift_data.show_model == DISPLAY_TYPE.GATHER then
			self["model" .. i]:SetPanelName("seven_day_shenzhuang_model_panel")
			self["model" .. i]:SetMainAsset(bundle,asset)
		else
			self["model" .. i]:SetPanelName("seven_day_stone_model_panel")
			self["model" .. i]:SetMainAsset(bundle,asset)
		end
	end
end

function LoginGift7View:CloseCallBack()
	self.cur_chosen_gift = 1
end

function LoginGift7View:CloseView()
	self:Close()
end

function LoginGift7View:FlushRewardState(fecth_day)
	local reward_id = fecth_day
	if reward_id == 0 then
		reward_id = 1
	end

	if self:CurDayIsReceive(reward_id) then
		self.receive_bt_obj.grayscale.GrayScale = 255
		self.receive_bt_text.grayscale.GrayScale = 255
		self.receive_bt_obj.button.interactable = false
		
		--self.receive_bt:SetAsset("uis/images_atlas", "Button_7Login01")
		if fecth_day > 0 then
			self.login_bt_list[fecth_day]:ShowGotGift(true)
			self.login_bt_list[fecth_day]:ShowRedPoint(false)
		end
		-- 设置已领取的值为2
		LoginGift7Data.Instance:SetLoginDay(reward_id,2)
	else
		self.receive_bt_obj.grayscale.GrayScale = 0
		self.receive_bt_text.grayscale.GrayScale = 0
		self.receive_bt_obj.button.interactable = true

		--self.receive_bt:SetAsset("uis/images_atlas", "Button_7Login")
	end
end

function LoginGift7View:ReceiveAward()
	if not self:CurDayIsReceive(self.cur_chosen_gift) then
		self.temp_day = self.cur_chosen_gift
		LoginGift7Ctrl.Instance:SendSevenDayLoginRewardReq(self.cur_chosen_gift)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LoginDayNotFull)
	end
end

function LoginGift7View:ToggleEvent(index)
	if index ~= GODDESS_TOGGLE_INDEX then
		self:ShowIndex()
	end
	self.receive_name:SetValue(LoginGift7Data.Instance:GetDataByDay(index).show_dec1)
	self.cur_chosen_gift = index
	local reward_list = LoginGift7Data.Instance:GetRewardList(index)
	local gift_item_id = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id

	for i=1,6 do
		if reward_list[i] then
			self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
		else
			self.item_list[i]:SetParentActive(false)
		end
	end
	local gift_data = LoginGift7Data.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item
	if index == 7 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local num_str = string.format("%02d", gift_data.show_item)
		bundle, asset = ResPath.GetWeaponShowModel("100" .. main_role_vo.prof .. num_str)
	end
	if self.button_click ~= nil and self.button_click ~= index then 
       self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)
	end
	self:FlushRewardState(index)
	self.login_daycount:SetValue(index)
	self.get_num:SetValue(LoginGift7Data.Instance:GetGiftRewardByDay(index))

	local bundle, asset = ResPath.GetSevenDayGift("word_" .. index)
	self.word_bg:SetAsset(bundle, asset)

	local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. index)
	self.word_item_desc:SetAsset(bundle, asset)

	--是否可旋转
	if gift_data.can_spin then
		self.show_block:SetValue(gift_data.can_spin == 0)
	end

	self.show_item_eff:SetValue(index ~= 6)
	self.show_partical_eff:SetValue(true)
	for i=1,7 do
		if i ~= index then
			self.login_bt_list[i]:ShowHighLight(false)
		else
			self.login_bt_list[i]:ShowHighLight(true)
		end
	end
	self.button_click = index
end

function LoginGift7View:OnFlush()
	self:FlushRewardState(self.temp_day)
	self:FlushMainUIShow()
	self:SetToggleNextOn()
end

function LoginGift7View:IsShowRedpt()
	local  login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	for i=1,7 do
		if login_day_list[i] == 1 then
			return true
		end
	end

	return false
end

function LoginGift7View:IsReceiveAll()
	local  login_day_list = LoginGift7Data.Instance:GetLoginDayList()
	for i=1,7 do
		if login_day_list[i] ~= 2 then
			return
		end
	end
	LoginGift7Data.Instance:SetIsAllReceive(true)
end

function LoginGift7View:SetToggleNextOn()
	local login_day_list = LoginGift7Data.Instance:GetLoginDayList()

	local now_show_index = self:GetShowIndex()
	if nil ~= now_show_index and now_show_index == TabIndex.seven_login_goddess then
		self.gift_event[GODDESS_TOGGLE_INDEX].toggle.isOn = true
		self.login_bt_list[GODDESS_TOGGLE_INDEX]:ShowHighLight(true)
		self:ToggleEvent(GODDESS_TOGGLE_INDEX)
		return
	end

	if nil ~= now_show_index and now_show_index == TabIndex.seven_login_goddess_2 then
		self.gift_event[GODDESS_TOGGLE_INDEX2].toggle.isOn = true
		self.login_bt_list[GODDESS_TOGGLE_INDEX2]:ShowHighLight(true)
		self:ToggleEvent(GODDESS_TOGGLE_INDEX2)
		return
	end

	for i=1,7 do
		if LoginGift7Data.Instance:IsCanReceive(i) then
			self.gift_event[i].toggle.isOn = true
			self.login_bt_list[i]:ShowHighLight(true)
			self:ToggleEvent(i)
			return
		end
	end
end

function LoginGift7View:FlushMainUIShow()
	-- 判断是否显示红点
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_RED_POINT, MainUIData.RemindingName.Seven_Login_Redpt, self:IsShowRedpt())

	-- 判断是否领取全部奖励
	self:IsReceiveAll()
end

function LoginGift7View:CurDayIsReceive(day)
	local cur_day = day
	local is_reward = LoginGift7Data.Instance:GetLoginRewardFlag(cur_day)
	return is_reward
end

function LoginGift7View:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function LoginGift7View:SetSpecialModle(modle_id, model_type)
	local display_name = model_type == nil and "login_gift_seven_day_wuqi_panel" or "seven_day_wuqi_model_panel"
	local display_list = model_type == nil and DISPLAYNAME or SMALEDISPLAYNAME
	local id = tonumber(modle_id)
	for k,v in pairs(display_list) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

---------------------------------------------------------------------------- 每日奖励按钮类
LoginButtonItem = LoginButtonItem or BaseClass(BaseCell)

function LoginButtonItem:__init()
	self.got_gift = self:FindObj("GotGift")
	self.red_point = self:FindObj("RedPoint")
	self.is_high_light = self:FindVariable("is_high_light")
end

function LoginButtonItem:ShowGotGift(is_show)
	self.got_gift:SetActive(is_show)
end

function LoginButtonItem:ShowRedPoint(is_show)
	self.red_point:SetActive(is_show)
end

function LoginButtonItem:ShowHighLight(is_show)
	self.is_high_light:SetValue(is_show)
end
