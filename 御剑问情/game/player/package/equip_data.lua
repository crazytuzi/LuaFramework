--------------------------------------------------------
--玩家身上的装备数据管理
--------------------------------------------------------
EquipData = EquipData or BaseClass()

-- 万分比属性类型
local LEGEND_PER_TYPE = {
	["per_max_gongji"] = 0,
	["per_max_fangyu"] = 0,
	["per_max_maxhp"] = 0,
	["per_max_mingzhong"] = 0,
	["per_max_shanbi"] = 0,
	["per_max_baoji"] = 0,
	["per_max_jianren"] = 0,
}
-- 等级类型属性
local LEGEND_LEVEL_TYPE = {
	["max_gongji"] = 0,
	["max_fangyu"] = 0,
	["max_maxhp"] = 0,
	["max_mingzhong"] = 0,
	["max_shanbi"] = 0,
	["max_baoji"] = 0,
	["max_jianren"] = 0,
}

-- 全身装备属性百分比
local LEGEND_EQUIP_PER_TYPE = {
	["equip_per_fang_yu"] = 0,
	["equip_per_max_hp"] = 0,
	["equip_per_gong_ji"] = 0,
}

local LEGEND_TYPE_KEY = {
	[1] = "per_max_maxhp",
	[2] = "per_max_gongji",
	[3] = "per_max_fangyu",
	[4] = "per_max_mingzhong",
	[5] = "per_max_shanbi",
	[6] = "per_max_baoji",
	[7] = "per_max_jianren",
	[8] = "max_maxhp",
	[9] = "max_gongji",
	[10] = "max_fangyu",
	[11] = "max_mingzhong",
	[12] = "max_shanbi",
	[13] = "max_baoji",
	[14] = "max_jianren",
	[20] = "equip_per_fang_yu",
	[21] = "equip_per_max_hp",
	[22] = "equip_per_gong_ji",
}

local WAN_PERCENT = 10000
local MAX_SHUXING_TYPE = 14

function EquipData:__init()
	self.grid_data_list = {}
	self.grid_info = {}
	EquipData.Instance = self
	self.notify_data_change_callback_list = {}		--身上装备有更新变化时进行回调
	self.notify_datalist_change_callback_list = {} 	--身上装备列表有变化时回调，一般是整理时，或初始化物品列表时

	self.min_eternity_level = 0
	self.use_eternity_level = 0
	self.min_lianhun_level = 0

	self.is_set_equip_info = false

	self.is_take_off_equip = false
	local equipment_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	self.equip_cfg_list = {}
	for k,v in pairs(equipment_cfg) do
		self.equip_cfg_list[v.limit_prof] = self.equip_cfg_list[v.limit_prof] or {}
		self.equip_cfg_list[v.limit_prof][v.order] = self.equip_cfg_list[v.limit_prof][v.order] or {}
		self.equip_cfg_list[v.limit_prof][v.order][v.sub_type] = self.equip_cfg_list[v.limit_prof][v.order][v.sub_type] or {}
		self.equip_cfg_list[v.limit_prof][v.order][v.sub_type][v.color] = v
	end
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

function EquipData:GetGridInfo()
	return self.grid_info
end

function EquipData.GetPinkEquipParam()
	local param = CommonStruct.ItemParamData()
	param.xianpin_type_list = {58, 59, 60}
	return param
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
			v.param.eternity_level = data.eternity_level
			v.param.lianhun_level = data.lianhun_level
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
		count = count + 1
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

--勾玉类型
function EquipData.IsGouYuEqType(equip_type)
	return GameEnum.EQUIP_TYPE_GOUYU_LEFT == equip_type or GameEnum.EQUIP_TYPE_GOUYU_RIGHT == equip_type
end

--通过装备类型获得可以放置的索引
function EquipData:GetEquipIndexByType(equip_type)
	if not equip_type then return -1 end
	if equip_type >= GameEnum.EQUIP_TYPE_TOUKUI and equip_type <= GameEnum.EQUIP_TYPE_GOUYU_RIGHT then
		--return equip_type - GameEnum.EQUIP_TYPE_TOUKUI
		if equip_type == GameEnum.EQUIP_TYPE_JIEZHI then
			return self:GetJieZhiEquipIndex()
		else
			if EquipData.IsGouYuEqType(equip_type) then
				return equip_type - GameEnum.EQUIP_TYPE_TOUKUI + 1
			else
				return equip_type - GameEnum.EQUIP_TYPE_TOUKUI
			end
		end
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

function EquipData.GetEquipSubtype(index)
	if index == GameEnum.EQUIP_INDEX_TOUKUI then
		return GameEnum.EQUIP_TYPE_TOUKUI
	elseif index == GameEnum.EQUIP_INDEX_YIFU then
		return GameEnum.EQUIP_TYPE_YIFU
	elseif index == GameEnum.EQUIP_INDEX_KUZI then
		return GameEnum.EQUIP_KUZI
	elseif index == GameEnum.EQUIP_INDEX_XIEZI then
		return GameEnum.EQUIP_TYPE_XIEZI
	elseif index == GameEnum.EQUIP_INDEX_HUSHOU then
		return GameEnum.EQUIP_TYPE_HUSHOU
	elseif index == GameEnum.EQUIP_INDEX_XIANGLIAN then
		return GameEnum.EQUIP_TYPE_XIANGLIAN
	elseif index == GameEnum.EQUIP_INDEX_WUQI then
		return GameEnum.EQUIP_TYPE_WUQI
	elseif index == GameEnum.EQUIP_INDEX_YAODAI then
		return GameEnum.EQUIP_TYPE_YAODAI
	elseif index == GameEnum.EQUIP_INDEX_JIEZHI or index == GameEnum.EQUIP_INDEX_JIEZHI_2 then
		return GameEnum.EQUIP_TYPE_JIEZHI
	end
end

-- 获取装备基础和传说属性战力(人物基本装备)
-- is_from_equip 是否穿着在身上装备
-- is_single_fight_pwoer 是否计算单件装备
function EquipData:GetEquipLegendFightPowerByData(data, is_from_equip, is_single_fight_pwoer, vo)
	local fight_power = 0
	fight_power = self:CalculateEquipXianPinCapability(data, is_from_equip, is_single_fight_pwoer, vo)
	return fight_power
end

-- 当前选择装备的传奇属性加成
local select_equip_legend_list = {
		["equip_per_gong_ji"] = 0,
		["equip_per_fang_yu"]= 0,
		["equip_per_max_hp"] = 0,
}
-- 对应格子装备传奇属性加成
local grid_equip_legend_list = {
		["equip_per_gong_ji"] = 0,
		["equip_per_fang_yu"] = 0,
		["equip_per_max_hp"] = 0,
}
function EquipData:CalculateEquipXianPinCapability(data, is_from_equip, is_single_fight_pwoer, vo)
	for k, v in pairs(LEGEND_EQUIP_PER_TYPE) do
		LEGEND_EQUIP_PER_TYPE[k] = 0
		select_equip_legend_list[k] = 0
		grid_equip_legend_list[k] = 0
	end

	if not data then return 0 end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return 0 end

	local vo = vo or GameVoManager.Instance:GetMainRoleVo()
	local capability = 0
	local legend_cfg = nil
	-- 身上装备总属性
	local total_attr_list = CommonDataManager.GetAttributteByClass()
	local type_key = ""
	local this_equip_index = is_from_equip and data.index or self:GetEquipIndexByType(item_cfg.sub_type)
	-- 当前选择装备的属性
	local select_equip_attr_list = CommonDataManager.GetAttributteByClass(item_cfg)
	-- 对应格子装备上的属性
	local grid_equip_attr_list = CommonDataManager.GetAttributteByClass()
	-- 身上装备
	local legend_order_cfg = ForgeData.Instance:GetLegendOrderCfg()
	for k, v in pairs(self.grid_data_list) do
		local gird_item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if this_equip_index == k then
			grid_equip_attr_list = CommonDataManager.GetAttributteByClass(gird_item_cfg)
		end
		if gird_item_cfg and gird_item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_GOUYU_LEFT and gird_item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_GOUYU_RIGHT then
			total_attr_list = CommonDataManager.AddAttributeAttr(total_attr_list, CommonDataManager.GetAttributteByClass(gird_item_cfg))
		end
		for k2, v2 in pairs(v.param.xianpin_type_list or {}) do
			legend_cfg = ForgeData.Instance:GetLegendCfgByType(v2)
			if nil ~= legend_cfg
				and nil ~= LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
				type_key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]

				local cur_grade_info = nil
				for k1, v1 in pairs(legend_order_cfg) do
					if legend_cfg.xianpin_type == v1.xianpin_type then
						if gird_item_cfg and gird_item_cfg.order == v1.order then
							cur_grade_info = v1
						end
					end
				end

				if cur_grade_info then
					if this_equip_index == k then
						grid_equip_legend_list[type_key] = legend_cfg.add_value * (cur_grade_info.add_per / 10000)
					end
					LEGEND_EQUIP_PER_TYPE[type_key] = LEGEND_EQUIP_PER_TYPE[type_key] + legend_cfg.add_value * (cur_grade_info.add_per / 10000)
				end
				if item_cfg.sub_type == GameEnum.EQUIP_TYPE_GOUYU_LEFT or item_cfg.sub_type == GameEnum.EQUIP_TYPE_GOUYU_RIGHT then
					LEGEND_EQUIP_PER_TYPE[type_key] = 0
				end
			end
		end
	end
	-- 当前选择装备

	local temp_xianpin_list = data.param and data.param.xianpin_type_list or {}
	for k, v in pairs(temp_xianpin_list or {}) do
		legend_cfg = ForgeData.Instance:GetLegendCfgByType(v)
		if nil ~= legend_cfg
			and nil ~= LEGEND_TYPE_KEY[legend_cfg.shuxing_type] then
			type_key = LEGEND_TYPE_KEY[legend_cfg.shuxing_type]
			local cur_grade_info = nil
			for k1,v1 in pairs(legend_order_cfg) do
				if legend_cfg.xianpin_type == v1.xianpin_type then
					if item_cfg and item_cfg.order == v1.order then
						cur_grade_info = v1
					end
				end
			end
			select_equip_legend_list[type_key] = legend_cfg.add_value
			if cur_grade_info then
				select_equip_legend_list[type_key] = select_equip_legend_list[type_key] * (cur_grade_info.add_per / 10000)
			end
		end
	end
	-- 脱下当前格子装备的属性差值
	local diff_attr_list = CommonDataManager.GetAttributteByClass()
	diff_attr_list.gong_ji = total_attr_list.gong_ji * grid_equip_legend_list["equip_per_gong_ji"] / 10000
							+ grid_equip_attr_list.gong_ji *
							(LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] / 10000 + 1 - grid_equip_legend_list["equip_per_gong_ji"] / 10000)

	diff_attr_list.fang_yu = total_attr_list.fang_yu * grid_equip_legend_list["equip_per_fang_yu"] / 10000
							+ grid_equip_attr_list.fang_yu *
							(LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] / 10000 + 1 - grid_equip_legend_list["equip_per_fang_yu"] / 10000)

	diff_attr_list.max_hp = total_attr_list.max_hp * grid_equip_legend_list["equip_per_max_hp"] / 10000
							+ grid_equip_attr_list.max_hp *
							(LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] / 10000 + 1 - grid_equip_legend_list["equip_per_max_hp"] / 10000)

	total_attr_list.gong_ji = total_attr_list.gong_ji - grid_equip_attr_list.gong_ji
	total_attr_list.fang_yu = total_attr_list.fang_yu - grid_equip_attr_list.fang_yu
	total_attr_list.max_hp = total_attr_list.max_hp - grid_equip_attr_list.max_hp

	if item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_GOUYU_LEFT or item_cfg.sub_type ~= GameEnum.EQUIP_TYPE_GOUYU_RIGHT then
		LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] = LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] - grid_equip_legend_list["equip_per_gong_ji"]
		LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] = LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] - grid_equip_legend_list["equip_per_fang_yu"]
		LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] = LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] - grid_equip_legend_list["equip_per_max_hp"]
	else
		LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] = 0
		LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] = 0
		LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] = 0
	end

	local final_attr_list = CommonDataManager.GetAttributteByClass()
	final_attr_list = CommonDataManager.AddAttributeBaseAttr(final_attr_list, vo)
	final_attr_list.gong_ji = vo.base_gongji - diff_attr_list.gong_ji + vo.base_gongji * (vo.huixinyiji or 0) / 10000 * 0.6 --装备没有会心一击
	final_attr_list.fang_yu = vo.base_fangyu - diff_attr_list.fang_yu
	final_attr_list.max_hp = vo.base_max_hp - diff_attr_list.max_hp
	final_attr_list.ming_zhong = vo.base_mingzhong - grid_equip_attr_list.ming_zhong
	final_attr_list.shan_bi = vo.base_shanbi - grid_equip_attr_list.shan_bi
	final_attr_list.bao_ji = vo.base_baoji - grid_equip_attr_list.bao_ji
	final_attr_list.jian_ren = vo.base_jianren - grid_equip_attr_list.jian_ren
	final_attr_list.per_jingzhun = vo.base_per_jingzhun - grid_equip_attr_list.per_jingzhun
	final_attr_list.per_baoji = vo.base_per_baoji - grid_equip_attr_list.per_baoji
	final_attr_list.per_mianshang = vo.base_per_mianshang - grid_equip_attr_list.per_mianshang
	final_attr_list.per_pofang = vo.base_per_pofang - grid_equip_attr_list.per_pofang
	final_attr_list.goddess_gongji = (vo.base_goddess_gongji or vo.base_fujia_shanghai) - grid_equip_attr_list.goddess_gongji

	-- bug...之前的代码没漏了这2个属性，导致计算战力错误。因为装备没有这两个属性，所以不加减。
	final_attr_list.constant_zengshang = vo.base_constant_zengshang
	final_attr_list.constant_mianshang = vo.base_constant_mianshang

	if is_from_equip then
		capability = vo.capability - CommonDataManager.GetCapabilityCalculation(final_attr_list) - vo.other_capability
	else
		diff_attr_list.gong_ji = total_attr_list.gong_ji * select_equip_legend_list["equip_per_gong_ji"] / 10000
								+ select_equip_attr_list.gong_ji *
								(LEGEND_EQUIP_PER_TYPE["equip_per_gong_ji"] / 10000 + 1 + select_equip_legend_list["equip_per_gong_ji"] / 10000)
		diff_attr_list.fang_yu = total_attr_list.fang_yu * select_equip_legend_list["equip_per_fang_yu"] / 10000
								+ select_equip_attr_list.fang_yu *
								(LEGEND_EQUIP_PER_TYPE["equip_per_fang_yu"] / 10000 + 1 + select_equip_legend_list["equip_per_fang_yu"] / 10000)

		diff_attr_list.max_hp = total_attr_list.max_hp * select_equip_legend_list["equip_per_max_hp"] / 10000
								+ select_equip_attr_list.max_hp *
								(LEGEND_EQUIP_PER_TYPE["equip_per_max_hp"] / 10000 + 1 + select_equip_legend_list["equip_per_max_hp"] / 10000)
		final_attr_list.gong_ji = final_attr_list.gong_ji + diff_attr_list.gong_ji
		final_attr_list.fang_yu = final_attr_list.fang_yu + diff_attr_list.fang_yu
		final_attr_list.max_hp = final_attr_list.max_hp + diff_attr_list.max_hp
		final_attr_list.ming_zhong = final_attr_list.ming_zhong + select_equip_attr_list.ming_zhong
		final_attr_list.shan_bi = final_attr_list.shan_bi + select_equip_attr_list.shan_bi
		final_attr_list.bao_ji = final_attr_list.bao_ji + select_equip_attr_list.bao_ji
		final_attr_list.jian_ren = final_attr_list.jian_ren + select_equip_attr_list.jian_ren
		final_attr_list.per_jingzhun = final_attr_list.per_jingzhun + select_equip_attr_list.per_jingzhun
		final_attr_list.per_baoji = final_attr_list.per_baoji + select_equip_attr_list.per_baoji
		final_attr_list.per_mianshang = final_attr_list.per_mianshang + select_equip_attr_list.per_mianshang
		final_attr_list.per_pofang = final_attr_list.per_pofang + select_equip_attr_list.per_pofang
		final_attr_list.goddess_gongji = final_attr_list.goddess_gongji + select_equip_attr_list.goddess_gongji
		if not is_single_fight_pwoer then
			capability = CommonDataManager.GetCapabilityCalculation(final_attr_list) + vo.other_capability
		else
			select_equip_attr_list.gong_ji = diff_attr_list.gong_ji
			select_equip_attr_list.fang_yu = diff_attr_list.fang_yu
			select_equip_attr_list.max_hp = diff_attr_list.max_hp
			capability = CommonDataManager.GetCapabilityCalculation(select_equip_attr_list)
		end
	end
	for k, v in pairs(LEGEND_EQUIP_PER_TYPE) do
		LEGEND_EQUIP_PER_TYPE[k] = 0
		select_equip_legend_list[k] = 0
		grid_equip_legend_list[k] = 0
	end
	return capability
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

function EquipData:CheckIsAutoEquip(item_id, the_index)
	local cur_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == cur_cfg then
		return false
	end

	local sub_type = cur_cfg.sub_type

	if sub_type == 202 then --婚戒
		return true
	end

	--情饰装备特殊处理
	if EquipData.IsMarryEqType(sub_type) then
		local qy_dess_equip_list = MarryEquipData.Instance:GetMarryEquipInfo()
		local fight_power = CommonDataManager.GetCapability(cur_cfg)

		local dress_fight_power = 0
		local qy_dess_index = MarryEquipData.GetMarryEquipIndex(sub_type)
		local qy_dess_equip_info = qy_dess_equip_list[qy_dess_index]
		if qy_dess_equip_info ~= nil then
			local dress_item_cfg = ItemData.Instance:GetItemConfig(qy_dess_equip_info.item_id)
			dress_fight_power = dress_item_cfg and CommonDataManager.GetCapability(dress_item_cfg) or 0
		end

		if cur_cfg.limit_sex == GameVoManager.Instance:GetMainRoleVo().sex then
			local marry_info = MarryEquipData.Instance:GetMarryInfo()
			if cur_cfg.limit_level <= marry_info.marry_level then
				return fight_power > dress_fight_power
			end
		end
		return false
	end

	local index = sub_type%10
	local equip_data = self:GetDataList()
	local new_equip_data = ItemData.Instance:GetGridData(the_index)
	local new_equip_power = self:GetEquipLegendFightPowerByData(new_equip_data)

	return new_equip_power - GameVoManager.Instance:GetMainRoleVo().capability >= COMMON_CONSTS.COMPARE_MIN_POWER
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

function EquipData:SetMinEternityLevel(min_eternity_level)
	self.min_eternity_level = min_eternity_level or 0
	local huixinyiji = ForgeData.Instance:GetEternitySuitHXYJPerByLevel(self.min_eternity_level)
	PlayerData.Instance:SetAttr("huixinyiji", huixinyiji)
end

function EquipData:GetMinEternityLevel()
	return self.min_eternity_level
end

function EquipData:SetMinLianhunLevel(min_lianhun_level)
	self.min_lianhun_level = min_lianhun_level or 0
end

function EquipData:GetMinLianhunLevel()
	return self.min_lianhun_level
end

function EquipData:SetUseEternityLevel(use_eternity_level)
	self.use_eternity_level = use_eternity_level or 0
end

function EquipData:GetUseEternityLevel()
	return self.use_eternity_level
end

function EquipData:GetOrderEquip(prof, order, sub_type, color)
	local cfg = self.equip_cfg_list[prof]
	if cfg and cfg[order] and cfg[order][sub_type] then
		return cfg[order][sub_type][color]
	end
	cfg = self.equip_cfg_list[5]
	if cfg and cfg[order] and cfg[order][sub_type] then
		return cfg[order][sub_type][color]
	end

	return nil
end