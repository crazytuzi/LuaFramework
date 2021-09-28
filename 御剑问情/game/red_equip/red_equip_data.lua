RedEquipData = RedEquipData or BaseClass()

function RedEquipData:__init()
	if RedEquipData.Instance then
		print_error("[BeautyData] Attemp to create a singleton twice !")
	end
	RedEquipData.Instance = self
	self.equip_list = {}
	self.active_flag = {}
	self.active_reward_flag = {}
	self.orange_equip_list = {}
	self.orange_active_flag = {}
	self.orange_active_reward_flag = {}
	self.stars_info = {}
	self.orange_stars_info = {}
	self.is_show_level = -1

	local other_config = ConfigManager.Instance:GetAutoConfig("other_config_auto")
	self.equip_cfg = ListToMap(other_config.red_equip_collect, "seq", "prof")
	self.attr_cfg = ListToMap(other_config.red_equip_collect_attr, "seq","collect_count")
	self.other_cfg = ListToMap(other_config.red_equip_collect_other, "seq")
	self.other_prof_cfg = ListToMap(other_config.red_equip_collect_other, "seq", "prof")
	-- self.orange_attr_cfg = ListToMap(other_config.orange_equip_collect_attr, "seq","collect_count")
	self.orange_attr_cfg = ListToMapList(other_config.orange_equip_collect_attr, "seq")
	self.orange_equip_cfg = ListToMap(other_config.orange_equip_collect, "seq", "prof")
	self.orange_other_cfg = ListToMap(other_config.orange_equip_collect_other, "seq")
	-- self.orange_other_prof_cfg = ListToMap(other_config.orange_equip_collect_other, "seq", "prof")

end

function RedEquipData:__delete()
	RedEquipData.Instance = nil
end

function RedEquipData:GetOtherInfo()
	return self.other_cfg
end

function RedEquipData:GetProfOtherInfo(seq, prof)
	if seq and prof then
		if self.other_prof_cfg[seq] then
			return self.other_prof_cfg[seq][prof]
		end
	end
	return nil
end

function RedEquipData:GetOrangeItemNum()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local num = 0
	local state = true
	local active_role_level = 0
	for k, v in pairs(self.orange_other_cfg) do
		if level < v.active_role_level then
			state = false
			active_role_level = v.active_role_level
			break
		end

		num = num + 1
	end

	if state then
		return num, state, active_role_level
	else
		return num + 1, state, active_role_level
	end
end

function RedEquipData:GetOrangeOtherInfo()
	return self.orange_other_cfg
end

function RedEquipData:GetOrangeProfOtherInfo(seq, prof)
	if seq then
		if self.orange_other_cfg[seq] then
			return self.orange_other_cfg[seq]
		end
	end
	return nil
end

function RedEquipData:GetBossInfo(seq)
	if seq then
		return self.other_cfg[seq].get_way
	end
	return nil
end

function RedEquipData:GetOrangeBossInfo(seq)
	if seq then
		return self.orange_other_cfg[seq].get_way
	end
	return nil
end

function RedEquipData:GetOtherStar(seq)
	return self.other_cfg[seq]
end

function RedEquipData:GetOrangeOtherStar(seq)
	return self.orange_other_cfg[seq]
end

function RedEquipData:RedEquipCollect(protocol)
	self.equip_list[protocol.seq] = protocol.equip_slot
end

function RedEquipData:GetEquipSlot(seq)
	return self.equip_list[seq]
end

function RedEquipData:OrangeEquipCollect(protocol)
	self.orange_equip_list[protocol.seq] = protocol.equip_slot
end

function RedEquipData:GetOrangeEquipSlot(seq)
	return self.orange_equip_list[seq]
end

function RedEquipData:GetOrangeEquipSlotInfo()
	return self.orange_equip_list
end

function RedEquipData:OrangeEquipCollectOther(protocol)
	self.orange_active_flag = bit:d2b(protocol.seq_active_flag)
	self.orange_act_reward_can_fetch_flag = bit:d2b(protocol.act_reward_can_fetch_flag)
	self.orange_collect_count = protocol.collect_count
	self.orange_stars_info = protocol.stars_info
	self.orange_active_reward_flag = bit:d2b(protocol.active_reward_flag)
	self:SetOrangeActiveMax()
end

function RedEquipData:RedEquipCollectOther(protocol)
	self.active_flag = bit:d2b(protocol.seq_active_flag)
	self.act_reward_can_fetch_flag = bit:d2b(protocol.act_reward_can_fetch_flag)
	self.collect_count = protocol.collect_count
	self.stars_info = protocol.stars_info
	self.active_reward_flag = bit:d2b(protocol.active_reward_flag)
	self:SetActiveMax()
end

-- 获取当前星
function RedEquipData:GetOrangeStarsInfo(seq)
	return self.orange_stars_info[seq]
end

function RedEquipData:GetStarsInfo(seq)
	return self.stars_info[seq]
end

function RedEquipData:GetActiveFlag(seq)
	return self.active_flag[32 - seq]
end

function RedEquipData:GetOrangeActiveFlag(seq)
	return self.orange_active_flag[32 - seq]
end

function RedEquipData:GetTitleActiveFlag(seq)
	return self.active_reward_flag[32 - seq]
end

function RedEquipData:GetOrangeTitleActiveFlag(seq)
	return self.active_reward_flag[32 - seq]
end

function RedEquipData:GetReward()
	for i=1, 32 do
		if self.act_reward_can_fetch_flag[33 - i] == 1 then
			return true, i
		end
	end
	return false, 0
end

function RedEquipData:GetRewardIsGet()
	local cur_index = self.collect_count
	for i = 1, cur_index do
		if self.act_reward_can_fetch_flag[33 - i] == 1 then
			return i
		end
	end
	return cur_index
end

function  RedEquipData:GeCollecttCount()
	return self.collect_count or 0
end

function  RedEquipData:GetOrangeCollecttCount()
	return self.orange_collect_count or 0
end

--当前开启装备套装
function RedEquipData:SetActiveMax()
	self.is_show_level = 0
	for i=0,17 do
		if self:GetActiveFlag(i) == 1 then
			self.is_show_level = self.is_show_level + 1
		end
	end
end

function RedEquipData:SetOrangeActiveMax()
	self.is_orange_show_level = 0
	for i=0,17 do
		if self:GetOrangeActiveFlag(i) == 1 then
			self.is_orange_show_level = self.is_orange_show_level + 1
		end
	end
end

function RedEquipData:GetActiveMax()
	return self.is_show_level
end

function RedEquipData:GetOrangeActiveMax()
	return self.is_orange_show_level
end

--获取装备列表
function RedEquipData:GetRedEquipList(item_id)
	local data_list = {}
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	for k , v in pairs(bg_data_list) do
		if v ~= nil then
			if v.item_id == item_id then
				table.insert(data_list, v)
			end
		end
	end
	return data_list
end

-- 更换更好的装备
function RedEquipData:GetBetter(data)
	local data_list = {}
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	for k , v in pairs(bg_data_list) do
		if v ~= nil then
			if v.item_id == data.item_id then
				if #v.param.xianpin_type_list > #data.param.xianpin_type_list then
					return true
				end
			end
		end
	end
	return false
end

-- 背包是否有装备
function RedEquipData:GetRedEquipIsYes(seq, item_id)
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	if self:GetActiveFlag(seq) == 1 then
		for k , v in pairs(bg_data_list) do
			if v ~= nil then
				if v.item_id == item_id then
					return true
				end
			end
		end
	end
	return false
end

function RedEquipData:GetOrangeEquipIsYes(seq, item_id)
	local bg_data_list = ItemData.Instance:GetBagItemDataList()
	if self:GetOrangeActiveFlag(seq) == 1 then
		for k , v in pairs(bg_data_list) do
			if v ~= nil then
				if v.item_id == item_id then
					return true
				end
			end
		end
	end
	return false
end

function RedEquipData:GetAttrCfg(seq,count)
    if seq and count then
		if self.attr_cfg[seq] then
			return self.attr_cfg[seq][count]
		end
	end
	return nil
end

function RedEquipData:GetOrangeAttrInfo(seq,index)
	local num = 0
	if seq and index then
		if self.orange_attr_cfg[seq] then
			local cfg = self.orange_attr_cfg[seq]
			for k, v in pairs(cfg) do
				num = num + 1
				if num == index then
					return v
				end
			end
		end
	end

	return nil
end

function RedEquipData:GetOrangeAttrCfg(seq,count)
	local list = {}
    if seq and count then
		if self.orange_attr_cfg[seq] then
			local cfg = self.orange_attr_cfg[seq]
			for k, v in pairs(cfg) do
				if count < v.collect_count then
					break
				end
				table.insert(list, TableCopy(v))

			end
		end
	end

	return list
end

function RedEquipData:GetEquipCfg(seq)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if seq then
		if self.equip_cfg[seq] then
			return self.equip_cfg[seq][gamevo.prof]
		end
	end
end

function RedEquipData:GetOrangeEquipCfg(seq)
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if seq then
		if self.orange_equip_cfg[seq] then
			return self.orange_equip_cfg[seq][gamevo.prof]
		end
	end
end

function RedEquipData:GetEquipItemCfg(seq)
	local cfg = TableCopy(self:GetEquipCfg(seq))
	local item_list = {}
	if cfg then
		local i = 1
		local t = Split(cfg.equip_items, "|") or {}
		for k,v in pairs(t) do
			item_list[i] = tonumber(v)
			i = i + 1
		end
		ts_virtual = cfg.ts_virtual
	end
	return item_list
end

function RedEquipData:GetOrangeEquipItemCfg(seq)
	local cfg = TableCopy(self:GetOrangeEquipCfg(seq))
	local item_list = {}
	if cfg then
		local i = 1
		local t = Split(cfg.equip_items, "|") or {}
		for k,v in pairs(t) do
			item_list[i] = tonumber(v)
			i = i + 1
		end
		ts_virtual = cfg.ts_virtual
	end
	return item_list
end

function RedEquipData:GetWayItemCfg(seq,index)
	local cfg = TableCopy(self:GetEquipCfg(seq))
	local get_way_list = {}
	if cfg then
		local i = 1
		local t = Split(cfg.ts_virtual, "|") or {}
		for k,v in ipairs(t) do
			get_way_list[i] = tonumber(v)
			i = i + 1
		end
	end
	return get_way_list[index]
end

function RedEquipData:GetOrangeWayItemCfg(seq,index)
	local cfg = TableCopy(self:GetOrangeEquipCfg(seq))
	local get_way_list = {}
	if cfg then
		local i = 1
		local t = Split(cfg.ts_virtual, "|") or {}
		for k,v in ipairs(t) do
			get_way_list[i] = tonumber(v)
			i = i + 1
		end
	end
	return get_way_list[index]
end

function RedEquipData:GetIsShowTipsImage(seq, equip, item_id)
	-- local cur_equip_list = self:GetEquipSlot(seq)
	-- local bg_data_list = ItemData.Instance:GetBagItemDataList()
	local bg_equip_list = self:GetRedEquipList(item_id)
	if self:GetActiveFlag(seq) == 1 then
		for k , v in pairs(bg_equip_list) do
			if v ~= nil then
				if equip.item_id <= 0 then
					return true

				end
			end
		end
	end
	return false
end

function RedEquipData:GetOrangeIsShowTipsImage(seq, equip, item_id)
	local bg_equip_list = self:GetRedEquipList(item_id)
	if self:GetOrangeActiveFlag(seq) == 1 then
		for k , v in pairs(bg_equip_list) do
			if v ~= nil then
				if equip.item_id <= 0 then
					return true

				end
			end
		end
	end
	return false
end

function RedEquipData:GetAttrAddInfo(attr_list, num)
	local attr = TableCopy(attr_list)
	for k,v in pairs(attr) do
		if v > 0 and Language.Common.AttrNameNoUnderline[k] then
			attr[k] = math.floor(v + (v*num)/100)
		end
	end
	return attr
end

function RedEquipData:GetEquipList(seq)
	local equip_list, _ = self:GetEquipItemCfg(seq)
	local cur_equip_list = self:GetEquipSlot(seq)
	if nil == equip_list or nil == cur_equip_list then
		return false
	end

	for i = 1,10 do
		local bg_equip_list = self:GetRedEquipList(equip_list[i])
		for k,v in ipairs(bg_equip_list) do
			if cur_equip_list[i].item_id <= 0 then
				return true, 1
			elseif self:GetStarBool(cur_equip_list[i].param.xianpin_type_list, v.param.xianpin_type_list) then
				return true, 2
			end
		end
	end
	return false
end

function RedEquipData:GetOrangeEquipList(seq)
	local equip_list, _ = self:GetOrangeEquipItemCfg(seq)
	local cur_equip_list = self:GetOrangeEquipSlot(seq)
	if nil == equip_list or nil == cur_equip_list then
		return false
	end

	for i = 1,10 do
		local bg_equip_list = self:GetRedEquipList(equip_list[i])
		for k,v in ipairs(bg_equip_list) do
			if cur_equip_list[i].item_id <= 0 then
				return true, 1
			-- elseif self:GetStarBool(cur_equip_list[i].param.xianpin_type_list, v.param.xianpin_type_list) then
			-- 	return true, 2
			end
		end
	end
	return false
end

function RedEquipData:GetStarBool(list1, list2)
	local star1 = 0
	local star2 = 0
	for i=1,3 do
		if list1[i]then
			-- local legend_cfg = ForgeData.Instance:GetLegendCfgByType(list1[i])
			-- if legend_cfg and legend_cfg.color >= 2 then

			-- end
			star1 = star1 + 1
		end
		if list2[i]then
			-- local legend_cfg = ForgeData.Instance:GetLegendCfgByType(list2[i])
			-- print_error(legend_cfg)
			-- if legend_cfg and legend_cfg.color >= 2 then

			-- end
			star2 = star2 + 1
		end
	end
	return star2 > star1
end

function RedEquipData:GetCurEquipCap(seq)
	local cap = 0
	for k,v in pairs(self:GetEquipSlot(seq)) do
		local item_cfg, _ = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			cap = cap + CommonDataManager.GetCapabilityCalculation(item_cfg)
			-- for k1,v1 in pairs(v.param.xianpin_type_list) do
			-- 	local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v1)
			-- end
		end
	end
	return cap
end

function RedEquipData:GetTitleInfo(seq)
	local index = seq or 0
	local stars_info = self:GetStarsInfo(index) or {}
	local title_state = self:GetTitleActiveFlag(index) or 0

	if stars_info.item_count and stars_info.item_count >= 8 and title_state == 0 then
		return true
	end

	return false
end

function RedEquipData:GetOrangeTitleInfo(seq)
	local index = seq or 0
	local stars_info = self:GetOrangeStarsInfo(index) or {}
	local title_state = self:GetOrangeTitleActiveFlag(index) or 0

	if stars_info.item_count and stars_info.item_count >= 8 and title_state == 0 then
		return true
	end

	return false
end

function RedEquipData:GetOrangePointState()
	local yellow_num, state = self:GetOrangeItemNum()
	if state then
		for i = 0, yellow_num - 1 do
			local flag2 = self:GetOrangeEquipList(i)
			if flag2 then
				return true
			end
		end
	else
		for i = 0, yellow_num - 2 do
			local flag2 = self:GetOrangeEquipList(i)
			if flag2 then
				return true
			end
		end
	end

	return false
end

function RedEquipData:GetRedPointState()
	local num = #self:GetOtherInfo()
	for i=0,num do
		local title_state = self:GetTitleInfo(i)
		if title_state then
			return true
		end

		local flag = self:GetEquipList(i)
		if flag and self:GetActiveFlag(i) == 1 then
			return true
		end
	end

	return false
end