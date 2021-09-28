-------------------------------------------
--主角服装数据
--------------------------------------------

FashionData = FashionData or BaseClass()

SHIZHUANG_TYPE = {
	WUQI = 0,
	BODY = 1,
	MAX = 2,
}

SHIZHUANG = {
	SHIZHUANG_MAX_LEVEL = 20,
	SHIZHUANG_MAX_INDEX = 63,
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
	local shizhuang_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto")

	self.fashion_cfg_list = shizhuang_cfg.cfg
	self.fashion_level_cfg = ListToMap(shizhuang_cfg.upgrade, "index", "part_type", "level")
	self.jinjie_type = shizhuang_cfg.jinjie_type
	self.canupgrade_cfg_list = shizhuang_cfg.can_upgrade

	RemindManager.Instance:Register(RemindName.PlayerFashion, BindTool.Bind(self.GetPlayerFashionRemind, self))
end

function FashionData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerFashion)

	FashionData.Instance = nil
	self.upgrade_list = {}
end

function FashionData:GetUpgradeLevelCfg(part_type, index, level)
	if nil == self.fashion_level_cfg[index] or
		nil == self.fashion_level_cfg[index][part_type] then
		return nil
	end

	return self.fashion_level_cfg[index][part_type][level]
end

--同步已经激活的服装
function FashionData:SetClothingActFlag(act_flag, act_flag2)
	local ative_flag_list = bit:d2b(act_flag2)
	local ative_flag_list2 = bit:d2b(act_flag)
	for i,v in ipairs(ative_flag_list2) do
		table.insert(ative_flag_list, v)
	end

	self.clothing_act_id_list = {}
	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.BODY then
			self.clothing_act_id_list[v.index] = ative_flag_list[64 - v.index]
		end
	end

	FestivalActivityCtrl.Instance:FlushView("fashion")
end

--服装是否激活
function FashionData:GetClothingActFlag(index)
	return self.clothing_act_id_list[index]
end

function FashionData:GetFashionCfgs()
	return self.fashion_cfg_list
end

--同步已经激活的武器
function FashionData:SetWuqiActFlag(act_flag, act_flag2)
	local ative_flag_list = bit:d2b(act_flag2)
	local ative_flag_list2 = bit:d2b(act_flag)
	for i,v in ipairs(ative_flag_list2) do
		table.insert(ative_flag_list, v)
	end

	self.wuqi_act_id_list = {}
	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.WUQI then
			self.wuqi_act_id_list[v.index] = ative_flag_list[64 - v.index]
		end
	end
	FestivalActivityCtrl.Instance:FlushView("fashion")
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

function FashionData:GetFashionActFlagById(id)
	local cfg = self:GetFashionCfgs()
	local index
	for k,v in pairs(cfg) do
		if v.active_stuff_id == id then
			index = v.index
		end
	end
	if index then
		local flag = self:GetClothingActFlag(index)
		return flag == 1
	end
	return false
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
	for k, v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.BODY and clothing_index == v.index then
			return v
		end
	end
	return nil
end

--根据index获取武器的配置
function FashionData:GetWuqiConfig(wuqi_index)
	for k, v in pairs(self.fashion_cfg_list) do
		if v.part_type == SHIZHUANG_TYPE.WUQI and wuqi_index == v.index then
			return v
		end
	end
	return nil
end

--根据type, index获取时装的配置
function FashionData:GetFashionConfig(part_type, index)
	for k, v in pairs(self.fashion_cfg_list) do
		if v.part_type == part_type and index == v.index then
			return v
		end
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
			local is_dressed = self:CheckIsDressed(data.part_type, data.index)
			local is_active = self:CheckIsActive(data.part_type, data.index)
			if is_dressed then
				table.insert(final_list, data)
			elseif is_active then
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
function FashionData.GetFashionResByItemId(item_id, sex, prof)
	if nil == item_id then return nil end
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg) do
		if v.active_stuff_id == item_id then
			return v["resouce"..prof..sex], v.part_type, v
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

	return self:GetUpgradeLevelCfg(part_type, index, level)
end

-- 默认是武器类型
function FashionData:GetFashionSameTypeList(part_type)
	local list = {}
	local part_type = part_type or 0
	for k,v in pairs(self.fashion_cfg_list) do
		if v.part_type == part_type then
			table.insert(list, v)
		end
	end
	return list
end

function FashionData:GetPlayerFashionRemind()
	return self:IsShowJinjieRedPoint() and 1 or 0
end

function FashionData:IsShowJinjieRedPoint(part_type)
	for k1, v1 in pairs(self.upgrade_list) do
		if part_type == nil or k1 == part_type then

			for k2, v2 in pairs(v1.level_list) do
				local level = v2
				if self:GetFashionActFlag(k1, k2) then
					level = level + 1
				end

				local level_cfg = self:GetUpgradeLevelCfg(k1, k2, level)
				if nil ~= level_cfg and ItemData.Instance:GetItemNumInBagById(level_cfg.need_stuff) >= level_cfg.stuff_count then
					return true
				end
			end
		end
	end

	return false
end

function FashionData:SetFashionLeastTimeInfo(least_time_list)
	self.least_time_list = least_time_list
end

function FashionData:GetFashionTimeInfo()
	return self.least_time_list or {}
end

function FashionData:GetTimeCfg(index, part_type)
	local cfg = self:GetFashionTimeInfo()
	if next(cfg) == nil then
		return
	end
	local time = TimeCtrl.Instance:GetServerTime()
	local least_time = cfg[part_type].time_list[index] - time
	least_time = TimeUtil.FormatSecond(least_time,8)
	return least_time
end