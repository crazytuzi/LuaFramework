CompetitionActivityData = CompetitionActivityData or BaseClass()

COMPETITION_ACTIVITY_TYPE = {
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN,
	RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE,
}

function CompetitionActivityData:__init()
	if CompetitionActivityData.Instance then
		print_error("[CompetitionActivityData] Attempt to create singleton twice!")
		return
	end
	CompetitionActivityData.Instance = self
	RemindManager.Instance:Register(RemindName.BiPin, BindTool.Bind(self.GetBiPinRemind, self))

	self.is_first_open = true
	self.toggle_not_is_on = false
end

function CompetitionActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.BiPin)
	
	CompetitionActivityData.Instance = nil
	self.is_first_open = true
	self.toggle_not_is_on = nil
end

function CompetitionActivityData:SetFirstOpenFlag()
	self.is_first_open = false
end

function CompetitionActivityData:GetFirstOpenFlag()
	return self.is_first_open
end

function CompetitionActivityData.IsBiPin(activity_type)
	return COMPETITION_ACTIVITY_TYPE[activity_type] ~= nil
end

function CompetitionActivityData:GetBiPinRemind()
	return self:GetIsShowRedpt() and 1 or 0
end

function CompetitionActivityData:GetIsShowRedpt()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity_type = COMPETITION_ACTIVITY_TYPE[server_day]
	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then return false end

	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then return false end

	-- local is_reward = KaifuActivityData.Instance:IsGetReward(#cfg, activity_type)
	-- local is_complete = KaifuActivityData.Instance:IsComplete(#cfg, activity_type)
	for i=5, #cfg do
		 is_reward = KaifuActivityData.Instance:IsGetReward(cfg[i].seq, activity_type)
		if not is_reward then break end
	end
	for i=5, #cfg do
		 is_complete = KaifuActivityData.Instance:IsComplete(cfg[i].seq, activity_type)
		if is_complete then break end
	end
	return (is_complete and not is_reward and self:CurGrade(activity_type)) --or self:GetFirstOpenFlag()
end

function CompetitionActivityData:CurGrade(activity_type)
	local info
	if activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK then -- 坐骑
		info = MountData.Instance:GetMountInfo()  
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK then -- 羽翼
		info = WingData.Instance:GetWingInfo() 
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK then -- 天罡
		info = HaloData.Instance:GetHaloInfo()
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK then -- 法印
		info = FaZhenData.Instance:GetFightMountInfo()
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK then -- 芳华
		info = BeautyHaloData.Instance:GetBeautyHaloInfo()
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN then -- 圣物
		info = HalidomData.Instance:GetHalidomInfo() 
	elseif activity_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE then -- 披风
		info = ShenyiData.Instance:GetShenyiInfo() 
	end
	if info ~= nil then
		local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
		if cfg == nil then return end
		local index_seq = KaifuActivityData.Instance:GetRewardSeq(activity_type)
		for i,v in ipairs(cfg) do
			if v.seq == index_seq then
				if info.grade >= v.cond2 then
					return true
				end
			end
		end
	end
	return false

end

function CompetitionActivityData:GetBiPinTips(index)
	if ((index == TabIndex.mount_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[1]))				--坐骑进阶
		or (index == TabIndex.wing_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[2]))			--羽翼进阶
		or (index == TabIndex.halo_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[5]))			--光环进阶
		or (index == TabIndex.goddess_shengong and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[3]))		--神弓进阶
		or (index == TabIndex.goddess_shenyi and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[4])))		--神翼进阶
		and self:GetUpLVDan(index)
	then
		return index
	elseif TipsCtrl.Instance:GetBiPingView():IsOpen() then
		TipsCtrl.Instance:GetBiPingView():Close()
		return false
	end
	return false
end

function CompetitionActivityData:GetUpLVDan(index)
	local item_id = nil
	if TabIndex.mount_jinjie == index then
		item_id = 23234
	elseif TabIndex.wing_jinjie == index then
		item_id = 23235
	elseif TabIndex.halo_jinjie == index then
		item_id = 23236
	elseif TabIndex.goddess_shengong == index then
		item_id = 23237
	elseif TabIndex.goddess_shenyi == index then
		item_id = 23238
	end
	if item_id then
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
		for k,v in pairs(bag_data_list) do
			if item_id == v.item_id then return false end
		end
	end
	return true
end

function CompetitionActivityData:SetToggleState(value)
	self.toggle_not_is_on = value or false
end

function CompetitionActivityData:GetToggleState()
	return self.toggle_not_is_on
end