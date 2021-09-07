MapFindData = MapFindData or BaseClass()

function MapFindData:__init()
	if MapFindData.Instance then
		print_error("[MapFindData] Attempt to create singleton twice!")
		return
	end
	MapFindData.Instance = self
end

function MapFindData:__delete(  )
	self.flush_data_range = nil
	self.camp_range = nil
	MapFindData.Instance = nil
end

-------------------获取数据----------------

function MapFindData:GetMapData()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().map_hunt_city
end

function MapFindData:GetMapCampData()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().map_hunt_route
end

function MapFindData:GetMapFlushData()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().map_hunt_server_reward
end

function MapFindData:GetMapTotalFree()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].map_hunt_free_count
end

function MapFindData:GetMapFlushSpend()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].map_hunt_flush_gold
end

function MapFindData:GetMapFindSpend()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].map_hunt_xunbao_glod
end
-- function MapFindData:GetRouteByChoose()
-- 	local data = self:GetMapCampData()
-- 	if self.route_info.route_index == 0 then
-- 		return data[1]
-- 	else
-- 		return data[self.route_info.route_index]
-- end

function MapFindData:GetFlushDataByOpenday()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local reward_item = {}
	local data = self:GetMapFlushData()
	reward_item = ActivityData.Instance:GetRandActivityConfig(data,ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT)
	-- if self.flush_data_range ==nil then
	-- 	self.flush_data_range = GetDataRange(data,"opengame_day")
	-- end
	-- local day_index = self.flush_data_range[1]
	-- for i,v in ipairs(self.flush_data_range) do
	-- 	if open_day <= v then
	-- 		day_index = v
	-- 		break
	-- 	end
	-- end
	-- for k,v in pairs(data) do
	-- 	if v.opengame_day == day_index then
	-- 		table.insert(reward_item,v)
	-- 	end
	-- end
	return reward_item
end

function MapFindData:GetRouteNumber()
	local data = self:GetMapCampData()
	return data[#data].route_index
end

-- function MapFindData:GetMapCampDataRange()
-- 	if self.camp_range then
-- 		return self.camp_range
-- 	end
-- 	local data = self:GetMapCampData()
-- 	self.camp_range = GetDataRange(data,"opengame_day")
-- 	return self.camp_range
-- end

-- function MapFindData:GetMapCampDataRangeByOpenDay()
-- 	-- local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
-- 	local camp_range = self:GetMapCampDataRange()
-- 	for i,v in ipairs(camp_range) do
-- 		if open_day <= v then
-- 			return v
-- 		end
-- 	end
-- end

function MapFindData:GetMapCampDataByDayRange(index)
	-- local day_range = self:GetMapCampDataRangeByOpenDay()
	local data = self:GetMapCampData()
	local data_range = ActivityData.Instance:GetRandActivityConfig(data,ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT)
	for k,v in pairs(data_range) do
		if index == v.route_index then
			return v
		end
	end
	return data[#data]
end

function MapFindData:GetNameById(id)
	local  data = self:GetMapData()
	for k,v in pairs(data) do
		if v.city_id == id then
			return v.name
		end
	end
end

function MapFindData:GetMapRewardData(id)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = self:GetMapData()
	local day_rank = ActivityData.Instance:GetRandActivityConfig(data,ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT)
	-- local day_index = day_rank[1]
	-- for i,v in ipairs(day_rank) do
	-- 	if open_day <= v then
	-- 		day_index = v
	-- 		break
	-- 	end
	-- end
	for k,v in pairs(day_rank) do
		if id == v.city_id then
			return v
		end
	end
	return nil
end

function MapFindData:SetMapData(protocol)
	self.route_info = protocol.route_info
	self.flush_times = protocol.flush_times
	self.next_flush_timestamp = protocol.next_flush_timestamp
	self.return_reward_fetch_flag = protocol.return_reward_fetch_flag
	self.free_count = protocol.free_count
	self.can_extern_reward = protocol.can_extern_reward
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT, self:GetFreeTimes() > 0 and tonumber(self.route_info.city_fetch_flag) ~= 7)
end

function MapFindData:GetRouteIndex()
	return self.route_info.route_index == 0 and 1 or self.route_info.route_index
end

function MapFindData:GetFreeTimes()
	local total_free = self:GetMapTotalFree()
	return total_free - self.free_count
end

function MapFindData:GetNextFlushTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	return self.next_flush_timestamp - now_time
end

function MapFindData:GetRouteInfo()
	return self.route_info
end

function MapFindData:GetFetchFlag(index)
	local flag =  bit:d2b(self.route_info.city_fetch_flag)
	return flag[33 - index]
end

function MapFindData:GetActiveFlag(index)
	local flag = bit:d2b(self.route_info.route_active_flag)
	return flag[33 - index]
end

function MapFindData:SetSelect(select)
	self.select = select
end

function MapFindData:GetSelect()
	return self.select or 1
end

function MapFindData:GetFlushTimes()
	return self.flush_times
end

function MapFindData:GotReward(index)
	local data = bit:d2b(self.return_reward_fetch_flag)
	return data[32 - index]
end

function MapFindData:IsRareMap(index)
	local data = self:GetMapData()
	return data[index].is_broadcast == 1
end