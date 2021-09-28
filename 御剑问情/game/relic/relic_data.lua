RelicData = RelicData or BaseClass()

local ONE_DAY_GATHRE_BOX_NUM = 20

function RelicData:__init()
	if RelicData.Instance then
		print_error("[RelicData] Attempt to create singleton twice!")
		return
	end
	RelicData.Instance = self

	self.config = ConfigManager.Instance:GetAutoConfig("xingzuoyijiconfig_auto")
	self.box_cfg = ListToMap(self.config.box_type, "gather_id")
	self.skip_cfg = ListToMap(self.config.skip_cfg, "quality")

	self.info = {}
end

function RelicData:__delete()
	self.info = nil
	RelicData.Instance = nil
end

function RelicData:IsRelicScene(scene_id)
	return scene_id == 1600
end

function RelicData:SetXingzuoYijiInfo(protocol)
	self.info = protocol
end

function RelicData:GetNowGatherNormalBoxNum()
	if nil == self.info.gather_box_num_list then
		return 0
	end

	local num = 0
	for i = 1, 2 do
		num = num + self.info.gather_box_num_list[i]
	end

	return num
end

function RelicData:IsCanGatherNormalBox(gather_id)
	if self:IsGatherNormalRelicBox(gather_id)
		and self:GetNowGatherNormalBoxNum() < ONE_DAY_GATHRE_BOX_NUM then
		return true
	end

	return false
end

function RelicData:IsGatherNormalRelicBox(gather_id)
	if nil ~= self.box_cfg[gather_id] then
		return self.box_cfg[gather_id].gather_index <= 1
	end
	return false
end

function RelicData:IsGatherGoldRelicBox(gather_id)
	if nil ~= self.box_cfg[gather_id] then
		return self.box_cfg[gather_id].gather_index > 1
	end
	return false
end

function RelicData:IsCanGatherGoldBox(gather_id)
	if self:IsGatherGoldRelicBox(gather_id)
		and self:GetGoldBoxRestNum() > 0 then
		return true
	end

	return false
end

function RelicData:GetSkipCfg(quality)
	return self.skip_cfg[quality]
end

function RelicData:GetGoldBoxRestNum()
	if nil == self.info.can_gather_num then
		return 0
	end
	return self.info.can_gather_num
end

function RelicData:IsShowBtnEffect()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
	if not is_open then return false end

	local is_not_hide = OpenFunData.Instance:CheckIsHide("shengxiao_uplevel")
	if not is_not_hide then return false end

	if nil == next(self.info) then return false end

	if self.info.next_boss_refresh_time <= 0 and self.info.now_boss_num <= 0 then
		return false
	end

	return true
end

function RelicData:GetXingzuoYijiInfo()
	return self.info
end

function RelicData:GetOneDayGatherBoxMaxNum()
	return ONE_DAY_GATHRE_BOX_NUM
end

function RelicData:GetRelicCfg()
	return self.config
end

function RelicData:GetBossPos()
	local x, y = 0, 0
	local boss_cfg = self.config.boss
	if boss_cfg then
		x = boss_cfg[1].boss_pos_x_0
		y = boss_cfg[1].boss_pos_y_0
	end

	return x, y
end