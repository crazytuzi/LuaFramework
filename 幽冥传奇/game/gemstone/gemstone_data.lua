GemStoneData = GemStoneData or BaseClass()

function GemStoneData:__init()
	if GemStoneData.Instance then
		ErrorLog("[GemStoneData] attempt to create singleton twice!")
		return
	end
	GemStoneData.Instance = self
	self.polish_result = nil
	self.auto_use_gold = 0
end

function GemStoneData:__delete()

end
function GemStoneData:GetSoulStoneCfg(diamond_pos, level) 
	local data = DiamondConfig.upgradeConsumes[diamond_pos][level]
	if data == nil then return nil, nil end
	local consume = data and data.upGradeConsumes and data.upGradeConsumes[1] 
	local Id = data.upItemId
	return consume, Id
end

function GemStoneData:GetMoney(diamond_pos, level)
	local data = DiamondConfig.upgradeConsumes[diamond_pos][level]
	if data == nil then return nil end
	local money = data and data.upGradeGoldConsumes and data.upGradeGoldConsumes[1]
	return money
end


function GemStoneData:GetProfectStoneCfg(level) 
	local data = DiamondConfig.upgradeConsumes[level]
	local type = data and data.toPerfectConsumes and data.toPerfectConsumes[1] 
	return type
end
function GemStoneData:ProfectFuCfg(level)
	local data = DiamondConfig.upgradeConsumes[level]
	local type = data and data.perfectUpGradeConsumes and data.perfectUpGradeConsumes[1] 
	return type
end

function GemStoneData:GetNeedEquipCircle(diamond_level, diamond_pos)
	local data_diamond =  DiamondConfig.diamondCircleCond
	if data_diamond[diamond_level] then
		return data_diamond[diamond_level][diamond_pos] 
	end 
	return nil
end

function GemStoneData.GetDiamondAttrCfg(diamond_type, level)
	return ConfigManager.Instance:GetServerConfig("attr/DiamondHoleAttrsConfig")[1][diamond_type][level]
end
function GemStoneData:SetPolishDiamondResult(protocol)
	self.polish_result = protocol.polish_result
end

function GemStoneData:RePolishDiamondResult()
	return self.polish_result
end

function GemStoneData:GetDiamondByType(diamond_type)
	local bag_item = ItemData.Instance:GetBagItemDataList()
	local index = 0
	local cur_data = {}
	for k, v in pairs(bag_item) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		if config.dura == diamond_type then
			cur_data[index] = v
			index = index + 1
		end
	end
	return cur_data
end

function GemStoneData:GetShowReWard()
	local config = DiamondConfig.diamondSmelt
	local other_day = OtherData.Instance:GetOpenServerDays()
	local cur_data = {}
	local index = 1
	for i, v in ipairs(config) do
		if v.cond[1] <= other_day and other_day <= v.cond[2] then
			for k1,v1 in pairs(v.diamondSmeltList) do
				cur_data[index] = {item_id = v1.showItemId, num = 1, is_bind = 0}
				index = index + 1
			end
			break
		end
	end
	return cur_data
end

function GemStoneData:GetConsume()
	local config = DiamondConfig.diamondSmelt
	local other_day = OtherData.Instance:GetOpenServerDays()
	for i, v in ipairs(config) do
		if v.cond[1] <= other_day and other_day <= v.cond[2] then
			return v.diamondSmeltConsume[1]
		end
	end
	return nil
end

function GemStoneData:GetCoumpondTreeList()
	local item_data = EquipSynthesisConfigEx[5] or {}
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combineday = OtherData.Instance:GetCombindDays()
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local tree_data = {}
	if item_data == nil then return end
	for i, v in ipairs(item_data) do
		if v.type == i then
			local bool = false
			if v.combineday == 0 then
				if open_days >= v.openday then
					if lv >= v.level[2] and circle >= v.level[1] then
						bool = true
					end
				end
			elseif v.combineday > 0 then
				if  combineday >= v.combineday or open_days >= v.openday then
					if lv >= v.level[2] and circle >= v.level[1] then
						bool = true
					end
				end
			end
			if bool == true then
				tree_data[i] = {item_id = (v.id and v.id[prof]), num = 1, is_bind = 0, name = v.name, current_index = index, openday = v.openday, combineday = v.combineday, current_item_index = i}
			end
		end
	end
	local sort_data = {}
	local index = 1
	for k, v in pairs(tree_data) do
		sort_data[index] = v
		index = index + 1
	end
	return sort_data
end

function GemStoneData:GetCoumpondChildList(tree_index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combineday = OtherData.Instance:GetCombindDays()
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local child_data = {}
	local data_t = EquipSynthesisConfigEx[5] or {}
	for k, v in ipairs(data_t) do
		for k1, v1 in ipairs(v.synthesis[prof]) do
			if v.type == tree_index then
				local bool = false
				if v1.combineday == nil or v1.combineday == 0 then
					if open_days >= v1.openday then
						if lv >= v.level[2] and circle >= v.level[1] then
							bool = true
						end
					end
				elseif v1.combineday > 0  then
					if  combineday >= v1.combineday or open_days >= v1.openday then
						if lv >= v.level[2] and circle >= v.level[1] then
							bool = true
						end
					end
				end
				if bool == true then
					local reward_item = {item_id = v1.award.id, num = v1.award.count, is_bind = v1.award.bind}
					local consume_item = {item_id = v1.consume[1] and v1.consume[1].id, num = 1, is_bind = 0}
					local consume_gold = v1.consume[2] and v1.consume[2].count
					local bool_compound = v.denyFilter
					local data = {item = reward_item, consume = consume_item, consume_num = v1.consume[1] and v1.consume[1].count, current_index = index, current_type = v.type, current_item_index = k1}
					table.insert(child_data, data)
				end
			end
		end
	end
	return child_data
end

function GemStoneData:BoolCanCoupond()
	local item_data = EquipSynthesisConfigEx[5] or {}
	for k, v in pairs(item_data) do
		if GemStoneData.Instance:GetSingleCanCompond(v.type) > 0 then
			return 1
		end
	end
	return 0
end

function GemStoneData:GetSingleCanCompond(tree_index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combineday = OtherData.Instance:GetCombindDays()
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local item_data_t = EquipSynthesisConfigEx[5] or {}
	local data = item_data_t[tree_index] or {}
	for k, v1 in pairs(data.synthesis[prof]) do
		local bool = false
		if v1.combineday == nil or v1.combineday == 0 then
			if open_days >= v1.openday then
				if lv >= v1.level[2] and circle >= v1.level[1] then
					bool = true
				end
			end
		elseif v1.combineday > 0  then
			if  combineday >= v1.combineday or open_days >= v1.openday then
				if lv >= v1.level[2] and circle >= v1.level[1] then
					bool = true
				end
			end
		end
		if bool == true then
			local consume_item_id = v1.consume[1] and v1.consume[1].id 
			local consume_count = v1.consume[1] and v1.consume[1].count
			local num = ItemData.Instance:GetItemNumInBagById(consume_item_id, nil)
			if num >= consume_count then
				return 1
			end
		end
	end
	return 0
end


--===
function GemStoneData:SetBoolUseGold(bool_use_gold)
	self.auto_use_gold = bool_use_gold
end

function GemStoneData:GetBoolUseGold()
	return self.auto_use_gold
end