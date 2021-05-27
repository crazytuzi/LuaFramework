GodWeaponEtremeData = GodWeaponEtremeData or BaseClass()

GODWEAPONETREMEDATA_TYPE = {
	COMMON = 1,
	WEAPON = 2, 
	FASHION = 3,
	DECOMPOSE = 4,
}

EquipType = {
	ItemData.ItemType.itWeapon, 
	ItemData.ItemType.itDress, 
	ItemData.ItemType.itHelmet, 
	ItemData.ItemType.itNecklace, 
	ItemData.ItemType.itBracelet, 
	ItemData.ItemType.itRing, 
	ItemData.ItemType.itGirdle, 
	ItemData.ItemType.itShoes, 
}

function GodWeaponEtremeData:__init()
	if GodWeaponEtremeData.Instance then
		ErrorLog("[GodWeaponEtremeData] attempt to create singleton twice!")
		return
	end
	GodWeaponEtremeData.Instance = self
	self.bool_use = 0
	self.bool_fashion_use = 0
end

function GodWeaponEtremeData:__delete()

end

function GodWeaponEtremeData:SetWeaponUseItem(bool_use)
	self.bool_use = bool_use
end

function GodWeaponEtremeData:GetBoolUse()
	return self.bool_use
end

function GodWeaponEtremeData:SetFashionBoolUse(bool_use)
	self.bool_fashion_use = bool_use
end

function GodWeaponEtremeData:GetFashionUse()
	return self.bool_fashion_use
end

function GodWeaponEtremeData:GetGroupNameData()
	local name_list = {}
	local index = 1
	for i, v in ipairs(Language.GodWeapon.TabGroup1) do
		local cur_data = self:GetChildListDataBy(i)
		if #cur_data ~= 0 then
			name_list[index] = v
			index = index + 1
		end
	end
	return name_list
end

function GodWeaponEtremeData:GetChildListDataBy(groupId)
	print("groupId1111111==" ..groupId)
	local data = EquipSynthesisConfigEEx[GODWEAPONETREMEDATA_TYPE.FASHION]
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if data == nil then return {} end
	local cur_data = {}
	local index = 1
	for k, v in pairs(data) do
		if v.groupId == groupId then
			if circle >= v.circle then
				cur_data[index] = {}
				cur_data[index] = {
					consume_id = k,
					preview_id = v.newEquipId,
					equipConsumes = v.equipConsumes,
					materialConsumes = v.materialConsumes,
					inheritConsumes = v.inheritConsumes,
				}
				index = index + 1
			end
		end
	end
	local function sort(a, b)
		if a.consume_id ~= b.consume_id then
			return a.consume_id < b.consume_id
		end
		return a.consume_id < b.consume_id
	end
	table.sort(cur_data, sort)
	return cur_data
end

function GodWeaponEtremeData:GetItemDataById(item_id, bool, series)
	local item_data = {}
	if series == nil then
		item_data = ItemData.Instance:GetBagItemDataList()
	else
		for k, v in pairs(ItemData.Instance:GetBagItemDataList()) do
			if v.series ~= series then
				table.insert(item_data, v)
			end
		end
	end
	local index = 1
	local cur_data = {}
	for k, v in pairs(item_data) do
		if v.item_id == item_id then
			cur_data[index] = {item = v, score = 0}
			cur_data[index].score = ItemData.Instance:GetItemScore(v)
			index  = index +1
		end 
	end
	if #cur_data >= 2 then
		local function sort_baglist()
			return function(c, d)
				if c.score ~= d.score then
					return c.score < d.score
				end
				return c.item.item_id < d.item.item_id
			end
		end
		table.sort(cur_data, sort_baglist())
	end
	if bool then
		return cur_data[#cur_data]
	else
		return cur_data[1]
	end
end

function GodWeaponEtremeData:GetUpConfigIdbuId(id)
	return EquipSynthesisConfigEEx[GODWEAPONETREMEDATA_TYPE.FASHION][id]
end

function GodWeaponEtremeData:InitGodEquipWeaponBagList(index)
	local function sort(a, b)
		if a.item_id ~= b.item_id then
			return a.item_id > b.item_id
		else
			return a.is_bind < b.is_bind
		end
	end
	if index then					
		self.type_list = self.type_list or {}
		self.type_list[index] = {}
		if index == 1 then
			self.type_list[index] = self:GetGodWeaponList()
		else
			for k,v in pairs(GodWeaponEtremeData.Instance:GetGodFashionExtreme()) do
				local type_index = GodWeaponEtremeData.GetSuitIdIndex(v.item_id)
				if type_index == index then
					table.insert(self.type_list[index], v)
				end
			end
			table.sort(self.type_list[index], sort)
			self.type_list[index][0] = table.remove(self.type_list[index], 1)
		end
	else
		self.type_list = {}
		self.type_list[1] = self:GetGodWeaponList()
		for k,v in pairs(GodWeaponEtremeData.Instance:GetGodFashionExtreme()) do
			local type_index = GodWeaponEtremeData.GetSuitIdIndex(v.item_id)
			if type_index > 0 then
				self.type_list[type_index] = self.type_list[type_index] or {}
				table.insert(self.type_list[type_index], v)
			end
		end
	end
	for k, v in pairs(self.type_list) do
		table.sort(v, sort)
		v[0] = table.remove(v, 1)
	end
end


function GodWeaponEtremeData:GetGodWeaponList()
	local cur_data = {}
	local bag_data = ItemData.Instance:GetBagEquipList()
	for k,v in pairs(bag_data) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		if config.flags and config.flags.theShenArmy == true then
			if EquipSynthesisConfigEEx and EquipSynthesisConfigEEx[4] then
				for k1,v1 in pairs(EquipSynthesisConfigEEx[4]) do
					if k1 == v.item_id then
						table.insert(cur_data, v)
					end
				end
			end
		end
	end
	return cur_data
end


function GodWeaponEtremeData:GetGodFashionExtreme()
	local cur_data = {}
	local bag_data = ItemData.Instance:GetBagEquipList()
	for k,v in pairs(bag_data) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		if config.flags and config.flags.primeEquip == true then
			for i = 1, #EquipSynthesisConfigEEx do
				if EquipSynthesisConfigEEx[i][v.item_id] then
					table.insert(cur_data, v)
				end
			end
		end
	end
	return cur_data
end


function GodWeaponEtremeData.GetSuitIdIndex(item_id)

		local item_cfg = ItemData.Instance:GetItemConfig(item_id) 
		if item_cfg.flags.godEquip == true then return 1 end
			local level, zhuan = ItemData.GetItemLevel(item_id)
			if zhuan > 0 then
				for k, v in pairs(ExtremeEquipRecoveryCfg) do
					if k ~= 1 then
						if zhuan >= v.circleMin and zhuan <= v.circleMax then

							return k
						end
					end
				end
			else
				for k, v in pairs(ExtremeEquipRecoveryCfg) do
					if k ~= 1 then
						if level >= v.LevelMin and level <= v.LevelMax then
							return k
						end
					end
				end
			end
		


	return -1
end

function GodWeaponEtremeData:GetDecomposeBtnList()
	local list = {}
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k,v in pairs(ExtremeEquipRecoveryCfg) do
		if circle >= v.role_circle then
			local num = 0
			if self.type_list[k] then
				num = #self.type_list[k] + (self.type_list[k][0] and 1 or 0)
			end
			list[k] = v.name .. "(" .. num .. ")"
		end
	end
	return list
end

function GodWeaponEtremeData:GetWeaponList()
	return self.type_list
end

function GodWeaponEtremeData:GetAccoridtionData()
	local circle  = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	for k, v in pairs(Language.GodWeapon.TabWeaponGroup) do
		v.child = self:GetDataConfigByGroupId(v.index, circle)
	end
	return Language.GodWeapon.TabWeaponGroup
end


function GodWeaponEtremeData:GetWeaponCfg(id)
	return EquipSynthesisConfigEEx[GODWEAPONETREMEDATA_TYPE.WEAPON][id]
	
end


function GodWeaponEtremeData:GetWeaponDecomposeCfg(id)
	return EquipSynthesisConfigEEx[GODWEAPONETREMEDATA_TYPE.DECOMPOSE][id] 

end


function GodWeaponEtremeData:GetDataConfigByGroupId(groupId,circle)
	local data = EquipSynthesisConfigEEx[GODWEAPONETREMEDATA_TYPE.WEAPON] or {}
	
	local cur_data = {}
	local cur_index = 1
	for k, v in pairs(data) do
		if v.groupId == groupId then
			if circle >= v.circle then
				cur_data[cur_index] = {name = "", index = cur_index, item_id = v.newEquipId, consume_id = k,equipConsumes = v.equipConsumes,
					materialConsumes = v.materialConsumes,
					inheritConsumes = v.inheritConsumes, child = {}}
				cur_data[cur_index].name = self:GetEquipName(v.newEquipId)
				cur_index = cur_index + 1
			end
		end
	end
	local function sort(a, b)
		if a.item_id ~= b.item_id then
			return a.item_id < b.item_id
		end
	end
	table.sort(cur_data, sort)
	local new_index = 1
	for k, v in pairs(cur_data) do
		v.index = new_index
		new_index = new_index + 1
	end
	return cur_data
end

function GodWeaponEtremeData:GetEquipName(k)
	local config = ItemData.Instance:GetItemConfig(k)
	if config ~= nil then
		return config.name
	end
	return ""
end

function GodWeaponEtremeData:GetBodyEquipbyItemID(item_id)
	local data = EquipData.Instance:GetDataList()
	for k, v in pairs(data) do
		if v.item_id == item_id  then
			return v
		end
	end
	return nil
end

function GodWeaponEtremeData:SetPointShow(index)
	local data = EquipSynthesisConfigEEx[index]
	local circle  = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local num = 0

	for k, v in pairs(data) do
		if v.newEquipId ~= nil then
			if circle >= v.circle then
				local comsume_circle = 0
				local config = ItemData.Instance:GetItemConfig(v.newEquipId)
				for k3, v3 in pairs(config and config.conds or {}) do
					if v3.cond == ItemData.UseCondition.ucMinCircle then
						comsume_circle = v3.value
					end
				end
				if circle >= comsume_circle then
					num = num + self:GetBoolShowPoint(k, v.equipConsumes, v.materialConsumes)
				end
			end
		end
	end
	return num
end

function GodWeaponEtremeData:GetBoolShowPoint(consume_id, equipConsumes, materialConsumes)
	if GodWeaponEtremeData.Instance:GetBodyEquipbyItemID(consume_id) ~= nil then
		local consume_num = 0 
		for k1, v1 in pairs(equipConsumes) do
			if ItemData.Instance:GetItemNumInBagById(v1.id, nil) >= v1.count then
				consume_num = consume_num + 1
			end
		end
		local material_num = 0 
		for k2, v2 in pairs(materialConsumes) do
			if ItemData.Instance:GetItemNumInBagById(v2.id, nil) >= v2.count then
				material_num = material_num + 1
			end
		end
		if consume_num >= #equipConsumes and material_num >= #materialConsumes then
			return 1
		end
	else
		local cs_num = ItemData.Instance:GetItemNumInBagById(consume_id, nil)
		local consume_num = 0 
		for k1, v1 in pairs(equipConsumes) do 
			local count = v1.count
			if consume_id == v1.id then 
				count = v1.count + 1
			end
			if ItemData.Instance:GetItemNumInBagById(v1.id, nil) >= count then
				consume_num = consume_num + 1
			end
		end
		local material_num = 0 
		for k2, v2 in pairs(materialConsumes) do
			if ItemData.Instance:GetItemNumInBagById(v2.id, nil) >= v2.count then
				material_num = material_num + 1
			end
		end
		if cs_num > 0 and consume_num >= #equipConsumes and material_num >= #materialConsumes then
			return 1
		end
	end
	return 0
end

function GodWeaponEtremeData:GetUpRedPointGroup()
	local num_1 = self:SetPointShow(GODWEAPONETREMEDATA_TYPE.WEAPON)
	local num_2 = self:SetPointShow(GODWEAPONETREMEDATA_TYPE.FASHION)
	return (num_1 + num_2) >= 1 and 1 or 0
end

function GodWeaponEtremeData:GetWeaponCanUp()
	return self:SetPointShow(GODWEAPONETREMEDATA_TYPE.WEAPON)
end

function GodWeaponEtremeData:GetFashionCanUp()
	return self:SetPointShow(GODWEAPONETREMEDATA_TYPE.FASHION)
end

function GodWeaponEtremeData:GetFashionPointByItemId(groupId)
	local fashion_data = GodWeaponEtremeData.Instance:GetChildListDataBy(groupId)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local num = 0
	for k, v in pairs(fashion_data) do
		local comsume_circle = 0
		local config = ItemData.Instance:GetItemConfig(v.preview_id)
		for k1, v1 in pairs(config.conds) do
			if v1.cond == ItemData.UseCondition.ucMinCircle then
				comsume_circle = v1.value
			end
		end
		
		if circle >= comsume_circle then
			num = num + self:GetBoolShowPoint(v.consume_id, v.equipConsumes, v.materialConsumes)
		end
	end
	return num
end

function GodWeaponEtremeData:GetWeaponPointByItemId(groupId, circle)
	local weapon_data = GodWeaponEtremeData.Instance:GetDataConfigByGroupId(groupId,circle)
	local num = 0
	for k, v in pairs(weapon_data) do
		local comsume_circle = 0
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		for k1, v1 in pairs(config.conds) do
			if v1.cond == ItemData.UseCondition.ucMinCircle then
				comsume_circle = v1.value
			end
		end
		if circle >= comsume_circle then
			num = num + self:GetBoolShowPoint(v.consume_id, v.equipConsumes, v.materialConsumes)
		end
	end
	return num
end


function GodWeaponEtremeData:GetDecomposeNum(data, index)
	local recycle_num = 0
	if index == GODWEAPONETREMEDATA_TYPE.FASHION then
		for k, v in pairs(data) do
			local config = GodWeaponEtremeData.Instance:GetUpConfigIdbuId(v.item_id)
			recycle_num = recycle_num + config.recycleAwards[1].count
		end
	else
		for k, v in pairs(data) do
			local config = GodWeaponEtremeData.Instance:GetWeaponDecomposeCfg(v.item_id)
			recycle_num = recycle_num + config.recycleAwards[1].count
		end
	end
	return recycle_num
end

function GodWeaponEtremeData:GetShowBySuitId(suitId, index)
	local data = {}
	if index == 1 then
		data = EquipData.Instance:GetExtremeData()
	elseif index == 3 then
		data = ZhanjiangData.Instance:GetShowGrid()
	elseif index == 2 then
		data = BrowseData.Instance:GetExtremeData()
	end
	local color = {}
	local num  = 0
	for i, v in ipairs(EquipType) do
		color[i] = "afafaf"
		for k1, v1 in pairs(data) do
			local itemConfig = ItemData.Instance:GetItemConfig(v1.item_id)
			if itemConfig.type == v and itemConfig.suitId == suitId then 
				color[i] = "00ff00"
			end  
		end
	end
	local n = 0
	local m = 0
	for k, v in pairs(data) do
		local itemConfig = ItemData.Instance:GetItemConfig(v.item_id)
		if itemConfig.suitId == suitId then
			num = num + 1
			if itemConfig.type == ItemData.ItemType.itBracelet then
				n = n + 1
			end
			if itemConfig.type == ItemData.ItemType.itRing then
				m = m + 1
			end
		end
	end
	if n >=2 then 
		num = num - 1
	end
	if m >= 2 then 
		num = num - 1
	end 
	return color, num
end

function GodWeaponEtremeData:GetServerAttrConfig(suitId, prof)
	 local attr_t = ConfigManager.Instance:GetServerConfig("attr/EquipPosSuitAttrsConfig")[1][suitId]
	 local attr_t_list = {}
	 for i, v in ipairs(attr_t) do
	 	attr_t_list[i] = {}
 		for k1, v1 in pairs(v) do
 			if v1.job == nil or v1.job == prof then
 				table.insert(attr_t_list[i], v1)
 			end
 		end
	 end
	return attr_t_list
end

function GodWeaponEtremeData:GetBoolHad(item_id, series)
	local data = ItemData.Instance:GetItemData(item_id)
	local n = 0
	local m = 0
	for k, v in pairs(data) do
		if v.series ~= series then
			if EquipmentData.Instance:BoolPropertyEquip(v) then
				m = m + 1
			else
				n = n + 1
			end
		end
	end
	return m > 0  and true or false
end

function GodWeaponEtremeData:GetBoolFlushTabbarByItemId(item_id, index)
	local data = EquipSynthesisConfigEEx[index] or {}
	for k,v in pairs(data) do
		if k == item_id then
			return true
		else
			if type(v.equipConsumes) ~= "table" then
				return false
			end
			for k1,v1 in pairs(v.equipConsumes) do
				if v1.id == item_id then
					return true
				end
			end
			for k2,v2 in pairs(v.materialConsumes) do
				if v2.id == item_id then
					return true
				end
			end
		end
	end
	return false
end
