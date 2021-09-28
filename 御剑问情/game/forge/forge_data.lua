ForgeData = ForgeData or BaseClass()

FORGE_TYPE =
{
	STRENGTH = 0,
	GEM = 1,
	SHENZHU = 2,
	SHENGXING = 3,
	TAOZHUANG = 4,
	COMPOSE = 5,
}

local SPECIAL_GEM_TYPE = 5

local MaxStartLevel = 500
ETERNITY_ACTIVE_NEED = 10 --套装激活所需
function ForgeData:__init()
	if ForgeData.Instance ~= nil then
		print_error("[ForgeData] attempt to create singleton twice!")
		return
	end
	self.total_level = 0
	self.gem_info = {}
	self.suit_info = {}
    self.wait_time = 0
	self.eternity_equip_max_level_list = {}
	self.specialmintype_list = {}
	ForgeData.Instance = self

	self.equipforge_auto_cfg = ConfigManager.Instance:GetAutoConfig("equipforge_auto")

	self.xianzunka_cfg = ConfigManager.Instance:GetAutoConfig("xianzunka_auto")
	self.xianzunka_base_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_base_cfg, "card_type")

	self.strength_cfg = ListToMap(self.equipforge_auto_cfg.strength_base, "equip_index", "strength_level")
	self.up_star_cfg = ListToMap(self.equipforge_auto_cfg.up_star, "equip_index", "star_level")
	self.stone_cfg = ListToMap(self.equipforge_auto_cfg.stone, "item_id")
	self.stone_type_level_cfg = ListToMap(self.equipforge_auto_cfg.stone, "stone_type", "level")
	self.shen_op_cfg = ListToMap(self.equipforge_auto_cfg.shen_op, "equip_index", "shen_level")
	self.xianpin_cfg = ListToMap(self.equipforge_auto_cfg.xianpin, "xianpin_type")

	--装备合成列表
	self.equip_compose_cfg = ListToMap(self.equipforge_auto_cfg.red_color_equip_compose, "prof", "order")

	self.total_upstar_cfg = self.equipforge_auto_cfg.total_upstar
	self.all_shen_op_cfg = self.equipforge_auto_cfg.all_shen_op
	self.gem_open_limit_cfg = self.equipforge_auto_cfg.stone_open_limit

	local forge_suit_cfg = ConfigManager.Instance:GetAutoConfig("duanzaosuit_auto")
	self.suit_uplevel_cfg = ListToMap(forge_suit_cfg.suit_uplevel, "equip_id")
	self.suit_attr_ss_list_cfg = ListToMap(forge_suit_cfg.suit_attr_ss, "suit_id", "equip_count")
	self.suit_attr_cq_list_cfg = ListToMap(forge_suit_cfg.suit_attr_cq, "suit_id", "equip_count")

	self.xianpin_fix = self.equipforge_auto_cfg.xianpin_fix		-- 固定仙品属性
	self.xianpin_show = self.equipforge_auto_cfg.xianpin_show	-- 仙品属性展示

	self.equipment_compose_cfg = ListToMap(self.equipforge_auto_cfg.equiment_compound_cfg, "item_id", "xianpin_count")

	self.equipment_slot_cfg = self.equipforge_auto_cfg.equiment_compound_slot or {}
	self.equiment_zhuang_sheng_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").rand_attr_val
	self.equiment_zs_equip_show_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").equip_show

	self.eternity_equip_cfg = ListToMap(self.equipforge_auto_cfg.eternity_equip, "equip_index", "eternity_level")
	self.eternity_suit_cfg = ListToMap(self.equipforge_auto_cfg.eternity_suit, "suit_level")

	self.compose_red_t = {}

-----------------合成配置整理
	self.color_equipment_compose_cfg = {}
	self.color_equipment_compose_can_compose_cfg = ListToMap(self.equipforge_auto_cfg.color_equipment_compose, "stuff_id_0")
	self:InitComposeCfg()
-----------------------------

	self.cur_item_data = nil
	self.cur_open_view = 1
	self.max_eternity_suit_count = 0

	self.last_flush_time = 0

	RemindManager.Instance:Register(RemindName.ForgeStrengthen, BindTool.Bind(self.GetForgeStrenthenRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeBaoshi, BindTool.Bind(self.GetForgeBaoshiRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeCast, BindTool.Bind(self.GetForgeCastRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeUpStar, BindTool.Bind(self.GetForgeUpstarRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeSuit, BindTool.Bind(self.GetForgeSuitRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeYongheng, BindTool.Bind(self.GetForgeYonghengRemind, self))
	RemindManager.Instance:Register(RemindName.ForgeRedEquip, BindTool.Bind(self.GetForgeRedEquipRemind, self))
	-- RemindManager.Instance:Register(RemindName.ForgeCompose, BindTool.Bind(self.GetForgeComposeRemind, self))
end

function ForgeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ForgeStrengthen)
	RemindManager.Instance:UnRegister(RemindName.ForgeBaoshi)
	RemindManager.Instance:UnRegister(RemindName.ForgeCast)
	RemindManager.Instance:UnRegister(RemindName.ForgeUpStar)
	RemindManager.Instance:UnRegister(RemindName.ForgeSuit)
	RemindManager.Instance:UnRegister(RemindName.ForgeYongheng)
	RemindManager.Instance:UnRegister(RemindName.ForgeRedEquip)
	-- RemindManager.Instance:UnRegister(RemindName.ForgeCompose)

	ForgeData.Instance = nil
end

function ForgeData:InitComposeCfg()
	local color_equipment_compose_cfg = {}
	local index = 1
	local index_list = {}
	for k,v in ipairs(self.equipforge_auto_cfg.color_equipment_compose) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.compose_equipment_id)
		if item_cfg then
			local cur_index = index_list[item_cfg.order]
			if cur_index == nil then
				index_list[item_cfg.order] = index
				cur_index = index
				index = index + 1
			end
			color_equipment_compose_cfg[cur_index] = color_equipment_compose_cfg[cur_index] or {}
			color_equipment_compose_cfg[cur_index].order = item_cfg.order
			color_equipment_compose_cfg[cur_index][item_cfg.sub_type] = color_equipment_compose_cfg[cur_index][item_cfg.sub_type] or {}
			color_equipment_compose_cfg[cur_index][item_cfg.sub_type].cfg = v
			color_equipment_compose_cfg[cur_index][item_cfg.sub_type].sub_type = item_cfg.sub_type
			color_equipment_compose_cfg[cur_index][item_cfg.sub_type].item_cfg = item_cfg
		end
	end
	for k,v in ipairs(color_equipment_compose_cfg) do
		local list = {}
		for k1,v1 in pairs(v) do
			if k1 ~= "order" then
				table.insert(list, v1)
			end
		end
		table.sort(list, SortTools.KeyLowerSorter("sub_type"))
		list.order = v.order
		table.insert(self.color_equipment_compose_cfg, list)
	end
	table.sort(self.color_equipment_compose_cfg, SortTools.KeyLowerSorter("order"))
	for k,v in pairs(self.color_equipment_compose_cfg) do
		v.index = k
	end
end

function ForgeData:GetTime()
	return self.wait_time or 0
end

function ForgeData:SetTime(time)
	self.wait_time = time
end

function ForgeData:CanComposePinkEquip(item_id)
	return false--self.color_equipment_compose_can_compose_cfg[item_id] ~= nil
end

function ForgeData:SetCurOpenViewIndex(index)
	self.cur_open_view = index
end

function ForgeData:GetCurOpenViewIndex()
	return self.cur_open_view
end

function ForgeData:SetCurItemData(data)
	self.cur_item_data = data
end

function ForgeData:GetCurItemData()
	return self.cur_item_data
end

function ForgeData:GetNameEffectByData(data)
	local cfg = self:GetShenOpSingleCfg(data.index, data.param.shen_level)
	return cfg and cfg.effect or 0
end

function ForgeData:GetStrengthSingleCfg(equip_index, strength_level)
	local cfg = self.strength_cfg[equip_index]
	return cfg and cfg[strength_level] or nil
end

function ForgeData:GetUpStarSingleCfg(equip_index, star_level)
	local cfg = self.up_star_cfg[equip_index]
	return cfg and cfg[star_level] or nil
end

function ForgeData:GetShenOpSingleCfg(equip_index, shen_level)
	local cfg =  self.shen_op_cfg[equip_index]
	return cfg and cfg[shen_level] or nil
end

function ForgeData:GetGemCfg(item_id)
	return self.stone_cfg[item_id]
end

function ForgeData:GetGemCfgByTypeAndLevel(type, level)
	local cfg = self.stone_type_level_cfg[type]
	return cfg and cfg[level]
end

--传奇 根据类型获取传奇属性Cfg
function ForgeData:GetLegendCfgByType(type)
	return self.xianpin_cfg[type]
end

--获取仙品阶数属性加成Cfg
function ForgeData:GetLegendOrderCfg()
	return self.equipforge_auto_cfg.xianpin_order_add
end
--根据阶数计算仙品阶数属性加成的描述
function ForgeData:CalculateLegendDes(lengend_cfg, grade)
	local legend_order_cfg = self:GetLegendOrderCfg()
	local result_desc = lengend_cfg.desc
	local cur_grade_info
	for k,v in pairs(legend_order_cfg) do
		if lengend_cfg.xianpin_type == v.xianpin_type and grade == v.order then
			cur_grade_info = v
		end
	end
	if cur_grade_info then
		local addition = cur_grade_info.add_per / 10000 * lengend_cfg.add_value / 10000		--两个都是万分比
		addition = addition * 100 															--万分比转为百分比
		addition = math.floor(addition * 10) * 0.1  										--保留一位小数
		result_desc = string.format("%s%s%%", result_desc, addition)
	end
	return result_desc
end

--强化 获取受阶数限制后的强化等级
function ForgeData:GetGradeStrengthLevel(equip_index, grid_level)
	-- print(ToColorStr("获取受阶数限制后的强化等级  "..equip_index.." "..grid_level, TEXT_COLOR.PURPLE))
	local equip = EquipData.Instance:GetDataList()[equip_index]
	if equip ~= nil and equip.item_id ~= nil and equip.item_id ~= 0 then
		-- print("有装备")
		local cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		-- print(equip.item_id)
		if nil == cfg then return 0 end
		local max_level = self:GetMaxStrengthLevelByGrade(equip_index, cfg.order)
		-- print(max_level)
		if grid_level > max_level then
			return max_level
		else
			return grid_level
		end
	end
end

--强化 获取某阶数最高强化等级
function ForgeData:GetMaxStrengthLevelByGrade(equip_index, grid)
	local cfg = self.strength_cfg[equip_index]
	if nil == cfg then
		return 0
	end

	local max_level = 0

	for k,v in pairs(cfg) do
		if v.equip_index == equip_index then
			if grid >= v.need_order then
				if v.strength_level > max_level then
					max_level = v.strength_level
				end
			end
		end
	end
	return max_level
end

--强化 检查装备的阶数是否能继续升级
function ForgeData:GetEquipCanStrengthByGrade(data)
	return nil ~= self:GetStrengthSingleCfg(data.index, data.param.strengthen_level + 1)
end

--强化 获得全身强化等级
function ForgeData:GetTotalStrengthLevel()
	local data = EquipData.Instance:GetDataList()
	local total_level = 0
	for k,v in pairs(data) do
		total_level = total_level + v.param.strengthen_level
	end
	return total_level
end

--强化 获取全身强化Cfg
function ForgeData:GetTotalStrengthCfgByLevel(total_level)
	local full_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
	local target_cfg = nil
	local next_cfg = nil
	for k,v in pairs(full_strength_cfg) do
		if v.total_strength_level <= total_level then
			target_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return target_cfg, next_cfg
end

--强化 根据编号获取全身强化配置
function ForgeData:GetTotalStrengthNameByLevel(seq)
	local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
	for k,v in pairs(total_strength_cfg) do
		if v.seq == seq then
			return v.name
		end
	end
end

--强化 获取强化Cfg
function ForgeData:GetStrengthCfg(data,is_next)
	if not data or data.item_id == nil or data.item_id == 0 then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)

	if equip_index < 0 then
		return nil
	end
	local cur_index = data.index or data.data_index or equip_index

	if is_next then
		level = data.param.strengthen_level + 1
	else
		level = data.param.strengthen_level
	end

	local cfg = self:GetStrengthSingleCfg(cur_index, level)

	if cfg ~= nil then
		if item_cfg.order >= cfg.need_order then
			return cfg
		end
	end
end

--宝石 设置服务器发来的玩家宝石信息
function ForgeData:SetGemInfo(protocol)
	self.gem_total_level = protocol.min_level
	self.stone_limit_list = bit:d2b(protocol.stone_limit_flag) or {}
	self.gem_info = protocol.stone_infos
	self:SetTotalGemPower()
	RemindManager.Instance:Fire(RemindName.KaiFu)
	RemindManager.Instance:Fire(RemindName.ForgeBaoshi)
end

--宝石 获取服务器发来的玩家宝石信息
function ForgeData:GetGemInfo()
	return self.gem_info or {}
end

function ForgeData:GetGemTotalLevel()
	return self.gem_total_level or 0
end

--根据格子index获取开启条件
function ForgeData:GetGemOpenLimitCfg(index)
	for k,v in pairs(self.gem_open_limit_cfg) do
		if index == v.stone_index then
			return v
		end
	end
end

function ForgeData:GetEquipGemCount(level, stone_type)
	local count = 0
	for k,v in pairs(self.gem_info) do
		for k1,v1 in pairs(v) do
			if v1.stone_id > 0 then
				local cfg = self:GetGemCfg(v1.stone_id)
				if cfg and cfg.stone_type == stone_type and cfg.level >= level then
					count = count + 1
				end
			end
		end
	end
	return count
end

--宝石 获取装备上所有宝石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function ForgeData:GetEquipGemInfo(param_data)
	local final_data = {}
	local gem_data = self.gem_info[param_data.index] or {}

	for k,v in pairs(gem_data) do
		local temp_data = {}
		if v.stone_id == 0 then
			if self.stone_limit_list[32-k] == 0 then
				temp_data.gem_state = 0
			else
				temp_data.gem_state = 1
			end
		else
			temp_data.gem_state = 2
			temp_data.gem_id = v.stone_id
		end
		final_data[k] = temp_data
	end
	return final_data
end

function ForgeData:SetCurEquipGemInfo(gem_data)
	self.gem_data = gem_data
end

function ForgeData:GetCurEquipGemInfo()
	return self.gem_data or {}
end

function ForgeData:GetGemTypeByid(id)
	local cfg = self:GetGemCfg(id)
	return cfg and cfg.stone_type or 0
end

function ForgeData:GetMinType()
	local has_type_list = {}
	local all_type_list = {}
	for i = 0, 5 do
		table.insert(all_type_list, i)
	end
	if next(self:GetCurEquipGemInfo()) then
		for k,v in pairs(self:GetCurEquipGemInfo()) do
			if v.gem_state == 2 then
				local cfg = self:GetGemCfg(v.gem_id)
				if nil ~= cfg then
					table.insert(has_type_list, cfg.stone_type)
				end
			end
		end
	end
	if nil ~= next(has_type_list) then
		for i=#all_type_list,1,-1 do
			for k,v in pairs(has_type_list) do
				if all_type_list[i] and all_type_list[i] == v then
					table.remove(all_type_list, i)
				end
			end
		end
	end
	self.specialmintype_list = all_type_list
	if next(all_type_list) then
		for k,v in pairs(all_type_list) do
			return v
		end
	end
	return 0
end

function ForgeData:GetSpecialMinType()
	if next(self.specialmintype_list) == nil then return 5 end
	for k,v in pairs(self.specialmintype_list) do 
		if v >= 5 then
			return v
		end
	end
end

function ForgeData:GetCurBagGemList()
	local bag_all_list = {}
	local bag_all_temp_list = {}
	local has_type_list = {}
	local all_type_list = {}
	for i = 0, 4 do
		table.insert(all_type_list, i)
	end
	if next(self:GetCurEquipGemInfo()) then
		for k,v in pairs(self:GetCurEquipGemInfo()) do
			if v.gem_state == 2 then
				local cfg = self:GetGemCfg(v.gem_id)
				if nil ~= cfg then
					table.insert(has_type_list, cfg.stone_type)
				end
			end
		end
	end
	if nil ~= next(has_type_list) then
		for i=#all_type_list,1,-1 do
			for k,v in pairs(has_type_list) do
				if all_type_list[i] and all_type_list[i] == v then
					table.remove(all_type_list, i)
				end
			end
		end
	end
	for k,v in pairs(all_type_list) do
		table.insert(bag_all_temp_list, self:GetGemsInBag(v))
	end
	for k,v in pairs(bag_all_temp_list) do
		if next(v) then
			for k1,v1 in pairs(v) do
				table.insert(bag_all_list, v1)
			end
		end
	end
	if next(bag_all_list) then
		table.sort(bag_all_list, SortTools.KeyLowerSorter("item_id"))
	end
	return bag_all_list
end

function ForgeData:GetBagGemlistByGemInfo(gem_info)
	local bag_all_list = {}
	local bag_all_temp_list = {}
	local has_type_list = {}
	local all_type_list = {}
	for i = 0, 4 do
		table.insert(all_type_list, i)
	end
	if next(gem_info) then
		for k,v in pairs(gem_info) do
			if v.gem_state == 2 then
				local cfg = self:GetGemCfg(v.gem_id)
				if nil ~= cfg then
					table.insert(has_type_list, cfg.stone_type)
				end
			end

		end
	end
	if nil ~= next(has_type_list) then
		for i=#all_type_list,1,-1 do
			for k,v in pairs(has_type_list) do
				if all_type_list[i] and all_type_list[i] == v then
					table.remove(all_type_list, i)
				end
			end
		end
	end
	for k,v in pairs(all_type_list) do
		table.insert(bag_all_temp_list, self:GetGemsInBag(v))
	end

	for k,v in pairs(bag_all_temp_list) do
		if next(v) then
			for k1,v1 in pairs(v) do
				table.insert(bag_all_list, v1)
			end
		end
	end

	if next(bag_all_list) then
		table.sort(bag_all_list, SortTools.KeyLowerSorter("item_id"))
	end
	return bag_all_list
end

--宝石 获得宝石中文属性对
function ForgeData:GetGemAttr(gem_id)
	forge_gem_cfg = self:GetGemCfg(gem_id)
	local attr_list = {}
	for i=1,3 do
		if forge_gem_cfg["attr_type"..i] == nil or forge_gem_cfg["attr_type"..i] == 0 then
			break
		else
			local data = {}
			if forge_gem_cfg.stone_type > 2 and forge_gem_cfg.stone_type < 5 then
				data.attr_name = Language.Equip.BaoShi..CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i])
				data.attr_value = (forge_gem_cfg["attr_val"..i]/100)..'%'
			else
				data.attr_name = CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i])
				data.attr_value = forge_gem_cfg["attr_val"..i]
			end
			data.attr_real_name = CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i])
			table.insert(attr_list,data)
		end
	end
	return attr_list
end

--宝石 得到玩家背包中的宝石 gem_type:0-4,指定宝石的类型
function ForgeData:GetGemsInBag(gem_type)
	local gems_list = ItemData.Instance:GetGemsInBag(gem_type) or {}
	return gems_list
end

--宝石 根据编号获取全身宝石配置
function ForgeData:GetTotalGemCfgByLevel(level)

	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
	for k,v in pairs(total_gem_cfg) do
		if v.stone_level == level then
			return v.name
		end
	end
end

--宝石 全身宝石等级配置
function ForgeData:GetTotalGemCfg()
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
	local current_cfg = {}
	local next_cfg = {}

	for k,v in pairs(total_gem_cfg) do
		if v.total_level <= self.gem_total_level then
			current_cfg = v
		else
			next_cfg = v
			break
		end
	end
	return self.gem_total_level, current_cfg, next_cfg
end

--宝石 获取单个装备的宝石战斗力
function ForgeData:GetEquipGemPower(data)
	if data == nil then
		return 0
	end
	local final_attr = {}
	local additions = {}
	for k,v in pairs(data) do
		if v.stone_id ~= 0 then
			local gem_cfg = self:GetGemCfg(v.stone_id)
			if gem_cfg ~= nil then
				if gem_cfg.stone_type <=2 or gem_cfg.stone_type >= 5 then
					if final_attr[gem_cfg.attr_type1] == nil then
						final_attr[gem_cfg.attr_type1] = 0
					end
					if final_attr[gem_cfg.attr_type2] == nil then
						final_attr[gem_cfg.attr_type2] = 0
					end
					if final_attr[gem_cfg.attr_type3] == nil then
						final_attr[gem_cfg.attr_type3] = 0
					end
					final_attr[gem_cfg.attr_type1] =  final_attr[gem_cfg.attr_type1] + gem_cfg.attr_val1
					final_attr[gem_cfg.attr_type2] =  final_attr[gem_cfg.attr_type2] + gem_cfg.attr_val2
					final_attr[gem_cfg.attr_type3] =  final_attr[gem_cfg.attr_type3] + gem_cfg.attr_val3
				else
					if additions[gem_cfg.attr_type1] == nil then
						additions[gem_cfg.attr_type1] = 0
					end
					if additions[gem_cfg.attr_type2] == nil then
						additions[gem_cfg.attr_type2] = 0
					end
					additions[gem_cfg.attr_type1] =   additions[gem_cfg.attr_type1] + gem_cfg.attr_val1
					additions[gem_cfg.attr_type2] =   additions[gem_cfg.attr_type2] + gem_cfg.attr_val2
				end
			else
				-- print(ToColorStr("宝石信息为空  "..v.stone_id, TEXT_COLOR.GREEN))
			end
		end
	end

	for k,v in pairs(additions) do
		if final_attr[k] ~= nil then
			final_attr[k] = math.floor(final_attr[k] * (1 + additions[k] / 10000))
		end
	end
	local power = CommonDataManager.GetCapability(final_attr)
	return power
end

--宝石 根据Euqip_Index获取装备宝石战力
function ForgeData:GetGemPowerByIndex(equip_index)
	local gem_data = self.gem_info[equip_index]
	local power = self:GetEquipGemPower(gem_data)
	return power
end

--宝石 设置总宝石战斗力
function ForgeData:SetTotalGemPower()
	local total_power = 0
	for k,v in pairs(self.gem_info) do
		total_power = self:GetEquipGemPower(v) + total_power
	end
	self.gem_power = total_power
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
end

--宝石 得到总宝石战斗力
function ForgeData:GetTotalGemPower()
	return self.gem_power + self:GetGemSuitPower()
end

--宝石 获取宝石套装战力
function ForgeData:GetGemSuitPower()
	local suit_power = 0
	local suit_id = self:GetGemSuitId()
	if suit_id >= 0 then
		local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add
		suit_power = CommonDataManager.GetCapabilityCalculation( total_gem_cfg[suit_id] )
	end
	return suit_power
end

--宝石 获取套装id
function ForgeData:GetGemSuitId()
	local suit_id = -1
	local total_gem_cfg = self.equipforge_auto_cfg.stone_ex_add

	--获取全部宝石的总等级
	local total_level = 0
	for k,v in pairs(self.gem_info) do
		for k1,v1 in pairs(v) do
			if v1.stone_id ~= 0 then
				local gem_cfg = self:GetGemCfg(v1.stone_id)
				if gem_cfg == nil then return suit_id end
				total_level = total_level + gem_cfg.level
			end
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_gem_cfg do
		-- print_error("######获取总等级对应的套装id####",total_level,#total_gem_cfg,total_gem_cfg)
		--等级最高处理
		if total_level >= total_gem_cfg[#total_gem_cfg].total_level then
			suit_id = total_gem_cfg[#total_gem_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_gem_cfg[i].total_level and total_level <= total_gem_cfg[i + 1].total_level then
			suit_id = total_gem_cfg[i].seq
		end
	end
	return suit_id
end

--强化 获取强化套装战力
function ForgeData:GetStrengthSuitPower()
	local suit_power = 0
	local suit_id = self:GetStrengthSuitId()
	if suit_id >= 0 then
		local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward
		suit_power = CommonDataManager.GetCapabilityCalculation(total_strength_cfg[suit_id + 1] )
	end
	return suit_power
end

--强化获取套装id
function ForgeData:GetStrengthSuitId()
	local suit_id = -1
	local total_strength_cfg = self.equipforge_auto_cfg.strength_minlevel_reward

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.strengthen_level ~= 0 then
			total_level = total_level + v.param.strengthen_level
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_strength_cfg do
		--等级最高处理
		if total_level >= total_strength_cfg[#total_strength_cfg].total_strength_level then
			suit_id = total_strength_cfg[#total_strength_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_strength_cfg[i].total_strength_level and total_level <= total_strength_cfg[i + 1].total_strength_level then
			suit_id = total_strength_cfg[i].seq
		end
	end
	return suit_id
end

--神铸 获取神铸套装战力
function ForgeData:GetCastSuitPower()
	local suit_power = 0
	local the_level = self:GetCastSuitId()
	local attr = {}
	if the_level >= 0 then
		local total_cast_cfg = self.equipforge_auto_cfg.all_shen_op
		for k,v in pairs(total_cast_cfg) do
			if v.shen_level == the_level then
				attr = v
			end
		end
		suit_power = CommonDataManager.GetCapabilityCalculation(attr)
	end
	return suit_power
end

--神铸获取套装id
function ForgeData:GetCastSuitId()
	local the_level = -1
	local total_cast_cfg = self.equipforge_auto_cfg.all_shen_op

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.shen_level ~= 0 then
			total_level = total_level + v.param.shen_level
		end
	end
	--获取总等级对应的套装id
	for i = 1 , #total_cast_cfg do
		--等级最高处理
		if total_level >= total_cast_cfg[#total_cast_cfg].shen_level then
			the_level = total_cast_cfg[#total_cast_cfg].shen_level
			return the_level
		end
		--等级未达到最高处理
		if total_level >= total_cast_cfg[i].shen_level and total_level <= total_cast_cfg[i + 1].shen_level then
			the_level = total_cast_cfg[i].shen_level
		end
	end
	return the_level
end

--升星 获取升星套装战力
function ForgeData:GetUpStarSuitPower()
	local suit_power = 0
	local suit_id = self:GetUpStarSuitId()
	if suit_id >= 0 then
		local total_up_star_cfg = self.equipforge_auto_cfg.total_upstar
		suit_power = CommonDataManager.GetCapabilityCalculation(total_up_star_cfg[suit_id + 1] )
	end
	return suit_power
end

--升星获取套装id
function ForgeData:GetUpStarSuitId()
	local suit_id = -1
	local total_up_star_cfg = self.equipforge_auto_cfg.total_upstar

	--获取全部强化的总等级
	local total_level = 0
	local equiplist = EquipData.Instance:GetDataList()
	for k,v in pairs(equiplist) do
		if v.param.shen_level ~= 0 then
			total_level = total_level + v.param.star_level
		end
	end

	--获取总等级对应的套装id
	for i = 1 , #total_up_star_cfg do
		--等级最高处理
		if total_level >= total_up_star_cfg[#total_up_star_cfg].total_star then
			suit_id = total_up_star_cfg[#total_up_star_cfg].seq
			return suit_id
		end
		--等级未达到最高处理
		if total_level >= total_up_star_cfg[i].total_star and total_level <= total_up_star_cfg[i + 1].total_star then
			suit_id = total_up_star_cfg[i].seq
		end
	end
	return suit_id
end

--宝石 检查装备的宝石是否能镶嵌(1)、替换(2)、升级(3)
function ForgeData:GetEquipGemCanImprove(data)
	local gem_data = self:GetEquipGemInfo(data)
	for k,v in pairs(gem_data) do
		local bag_gem = {}
		if v.gem_id ~= nil then
			local gem_type = ForgeData.Instance:GetGemTypeByid(v.gem_id)
			bag_gem = self:GetGemsInBag(gem_type)
		else
			bag_gem = self:GetBagGemlistByGemInfo(gem_data)
		end
		local count = 0
		for k,v in pairs(bag_gem) do
			count = count + 1
		end
		if v.gem_state == 1 then
			--处理可镶嵌
			if k > 5 then
				count = self:GetSpecialGemNumInBag()
			end
			if count > 0 then
				return 0, 1
			end
		elseif v.gem_state == 2 then
			--处理可替换
			local max_id = v.gem_id
			for k2,v2 in pairs(bag_gem) do
				if v2.item_id > max_id then
					return 0, 2
				end
			end
			--处理可升级
			local forge_gem_cfg = self:GetGemCfg(v.gem_id)
			local level = forge_gem_cfg.level
			local next_cfg =self:GetGemCfgByTypeAndLevel(forge_gem_cfg.stone_type, level + 1)
			if next_cfg ~= nil then
				local upgrade_need_energy = math.pow(3, level) - math.pow(3, level - 1)
				local had_energy = 0
				for k,v in pairs(bag_gem) do
					if v.item_id <= forge_gem_cfg.item_id then
						local tmp_forge_gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
						if tmp_forge_gem_cfg then
							had_energy = had_energy + (math.pow(3, tmp_forge_gem_cfg.level - 1) * v.num)
						end
					end
				end
				if had_energy >= upgrade_need_energy then
					return 0, 3
				end
			end
		end
	end
	return false
end

--神铸 获取神铸Cfg
function ForgeData:GetCastCfg(data,is_next)
	if not data or data.item_id == nil or data.item_id == 0 then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)

	if not item_cfg or item_cfg.sub_type == nil then
		return
	end

	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local cur_index = data.index
	if equip_index < 0 then
		return nil
	end
	if equip_index ~= data.index then
		cur_index = equip_index
	end
	if is_next then
		cast = data.param.shen_level + 1
	else
		cast = data.param.shen_level
	end

	return self:GetShenOpSingleCfg(cur_index, cast)
end

--神铸 全身神铸配置
function ForgeData:GetFullCastLevel(is_next)
	local data = EquipData.Instance:GetDataList()
	local cast_count = 0
	for k,v in pairs(data) do
		cast_count = cast_count + v.param.shen_level
	end
	local casst_auto =  self.equipforge_auto_cfg.all_shen_op
	local target_data = {}
	local next_data = {}
	for k,v in pairs(casst_auto) do
		if cast_count >= v.shen_level then
			target_data = v
		else
			next_data = v
			break
		end
	end
	return cast_count, target_data, next_data
end

--神铸 获取装备神铸前缀
function ForgeData:GetQualityFormat(data)
	if data == nil then
		return ""
	end
	--神铸名字
	local cast_prefix = ""
	local cast_cfg = self:GetCastCfg(data)
	if cast_cfg ~= nil then
		cast_prefix = cast_cfg.name
	end
	return cast_prefix
end

--获取神铸等级
function ForgeData:GetQualityNameIndex(data)
	if data == nil then
		return 0
	end
	local shen_level = data.param.shen_level
	if nil == shen_level then
		return 10
	end
	return shen_level
end

function ForgeData:GetCanUpStarByLevelAndIndex(index, level)
	if level >= MaxStartLevel then return false end
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	local need_star_mojing = self:GetStarAttr(index, level + 1)
	return mojing >= need_star_mojing.need_shengwang
end

function ForgeData:GetMinStarIndex()
	local data_list = EquipData.Instance:GetDataList()
	local min_index = -1
	local min_value = 999999
	for k, v in pairs(data_list) do
		local equip_data = data_list[k]
		if nil ~= equip_data and nil ~= equip_data.index then
			if equip_data.param.star_level < MaxStartLevel then
				local need_star_mojing = self:GetStarAttr(equip_data.index, equip_data.param.star_level + 1)
				if need_star_mojing and need_star_mojing.need_shengwang < min_value then
					min_value = need_star_mojing.need_shengwang
					min_index = equip_data.index
				end
			end
		end
	end
	local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
	if mojing < min_value then
		return -2
	end
	return min_index
end

--公用 是否能强化/升品/神铸/宝石提升 0可以 1到达顶级 2不够材料
function ForgeData:CheckIsCanImprove(data, param_type)


	local next_cfg = nil

	if param_type == TabIndex.forge_strengthen then
		next_cfg = ForgeData.Instance:GetStrengthCfg(data,true)
	elseif param_type == TabIndex.forge_cast then
		next_cfg = ForgeData.Instance:GetCastCfg(data,true)
	elseif param_type == TabIndex.forge_baoshi then
		local can_improve, improve_type = self:GetEquipGemCanImprove(data)
		return can_improve, improve_type
	elseif param_type == TabIndex.forge_up_star then
		local param = data.param or {}
		local mojing = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.MOJING)
		if mojing > 0 and param.star_level and param.star_level < MaxStartLevel then
			if self:CheckIsGouYU(data) then
				return 2
			end
			local need_star_mojing = self:GetStarAttr(data.index, param.star_level + 1)

			if need_star_mojing and mojing > need_star_mojing.need_shengwang then
				return 0
			else
				return 2
			end
		else
			return 2
		end
	elseif param_type == TabIndex.forge_red_equip then
		return self:CaculateRedEquipRemind(data)
	elseif param_type == TabIndex.forge_yongheng then
		return self:CaculateEternityRemind()
	end

	--是否满级
	if next_cfg == nil then
		return 1
	end
	--材料
	local item_id = next_cfg["stuff_id"]
	local item_count = next_cfg["stuff_count"]
	local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	if param_type == TabIndex.forge_strengthen then 					--策划规定强化石数量大于5才显示红点
		if had_item_num < item_count or had_item_num < 5 then
			return 2, item_id, (item_count - had_item_num)
		end
	else
		if had_item_num < item_count then
			return 2, item_id, (item_count - had_item_num)
		end
	end

	--强化特有，阶数限制
	if param_type == TabIndex.forge_strengthen then
		if not self:GetEquipCanStrengthByGrade(data) then
			return 3
		end
	end
	return 0
end

function ForgeData:CheckIsGouYU(data)
	if data == nil or data.index == nil then
		return false
	end
	return data.index == GameEnum.EQUIP_INDEX_GOUYU_1 or data.index == GameEnum.EQUIP_INDEX_GOUYU_2
end

--公用 获取可提升的装备
function ForgeData:GetCanImproveEquip(param_type)
	local equip_data = EquipData.Instance:GetDataList()
	for k,v in pairs(equip_data) do
		if v.item_id ~= nil then
			if self:CheckIsCanImprove(v, param_type) == 0 then
				return v
			end
		end
	end
end
--公用 获取装备的所有加成
function ForgeData:GetForgeAddition(data)
	if not data then return end
	--强化加成
	local strength_cfg = self:GetStrengthCfg(data)
	--神铸加成
	local cast_cfg = self:GetCastCfg(data)

	--获取角色等级
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local ro_level = vo.level
	--物品基础属性
	local equip_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local base_result = CommonDataManager.GetAttributteNoUnderline(equip_cfg)
	---------去掉基础属性---------
	for k,v in pairs(base_result) do
		base_result[k] = 0
	end
	---------去掉基础属性--------
	local strength_result = {}
	local cast_result = {}
	for k, v in pairs(base_result) do
		--强化
		local strengthen_addition = 0
		if strength_cfg ~= nil then
			local key = (k == "maxhp") and "max_hp" or k
			strengthen_addition = strength_cfg[key] or 0
		end
		strength_result[k] = strengthen_addition
		--神铸
		local cast_addition_fix = 0
		local cast_addition_per = 0
		if cast_cfg ~= nil then
			cast_addition_fix = cast_cfg[k] or 0
			cast_addition_per = math.floor(cast_cfg.attr_percent * 0.01 * v)
		end
		cast_result[k] = cast_addition_fix + cast_addition_per
	end
	cast_result.shen_level = data.param.shen_level
	cast_result.item_id = data.item_id
	return base_result, strength_result, cast_result
end

--公用 获取装备中文属性和战斗力s
function ForgeData:GetEquipAttrAndPower(data, cur_open_view)
	cur_open_view = cur_open_view or self.cur_open_view
	local base_result, strength_result, cast_result = self:GetForgeAddition(data)
	if strength_result == nil and cast_result == nil then
		return nil, 0
	end

	local total_attr = {}
	local power_attr = {}
	for k,v in pairs(base_result) do
		local value = 0
		if cur_open_view == 1 then
			value = strength_result[k]
		-- elseif self.cur_open_view == 2 then
		elseif cur_open_view == 3 then
			value = cast_result[k]
		end
		total_attr[CommonDataManager.GetAttrName(k)] = value
		power_attr[k] = value
	end
	local power = CommonDataManager.GetCapabilityCalculation(power_attr)
	return total_attr, power
end

--设置升星红点
function ForgeData:SetUpStarRedPoint()

end

function ForgeData:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ForgeData:GetStarAttr(equip_index, star_level)
	local star_attr_info = {}
	if star_level == 0 then
		star_attr_info.equip_index = equip_index
		star_attr_info.star_level = 0
		star_attr_info.equip_level = 1
		star_attr_info.need_shengwang = 0
		star_attr_info.maxhp = 0
		star_attr_info.gongji = 0
		star_attr_info.fangyu = 0
		return star_attr_info
	end

	return self:GetUpStarSingleCfg(equip_index, star_level)
end

--获取当前总星星数
function ForgeData:GetNowTotalStar()
	local equip_list = EquipData.Instance:GetDataList()
	local all_star_level = 0
	for k, v in pairs(equip_list) do
		local param = v.param or {}
		local star_level = param.star_level
		if star_level and star_level > 0 then
			all_star_level = all_star_level + star_level
		end
	end
	return all_star_level
end

--获取升星全身套装属性
function ForgeData:GetTotleStarInfo()
	local all_star_level = self:GetNowTotalStar()
	local now_total = {}
	local next_total = {}
	local taozhuang_name = ""
	for k, v in ipairs(self.total_upstar_cfg) do
		if all_star_level < v.total_star then
			now_total = self.total_upstar_cfg[k - 1] or {}
			next_total = v
			break
		end
	end
	if not next(now_total) and not next(next_total) then
		now_total = self.total_upstar_cfg[#self.total_upstar_cfg]
	end
	return all_star_level, now_total, next_total
end

--获取升星套装属性
function ForgeData:GetTotleStarBySeq(seq)
	local taozhuang_name = ""
	for k, v in ipairs(self.total_upstar_cfg) do
		if v.seq == seq then
			taozhuang_name = v.name
			break
		end
	end
	return taozhuang_name
end

--装备总战力
function ForgeData:GetEquipZhanLi()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		capability = capability + EquipData.Instance:GetEquipLegendFightPowerByData(v,true, false)
	end
	local strength_power = self:GetStrengthPower()
	local baoshi_power = self:GetTotalGemPower()
	local cast_power = self:GetShenZhuPower()
	local up_star_power = self:GetUpStarPower()
	local suit_power = self:GetSuitPower()
	capability = capability + strength_power + baoshi_power + cast_power + up_star_power + suit_power
	return capability
end

--强化总战力
function ForgeData:GetStrengthPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local _, power = self:GetEquipAttrAndPower(v, 1)
		capability = capability + power
	end
	capability = capability + self:GetStrengthSuitPower()
	return capability
end

--神铸总战力
function ForgeData:GetShenZhuPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local _, power = self:GetEquipAttrAndPower(v, 3)
		capability = capability + power
	end
	capability = capability + self:GetCastSuitPower()
	return capability
end

--升星总战力
function ForgeData:GetUpStarPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local attr_info = self:GetStarAttr(v.index, v.param.star_level)
		if nil ~= attr_info then
			capability = capability + CommonDataManager.GetCapabilityCalculation(attr_info)
		end
	end
	capability = capability + self:GetUpStarSuitPower()
	return capability
end

--套装战力
function ForgeData:GetSuitPower()
	local capability = 0
	local temp_equip_list_data = self:ReorderEquipList() or {}
	local suit_list = {}
	for k,v in pairs(temp_equip_list_data) do
		local suit_uplevel_cfg = self:GetSuitUpLevelCfgByItemId(v.item_id) or {}
		local suit_id = suit_uplevel_cfg.suit_id or 0
		local suit_type = self:GetCurEquipSuitType(k - 1)
		if suit_id ~= 0 and suit_type ~= 0 then
			suit_list[suit_id] = suit_list[suit_id] or {}
			if suit_type == 2 then
				suit_type = -1
			end
			suit_list[suit_id][suit_type] = suit_list[suit_id][suit_type] and suit_list[suit_id][suit_type] + 1 or 1
		end
	end
	for k1,v1 in pairs(suit_list) do
		for k2,v2 in pairs(v1) do
			local suit_data_cfg = self:GetSuitAttCfg(k1, v2, k2) or {}
			local add_capability = CommonDataManager.GetCapability(suit_data_cfg) or 0
			capability = capability + add_capability
		end
	end
	return capability
end

-------------套装-------------
--套装信息
function ForgeData:SetForgeSuitInfo(protocol)
	self.suit_info = protocol.suit_level_list or {}
	RemindManager.Instance:Fire(RemindName.KaiFu)
end

--获取当前装备的套装类型
function ForgeData:GetCurEquipSuitType(index)
	if not next(self.suit_info) or nil == index then
		return 0
	end

	if not self.suit_info[index] then
		return 0
	 end

	return self.suit_info[index].suit_type
end

function ForgeData:GetSuitCount(grade, index)
	if not next(self.suit_info) or self.suit_info[index] == nil then
		return 0
	end
	if self.suit_info[index].suit_type > 0 and EquipData.Instance:GetGridData(index) then
		local equip = EquipData.Instance:GetGridData(index)
		local cfg = ItemData.Instance:GetItemConfig(equip.item_id)
		if cfg and cfg.order >= grade then
			return 1
		end
	end
	return 0
end

--获取装备的升级cfg
function ForgeData:GetSuitUpLevelCfgByItemId(item_id)
	return self.suit_uplevel_cfg[item_id]
end

function ForgeData:GetSuitIdByItemId(item_id)
	local cfg = self:GetSuitUpLevelCfgByItemId(item_id)
	return cfg and cfg.suit_id, 0
end

--统计相同套装id总件数  suit_type(0普通,1史诗,2传奇)
function ForgeData:GetSuitNumByItemId(item_id, suit_type)
	local suit_uplevel_cfg = self:GetSuitUpLevelCfgByItemId(item_id)
	local equip_list_data = EquipData.Instance:GetDataList()
	local suit_num = 0
	for k,v in pairs(equip_list_data) do
		local temp_suit_uplevel_cfg = self:GetSuitUpLevelCfgByItemId(v.item_id)
		if nil ~= temp_suit_uplevel_cfg then
			if suit_uplevel_cfg.suit_id == temp_suit_uplevel_cfg.suit_id then
				if suit_type == 1 then
					if self.suit_info[v.data_index or v.index].suit_type == 1 then
						suit_num = suit_num + 1
					end
				else
					if suit_type == self.suit_info[v.data_index or v.index].suit_type then
						suit_num = suit_num + 1
					end
				end
			end
		end
	end
	return suit_num
end

--获取背包中套装石数量
function ForgeData:GetBagSuitRockNum(item_id)
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
	local rock_num = 0
	for k,v in pairs(bag_data_list) do
		if item_id == v.item_id then
			rock_num = rock_num + v.num
		end
	end
	return rock_num
end

--根据套装类型获取配置
function ForgeData:GetSuitAttCfg(suit_id, equip_count, suit_type)
	if suit_type == 1 and nil ~= self.suit_attr_ss_list_cfg[suit_id] then
		return self.suit_attr_ss_list_cfg[suit_id][equip_count]

	elseif suit_type == -1 and nil ~= self.suit_attr_cq_list_cfg[suit_id] then
		return self.suit_attr_cq_list_cfg[suit_id][equip_count]
	end

	return nil
end

--获取装备的套装名
function ForgeData:GetSuitName(suit_id, suit_type)
	local list = nil
	if suit_type == 1 then
		list = self.suit_attr_ss_list_cfg[suit_id]

	elseif suit_type == -1 then
		list = self.suit_attr_cq_list_cfg[suit_id]
	end

	if nil == list then
		return ""
	end

	local _, cfg = next(list)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	return cfg and cfg["suit_name_" .. prof] or ""
end

function ForgeData:GetCurSuitRockNum(select_equip_item_id, suit_type)
	local cur_num_1 = 0 --当前拥有的套装石数量
	local cur_num_2 = 0 --当前拥有的套装石数量
	local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(select_equip_item_id)
	if nil == strength_data_cfg then
		return 0, 0
	end
	if suit_type == 1 then
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_ss)
	else
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq1)
		cur_num_2 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq2)
	end
	return cur_num_1, cur_num_2
end

function ForgeData:SetRedPointStatus(rock1_is_enough, rock2_is_enough, data_index, suit_type)
	local red_point_status = false
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(data_index)
	if suit_type == 1 then
		if rock1_is_enough and cur_suit_type == 0 then
			red_point_status = true
		end
	else
		if rock1_is_enough and cur_suit_type == 1 and rock2_is_enough then
			red_point_status = true
		end
	end
	return red_point_status
end

--套装石是否足够
function ForgeData:GetItemNumIsEnough(cur_num, need_num)
	if tonumber(cur_num) >= tonumber(need_num) then
		return true
	else
		return false
	end
end

--suit_type:当前界面（1:史诗，-1:传说）equip_data:装备列表
function ForgeData:GetChangeSuitBtnRedPointStatus(equip_data,suit_type)
	for k,v in pairs(equip_data) do
		local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(v.item_id)
		if nil ~= strength_data_cfg then
			local cur_num_1, cur_num_2 = ForgeData.Instance:GetCurSuitRockNum(v.item_id, suit_type)
			local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
			local rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
			local red_point_status = ForgeData.Instance:SetRedPointStatus(rock1_is_enough, rock2_is_enough, v.data_index or v.index, suit_type)
			if red_point_status then
				return true
			end
		end
	end
	return false
end

--装备列表重排序
function ForgeData:ReorderEquipList()
	-- 头盔 衣服 护腿 鞋子 武器 腰带  护手 项链 戒指 戒指
	local sort_type_list = {100, 101, 102, 103, 106, 108, 104, 105, 107}
	local equip_type_dic = {}
	for k,v in pairs(sort_type_list) do
		equip_type_dic[v] = k
	end

	local temp_equip_list = {}
	local equip_list_data = EquipData.Instance:GetDataList()
	for k,v in pairs(equip_list_data) do
		if nil ~= v.item_id then
			local t = {}
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)

			if item_cfg then
				t.sort = equip_type_dic[item_cfg.sub_type]
				t.data = v
				table.insert(temp_equip_list, t)
			end
		end
	end

	table.sort(temp_equip_list, SortTools.KeyLowerSorter("sort"))

	local sort_list = {}
	for k,v in pairs(temp_equip_list) do
		sort_list[k] = v.data
	end
	return sort_list
end

function ForgeData:CheckIsSuitRock(item_id)
	if item_id >= 27678 and item_id <= 27687 then
		return true
	end
	return false
end

function ForgeData:GetEquipXianpinAttr(equip_id, gift_item_id)
	local type_list = {}
	local max_xianpin_num = 3
	local is_random = false

	if gift_item_id then
		for k, v in pairs(self.xianpin_fix) do
			if v.equip_id == equip_id and v.param_1 == gift_item_id then
				for i = 1, max_xianpin_num do
					if v["xianpin_type_"..i] > 0 then
						table.insert(type_list, v["xianpin_type_"..i])
					end
				end
				return type_list
			end
		end
		is_random = true
	else
		local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			for k, v in pairs(self.xianpin_show) do
				if v.equip_index == equip_index and v.equip_color == item_cfg.color then
					for i = 1, max_xianpin_num do
						if v["xianpin_type_"..i] > 0 then
							table.insert(type_list, v["xianpin_type_"..i])
						end
					end
					return type_list
				end
			end
		end
	end

	if gift_item_id and is_random then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			for k, v in pairs(self.xianpin_show) do
				if v.equip_index == equip_index and v.equip_color == item_cfg.color then
					for i = 1, max_xianpin_num do
						if v["xianpin_type_"..i] > 0 then
							table.insert(type_list, v["xianpin_type_"..i])
						end
					end
					return type_list
				end
			end
		end
	end

	return type_list
end

function ForgeData:GetEquipIsNotRandomGift(equip_id, gift_item_id)
	if not equip_id or not gift_item_id then return false end

	for k, v in pairs(self.xianpin_fix) do
		if v.equip_id == equip_id and v.param_1 == gift_item_id then
			return true
		end
	end

	return false
end

function ForgeData:GetTypeListByIndex(index)
	local equip_list = {}
	for k,v in pairs(self.equipment_compose_cfg) do
		if v.index == index -1 then
			table.insert(equip_list, v)
		end
	end
	return equip_list
end

function ForgeData:GetSlotTypeByIndex(index)
	return self.equipment_slot_cfg[index] and self.equipment_slot_cfg[index].equiment_slot or 0
end

function ForgeData:GetNumOfSlot()
	local count = 0
	for k,v in pairs(self.equipment_slot_cfg) do
		count = count + 1
	end
	return count
end

function ForgeData:GetItemIdByGrade(slot_type, grade)
	local main_role_prof = GameVoManager.Instance:GetMainRoleVo().prof
	local equipment_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	local sub_type = 100 + slot_type
	for k,v in pairs(equipment_cfg) do
		if v.color == GameEnum.ITEM_COLOR_RED and grade == v.order and sub_type == v.sub_type then
			if v.limit_prof == main_role_prof or v.limit_prof == 5 then
				return v.icon_id , v.id
			end
		end
	end
	return 100
end

function ForgeData:GetComposeNeedStuff(grade, star)
	for k,v in pairs(self.equipment_compose_cfg) do
		if grade == v.compound_order and star + 1 == v.compound_star then
			return v
		end
	end
end

function ForgeData:GetBagComposeStuff(data)
	if nil == data then return {} end

	local bag_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	if nil == bag_list or #bag_list <= 0 then return {} end
	local match_list = {}
	for k,v in pairs(bag_list) do
		if v.item_id == data.cfg.stuff_id_0 or v.item_id == data.cfg.stuff_id_1 or v.item_id == data.cfg.stuff_id_2 then
			table.insert(match_list, v)
		end
	end
	return match_list
end

function ForgeData:SetIsComposeSucc(is_succ)
	self.is_succ = is_succ
end

function ForgeData:GetIsComposeSucc()
	if self.is_succ and self.is_succ == 1 then
		return true
	end
	return false
end

function ForgeData:GetZSRandomValueList(equip_level, equip_color, equip_type)
	local list = {}
	local equip_type_list = self:GetShowZSType(equip_level, equip_color, equip_type)
	if #equip_type_list == 0 then return list end
	for k,v in pairs(self.equiment_zhuang_sheng_cfg) do
		if v.equip_color == equip_color and equip_level == v.equip_level then
			if v.attr_type == equip_type_list[1] then
				list[1] = {}
				list[1].attr_value_max = v.attr_value_max
				list[1].attr_value_min = v.attr_value_min
			elseif v.attr_type == equip_type_list[2] then
				list[2] = {}
				list[2].attr_value_max = v.attr_value_max
				list[2].attr_value_min = v.attr_value_min
			elseif v.attr_type == equip_type_list[3] then
				list[3] = {}
				list[3].attr_value_max = v.attr_value_max
				list[3].attr_value_min = v.attr_value_min
			end
			if #list == 3 then
				break
			end
		end
	end
	return list
end

function ForgeData:GetShowZSType(equip_level, equip_color, equip_type)
	local list = {}
	for k,v in pairs(self.equiment_zs_equip_show_cfg) do
		if v.equip_type == equip_type and v.equip_grade == equip_level and v.equip_color == equip_color then
			list[1] = v.suiji_type1
			list[2] = v.suiji_type2
			list[3] = v.suiji_type3
			return list
		end
	end
	return list
end

--展示套装属性
function ForgeData:GetTotalLevelDes(attr_list, is_next, total_level_name, now_level)
	local total_level = attr_list.total_level or attr_list.total_strength_level or attr_list.total_star or attr_list.shen_level or attr_list.level or 0
	local total_level_name = total_level_name ~= "" and total_level_name or Language.Forge.AllTotalLevel
	local suit_name = total_level_name
	local total_level = ToColorStr(total_level.. Language.Common.Ji, TEXT_COLOR.GRAY_WHITE)
	local now_level = ToColorStr(now_level .. Language.Common.Ji, TEXT_COLOR.RED)
	local total_str = ""
	if is_next then
		total_str =  total_level_name .. "(".. now_level .. " / " .. total_level .. ")"
	else
		now_level = ToColorStr(now_level, TEXT_COLOR.GRAY_WHITE) --  .. Language.Common.Ji
		total_str = total_level_name .. "(" .. now_level .. ")"
	end
	return total_str
end

function ForgeData:GetShowXianPinCfg()
	local decs_list = {}
	local star_value = 0
	for k,v in pairs(self.xianpin_cfg) do
		if v.equip_color == 5
			and (v.xianpin_type == 58 or v.xianpin_type == 59 or v.xianpin_type == 60) then
			if v.xianpin_type == 58 then
				star_value = 1
			elseif v.xianpin_type == 59 then
				star_value = 2
			elseif v.xianpin_type == 60 then
				star_value = 3
			end
			table.insert(decs_list, "<color=" ..TEXT_COLOR.RED_4 ..  ">" .. star_value .. "★</color>" .. ToColorStr(v.desc,TEXT_COLOR.BLUE_4))
		end
	end
	return decs_list
end

function ForgeData:GetShowXianPinCount()
	local count = 0
	local xianpin_cfg = ConfigManager.Instance:GetAutoConfig("equipforge_auto").xianpin
	for k,v in pairs(xianpin_cfg) do
		if v.equip_color == 5 and v.color == 1 then
			count = count + 1
		end
	end
	return count
end

function ForgeData:GetShenZhuEffect()
	if not self.cur_item_data or not self.cur_item_data.param or not self.cur_item_data.param.shen_level then
		return {{1, false}, {1, false}, {1, false}, {1, false}, {1, false}}
	end
	local shen_level = self.cur_item_data.param.shen_level
	local effect_type = -1
	if shen_level == 0 then return {{1, false}, {1, false}, {1, false}, {1, false}, {1, false}} end

	local temp_list = {5, 10, 15, 20, 25}

	if shen_level > 0 and shen_level <= 5 then
		effect_type = 2
	elseif shen_level > 5 and shen_level <= 10 then
		effect_type = 3
	elseif shen_level > 10 and shen_level <= 15 then
		effect_type = 4
	elseif shen_level > 15 and shen_level <= 20 then
		effect_type = 5
	elseif shen_level > 20 and shen_level <= 25 then
		effect_type = 6
	end
	local temp = shen_level%5
	local cur_index = temp ~= 0 and temp or 5
	local result_list = {}
	for i=1,5 do
		local list = {}
		if cur_index >= i then
			list = {effect_type, true}
		else
			list = {effect_type - 1, shen_level > 5}
		end
		table.insert(result_list, list)
	end
	return result_list
end

function ForgeData:GetNextShenZhuAttrPresent(equip_index, cur_attr_present)
	for k,v in pairs(self.shen_op_cfg) do
		for m,n in pairs(v) do
			if n.equip_index == equip_index and n.attr_percent > cur_attr_present then
				local list = {}
				list.shen_level = n.shen_level
				list.attr_percent = n.attr_percent
				return list
			end
		end
	end
	return
end

function ForgeData:GetRedEquipComposeCfg(item_id, xianpin_count)
	if nil == item_id or nil == xianpin_count then return nil end

	if nil == self.equipment_compose_cfg[item_id] then
		return nil
	end

	return self.equipment_compose_cfg[item_id][xianpin_count]
end

-- 红色装备红点
function ForgeData:CaculateRedEquipRemind(data)
	if nil == data or nil == next(data) then
		return 2
	end
	local compose_cfg = nil
	local bag_num = 0
	if nil ~= data.param and nil ~= data.param.xianpin_type_list then
		compose_cfg = self:GetRedEquipComposeCfg(data.item_id, #data.param.xianpin_type_list)
		if nil ~= compose_cfg then
			bag_num = ItemData.Instance:GetItemNumInBagById(compose_cfg.stuff_item.item_id)

			if #data.param.xianpin_type_list >= 3 then
				return 1
			end

			if compose_cfg.gain_item <= 0 then
				return 2
			end

			if bag_num >= compose_cfg.stuff_item.num then
				return 0
			end
		end
	end
	return 2
end

-- 红装格子是否可以被选中
function ForgeData:CheckEquipCanSelect(data)
	if nil == data or nil == next(data) then
		return false
	end

	if nil == data.param or nil == data.param.xianpin_type_list then
		return false
	end

	if #data.param.xianpin_type_list >= 3 then
		return false
	end
	local compose_cfg = self:GetRedEquipComposeCfg(data.item_id, #data.param.xianpin_type_list)
	if nil == compose_cfg or compose_cfg.gain_item <= 0 then
		return false
	end

	return true
end

-- 永恒装备配置
function ForgeData:GetEternityEquipCfg(equip_index, is_next, level)
	if nil == equip_index then return end

	local equip_data = EquipData.Instance:GetGridData(equip_index)
	if nil == equip_data then return end

	level = level or equip_data.param.eternity_level or 0
	level = is_next and level + 1 or level

	if nil == self.eternity_equip_cfg[equip_index] then
		return nil
	end
	return self.eternity_equip_cfg[equip_index][level]
end

function ForgeData:GetEternityEquipMaxLevel(equip_index)
	if nil == equip_index
		or nil == self.eternity_equip_cfg[equip_index] then
		return 0
	end

	if nil == self.eternity_equip_max_level_list[equip_index] then
		local count = 0
		for k, v in pairs(self.eternity_equip_cfg[equip_index]) do
			count = count + 1
		end
		self.eternity_equip_max_level_list[equip_index] = count
	end

	return self.eternity_equip_max_level_list[equip_index]
end

-- 获取永恒装备总等级
function ForgeData:GetEternityTotalLevel()
	local data_list = EquipData.Instance:GetDataList()
	if nil == data_list or nil == next(data_list) then
		return 0
	end
	local total_level = 0
	for k, v in pairs(data_list) do
		total_level = total_level + (v.param.eternity_level or 0)
	end
	return total_level
end

--获取永恒套装总战力
function ForgeData:GetEternityTotalCapability()
	local total_capability = 0
	local attr = CommonStruct.Attribute()
	local equip_data = EquipData.Instance:GetDataList() or {}
	for k, v in pairs(equip_data) do
		local param = v.param
		if param then
			local eternity_level = param.eternity_level or 0
			if self.eternity_equip_cfg[k] then
				local attr_info = self.eternity_equip_cfg[k][eternity_level] or {}
				attr = CommonDataManager.AddAttributeAttr(attr, CommonDataManager.GetAttributteByClass(attr_info))
				total_capability = total_capability + CommonDataManager.GetCapabilityCalculation(attr_info)
			end
		end
	end
	--加上强化百分比战斗力
	local percent = self:GetEternitySuitHXYJPerCent()
	attr.huixinyiji = percent
	total_capability = CommonDataManager.GetCapabilityCalculation(attr)
	return total_capability
end

--获取当前的套装百分比
function ForgeData:GetEternitySuitPerCent()
	local percent = 0
	local suit_level = EquipData.Instance:GetMinEternityLevel()
	local now_suit_cfg = self.eternity_suit_cfg[suit_level] or {}
	percent = now_suit_cfg.per_attr or 0

	return percent
end

--获取当前的套装百分比
function ForgeData:GetEternitySuitHXYJPerCent()
	local percent = 0
	local suit_level = EquipData.Instance:GetMinEternityLevel()
	local now_suit_cfg = self.eternity_suit_cfg[suit_level] or {}
	percent = now_suit_cfg.hxyj or 0

	return percent
end

--获取套装百分比
function ForgeData:GetEternitySuitHXYJPerByLevel(suit_level)
	local suit_cfg = self.eternity_suit_cfg[suit_level] or {}
	local percent = suit_cfg.hxyj or 0
	local percent2 = suit_cfg.hxyj_hurt_per or 0

	return percent, percent2
end

-- 获取永恒装备套装配置
function ForgeData:GetEternitySuitCfg(suit_level)
	if nil == suit_level then return nil, nil end

	local now_suit_cfg = nil
	local next_suit_cfg = nil

	local suit_index = self:GetEternitySuitIndex(suit_level)
	if suit_index <= 0 then
		next_suit_cfg = self.eternity_suit_cfg[suit_level + 1]
		return now_suit_cfg, next_suit_cfg
	end

	now_suit_cfg = self.eternity_suit_cfg[suit_level]

	if suit_index >= self:GetMaxEternitySuitCount() then
		return now_suit_cfg, next_suit_cfg
	end

	for k, v in pairs(self.eternity_suit_cfg) do
		if v.suit_index > suit_index
			and v.suit_index - suit_index == 1 then

			next_suit_cfg = v
			break
		end
	end
	return now_suit_cfg, next_suit_cfg
end

function ForgeData:GetMaxEternitySuitCount()
	if self.max_eternity_suit_count <= 0 then
		for _, v in pairs(self.eternity_suit_cfg) do
			self.max_eternity_suit_count = self.max_eternity_suit_count + 1
		end
	end
	return self.max_eternity_suit_count
end

function ForgeData:GetEternityActiveNum()
	local data_list = EquipData.Instance:GetDataList()
	if nil == data_list or nil == next(data_list) then
		return 0, 0
	end
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	-- local use_eternity_level = game_vo.appearance.use_eternity_level
	local min_eternity_level = EquipData.Instance:GetMinEternityLevel()
	local now_active_nun, next_active_num = 0, 0

	for i = 0, 9 do
		if min_eternity_level <= 0 then
			if self:GetEquipIsActive(i) then
				next_active_num = next_active_num + 1
			end
		else
			now_active_nun = now_active_nun + 1
			if self:GetEquipIsActive(i) then
				next_active_num = next_active_num + 1
			end
		end
	end

	return now_active_nun, next_active_num
end

function ForgeData:GetEquipIsActive(equip_index, max_return)
	if nil == equip_index then return false end

	local equip_data = EquipData.Instance:GetGridData(equip_index)
	if nil == equip_data
		or nil == next(equip_data)
		or nil == equip_data.item_id
		or equip_data.item_id <= 0 then
		return false
	end

	local min_eternity_level = EquipData.Instance:GetMinEternityLevel()
	local now_suit_cfg, next_suit_cfg = self:GetEternitySuitCfg(min_eternity_level)

	if nil == next_suit_cfg then return max_return == true end

	if equip_data.param.eternity_level < next_suit_cfg.suit_level then -- min_eternity_level
		return false
	end

	return true
end

function ForgeData:GetSuitLevelByIndex(suit_index)
	if nil == suit_index then return 0 end

	for k, v in pairs(self.eternity_suit_cfg) do
		if v.suit_index == suit_index then
			return v.suit_level
		end
	end

	return 0
end

function ForgeData:GetEternitySuitIndex(suit_level)
	if nil == suit_level then return 0 end

	if nil == self.eternity_suit_cfg[suit_level] then
		return 0
	end
	return self.eternity_suit_cfg[suit_level].suit_index
end

-- 永恒装备红点
function ForgeData:CaculateEternityRemind()
	for i = 0, 9 do
		if self:GetEquipCanEternity(i) then
			return 0
		end
	end
	return 2
end

function ForgeData:GetEquipCanEternity(equip_index)
	if nil == equip_index then return false end

	local equip_data, item_cfg = nil, nil
	local next_eternity_cfg = self:GetEternityEquipCfg(equip_index, true)
	local cur_eternity_cfg = self:GetEternityEquipCfg(equip_index)
	local bag_num = 0
	local bag_num2 = 0

	if nil ~= next_eternity_cfg then
		equip_data = EquipData.Instance:GetGridData(equip_index)
		item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
		if nil ~= cur_eternity_cfg then
			bag_num = ItemData.Instance:GetItemNumInBagById(cur_eternity_cfg.stuff_id)
			bag_num2 = ItemData.Instance:GetItemNumInBagById(cur_eternity_cfg.stuff_2_id)
			if nil ~= item_cfg and item_cfg.order >= next_eternity_cfg.show_level
				and cur_eternity_cfg.stuff_count <= bag_num and cur_eternity_cfg.stuff_2_num <= bag_num2 then
				return true
			end
		end
	end
	return false
end

function ForgeData:GetForgeStrenthenRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_strengthen") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_strengthen) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeBaoshiRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_baoshi") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_baoshi) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeCastRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_cast") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_cast) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeUpstarRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_up_star") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_up_star) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeSuitRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_suit") then
		return 0
	end

	local temp_equip_list_data = self:ReorderEquipList()
	if self:GetChangeSuitBtnRedPointStatus(temp_equip_list_data, 1)
		or self:GetChangeSuitBtnRedPointStatus(temp_equip_list_data, -1) then
		return 1
	end

	return 0
end

function ForgeData:GetForgeYonghengRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_yongheng") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_yongheng) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetForgeRedEquipRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_red_equip") then
		return 0
	end

	local equip_data = EquipData.Instance:GetDataList()
	for _, v in pairs(equip_data) do
		if v.item_id ~= nil and 0 == self:CheckIsCanImprove(v, TabIndex.forge_red_equip) then
			return 1
		end
	end

	return 0
end

function ForgeData:GetColorComposeCfg()
	return self.color_equipment_compose_cfg
end

function ForgeData:GetColorComposeIndexByStuff(stuff_id)
	for i,v in ipairs(self.color_equipment_compose_cfg) do
		for i1,v1 in ipairs(v) do
			if v1.cfg.stuff_id_0 == stuff_id or v1.cfg.stuff_id_1 == stuff_id or v1.cfg.stuff_id_2 == stuff_id then
				return i, i1
			end
		end
	end
	return 1, 1
end

function ForgeData:GetOneForgeComposeRemind(index, index2)
	if self.compose_red_t[index] == nil then
		return false
	end
	if index2 == nil then
		for k,v in pairs(self.compose_red_t[index]) do
			if v then
				return true
			end
		end
		return false
	end
	return self.compose_red_t[index][index2] == true
end

function ForgeData:GetForgeComposeRemind()
	self.compose_red_t = {}
	local num = 0
	for k,v in ipairs(self.color_equipment_compose_cfg) do
		self.compose_red_t[k] = self.compose_red_t[k] or {}
		for k1,v1 in pairs(v) do
			if k1 ~= "order" and k1 ~= "index" then
				local scroller_data = ForgeData.Instance:GetBagComposeStuff(v1)
				self.compose_red_t[k][k1] = #scroller_data >= 3
				if #scroller_data >= 3 then
					num = num + 1
				end
			end
		end
	end
	ViewManager.Instance:FlushView(ViewName.Treasure, "compose_redpoint")
	return num
end

function ForgeData:GetEquipComponseCfgList(prof, grade)
	if self.equip_compose_cfg[prof] then
		return self.equip_compose_cfg[prof][grade]
	end

	return nil
end

--根据星级和阶数获取背包中的装备列表（红装，本职业的装备，不包括通用装备）
function ForgeData:GetEquipListByGradeAndStar(prof, grade, star, ignore_index_list)
	local bag_epuip_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	if not next(bag_epuip_list) then
		return nil
	end

	prof = prof or 0
	grade = grade or 0
	star = star or 0
	ignore_index_list = ignore_index_list or {}

	local item_cfg = nil
	local param = nil
	local list = nil
	for k, v in ipairs(bag_epuip_list) do
		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		param = v.param

		if nil == ignore_index_list[v.index]
			and item_cfg and grade == item_cfg.order
			and item_cfg.color == 5
			and item_cfg.limit_prof ~= 5 and prof == item_cfg.limit_prof
			and param and param.xianpin_type_list
			and star == #param.xianpin_type_list then

			if nil == list then
				list = {}
			end
			table.insert(list, v)
		end
	end

	return list
end

function ForgeData:GetXianZunCardType()
	local card_type = 0
	local card_name = ""
	local addition_cfg = self.xianzunka_cfg.xianzunka_addition_cfg

	for k, v in pairs(addition_cfg) do
		if (XianzunkaData.Instance:IsActiveForever(v.card_type) or XianzunkaData.Instance:GetCardEndTimestamp(v.card_type) - TimeCtrl.Instance:GetServerTime() > 0)
				and v.add_equip_strength_succ_rate > 0 then
			card_type = v.card_type
			card_name = self.xianzunka_base_cfg[card_type].name
		end
	end

	return card_type, card_name
end

-- 获取特殊宝石在背包中的数量
function ForgeData:GetSpecialGemNumInBag()
	local count = 0
	local special_gem_in_bag_list = self:GetGemsInBag(SPECIAL_GEM_TYPE)
	for k,v in pairs(special_gem_in_bag_list) do
		count = count + 1
	end
	return count, special_gem_in_bag_list
end