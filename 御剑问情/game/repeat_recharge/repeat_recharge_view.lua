RepeatRechargeView = RepeatRechargeView or BaseClass(BaseView)

function RepeatRechargeView:__init()
	self.ui_config = {"uis/views/randomact/repeatrecharge_prefab", "RepeatRecharge"}

	self.play_audio = true
	self.full_screen = false

    self.is_show = false
	self.show_display = nil
	self.title = nil
	self.fashion_role_model = nil
end

function RepeatRechargeView:LoadCallBack()
	self.model_names = {
		[DISPLAY_TYPE.MOUNT] = "repeatrecharge_mount_panel",
		[DISPLAY_TYPE.WING] = "repeatrecharge_wing_panel",
		[DISPLAY_TYPE.FOOTPRINT] = "repeatrecharge_foot_panel",
		[DISPLAY_TYPE.FASHION] = "repeatrecharge_fashion_panel",
		[DISPLAY_TYPE.HALO] = "repeatrecharge_fashion_panel",
		[DISPLAY_TYPE.SPIRIT] = "repeatrecharge_spirit_panel",
		[DISPLAY_TYPE.FIGHT_MOUNT] = "repeatrecharge_fight_mount_panel",
		[DISPLAY_TYPE.SHENGONG] = "repeatrecharge_xian_nv_panel",
		[DISPLAY_TYPE.SHENYI] = "repeatrecharge_xian_nv_panel",
		[DISPLAY_TYPE.XIAN_NV] = "repeatrecharge_xian_nv_panel",
		[DISPLAY_TYPE.ZHIBAO] = "repeatrecharge_zhibao_panel",
	}
	self:ListenEvent("Close", BindTool.Bind(self.Close,self))
	self:ListenEvent("OnClickGetReward", BindTool.Bind(self.OnClickGetReward,self))

	self.text_act_left_time = self:FindVariable("text_act_left_time")
	self.text_total_recharge = self:FindVariable("text_total_recharge")
	self.text_recharge_limit = self:FindVariable("text_recharge_limit")
	self.text_number_gift = self:FindVariable("text_number_gift")
	self.text_day_recharge = self:FindVariable("text_day_recharge")
	self.prog_value = self:FindVariable("prog_value")
	self.is_show_effect = self:FindVariable("is_show_effect")
	self.btn_get_reward = self:FindObj("BtnGetReard")
	self.display = self:FindObj("RoleDisplay")
	self.cap = self:FindVariable("Cap")
	self.is_show_prog_effect = self:FindVariable("is_show_prog_effect")
	self.is_show_red_point = self:FindVariable("is_show_red_point")
	self.is_show_prog_effect:SetValue(true)

	self.model = RoleModel.New("repeatrecharge_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		-- item:SetData(nil)
		-- item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		table.insert(self.item_list, item)
	end
end

function RepeatRechargeView:ReleaseCallBack()
	self.text_act_left_time = nil
	self.text_total_recharge = nil
	self.text_recharge_limit = nil
	self.text_number_gift = nil
	self.text_day_recharge = nil
	self.prog_value = nil
	self.is_show_effect = nil
	self.btn_get_reward = nil
	self.is_show_prog_effect = nil
	self.cap = nil
	self.is_show_red_point = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil

	self.item_list = {}
end

function RepeatRechargeView:OpenCallBack()
	self.is_first = true
	RepeatRechargeCtrl.Instance:SendAllInfoReq()
	self:Flush()
	self:FlushModel()
end

function RepeatRechargeView:CloseCallBack()
end

-- click callback -----------------------------------------------------
function RepeatRechargeView:OnClickGetReward()
	RepeatRechargeCtrl.Instance:SendGetReward()
end

-- flush func ---------------------------------------------------------

local cfg_index_t = {"wuqi_index" , "taozhuang_index" , "zuji_index", "guanghuan_index", "chibang_res"}
function RepeatRechargeView:OnFlush()
	-- 活动剩余时间刷新
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	-- 当前充值
	local chongzhi_info = RepeatRechargeData.Instance:GetCirculationChongzhiInfo()
	local total_recharge = chongzhi_info.total_chongzhi or 0
	self.text_total_recharge:SetValue(total_recharge)

	local day_cfg = RepeatRechargeData.Instance:GetCirculationChongzhiRewardShowData()
	self.text_recharge_limit:SetValue(day_cfg.need_chongzhi_gold or 0)

	local cur_chongzhi = chongzhi_info.cur_chongzhi or 0
	local num = math.floor(cur_chongzhi / day_cfg.need_chongzhi_gold)
	self.text_number_gift:SetValue(num)

	if self.is_first then
		self.is_first = false
		self.prog_value:InitValue(cur_chongzhi / day_cfg.need_chongzhi_gold)
	else
		self.prog_value:SetValue(cur_chongzhi / day_cfg.need_chongzhi_gold)
	end

	if cur_chongzhi < day_cfg.need_chongzhi_gold then
		cur_chongzhi = ToColorStr(cur_chongzhi, TEXT_COLOR.RED)
	else
		cur_chongzhi = ToColorStr(cur_chongzhi, TEXT_COLOR.BLUE1)
	end
	self.text_day_recharge:SetValue(cur_chongzhi)


	-- 礼包展示
	local reward_item_list = ItemData.Instance:GetGiftItemList(day_cfg.reward_item.item_id)
	for i = 1, 4 do
		if nil ~= reward_item_list[i] then
			self.item_list[i]:SetActive(true)
			self.item_list[i]:SetData(reward_item_list[i])
		else
			self.item_list[i]:SetActive(false)
		end
	end

	-- 按钮特效展示
	local is_can_get_reward = chongzhi_info.cur_chongzhi >= day_cfg.need_chongzhi_gold
	self.is_show_effect:SetValue(is_can_get_reward)
	self.btn_get_reward.button.interactable = is_can_get_reward
	self.is_show_red_point:SetValue(is_can_get_reward)
	local show_power = 0
	if day_cfg.show_type == "people" then
		for k,v in pairs(cfg_index_t) do
			if day_cfg[v] then
				show_power = show_power + ItemData.GetFightPower(day_cfg[v])
			end
		end
	else
		for k, v in pairs(reward_item_list) do
			show_power = show_power + ItemData.GetFightPower(v.item_id)
		end
	end

	self.cap:SetValue(show_power)
end

function RepeatRechargeView:SetTime(time)
    if time >= (24 * 3600 * 10) then
        -- 00天00时
        return TimeUtil.FormatSecond2DHMS(time,2)
    elseif time > (24 * 3600) then
        local hour_time = time - math.floor(time / (24 * 3600)) * (24 * 3600)
        if hour_time >= (10 * 3600) then
            return TimeUtil.FormatSecond2DHMS(time,3)
        else
            return TimeUtil.FormatSecond2DHMS(time,4)
        end
    elseif time > 3600 then
        if time >= (10 * 3600) then
            return TimeUtil.FormatSecond(time,3)
        else
            return TimeUtil.FormatSecond(time - 1)
        end
    else
        return TimeUtil.FormatSecond(time, 2)
    end
end

function RepeatRechargeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_REPEAT_RECHARGE)

	self.text_act_left_time:SetValue(self:SetTime(time))

end

function RepeatRechargeView:FlushModel()
	local day_cfg = RepeatRechargeData.Instance:GetCirculationChongzhiRewardShowData()
	-- 形象展示
	if day_cfg.show_type == "people" then
		self.model:SetPanelName(self.model_names[DISPLAY_TYPE.FASHION])
		local main_role = Scene.Instance:GetMainRole()
		self.model:SetRoleResid(main_role:GetRoleResId())
		if day_cfg.wuqi_index and day_cfg.wuqi_index > 0 then
			self:ChangeModule(self.model, day_cfg.wuqi_index)
		end

		if day_cfg.taozhuang_index and day_cfg.taozhuang_index > 0 then
			self:ChangeModule(self.model, day_cfg.taozhuang_index)
		end

		if day_cfg.zuji_index and day_cfg.zuji_index > 0 then
			self:ChangeModule(self.model, day_cfg.zuji_index)
		end

		if day_cfg.guanghuan_index and day_cfg.guanghuan_index > 0 then
			self:ChangeModule(self.model, day_cfg.guanghuan_index)
		end

		if day_cfg.chibang_res and day_cfg.chibang_res > 0 then
			self:ChangeModule(self.model, day_cfg.chibang_res)
		end
	else
		local item_id = day_cfg.res_id or 22301
		local cfg = ItemData.Instance:GetItemConfig(item_id)
		if cfg then
			if cfg.is_display_role == DISPLAY_TYPE.FIGHT_MOUNT then
				for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
					if v.item_id == item_id then
						local bundle, asset = ResPath.GetFightMountModel(v.res_id)
						self.model:SetPanelName(self:SetFightMountSpecialModle(asset))
						break
					end
				end
			elseif cfg.is_display_role == DISPLAY_TYPE.ZHIBAO then
				for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
					if v.active_item == item_id then
						local res_id = v.image_id
						self.model:SetPanelName(self:SetZhibaoSpecialModle(res_id))
						break
					end
				end
			else
				self.model:SetPanelName(self.model_names[cfg.is_display_role] or self.model_names[DISPLAY_TYPE.FASHION])
			end
		end
		ItemData.ChangeModel(self.model, item_id)
	end
end

function RepeatRechargeView:ChangeModule(model, item_id, item_id2)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0

	if display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		model:SetWingResid(res_id)
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model.display:SetRotation(Vector3(0, -33.2, 0))
			model:SetBool("UIRun", true)
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			model:SetBool("fight", true)
			model:SetFootResid(res_id)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..game_vo.prof..game_vo.sex]
					model:SetRoleResid(res_id)
				else
					weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]

					if weapon_res_id == 0 then
						weapon_res_id = main_role:GetWeaponResId()
						weapon2_res_id = main_role:GetWeapon2ResId()
					end

					model:SetWeaponResid(weapon_res_id)
					if weapon2_res_id then
						model:SetWeapon2Resid(weapon2_res_id)
					end
				end
			end

		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	end

	-- if model and res_id > 0 then
	-- 	model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[display_role], res_id, DISPLAY_PANEL.PROP_TIP)
	-- end
	if bundle and asset and model then
		model:SetMainAsset(bundle, asset)
		-- if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
		-- 	model:SetTrigger(ANIMATOR_PARAM.REST)
		-- end
	end

end

local DISPLAYNAME = {
	[7113001] = "repeatrecharge_fight_mount_1",
	[7114001] = "repeatrecharge_fight_mount_2",
	[7111001] = "repeatrecharge_fight_mount_3",
	[7115001] = "repeatrecharge_fight_mount_4",
	[7116001] = "repeatrecharge_fight_mount_5",
	[7117001] = "repeatrecharge_fight_mount_6",
	[13005] = "repeatrecharge_zhibao2",
	[13016] = "repeatrecharge_zhibao3",
	[13017] = "repeatrecharge_zhibao4",
}
function RepeatRechargeView:SetFightMountSpecialModle(modle_id)
	local display_name = "repeatrecharge_fight_mount_panel"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

--灵玉的特殊处理
function RepeatRechargeView:SetZhibaoSpecialModle(modle_id)
	local display_name = "repeatrecharge_zhibao_panel"
	if nil ~= DISPLAYNAME[modle_id] then
		display_name = DISPLAYNAME[modle_id]
	end
	return display_name
end
