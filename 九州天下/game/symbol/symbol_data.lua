SymbolData = SymbolData or BaseClass()
SymbolData.INFO_TYPE =
	{
	SINGLE_ELEMENT = 0,			-- 单个信息
	ALL_ELEMENT = 1,			-- 全部信息
	WUXING_CHANGE = 2,			-- 五行转换信息
}
SymbolData.XL_ATTR = {
	[1] = "max_hp",
	[2] = "gong_ji",
	[3] = "fang_yu",
	[4] = "ming_zhong",
	[5] = "shan_bi",
	[6] = "bao_ji",
	[7] = "jian_ren",
	[8] = "hurt_increase",
	[9] = "hurt_reduce",
	}
local RESTRICTION =
{
	[0] = 3,
	[1] = 0,
	[2] = 4,
	[3] = 2,
	[4] = 1,
}
SymbolData.ELEMENT_MODEL =
{
	[0] = 10039001,
	[1] = 10037001,
	[2] = 10040001,
	[3] = 10038001,
	[4] = 10041001,
}

SymbolData.XiLianStuffColor = {
	FREE = 0,					-- 免费
	BLUE = 1,					-- 蓝
	PURPLE = 2,					-- 紫
	ORANGE = 3,					-- 橙
	RED = 4,					-- 红
}

local ITEM_TYPE = {
		FOOD = 1,
		YH_STUFF = 2,
		YS_STUFF = 3,
		EQUIP = 4,
}
SymbolData.LOCK = {}
function SymbolData:__init()
	if SymbolData.Instance then
		print_error("[SymbolData] Attempt to create singleton twice!")
		return
	end
	SymbolData.Instance = self

	local chou_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").chou_cfg
	self.element_heart_openc_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_heart_openc_fg
	self.element_heart_openc_cfg2 = ListToMap(self.element_heart_openc_cfg, "id")
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	self.element_heart_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_heart_level, "level")
	self.element_heart_grade_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_heart_grade, "grade")
	self.xilian_slot_opene_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").xilian_slot_open, "element_id")
	self.xilian_type_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").xilian_type, "element_id")
	self.order_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").order, "type")
	self.lock_consume_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").lock_consume, "lock_num")
	self.element_shuxing_addition_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_shuxing_addition, "element_shuxing_type")
	self.xilian_consume_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").xilian_consume
	self.item_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").item_cfg, "item_id")
	self.item_type_cfg = ListToMapList(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").item_cfg, "type")
	self.upgrade_limit_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").upgrade_limit,"element_id")

	self.chou_item_cfg = {}
	self.item_res_list = {}
	local item_res_list = {}
	for k,v in pairs(chou_cfg) do
		self.chou_item_cfg[v.reward_item.item_id] = true
		local item_cfg = ItemData.Instance:GetItemConfig(v.reward_item.item_id)
		if item_cfg and item_cfg.icon_id then
			item_res_list[item_cfg.icon_id] = item_cfg.icon_id
		end
	end
	for k,v in pairs(item_res_list) do
		table.insert(self.item_res_list, v)
	end

	self.element_texture_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_texture_level,"wuxing_type","grade")
	self.inlay_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").inlay,"e_index")

	self.food_cfg = self.item_type_cfg[ITEM_TYPE.FOOD]
	self.food_list ={}

	self.ys_stuff_cfg = ListToMapList(self.item_type_cfg[ITEM_TYPE.YS_STUFF],"param1")  --装备的物品信息

	self.yh_stuff_cfg = self.item_type_cfg[ITEM_TYPE.YH_STUFF]

	self.element_equip_shop_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_equip_shop, "seq")
	self.element_equip_level_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_equip_level, "real_level")
	self.element_equip_shuxing_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").element_equip_shuxing, "item_id")

	self.element_heart_info = {
		pasture_score = 0,
		free_chou_times = 0,
		element_list = {},
	}

	self.element_shop_info = {
		today_shop_flush_times = 0,
		next_refresh_timestamp = 0,
		shop_item_list = {},
	}

	self.element_texture_info = {
		charm_list = {},
	}

	self.charm_ghost_single_charm_info = {
		index = 0,
		charm = {},
	}

	self.element_heart_chou_reward_list_info = {
		reward_list = {},
	}

	self.element_product_list_info = {
		info_type = 0,
		product_list = {},
	}
	self.xilian_list_info = {}

	self.cache_element_item_list = nil
	self.recycle_data_list = {}
	self.all_yuanzhuang_item_list = nil

	RemindManager.Instance:Register(RemindName.SymbolYuanSu, BindTool.Bind(self.GetSymbolYuanSuRemind, self))
	RemindManager.Instance:Register(RemindName.SymbolYuanHuo, BindTool.Bind(self.GetSymbolYuanHuoRemind, self))
	RemindManager.Instance:Register(RemindName.SymbolYuanHun, BindTool.Bind(self.GetSymbolYuanHunRemind, self))
	RemindManager.Instance:Register(RemindName.SymbolYuanYong, BindTool.Bind(self.GetSymbolYuanYongRemind, self))
	RemindManager.Instance:Register(RemindName.SymbolYuanShi, BindTool.Bind(self.GetSymbolYuanShiRemind, self))
end

function SymbolData:__delete()
	RemindManager.Instance:UnRegister(RemindName.SymbolYuanSu)
	RemindManager.Instance:UnRegister(RemindName.SymbolYuanHuo)
	RemindManager.Instance:UnRegister(RemindName.SymbolYuanHun)
	RemindManager.Instance:UnRegister(RemindName.SymbolYuanYong)
	RemindManager.Instance:UnRegister(RemindName.SymbolYuanShi)
	SymbolData.Instance = nil
end

function SymbolData:ClearCacheElementItemList()
	self.cache_element_item_list = nil
	self.all_yuanzhuang_item_list = nil
end

--从背包获取元素物品列表
function SymbolData:GetAllElementItemList()
	if self.cache_element_item_list then
		return self.cache_element_item_list
	end
	self.cache_element_item_list = {}
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_list) do
		if self.chou_item_cfg[v.item_id] then
			table.insert(self.cache_element_item_list, v)
		end
	end
	return self.cache_element_item_list
end

--元素信息
function SymbolData:SetElementHeartInfo(info)
	self.element_heart_info.free_chou_times = info.free_chou_times
	self.element_heart_info.pasture_score = info.pasture_score
	if info.info_type == SymbolData.INFO_TYPE.ALL_ELEMENT then
		self.element_heart_info.element_list = info.element_list
	else
		for k,v in pairs(info.element_list) do
			self.element_heart_info.element_list[v.id] = v
		end
	end
end

function SymbolData:GetPastureScore()
	return self.element_heart_info.pasture_score
end

function SymbolData:GetMishiFreeTimes()
	return self.element_heart_info.free_chou_times
end

function SymbolData:GetElementList()
	return self.element_heart_info.element_list
end

function SymbolData:GetUpgradeLimitById(id)
	return self.upgrade_limit_cfg[id]
end

--获取元素抽奖相关物品配置
function SymbolData:GetElementItemCfg(item_id)
	return self.chou_item_cfg[item_id]
end

function SymbolData:GetElementInfo(id)
	return self.element_heart_info.element_list[id]
end

--获取元素等级配置
function SymbolData:GetElementHeartLevelCfg(grade)
	return self.element_heart_level_cfg[grade]
end

--获取元素等级
function SymbolData:GetElementHeartLevel(wuxingshuxing)
	local level = 0
	for i,v in ipairs(self.element_heart_level_cfg) do
		if wuxingshuxing >= v.wuxing_min and wuxingshuxing <= v.wuxing_max then
			return i
		elseif wuxingshuxing > v.wuxing_max then
			level = i
		end
	 end
	return level
end

--五行之灵最大等级
function SymbolData:GetElementMaxLevel()
	return #self.element_heart_level_cfg
end

--元素开启激活条件配置
function SymbolData:GetElementHeartOpencCfg()
	return self.element_heart_openc_cfg
end

--元素激活条件说明
function SymbolData:GetElementLimitString(element_id)
	if self.element_heart_openc_cfg2[element_id] then
		local cfg = self.element_heart_openc_cfg2[element_id]
		local str = Language.Symbol.FreeActivation[cfg.condtion_type]
		if str and cfg.condtion > 0 then
			return string.format(str, cfg.condtion)
		end
	end
	return Language.Symbol.FreeActivation["free"]
end

function SymbolData:GetModelResIdByElementId(element_id)
	if self.element_heart_openc_cfg2[element_id] then
		return self.element_heart_openc_cfg2[element_id].res_id
	end

	return 0
end

--元素物品图标数组
function SymbolData:GetItemResList()
	return self.item_res_list
end

--获取元素食物
function SymbolData:UpdateFoodList()
	self.food_list = {}
	for k,v in pairs(RESTRICTION) do
		self.food_list[k] = {}
		for k1,v1 in ipairs(self.order_cfg[k] or {}) do
			local num = ItemData.Instance:GetItemNumInBagById(v1.item_id)
			table.insert(self.food_list[k], {item_id = v1.item_id, num = num})
		end
	end
end

--获取元素食物
function SymbolData:GetElementFoodsByType(wx_type)
	return self.food_list[wx_type] or {}
end

--获取元素食物是否存在
function SymbolData:GetHasTuijianElementFoods(wx_type)
	local food_list = self.food_list[wx_type] or {}
	if food_list[1] and food_list[1].num > 0 then
		return true
	end
	return false
end

--获取装备信息
function SymbolData:GetElementTextureInfo(index)
	return self.element_texture_info.charm_list[index]
end

--获取装备符咒的全部信息
function SymbolData:GetElementTextureInfoList()
	return self.element_texture_info.charm_list
end

--根据五行类型和等级获取数据
function SymbolData:GetElementTextureLevel(wuxing_type, grade)
	if self.element_texture_level_cfg[wuxing_type] then
		return self.element_texture_level_cfg[wuxing_type][grade]
	end
	return nil
end

--获取装备符咒最大等级
function SymbolData:GetElementTextureMaxLevel()
	return #self.element_texture_level_cfg[0]
end

--获取装备对应的五行
function SymbolData:GetEquipByWuxing(index)
	if self.inlay_cfg[index] then
		return self.inlay_cfg[index].wuxing_type or 0
	end
	return 0
end

--获取装备index对应的装备数据
function SymbolData:GetEquipInfoByEquipIndex(index)
	return self.inlay_cfg[index]
end

--获取装备消耗的物品信息
function SymbolData:GetYSStuffCfg()
	return self.item_type_cfg[ITEM_TYPE.YS_STUFF]
end

--获取进阶需要消耗的物品
function SymbolData:GetYHStuffCfg()
	return self.yh_stuff_cfg[1]
end

--根据进阶数获取数据
function SymbolData:GetElementHeartCfgByGrade(grade)
	return self.element_heart_grade_cfg[grade]
end

function SymbolData:GetElementMaxGrade()
	return #self.element_heart_grade_cfg
end

--商店信息
function SymbolData:SetElementShopInfo(info)
	self.element_shop_info.today_shop_flush_times = info.today_shop_flush_times
	self.element_shop_info.next_refresh_timestamp = info.next_refresh_timestamp
	self.element_shop_info.shop_item_list = info.shop_item_list
end

--元素之纹列表信息
function SymbolData:SetElementTextureInfo(info)
	self.element_texture_info.charm_list = info.charm_list
end

--单个元素之纹信息
function SymbolData:SetCharmGhostSingleCharmInfo(info)
	self.charm_ghost_single_charm_info.index = info.index
	self.charm_ghost_single_charm_info.charm = info.charm
	self.element_texture_info.charm_list[info.index] = info.charm
end

function SymbolData:GetCharmGhostSingleCharmInfo()
	return self.charm_ghost_single_charm_info
end

--抽奖奖品
function SymbolData:SetElementHeartChouRewardListInfo(info)
	self.element_heart_info.free_chou_times = info.free_chou_times
	self.element_heart_chou_reward_list_info.reward_list = info.reward_list
end

--抽奖奖品
function SymbolData:GetElementHeartRewardList()
	return self.element_heart_chou_reward_list_info.reward_list
end

--产出列表
function SymbolData:SetElementProductListInfo(info)
	self.element_product_list_info.info_type = info.info_type
	self.element_product_list_info.product_list = info.product_list
end

--获取产出列表
function SymbolData:GetElementProductListInfo()
	local list = {}
	for k,v in pairs(self.element_product_list_info.product_list) do
		table.insert(list, {item_id = v,num = 1,is_bind = 0})
	end
	return list
end

function SymbolData:GetElementShopInfo()
	return self.element_shop_info
end

--全部洗练信息
function SymbolData:SetElementXiLianAllInfo(info)
	self.xilian_list_info = info.xilian_list_info
end

--全部洗练信息
function SymbolData:GetElementXiLianTypeCount(element_id)
	if self.xilian_list_info[element_id] == nil then return {} end
	local count_t = {}
	for k,v in pairs(self.xilian_list_info[element_id].slot_list) do
		if v.open_slot == 1 then
			if count_t[v.element_attr_type] then
				count_t[v.element_attr_type] = count_t[v.element_attr_type] + 1
			else
				count_t[v.element_attr_type] = 1
			end
		end
	end
	return count_t
end

--单个洗练信息
function SymbolData:SetElementXiLianSingleInfo(info)
	self.xilian_list_info[info.element_id] = info.element_xl_info
end

--获取单个洗练信息
function SymbolData:GetElementXiLianSingleInfo(element_id)
	return self.xilian_list_info[element_id]
end

--获取单个洗练开启等级
function SymbolData:GetElementXiLianOpenLevel(element_id, slot)
	if self.xilian_slot_opene_cfg[element_id] then
		for k,v in pairs(self.xilian_slot_opene_cfg[element_id]) do
			if v.slot_id == slot then
				return v.feed_level
			end
		end
	end
	return 0
end

--默认洗练材料配置
function SymbolData:GetXiLianDefaultInfo()
	local stuff_cfg = nil
	for i,v in ipairs(self.xilian_consume_cfg) do
		if v.comsume_color ~= SymbolData.XiLianStuffColor.FREE then
			local stuff_num = ItemData.Instance:GetItemNumInBagById(v.consume_item.item_id)
			if stuff_num > 0 then
				stuff_cfg = v
			end
		end
	end
	if stuff_cfg == nil then
		stuff_cfg = self.xilian_consume_cfg[SymbolData.XiLianStuffColor.BLUE + 1]
	end
	return stuff_cfg
end

--获取洗练配置列表
function SymbolData:GetSymbolXiLianStuffList()
	local consume_list = {}
	for i,v in ipairs(self.xilian_consume_cfg) do
		if v.comsume_color ~= SymbolData.XiLianStuffColor.FREE then
			table.insert(consume_list, v)
		end
	end
	return consume_list
end

--获取稀有洗练数
function SymbolData:GetXiLianHasRareById(element_id)
	local has_rare = false
	local num = 0
	if not self.xilian_list_info[element_id] then
		return has_rare
	end
	for i,v in pairs(self.xilian_list_info[element_id].slot_list) do
		local star = self:GetElementXiLianAttrStar(element_id, i - 1, v.xilian_val)
		if star >= 7 and not SymbolData.LOCK[i - 1] then
			has_rare = true
			num = num + 1
		end
	end
	return has_rare, num
end

--获取洗练锁定配置
function SymbolData:GetElementXiLianLockCfg(lock_num)
	return self.lock_consume_cfg[lock_num]
end

--获取单个洗练星级
function SymbolData:GetElementXiLianAttrStar(element_id, slot, value)
	local star = 1
	if self.xilian_type_cfg[element_id] then
		for k,v in pairs(self.xilian_type_cfg[element_id]) do
			if v.xilian_solt == slot then
				for i= 0, 9 do
					if value >= v["star_min_" .. i] and value <= v["star_max_" .. i] then
						return i + 1
					elseif value > v["star_max_" .. i] then
						star = i + 1
					end
				end
			end
		end
	end
	return star
end

--获取单个洗练属性类型
function SymbolData:GetElementXiLianAttr(element_id, slot)
	local star = 1
	if self.xilian_type_cfg[element_id] then
		for k,v in pairs(self.xilian_type_cfg[element_id]) do
			if v.xilian_solt == slot then
				return SymbolData.XL_ATTR[v.shuxing_type] or SymbolData.XL_ATTR[1]
			end
		end
	end
	return SymbolData.XL_ATTR[1]
end

--获取单个洗练属性类型
function SymbolData:GetElementXiLianAttrAddition(wuxing_type)
	return self.element_shuxing_addition_cfg[wuxing_type] or {}
end

--获取单个洗练属性类型
function SymbolData:GetElementXiLianAttrAdditionValue(element_id)
	local add = 0
	local info = self.element_heart_info.element_list[element_id]
	if info then
		local add_cfg = self.element_shuxing_addition_cfg[info.wuxing_type] or {}
		local count_t = self:GetElementXiLianTypeCount(element_id)
		for k,v in pairs(add_cfg) do
			local has_count = count_t[v.element_shuxing_type] or 0
			if has_count >= v.need_element_shuxing_count and add < v.add_percent then
				add = v.add_percent
			end
		end
	end
	return add
end

--获取单个洗练属性类型
function SymbolData:GetElementXiLianCanChangeLock(element_id, slot)
	if SymbolData.LOCK[slot] or not self.xilian_list_info[element_id] then
		return true
	end
	local unlock_count = 0
	for i,v in pairs(self.xilian_list_info[element_id].slot_list) do
		if v.open_slot == 1 and not SymbolData.LOCK[i - 1] then
			unlock_count = unlock_count + 1
		end
	end
	return unlock_count > 1
end

function SymbolData:GetElementShopCfg(seq)
	return self.element_equip_shop_cfg[seq]
end

function SymbolData:GetSymbolOtherConfig()
	return self.other_cfg
end

function SymbolData:GetElementEquipLevelCfg(level)
	return self.element_equip_level_cfg[level]
end

function SymbolData:GetElementEquipMaxLevel()
	return self.element_equip_level_cfg[#self.element_equip_level_cfg]
end

function SymbolData:GetElementEquipDataList(id)
	local info = self:GetElementInfo(id)
	if info == nil then
		return nil
	end

	local equip_info = info.equip_param

	local cfg = self:GetElementEquipLevelCfg(equip_info.real_level)
	if cfg == nil then
		return nil
	end

	local equip_data_list = {}
	local flag_t = bit:d2b(equip_info.slot_flag)

	for i=1, GameEnum.ELEMENT_MAX_EQUIP_SLOT do
		local vo = {}
		vo.item_id = cfg["grid_" .. i - 1 .. "_id"] or 0
		vo.active_flag = flag_t[33 - i]
		vo.index = i - 1
		vo.element_id = id
		equip_data_list[i] = vo
	end

	local data = {}
	data.equip_data_list = equip_data_list
	data.upgrade_progress = equip_info.upgrade_progress
	data.real_level = equip_info.real_level

	return data
end

--元晶装备总属性（因为都是配置里的，所以只算一遍就好了）
local cache_yuanzhuang_equip_all_attr = {}
function SymbolData:GetYuanzhuangEquipLevelAttr(level)
	if cache_yuanzhuang_equip_all_attr[level] then return cache_yuanzhuang_equip_all_attr[level] end
	local attribute = CommonStruct.Attribute()
	for i = level, 0, -1 do
		if self.element_equip_level_cfg[i] then
			if cache_yuanzhuang_equip_all_attr[i] then
				attribute = CommonDataManager.AddAttributeAttr(attribute, cache_yuanzhuang_equip_all_attr[i])
				cache_yuanzhuang_equip_all_attr[level] = attribute
				return attribute
			else
				for j = 0, 5 do
					local item_id = self.element_equip_level_cfg[i]["grid_" .. j .. "_id"] or 0
					if self.element_equip_shuxing_cfg[item_id] then
						local equip_attr = CommonDataManager.GetAttributteByClass(self.element_equip_shuxing_cfg[item_id])
						attribute = CommonDataManager.AddAttributeAttr(attribute, equip_attr)
					end
				end
			end
		end
	end
	cache_yuanzhuang_equip_all_attr[level] = attribute
	return attribute
end

function SymbolData:GetEquipmentAttrCfg(item_id)
	return self.element_equip_shuxing_cfg[item_id]
end

--元装装备回收值
function SymbolData:GetEquipmentDecomposeReward(item_id)
	if self.element_equip_shuxing_cfg[item_id] then
		return self.element_equip_shuxing_cfg[item_id].reward_item.num
	end
	return 0
end

function SymbolData:GetAllEquipmentItemList()
	if self.all_yuanzhuang_item_list then
		return self.all_yuanzhuang_item_list
	end
	local item_list = {}
	local bag_list = ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(bag_list) do
		if self:IsEquipmentItem(v.item_id) then
			table.insert(item_list, v)
		end
	end
	self.all_yuanzhuang_item_list = item_list
	return self.all_yuanzhuang_item_list
end

function SymbolData:CanDecomposeItem(item_id)
	for key, value in pairs(self.element_equip_shop_cfg) do
		if value.canfenjie == 1 and item_id == value.reward_item.item_id then
			return true
		end
	end
	return false
end

function SymbolData:IsEquipmentItem(item_id)
	for key, value in pairs(self.element_equip_shop_cfg) do
		if item_id == value.reward_item.item_id then
			return true
		end
	end
	return false
end


--元素可激活
function SymbolData:GetSymbolYuanSuCanActive(element_id)
	local info = self.element_heart_info.element_list[element_id]
	if info == nil or info.element_level > 0 then
		return false
	elseif element_id == 0 then
		return true
	end
	local open_cfg = self.element_heart_openc_cfg2[element_id]
	if open_cfg and open_cfg.condtion_type == 0 then
		local last_info = self.element_heart_info.element_list[element_id - 1]
		if last_info and last_info.element_level >= open_cfg.condtion then
			return true
		end
	end
	return false
end

--元素提醒
function SymbolData:GetSymbolYuanSuRemind()
	local max_level =self:GetElementMaxLevel() 
	for k,v in pairs(self.element_heart_info.element_list) do
		if v.element_level > 0 and v.element_level < max_level then     
			local wx_type = v.wuxing_type
			if self:GetHasTuijianElementFoods(wx_type) then
				return 1
			end
			if v.next_product_timestamp <= TimeCtrl.Instance:GetServerTime() then
				return 1
			end
		elseif self:GetSymbolYuanSuCanActive(k) then
			return 1
		end
	end
	return 0
end

--元获提醒
function SymbolData:GetSymbolYuanHuoRemind()
	-- local data = EquipmentShenData.Instance:GetPartList()
	local wuxing_type_list = {}

	for i = 0, 9 do
		for k1,v1 in pairs(self.element_heart_info.element_list) do
			local texture_info = self:GetElementTextureInfo(i)
			if texture_info and texture_info.wuxing_type == v1.wuxing_type
				and v1.grade > 0 and texture_info.grade < self:GetElementTextureMaxLevel() then
				table.insert(wuxing_type_list, v1.wuxing_type)
				break
			end
		end
	end

	if #wuxing_type_list > 0 then
		for k, v in ipairs(self.item_type_cfg[ITEM_TYPE.YS_STUFF]) do
			if ItemData.Instance:GetItemNumInBagById(v.item_id) > 0 then
				return 1
			end
		end
	end

	return 0
end

--元魂提醒
function SymbolData:GetSymbolYuanHunRemind()
	if nil == self.element_heart_info.element_list[0] or self.element_heart_info.element_list[0].element_level <= 0 then
		return 0
	end
	local has_item = false
	for i,v in ipairs(self.xilian_consume_cfg) do
		if 0 ~= v.consume_item.item_id then
			local item_num = ItemData.Instance:GetItemNumInBagById(v.consume_item.item_id)
			if item_num > 0 then
				has_item = true
				break
			end
		end
	end

	local num = has_item and 1 or 0
	return num
end

--元装提醒
function SymbolData:GetOneSymbolYuanZhuangRemind(element_id)
	local info = self:GetElementEquipDataList(element_id)
	if nil == info then return false end

	local can_up = true
	for k,v in pairs(info.equip_data_list) do
		if 0 == v.active_flag and ItemData.Instance:GetItemConfig(v.item_id) then
			local num = ItemData.Instance:GetItemNumInBagById(v.item_id)
			if num > 0 then
				return true
			end
			can_up = false
		end
	end
	if can_up and info.real_level < #self.element_equip_level_cfg then
		local level_cfg = self:GetElementEquipLevelCfg(info.real_level)
		if level_cfg then
			local need = math.max(level_cfg.upgrade_progress - info.upgrade_progress, 0)
			return ItemData.Instance:GetItemNumInBagById(level_cfg.comsume_item_id) >= need
		end
	end
	return false
end

--元装提醒
function SymbolData:GetSymbolYuanZhuangRemind()
	for k,v in pairs(self.element_heart_info.element_list) do
		if v.element_level > 0 and self:GetOneSymbolYuanZhuangRemind(k) then
			return 1
		end
	end
	return 0
end

--元涌提醒
function SymbolData:GetSymbolYuanYongRemind()
	if self.other_cfg.one_chou_free_chou_times - self.element_heart_info.free_chou_times> 0 then
		return 1
	end
	return 0
end

--元释提醒
function SymbolData:GetSymbolYuanShiRemind()
	local item_id = self.yh_stuff_cfg[1].item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	for k,v in pairs(self.element_heart_info.element_list) do
		if v.grade <=0 then break end

		local cfg = self:GetElementHeartCfgByGrade(v.grade)
		if cfg then
			local need_item_num = cfg.need_item_num
			if num >= need_item_num then
				return 1
			end
		end
	end
	return 0
end

--------recyle----------------
function SymbolData:EmptyRecycleList()
	self.recycle_data_list = {}
end

function SymbolData:SetRecycleItemDataList(is_add, data_list, color)
	if is_add then
		for k,v in pairs(data_list) do
			table.insert(self.recycle_data_list, v)
		end
	else
		for i = #self.recycle_data_list ,1 ,-1 do
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(self.recycle_data_list[i].item_id)
			if color == 2 then
				if item_cfg.color <= 2 then
					table.remove( self.recycle_data_list, i )
				end
			else
				if item_cfg.color == color then
					table.remove( self.recycle_data_list, i )
				end
			end
		end
	end
end

function SymbolData:GetRecycleItemDataList()
	return self.recycle_data_list
end

--获取可回收的装备列表
function SymbolData:GetRecycleDataList()
	local data_list = {}
	local equip_type_list = SymbolData.Instance:GetAllEquipmentItemList()

	for k , v in pairs(equip_type_list) do
		if self:CanDecomposeItem(v.item_id) then
			table.insert(data_list, v)
		end
	end
	return data_list
end

--获取蓝装以下的装备列表
function SymbolData:GetBlueAndUnderDataList()
	local blue_data_list = {}
	local data_list = self:GetRecycleDataList()
	for k , v in pairs(data_list) do
		if v ~= nil then
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
			if nil ~= item_cfg and item_cfg.color <= 2 then
				table.insert(blue_data_list,v)
			end
		end
	end
	return blue_data_list
end

--根据颜色获取装备列表
function SymbolData:GetEquipDataListByColor(color)
	local purple_data_list = {}
	local num = 1
	local data_list = self:GetRecycleDataList()
	for k , v in pairs(data_list) do
		if v ~= nil then
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
			if nil ~= item_cfg and item_cfg.color == color then
				table.insert(purple_data_list,v)
			end
		end
	end
	return purple_data_list
end

function SymbolData:AddItemToRecycleList(data)
	table.insert(self.recycle_data_list, data)
end

function SymbolData:RemoveRecycData(data)
	if not data then return end
	for k, v in pairs(self.recycle_data_list) do
		if data.index == v.index then
			table.remove(self.recycle_data_list, k)
			break
		end
	end
end
