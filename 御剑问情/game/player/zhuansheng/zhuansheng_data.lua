--------------------------------------------------------
--转生数据管理
--------------------------------------------------------
ZhuanShengData = ZhuanShengData or BaseClass()

function ZhuanShengData:__init()
	if ZhuanShengData.Instance then
		print_error("[ZhuanShengData] Attemp to create a singleton twice !")
	end
	ZhuanShengData.Instance = self

	self.xiuwei_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto")
	self.is_hook = true

	self.select_recovery_list = {}				-- 已选择回收的装备列表
	self.zhuansheng_info = {}
	self.zhuansheng_other_info = {}
	for i= 0, 7 do
		self.select_recovery_list[i] = {}
	end
	self.item_id_ilst = {[0] = 900, 901, 902, 903, 904, 905, 906, 907}
end

function ZhuanShengData:__delete()
	ZhuanShengData.Instance = nil
end

-- 转生装备信息
function ZhuanShengData:SetZhuanShengAllInfo(protocol)
	self.zhuansheng_info.zhuansheng_equip_list = protocol.zhuansheng_equip_list
	self.zhuansheng_info.last_time_free_chou_timestamp = protocol.last_time_free_chou_timestamp
	self.zhuansheng_info.personal_xiuwei = protocol.personal_xiuwei
	self.zhuansheng_info.zhuansheng_level = protocol.zhuansheng_level
	self.zhuansheng_info.day_change_times = protocol.day_change_times

	self.cur_level = self.zhuansheng_info.zhuansheng_level
end

-- 转生装备其他信息
function ZhuanShengData:SetZhuanShengOtherInfo(protocol)
	self.zhuansheng_info.last_time_free_chou_timestamp = protocol.last_time_free_chou_timestamp
	self.zhuansheng_info.personal_xiuwei = protocol.personal_xiuwei
	self.zhuansheng_info.zhuansheng_level = protocol.zhuansheng_level
	self.zhuansheng_info.day_change_times = protocol.day_change_times
end

function ZhuanShengData:GetZhuanShengInfo()
	return self.zhuansheng_info
end

function ZhuanShengData:GetZhuanShengOtherInfo()
	return self.zhuansheng_other_info
end

function ZhuanShengData:GetDressEquipList()
	return self.zhuansheng_info.zhuansheng_equip_list or {}
end

function ZhuanShengData:GetEquipShowList()
	return self.xiuwei_cfg.show
end

-- 获取某已转生配置
function ZhuanShengData:GetZsCfgByZsLevel(zhuansheng_level)
	local zhuansheng_cfg = self.xiuwei_cfg.zhuansheng_attr_cfg
	for k,v in pairs(zhuansheng_cfg) do
		if zhuansheng_level == v.level then
			return v
		end
	end
	return nil
end

-- 获取回收装备
function ZhuanShengData:GetRecoveryEquipList()
	return self.select_recovery_list
end
-- 清空回收里的装备数据
function ZhuanShengData:ResetRecoveryEquipList()
	self.select_recovery_list = {}
	for i= 0, 7 do
		self.select_recovery_list[i] = {}
	end
end

function ZhuanShengData:GetIsHook()
	return self.is_hook
end

function ZhuanShengData:SetIsHook(is_hook)
	self.is_hook = is_hook
end

-- 添加选择回收的装备
function ZhuanShengData:AddSelectRecoveryEquipList(index)
	local data_list = self:GetBagZhuanShenEquipList()
	for k, v in pairs(data_list) do
		local is_add = true
		for k2, v2 in pairs(self.select_recovery_list) do
			if v2.index == v.index and v2.item_id == v.item_id then
				is_add = false
			end
		end
		if is_add then
			self.select_recovery_list[index] = v
			break
		end
	end
end

-- 自动添加回收的装备
function ZhuanShengData:AutoAddSelectRecoveryEquipList()
	self.select_recovery_list = {}
	-- if self.is_hook then
	-- 	data_list = self:GetBagZhuanShenAutoREquipList()
	-- else
	-- 	data_list = self:GetBagZhuanShenEquipList()
	-- end
	local data_list = self:GetBagCanRecoverEquilList(self.is_hook)
	local i = 0
	for k, v in pairs(data_list) do
		if i <= 7 then
			self.select_recovery_list[i] = v
			i = i + 1
		end
	end
	-- 如果背包里不足8件装备的话就填满它。
	if i < 7 then
		for j = i, 7 do
			self.select_recovery_list[j] = {}
		end
	end
end

-- 计算当前选择装备回收的价格(这里是修为值)
function ZhuanShengData:GetSelectEquipRecoveryPrice()
	local num = 0
	for k,v in pairs(self.select_recovery_list) do
		if v and v.item_id then
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				num = num + item_cfg.recyclget
			end
		end
	end
	return num
end

-- 获取背包里所有转生装备
function ZhuanShengData:GetBagZhuanShenEquipList()
	local data_list = {}
	local i = 0
	local bag_item_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and EquipData.IsZhuanshnegEquipType(item_cfg.sub_type) then
			data_list[i] = v
			i = i + 1
		end
	end
	return data_list
end

-- 获取筛选后背包里自动回收的的装备
function ZhuanShengData:GetBagZhuanShenAutoREquipList()
	local auto_equip_list = {}
	for i=0,#self.zhuansheng_info.zhuansheng_equip_list do
		local cur_equip_list = {}
		cur_equip_list = self:GetLevelEquip(self.item_id_ilst[i])
		if cur_equip_list and cur_equip_list[1] then
			if self.zhuansheng_info.zhuansheng_equip_list[i] and self.zhuansheng_info.zhuansheng_equip_list[i].item_id > 0 and cur_equip_list[1].cap > self:GetEquipCap(self.zhuansheng_info.zhuansheng_equip_list[i]) then
				table.remove(cur_equip_list, 1)
			end
			for k,v in pairs(cur_equip_list) do
				table.insert(auto_equip_list,v)
			end
		end
	end
	return auto_equip_list
end

-- 获取背包可以回收的转生装备
function ZhuanShengData:GetBagCanRecoverEquilList(is_hook)
	if not is_hook then
		return self:GetBagZhuanShenEquipList()
	end
	local list = {}
	for k, v in pairs(self.zhuansheng_info.zhuansheng_equip_list or {}) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		local fight_power = self:GetZhuangShengEquipFightPower(v)
		if item_cfg then
			for i, j in pairs(self:GetBagZhuanShenEquipList()) do
				local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(j.item_id)
				if item_cfg.sub_type == item_cfg1.sub_type then
					if fight_power >= self:GetZhuangShengEquipFightPower(j) then
						table.insert(list, j)
					end
				end
			end
		end
	end
	return list
end

-- 获取当前比身上好的装备
function ZhuanShengData:GetBagZhuanshengEquip()
	local equip_list = {}
	for i=0,#self.zhuansheng_info.zhuansheng_equip_list do
		local cur_equip_list = {}
		cur_equip_list = self:GetLevelEquip(self.item_id_ilst[i])
		if cur_equip_list and cur_equip_list[1] then
			if self.zhuansheng_info.zhuansheng_equip_list[i] and self.zhuansheng_info.zhuansheng_equip_list[i].item_id > 0 and cur_equip_list[1].cap > self:GetEquipCap(self.zhuansheng_info.zhuansheng_equip_list[i]) then
				table.insert(equip_list, cur_equip_list[1])
			end
		end
	end
	return equip_list
end

function ZhuanShengData:GetLevelEquip(sub_type)

	local requip_list = self:GetBagZhuanShenEquipList()
	local level_equip = {}
	local i = 1
	for k,v in pairs(requip_list) do
		local requip_cfg, requip_type = ItemData.Instance:GetItemConfig(v.item_id)

		if requip_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and sub_type == requip_cfg.sub_type and self.zhuansheng_info.zhuansheng_level >= requip_cfg.order then
			level_equip[i] = v
			level_equip[i].cap = self:GetEquipCap(v)
			i = i + 1
		end
	end
	table.sort(level_equip, SortTools.KeyUpperSorter("cap"))
	return level_equip
end

function ZhuanShengData:GetEquipCap(EquipData)
	local level_cfg, level_type = ItemData.Instance:GetItemConfig(EquipData.item_id)
	local attribute1 = CommonDataManager.GetAttributteByClass(level_cfg)
	local cap1 = CommonDataManager.GetCapability(attribute1)

	local rand_data = self:GetRandAttrListData(EquipData)
	local attribute2 = CommonDataManager.GetAttributteByClass(rand_data[1])
	local cap2 = CommonDataManager.GetCapability(attribute2)

	local cap3 = 0
	for k,v in pairs(rand_data[2]) do
		cap3 = cap3 + self:GetRandAttrScore(k, v)
	end
	return cap1 + cap2 + cap3
end

function ZhuanShengData:GetRandAttrScore(attr_type, num)
	local cap = 0
	if self.xiuwei_cfg and self.xiuwei_cfg.rand_attr_score then
		for k,v in pairs(self.xiuwei_cfg.rand_attr_score) do
			if attr_type == v.attr_type then
				cap = v.attr_score * num
			end
		end
	end
	return cap
end

function ZhuanShengData:GetRandAttrListData(data)
	local attr_type = {[33] = "max_hp", [35] = "gong_ji", [36] = "fang_yu", [39] = "bao_ji", [200] = 200, [201] = 201}
	-- local attr_type = CommonDataManager.GetAttrAdvancedKeyList()
	local list = {}
	if data and data.param then
		if attr_type[data.param.shen_level] then
			list[attr_type[data.param.shen_level]] = data.param.random_arrt_val
		end
		if attr_type[data.param.fuling_level] then
			list[attr_type[data.param.fuling_level]] = data.param.has_lucky
		end
		if attr_type[data.param.random_attr_type] then
			list[attr_type[data.param.random_attr_type]] = data.param.fumo_id
		end
	end

	local rand_list = {}
	local exp_list = {}
	for k,v in pairs(list) do
		if k ~= 200 and k ~= 201 then
			rand_list[k] = v
		else
			exp_list[k] = v
		end
	end
	return {rand_list, exp_list}
end

function ZhuanShengData:GetEquipScore(data, fight_power)
	if not data or not next(data) then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return end
	for k, v in pairs(self.xiuwei_cfg.s_grade) do
		if v.equip_type == item_cfg.sub_type and v.equip_grade == item_cfg.limit_level then
			if v.ss_score < fight_power then
				if v.sss_score <= fight_power then
					return Split("sss_score", "_")[1]
				else
					return Split("ss_score", "_")[1]
				end
			elseif v.ss_score == fight_power then
				return Split("ss_score", "_")[1]
			elseif v.s_score <= fight_power then
				return Split("s_score", "_")[1]
			end
		end
	end
	return nil
end

function ZhuanShengData:GetZhuanShengEquipIndex(sub_type)
	if sub_type >= GameEnum.ZS_EQUIP_TYPE_TOUKUI and sub_type <= GameEnum.ZS_EQUIP_TYPE_JIEZHI then
		return sub_type - GameEnum.ZS_EQUIP_TYPE_TOUKUI
	end
	return -2
end

function ZhuanShengData:IsSameEquip(data_1, data_2)
	if not data_1 or not data_2 then return false end
	local param_1 = data_1.param or {}
	local param_2 = data_2.param or {}
	local attr_1 = {}
	local attr_2 = {}
	for i= 1, 3 do
		table.insert(attr_1, param_1["rand_attr_type_"..i])
		table.insert(attr_2, param_2["rand_attr_type_"..i])
	end
	table.sort(attr_1, function(a, b)
		return a < b
	end)
	table.sort(attr_2, function(a, b)
		return a < b
	end)
	for k, v in pairs(attr_1) do
		if v ~= attr_2[k] then
			return false
		end
	end
	return true
end

-- 计算转生装备战力
function ZhuanShengData:GetZhuangShengEquipFightPower(data)
	local fight_power = 0
	if not data or not next(data) then return fight_power end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return fight_power end

	local base_attr_list = CommonDataManager.GetAttributteByClass(item_cfg)
	local exp_type_count = 0

	if data.param and item_cfg.sub_type >= GameEnum.ZHUANSHENG_SUB_TYPE_MIN and item_cfg.sub_type <= GameEnum.ZHUANSHENG_SUB_TYPE_MAX then
		--转生装备
		for i=1,3 do
			if nil ~= data.param["rand_attr_val_"..i] and data.param["rand_attr_val_"..i] > 0 then
				if data.param["rand_attr_type_"..i] ~= 200 then
					local key = Language.Common.ZhuanShengRandAttrKey[data.param["rand_attr_type_"..i]]
					base_attr_list[key] = base_attr_list[key] + data.param["rand_attr_val_"..i]
				else
					exp_type_count = exp_type_count + 1
				end
			end
		end
	end

	fight_power = CommonDataManager.GetCapabilityCalculation(base_attr_list) --+ self:GetRandAttrScore(200, exp_type_count)

	return fight_power
end