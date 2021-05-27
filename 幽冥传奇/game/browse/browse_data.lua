BrowseData = BrowseData or BaseClass()

function BrowseData:__init()
	if BrowseData.Instance ~= nil then
		ErrorLog("[BrowseData] Attemp to create a singleton twice !")
	end
	BrowseData.Instance = self

	self.role_info = {}
	self.all_qianghua_level = 0
	self.suit_level = 0
	self.gem_level = 0
	self.level_t = {}
	self.suit_level_t = {}
	self.gem_Lv_list = {}
	self.max_data = {}
	self.index_t = {}
	self.godequip_level = 0
	self.godequip_level_t = {}
	self.god_index_t = {}
	self.chuanshi_equip = {}
	self.hao_equip = {}
	self.all_equips = {}
	
	self.xinghun_equip = {}
	self.shouhu_equip = {}
end

function BrowseData:__delete()
	BrowseData.Instance = nil
end

function BrowseData:SetRoleInfo(vo)
	self.role_info = vo
	self.role_info.grid_data_list = {}
	-- if self.item_cfg_call_back == nil then
	-- 	self.item_cfg_call_back = ItemData.Instance:NotifyItemConfigCallBack(BindTool.Bind(self.ItemConfigCallback, self))
	-- end
	--self:SortEquipList()
	--self:SetQianghuaALLLevel()
	--print(self.role_info.chuanshi_info)
	self.chuanshi_equip = {}
	self.all_equips = {}
	for k, v in pairs(self.role_info.equip_list) do
		local  item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local slot = EquipData.Instance:GetEquipSlotByType(item_cfg.type, v.hand_pos)
		if slot >=  EquipData.EquipSlot.itHandedDownWeaponPos and  slot <= EquipData.EquipSlot.itHandedDownShoesPos then
			self.chuanshi_equip[slot] = v
		end
		if slot >=  EquipData.EquipSlot.itSubmachineGunPos and  slot <= EquipData.EquipSlot.itMaxLuxuryEquipPos then
			self.hao_equip[slot] = v
		end
		self.all_equips[slot] = v
	end
	self.xinghun_equip = {}
	for k, v in pairs(self.role_info.xing_hun_equip) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local type = item_cfg.stype or 0
		self.xinghun_equip[type] = v
	end

	local equip_list = {}
	for k, v in pairs(self.role_info.shou_hu_shen_zhuang) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		local type = item_cfg.stype or 0
		equip_list[type] = v
	end


	local cfg = GuardGodEquipConfig or {}
	local max_slot = cfg.max_slot or 7
	for e_type = 1, 4 do
		self.shouhu_equip[e_type - 1] = {}
		for slot = 0, max_slot - 1 do
			local slot1 = (e_type - 1) * max_slot + slot
			self.shouhu_equip[e_type - 1][slot + 1] = equip_list[slot1]
		end
	end
end

-- function BrowseData:ItemConfigCallback(item_config_t)
	-- for k,v in pairs(item_config_t) do
	-- 	for k1,v1 in pairs(self.role_info.equip_list) do
	-- 		if v.item_id == v1.item_id then
	-- 			self:SortEquipList()
	-- 			break
	-- 		end
	-- 	end
	-- end

-- end

-- function BrowseData:SortEquipList()
	-- for k,v in pairs(self.role_info.equip_list) do
	-- 	local index = EquipData.Instance:GetEquipIndexByType(v.type, v.hand_pos)
	-- 	if index >= 0 then
	-- 		v.index = index
	-- 		v.slot_strength = self:GetOneStrengthLvByEquipIndex(index)
	-- 		v.slot_xuelian = self:GetOneXuelianLvByEquipIndex(index)
	-- 		v.slot_soul = self:GetOneSoulLvByEquipIndex(index)
	-- 		v.slot_chuanshi = self:GetOneChuanshiLvByEquipIndex(index)
	-- 		v.slot_affinage = self:GetOneAffinageLvByEquipIndex(index)
	-- 		local inlay_list = self:GetOneInlayListByEquipIndex(index)
	-- 		if inlay_list then
	-- 			for k1, v1 in pairs(inlay_list) do 
	-- 				v["slot_" .. k1] = v1
	-- 			end
	-- 		end
	-- 		self.role_info.grid_data_list[index] = v
	-- 	end
	-- end
	-- local prof = self.role_info[OBJ_ATTR.ACTOR_PROF]
	
	-- -- local offic = self.role_info[OBJ_ATTR.ACTOR_STONE]
	-- -- if offic > 0 then
	-- -- 	local offic_data = CommonStruct.ItemDataWrapper()
	-- -- 	offic_data.item_id = OFFICE_ID[prof]
	-- -- 	offic_data.num = 1
	-- -- 	offic_data.is_bind = 1
	-- -- 	offic_data.office_level = offic
	-- -- 	self.role_info.grid_data_list[EquipData.EquipIndex.AnklePad] = offic_data
	-- -- end

	-- local ring_soul_level = ComposeData.Instance:GetRingSoulAllLevel(self.role_info)
 --    local ring_data_r = self.role_info.grid_data_list[EquipData.EquipIndex.SpecialRingR]
 --    if ring_data_r then
 --    	ring_data_r.ring_soul_level = ring_soul_level
 --    end

	-- self:SetSuitInfo()
	-- self:SetGemList()
	-- self:SetGodEquipData()
-- end

-- function BrowseData:GetOneStrengthLvByEquipIndex(index)
-- 	local slot = QianghuaData.GetStrengthIndex(index)
-- 	local strengthen_level = self.role_info.equip_slots[slot]
-- 	return strengthen_level
-- end

function BrowseData:GetOneXuelianLvByEquipIndex(index)
	return self.role_info.blood_info[index - EquipData.EquipIndex.PeerlessWeaponPos]
end

function BrowseData:GetOneSoulLvByEquipIndex(index)
	return self.role_info.soul_info[index - EquipData.EquipIndex.Weapon]
end

function BrowseData:GetOneChuanshiLvByEquipIndex(index)
	return self.role_info.blood_info[index - EquipData.EquipSlot.itHandedDownWeaponPos + 1]
end

function BrowseData:GetOneInlayListByEquipIndex(index)
	return self.role_info.stone_info[index - EquipData.EquipIndex.Weapon + 1]
end

function BrowseData:GetOneAffinageLvByEquipIndex(index)
	return self.role_info.affinage_info[index - EquipData.EquipIndex.Weapon + 1]
end

function BrowseData:GetChuanShiEquipByIndex(index)
	return self.chuanshi_equip[index]
end

function BrowseData:GetHowEquip( slot )
	return self.hao_equip[slot]
end

function BrowseData:GetEquipBySolt(slot)
	return self.all_equips[slot]
end

function BrowseData:GetRoleInfo()
	return self.role_info
end

function BrowseData:GetAttr(key)
	return self.role_info[key]
end

function BrowseData:SetSuitInfo()
	self.suit_level_t = {}
	self.index_t = {}
	local n = 0
	for k,v in pairs(self.role_info.grid_data_list) do
		for k1, v1 in pairs(SuitPlusConfig) do
			for i,v2 in ipairs(v1.items) do
				if v.item_id == v2 then
					self.suit_level_t[k1] = self.suit_level_t[k1] or 0
					self.suit_level_t[k1] = self.suit_level_t[k1] + 1
					self.index_t[k] = k1
				end
			end
		end
	end
	self.level_t = {}
	local level = 1
	self.suit_level = 0
	local function suit()
		if self.suit_level_t[level] then
			self.level_t[level] = self.suit_level_t[level]
			for k,v in pairs(self.suit_level_t) do
				if k > level then
					self.level_t[level] = self.level_t[level] + v
				end
			end
			if self.level_t[level] >= #SuitPlusConfig[level].items then
				if level > self.suit_level then
					self.suit_level = level
				end
			end
		end
		level = level + 1
		if level <= #SuitPlusConfig then
			suit()
		end
	end
	suit()
end

function BrowseData:SetGodEquipData()
	local sex = self.role_info[OBJ_ATTR.ACTOR_SEX] 
	if sex == nil then return end
	local config = HallowRuleData.Instance:GetConfig(sex)
	self.god_equip = {}
	for k,v in pairs(self.role_info.grid_data_list) do
		if k == 18 or k == 20 then
			self.god_equip[k] = v.item_id
		end
	end	
	self.godequip_level_t = {}	
	self.god_index_t = {}
	for k,v in pairs(self.god_equip) do
		for k1, v1 in pairs(config) do
			for i,v2 in ipairs(v1.items) do
				if v == v2 then
					self.godequip_level_t[k1] = self.godequip_level_t[k1] or 0
					self.godequip_level_t[k1] = self.godequip_level_t[k1] + 1 
					self.god_index_t[k] = k1
				end
			end
		end
	end
	local count = 0
	local level = 0
	self.godequip_level = 0
	self.god_level_t = {}
	local function suit()
		if self.godequip_level_t[level] then
			self.god_level_t[level] = self.godequip_level_t[level]
			for k,v in pairs(self.godequip_level_t) do
				if k > level then
					self.god_level_t[level] = self.god_level_t[level] + v
				end
			end
			if self.god_level_t[level] >= #config[level].items then
				if level >= self.godequip_level then
					self.godequip_level = level
				end
			end
		end
		level = level + 1
		if level <= #config then
			suit()
		end
	end
	suit()
end

function BrowseData:GetGodAddLevel()
	return self.godequip_level
end

function BrowseData:GetGodEquipCount(level)
	local num = 0
	for k,v in pairs(self.godequip_level_t) do
		if k >= level then
			num = num + v
		end
	end
	return num
end

function BrowseData:GetGodEquipData(level)
	local data = {}
	local z = 0
	for k,v in pairs(self.god_index_t) do
		z = z + 1
	end
	for i = 1, 2 do
		if z ~= 0 then
			for k, v in pairs(self.god_index_t) do
				if v >= level then
					data[(math.floor(k/10))] = 1
				end
			end
		else
			data[i] = 0
		end
	end 
	return data
end

--通过等级得到套装数量
function BrowseData:GetSuitNum(suit_level)
	local num = 0
	for k,v in pairs(self.suit_level_t) do
		if k >= suit_level then
			num = num + v
		end
	end
	return num
end

function BrowseData:GetSuitLevelList()
	return self.suit_level_t
end

--得到套装等级
function BrowseData:GetSuitLevel()
	return self.suit_level
end

function BrowseData:SetQianghuaALLLevel()
	self.all_qianghua_level = 0
	for k,v in pairs(self.role_info.equip_slots) do
		self.all_qianghua_level = self.all_qianghua_level + v
	end
end

--得到所有强化等级
function BrowseData:GetQinghuaAdditionLevel()
	return self.all_qianghua_level
end

--当前Tips等级
function BrowseData:GetAdditionTipLevel()
	local z = 0
	if self.all_qianghua_level < 60 then
		return z
	elseif self.all_qianghua_level >= 480 or self.all_qianghua_level> 30 and  self.all_qianghua_level % 30 == 0 then
		return math.ceil((self.all_qianghua_level-60)/30) + 1
	else
		return math.ceil((self.all_qianghua_level-60)/30)
	end  
end

--宝石
function BrowseData:SetGemList()
	self.gem_Lv_list = {}
	local gem_list = {}
	for k,v in pairs(self.role_info.grid_data_list) do
		gem_list[k] = {}
		for i = 1, 6 do
			local lv = v["slot_" .. i]
			gem_list[k][i] = lv or 0
		end
	end
	local data = {}
	for k,v in pairs(gem_list) do
		if k <= 11 and k ~= 4 then
			data[k] = v
		end
	end
	self.max_data = data
	local max_level = 1
	local stone_plus_cfg = {}
	for key, value in pairs(StonePlusCfg) do
		if value.level >= max_level then
			max_level = value.level
		end
		stone_plus_cfg[value.level] = value.count
	end
	local level_data = {}
	for i = 1, max_level do
		for k, v in pairs(data) do
			for key, value in pairs(v) do
				if value >= i then
					if level_data[i] == nil then
						level_data[i] = {num = 0, equips = {}}
					end
					level_data[i].num = level_data[i].num + 1
					table.insert(level_data[i].equips, k)
					break
				end
			end
		end
	end
	self.gem_level = 0
	for k, v in pairs(level_data) do
		if stone_plus_cfg[k] and v.num >= stone_plus_cfg[k] then
			if k >= self.gem_level then
				self.gem_level = k
			end
		end
	end
	for k,v in pairs(self.max_data) do
		local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
			return function(c, d)
				if c ~= d then
					return c < d
				end
				return c < d
 			end
		end
		table.sort(self.max_data[k], sort_list()) 
	end
	for k,v in pairs(self.max_data) do
		self.max_data[k] = v[5]
	end
end

--得到镶嵌宝石的数目
function BrowseData:GetAllGemNum(gem_level)
	local num = 0
	for k, v in pairs(self.max_data) do
		if v >= gem_level then
			num = num + 1
		end
	end
	return num
end

function BrowseData:GetIndexData()
	return self.index_t
end

function BrowseData:GetStoneData()
	return self.max_data
end

function BrowseData:GetGemLevel()
	return self.gem_level
end

function BrowseData:GetData(gem_level)
	local data = {}
	local z = 0 
	for k,v in pairs(self.max_data) do
		z = z + 1
	end
	for i = 1, 10 do
		if z ~= 0 then
			for k, v in pairs(self.max_data) do
				if k <= 4 then
					if v >= gem_level then
						data[k+1] = 1
					else
						data[k+1] = 0
					end
				else
					if v >= gem_level then
						data[k] = 1
					else
						data[k] = 0
					end	
				end
			end
		else 
			data[i] = 0
		end
	end
	return data
end

function BrowseData:GetSuitData(suit_level)
	local data = {}
	local z = 0
	for k,v in pairs(self.index_t) do
		z = z + 1
	end
	for i = 1, 5 do
		if z ~= 0 then
			for k, v in pairs(self.index_t) do
				if k - 20 == i then
					if v >= suit_level then
						data[i] = 1
					else
						data[i] = 0
					end
				end
			end
		else
			data[i] = 0
		end
	end 
	return data
end


function BrowseData:SetOutLinePlayerInfo(vo)
	if not vo then return end
	self.out_line_player_vo = vo
end


function BrowseData:GetXinghunData(index)
	return self.xinghun_equip[index]
end

function BrowseData:GetShouHuData( ... )
	return self.shouhu_equip
end