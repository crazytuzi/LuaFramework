EqComposeData = EqComposeData or BaseClass()

function EqComposeData:__init()
	if EqComposeData.Instance then
		ErrorLog("[EqComposeData]:Attempt to create singleton twice!")
	end
	EqComposeData.Instance = self
	self.compose_type_group = {}
	self.compose_item_group = {}
	self.tabbar_remind_list = {}
	self.is_one_key_compose = false
end

function EqComposeData:__delete()
	EqComposeData.Instance = nil

	self.compose_type_group = nil
	self.compose_item_group = nil
	self.tabbar_remind_list = nil
	self.is_one_key_compose = nil
end

function EqComposeData:GetConfigTypeIndex( tab_index )
	local index_map = {
		[TabIndex.eqcompose_stone] = 2,
		[TabIndex.eqcompose_god] = 3,
		[TabIndex.eqcompose_cp_extant] = 12,
		[TabIndex.eqcompose_dp_extant] = 1,
		[TabIndex.eqcompose_equip] = 1,
		[TabIndex.eqcompose_pet] = 4,
		[TabIndex.eqcompose_dp_equip] = 2,
	}
	return index_map[tab_index]
end

function EqComposeData:SetIsOneKeyCompose(b)
	self.is_one_key_compose = b
end

function EqComposeData:GetIsOneKeyCompose()
	return self.is_one_key_compose
end

function EqComposeData:GetComposeTypeDataList(tab_index)
	if self.compose_type_group[tab_index] == nil then
		self:SetComposeTypeDataList(tab_index)
	end
	return self.compose_type_group[tab_index]
end

function EqComposeData:SetComposeTypeDataList(tab_index)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)	
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combind_days = OtherData.Instance:GetCombindDays()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local viplv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)

	local data_list = {}
	local type_index = self:GetConfigTypeIndex(tab_index)
	if tab_index == TabIndex.eqcompose_stone or 
		tab_index == TabIndex.eqcompose_god or 
		tab_index == TabIndex.eqcompose_cp_extant or 
		tab_index == TabIndex.eqcompose_pet or 
		tab_index == TabIndex.eqcompose_equip then
		local config = EquipSynthesisConfig[type_index]
		for k, v in pairs(config) do 
			local nothing = true
			for k1, v1 in pairs(v.synthesis[prof]) do 
				if open_days >= v1.opensvrday and combind_days >= v1.combinesvrday and level >= v1.level and circle >= v1.circle and viplv >= v1.viplv then
					nothing = false
					break
				end
			end
			-- 只要有可合成物品就显示这个合成组
			if not nothing then
				table.insert( data_list, { tab_index = tab_index, type_index = type_index, title = v.title, item_id = v.id, tree_index = k} )
			end
		end
	elseif tab_index == TabIndex.eqcompose_dp_extant or
		tab_index == TabIndex.eqcompose_dp_equip then
		local config = EquipDecomposeConfig[type_index]
		for k, v in pairs(config) do 
			local dc_cfg = v.Decompose
			if dc_cfg and open_days >= dc_cfg.opensvrday and level >= dc_cfg.level and circle >= dc_cfg.circle then
				table.insert( data_list, { tab_index = tab_index, type_index = type_index, title = v.title, item_id = v.id, tree_index = k} )
			end
		end
	end
	self.compose_type_group[tab_index] = data_list
end

function EqComposeData:GetComposeItemDataList(tab_index, item_index)
	self:SetComposeItemDataList(tab_index, item_index)
	return self.compose_item_group[tab_index][item_index]
end

-- 根据背包物品数量算出可以合成的总次数
function EqComposeData.GetConsumeNumInBag(consumes)
	local all_num = 999
	local num_in_bag = 0
	for k, v in pairs(consumes or {}) do
		num_in_bag = BagData.Instance:GetItemNumInBagById(v.item_id)
		local num = math.floor(num_in_bag / v.num)
		if all_num > num then
			all_num = num
		end 
	end
	return all_num
end

function EqComposeData:SetComposeItemDataList(tab_index, item_index)
	if self.compose_item_group[tab_index] == nil then 
		self.compose_item_group[tab_index] = {} 
	end

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)	
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combind_days = OtherData.Instance:GetCombindDays()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local viplv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)

	local data_list = {}
	local type_index = self:GetConfigTypeIndex( tab_index )
	if tab_index == TabIndex.eqcompose_stone or 
		tab_index == TabIndex.eqcompose_god or 
		tab_index == TabIndex.eqcompose_cp_extant or
		tab_index == TabIndex.eqcompose_pet or
		tab_index == TabIndex.eqcompose_equip then
		local synthesis_cfg = EquipSynthesisConfig[type_index][item_index].synthesis
		-- local type = EquipSynthesisConfig[type_index] and EquipSynthesisConfig[type_index][item_index] and EquipSynthesisConfig[type_index][item_index].type
		if synthesis_cfg then
			local synthesis = synthesis_cfg[prof]
			for k, v in pairs(synthesis) do
				-- if open_days >= v.opensvrday and combind_days >= v.combinesvrday and level >= v.level and circle >= v.circle and viplv >= v.viplv then
					local award_cfg = v.award
					local consume_cfg = v.consume and v.consume[1]

					local consumes = {}
					for num, item in pairs(v.consume) do
						consumes[num] = ItemData.FormatItemData(item)
					end

					if award_cfg and consume_cfg then
						local can_consume_num = EqComposeData.GetConsumeNumInBag(consumes)
						table.insert( data_list, (can_consume_num > 0) and 1 or #data_list + 1, {	-- 材料足够的排在前面
							tab_index = tab_index,
							type_index = type_index, 
							item_index = item_index, 
							award_index = k, 
							award = { item_id = award_cfg.id, count = award_cfg.count, bind = award_cfg.bind },
							consume = { item_id = consume_cfg.id, count = consume_cfg.count, bind = 0 },
							consumes = consumes,
							can_consume_num = can_consume_num,
						} )
					end
				-- end
			end
		end
	elseif tab_index == TabIndex.eqcompose_dp_extant or
		tab_index == TabIndex.eqcompose_dp_equip then
		local dc_items_cfg = EquipDecomposeConfig[type_index][item_index].Decompose.items
		local type = EquipDecomposeConfig[type_index][item_index].type
		if dc_items_cfg then
			local items = dc_items_cfg[prof]
			for k, v in pairs(items) do
				local award_cfg = v.award and v.award[1]
				local consume_cfg = v.consume
				local consumes = {ItemData.FormatItemData(v.consume)}
				local can_consume_num = EqComposeData.GetConsumeNumInBag(consumes)
				table.insert( data_list, (can_consume_num > 0) and 1 or #data_list + 1, {
					tab_index = tab_index,
					type_index = type_index, 
					item_index = type, 
					award_index = k, 
					award = { item_id = award_cfg.id, count = award_cfg.count, bind = award_cfg.bind },
					consume = { item_id = consume_cfg.id, count = consume_cfg.count, bind = 0 },
					consumes = consumes,
					can_consume_num = can_consume_num,
				} )
			end
		end
	end
	self.compose_item_group[tab_index][item_index] = data_list
end

--得到背包中未镶嵌宝石且可合成的物品的数量
function EqComposeData.GetBagItemNum(item_id, bind_type)
	local bag_list = BagData.Instance:GetItemDataList() --获得背包中所有物品
	local num = 0
	for k,v in pairs(bag_list) do
		if	v.item_id == item_id then 
			local bool_set = EquipData.Instance:GetEquipHasStone(v)
			if bool_set == false then
				if bind_type == nil then
					num = num + v.num
				elseif bind_type == v.is_bind then
					num = num + v.num
				end
			end
		end
	end
	return num
end

function EqComposeData:GetRemindNum( tab_index, item_index )
	local num = 0
	local item_data_list = self:GetComposeItemDataList(tab_index, item_index)
	for k, v in pairs(item_data_list) do
		num = num + v.can_consume_num
	end
	if num >= 100 then num = 99 end
	return num
end

function EqComposeData:GetCanCompose( tab_index )
	local type_data_list = self:GetComposeTypeDataList(tab_index)
	local num = 0
	for k, v in pairs(type_data_list) do
		num = num + self:GetRemindNum(tab_index, v.tree_index)
	end
	return num
end

function EqComposeData:GetComposeBtnTxt( tab_index )
	if tab_index == TabIndex.eqcompose_stone or 
		tab_index == TabIndex.eqcompose_god or 
		tab_index == TabIndex.eqcompose_cp_extant or 
		tab_index == TabIndex.eqcompose_pet or 
		tab_index == TabIndex.eqcompose_equip then
		return Language.EqCompose.ComposeBtnTxt[1]
	elseif tab_index == TabIndex.eqcompose_dp_extant or
		tab_index == TabIndex.eqcompose_dp_equip then
		return Language.EqCompose.ComposeBtnTxt[2]
	end
end

function EqComposeData:SetTabbarRemindNum( tab_index, num )
	self.tabbar_remind_list[tab_index] = num
end

function EqComposeData:GetTabbarRemindList()
	return self.tabbar_remind_list
end
