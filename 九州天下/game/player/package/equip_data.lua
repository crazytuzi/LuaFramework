--------------------------------------------------------
--玩家身上的装备数据管理
--------------------------------------------------------
EquipData = EquipData or BaseClass()

-- 万分比属性类型
local LEGEND_PER_TYPE = {
	["per_max_gongji"] = 0, ["per_max_fangyu"] = 0, ["per_max_maxhp"] = 0, ["per_max_mingzhong"] = 0, ["per_max_shanbi"] = 0, ["per_max_baoji"] = 0, ["per_max_jianren"] = 0,
}
-- 等级类型属性
local LEGEND_LEVEL_TYPE = {
	["max_gongji"] = 0, ["max_fangyu"] = 0, ["max_maxhp"] = 0, ["max_mingzhong"] = 0, ["max_shanbi"] = 0, ["max_baoji"] = 0, ["max_jianren"] = 0,
}

local LEGEND_TYPE_KEY = {
	[1] = "per_max_maxhp", [2] = "per_max_gongji", [3] = "per_max_fangyu", [4] = "per_max_mingzhong", [5] = "per_max_shanbi", [6] = "per_max_baoji", [7] = "per_max_jianren",
	[8] = "max_maxhp", [9] = "max_gongji", [10] = "max_fangyu", [11] = "max_mingzhong", [12] = "max_shanbi", [13] = "max_baoji", [14] = "max_jianren",
}

local LEGEND_TYPE_CAP_KEY = {
	[1] = "per_maxhp", [2] = "per_gongji", [3] = "per_fangyu", [4] = "per_mingzhong", [5] = "per_shanbi", [6] = "per_baoji", [7] = "per_max_jianren",
	[8] = "max_hp", [9] = "gongji", [10] = "fangyu", [11] = "mingzhong", [12] = "shanbi", [13] = "baoji", [14] = "jian_ren", [15] = "ignore_fangyu",
	[16] = "hurt_increase", [17] = "hurt_reduce", [19] = "pvp_hurt_increase_per", [21] = "pvp_hurt_reduce_per", 
}

local WAN_PERCENT = 10000
local MAX_SHUXING_TYPE = 14
local MAX_SHUXING_CAP_TYPE = 21

function EquipData:__init()
	self.grid_data_list = {}
	self.grid_info = {}
	EquipData.Instance = self
	self.notify_data_change_callback_list = {}		--身上装备有更新变化时进行回调
	self.notify_datalist_change_callback_list = {} 	--身上装备列表有变化时回调，一般是整理时，或初始化物品列表时

	self.is_set_equip_info = false

	self.is_take_off_equip = false
end

function EquipData:__delete()
	self.grid_data_list = nil
	self.notify_data_change_callback_list = nil
	self.notify_datalist_change_callback_list = nil
	EquipData.Instance = nil
end

--一开始同步所有装备信息
function EquipData:SetDataList(datalist)
	self.grid_data_list = datalist
	self:FlushGridData()
	for k,v in pairs(self.notify_datalist_change_callback_list) do  --物品有变化，通知观察者，不带消息体
		v()
	end
	RemindManager.Instance:Fire(RemindName.KaiFu)

	self.is_set_equip_info = true
end

--强化、神铸改变
function EquipData:SetEquipmentGridInfo(datalist)
	self.grid_info = datalist
	self:FlushGridData()
	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v()
	end
end

function EquipData:FlushGridData()
	if self.grid_data_list == nil or next(self.grid_data_list) == nil then
		return
	end
	for k,v in pairs(self.grid_data_list) do
		if v.param == nil then
			v.param = {}
		end
		local data = self.grid_info[k]
		if data ~= nil then
			v.param.strengthen_level = data.strengthen_level
			v.param.shen_level = data.shenzhu_level
			v.param.star_level = data.star_level
			v.param.star_exp = data.star_exp
			v.param.grid_strengthen_level = data.grid_strengthen_level
		end
	end
end

--改变某个格中的数据
function EquipData:ChangeDataInGrid(data)
	if data == nil then
		return
	end
	local change_reason = 2
	local change_item_id = data.item_id
	local change_item_index = data.index
	local t = self:GetGridData(data.index)

	if t ~= nil and data.num == 0 then --delete
		change_reason = 0
		change_item_id = t.item_id
		self.grid_data_list[data.index] = {}
	elseif t == nil	 then			   --add
		change_reason = 1
	end
	if change_reason ~= 0 then
		self.grid_data_list[data.index] = data
	end

	self:FlushGridData()

	for k,v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v(change_item_id, change_item_index, change_reason)
	end
end

function EquipData:GetDataList()
	return self.grid_data_list
end

--获取身上装备数量
function EquipData:GetDataCount()
	local count = 0
	for k,v in pairs(self.grid_data_list) do
		if v.item_id then
			count = count + 1
		end
	end
	return count
end

-- 装备类型
function EquipData:IsFangJuType(equip_type)
	return GameEnum.EQUIP_TYPE_TOUKUI == equip_type or GameEnum.EQUIP_TYPE_YIFU == equip_type or GameEnum.EQUIP_TYPE_YAODAI == equip_type or
			GameEnum.EQUIP_TYPE_HUTUI == equip_type or GameEnum.EQUIP_TYPE_XIEZI == equip_type or GameEnum.EQUIP_TYPE_HUSHOU == equip_type
end

-- 武器类型
function EquipData.IsWQType(equip_type)
	return GameEnum.EQUIP_TYPE_WUQI == equip_type
end

-- 饰品类型
function EquipData.IsSPType(equip_type)
	return GameEnum.EQUIP_TYPE_JIEZHI == equip_type or GameEnum.EQUIP_TYPE_XIANGLIAN == equip_type or GameEnum.EQUIP_TYPE_GOUYU == equip_type
end

-- 护甲类型
function EquipData.IsHJType(equip_type)
	return GameEnum.EQUIP_TYPE_TOUKUI == equip_type or GameEnum.EQUIP_TYPE_YIFU == equip_type
end

-- 防具类型
function EquipData.IsFJType(equip_type)
	return GameEnum.EQUIP_TYPE_HUTUI == equip_type or GameEnum.EQUIP_TYPE_HUSHOU == equip_type or GameEnum.EQUIP_TYPE_XIEZI == equip_type
end

-- 转生装备
function EquipData.IsZhuanshnegEquipType(equip_type)
	if equip_type >= 900 and equip_type <= 909 then
		return true
	end
	return false
end

-- 精灵类型
function EquipData.IsJLType(equip_type)
	return GameEnum.EQUIP_TYPE_JINGLING == equip_type
end

--情缘装备类型
function EquipData.IsMarryEqType(equip_type)
	return GameEnum.E_TYPE_QINGYUAN_1 == equip_type or GameEnum.E_TYPE_QINGYUAN_2 == equip_type
	or GameEnum.E_TYPE_QINGYUAN_3 == equip_type or GameEnum.E_TYPE_QINGYUAN_4 == equip_type
end

--小宠物玩具装备类型
function EquipData.IsLittlePetToyType(equip_type)
	return GameEnum.E_TYPE_LITTLEPET_1 == equip_type or GameEnum.E_TYPE_LITTLEPET_2 == equip_type
		or GameEnum.E_TYPE_LITTLEPET_3 == equip_type or GameEnum.E_TYPE_LITTLEPET_4 == equip_type
end

--通过装备类型获得可以放置的索引
function EquipData:GetEquipIndexByType(equip_type)
	if not equip_type then return -1 end
	if equip_type >= GameEnum.EQUIP_TYPE_TOUKUI and equip_type <= GameEnum.EQUIP_TYPE_YAODAI then
		--return equip_type - GameEnum.EQUIP_TYPE_TOUKUI
		if equip_type == GameEnum.EQUIP_TYPE_JIEZHI then
			return self:GetJieZhiEquipIndex()
		else
			return equip_type - GameEnum.EQUIP_TYPE_TOUKUI
		end
	elseif equip_type >= GameEnum.E_TYPE_QINGYUAN_1 and equip_type <= GameEnum.E_TYPE_QINGYUAN_4 then
		return equip_type
	end
	return -1
end

--得到戒指索引
function EquipData:GetJieZhiEquipIndex()
	local equiplist = EquipData.Instance:GetDataList()
	if equiplist then
		if not equiplist[GameEnum.EQUIP_INDEX_JIEZHI] or equiplist[GameEnum.EQUIP_INDEX_JIEZHI].item_id == 0 then
			return GameEnum.EQUIP_INDEX_JIEZHI
		end
		if not equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2] or equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2].item_id == 0 then
			return GameEnum.EQUIP_INDEX_JIEZHI_2
		end
		local capability1 = self:GetEquipLegendFightPowerByData(equiplist[GameEnum.EQUIP_INDEX_JIEZHI], true)
		local capability2 = self:GetEquipLegendFightPowerByData(equiplist[GameEnum.EQUIP_INDEX_JIEZHI_2], true)
		return capability2 < capability1 and GameEnum.EQUIP_INDEX_JIEZHI_2 or GameEnum.EQUIP_INDEX_JIEZHI
	end
	return GameEnum.EQUIP_INDEX_JIEZHI
end

--绑定数据改变时的回调方法.用于任意物品有更新时进行回调
function EquipData:NotifyDataChangeCallBack(callback, notify_datalist)
	self:UnNotifyDataChangeCallBack(callback)
	if notify_datalist then
		self.notify_datalist_change_callback_list[#self.notify_datalist_change_callback_list + 1] = callback
	else
		self.notify_data_change_callback_list[#self.notify_data_change_callback_list + 1] = callback
	end
end

--移除绑定回调
function EquipData:UnNotifyDataChangeCallBack(callback)
	for k,v in pairs(self.notify_data_change_callback_list) do
		if v == callback then
			self.notify_data_change_callback_list[k] = nil
			return
		end
	end
	for k,v in pairs(self.notify_datalist_change_callback_list) do
		if v == callback then
			self.notify_datalist_change_callback_list[k] = nil
			return
		end
	end
end

--获得某个格子的数据
function EquipData:GetGridData(index)
	return self.grid_data_list[index]
end

function EquipData.GetEquipBg(index)
	if index == GameEnum.EQUIP_INDEX_TOUKUI then
		return "HelmetBG"
	elseif index == GameEnum.EQUIP_INDEX_YIFU then
		return "ClothesBG"
	elseif index == GameEnum.EQUIP_INDEX_HUTUI then
		return "LegGuardBG"
	elseif index == GameEnum.EQUIP_INDEX_XIEZI then
		return "ShoesBG"
	elseif index == GameEnum.EQUIP_INDEX_HUSHOU then
		return "GlovesBG"
	elseif index == GameEnum.EQUIP_INDEX_XIANLIAN2 or index == GameEnum.EQUIP_INDEX_XIANLIAN1 then
		return "NecklaceBG"
	elseif index == GameEnum.EQUIP_INDEX_WUQI then
		return "WeaponsBG"
	elseif index == GameEnum.EQUIP_JIEZHI_2 or index == GameEnum.EQUIP_JIEZHI_1 then
		return "RingBG"
	end
end

-- 获取装备基础和传说属性战力(人物基本装备)
-- is_from_equip 是否穿着在身上装备
-- is_single_fight_pwoer 是否计算单件装备
-- compare_other  是否计算升星，神铸，强化
function EquipData:GetEquipLegendFightPowerByData(data, is_from_equip, is_single_fight_pwoer, vo, compare_other, ignore_same)
	return self:GetCompareCap(data, is_from_equip, is_single_fight_pwoer, vo, compare_other, ignore_same)


	-- if not data then return 0 end

	-- local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)

	-- if not item_cfg then return 0 end
	-- for k, v in pairs(LEGEND_PER_TYPE) do
	-- 	LEGEND_PER_TYPE[k] = 0
	-- end
	-- for k, v in pairs(LEGEND_LEVEL_TYPE) do
	-- 	LEGEND_LEVEL_TYPE[k] = 0
	-- end
	-- local attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	-- local vo = vo or GameVoManager.Instance:GetMainRoleVo()
	-- local this_equip_index = -1

	-- if is_from_equip then
	-- 	this_equip_index = data.index
	-- else
	-- 	this_equip_index = self:GetEquipIndexByType(item_cfg.sub_type)
	-- end

	-- local same_attr_list = CommonDataManager.GetAttributteNoUnderline()
	-- local is_qy = false

	-- if this_equip_index ~= nil and this_equip_index >= GameEnum.E_TYPE_QINGYUAN_1 and this_equip_index <= GameEnum.E_TYPE_QINGYUAN_4 then
	-- 	is_qy = true
	-- 	local marry_index = this_equip_index - GameEnum.E_TYPE_QINGYUAN_1
	-- 	local qy_data = MarryEquipData.Instance:GetMarryEquipInfo()
	-- 	if qy_data ~= nil and qy_data[marry_index] ~= nil and qy_data[marry_index].item_id > 0 then
	-- 		local qy_item_cfg = ItemData.Instance:GetItemConfig(qy_data[marry_index].item_id)
	-- 		if qy_item_cfg ~= nil then
	-- 			local item_attr = CommonDataManager.GetAttributteNoUnderline(qy_item_cfg)
	-- 			for k,v in pairs(item_attr) do
	-- 				if v > 0 and same_attr_list[k] ~= nil then
	-- 					same_attr_list[k] = same_attr_list[k] + v
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- if data.param and data.param.xianpin_type_list then
	-- 	for k, v in pairs(self.grid_data_list) do
	-- 		item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
	-- 		local temp_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	-- 		local temp_equip_index = v.index
	-- 		local is_same = false
	-- 		if this_equip_index == temp_equip_index and temp_equip_index >= 0 then
	-- 			same_attr_list = temp_list
	-- 			is_same = true
	-- 		end

	-- 		if v.param and v.param.xianpin_type_list then
	-- 			for i, j in pairs(v.param.xianpin_type_list) do
	-- 				if j and j > 0 then
	-- 					local legend_cfg = ForgeData.Instance:GetLegendCfgByType(j)
	-- 					if legend_cfg and legend_cfg.shuxing_type and legend_cfg.shuxing_type <= MAX_SHUXING_TYPE then
	-- 						if LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
	-- 							local key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]
	-- 							-- 万分比属性
	-- 							if LEGEND_PER_TYPE[key] then
	-- 								if is_same then
	-- 									same_attr_list[key] = same_attr_list[key] or 0
	-- 									same_attr_list[key] = same_attr_list[key] + legend_cfg.add_value / WAN_PERCENT
	-- 								end
	-- 								LEGEND_PER_TYPE[key] = LEGEND_PER_TYPE[key] + legend_cfg.add_value / WAN_PERCENT
	-- 							end
	-- 							-- 等级属性
	-- 							if LEGEND_LEVEL_TYPE[key] then
	-- 								if is_same then
	-- 									same_attr_list[key] = same_attr_list[key] or 0
	-- 									same_attr_list[key] = same_attr_list[key] + vo.level * legend_cfg.add_value
	-- 								end
	-- 								LEGEND_LEVEL_TYPE[key] = LEGEND_LEVEL_TYPE[key] + vo.level * legend_cfg.add_value
	-- 							end
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- 	for k, v in pairs(data.param.xianpin_type_list) do
	-- 		if v and v > 0 then
	-- 			local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
	-- 			if legend_cfg and legend_cfg.shuxing_type and legend_cfg.shuxing_type <= MAX_SHUXING_TYPE then
	-- 				if LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
	-- 					local key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]
	-- 					-- 万分比属性
	-- 					if LEGEND_PER_TYPE[key] then
	-- 						attr_list[key] = 0
	-- 						attr_list[key] = attr_list[key] + legend_cfg.add_value / WAN_PERCENT
	-- 						LEGEND_PER_TYPE[key] = LEGEND_PER_TYPE[key] + legend_cfg.add_value / WAN_PERCENT
	-- 					end
	-- 					-- 等级属性
	-- 					if LEGEND_LEVEL_TYPE[key] then
	-- 						attr_list[key] = 0
	-- 						attr_list[key] = attr_list[key] + vo.level * legend_cfg.add_value
	-- 						LEGEND_LEVEL_TYPE[key] = LEGEND_LEVEL_TYPE[key] + vo.level * legend_cfg.add_value
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- local final_attr_list = CommonDataManager.GetAttributteNoUnderline()

	-- local fight_power = 0
	-- local base_attr_list = CommonDataManager.AddAttributeBaseAttr(final_attr_list, vo, true)
	-- if is_from_equip then
	-- 	for k, v in pairs(final_attr_list) do
	-- 		if LEGEND_PER_TYPE["per_max_"..k] and LEGEND_LEVEL_TYPE["max_"..k] then
	-- 			local same_per_value = same_attr_list["per_max_"..k] or 0
	-- 			local same_level_value = same_attr_list["max_"..k] or 0

	-- 			local per_value = attr_list["per_max_"..k] or 0
	-- 			local level_value = attr_list["max_"..k] or 0

	-- 			final_attr_list[k] = (base_attr_list[k] / (LEGEND_PER_TYPE["per_max_"..k] + 1 - per_value) - level_value
	-- 				- attr_list[k]) * (1 + LEGEND_PER_TYPE["per_max_"..k] - per_value - per_value)
	-- 		else
	-- 			final_attr_list[k] = base_attr_list[k] or 0
	-- 		end
	-- 	end

	-- 	fight_power = vo.capability - CommonDataManager.GetCapabilityCalculation(final_attr_list) - vo.other_capability
	-- 	-- fight_power = CommonDataManager.GetCapabilityCalculation(base_attr_list) - CommonDataManager.GetCapabilityCalculation(final_attr_list)
	-- else
	-- 	for k, v in pairs(final_attr_list) do
	-- 		if LEGEND_PER_TYPE["per_max_"..k] and LEGEND_LEVEL_TYPE["max_"..k] then
	-- 			local same_per_value = same_attr_list["per_max_"..k] or 0
	-- 			local same_level_value = same_attr_list["max_"..k] or 0

	-- 			local per_value = attr_list["per_max_"..k] or 0
	-- 			local level_value = attr_list["max_"..k] or 0

	-- 			final_attr_list[k] = (base_attr_list[k] / (LEGEND_PER_TYPE["per_max_"..k] + 1 - per_value) - same_level_value
	-- 				- same_attr_list[k] + level_value + attr_list[k]) * (1 + LEGEND_PER_TYPE["per_max_"..k] - same_per_value)
	-- 		else
	-- 			final_attr_list[k] = base_attr_list[k] or 0

	-- 			if is_qy and same_attr_list[k] ~= nil and base_attr_list[k] ~= nil and attr_list[k] ~= nil then
	-- 				final_attr_list[k] = base_attr_list[k] - same_attr_list[k] + attr_list[k]
	-- 			end
	-- 		end
	-- 	end


	-- 	if not is_single_fight_pwoer then
	-- 		-- 模拟穿上身后总战力，用于对比装备用，显示上升，下降箭头
	-- 		fight_power = CommonDataManager.GetCapabilityCalculation(final_attr_list) + vo.other_capability
	-- 	else
	-- 		local take_off_attr = CommonDataManager.GetAttributteNoUnderline()
	-- 		for k, v in pairs(take_off_attr) do
	-- 			if LEGEND_PER_TYPE["per_max_"..k] and LEGEND_LEVEL_TYPE["max_"..k] then
	-- 				local same_per_value = same_attr_list["per_max_"..k] or 0
	-- 				local same_level_value = same_attr_list["max_"..k] or 0

	-- 				local per_value = attr_list["per_max_"..k] or 0
	-- 				local level_value = attr_list["max_"..k] or 0

	-- 				take_off_attr[k] = (base_attr_list[k] / (LEGEND_PER_TYPE["per_max_"..k] + 1 - per_value) - same_level_value
	-- 					- same_attr_list[k]) * (1 + LEGEND_PER_TYPE["per_max_"..k] - same_per_value - per_value)
	-- 			else
	-- 				take_off_attr[k] = base_attr_list[k] or 0
	-- 			end
	-- 		end
	-- 		fight_power = CommonDataManager.GetCapabilityCalculation(final_attr_list) - CommonDataManager.GetCapabilityCalculation(take_off_attr)
	-- 		-- fight_power = CommonDataManager.GetCapabilityCalculation(base_attr_list) - CommonDataManager.GetCapabilityCalculation(take_off_attr)
	-- 	end
	-- end

	-- return fight_power
end

function EquipData:GetCompareCap(data, is_from_equip, is_single_fight_pwoer, vo, compare_other, ignore_same)
	local fight_power = 0
	if data == nil then
		return fight_power
	end

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return fight_power end
	if big_type ~= GameEnum.ITEM_BIGTYPE_EQUIPMENT then
		return fight_power
	end

	local attr_list = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local vo = vo or GameVoManager.Instance:GetMainRoleVo()
	--local this_equip_index = self:GetEquipIndexByType(item_cfg.sub_type)
	local is_equip = false
	local equip_index = -1
	local is_qy = false
	local is_role_equip = true
	local same_attr_list = CommonStruct.AttributeNoUnderline()

	if item_cfg.sub_type >= GameEnum.EQUIP_TYPE_TOUKUI and item_cfg.sub_type <= GameEnum.EQUIP_TYPE_YAODAI then
		equip_index = item_cfg.sub_type - GameEnum.EQUIP_TYPE_TOUKUI
	end

	if item_cfg.sub_type >= GameEnum.E_TYPE_QINGYUAN_1 and item_cfg.sub_type <= GameEnum.E_TYPE_QINGYUAN_4 then
		equip_index = item_cfg.sub_type - GameEnum.E_TYPE_QINGYUAN_1
		is_qy = true
	end

	--如果是情缘装备，计算身上同样位置的情缘装备的属性
	if is_qy then
		local marry_index = equip_index
		local qy_data = MarryEquipData.Instance:GetMarryEquipInfo()
		if qy_data ~= nil and qy_data[marry_index] ~= nil and qy_data[marry_index].item_id > 0 then
			local qy_item_cfg = ItemData.Instance:GetItemConfig(qy_data[marry_index].item_id)
			if qy_item_cfg ~= nil then
				local item_attr = CommonDataManager.GetAttributteNoUnderline(qy_item_cfg)
				for k,v in pairs(item_attr) do
					if v > 0 and same_attr_list[k] ~= nil then
						same_attr_list[k] = same_attr_list[k] + v
					end
				end
			end
		end

	--如果是人物装备，计算身上同样位置的装备的属性
	else
		if self.grid_data_list ~= nil and equip_index ~= -1 then
			local now_equip_data = self.grid_data_list[equip_index]
			if now_equip_data ~= nil and now_equip_data.item_id ~= nil and now_equip_data.item_id > 0 then
				local equip_cfg = ItemData.Instance:GetItemConfig(now_equip_data.item_id) or {}
				local item_attr = CommonDataManager.GetAttributteNoUnderline(equip_cfg)
				for k,v in pairs(item_attr) do
					if v > 0 and same_attr_list[k] ~= nil then
						same_attr_list[k] = same_attr_list[k] + v
					end
				end	

				local same_xianpin = ForgeData.Instance:GetEquipXianPinAttrValue(now_equip_data, vo, equip_cfg.limit_level)	
				for k,v in pairs(same_xianpin) do
					if v > 0 and same_attr_list[k] ~= nil then
						same_attr_list[k] = same_attr_list[k] + v
					end
				end	
			end
		end
	end

	--传进来的装备的仙品属性
	local equip_xianpin_value = ForgeData.Instance:GetEquipXianPinAttrValue(data, vo, item_cfg.limit_level)	
	local equip_base_value = CommonDataManager.GetAttributteNoUnderline(item_cfg)
	local final_attr_list = CommonDataManager.GetAttributteNoUnderline()
	local base_attr_list = CommonDataManager.AddAttributeBaseAttr(final_attr_list, vo, true)
	local data_cap = CommonDataManager.GetCapability(equip_base_value) + CommonDataManager.GetCapability(equip_xianpin_value)
	local other_cap = 0
	local same_cap = CommonDataManager.GetCapability(same_attr_list)

	if is_from_equip then
		fight_power = vo.capability - data_cap
	else
		if not is_single_fight_pwoer then
			-- 模拟穿上身后总战力，用于对比装备用，显示上升，下降箭头
			fight_power = vo.capability + data_cap - same_cap
		else
			if ignore_same then
				fight_power = data_cap
			else
				fight_power = data_cap - same_cap
			end
		end
	end


	if compare_other and not is_qy and equip_index ~= -1 and self.grid_data_list ~= nil and same_cap == 0 then
		local other_equip_data = self.grid_data_list[equip_index]
		other_cap =  ForgeData.Instance:GetEquipOtherCap(other_equip_data, equip_index)
		fight_power = fight_power + other_cap
	end

	return fight_power
end

function EquipData:IsSameEquip(data, data_2)
	if not data then return false end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return false end

	local equip_index = self:GetEquipIndexByType(item_cfg.sub_type)
	if equip_index < 0 then return false end

	local grid_data = data_2 or self:GetGridData(equip_index)
	if not grid_data or not grid_data.item_id then return false end

	if grid_data.item_id == data.item_id then
		local temp_data_xianpin = {}
		local temp_grid_datax_xianpin = {}
		local data_xianpin = data.param and data.param.xianpin_type_list or {}
		local grid_xianpin = grid_data.param and grid_data.param.xianpin_type_list or {}
		if next(data_xianpin) then
			table.sort(data_xianpin, function(a, b)
				return a < b
			end)
		end
		if next(grid_xianpin) then
			table.sort(grid_xianpin, function(a, b)
				return a < b
			end)
		end
		for k, v in pairs(data_xianpin) do
			if v and v > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
				if legend_cfg and legend_cfg.color then
					table.insert(temp_data_xianpin, v)
				end
			end
			if grid_xianpin[k] and grid_xianpin[k] > 0 then
				local legend_cfg = ForgeData.Instance:GetLegendCfgByType(grid_xianpin[k])
				if legend_cfg and legend_cfg.color then
					table.insert(temp_grid_datax_xianpin, grid_xianpin[k])
				end
			end
		end

		if #temp_grid_datax_xianpin ~= #temp_data_xianpin then
			return false
		end

		for k, v in pairs(temp_grid_datax_xianpin) do
			if v ~= temp_data_xianpin[k] then
				return false
			end
		end
		return true
	end
end

--获取武器战力
function EquipData:GetEquipCapacity(data)
	if nil == data or nil == data.item_id then
		return 0
	end

	local capability = EquipData.Instance:GetEquipLegendFightPowerByData(data)
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	capability = capability - game_vo.capability
	return capability
end
--获取武器战力(避免改到其他地方，新写一个接口)
function EquipData:NewGetEquipCapacity(data)
	local vo_level = GameVoManager.Instance:GetMainRoleVo().level
	local xianpin_level = ConfigManager.Instance:GetAutoConfig("equipforge_auto")
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local legend_level = 0
	if xianpin_level then
		local xianpin_attr_level = item_cfg.equip_level + xianpin_level["other"][1].xianpin_attr_level_param
		legend_level = xianpin_attr_level
	end
	local legend_data = {}
	if data.param and data.param.xianpin_type_list then
		for i, j in pairs(data.param.xianpin_type_list) do
			local legend_cfg = ForgeData.Instance:GetLegendCfgByType(j)
			if legend_cfg and legend_cfg.shuxing_type and legend_cfg.shuxing_type <= MAX_SHUXING_TYPE then
				if LEGEND_TYPE_CAP_KEY[legend_cfg.shuxing_type] then
					local key = LEGEND_TYPE_CAP_KEY[legend_cfg.shuxing_type]
					legend_data[key] = legend_cfg.add_value * legend_level
				end
			end
		end
	end
	local legend_capability = next(legend_data) and CommonDataManager.GetCapabilityCalculation(legend_data) or 0
	local common_capability = CommonDataManager.GetCapabilityCalculation(item_cfg)
	local capability = common_capability + legend_capability
	return capability
end

function EquipData:CheckIsAutoEquip(item_id, the_index)
	local cur_cfg = ItemData.Instance:GetItemConfig(item_id)
	if cur_cfg.sub_type == 202 then --婚戒
		return true
	end
	local index = cur_cfg.sub_type%10
	local equip_data = self:GetDataList()
	local new_equip_data = ItemData.Instance:GetGridData(the_index)
	local new_equip_power = self:GetEquipLegendFightPowerByData(new_equip_data, false, true) --GetEquipCapacity(new_equip_data)
	local old_equip_power = 0

	if self:IsSameEquip(new_equip_data) then
		return false
	end

	if equip_data[index] ~= nil then
		old_equip_data = self:GetGridData(index)
		old_equip_power = self:GetEquipLegendFightPowerByData(old_equip_data, false, true)  --GetEquipCapacity(old_equip_data)
	end

	if new_equip_power > old_equip_power then
		return true
	else
		return false
	end
end

function EquipData:GetTextColor1(the_color_1)
	local color_text_1 = ""
	if the_color_1 == 1 then
		color_text_1 = TEXT_COLOR.GREEN_2
	elseif the_color_1 == 2 then
		color_text_1 = TEXT_COLOR.BLUE_2
	elseif the_color_1 == 3 then
		color_text_1 = TEXT_COLOR.PURPLE_2
	elseif the_color_1 == 4 then
		color_text_1 = TEXT_COLOR.ORANGE_2
	elseif the_color_1 == 5 then
		color_text_1 = TEXT_COLOR.RED_2
	end
	return color_text_1
end

function EquipData:GetTextColor2(the_color_2)
	local color_text_2 = ""
	if the_color_2 == 1 then
		color_text_2 = TEXT_COLOR.GREEN_1
	elseif the_color_2 == 2 then
		color_text_2 = TEXT_COLOR.BLUE_1
	elseif the_color_2 == 3 then
		color_text_2 = TEXT_COLOR.PURPLE_1
	elseif the_color_2 == 4 then
		color_text_2 = TEXT_COLOR.ORANGE_1
	elseif the_color_2 == 5 then
		color_text_2 = TEXT_COLOR.RED_1
	end
	return color_text_2
end

function EquipData:IsSetEquipInfo()
	return self.is_set_equip_info
end

function EquipData:SetTakeOffFlag(value)
	self.is_take_off_equip = value
end

function EquipData:GetTakeOffFlag()
	return self.is_take_off_equip
end
--获取装备熔炉积分
function EquipData:GetEquipResolve(color, level)
	local cfg = ConfigManager.Instance:GetAutoConfig("ronglu_config_auto").ronglu_jingyan
	for k, v in pairs(cfg) do
		if color == v.equip_color and level == v.equip_level then
			return v.ronglu_jingyan
		end
	end
	return nil
end
