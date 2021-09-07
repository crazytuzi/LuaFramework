-------------------------------------------
--主角服装数据
--------------------------------------------

FashionData = FashionData or BaseClass()

SHIZHUANG_TYPE = {
	WUQI = 0,
	BODY = 1,
	MAX = 2,
}

SHIZHUANG_TYPE_KEY = {
	WUQI = 0,
	BODY = 1,
	MOUNT = 2,
	WING = 3,
}

SHIZHUANG = {
	SHIZHUANG_MAX_LEVEL = 20,
	SHIZHUANG_MAX_INDEX = 31,
	SHIZHUANG_CROSS_RANK_REWARD_INDEX = 30,
}

function FashionData:__init()
	if FashionData.Instance then
		print_error("[FashionData] 尝试创建第二个单例模式")
	end
	FashionData.Instance = self
	self.clothing_act_id_list = {}
	self.wuqi_act_id_list = {}
	self.clothing_act_id_list = {}
	self.upgrade_list = {}
	self.fashion_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	self.fashion_level_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").upgrade
	--self.jinjie_type = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").jinjie_type
	self.canupgrade_cfg_list = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").can_upgrade
	RemindManager.Instance:Register(RemindName.PlayerFashion, BindTool.Bind(self.GetPlayerFashionRemind, self))


	self.master_fla_list = {}
	self.master_collect = ConfigManager.Instance:GetAutoConfig("other_config_auto").master_collect
	self.master_show = ConfigManager.Instance:GetAutoConfig("other_config_auto").show

	self.cur_show_item_list = {}		-- 当前显示数据

	self.fashion_cfg = ListToMap(self.fashion_cfg_list or {}, "part_type","index")
	self.fashion_upgrade_cfg1 = ListToMap(self.fashion_level_cfg or {}, "part_type","index","level")
	self.fashion_upgrade_cfg2 = ListToMap(self.fashion_level_cfg or {}, "part_type","index")
	
end

function FashionData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerFashion)
	
	FashionData.Instance = nil
	self.upgrade_list = {}
end

--同步已经激活的服装
function FashionData:SetClothingActFlag(act_flag)
	local ative_flag_list = bit:d2b(act_flag)

	self.clothing_act_id_list = {}
	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.BODY then
			self.clothing_act_id_list[v.index] = ative_flag_list[32 - v.index]
		end
	end

end

--服装是否激活
function FashionData:GetClothingActFlag(index)
	return self.clothing_act_id_list[index]
end

function FashionData:GetFashionCfgs()
	return self.fashion_cfg_list
end

function FashionData:GetShowSpecialInfo()
	local num = 0
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local active_list = self.clothing_act_id_list or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self.fashion_cfg_list) do
		if v ~= nil then
			if (v.show_level ~= nil and role_level >= v.show_level) and (v.open_day ~= nil and open_day >= v.open_day) then
				num = num + 1
				table.insert(show_list, v)
			else
				local need_item = v.active_stuff_id
				local has_num = ItemData.Instance:GetItemNumInBagById(need_item)
				if self:GetFashionActFlag(v.part_type, v.index) == 1 or has_num > 0 then
					num = num + 1
					table.insert(show_list, v)					
				end
			end
		end
	end

	local function sort_function(a, b)
		return a.index < b.index
	end
	table.sort(show_list, sort_function)

	return num, show_list
end

function FashionData:CheckIsFashionItem(item_id)
	local is_item = false
	if item_id == nil or self.fashion_cfg_list == nil then
		return
	end

	for k,v in pairs(self.fashion_cfg_list) do
		if v ~= nil and v.active_stuff_id == item_id then
			is_item = true
			break
		end
	end

	return is_item
end

--同步已经激活的武器
function FashionData:SetWuqiActFlag(act_flag)
	local ative_flag_list = bit:d2b(act_flag)

	self.wuqi_act_id_list = {}
	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.WUQI then
			self.wuqi_act_id_list[v.index] = ative_flag_list[32 - v.index]
		end
	end
end

--武器是否激活
function FashionData:GetWuqiActFlag(index)
	return self.wuqi_act_id_list[index]
end

-- 时装是否激活
function FashionData:GetFashionActFlag(part_type, index)
	if part_type == SHIZHUANG_TYPE.WUQI then
		return self.wuqi_act_id_list[index]
	elseif part_type == SHIZHUANG_TYPE.BODY then
		return self.clothing_act_id_list[index]
	end
end

function FashionData:CheckIsActiveByItem(part_type, item_id)
	local is_active = false
	local value = nil
	local index = nil
	if part_type == SHIZHUANG_TYPE_KEY.WUQI then
		if self.wuqi_act_id_list == nil then
			return is_active, value
		end

		for k,v in pairs(self.fashion_cfg_list) do
			if v.part_type == part_type and v.active_stuff_id == item_id then
				index = v.index
				break
			end
		end

		if index and self.wuqi_act_id_list[index] then
			is_active =  self.wuqi_act_id_list[index] == 1
			value = index
		end
	elseif part_type == SHIZHUANG_TYPE_KEY.BODY then
		if self.clothing_act_id_list == nil then
			return is_active, value
		end

		for k,v in pairs(self.fashion_cfg_list) do
			if v.part_type == part_type and v.active_stuff_id == item_id then
				index = v.index
				break
			end
		end

		if index and self.clothing_act_id_list[index] then
			is_active =  self.clothing_act_id_list[index] == 1
			value = index
		end
	elseif part_type == SHIZHUANG_TYPE_KEY.MOUNT then
		is_active, value = MountData.Instance:CheckHHIsActiveByItem(item_id)
	elseif part_type == SHIZHUANG_TYPE_KEY.WING then
		is_active, value = WingData.Instance:CheckHHIsActiveByItem(item_id)
	end

	return is_active, value
end

--同步使用中的服装
function FashionData:SetUseClothingIndex(use_clothing_index)
	self.use_clothing_index = use_clothing_index
end

--获取使用中的服装
function FashionData:GetUsedClothingIndex()
	return self.use_clothing_index
end

--同步使用中的武器
function FashionData:SetUseWuqiIndex(use_wuqi_index)
	self.use_wuqi_index = use_wuqi_index
end

--获取使用中的武器
function FashionData:GetUsedWuqiIndex()
	return self.use_wuqi_index
end

-- 通关id获取时装类型和index
function FashionData:GetFashionTypeAndIndexById(id)
	for k,v in pairs(self.fashion_cfg_list) do
		if v.active_stuff_id == id then
			return v.part_type, v.index
		end
	end
	return nil, nil
end

-- 根据时装类型获取当前index
function FashionData:GetUsedFashionIndexByType(part_type)
	if part_type == SHIZHUANG_TYPE.WUQI then
		return self.use_wuqi_index
	elseif  part_type == SHIZHUANG_TYPE.BODY then
		return self.use_clothing_index
	end
end

--根据index获取服装的配置
function FashionData:GetClothingConfig(clothing_index)
	-- for k, v in pairs(self.fashion_cfg_list) do
	-- 	if v.part_type == SHIZHUANG_TYPE.BODY and clothing_index == v.index then
	-- 		return v
	-- 	end
	-- end

	if self.fashion_cfg[SHIZHUANG_TYPE.BODY] then
		return self.fashion_cfg[SHIZHUANG_TYPE.BODY][clothing_index]
	end	
	return nil
end

--根据index获取武器的配置
function FashionData:GetWuqiConfig(wuqi_index)
	-- for k, v in pairs(self.fashion_cfg_list) do
	-- 	if v.part_type == SHIZHUANG_TYPE.WUQI and wuqi_index == v.index then
	-- 		return v
	-- 	end
	-- end
	if self.fashion_cfg[SHIZHUANG_TYPE.WUQI] then
		return self.fashion_cfg[SHIZHUANG_TYPE.WUQI][wuqi_index]
	end
	return nil
end

--根据type, index获取时装的配置
function FashionData:GetFashionConfig(part_type, index)
	-- for k, v in pairs(self.fashion_cfg_list) do
	-- 	if v.part_type == part_type and index == v.index then
	-- 		return v
	-- 	end
	-- end
	if self.fashion_cfg[part_type] then
		return self.fashion_cfg[part_type][index]
	end
	return nil
end

function FashionData:CheckIsDressed(fz_type, index)
	if fz_type == SHIZHUANG_TYPE.WUQI then
		return (self.use_wuqi_index == index)
	elseif fz_type == SHIZHUANG_TYPE.BODY then
		return (self.use_clothing_index == index)
	end
end
function FashionData:CheckIsActive(fz_type, index)
	if fz_type == SHIZHUANG_TYPE.WUQI then
		return (self:GetWuqiActFlag(index) == 1)
	elseif fz_type == SHIZHUANG_TYPE.BODY then
		return (self:GetClothingActFlag(index) == 1)
	end
end

--根据时装类型获取时装配置
function FashionData:GetAllFashionConfigByType(fz_type)
	local final_list = {}
	local active_list = {}
	local not_active_list = {}

	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == fz_type then
			local data = v
			data.is_dressed = self:CheckIsDressed(data.part_type, data.index)
			data.is_active = self:CheckIsActive(data.part_type, data.index)
			if data.is_dressed then
				table.insert(final_list, data)
			elseif data.is_active then
				table.insert(active_list, data)
			else
				table.insert(not_active_list, data)
			end
		end
	end
	for k,v in pairs(active_list) do
		table.insert(final_list, v)
	end
	for k,v in pairs(not_active_list) do
		table.insert(final_list, v)
	end
	return final_list
end

--获取服装激活数
function FashionData:GetFashionActNum()
	local num = 0

	for k,v in pairs(self.clothing_act_id_list) do
		if v == 1 then
			num = num + 1
		end
	end
	for k,v in pairs(self.wuqi_act_id_list) do
		if v == 1 then
			num = num + 1
		end
	end

	return num
end

--是否有激活的时装
function FashionData:GetHasActFashion()
	for k,v in pairs(self.clothing_act_id_list) do
		if v == 1 then
			return true
		end
	end
	for k,v in pairs(self.wuqi_act_id_list) do
		if v == 1 then
			return true
		end
	end
	return false
end

--获取服装总属性和总战力
function FashionData:GetFashionTotalAttribute()
	local total_attr = CommonStruct.Attribute()
	local total_power = 0

	for k, v in pairs(self.clothing_act_id_list) do
		if v == 1 then
			-- local attr = CommonDataManager.GetAttributteByClass(self:GetClothingConfig(k), true)
			local upgrade_attr = CommonDataManager.GetAttributteByClass(self:GetFashionUpgradeCfg(k, SHIZHUANG_TYPE.BODY))
			total_power = total_power + CommonDataManager.GetCapability(upgrade_attr) --+ CommonDataManager.GetCapability(attr)
			-- total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, upgrade_attr)
		end
	end
	for k, v in pairs(self.wuqi_act_id_list) do
		if v == 1 then
			-- local attr = CommonDataManager.GetAttributteByClass(self:GetWuqiConfig(k), true)
			local upgrade_attr = CommonDataManager.GetAttributteByClass(self:GetFashionUpgradeCfg(k))
			total_power = total_power + CommonDataManager.GetCapability(upgrade_attr) -- + CommonDataManager.GetCapability(attr)
			-- total_attr = CommonDataManager.AddAttributeAttr(total_attr, attr)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, upgrade_attr)
		end
	end
	total_attr.power = total_power
	return total_attr
end

-- 根据时装物品id获取资源id
function FashionData.GetFashionResByItemId(item_id)
	if nil == item_id then return nil end
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg) do
		if v.active_stuff_id == item_id then
			return v.resouce, v.part_type, v
		end
	end
	return nil
end

-- 根据套装id获取相应配置
function FashionData:GetFashionCfg(fashion_id)
	local cfg = {}
	for k,v in pairs(self.fashion_cfg_list) do
		if v.active_stuff_id == fashion_id then
			cfg = v
		end
	end

	return cfg
end

 -- 获取总战力
-- function FashionData:GetFashionCapacityLerp(fashion_id, fashion_cur_level, fashion_next_level)
-- 	local power = 0



-- 	local cur_cfg = self:GetFashionLevelCfg(fashion_id, fashion_cur_level)
-- 	local next_cfg = self:GetFashionLevelCfg(fashion_id, fashion_next_level)

-- 	local cur_attribute = CommonDataManager.GetAttributteByClass(cur_cfg)
-- 	local next_attribute = CommonDataManager.GetAttributteByClass(next_cfg)

-- 	local attribute = CommonDataManager.LerpAttributeAttr(cur_attribute, next_attribute)
-- 	return CommonDataManager.GetCapability(attribute)
-- end

function FashionData:SetFashionUpgradeInfo(upgrade_list)
	self.upgrade_list = upgrade_list
end

function FashionData:GetFashionUpgradeInfo()
	return self.upgrade_list or {}
end

-- 获取当前等级
function FashionData:GetCurLevel(index, part_type)
	local level = 0
	level = (self.upgrade_list[part_type] and self.upgrade_list[part_type].level_list) and self.upgrade_list[part_type].level_list[index] or 0
	return level
end

-- 默认是武器类型
function FashionData:GetFashionUpgradeCfg(index, part_type, is_next, level)
	local part_type = part_type or 0
	if not index then return nil end

	local level = level or (self.upgrade_list[part_type] and self.upgrade_list[part_type].level_list) and self.upgrade_list[part_type].level_list[index] or 0
	if is_next then
		level = level + 1
	else
		level = level > 0 and level or 1
	end
	--level = level >= self:GetFashionMaxUpgrade(index, part_type) and self:GetFashionMaxUpgrade(index, part_type) or level
	-- for k, v in pairs(self.fashion_level_cfg) do
	-- 	if v.part_type == part_type and v.index == index and v.level == level then
	-- 		return v
	-- 	end
	-- end
	if self.fashion_upgrade_cfg1[part_type] and self.fashion_upgrade_cfg1[part_type][index] then
		return self.fashion_upgrade_cfg1[part_type][index][level]
	end
	return nil
end

-- 默认是武器类型
function FashionData:GetFashionSameTypeList(part_type)
	local list = {}
	local part_type = part_type or 0
	local _, data = self:GetShowSpecialInfo()
	for k,v in pairs(data) do
		if v.part_type == part_type then
			table.insert(list, v)
		end
	end
	return list
end

function FashionData:GetFashionMaxUpgrade(index, part_type)
	local part_type = part_type or 0
	local count = 0
	if not index then return count end
	-- for k, v in pairs(self.fashion_level_cfg) do
	-- 	if v.part_type == part_type and v.index == index then
	-- 		count = count + 1
	-- 	end
	-- end
	if self.fashion_upgrade_cfg2[part_type] and self.fashion_upgrade_cfg2[part_type][index] then
		count = count + 1
	end
	return count
end

function FashionData:GetPlayerFashionRemind()
	return (self:IsShowJinjieRedPoint() or self:IsShowMountRed() or self:IsShowWingRed()) and 1 or 0
end

function FashionData:IsShowJinjieRedPoint()
	for k, v in pairs(self.fashion_level_cfg) do
		local level = (self.upgrade_list[v.part_type] and self.upgrade_list[v.part_type].level_list) and self.upgrade_list[v.part_type].level_list[v.index] or 0
		if self:GetFashionActFlag(v.part_type, v.index) then
			level = level + 1
		end
		level = level > 0 and level or 1
		if v.level == level and v.stuff_count <= ItemData.Instance:GetItemNumInBagById(v.need_stuff) then
			return true
		end
	end
	return false
end

-- 默认是衣服
function FashionData:IsShowRedPointByType(part_type)
	local part_type = part_type or SHIZHUANG_TYPE.BODY
	for k, v in pairs(self.fashion_level_cfg) do
		if v.part_type == part_type then
			local level = (self.upgrade_list[v.part_type] and self.upgrade_list[v.part_type].level_list) and self.upgrade_list[v.part_type].level_list[v.index] or 0
			if self:GetFashionActFlag(v.part_type, v.index) then
				level = level + 1
			end
			level = level > 0 and level or 1
			if v.level == level and v.stuff_count <= ItemData.Instance:GetItemNumInBagById(v.need_stuff) then
				return true
			end
		end
	end
	return false
end

-- 坐骑幻化
function FashionData:IsShowMountRed()
	local mount_cfg = MountData.Instance:GetSpecialImagesCfg()
	for i = 1, #mount_cfg do
		local image_id = mount_cfg[i].image_id
		local upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(image_id)
		local level_max = MountData.Instance:GetSpecialImageMaxUpLevelById(image_id)
		if upgrade_cfg then
			local stuff_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.stuff_id)
			local cur_level = upgrade_cfg.grade
			if stuff_num >= 1 and cur_level < level_max then
				return true
			end
		end
	end
	return false
end

-- 羽翼幻化
function FashionData:IsShowWingRed()
	local wing_cfg = WingData.Instance:GetSpecialImagesCfg()
	for i = 1,#wing_cfg do
		local image_id = wing_cfg[i].image_id
		local upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(image_id)
		local level_max = WingData.Instance:GetSpecialImageMaxUpLevelById(image_id)
		if upgrade_cfg then
			local stuff_num = ItemData.Instance:GetItemNumInBagById(upgrade_cfg.stuff_id)
			local cur_level = upgrade_cfg.grade
			if stuff_num >= 1 and cur_level < level_max then
				return true
			end
		end
	end
	return false
end

-- 套装列表
function FashionData:GetMasterCollectListCfg()
	return self.master_collect
end

function FashionData:GetMasterCfgById(id)
	for k,v in pairs(self.master_collect) do
		if v.weapon_id == id or v.dress_id == id or v.mount_id == id or v.wing_id == id then
			return v
		end
	end
	
	return nil
end

function FashionData:GetShowMasterCollectInfo()
	local show_list = {}
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	for k,v in pairs(self.master_collect) do
		local active_num = self:GetMasterNum(v.seq + 1)
		if v ~= nil then
			if ((v.show_level ~= nil and role_level >= v.show_level) and (v.open_day ~= nil and open_day >= v.open_day)) or active_num > 0 then
				table.insert(show_list, v)
			end
		end
	end

	return show_list
end

function FashionData:GetMasterShow(index)
	local data_list = {}
	for i,v in ipairs(self.master_show) do
		if index == v.index then
			table.insert(data_list, v)
		end
	end
	return data_list
end

function FashionData:GetMasterShowId(index, item_id)
	local item_info = self:GetMasterShow(index)
	if item_info then
		for k,v in pairs(item_info) do
			if item_id == v.id then
				return v.show_id
			end
		end
	end
	return 0
end

function FashionData:SetMasterActiveFla(fla_list)
	self.master_fla_list = fla_list
end

-- 获取激活index
function FashionData:GetMasterFlaIndex(index)
	if index == SHIZHUANG_TYPE_KEY.MOUNT then
		return 1
	elseif index == SHIZHUANG_TYPE_KEY.WING then
		return 2
	elseif index == SHIZHUANG_TYPE_KEY.WUQI then
		return 3	
	elseif index == SHIZHUANG_TYPE_KEY.BODY then
		return 4	
	end
end

-- 获取激活标记1坐骑，2羽翼，3时装， 4武器
function FashionData:GetMasterActiveFla(seq, index)
	if seq <= 0 then return false end
	local bit_list = bit:d2b(self.master_fla_list[seq].flag)
	return bit_list[32 - index]
end

function FashionData:GetMasterNum(seq)
	local bit_list = bit:d2b(self.master_fla_list[seq].flag)
	local num = 0
	for i=1,4 do
		if bit_list[32 - i] == 1 then
			num = num + 1
		end
	end
	return num
end

function FashionData:SetClickIndex(index)
	self.click_index = index
end

function FashionData:GetClickIndex()
	return self.click_index or 1
end

function FashionData:GetCurFashionList()
	local cur_wuqi_cfg = self:GetWuqiConfig(self.use_wuqi_index)
	local cur_clothing_cfg = self:GetClothingConfig(self.use_clothing_index)

	local cur_mount_cfg = self:GetMountImageidCfg(MountData.Instance:GetMountInfo().used_imageid)
	local cur_wing_cfg = self:GetWingImageidCfg(WingData.Instance:GetWingInfo().used_imageid)

	local wuqi_id = cur_wuqi_cfg and cur_wuqi_cfg.active_stuff_id or nil
	local clothing_id = cur_clothing_cfg and cur_clothing_cfg.active_stuff_id or nil
	local mount_id = cur_mount_cfg and cur_mount_cfg.item_id or nil
	local wing_id = cur_wing_cfg and cur_wing_cfg.item_id or nil
	return {[1] = {item_id = wuqi_id}, [2] = {item_id = clothing_id}, [3] = {item_id = mount_id}, [4] = {item_id = wing_id}}
end

function FashionData:GetMountImageidCfg(used_imageid)
	if used_imageid >= 1000 then
		return MountData.Instance:GetSpecialImageCfg(used_imageid - 1000)
	else
		return MountData.Instance:GetMountImageCfg(used_imageid)
	end
end

function FashionData:GetWingImageidCfg(used_imageid)
	if used_imageid >= 1000 then
		return WingData.Instance:GetSpecialImageCfg(used_imageid - 1000)
	else
		return WingData.Instance:GetWingImageCfg(used_imageid)
	end
end

function FashionData:SetCurItemListData(item_list, seq)
	self.cur_show_item_list = {}
	for k,v in pairs(SHIZHUANG_TYPE_KEY) do
		local index = self:GetMasterFlaIndex(v)
		if item_list and item_list[index] and item_list[index].item_id > 0 then
			self.cur_show_item_list[v + 1] = item_list[index]
			self.cur_show_item_list[v + 1].show_order = v
			self.cur_show_item_list[v + 1].seq = seq
		end
	end
end

-- 获取当前显示的item
function FashionData:GetCurItemListData()
	return self.cur_show_item_list
end

-- 获取形象配置
function FashionData:GetUpGradeCfg(cur_cell_index, toggle_state)
	if toggle_state == SHIZHUANG_TYPE_KEY.WUQI or toggle_state == SHIZHUANG_TYPE_KEY.BODY then
		return self:GetMasterShow(cur_cell_index - 1)[toggle_state + 1]
	else
		return self:GetMasterShow(cur_cell_index)[toggle_state + 1]
	end
end

-- 只拿套装列表
function FashionData:GetMountSpecialImagesCfg(cfg_list)
	local cfg = {}
	for i,v in ipairs(cfg_list) do
		if v.is_suit and v.is_suit then
			table.insert(cfg, v)
		end
	end
	return cfg
end

function FashionData:GetCurIndex()
	local index_list = {
		[0] = self.use_wuqi_index,
		[1] = self.use_clothing_index,
		[2] = MountData.Instance:GetMountInfo().used_imageid,
		[3] = WingData.Instance:GetWingInfo().used_imageid,
	}
	return index_list
end