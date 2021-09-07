HeadFrameData = HeadFrameData or BaseClass()

local AttrList = {
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "maxhp",
}

function HeadFrameData:__init()
	HeadFrameData.Instance = self

	self.head_frame_list_data = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").avatar_rim
	local head_frame_level_info_data = ConfigManager.Instance:GetAutoConfig("personalize_window_auto").avatar_rim_level
	self.head_frame_level_info_data = ListToMap(head_frame_level_info_data, "avatar_type", "avatar_level")
	self:InitListData()
end

function HeadFrameData:__delete()
	HeadFrameData.Instance = nil
end

function HeadFrameData:GetHeadFrameRedPoint()
	local is_can_up = false
	for k,v in pairs(self.head_frame_list) do
		v.cur_num = ItemData.Instance:GetItemNumInBagById(v.item1.item_id)
		v.is_can_up = false
		if v.cur_num >= v.need_num then
			if self.head_frame_level_info_data[v.seq][v.level + 1] then
				v.is_can_up = true
				is_can_up = true
			end
		end
	end
	return is_can_up
end

function HeadFrameData:InitListData()
	self.head_frame_list = {}
	for i,v in ipairs(self.head_frame_list_data) do
		local data = self:InitData(v)
		table.insert(self.head_frame_list, data)
	end
end

function HeadFrameData:InitData(value)
	if self.head_frame_level_info_data[value.seq] == nil then
		print_error("配置表出错")
		return {}
	end
	local data = {}
	data.seq = value.seq
	data.item1 = self.head_frame_level_info_data[value.seq][0].common_item
	data.name = value.name
	data.image = value.image
	data.maxhp = value.maxhp
	data.gongji = value.gongji
	data.fangyu = value.fangyu
	data.max_level = #self.head_frame_level_info_data[value.seq]
	data.cur_num = 0
	data.need_num = data.item1.num
	data.level = 0
	data.is_active = false
	data.is_can_up = false
	return data
end

function HeadFrameData:SetListDataInfo(protocol)
	self.user_frame = protocol.cur_use_avatar_type
	for i=1,#self.head_frame_list do
		local data = self.head_frame_list[i]
		data.level = protocol.avatar_level[i]
		local attrs = self:GetAttrs(data.level, data.seq)
		for k,v in pairs(AttrList) do
			data[v] = attrs[k]
		end
		data.is_active = data.level > 0
		data.item1 =  self.head_frame_level_info_data[data.seq][data.level].common_item
		data.need_num = data.item1.num
	end
end

function HeadFrameData:GetListData()
	return self.head_frame_list
end

function HeadFrameData:GetMaxNum()
	return #self.head_frame_list
end

function HeadFrameData:GetChooseData(index)
	for k,v in pairs(self.head_frame_list) do
		if v.seq == index then
			return v
		end
	end
	print_error("seq不存在", index)
	return self.head_frame_list[1]
end

function HeadFrameData:GetAttrData(level, id)
	if level == nil or id == nil or self.head_frame_level_info_data[id] == nil then
		print_error("错误信息:", level, id, self.head_frame_level_info_data[id])
		return nil
	end
	local data = {}
	data.level = level
	data.power = self:GetPowerByLevel(level, id)
	data.attrs = self:GetAttrs(level, id)
	return data
end

function HeadFrameData:GetPowerByLevel(level, id)
	local data = self.head_frame_level_info_data[id][level]
	if data == nil then
		return -1
	end
	local power = CommonDataManager.GetCapability(data)
	return power
end

function HeadFrameData:GetAttrs(level, id)
	local data = self.head_frame_level_info_data[id][level]
	if data == nil then
		return {0, 0, 0}
	end
	return {[1] = data.gongji, [2] = data.fangyu, [3] = data.maxhp}
end

function HeadFrameData:GetHeadFrameAttribute()
	local data = CommonStruct.AttributeNoUnderline()
	for k,v in pairs(self.head_frame_list) do
		data.gongji = data.gongji + v.gongji
		data.fangyu = data.fangyu + v.fangyu
		data.maxhp = data.maxhp + v.maxhp
	end
	return data
end

function HeadFrameData:GetUseFrame()
	return self.user_frame
end

function HeadFrameData:GetPrefabByItemId(item_id)
	for k,v in pairs(self.head_frame_list) do
		if v.item1.item_id == item_id then
			return v.seq
		end
	end
	return -1
end

function HeadFrameData:GetHeadFrameCfgByItemId(item_id)
	for k, v in pairs(self.head_frame_list_data) do
		local itme_data = v.item1 or {}
		if itme_data.item_id == item_id then
			return v
		end
	end

	return {}
end