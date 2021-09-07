ForgeData = ForgeData or BaseClass()

ForgeData.ForgeType = {
	ForgeStrengthen = 0,
	ForgeGem = 1,
	ForgeCast = 2,
	ForgeUpStar = 3,
}

SOUL_ATTR_NAME_LIST = {
	[0] = "gongji",
	[1] = "fangyu",
	[2] = "maxhp",
	[3] = "mingzhong",
	[4] = "shanbi",
	[5] = "baoji",
	[6] = "jianren",
}

ForgeData.ForgeAttrName = {
	[0] = {
		"ice_master",
		"fire_master",
		"thunder_master",
		"poison_master",
	},
	[1] = {
		"per_pvp_hurt_increase",
	},
	[2] = {
		"per_pofang",
		"per_mianshang",
		"zhanli",
	},
	[3] = {
		"per_pvp_hurt_reduce",
	},
}

ForgeData.GemStoneType = {
	GongJi = 0,
	MaxHp = 1,
	FangYu = 2,
}

ForgeData.StoneMinItemId = 26200
ForgeData.StoneMaxItemId = 26249

FORGE_TYPE =
{
	STRENGTH = 0,
	GEM = 1,
	SHENZHU = 2,
	SHENGXING = 3,
	TAOZHUANG = 4,
	COMPOSE = 5,
}

ForgeData.EquipIndex = {
	GameEnum.EQUIP_INDEX_TOUKUI,
	GameEnum.EQUIP_INDEX_YIFU,
	GameEnum.EQUIP_INDEX_KUZI,
	GameEnum.EQUIP_INDEX_XIEZI,
	GameEnum.EQUIP_INDEX_HUSHOU,
	GameEnum.EQUIP_INDEX_XIANGLIAN,
	GameEnum.EQUIP_INDEX_WUQI,
	GameEnum.EQUIP_INDEX_YAODAI,
}

FORGE_LEVEL_TYPE = {
	BLACK = 0,
	OPEN = 1,
}

SortIndex = {
	[GameEnum.EQUIP_INDEX_TOUKUI] = 2,							--头盔
	[GameEnum.EQUIP_INDEX_YIFU] = 3,								--衣服
	[GameEnum.EQUIP_INDEX_KUZI] = 4,								--裤子
	[GameEnum.EQUIP_INDEX_XIEZI] = 5,								--鞋子
	[GameEnum.EQUIP_INDEX_HUSHOU] = 6,							--护手
	[GameEnum.EQUIP_INDEX_XIANGLIAN] = 7,							--项链
	[GameEnum.EQUIP_INDEX_WUQI] = 1,								--武器
	[GameEnum.EQUIP_INDEX_YAODAI] = 8,							--腰带
}

-- SortIndexNew = {
-- 	[GameEnum.EQUIP_INDEX_WUQI] = 1,								--武器
-- 	[GameEnum.EQUIP_INDEX_TOUKUI] = 2,							--头盔
-- 	[GameEnum.EQUIP_INDEX_YIFU] = 3,								--衣服
-- 	[GameEnum.EQUIP_INDEX_KUZI] = 4,								--裤子
-- 	[GameEnum.EQUIP_INDEX_XIEZI] = 5,								--鞋子
-- 	[GameEnum.EQUIP_INDEX_HUSHOU] = 6,							--护手
-- 	[GameEnum.EQUIP_INDEX_XIANGLIAN] = 7,							--项链
-- 	[GameEnum.EQUIP_INDEX_YAODAI] = 8,							--腰带
-- }

SortIndexNew = {
	[1] = GameEnum.EQUIP_INDEX_WUQI,
	[2] = GameEnum.EQUIP_INDEX_TOUKUI,
	[3] = GameEnum.EQUIP_INDEX_YIFU,
	[4] = GameEnum.EQUIP_INDEX_KUZI,
	[5]	= GameEnum.EQUIP_INDEX_XIEZI,
	[6]	= GameEnum.EQUIP_INDEX_HUSHOU,	
	[7]	= GameEnum.EQUIP_INDEX_XIANGLIAN,
	[8]	= GameEnum.EQUIP_INDEX_YAODAI,
}

ForgeData.GemState = {
	Lock = 0,			-- 锁定
	CanInLay = 1,		-- 可镶嵌
	HasInLay = 2,		-- 已镶嵌
}

ForgeData.SOUL_FROM_VIEW = {
	SOUL_POOL = 1, 
	SOUL_BAG = 2,
}

function ForgeData:__init()
	if ForgeData.Instance ~= nil then
		print_error("[ForgeData] attempt to create singleton twice!")
		return
	end
	self.total_level = 0
	self.gem_info = {}
	self.suit_info = {}
	ForgeData.Instance = self
	self.red_point_list = {
		[TabIndex.forge_strengthen] = false,
		[TabIndex.forge_baoshi] = false,
		[TabIndex.forge_cast] = false,
		[TabIndex.forge_up_star] = false,
		[TabIndex.forge_suit] = false,
	}
	self.fun_open_list = {
		[TabIndex.forge_strengthen] = false,
		[TabIndex.forge_baoshi] = false,
		[TabIndex.forge_cast] = false,
		[TabIndex.forge_up_star] = false,
		[TabIndex.forge_suit] = false,
	}
	self.cur_item_data = nil
	self.cur_open_view = 1

	self.last_flush_time = 0

	self.slot_soul_info = {
		notify_reason = 0,
		lieming_list = {},
	}
	self.soul_bag_info = {
		notify_reason = 0,
		hunshou_exp = 0,
		liehun_color = 0,
		daily_has_free_chou = 0,
		daily_has_change_color = 0,
		hunli = 0,
		liehun_pool = {},
		grid_list = {},
	}
     self.spirit_info = {
    	jingling_name = 0,
		use_jingling_id = 0,
		use_imageid = 0,
		m_active_image_flag = 0,
		special_img_active_flag = 0,
		phantom_imageid = 0,
		count = 0,

		jinglingcard_list = {},
		phantom_level_list = {},
		phantom_level_list_new = {},
		jingling_list = {},
 	}

 	RemindManager.Instance:Register(RemindName.SpiritSoulGet, BindTool.Bind(self.GetSpiritSoulGetRemind, self))	
end

function ForgeData:__delete()
	ForgeData.Instance = nil
	self.soul_bag_info = {}

  	RemindManager.Instance:UnRegister(RemindName.SpiritSoulGet)
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

function ForgeData:GetStrengthListCfg()
	local cfg = self:GetSysCfg()
	if nil == self.strength_cfg then
		self.strength_cfg = ListToMap(cfg.strength_base, "equip_index", "strength_level")
	end
	return self.strength_cfg
end

function ForgeData:GetUpStarCfg()
	local cfg = self:GetSysCfg()
	if nil == self.up_star_cfg then
		self.up_star_cfg = ListToMap(cfg.up_star, "equip_index", "star_level")
	end
	return self.up_star_cfg
end

function ForgeData:GetStoneCfg()
	local cfg = self:GetSysCfg()
	if nil == self.stone_cfg then
		self.stone_cfg = ListToMap(cfg.stone, "item_id")
	end
	return self.stone_cfg
end

function ForgeData:GetStoneTypeCfg()
	local cfg = self:GetSysCfg()
	if nil == self.stone_type_level_cfg then
		self.stone_type_level_cfg = ListToMap(cfg.stone, "stone_type", "level")
	end
	return self.stone_type_level_cfg
end

function ForgeData:GetShenOpCfg()
	local cfg = self:GetSysCfg()
	if nil == self.shen_op_cfg then
		self.shen_op_cfg = ListToMap(cfg.shen_op, "equip_index", "shen_level")
	end
	return self.shen_op_cfg
end

function ForgeData:GetXianPinCfg()
	local cfg = self:GetSysCfg()
	if nil == self.xianpin_cfg then
		self.xianpin_cfg = ListToMap(cfg.xianpin, "xianpin_type")
	end
	return self.xianpin_cfg
end

function ForgeData:GetLieMingAutoCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto")
end

function ForgeData:GetSoulAuotCfg()
	local cfg = self:GetLieMingAutoCfg()
	if nil == self.soul_level_cfg then
		self.soul_level_cfg = ListToMap(cfg.hunge_activity_condition, "active_mingge_count")
	end
	return self.soul_level_cfg
end

function ForgeData:GetZhuangBerCfg()
	local cfg = self:GetLieMingAutoCfg()
	if nil == self.zhuangbei_open_cfg then
		self.zhuangbei_open_cfg = cfg.zhuangbei_open
	end
	return self.zhuangbei_open_cfg
end

function ForgeData:GetTotalCfg()
	local cfg = self:GetSysCfg()
	if nil == self.total_upstar_cfg then
		self.total_upstar_cfg = cfg.total_upstar
	end
	return self.total_upstar_cfg
end

function ForgeData:GetAllShenOpCfg()
	local cfg = self:GetSysCfg()
	if nil == self.all_shen_op_cfg then
		self.all_shen_op_cfg = cfg.all_shen_op
	end
	return self.all_shen_op_cfg
end

function ForgeData:GetGemOpenCfg()
	local cfg = self:GetSysCfg()
	if nil == self.gem_open_limit_cfg then
		self.gem_open_limit_cfg = cfg.stone_open_limit
	end
	return self.gem_open_limit_cfg
end

function ForgeData:GetSuitCfg()
	return ConfigManager.Instance:GetAutoConfig("duanzaosuit_auto") or {}
end

function ForgeData:GetSuitUpLevelCfg()
	local cfg = self:GetSuitCfg()
	if nil == self.suit_uplevel_cfg then
		self.suit_uplevel_cfg = ListToMap(cfg.suit_uplevel, "equip_id")
	end
	return self.suit_uplevel_cfg
end

function ForgeData:GetSuitAttListCfg()
	local cfg = self:GetSuitCfg()
	if nil == self.suit_attr_ss_list_cfg then
		self.suit_attr_ss_list_cfg = ListToMap(cfg.suit_attr_ss, "suit_id", "equip_count")
	end
	return self.suit_attr_ss_list_cfg
end

function ForgeData:GetSuitCQListCfg()
	local cfg = self:GetSuitCfg()
	if nil == self.suit_attr_cq_list_cfg then
		self.suit_attr_cq_list_cfg = ListToMap(cfg.suit_attr_cq, "suit_id", "equip_count")
	end
	return self.suit_attr_cq_list_cfg
end

function ForgeData:GetXianPinFixCfg()
	local cfg = self:GetSysCfg()
	if nil == self.xianpin_fix then
		self.xianpin_fix = cfg.xianpin_fix
	end
	return self.xianpin_fix
end

function ForgeData:GetXianPinShowCfg()
	local cfg = self:GetSysCfg()
	if nil == self.xianpin_show then
		self.xianpin_show = cfg.xianpin_show
	end
	return self.xianpin_show
end

function ForgeData:GetCompoundCfg()
	local cfg = self:GetSysCfg()
	if nil == self.equipment_compose_cfg then
		self.equipment_compose_cfg = cfg.equiment_compound_cfg
	end
	return self.equipment_compose_cfg
end

function ForgeData:GetSlotCfg()
	local cfg = self:GetSysCfg()
	if nil == self.equipment_slot_cfg then
		self.equipment_slot_cfg = cfg.equiment_compound_slot
	end
	return self.equipment_slot_cfg
end

function ForgeData:GetZhuanShengCfg()
	return ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto") or {}
end

function ForgeData:GetRandValCfg()
	local cfg = self:GetZhuanShengCfg()
	if nil == self.equiment_zhuang_sheng_cfg then
		self.equiment_zhuang_sheng_cfg = cfg.rand_attr_val
	end
	return self.equiment_zhuang_sheng_cfg
end

function ForgeData:GetEquipShowCfg()
	local cfg = self:GetZhuanShengCfg()
	if nil == self.equiment_zs_equip_show_cfg then
		self.equiment_zs_equip_show_cfg = cfg.equip_show
	end
	return self.equiment_zs_equip_show_cfg
end
function ForgeData:GetSysCfg()
	return ConfigManager.Instance:GetAutoConfig("equipforge_auto") or {}
end

function ForgeData:GetNameEffectByData(data)
	local cfg = self:GetShenOpSingleCfg(data.index, data.param.shen_level)
	return cfg and cfg.effect or 0
end

function ForgeData:GetStrengthSingleCfg(equip_index, strength_level)
	local cfg = self:GetStrengthListCfg()[equip_index]
	return cfg and cfg[strength_level] or nil
end

function ForgeData:GetUpStarSingleCfg(equip_index, star_level)
	local cfg = self:GetUpStarCfg()[equip_index]
	return cfg and cfg[star_level] or nil
end

function ForgeData:GetShenOpSingleCfg(equip_index, shen_level)
	local cfg =  self:GetShenOpCfg()[equip_index]
	return cfg and cfg[shen_level] or nil
end

function ForgeData:GetGemCfg(item_id)
	return self:GetStoneCfg()[item_id]
end

function ForgeData:GetGemCfgByTypeAndLevel(type, level)
	local cfg = self:GetStoneTypeCfg()[type]
	return cfg and cfg[level]
end

--传奇 根据类型获取传奇属性Cfg
function ForgeData:GetLegendCfgByType(type)
	return self:GetXianPinCfg()[type]
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
	local cfg = self:GetStrengthListCfg()[equip_index]
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

function ForgeData:GetMinStrengthLevel()
	local data = EquipData.Instance:GetDataList()
	local min_level = 999
	for i = 1, 10 do
		if i ~= GameEnum.EQUIP_INDEX_JIEZHI and i ~= GameEnum.EQUIP_INDEX_JIEZHI_2 then
			if nil == data[i] or nil == next(data[i]) then
				return 0
			end
		end
	end
	for k, v in pairs(data) do
		local strength_level = ForgeData.Instance:GetLevelCfgByStrengthLv(v.param.strengthen_level)
		min_level = strength_level <= min_level and strength_level or min_level
	end
	return min_level
end

--强化 获取全身强化Cfg
function ForgeData:GetTotalStrengthCfgByLevel(total_level)
	local full_strength_cfg = self:GetSysCfg().strength_minlevel_reward
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
	local total_strength_cfg = self:GetSysCfg().strength_minlevel_reward
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

	local level = 0
	if is_next then
		level = data.param.strengthen_level + 1
	else
		level = data.param.grid_strengthen_level or data.param.strengthen_level
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
	for k,v in pairs(self:GetGemOpenCfg()) do
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
	local strength_list_cfg =  self:GetStrengthListCfg()[param_data.index]

	for k,v in pairs(gem_data) do
		local temp_data = {}
		if v.stone_id == 0 then
			if self.stone_limit_list[32-k] == 0 then
				temp_data.gem_state = 0

				for _, v2 in pairs(strength_list_cfg) do
					if v2.stone_hole_num > k then
						temp_data.open_level = v2.strength_level
						break
					end
				end
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
	if next(all_type_list) then
		for k,v in pairs(all_type_list) do
			if v ~= 4 then
				return v
			end
		end
	end
	return 0
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

--宝石 根据宝石类型获取该类型1级的宝石
function ForgeData:GetMinLevelGemsIDByType(gem_type)
	for k,v in pairs(self:GetSysCfg().stone) do
		if v.stone_type == gem_type and v.level == 1 then
			return v
		end
	end
end

--宝石 获得宝石中文属性对
function ForgeData:GetGemAttr(gem_id)
	forge_gem_cfg = self:GetGemCfg(gem_id)
	local item_cfg = ItemData.Instance:GetItemConfig(gem_id)
	-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.. ":" .. "</color>" 
	local name_str = item_cfg.name .. ":"
	local attr_list = {}
	local function change_color(text)
		-- return "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. text .. "</color>" 
		return ToColorStr(text, SOUL_NAME_COLOR[item_cfg.color])
	end
	for i=1,2 do
		if forge_gem_cfg["attr_type"..i] == nil or forge_gem_cfg["attr_type"..i] == 0 then
			break
		else
			local data = {}
			if forge_gem_cfg.stone_type > 2 then
				-- data.attr_name = ToColorStr(Language.Equip.BaoShi..CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i]), TEXT_COLOR.BLUE_2)
				-- data.attr_value = ToColorStr((forge_gem_cfg["attr_val"..i]/100)..'%', TEXT_COLOR.GRAY_WHITE)
				data.attr_name = change_color(name_str .. Language.Equip.BaoShi..CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i]) .. "+")
				data.attr_value = change_color((forge_gem_cfg["attr_val"..i]/100)..'%')
				data.number_value = forge_gem_cfg["attr_val"..i]
			else
				-- data.attr_name = ToColorStr(CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i]), TEXT_COLOR.BLUE_2)
				-- data.attr_value = ToColorStr(forge_gem_cfg["attr_val"..i], TEXT_COLOR.GRAY_WHITE)
				data.attr_name = change_color(name_str .. CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i]) .. "+")
				data.attr_value = change_color(forge_gem_cfg["attr_val"..i])
				data.number_value = forge_gem_cfg["attr_val"..i]
			end
			data.attr_real_name = CommonDataManager.GetAttrName(forge_gem_cfg["attr_type"..i])
			table.insert(attr_list,data)
		end
	end
	return attr_list
end

--宝石 得到玩家背包中的宝石 gem_type:0-4,指定宝石的类型，5为得到全部
function ForgeData:GetGemsInBag(gem_type)
	-- print(ToColorStr("GetGemsInBag", TEXT_COLOR.GREEN))
	local gems_list = {}
	local count = 1
	for k,v in pairs(ItemData.Instance:GetBagItemDataList()) do
		local cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)

		if big_type == GameEnum.ITEM_BIGTYPE_OTHER and nil ~= self:GetGemCfg(v.item_id) then

			if gem_type == 5 then
				v.cfg = cfg
				gems_list[count] = v
				count = count + 1
			else
				if v.index < COMMON_CONSTS.MAX_BAG_COUNT then
					gem_cfg = self:GetGemCfg(cfg.id)
					if gem_cfg ~= nil then
						if gem_cfg.stone_type == gem_type then
							v.cfg = cfg
							gems_list[count] = v
							count = count + 1
						end
					end
				end
			end
		end
	end

	if gem_type ~= 5 then
		for i=1, #gems_list do
			for j=i+1,#gems_list do
				if gems_list[i].item_id < gems_list[j].item_id then
					gems_list[i], gems_list[j] = gems_list[j], gems_list[i]
				end
			end
		end
	end
	return gems_list
end

--宝石 根据编号获取全身宝石配置
function ForgeData:GetTotalGemCfgByLevel(level)

	local total_gem_cfg = self:GetSysCfg().stone_ex_add
	for k,v in pairs(total_gem_cfg) do
		if v.stone_level == level then
			return v.name
		end
	end
end

--宝石 全身宝石等级配置
function ForgeData:GetTotalGemCfg()
	local total_gem_cfg = self:GetSysCfg().stone_ex_add
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
				if gem_cfg.stone_type <=2 then
					if final_attr[gem_cfg.attr_type1] == nil then
						final_attr[gem_cfg.attr_type1] = 0
					end
					final_attr[gem_cfg.attr_type1] =  final_attr[gem_cfg.attr_type1] + gem_cfg.attr_val1
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
	local total_gem_cfg = self:GetSysCfg().stone_ex_add
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
		local total_gem_cfg = self:GetSysCfg().stone_ex_add
		suit_power = CommonDataManager.GetCapabilityCalculation( total_gem_cfg[suit_id] )
	end
	return suit_power
end

--宝石 获取套装id
function ForgeData:GetGemSuitId()
	local suit_id = -1
	local total_gem_cfg = self:GetSysCfg().stone_ex_add

	--获取全部宝石的总等级
	local total_level = 0
	for k,v in pairs(self.gem_info) do
		for k1,v1 in pairs(v) do
			if v1.stone_id ~= 0 then
				local gem_cfg = self:GetGemCfg(v1.stone_id)
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
		local total_strength_cfg = self:GetSysCfg().strength_minlevel_reward
		suit_power = CommonDataManager.GetCapabilityCalculation(total_strength_cfg[suit_id + 1] )
	end
	return suit_power
end

--强化获取套装id
function ForgeData:GetStrengthSuitId()
	local suit_id = -1
	local total_strength_cfg = self:GetSysCfg().strength_minlevel_reward

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
		local total_cast_cfg = self:GetSysCfg().all_shen_op
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
	local total_cast_cfg = self:GetSysCfg().all_shen_op

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
		local total_up_star_cfg = self:GetSysCfg().total_upstar
		suit_power = CommonDataManager.GetCapabilityCalculation(total_up_star_cfg[suit_id + 1] )
	end
	return suit_power
end

--升星获取套装id
function ForgeData:GetUpStarSuitId()
	local suit_id = -1
	local total_up_star_cfg = self:GetSysCfg().total_upstar

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
		-- local bag_gem = self:GetGemsInBag(k)
		if v.gem_state == 1 then
			--处理可镶嵌
			if #bag_gem > 0 then
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
				for i=1,#bag_gem do
					if bag_gem[i].item_id <= forge_gem_cfg.item_id then
						local tmp_forge_gem_cfg = ForgeData.Instance:GetGemCfg(bag_gem[i].item_id)
						had_energy = had_energy + (math.pow(3, tmp_forge_gem_cfg.level - 1) * bag_gem[i].num)
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
	local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
	local cur_index = data.index
	if equip_index < 0 then
		return nil
	end
	if equip_index ~= data.index then
		cur_index = equip_index
	end
	local cast = 0
	if is_next then
		cast = data.param.shen_level + 1
	else
		cast = data.param.grid_shen_level or data.param.shen_level
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
	local casst_auto =  self:GetSysCfg().all_shen_op
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
		return ""
	end
	local shen_level = data.param.shen_level
	if nil == shen_level or shen_level > 10 then
		return 10
	end
	return shen_level
end

function ForgeData:GetCanUpStarByLevelAndIndex(index, level)
	if level >= 100 then return false end
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
			if equip_data.param.star_level < 100 then
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
		return -1
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
		if mojing > 0 and param.star_level and param.star_level < 100 then
			local need_star_mojing = self:GetStarAttr(data.index, param.star_level + 1)
			if mojing > need_star_mojing.need_shengwang then
				return 0
			else
				return 2
			end
		else
			return 2
		end
	end
	--是否满级
	if next_cfg == nil then
		return 1
	end
	--材料
	local item_id = next_cfg["stuff_id"]
	local item_count = next_cfg["stuff_count"]
	local had_item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if had_item_num < item_count then
		return 2, item_id, (item_count - had_item_num)
	end
	--强化特有，阶数限制
	if param_type == TabIndex.forge_strengthen then
		if not self:GetEquipCanStrengthByGrade(data) then
			return 3
		end
	end
	return 0
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
--红点 获取所有红点信息
function ForgeData:GetRedPointList()
	return self.red_point_list
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

--红点 设定所有红点
-- 这里加了2秒CD，若短时间内重复刷新，则延迟到2秒后只执行一次
function ForgeData:SetAllRedPoint()
	if self.last_flush_time + 2 <= Status.NowTime then
		self.last_flush_time = Status.NowTime
		return self:CaculateRedPoint()
	else
		self.last_flush_time = Status.NowTime
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:SetAllRedPoint() end, 2.1)
	end
end

-- 计算所有红点
function ForgeData:CaculateRedPoint()
	local equip_data = EquipData.Instance:GetDataList()
	for k,v in pairs(self.red_point_list) do
		local flag = false
		for k2,v2 in pairs(equip_data) do
			if v2.item_id ~= nil then
				local can_improve = self:CheckIsCanImprove(v2, k)
				if can_improve == 0 then
					flag = true
					break
				end
			end
		end
		self.red_point_list[k] = flag
	end

	--设置套装红点状态
	local temp_equip_list_data = self:ReorderEquipList()
	local ss_btn_red_point_status = self:GetChangeSuitBtnRedPointStatus(temp_equip_list_data, 1)
	local cs_btn_red_point_status = self:GetChangeSuitBtnRedPointStatus(temp_equip_list_data, -1)
	self.red_point_list[TabIndex.forge_suit] = ss_btn_red_point_status or cs_btn_red_point_status

	local is_open_strengthen = OpenFunData.Instance:CheckIsHide("forge_strengthen")
	local is_open_baoshi = OpenFunData.Instance:CheckIsHide("forge_baoshi")
	local is_open_cast = OpenFunData.Instance:CheckIsHide("forge_cast")
	local is_open_up_star = OpenFunData.Instance:CheckIsHide("forge_up_star")
	local is_open_suit = OpenFunData.Instance:CheckIsHide("forge_suit")
	self.fun_open_list[TabIndex.forge_strengthen] = is_open_strengthen
	self.fun_open_list[TabIndex.forge_baoshi] = is_open_baoshi
	self.fun_open_list[TabIndex.forge_cast] = is_open_cast
	self.fun_open_list[TabIndex.forge_up_star] = is_open_up_star
	self.fun_open_list[TabIndex.forge_suit] = is_open_suit
	for k,v in pairs(self.fun_open_list) do
		if false == v then
			self.red_point_list[k] = v
		end
	end

	ForgeCtrl.Instance:FlushRedPoint()
	local forge_flag = false
	for k,v in pairs(self.red_point_list) do
		if v then
			forge_flag = true
			break
		end
	end
	-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Forge, forge_flag)
	return forge_flag and 1 or 0
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
	for k, v in ipairs(self:GetTotalCfg()) do
		if all_star_level < v.total_star then
			now_total = self:GetTotalCfg()[k - 1] or {}
			next_total = v
			break
		end
	end
	if not next(now_total) and not next(next_total) then
		now_total = self:GetTotalCfg()[#self:GetTotalCfg()]
	end
	return all_star_level, now_total, next_total
end

--获取升星套装属性
function ForgeData:GetTotleStarBySeq(seq)
	local taozhuang_name = ""
	for k, v in ipairs(self:GetTotalCfg()) do
		if v.seq == seq then
			taozhuang_name = v.name
			break
		end
	end
	return taozhuang_name
end

function ForgeData:GetEquipZhanLi()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		capability = capability + EquipData.Instance:GetEquipLegendFightPowerByData(v, false, true, nil, false, true)
	end

	local strength_power = self:GetStrengthPower()
	local baoshi_power = self:GetTotalGemPower()
	local cast_power = self:GetShenZhuPower()
	local up_star_power = self:GetUpStarPower()
	local suit_power = self:GetSuitPower()

	capability = capability + strength_power + baoshi_power + cast_power + up_star_power + suit_power
	return capability
end

--强化战力
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

--神铸战力
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

--升星战力
function ForgeData:GetUpStarPower()
	local equiplist = EquipData.Instance:GetDataList()
	local capability = 0
	for k,v in pairs(equiplist) do
		local attr_info = self:GetStarAttr(v.index, v.param.star_level)
		capability = capability + CommonDataManager.GetCapability(attr_info)
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
	return self:GetSuitUpLevelCfg()[item_id]
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
	if suit_type == 1 and nil ~= self:GetSuitAttListCfg()[suit_id] then
		return self:GetSuitAttListCfg()[suit_id][equip_count]

	elseif suit_type == -1 and nil ~= self:GetSuitCQListCfg()[suit_id] then
		return self:GetSuitCQListCfg()[suit_id][equip_count]
	end

	return nil
end

--获取装备的套装名
function ForgeData:GetSuitName(suit_id, suit_type)
	local list = nil
	if suit_type == 1 then
		list = self:GetSuitAttListCfg()[suit_id]

	elseif suit_type == -1 then
		list = self:GetSuitCQListCfg()[suit_id]
	end

	if nil == list then
		return ""
	end

	local _, cfg = next(list)
	return cfg and cfg.suit_name or ""
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
			t.sort = equip_type_dic[item_cfg.sub_type]
			t.data = v
			-- local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			-- if item_cfg.sub_type ~= 106 then --排除武器
				table.insert(temp_equip_list, t)
			-- end
		end
	end

	table.sort(temp_equip_list, SortTools.KeyLowerSorter("sort"))

	local sort_list = {}
	for k,v in pairs(temp_equip_list) do
		sort_list[k] = v.data
	end
	return sort_list
end

function ForgeData:GetEquipXianpinAttr(equip_id, gift_item_id)
	local type_list = {}
	local max_xianpin_num = 3
	local is_random = false

	if gift_item_id then
		for k, v in pairs(self:GetXianPinFixCfg()) do
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
			for k, v in pairs(self:GetXianPinShowCfg()) do
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
			for k, v in pairs(self:GetXianPinShowCfg()) do
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

	for k, v in pairs(self:GetXianPinFixCfg()) do
		if v.equip_id == equip_id and v.param_1 == gift_item_id then
			return true
		end
	end

	return false
end

function ForgeData:GetTypeListByIndex(index)
	local equip_list = {}
	for k,v in pairs(self:GetCompoundCfg()) do
		if v.index == index -1 then
			table.insert(equip_list, v)
		end
	end
	return equip_list
end

function ForgeData:GetSlotTypeByIndex(index)
	return self:GetSlotCfg()[index].equiment_slot
end

function ForgeData:GetNumOfSlot()
	local count = 0
	for k,v in pairs(self:GetSlotCfg()) do
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
	for k,v in pairs(self:GetCompoundCfg()) do
		if grade == v.compound_order and star + 1 == v.compound_star then
			return v
		end
	end
end

function ForgeData:GetBagComposeStuff(grade, star)
	local requst_list = self:GetComposeNeedStuff(grade, star)
	local bag_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
	if nil == bag_list or #bag_list <= 0 then return {} end

	local main_role_prof = GameVoManager.Instance:GetMainRoleVo().prof
	local match_list = {}
	for k,v in pairs(bag_list) do
		local equip_cfg = ItemData.Instance:GetItemConfig(v.item_id)

		local star_index = 0
		if v.param.xianpin_type_list and not EquipData.IsJLType(equip_cfg.sub_type) then
			for k1, v1 in pairs(v.param.xianpin_type_list) do
				if v1 ~= nil and v1 > 0 then
					local legend_cfg = self:GetLegendCfgByType(v1)
					if legend_cfg ~= nil and legend_cfg.color == 1 then
						star_index = star_index + 1
					end
				end
			end
		end
		if equip_cfg.color == requst_list.need_color and requst_list.compound_order == equip_cfg.order and requst_list.need_star == star_index then
			if main_role_prof == equip_cfg.limit_prof or equip_cfg.limit_prof == 5 then
				table.insert(match_list, v)
			end
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
	for k,v in pairs(self:GetRandValCfg()) do
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
	for k,v in pairs(self:GetEquipShowCfg()) do
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
		total_str =  total_level_name .. "(".. now_level .. "/" .. total_level .. ")"
	else
		now_level = ToColorStr(now_level, TEXT_COLOR.GRAY_WHITE) --  .. Language.Common.Ji
		total_str = total_level_name .. "(" .. now_level .. ")"
	end
	return total_str
end

function ForgeData:GetShowXianPinCfg()
	local decs_list = {}
	for k,v in pairs(self:GetXianPinCfg()) do
		if v.equip_color == 5 and v.color == 1 then
			table.insert(decs_list, v.desc)
		end
	end
	return decs_list
end

function ForgeData:GetShowXianPinCount()
	local count = 0
	local xianpin_cfg = self:GetSysCfg().xianpin
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
	for k,v in pairs(self:GetShenOpCfg()) do
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

------------------------------Common---------------------------------------
-- 获取当前装备列表
function ForgeData:GetCurEquipList()
	local equip_list = {}
	for k, v in pairs(EquipData.Instance:GetDataList()) do
		if v.index then
			local temp = TableCopy(v)
			temp.sort_index = SortIndex[v.index]
			table.insert(equip_list, temp)
		end
	end
	
	table.sort(equip_list, SortTools.KeyLowerSorter("sort_index"))
	return equip_list
end

function ForgeData:GetCurSoulEquipList()
	local equip_list = {}
	local index, index_one, index_two = 10, 20, 30
	for k, v in ipairs(SortIndexNew) do
		local temp = self:GetCurSoulEquip(v)
		if temp then
			if self:GetCurEquipIsLock(k) then
				index_two = index_two + 1
				temp.sort_index = index_two
			else
				temp.sort_index = k
			end
		else
			temp = {}
			index = index + 1
			index_two = index_two + 1
			if self:GetCurEquipIsLock(k) then
				temp.sort_index = index_two
				temp.sort_type = 0
			else
				temp.sort_index = index_two
				temp.sort_type = 1
			end
		end
		temp.equip_type = k
		table.insert(equip_list, temp)
	end
	table.sort(equip_list, SortTools.KeyLowerSorter("sort_index"))
	return equip_list
end

function ForgeData:IsHaveSoulEquip(index)
	for k, v in pairs(EquipData.Instance:GetDataList()) do
		if v.index == SortIndexNew[index] then
			return true
		end
	end
	return false
end

function ForgeData:GetCurSoulEquip(index)
	for k, v in pairs(EquipData.Instance:GetDataList()) do
		if v.index == index then
			temp = TableCopy(v)
			return temp
		end
	end
end

function ForgeData:GetCurEquipIsLock(index)
	local role_vo = vo or GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetZhuangBerCfg()
	if cfg[index] then
		return cfg[index].open_level > role_vo.level , cfg[index].open_level
	end
end

function ForgeData:GetCurEquipNextLevel()
	local role_vo = vo or GameVoManager.Instance:GetMainRoleVo()
	local cfg = self:GetZhuangBerCfg()
	local next_level = 1
	if cfg then
		for i,v in ipairs(cfg) do
			if v.open_level > role_vo.level then
				next_level = i
				return next_level
			end
		end
	end
	return next_level
end
-- 获取装备默认下标
function ForgeData:GetDefaultEquipIndex()
	local equip_data = self:GetCurEquipList()
	return equip_data[1] and equip_data[1].index or 0
end
---------------------------------------------------------------------------
-- function ForgeData:GetSoulEquipList()
-- 	-- body
-- end


------------------------------Strength-------------------------------------
-- 根据强化等级获取当前需要显示的信息
function ForgeData:GetLevelCfgByStrengthLv(equip_index, strength_level)
	local equip_strength_level = 0
	local cur_level = 0
	local total_level = 0
	local cfg = self:GetStrengthSingleCfg(equip_index, strength_level)
	if nil == cfg or nil == next(cfg) then
		return equip_strength_level, cur_level, total_level
	end

	equip_strength_level = cfg.equip_strength_level or 0

	for k, v in pairs(self:GetStrengthListCfg()[equip_index]) do
		if v.equip_strength_level == equip_strength_level then
			total_level = total_level + 1
			if v.strength_level <= strength_level then
				cur_level = cur_level + 1
			end
		end
	end

	local next_cfg = self:GetStrengthSingleCfg(equip_index, strength_level + 1)
	if next_cfg then
		if next_cfg.equip_strength_level > cfg.equip_strength_level then
			equip_strength_level = equip_strength_level + 1
			cur_level = 0
		end
	end

	return equip_strength_level, cur_level, total_level
end

-- 获取强化界面当前装备所需显示的属性
function ForgeData:GetStrengthShowAttr(attr_data)
	local attr_list = {"max_hp", "gongji", "fangyu", "mingzhong", "shanbi", "baoji", "jianren"}
	for k, v in pairs(attr_list) do
		if attr_data[v] ~= 0 then
			return v
		end
	end

	return nil
end

-- 获取强化最大等级
function ForgeData:GetStrengthMaxLevel()
	return #self:GetStrengthListCfg()[0] or 0
end

-- 获取强化总属性
function ForgeData:GetStrengthTotalAttr()
	local total_attr = CommonStruct.Attribute()

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			local strength_cfg = self:GetStrengthSingleCfg(equip_data.index, equip_data.param.strengthen_level)
			local convert_strength_cfg = CommonDataManager.GetAttributteByClass(strength_cfg)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, convert_strength_cfg)
		end
	end

	return total_attr
end

function ForgeData:GetTotalLvByStrengthLv(strength_level)
	local total_level = 0
	local cfg = self:GetStrengthListCfg()[0]
	for k, v in pairs(cfg) do
		if strength_level == v.equip_strength_level then
			total_level = total_level + 1
		end
	end

	return total_level
end

-- 获取强化套装等级（全身装备强化最小等级）
function ForgeData:GetStrengthMinLevel()
	local min_level = 999

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil == equip_data then
			return 0
		end

		local strength_level = self:GetLevelCfgByStrengthLv(v, equip_data.param.strengthen_level)
		min_level = strength_level <= min_level and strength_level or min_level
	end

	return min_level
end

-- 获取强化套装属性
function ForgeData:GetStrengthAddCfgAndNextLevel()
	local level = self:GetStrengthMinLevel()
	local next_level = 3
	local cur_attr = CommonStruct.Attribute()
	local next_attr = CommonStruct.Attribute()
	local total_strength_cfg = self:GetSysCfg().strength_minlevel_reward
	for k, v in pairs(total_strength_cfg) do
		if level == v.need_min_strength_level then
			cur_attr = v
		end
	end

	next_level = level < 3 and next_level or level + 1

	for k, v in pairs(total_strength_cfg) do
		if next_level == v.need_min_strength_level then
			next_attr = v
		end
	end

	return cur_attr, next_level, next_attr
end

-- 获取全身是否强化满级
function ForgeData:GetIsStrengthMaxLevel()
	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			if equip_data.param.strengthen_level < self:GetStrengthMaxLevel() then
				return false
			end
		else
			return false
		end
	end

	return true
end

-- 获取强化对应index的item的红点提示
function ForgeData:GetStrengthRemindByIndex(index)
	local equip_data = EquipData.Instance:GetGridData(index)
	if equip_data then
		local attr = self:GetStrengthSingleCfg(index, equip_data.param.strengthen_level + 1)
		if nil == attr then
			return false
		end
		local item_has_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)
		local item_need_num = attr.stuff_count

		return item_has_num >= item_need_num
	end
	return false
end
---------------------------------------------------------------------------

------------------------------Gem------------------------------------------
--获取装备上所有宝石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function ForgeData:GetGemStateByEquipData(data)
	local gem_state = {}
	if nil == data then return gem_state end
	local gem_data = self.gem_info[data.index] or {}

	for k, v in pairs(gem_data) do
		if v.stone_id == 0 then
			if self.stone_limit_list[32 - k] == 0 then
				table.insert(gem_state, ForgeData.GemState.Lock)
			else
				table.insert(gem_state, ForgeData.GemState.CanInLay)
			end
		else
			table.insert(gem_state, ForgeData.GemState.HasInLay)
		end
	end
	return gem_state
end

-- 根据武器index获取可镶嵌宝石类型
function ForgeData:GetStoneTypeByIndex(index)
	local stone_type = 0

	if (index == GameEnum.EQUIP_INDEX_WUQI or index == GameEnum.EQUIP_INDEX_HUSHOU or index == GameEnum.EQUIP_INDEX_XIANGLIAN) then
		stone_type = ForgeData.GemStoneType.GongJi
	elseif (index == GameEnum.EQUIP_INDEX_KUZI or index == GameEnum.EQUIP_INDEX_YAODAI) then
		stone_type = ForgeData.GemStoneType.MaxHp
	elseif (index == GameEnum.EQUIP_INDEX_TOUKUI or index == GameEnum.EQUIP_INDEX_YIFU or index == GameEnum.EQUIP_INDEX_XIEZI) then
		stone_type = ForgeData.GemStoneType.FangYu
	end

	return stone_type
end

-- 根据武器index获取可镶嵌宝石列表
function ForgeData:GetStoneListByIndex(forge_index)
	local data = {}
	local stone_list = {}
	local item_data = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(item_data) do
		if v.item_id >= ForgeData.StoneMinItemId and v.item_id <= ForgeData.StoneMaxItemId then
			table.insert(stone_list, v)
		end
	end
	for k, v in pairs(stone_list) do
		local cfg = self:GetGemCfg(v.item_id)
		if cfg then
			if cfg.stone_type == self:GetStoneTypeByIndex(forge_index) then
				table.insert(data, v)
			end
		end
	end

	table.sort(data, SortTools.KeyUpperSorter("item_id"))

	-- 没有宝石自动放一颗最高级的到列表中
	if nil == next(data) then
		local gem_cfg = self:GetGemCfgByTypeAndLevel(self:GetStoneTypeByIndex(forge_index), 15)
		data[1] = ItemData.Instance:GetItemConfig(gem_cfg.item_id)
	end

	return data
end

-- 设置可以镶嵌宝石孔位
function ForgeData:SetCanInLayStoneIndex(stone_index)
	self.stone_index = stone_index
end

function ForgeData:GetCanInLayStoneIndex()
	return self.stone_index or 0
end

-- 得到是否可以镶嵌数据
function ForgeData:GetIsCanInLayDataByIndex(index)
	local boo = false
	local data_list = {}
	for k, v in pairs(self:GetGemsInBag(5)) do
		local data = self:GetGemCfg(v.item_id)
		if (index == GameEnum.EQUIP_INDEX_WUQI or index == GameEnum.EQUIP_INDEX_HUSHOU or index == GameEnum.EQUIP_INDEX_XIANGLIAN)
			and (data.stone_type == ForgeData.GemStoneType.GongJi) then
			table.insert(data_list, v)
			boo = true
		elseif (index == GameEnum.EQUIP_INDEX_KUZI or index == GameEnum.EQUIP_INDEX_YAODAI)
			and (data.stone_type == ForgeData.GemStoneType.MaxHp) then
			table.insert(data_list, v)
			boo = true
		elseif (index == GameEnum.EQUIP_INDEX_TOUKUI or index == GameEnum.EQUIP_INDEX_YIFU or index == GameEnum.EQUIP_INDEX_XIEZI)
			and (data.stone_type == ForgeData.GemStoneType.FangYu) then
			table.insert(data_list, v)
			boo = true
		end
	end
	table.sort(data_list, SortTools.KeyUpperSorter("item_id"))
	return boo, data_list
end

-- 获取是否有更好的宝石
function ForgeData:GetHasBestGemStone(stone_id)
	local flag = false
	local cur_stone_cfg = self:GetGemCfg(stone_id)
	if cur_stone_cfg ~= nil then
		for k, v in pairs(self:GetGemsInBag(5)) do
			local tem_stone_cfg = self:GetGemCfg(v.item_id)
			if cur_stone_cfg.stone_type == tem_stone_cfg.stone_type and cur_stone_cfg.level < tem_stone_cfg.level then
				flag = true
			end
		end
	end

	return flag
end

-- 通过装备index获取宝石配置
function ForgeData:GetGemCfgByEquipIndex(equip_index)
	local cfg = {}

	for k, v in pairs(self:GetSysCfg().stone) do
		local index_table = Split(v.can_inlay_equip_types, "|")
		for _, index in pairs(index_table) do
			local temp_index = index % 10
			if temp_index == equip_index then
				cfg = v
			end
		end
	end

	return cfg
end

-- 通过装备index获取属性
function ForgeData:GetGemAttrByEquipIndex(equip_index)
	local total_attr = {}
	local gem_info = ForgeData.Instance:GetGemInfo()
	for k, v in pairs(gem_info[equip_index]) do
		local gem_cfg = self:GetGemCfg(v.stone_id)
		if nil ~= gem_cfg then
			total_attr[gem_cfg.attr_type1] = (total_attr[gem_cfg.attr_type1] or 0) + gem_cfg.attr_val1
		end
	end

	return total_attr
end

-- 获取宝石总属性
function ForgeData:GetGemTotalAttr()
	local total_attr = CommonStruct.Attribute()
	for k, v in pairs(ForgeData.EquipIndex) do
		local attr = self:GetGemAttrByEquipIndex(v)
		local convert_attr = CommonDataManager.GetAttributteByClass(attr)
		total_attr = CommonDataManager.AddAttributeAttr(total_attr, convert_attr)
	end

	return total_attr
end

-- 通过宝石信息获取宝石类型列表
function ForgeData:GetCurGemTypeListByIndex(index)
	local type_list = {}
	local gem_info = self:GetGemInfo()
	for k, v in pairs(gem_info[index]) do
		local gem_cfg = self:GetGemCfg(v.stone_id)
		if gem_cfg then
			table.insert(type_list, gem_cfg.stone_type + 1)
		else
			table.insert(type_list, 0)
		end
	end

	return type_list
end

-- 获取镶嵌宝石总等级
function ForgeData:GetStoneTotalLevel()
	local total_level = 0
	local gem_info = self:GetGemInfo()
	for _, v in pairs(gem_info) do
		for _, info in pairs(v) do
			local cfg = self:GetGemCfg(info.stone_id)
			if cfg then
				total_level = total_level + cfg.level
			end
		end
	end

	return total_level
end

-- 获取宝石套装属性
function ForgeData:GetGemAddCfgAndNextLevel()
	local level = self:GetStoneTotalLevel()
	local next_level = 0
	local cur_attr = CommonStruct.Attribute()
	local next_attr = CommonStruct.Attribute()
	local total_gem_cfg = self:GetSysCfg().stone_ex_add
	for k, v in ipairs(total_gem_cfg) do
		next_level = v.total_level
		if level < v.total_level then
			cur_attr = total_gem_cfg[v.seq - 1] and total_gem_cfg[v.seq - 1] or cur_attr
			break
		else
			cur_attr = v
		end
	end

	for k, v in ipairs(total_gem_cfg) do
		if next_level < v.total_level then
			next_attr = total_gem_cfg[v.seq - 1] and total_gem_cfg[v.seq - 1] or next_attr
			break
		else
			next_attr = v
		end
	end

	return cur_attr, next_level, next_attr
end

function ForgeData:GetGemMaxLevel()
	local stone_ex_add_cfg = self:GetSysCfg().stone_ex_add

	return stone_ex_add_cfg[#stone_ex_add_cfg].total_level or 0
end

-- 获取宝石对应index的item的红点提示
function ForgeData:GetGemRemindByIndex(index)
	local equip_data = EquipData.Instance:GetGridData(index)
	local gem_state = ForgeData.Instance:GetGemStateByEquipData(equip_data)
	local can_inlay = ForgeData.Instance:GetIsCanInLayDataByIndex(index)
	local show_red_point = false

	local gem_info = ForgeData.Instance:GetGemInfo()
	local gem_data = gem_info[index] or {}

	for i = 1, 8 do	
		if gem_data and next(gem_data) then
			local gem_id = gem_data[i - 1].stone_id
			if gem_state[i] == ForgeData.GemState.CanInLay then
				show_red_point = can_inlay
			elseif gem_state[i] == ForgeData.GemState.HasInLay then
				if gem_id ~= 0 then
					local best_gem_flag = ForgeData.Instance:GetHasBestGemStone(gem_id)
					show_red_point = best_gem_flag
				end
			end
			if show_red_point then
				break
			end
		end
	end

	return show_red_point
end
---------------------------------------------------------------------------

------------------------------Cast-----------------------------------------
function ForgeData:GetCastShowAttr(attr_data)
	local attr_list = {"maxhp", "gongji", "fangyu", "mingzhong", "shanbi", "baoji", "jianren"}
	for k, v in pairs(attr_list) do
		if attr_data[v] ~= 0 then
			return v
		end
	end

	return nil
end

-- 获取全身装备最小神铸等级
function ForgeData:GetCastMinLevel()
	local min_level = 999

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil == equip_data then
			return 0
		end

		local shen_level = equip_data.param.shen_level
		min_level = shen_level <= min_level and shen_level or min_level
	end

	return min_level
end

-- 获取神铸加成配置
function ForgeData:GetCastCfgByLevel(level)
	local cfg = {}
	for k, v in pairs(self:GetAllShenOpCfg()) do
		if level == v.need_min_shen_level then
			cfg = v
		end
	end

	return cfg
end

-- 获取符合当前神铸等级的装备个数
function ForgeData:GetCastNumByLevel(level)
	local num = 0
	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data and equip_data.param.shen_level >= level then
			num = num + 1
		end
	end

	return num
end

-- 获取神铸总属性
function ForgeData:GetCastTotalAttr()
	local total_attr = CommonStruct.Attribute()

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			local cast_cfg = self:GetShenOpSingleCfg(equip_data.index, equip_data.param.shen_level)
			local convert_cast_cfg = CommonDataManager.GetAttributteByClass(cast_cfg)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, convert_cast_cfg)
		end
	end

	local min_level = self:GetCastMinLevel()
	local cast_add_cfg = self:GetCastCfgByLevel(min_level)
	total_attr = CommonDataManager.AddAttributeAttr(total_attr, CommonDataManager.GetAttributteByClass(cast_add_cfg))

	return total_attr
end

-- 获取神铸最大等级
function ForgeData:GetCastMaxLevel()
	return #self:GetShenOpCfg()[0] or 0
end

-- 获取全身是否神铸满级
function ForgeData:GetIsCastMaxLevel()
	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			if equip_data.param.shen_level < self:GetCastMaxLevel() then
				return false
			end
		else
			return false
		end
	end

	return true
end

-- 获取神铸对应index的item的红点提示
function ForgeData:GetCastRemindByIndex(index)
	local equip_data = EquipData.Instance:GetGridData(index)
	if equip_data then
		local attr = self:GetShenOpSingleCfg(index, equip_data.param.shen_level + 1)
		if nil == attr then
			return false
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local item_has_num = ItemData.Instance:GetItemNumInBagById(attr["stuff_id_prof_" .. vo.prof])
		local item_need_num = attr.stuff_count

		return item_has_num >= item_need_num
	end
	return false
end
---------------------------------------------------------------------------

------------------------------UpStar---------------------------------------
function ForgeData:GetUpStarShowAttr(attr_data)
	local attr_list = {"maxhp", "gongji", "fangyu"}
	for k, v in pairs(attr_list) do
		if attr_data[v] ~= 0 then
			return v
		end
	end

	return nil
end

-- 获取升星总属性
function ForgeData:GetStarTotalAttr()
	local total_attr = CommonStruct.Attribute()

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			local strength_cfg = self:GetStrengthSingleCfg(equip_data.index, equip_data.param.star_level)
			local convert_strength_cfg = CommonDataManager.GetAttributteByClass(strength_cfg)
			total_attr = CommonDataManager.AddAttributeAttr(total_attr, convert_strength_cfg)
		end
	end

	return total_attr
end

-- 获取升星总等级
function ForgeData:GetStarTotalLevel()
	local total_level = 0

	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			total_level = total_level + equip_data.param.star_level
		end
	end

	return total_level
end

-- 获取升星套装属性
function ForgeData:GetStarAddCfgAndNextLevel()
	local level = self:GetStarTotalLevel()
	local next_level = 0
	local cur_attr = CommonStruct.Attribute()
	local next_attr = CommonStruct.Attribute()
	for k, v in ipairs(self:GetTotalCfg()) do
		next_level = v.total_star
		if level < v.total_star then
			cur_attr = self:GetTotalCfg()[v.seq - 1] and self:GetTotalCfg()[v.seq - 1] or cur_attr
			break
		else
			cur_attr = v
		end
	end

	for k, v in ipairs(self:GetTotalCfg()) do
		if next_level < v.total_star then
			next_attr = self:GetTotalCfg()[v.seq - 1] and self:GetTotalCfg()[v.seq - 1] or next_attr
			break
		else
			next_attr = v
		end
	end

	return cur_attr, next_level, next_attr
end

function ForgeData:GetStarMaxLevel()
	return self:GetTotalCfg()[#self:GetTotalCfg()].total_star or 0
end

-- 获取单个升星最高等级
function ForgeData:GetUpStarMaxLevel()
	return #self:GetUpStarCfg()[0] or 0
end

-- 获取全身是否升星满级
function ForgeData:GetIsUpStarMaxLevel()
	for k, v in pairs(ForgeData.EquipIndex) do
		local equip_data = EquipData.Instance:GetGridData(v)
		if nil ~= equip_data then
			if equip_data.param.star_level < self:GetUpStarMaxLevel() then
				return false
			end
		else
			return false
		end
	end

	return true
end

-- 获取升星对应index的item的红点提示
function ForgeData:GetUpStarRemindByIndex(index)
	local equip_data = EquipData.Instance:GetGridData(index)
	if equip_data then
		local level = equip_data.param.star_level + 1 > self:GetUpStarMaxLevel() and self:GetUpStarMaxLevel() or equip_data.param.star_level + 1
		if equip_data.param.star_level >= self:GetUpStarMaxLevel() then
			return false
		end
		
		local attr = self:GetUpStarSingleCfg(index, level)
		if nil == attr then
			return false
		end
		local item_has_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)

		return item_has_num >= 1
	end
	return false
end
---------------------------------------------------------------------------

-- 设置精灵命魂槽信息
function ForgeData:SetSpiritSlotSoulInfo(protocol)
	self.slot_soul_info.notify_reason = protocol.notify_reason
	self.slot_soul_info.lieming_list = protocol.lieming_list
end

function ForgeData:GetSpiritSlotSoulInfo()
	return self.slot_soul_info
end

function ForgeData:SetLieMingSingleInfo(protocol)
	local info = self:GetSpiritSlotSoulInfo()
	if info and info.lieming_list then
		if info.lieming_list[protocol.equip_index + 1] then
	 		info.lieming_list[protocol.equip_index + 1].slot_activity_flag = protocol.slot_activity_flag
			info.lieming_list[protocol.equip_index + 1].slot_list = protocol.slot_list
		end
	end
end

function ForgeData:SetSpiritSoulBagInfo(protocol)
	self.soul_bag_info.notify_reason = protocol.notify_reason
	self.soul_bag_info.hunshou_exp = protocol.hunshou_exp
	self.soul_bag_info.liehun_color = protocol.liehun_color
	self.soul_bag_info.daily_has_free_chou = protocol.daily_has_free_chou
	self.soul_bag_info.daily_has_change_color = protocol.daily_has_change_color
	self.soul_bag_info.hunli = protocol.hunli
	self.soul_bag_info.liehun_pool = protocol.liehun_pool
	self.soul_bag_info.grid_list = protocol.grid_list
end

function ForgeData:GetSpiritSoulBagInfo()
	return self.soul_bag_info
end

-- 获取精灵命魂配置
function ForgeData:GetSpiritSoulCfg(id)
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou[id]
end

-- 获取抽取精灵命魂消耗魂力配置
function ForgeData:GetSpiritCallSoulCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").chouhun
end

function ForgeData:GetSoulLevelCfg(active_mingge_count)
	if self:GetSoulAuotCfg() then
		return self:GetSoulAuotCfg()[active_mingge_count]
	end
	return nil
end

-- 协议
function ForgeData:SetSpiritInfo(protocol)
	self.spirit_info.jingling_name = protocol.jingling_name
	self.spirit_info.use_jingling_id = protocol.use_jingling_id
	self.spirit_info.use_imageid = protocol.use_imageid
	self.spirit_info.m_active_image_flag = protocol.m_active_image_flag
	self.spirit_info.special_img_active_flag = protocol.special_img_active_flag
	self.spirit_info.phantom_imageid = protocol.phantom_imageid
	self.spirit_info.count = protocol.count

	self.spirit_info.jinglingcard_list = protocol.jinglingcard_list
	self.spirit_info.phantom_level_list = protocol.phantom_level_list
	self.spirit_info.phantom_level_list_new = protocol.phantom_level_list_new
	self.spirit_info.jingling_list = protocol.jingling_list
end

function ForgeData:GetSpiritInfo()
	return self.spirit_info
end

-- 获取精灵命魂经验配置
function ForgeData:GetSpiritSoulExpCfg()
	return ConfigManager.Instance:GetAutoConfig("lieming_auto").hunshou_exp
end

-- 获取命魂属性配置
function ForgeData:GetSoulAttrCfg(id, level, is_sale_exp)
	level = level or 0
	if nil == id or nil == level then return end

	local soul_cfg = self:GetSpiritSoulCfg(id)
	if soul_cfg then
		local attr_cfg = self:GetSpiritSoulExpCfg()
		if not is_sale_exp then
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level == level then
					return v
				end
			end
		else
			local exp = 0
			for k, v in pairs(attr_cfg) do
				if v.hunshou_color == soul_cfg.hunshou_color and v.hunshou_level < level then
					exp = exp + v.exp
				end
			end
			return exp
		end
	end

	return nil
end

-- 判断命魂池里面是否有紫色以上品质的命魂
function ForgeData:IsHadMoreThenPurpleSoul()
	for k, v in pairs(self.soul_bag_info.liehun_pool) do
		if self:GetSoulAttrCfg(v.id) and self:GetSoulAttrCfg(v.id).hunshou_color > 2 then
			return true
		end
	end

	return false
end

function ForgeData:GetSlotSoulInfoByIndex(index)
	local info = self:GetSpiritSlotSoulInfo()
	if info and info.lieming_list then
		return info.lieming_list[index]
	end
	return nil	
end

-- 获取可装备命魂槽索引
function ForgeData:GetSlotSoulEmptyIndex(index)
	local slot_soul_info = self:GetSlotSoulInfoByIndex(index)
	if slot_soul_info and next(slot_soul_info) then
		local bit_list = bit:d2b(slot_soul_info.slot_activity_flag) or {}
		for k, v in pairs(slot_soul_info.slot_list) do
			if bit_list[32 - k] == 1 and v.hunshou_id <= 0 then
				return k
			end
		end
	end
	return nil
end

function ForgeData:GetEquipXianPinAttrValue(data, vo, limit_level)
	local attr = CommonStruct.AttributeNoUnderline()
	if data == nil or limit_level == nil then
		return attr
	end

	if data.param and data.param.xianpin_type_list then
		for k,v in pairs(data.param.xianpin_type_list) do
			if v ~= nil and v > 0 then
				local xianpin_type = self:GetLegendCfgByType(v)
				if xianpin_type ~= nil then
					local attr_key, value = ForgeData.Instance:GetXianPinAttrValue(xianpin_type, vo, limit_level)
					if attr_key ~= nil and attr[attr_key] ~= nil then
						attr[attr_key] = attr[attr_key] + value
					end
				end
			end
		end
	end

	return attr
end

function ForgeData:GetEquipOtherCap(data, equip_index)
	local cap = 0
	if data == nil or next(data) == nil or equip_index == nil then
		return cap
	end

	if data.param and data.param.strengthen_level then
		local str_cfg = self:GetStrengthSingleCfg(equip_index, data.param.grid_strengthen_level)
		if str_cfg ~= nil then
			local attr = CommonDataManager.GetAttributteNoUnderline(str_cfg)
			cap = CommonDataManager.GetCapability(attr) + cap
		end
	end

	if data.param and data.param.shen_level then
		local single_cfg = self:GetShenOpSingleCfg(equip_index, data.param.shen_level)
		if single_cfg then
			local attr = CommonDataManager.GetAttributteNoUnderline(single_cfg)
			cap = CommonDataManager.GetCapability(attr)	+ cap	
		end
	end

	if data.param and data.param.star_level then
		local star_cfg = self:GetUpStarSingleCfg(equip_index, data.param.star_level)
		if star_cfg then
			local attr = CommonDataManager.GetAttributteNoUnderline(star_cfg)
			cap = CommonDataManager.GetCapability(attr)	+ cap	
		end		
	end

	return cap
end

--策划说属性类型已经定死，不会改
function ForgeData:GetXianPinAttrValue(xianpin_type, vo, limit_level)
	local attr_str = nil
	local value = 0

	if xianpin_type == nil or limit_level == nil then
		return attr_str, value
	end

	local role_vo = vo or GameVoManager.Instance:GetMainRoleVo()
	local level = role_vo.level
	if xianpin_type.shuxing_type == 8 or xianpin_type.shuxing_type == 28 then
		attr_str = "maxhp"
	elseif xianpin_type.shuxing_type == 9 or xianpin_type.shuxing_type == 24 then
		attr_str = "gongji"
	elseif xianpin_type.shuxing_type == 10 then
		attr_str = "fangyu"
	elseif xianpin_type.shuxing_type == 11 then
		attr_str = "mingzhong"
	elseif xianpin_type.shuxing_type == 12 or xianpin_type.shuxing_type == 27 then
		attr_str = "shanbi"
	elseif xianpin_type.shuxing_type == 13 or xianpin_type.shuxing_type == 23 then
		attr_str = "baoji"
	elseif xianpin_type.shuxing_type == 14 or xianpin_type.shuxing_type == 25 then
		attr_str = "jianren"
	elseif xianpin_type.shuxing_type == 15 then
		attr_str = "ignore_fangyu"
	elseif xianpin_type.shuxing_type == 16 then
		attr_str = "hurt_increase"
	elseif xianpin_type.shuxing_type == 17 or xianpin_type.shuxing_type == 26 then
		attr_str = "hurt_reduce"
	end

	local read_level = level > limit_level and (limit_level + 29) or level
	if xianpin_type.compare_type == 2 then
		value = xianpin_type.add_value * read_level
	elseif xianpin_type.compare_type == 3 then
		value = xianpin_type.add_value
	elseif xianpin_type.compare_type == 0 then
		if xianpin_type.shuxing_type == 19 or xianpin_type.shuxing_type == 29 then
			attr_str = "per_pvp_hurt_increase"
			value = xianpin_type.add_value
		elseif xianpin_type.shuxing_type == 21 or xianpin_type.shuxing_type == 30 then
			attr_str = "per_pvp_hurt_reduce"
			value = xianpin_type.add_value
		end
	end
	return attr_str, value
end

function ForgeData:CheckSoulItemRed()
	local info = self:GetSpiritSlotSoulInfo().lieming_list
	for k1,v1 in pairs(info) do
		local soul_bag_info = self:GetSpiritSoulBagInfo()
		local slot_soul_info = v1
		if slot_soul_info and next(slot_soul_info) then
			for i=1,7 do
				local id = slot_soul_info.slot_list[i].hunshou_id or -1
				local soul_level_info = ForgeData.Instance:GetSoulLevelCfg(i)
				local attr_cfg = ForgeData.Instance:GetSoulAttrCfg(id, slot_soul_info.slot_list[i].level)
				if attr_cfg ~= nil and soul_bag_info and soul_bag_info.hunshou_exp and slot_soul_info.slot_list[i].exp then
					if soul_bag_info.hunshou_exp > attr_cfg.exp - slot_soul_info.slot_list[i].exp then
						if not self:GetCurEquipIsLock(k1) and self:IsHaveSoulEquip(k1)then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function ForgeData:CheckSingleSoulItemRed(index)
	local info = self:GetSpiritSlotSoulInfo().lieming_list
	local soul_bag_info = self:GetSpiritSoulBagInfo()
	local slot_soul_info = info[index]
	if slot_soul_info and next(slot_soul_info) then
		for i=1,7 do
			local id = slot_soul_info.slot_list[i].hunshou_id or -1
			local soul_level_info = ForgeData.Instance:GetSoulLevelCfg(i)
			local attr_cfg = ForgeData.Instance:GetSoulAttrCfg(id, slot_soul_info.slot_list[i].level)
			if attr_cfg ~= nil and soul_bag_info and soul_bag_info.hunshou_exp and slot_soul_info.slot_list[i].exp then
				if soul_bag_info.hunshou_exp > attr_cfg.exp - slot_soul_info.slot_list[i].exp then
					if not self:GetCurEquipIsLock(index) and self:IsHaveSoulEquip(index)then
						return true
					end
				end
			end
		end
	end
	return false
end
function ForgeData:GetSpiritSoulGetRemind()
	if not OpenFunData.Instance:CheckIsHide("forge_soul") then
		return 0
	end
	local item_red = self:CheckSoulItemRed()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local soul_bag_info = self:GetSpiritSoulBagInfo()
	if vo.hunli >= 50000 or soul_bag_info.daily_has_free_chou <= 0 or item_red then
		return 1
	else
		return 0
	end
end