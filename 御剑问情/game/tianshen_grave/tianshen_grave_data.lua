TianShenGraveData = TianShenGraveData or BaseClass()

function TianShenGraveData:__init()
	TianShenGraveData.Instance = self
	self.gather_id_list = {}
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("cross_shuijing_auto").other[1]
	self.gather_max_times = self.other_cfg.gather_max_times
	self:InitDataList()
end

function TianShenGraveData:__delete()
	TianShenGraveData.Instance = nil
end

function TianShenGraveData:InitDataList()
	local cfg = ConfigManager.Instance:GetAutoConfig("cross_shuijing_auto").gather
	self.data_list = {}
	for k,v in ipairs(cfg) do
		local item = self:InitData(v)
		if not self.gather_id_list[v.gather_id] then
			self.gather_id_list[v.gather_id] = {}
			self.gather_id_list[v.gather_id].index = k
		end
		table.insert(self.data_list, item)
	end
end

function TianShenGraveData:InitData(value)
	local item = {}
	for k,v in pairs(value) do
		item[k] = v
	end
	item.num = 0
	item.gather_list = {}
	
	return item
end

function TianShenGraveData:SetData(protocol)
	for k,v in ipairs(self.data_list) do
		v.num = 0
		v.gather_list = {}
	end
	for k,v in ipairs(protocol.gather_item_list) do
		if self.gather_id_list[v.gather_id] then
			local index = self.gather_id_list[v.gather_id].index
			local cur_data = self.data_list[index]
			cur_data.num = cur_data.num + 1
			table.insert(cur_data.gather_list, v)
		end
	end
	self.next_big_shuijing_refresh_timestamp = protocol.next_big_shuijing_refresh_timestamp
	self.info_arrive = true
end

function TianShenGraveData:SetUserData(protocol)
	self.cur_gather_times = protocol.cur_gather_times
	self.least_times = self.gather_max_times - self.cur_gather_times
	self.wudi_gather_buff_end_timestamp = protocol.wudi_gather_buff_end_timestamp
end

function TianShenGraveData:GetData()

end

function TianShenGraveData:GetItemData(index)
	return self.data_list[index]
end

function TianShenGraveData:GetLeastTimes()
	return self.least_times or 0
end

function TianShenGraveData:GetMinPos(data)
	if not data then
		return nil, nil
	end
	local pos_x, pos_y = 0, 0
	local min_distance = -1
	local main_role = Scene.Instance:GetMainRole()
	for k,v in pairs(data.gather_list) do
		local main_role_x, main_role_y = main_role:GetLogicPos()
		local temp_distance = GameMath.GetDistance(main_role_x, main_role_y, v.pos_x, v.pos_y, false)
		if temp_distance < min_distance then
			min_distance = temp_distance
			pos_x = v.pos_x
			pos_y = v.pos_y
		end
		if min_distance == -1 then
			min_distance = temp_distance
			pos_x = v.pos_x
			pos_y = v.pos_y
		end
	end
	if min_distance == -1 then
		return nil, nil
	end
	return pos_x, pos_y
end

 function TianShenGraveData:GetGatherBuffEndTime()
  	return self.wudi_gather_buff_end_timestamp or 0
 end

 function TianShenGraveData:GetBuffBuyGold()
 	return self.other_cfg.gather_buff_gold
 end

 function TianShenGraveData:GetBuffDurationTime()
 	return self.other_cfg.gather_buff_time
 end