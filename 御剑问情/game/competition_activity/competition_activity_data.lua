CompetitionActivityData = CompetitionActivityData or BaseClass()

-- 当前比拼活动顺序
-- COMPETITION_ACTIVITY_TYPE = {
-- 	[1] = 2143,	--坐骑
--  [2] = 2145,	--羽翼
-- 	[3] = 2154,	--伙伴
-- 	[4] = 2155,	--仙宠
-- 	[5] = 2150,	--光环
-- 	[6] = 2144,	--足迹
-- 	[7] = 2156,	--战骑
-- }

function CompetitionActivityData:__init()
	if CompetitionActivityData.Instance then
		print_error("[CompetitionActivityData] Attempt to create singleton twice!")
		return
	end
	CompetitionActivityData.Instance = self
	RemindManager.Instance:Register(RemindName.BiPin, BindTool.Bind(self.GetBiPinRemind, self))
	self.bipin_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto").bipin_cfg, "activity_type")
	self.toggle_not_is_on = false
	self.bipin_act_type_list = nil

	self.bipin_tab_index_t = {
		[1] = {day = 1, index = TabIndex.mount_jinjie, zsd = 23234, zsd2 = 23256},
		[2] = {day = 2, index = TabIndex.wing_jinjie, zsd = 23235, zsd2 = 23257},
		[3] = {day = 3, index = TabIndex.goddess_shengong, zsd = 23237},
		[4] = {day = 4, index = TabIndex.halo_jinjie, zsd = 24532},
		[5] = {day = 5, index = TabIndex.goddess_shenyi, zsd = 23238},
		[6] = {day = 6, index = TabIndex.foot_jinjie, zsd = 23236},
		[7] = {day = 7, index = TabIndex.fight_mount, zsd = 23239},

		[8] = {day = 8, index = TabIndex.appearance_waist, zsd = 23250},
		[9] = {day = 9, index = TabIndex.appearance_toushi, zsd = 23251},
		[10] = {day = 10, index = TabIndex.appearance_qilinbi, zsd = 23252},
		[11] = {day = 11, index = TabIndex.appearance_mask, zsd = 23253},
		[12] = {day = 12, index = TabIndex.appearance_xianbao, zsd = 23255},
		[13] = {day = 13, index = TabIndex.appearance_lingzhu, zsd = 23254},

	}
	self.bipin_tab_index_day_t = {}
	self.bipin_zsd_day_t = {}
	for k,v in pairs(self.bipin_tab_index_t) do
		self.bipin_tab_index_day_t[v.index] = v
		self.bipin_zsd_day_t[v.zsd] = v
	end
end

function CompetitionActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.BiPin)

	CompetitionActivityData.Instance = nil
	self.toggle_not_is_on = nil
	self:CancelCountDown()
end

function CompetitionActivityData:GetBiPinRemind()
	return self:GetIsShowRedpt() and 1 or 0
end

function CompetitionActivityData:IsBiPinActivity(activity_type)
	return self.bipin_cfg[activity_type] ~= nil
end

function CompetitionActivityData:GetIsShowRedpt()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = self:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[server_day] then
		return false
	end

	local activity_type = bipin_cfg[server_day].activity_type
	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then
		return false
	end

	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then
		return false
	end

	local is_reward = KaifuActivityData.Instance:IsGetReward(#cfg, activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(#cfg, activity_type)

	return (is_complete and not is_reward)
end

function CompetitionActivityData:GetBiPinTips(index)
	local activity_type = self:GetTabIndexToActType(index)
	if ActivityData.Instance:GetActivityIsOpen(activity_type or 0) and self:GetUpLVDan(index) then
		return index
	elseif TipsCtrl.Instance:GetBiPingView():IsOpen() then
		TipsCtrl.Instance:GetBiPingView():Close()
	end
	return false
end

function CompetitionActivityData:GetBiPinOpen(index)
	local activity_type = self:GetTabIndexToActType(index)
	return ActivityData.Instance:GetActivityIsOpen(activity_type or 0)
end

function CompetitionActivityData:GetUpLVDan(index, index_type)
	local item_id = nil
	if self.bipin_tab_index_day_t[index] then
		if 7 == index_type then
			item_id = self.bipin_tab_index_day_t[index].zsd2
		else
			item_id = self.bipin_tab_index_day_t[index].zsd
		end
	end
	if item_id then
		local bag_data_list = ItemData.Instance:GetBagItemDataList()
		for k,v in pairs(bag_data_list) do
			if item_id == v.item_id then
				return false, v.index
			end
		end
	end
	return true, -1
end

function CompetitionActivityData:SetToggleState(value)
	self.toggle_not_is_on = value or false
end

function CompetitionActivityData:GetToggleState()
	return self.toggle_not_is_on
end

function CompetitionActivityData:SendNotice()
	local bipin_cfg = self:GetBiPinActTypeList()
	if nil == bipin_cfg then
		return false
	end

	local notice = ""
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == server_day or server_day > 7 then
		return
	end

	if nil == bipin_cfg[server_day] then
		return
	end

	local active_rank_info = KaifuActivityData.Instance:GetOpenServerRankInfo(bipin_cfg[server_day].activity_type)
	if nil == active_rank_info or nil == next(active_rank_info) or active_rank_info.top1_uid <= 0 then
		notice = string.format(Language.Common.BiPinActivity2, Language.Common.BiPinName[server_day])
	else
		notice = string.format(Language.Common.BiPinActivity1, Language.Common.BiPinName[server_day], active_rank_info.role_name)
	end
	TipsCtrl.Instance:ShowSystemNotice(notice)
	self:SetRestTime(300)
end

function CompetitionActivityData:SetRestTime(diff_time)
	if self.count_down_chu == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				self:SendNotice()
				return
			end
		end

		diff_time_func(0, diff_time)
		self:CancelCountDown()
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function CompetitionActivityData:CancelCountDown()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function CompetitionActivityData:GetBiPingReward()
	local bipin_cfg = self:GetBiPinActTypeList()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == bipin_cfg or nil == bipin_cfg[open_day] then
		return false
	end


	local activity_type = bipin_cfg[open_day].activity_type
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if cfg == nil then
		return
	end

	local item_list = {}
	local reward_list = cfg[#cfg].reward_item
	for k, v in pairs(reward_list) do
		local gift_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_GIF then
			local item_gift_list = ItemData.Instance:GetGiftItemList(v.item_id)
			if gift_cfg and gift_cfg.rand_num and gift_cfg.rand_num > 0 then
				item_gift_list = {v}
			end
			for _, v2 in pairs(item_gift_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.item_id)
				if item_cfg and (item_cfg.limit_prof == prof or item_cfg.limit_prof == 5) then
					table.insert(item_list, v2)
				end
			end
		else
			table.insert(item_list, v)
		end
	end

	return item_list
end

function CompetitionActivityData:GetBiPinRewardTips(index)
	local activity_type = self:GetTabIndexToActType(index)
	return ActivityData.Instance:GetActivityIsOpen(activity_type or 0)
end

function CompetitionActivityData:IsGetReward(tab_index)
	local activity_type = self:GetTabIndexToActType(tab_index)
	if nil == activity_type then
		return
	end

	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then return false end

	local is_get_reward = KaifuActivityData.Instance:IsGetReward(#cfg, activity_type)
	return is_get_reward
end

function CompetitionActivityData:GetIsShowRedptByTabIndex(tab_index)
	local activity_type = self:GetTabIndexToActType(tab_index)
	if nil == activity_type then
		return false
	end

	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then return false end

	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then return false end

	local is_reward = KaifuActivityData.Instance:IsGetReward(#cfg, activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(#cfg, activity_type)

	return (is_complete and not is_reward)
end

function CompetitionActivityData:GetBiPinActTypeList()
	if nil == self.bipin_act_type_list then
		local bipin_cfg = KaifuActivityData.Instance:GetKaifiBiPinCfg()
		if nil == bipin_cfg then
			return nil
		end

		self.bipin_act_type_list = {}
		for k, v in pairs(bipin_cfg) do
			self.bipin_act_type_list[v.bipin_index] = v
		end
	end

	return self.bipin_act_type_list
end

function CompetitionActivityData:GetTabIndexToActType(tab_index)
	local bipin_cfg = self:GetBiPinActTypeList()
	if nil == bipin_cfg then
		return nil
	end
	local day = 0
	if self.bipin_tab_index_day_t[tab_index] then
		day = self.bipin_tab_index_day_t[tab_index].day
	end
	if bipin_cfg[day] then
		return  bipin_cfg[day].activity_type
	end

	return nil
end

function CompetitionActivityData:isBipinZSD(item_id)
	return self.bipin_zsd_day_t[item_id] ~= nil
end
local ZSD_GRADE = 6
function CompetitionActivityData:ChangeModelByZSD(model, item_id, index, cur_grade)
	if not index and self.bipin_zsd_day_t[item_id] then
		index = self.bipin_zsd_day_t[item_id].index
	end

	if not index then
		return
	end

    local bundle, asset = nil, nil
    local main_vo = GameVoManager.Instance:GetMainRoleVo()
    local main_role = Scene.Instance:GetMainRole()
    local res_id = 0
    if model then
        local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
        local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
        local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
        model.display:SetRotation(Vector3(0, 0, 0))
        if index ~= TabIndex.foot_jinjie then
            model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
        end
        if halo_part then
            halo_part:RemoveModel()
        end
        if wing_part then
            wing_part:RemoveModel()
        end
        if weapon_part then
            weapon_part:RemoveModel()
        end
    end

	if index == TabIndex.mount_jinjie then
		local mount_grade_cfg = 0
		if 7 ~= cur_grade then
			mount_grade_cfg = MountData.Instance:GetMountGradeCfg(ZSD_GRADE)
		else
			mount_grade_cfg = MountData.Instance:GetMountGradeCfg(cur_grade + 1)
		end

		local image_cfg = MountData.Instance:GetMountImageCfg()
		if nil == mount_grade_cfg or  nil == image_cfg then return end
		bundle, asset = ResPath.GetMountModel(image_cfg[mount_grade_cfg.image_id].res_id)
		model:SetPanelName("leiji_daily_mount_panel")
		model:SetMainAsset(bundle, asset)
		model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif index == TabIndex.wing_jinjie then
		local wing_grade_cfg = 0
		if 7 ~= cur_grade then
			wing_grade_cfg = WingData.Instance:GetWingGradeCfg(ZSD_GRADE)
		else
			wing_grade_cfg = WingData.Instance:GetWingGradeCfg(cur_grade + 1)
		end

		local image_cfg = WingData.Instance:GetWingImageCfg()
		if nil == wing_grade_cfg or nil == image_cfg then return end
		bundle, asset = ResPath.GetWingModel(image_cfg[wing_grade_cfg.image_id].res_id)
		model:SetPanelName("five_grade_wing_panel")
		model:SetMainAsset(bundle, asset)
		model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif index == TabIndex.goddess_shengong then
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id =ShengongData.Instance:IsActiviteShengong() and goddess_data:GetShowXiannvResId() or 11005
		info.weapon_res_id = ShengongData.Instance:GetShowShengongRes(ZSD_GRADE)
		model:SetPanelName("leiji_daily_xian_nv_panel")
		model:SetGoddessModelResInfo(info)
		model:SetTrigger("show_idle_1")
	elseif index == TabIndex.goddess_shenyi then
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id =ShenyiData.Instance:IsActiviteShenyi() and goddess_data:GetShowXiannvResId() or 11005
		info.wing_res_id = ShenyiData.Instance:GetShowShenyiRes(ZSD_GRADE)
		model:SetPanelName("leiji_daily_xian_nv_panel")
		model:SetGoddessModelResInfo(info)
		model:SetTrigger("show_idle_1")
	elseif index == TabIndex.halo_jinjie then
		local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(ZSD_GRADE)
		local image_cfg = HaloData.Instance:GetHaloImageCfg()
		if nil == halo_grade_cfg or nil == image_cfg then return end
		model:SetRoleResid(main_role:GetRoleResId())
        model:SetHaloResid(image_cfg[halo_grade_cfg.image_id].res_id)
        model:SetPanelName("leiji_daily_fashion_panel")
        model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif index == TabIndex.foot_jinjie then
		local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(ZSD_GRADE)
		local image_cfg = FootData.Instance:GetFootImageCfg()
		if nil == foot_grade_cfg or nil == image_cfg then return end
		model:SetRoleResid(main_role:GetRoleResId())
        model:SetFootResid(image_cfg[foot_grade_cfg.image_id].res_id)
        model:SetPanelName("leiji_daily_foot_panel")
        model.display:SetRotation(Vector3(0, -90, 0))
        model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif index == TabIndex.fight_mount then
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(ZSD_GRADE)
		local image_cfg = FightMountData.Instance:GetMountImageCfg()
		if mount_grade_cfg == nil or not image_cfg then return end
		bundle, asset = ResPath.GetFightMountModel(image_cfg[mount_grade_cfg.image_id].res_id)
		model:SetPanelName("leiji_daily_fight_mount_panel")
		model:SetMainAsset(bundle, asset)
	elseif index == TabIndex.appearance_waist then
		local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_vo.appearance.fashion_body
		info.appearance.yaoshi_used_imageid = grade_info.image_id

		model:ResetRotation()
		model:SetModelResInfo(info, true, true, true, true, true, true)
		model:SetPanelName("leiji_daily_fashion_panel")
	elseif index == TabIndex.appearance_toushi then
		local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_vo.appearance.fashion_body
		info.appearance.toushi_used_imageid = grade_info.image_id

		model:ResetRotation()
		model:SetModelResInfo(info, true, true, true, true, true, true)
		model:SetPanelName("leiji_daily_fashion_panel")
	elseif index == TabIndex.appearance_mask then
		local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_body = main_vo.appearance.fashion_body
		info.appearance.mask_used_imageid = grade_info.image_id

		model:ResetRotation()
		model:SetModelResInfo(info, true, true, true, true, true, true)
		model:SetPanelName("leiji_daily_fashion_panel")
	elseif index == TabIndex.appearance_qilinbi then
		local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end

		local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then
			return
		end

		local main_vo = GameVoManager.Instance:GetMainRoleVo()

		local bundle, asset = ResPath.GetQilinBiModel(image_info["res_id" .. main_vo.sex .. "_h"], main_vo.sex)
		model:ResetRotation()
		model:SetMainAsset(bundle, asset)
		model:SetPanelName("leiji_daily_qilinbi")
	elseif index == TabIndex.appearance_xianbao then
		--对应等级数据
		local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end

		--对应资源数据
		local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then
			return
		end

		local bundle, asset = ResPath.GetXianBaoModel(image_info.res_id)
		model:ResetRotation()
		model:SetMainAsset(bundle, asset)
		model:SetPanelName("leiji_daily_xianbao")
	elseif index == TabIndex.appearance_lingzhu then
		--对应等级数据
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(ZSD_GRADE)
		if nil == grade_info then
			return
		end

		--对应资源数据
		local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then
			return
		end

		model:ResetRotation()
		local bundle, asset = ResPath.GetLingZhuModel(image_info.res_id, true)
		model:SetMainAsset(bundle, asset)
		model:SetPanelName("leiji_daily_lingzhu")
	end
end

function CompetitionActivityData:GetFightPowerByZSD(item_id)
	local index = 0
	if self.bipin_zsd_day_t[item_id] then
		index = self.bipin_zsd_day_t[item_id].index
	else
		return 0
	end
	if index == TabIndex.mount_jinjie then
		local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(ZSD_GRADE)
		if nil == mount_grade_cfg then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(mount_grade_cfg))
	elseif index == TabIndex.wing_jinjie then
		local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(ZSD_GRADE)
		if nil == wing_grade_cfg then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(wing_grade_cfg))
	elseif index == TabIndex.goddess_shengong then
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(ZSD_GRADE)
		if nil == shengong_grade_cfg then return end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(shengong_grade_cfg))
	elseif index == TabIndex.goddess_shenyi then
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(ZSD_GRADE)
		if nil == shenyi_grade_cfg then return end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(shenyi_grade_cfg))
	elseif index == TabIndex.halo_jinjie then
		local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(ZSD_GRADE)
		if nil == halo_grade_cfg then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(halo_grade_cfg))
	elseif index == TabIndex.foot_jinjie then
		local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(ZSD_GRADE)
		if foot_grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(foot_grade_cfg))
	elseif index == TabIndex.fight_mount then
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(ZSD_GRADE)
		if mount_grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(mount_grade_cfg))
	elseif index == TabIndex.appearance_waist then
		local grade_cfg = WaistData.Instance:GetWaistGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	elseif index == TabIndex.appearance_toushi then
		local grade_cfg = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	elseif index == TabIndex.appearance_qilinbi then
		local grade_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	elseif index == TabIndex.appearance_mask then
		local grade_cfg = MaskData.Instance:GetMaskGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	elseif index == TabIndex.appearance_xianbao then
		local grade_cfg = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	elseif index == TabIndex.appearance_lingzhu then
		local grade_cfg = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(ZSD_GRADE)
		if grade_cfg == nil then return 0 end
		return CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(grade_cfg))
	end
	return 0
end