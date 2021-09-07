CrossCrystalData = CrossCrystalData or BaseClass()

function CrossCrystalData:__init()
	if CrossCrystalData.Instance then
		ErrorLog("[CrossCrystalData] attempt to create singleton twice!")
		return
	end
	CrossCrystalData.Instance =self
	self.info = {
		free_relive_times = 0,
		cur_gather_times = 0,
		gather_buff_time = 0,
		big_shuijing_num = 0,
		next_big_shuijing_refresh_timestamp = 0,

		next_time = 0,
	}
	self.config = nil
end

function CrossCrystalData:__delete()
	CrossCrystalData.Instance = nil
end

function CrossCrystalData:GetConfig()
	if not self.config then
		self.config = ConfigManager.Instance:GetAutoConfig("activityshuijing_auto")
	end
	return self.config
end

function CrossCrystalData:GetOtherConfig()
	local config = self:GetConfig()
	return config.other[1]
end

function CrossCrystalData:SetCrystalInfo(info)
	self.info.free_relive_times = info.free_relive_times											-- 已免费复活次数
	self.info.cur_gather_times = info.cur_gather_times 												-- 当前可采集次数
	self.info.gather_buff_time = info.gather_buff_time 												-- 采集不被打断buff时间
end

function CrossCrystalData:SetCrystalPosInfo(info)
	self.shuijing_count = info.shuijing_count														-- 水晶列表数
	self.shuijing_list = info.shuijing_list															-- 水晶列表
	self.info.big_shuijing_num = info.big_shuijing_num 												-- 至尊水晶数量
	self.info.next_big_shuijing_refresh_timestamp = info.next_big_shuijing_refresh_timestamp		-- 下次至尊水晶刷新时间
end

function CrossCrystalData:SetNextTime(time)
	self.info.next_time = time
end

function CrossCrystalData:GetCrystalInfo()
	return self.info
end

function CrossCrystalData:GetCrystalPosInfo()
	return self.shuijing_list or {}
end

function CrossCrystalData:GetCrystalType(gather_id)
	local ga_type = 0
	local reward_cfg = self:GetConfig().reward
	for k,v in pairs(reward_cfg) do
		if v.gather_id == gather_id then
			return v.ga_type
		end
	end
	return ga_type
end

function CrossCrystalData:GetCrystalCountList()
	local count_list = {0, 0, 0, 0}
	local shuijing_list = self:GetCrystalPosInfo()
	if nil == shuijing_list and nil == next(shuijing_list) then return end
	for k,v in pairs(shuijing_list) do
		local crystal_type = self:GetCrystalType(v.gather_id)
		count_list[crystal_type] = count_list[crystal_type] + 1
	end

	return count_list
end

function CrossCrystalData:GetGatherIdListByType(gather_type)
	local gather_list = {}
	local reward_cfg = self:GetConfig().reward
	if not reward_cfg then return end

	for i = 1, #reward_cfg do
		if reward_cfg[i].ga_type == gather_type then
			table.insert(gather_list, reward_cfg[i])
		end
	end
	return gather_list
end

function CrossCrystalData:GetGatherPos(gather_type)
	local gather_list = {}
	local reward_list = self:GetGatherIdListByType(gather_type)
	local shuijing_list = self:GetCrystalPosInfo()
	if not reward_list or not shuijing_list then return end

	SortTools.SortAsc(reward_list, "ga_type")

	for i = 1, #reward_list do
		for k,v in pairs(shuijing_list) do
			if reward_list[i].gather_id == v.gather_id then
				table.insert(gather_list, v)
			end
		end
	end
	return gather_list
end

function CrossCrystalData:GetMinDistancePosList(pos_list)
	local new_pos_list = {}
	if not next(pos_list) then return end
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_x, target_y = 0, 0

	for k, v in pairs(pos_list) do
		target_x, target_y = v.x, v.y
		v.dis = GameMath.GetDistance(x, y, target_x, target_y, false)
		table.insert(new_pos_list, v)
	end

	if not next(new_pos_list) then return end

	SortTools.SortAsc(new_pos_list, "dis")
	return new_pos_list
end

function CrossCrystalData:SetSelectGatherType(type)
	self.select_gather_type = type
end

function CrossCrystalData:GetSelectGatherType()
	return self.select_gather_type or 0
end