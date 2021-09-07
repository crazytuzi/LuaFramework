RuneData = RuneData or BaseClass()
--百分比属性表
RuneData.PercentList = {
	["gongji"] = false,
	["fangyu"] = false,
	["baoji"] = false,
	["shanbi"] = false,
	["maxhp"] = false,
	["mingzhong"] = false,
	["jianren"] = false,
	["ignore_fangyu"] = false,
	--以下百分比需换算
	["all_percent"] = true,
	["toukui_percent"] = true,
	["yifu_percent"] = true,
	["kuzi_percent"] = true,
	["xiezi_percent"] = true,
	["hushou_percent"] = true,
	["xianglian_percent"] = true,
	["wuqi_percent"] = true,
	["yaodai_percent"] = true,
}

--防具索引列表
RuneData.FJIndexList = {
	GameEnum.EQUIP_INDEX_TOUKUI,
	GameEnum.EQUIP_INDEX_YIFU,
	GameEnum.EQUIP_INDEX_KUZI,
	GameEnum.EQUIP_INDEX_XIEZI,
	GameEnum.EQUIP_INDEX_YAODAI,
}

function RuneData:__init()
	if RuneData.Instance then
		print_error("[RuneData] Attemp to create a singleton twice !")
	end
	RuneData.Instance = self
	local rune_system_cfg = ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto") or {}

	self.rune_attr_cfg = {}
	self.real_id_list_cfg = {}
	self.real_id_cfg = {}
	self.rune_fetch_cfg = {} 
	self.fuwen_zhuling_grade_cfg = {} 

	-- self.rune_attr_cfg = ListToMapList(rune_system_cfg.rune_attr, "types", "quality")
	-- self.real_id_list_cfg = ListToMapList(rune_system_cfg.real_id_list, "rune_id")
	-- self.real_id_cfg = ListToMap(rune_system_cfg.real_id_list, "quality", "type")
	-- self.rune_fetch_cfg = ListToMapList(rune_system_cfg.rune_fetch,"rune_id")
	-- self.fuwen_zhuling_grade_cfg = ListToMap(rune_system_cfg.fuwen_zhuling, "index", "grade")


	-- self:GetRuneSystemCfg().rune_slot_open = rune_system_cfg.rune_slot_open or {}
	-- self:GetRuneSystemCfg().rune_compose = rune_system_cfg.rune_compose or {}
	-- self:GetRuneSystemCfg().compose_show = rune_system_cfg.compose_show or {}
	-- self:GetRuneSystemCfg().other[1] = rune_system_cfg.other[1] or {}
	-- self.awaken_type = rune_system_cfg.awaken_type or {}
	-- self:GetRuneSystemCfg().awaken_limit = rune_system_cfg.awaken_limit or {}
 	-- self.awaken_item = rune_system_cfg.other or {}
 	-- self:GetRuneSystemCfg().awaken_cost = rune_system_cfg.awaken_cost or {}
 	-- self:GetRuneSystemCfg().fuwen_zhuling_slot = rune_system_cfg.fuwen_zhuling_slot or {}

 	

	self.bag_list = {}
	self.treasure_list = {}
	self.baoxiang_list = {}

	self.pass_layer = 0
	self.rune_jinghua = 0
	self.rune_suipian = 0
	self.old_magic_crystal = 0
	self.magic_crystal = 0
	self.suipian_list = {}
	self.next_free_xunbao_timestamp = 0
	self.rune_slot_open_flag_list = {}
	self.free_xunbao_times = 0
	self.is_need_recalc = 0
	self.awaken_seq = 0
	self.rune_awaken_times = 0

	self.slot_list = {}
	self.have_attr_list = {}

	self.rune_list = {}

	self.num_list = {}
	self:SetRuneList()

	self.baoxiang_id = 0

	self.red_point_list = {
		["Inlay"] = false,
		["Treasure"] = false,
		["Compose"] = false,
	}

	self.zhuling_info = {}

	RemindManager.Instance:Register(RemindName.RuneInlay, BindTool.Bind(self.CalcInlayRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAwake, BindTool.Bind(self.CalcAwakeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAnalyze, BindTool.Bind(self.CalcAnalyzeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneTreasure, BindTool.Bind(self.CalcTreasureRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneCompose, BindTool.Bind(self.CalcComposeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneExchange, BindTool.Bind(self.CalcExchangeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneJiLian, BindTool.Bind(self.CalcJiLianRedPoint, self))

	self.item_change_callback = BindTool.Bind(self.ItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	--觉醒用
	self.cell_index = 0


end

function RuneData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RuneInlay)
	RemindManager.Instance:UnRegister(RemindName.RuneAwake)
	RemindManager.Instance:UnRegister(RemindName.RuneAnalyze)
	RemindManager.Instance:UnRegister(RemindName.RuneTreasure)
	RemindManager.Instance:UnRegister(RemindName.RuneCompose)
	RemindManager.Instance:UnRegister(RemindName.RuneExchange)
	RemindManager.Instance:UnRegister(RemindName.RuneJiLian)

	RuneData.Instance = nil
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function RuneData:GetCommonAwakenItemID()
	if self:GetRuneSystemCfg().awaken_cost then
		return self:GetRuneSystemCfg().awaken_cost[1].common_awaken_item.item_id 
	end

	return 0
end

function RuneData:GetAwakenCostInfo()
	return self:GetRuneSystemCfg().awaken_cost
end


function RuneData:GetRuneSystemCfg()
	return ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto") or {}
end

function RuneData:GetRuneAttrCfg()
	local rune_system_cfg = self:GetRuneSystemCfg()
	if nil == next(self.rune_attr_cfg) then
		self.rune_attr_cfg = ListToMapList(rune_system_cfg.rune_attr, "types", "quality")
	end
	return self.rune_attr_cfg
end

function RuneData:GetRealIdListCfg()
	local rune_system_cfg = self:GetRuneSystemCfg()
	--next() 是空表的时候会返回一个nil
	if  nil == next(self.real_id_list_cfg) then
		self.real_id_list_cfg = ListToMapList(rune_system_cfg.real_id_list, "rune_id")
	end
	return self.real_id_list_cfg
end

function RuneData:GetRealIdCfg()
	local rune_system_cfg = self:GetRuneSystemCfg()
	if nil == next(self.real_id_cfg) then
		self.real_id_cfg = ListToMap(rune_system_cfg.real_id_list, "quality", "type")
	end
	return self.real_id_cfg
end

function RuneData:GetRuneFetchCfg()
	local rune_system_cfg = self:GetRuneSystemCfg()
	if nil == next(self.rune_fetch_cfg) then
		self.rune_fetch_cfg = ListToMapList(rune_system_cfg.rune_fetch,"rune_id")
	end
	return self.rune_fetch_cfg
end


function RuneData:GetFuWenZhuLingGrageCfg()
	local rune_system_cfg = self:GetRuneSystemCfg()
	if nil == next(self.fuwen_zhuling_grade_cfg) then
		self.fuwen_zhuling_grade_cfg = ListToMap(rune_system_cfg.fuwen_zhuling, "index", "grade")
	end
	return self.fuwen_zhuling_grade_cfg
end

function RuneData:GetAwakenTypeInfoByIndex(index)
	local awaken_type = self:GetRuneSystemCfg().awaken_type
	if nil == awaken_type and awaken_type then
		return
	end
	if awaken_type[index] then
		return awaken_type[index]
	else
		return {}
	end
end

function RuneData:GetIsPropertyByIndex(index)
	local data = self:GetAwakenTypeInfoByIndex(index)
	if data then
		return data.is_property
	else
		return 0
	end
end

function RuneData:SetAwakenTypeIndex(index)
	self.awaken_type_index = index
end

function RuneData:GetAwakenTypeIndex()
	return self.awaken_type_index
end


function RuneData:GetAwakenLimitByLevel(level)
	if nil == self:GetRuneSystemCfg().awaken_limit then
		return
	end
	local data = nil
	for k,v in pairs(self:GetRuneSystemCfg().awaken_limit) do
		if v.max_level >= level and v.min_level <= level then
			data = v
			break
		end
	end
	return data
end

function RuneData:GetNextLimitLayer(level)
	for k,v in pairs(self:GetRuneSystemCfg().awaken_limit) do
	 	if level < v.min_level then
	 		return v.min_level or 0
	 	end
	end 
end

function RuneData:SetCellIndex(value)
	if 1 > value then
		value = 1
	end
	self.cell_index = value
end

function RuneData:GetCellIndex()
	return self.cell_index
end

function RuneData:ItemDataChange(change_item_id)
	if change_item_id ~= self:GetRuneSystemCfg().other[1].xunbao_consume_itemid then
		return
	end

	RemindManager.Instance:Fire(RemindName.RuneTreasure)
end

--是否百分比属性
function RuneData:IsPercentAttr(key)
	return RuneData.PercentList[key]
end

--获取对应等级的符文属性
function RuneData:GetAttrInfo(quality, types, level)
	local attr_info = {}
	local rune_attr_cfg = self:GetRuneAttrCfg()
	quality = quality or -1
	types = types or -1
	level = level or 0
	if nil == rune_attr_cfg[types] or nil == rune_attr_cfg[types][quality] then
		return attr_info
	end
	return rune_attr_cfg[types][quality][level] or {}
end

function RuneData:GetOtherCfg()
	return self:GetRuneSystemCfg().other[1]
end

function RuneData:GetRuneMaxLevel()
	return self:GetRuneSystemCfg().other[1].rune_level_max or 0
end

--获取对应的物品id
function RuneData:GetRealId(quality, types)
	local item_id = 0
	local real_id_cfg = self:GetRealIdCfg()
	quality = quality or -1
	types = types or -1
	if real_id_cfg[quality] then
		local data = real_id_cfg[quality][types]
		if data then
			item_id = data.rune_id or 0
		end
	end
	return item_id
end

--获取对应品质和类型
function RuneData:GetQualityTypeByItemId(item_id)
	local quality = -1
	local types = -1
	local seq = -1
	local data = self:GetRealIdListCfg()[item_id]
	if data and data[1] then
		quality = data[1].quality or -1
		types  = data[1].type or -1
		seq = data[1].seq or -1
	end
	return quality, types, seq
end

--根据itemID获取power
function RuneData:GetRuneFetchPower(item_id)
	local rune_system_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto").rune_fetch, "rune_id")
	if rune_system_cfg then
		return rune_system_cfg[item_id]
	end
end

--获取符文名字
function RuneData:GetRuneNameByItemId(item_id)
	local name = ""
	local data = self:GetRealIdListCfg()[item_id]
	if data and data[1]	then
		name = data[1].fu_name
	end
	return name
end

--设置其他信息
function RuneData:SetOtherInfo(info)
	self.pass_layer = info.pass_layer                                 	-- 层数
	self.rune_jinghua = info.rune_jinghua								-- 精华
	self.rune_suipian = info.rune_suipian							    -- 碎片
	self.old_magic_crystal = self.magic_crystal 						-- 旧的水晶数量
	self.magic_crystal = info.magic_crystal								-- 水晶
	self.suipian_list = info.suipian_list								-- 寻宝获得碎片
	self.next_free_xunbao_timestamp = info.next_free_xunbao_timestamp	-- 下次免费时间戳
	local rune_slot_open_flag = info.rune_slot_open_flag				-- 符文槽开启标记 （0-7）  符文合成开启标记（15）
	self.rune_slot_open_flag_list = bit:d2b(rune_slot_open_flag)
	self.free_xunbao_times = info.free_xunbao_times						-- 免费寻宝次数
	self.rune_awaken_times = info.rune_awaken_times						-- 当前觉醒次数
end

function RuneData:GetAwakenTimes()
	return self.rune_awaken_times
end

--获取下次免费寻宝刷新时间
function RuneData:GetNextFreeXunBaoTimestamp()
	return self.next_free_xunbao_timestamp
end

--获取可免费寻宝的次数
function RuneData:GetFreeTimes()
	return self.free_xunbao_times
end

--获取现有的精华
function RuneData:GetJingHua()
	return self.rune_jinghua
end

--获取现有的魔晶
function RuneData:GetMagicCrystal()
	return self.magic_crystal
end

--获取已通过的层数
function RuneData:GetPassLayer()
	return self.pass_layer
end

--获取现有碎片数量
function RuneData:GetSuiPian()
	return self.rune_suipian
end

function RuneData:SetPlayTreasureAni(state)
	self.is_stop_play_ani = state
end

function RuneData:IsStopPlayAni()
	return self.is_stop_play_ani
end

--根据物品id获取需要通关的层数
function RuneData:GetPassLayerByItemId(item_id)
	local pass_layer = 0
	local data = self:GetRuneFetchCfg()[item_id]
	if data then
       pass_layer=data.in_layer_open or 0
	end
	return pass_layer
end

--设置可在总览内展示符文列表（根据层数划分，只获取1级的符文）
function RuneData:SetRuneList()
	local function AddTbl(data)
		local temp_data = {}
		temp_data.item_id = data.rune_id
		temp_data.in_layer_open = data.in_layer_open
		temp_data.convert_consume_rune_suipian = data.convert_consume_rune_suipian
		table.insert(self.rune_list, temp_data)
	end
	local rune_system_cfg = ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto") or {}
	local rune_fetch_cfg = rune_system_cfg.rune_fetch or {}
	for k, v in ipairs(rune_fetch_cfg) do
		if v.pandect > 0 then
			AddTbl(v)
		end
	end
	for k, v in ipairs(self.rune_list) do
		local item_id = v.item_id
		local quality, types, seq = self:GetQualityTypeByItemId(item_id)
		local rune_fetch_power = self:GetRuneFetchPower(item_id)
		local base_data = self:GetAttrInfo(quality, types, 1)
		v.quality = base_data.quality or -1
		v.type = base_data.types or -1
		v.seq = seq
		v.level = base_data.level
		-- v.attr_type_0 = base_data.attr_type_0
		-- v.add_attributes_0 = base_data.add_attributes_0
		-- v.attr_type_1 = base_data.attr_type_1
		-- v.add_attributes_1 = base_data.add_attributes_1
		v.attr_type1 = base_data.attr_type1
		v.attr_value1 = base_data.attr_value1
		v.attr_type2 = base_data.attr_type2
		v.attr_value2 = base_data.attr_value2
		v.power = rune_fetch_power.power
		v.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
	end
	table.sort(self.rune_list, SortTools.KeyLowerSorters("in_layer_open", "type", "quality") )
end

--根据层数获取已开启的符文列表(层数为空时默认获取全部)
function RuneData:GetRuneListByLayer(layer)
	local temp_list = {}
	if layer then
		for k, v in ipairs(self.rune_list) do
			if layer >= v.in_layer_open then
				table.insert(temp_list, v)
			end
		end
	else
		temp_list = self.rune_list
	end
	table.sort(temp_list, SortTools.KeyLowerSorter("seq"))
	
	return temp_list
end
--根据物品id获取符文数据(只能获取在符文总览下展示的符文)
function RuneData:GetRuneDataByItemId(item_id)
	local temp_data = {}
	for k, v in ipairs(self.rune_list) do
		if item_id == v.item_id then
			temp_data = v
			break
		end
	end
	return temp_data
end

local function SortExChangeList(a,b)
	local order_a = 100000
	local order_b = 100000
	if a.quality > b.quality then
		order_a = order_a + 10000
	elseif a.quality < b.quality then
		order_b = order_b + 10000
	end

	if a.type > b.type then
		order_a = order_a - 1000
	elseif a.type < b.type then
		order_b = order_b - 1000
	end
	return order_a > order_b
end

--获取兑换列表
function RuneData:GetExchangeList()
	-- local time1 = UnityEngine.Time.realtimeSinceStartup * 1000
	local exchange_list = {}
	for k, v in ipairs(self.rune_list) do
		if v.convert_consume_rune_suipian > 0 then
			table.insert(exchange_list, v)
		end
	end
	table.sort( exchange_list, SortExChangeList)
	return exchange_list
end

--改变镶嵌红点
function RuneData:CalcInlayRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	if self:CalcAwakeRedPoint() > 0 then
		return 1
	end
	local flag = 0
	-- local time1 = UnityEngine.Time.realtimeSinceStartup * 1000
	--先判断是否存在可升级的
	for i = 1, #self:GetRuneSystemCfg().rune_slot_open do
		local slot_data = self.slot_list[i]
		if slot_data and next(slot_data) ~= nil then
			--判断是否有可升级的格子
			if slot_data.quality ~= nil and slot_data.quality >= 0 then
				local uplevel_need_jinghua = slot_data.uplevel_need_jinghua
				local now_level = slot_data.level
				if now_level < self:GetRuneMaxLevel() and uplevel_need_jinghua > 0 and self.rune_jinghua >= uplevel_need_jinghua then
					flag = 1
					return flag
				end
			end
		end
	end

	if flag == 0 then
		for k, v in ipairs(self.bag_list) do
		 
			if v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				--是否存在可替换的符文
				for i = 1, #self:GetRuneSystemCfg().rune_slot_open do
					local slot_data = self.slot_list[i]
					if slot_data and slot_data.type == v.type and slot_data.quality < v.quality then
						flag = 1
						return flag
					end
				end
			end

			if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				--是否存在可镶嵌的符文
				for i = 1, #self:GetRuneSystemCfg().rune_slot_open do
					local slot_data = self.slot_list[i]
					local is_lock = self.rune_slot_open_flag_list[32-(i-1)] == 0
					--判断是否存在未镶嵌的格子
					if slot_data and not is_lock and slot_data.quality == -1 then
						flag = 1
						return flag
					end
				end
			end
		end
	end
	return flag
end

function RuneData:CalcAwakeRedPoint()
	local flag = 0
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return flag
	end
	local num = ItemData.Instance:GetItemNumInBagById(self:GetCommonAwakenItemID())

	local index = self:GetCurrentSelect()
	local solt_list = RuneData.Instance:GetSlotList()
	local show_red_point = false
	if nil == solt_list[index] or 0 == solt_list[index].level then
		show_red_point = false
	else
		show_red_point = true
	end

	if num > 0 and show_red_point then
		flag = 1
	end	
	return flag
end

--改变分解红点
function RuneData:CalcAnalyzeRedPoint()
	local flag = 0
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return flag
	end
	--判断是否有符文精华可分解
	for k, v in ipairs(self.bag_list) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			flag = 1
			return flag
		end
	end
	return flag
end

--改变铭刻红点
function RuneData:CalcTreasureRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	local flag = 0
	--先判断是否有免费次数
	if self.free_xunbao_times > 0 then
		flag = 1
	end

	--再判断是否有足够材料可寻宝
	if flag == 0 then
		local need_item_id = self:GetRuneSystemCfg().other[1].xunbao_consume_itemid
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		local min_need_num = self:GetRuneSystemCfg().other[1].xunbao_one_consume_num
		if num >= min_need_num then
			flag = 1
		end
	end
	return flag
end

--改变合成红点
function RuneData:CalcComposeRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	if self:GetRuneSystemCfg().other[1] and self.pass_layer < self:GetRuneSystemCfg().other[1].rune_compose_need_layer then
		return 0
	end
	return self:IsComPoseRedPoint() and 1 or 0
end

-- 计算兑换红点
function RuneData:CalcExchangeRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	if ClickOnceRemindList[RemindName.RuneExchange] and ClickOnceRemindList[RemindName.RuneExchange] == 0 then
		return 0
	end
	local sui_pian = self:GetSuiPian()
	return sui_pian >= 50 and 1 or 0
end

-- 计算祭炼红点
function RuneData:CalcJiLianRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune_zhuling") then
		return 0
	end

	if self.zhuling_info.zhuling_slot_bless and self.zhuling_info.run_zhuling_list then
		for i = 1, 10 do
			if self.zhuling_info.run_zhuling_list[i].grade < 200 and self.zhuling_info.zhuling_slot_bless > 0 then
				return 1
			end
		end
	end
	if ClickOnceRemindList[RemindName.RuneJiLian] and ClickOnceRemindList[RemindName.RuneJiLian] == 1 then
		return 1
	end
	return 0
end

--背包物品排序
local function BagSort(a, b)
	if a.type ~= b.type and (a.type == GameEnum.RUNE_JINGHUA_TYPE or b.type == GameEnum.RUNE_JINGHUA_TYPE) then				--符文精华（直接放在最后）
		return not (a.type == GameEnum.RUNE_JINGHUA_TYPE)
	end
	if a.is_repeat == b.is_repeat then
		if a.quality == b.quality then
			if a.type == b.type then
				return a.level > b.level
			end
			return a.type > b.type
		end
		return a.quality > b.quality
	end
	return not a.is_repeat
end

--设置符文背包
function RuneData:SetBagList(list)
	self.bag_list = {}
	for k, v in ipairs(list) do
		local data = {}
		local quality = v.quality
		local types = v.type
		if quality >= 0 then
			data.index = v.index
			data.quality = quality
			data.type = types
			data.level = v.level
			data.is_repeat = false
			local slot_data = self:GetAttrInfo(data.quality, data.type, data.level)
			if self:IsRepeat(slot_data) then
				data.is_repeat = true
			end
			-- data.attr_type_0 = slot_data.attr_type_0
			-- data.add_attributes_0 = slot_data.add_attributes_0
			-- data.attr_type_1 = slot_data.attr_type_1
			-- data.add_attributes_1 = slot_data.add_attributes_1
			data.attr_type1 = slot_data.attr_type1
			data.attr_value1 = slot_data.attr_value1
			data.attr_type2 = slot_data.attr_type2
			data.attr_value2 = slot_data.attr_value2
			data.dispose_fetch_jinghua = slot_data.dispose_fetch_jinghua
			local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
			data.item_id = item_id
		end
		if next(data) then
			table.insert(self.bag_list, data)
		end
	end
	table.sort(self.bag_list, BagSort)
	self:CollatingNum()
end

--改变背包数据
function RuneData:ChangeBagList(list)
	for k, v in ipairs(list) do
		local quality = v.quality
		local types = v.type
		if quality < 0 then
			--减少物品
			for k1, v1 in ipairs(self.bag_list) do
				if v1.index == v.index then
					table.remove(self.bag_list, k1)
					break
				end
			end
		elseif quality >= 0 then
			--增加物品
			local data = {}
			data.index = v.index
			data.quality = quality
			data.type = types
			data.level = v.level
			data.is_repeat = false
			local slot_data = self:GetAttrInfo(data.quality, data.type, data.level)
			if self:IsRepeat(slot_data) then
				data.is_repeat = true
			end
			-- data.attr_type_0 = slot_data.attr_type_0
			-- data.add_attributes_0 = slot_data.add_attributes_0
			-- data.attr_type_1 = slot_data.attr_type_1
			-- data.add_attributes_1 = slot_data.add_attributes_1
			data.attr_type1 = slot_data.attr_type1
			data.attr_value1 = slot_data.attr_value1
			data.attr_type2 = slot_data.attr_type2
			data.attr_value2 = slot_data.attr_value2
			data.dispose_fetch_jinghua = slot_data.dispose_fetch_jinghua
			local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
			data.item_id = item_id
			table.insert(self.bag_list, data)
		end
	end
	table.sort(self.bag_list, BagSort)
	self:CollatingNum()
end

--获取符文物品数量
function RuneData:GetBagNumByItemId(item_id)
	local num = self.num_list[item_id] or 0
	return num
end

--根据index获取背包符文属性
function RuneData:GetBagDataByIndex(index)
	local data_info = {}
	for k, v in ipairs(self.bag_list) do
		if v.index == index then
			data_info = v
			break
		end
	end
	return data_info
end

-- --根据item_id获取背包符文index(默认是找到的第一个)
function RuneData:GetBagIndexByItemId(item_id, data)
	local index = -1
	for k, v in ipairs(self.bag_list) do
		if v.item_id == item_id then
			if data ~= nil and data[v.index] == nil then
				index = v.index
				break
			elseif data == nil then
				index = v.index
				break	
			end
		end
	end
	return index
end

function RuneData:GetBagList()
	local temp_list = self.bag_list
	-- table.sort(temp_list, SortTools.KeyUpperSorters("quality","level","type"))
	return temp_list
end

--获得分解列表
function RuneData:GetAnalyList()
	local analy_list = {}
	for k, v in ipairs(self.bag_list) do
		table.insert(analy_list, v)
	end
	table.sort(analy_list, SortTools.KeyUpperSorters("quality", "type", "level"))
	return analy_list
end

function RuneData:GetTreasureList()
	return self.treasure_list
end

--设置寻宝列表
function RuneData:SetTreasureList(list)
	self.treasure_list = {}
	local count = 0
	for k, v in ipairs(list) do
		count = count + 1
		local data = {}
		local item_id = self:GetRealId(v.quality, v.type)
		data.item_id = item_id
		data.num = 1
		data.is_bind = 1
		table.insert(self.treasure_list, data)
	end
	--添加虚拟碎片物品
	local suipian_count = 0
	for k, v in ipairs(self.suipian_list) do
		suipian_count = suipian_count + v
	end
	local suipian_data = {}
	suipian_data.item_id = ResPath.CurrencyToIconId.rune_suipian
	suipian_data.num = suipian_count
	suipian_data.is_bind = 1
	table.insert(self.treasure_list, suipian_data)

	--添加虚拟水晶物品
	if self.pass_layer < self:GetRuneSystemCfg().other[1].rune_compose_need_layer then
		--未达到通关层数不处理
		return
	end
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	local one_mojing_num = self:GetRuneSystemCfg().other[1].xunbao_one_magic_crystal
	mojing_data.num = one_mojing_num * count
	mojing_data.is_bind = 1
	table.insert(self.treasure_list, mojing_data)
end

function RuneData:GetBaoXiangList()
	return self.baoxiang_list
end

--设置宝箱列表
function RuneData:SetBaoXiangList(list)
	self.baoxiang_list = {}
	local count = 0
	for k, v in ipairs(list) do
		count = count + 1
		local data = {}
		local item_id = self:GetRealId(v.quality, v.type)
		data.item_id = item_id
		data.num = 1
		data.is_bind = 1
		table.insert(self.baoxiang_list, data)
	end

	--添加虚拟水晶物品
	if self.old_magic_crystal == self.magic_crystal then
		--数量没变化不处理
		return
	end
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	local one_mojing_num = self:GetRuneSystemCfg().other[1].xunbao_one_magic_crystal
	mojing_data.num = one_mojing_num * count
	mojing_data.is_bind = 1
	table.insert(self.baoxiang_list, mojing_data)
end

--设置已有属性列表
function RuneData:SetHaveAttrList()
	self.have_attr_list = {}
	for k, v in ipairs(self.slot_list) do
		local slot_data = self:GetAttrInfo(v.quality, v.type, v.level)
		if next(slot_data) then
			--local attr_type_1 = slot_data.attr_type_0
			local attr_type1 = slot_data.attr_type1
			if "" ~= attr_type1 and not self.have_attr_list[attr_type1] then
				self.have_attr_list[attr_type1] = slot_data.attr_value1
			end
			--local attr_type_2 = slot_data.attr_type_1
			local attr_type2 = slot_data.attr_type2
			if "" ~= attr_type2 and not self.have_attr_list[attr_type2] then
				self.have_attr_list[attr_type2] = slot_data.attr_value2
			end
		end
	end
end

--刷新背包物品参数(是否有重复的属性, slot_index存在的话直接剔除相关属性)
function RuneData:ResetBagList(slot_index)
	local dis_attr_type_list = {}
	if slot_index then
		local slot_data = self:GetSlotDataByIndex(slot_index)
		if next(slot_data) then
			dis_attr_type_list[slot_data.attr_type1] = true
			if "" ~= slot_data.attr_type2 then
				dis_attr_type_list[slot_data.attr_type2] = true
			end
		end
	end
	for k, v in ipairs(self.bag_list) do
		if self:IsRepeat(v, dis_attr_type_list) then
			v.is_repeat = true
		else
			v.is_repeat = false
		end
	end
	table.sort(self.bag_list, BagSort)
end

--设置符文槽列表信息
function RuneData:SetSlotList(list)
	self.slot_list = {}
	for k, v in ipairs(list) do
		local data = {}
		if v.quality >= 0 then
			local base_data = self:GetAttrInfo(v.quality, v.type, v.level)
			data.quality = base_data.quality
			data.type = base_data.types
			data.level = base_data.level
			data.uplevel_need_jinghua = base_data.uplevel_need_jinghua
			--data.attr_type_0 = base_data.attr_type_0
			--data.add_attributes_0 = base_data.add_attributes_0
			-- data.attr_type_1 = base_data.attr_type_1
			-- data.add_attributes_1 = base_data.add_attributes_1
			data.attr_type1 = base_data.attr_type1
			data.attr_value1 = base_data.attr_value1
			data.attr_type2 = base_data.attr_type2
			data.attr_value2 = base_data.attr_value2
			data.power = base_data.power
			data.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
		else
			data.quality = v.quality
			data.type = v.type
			data.level = v.level
			data.uplevel_need_jinghua = -1
			-- data.attr_type_0 = -1
			-- data.add_attributes_0 = -1
			-- data.attr_type_1 = -1
			-- data.add_attributes_1 = -1
			data.attr_type1 = ""
			data.attr_value1 = -1
			data.attr_type2 = ""
			data.attr_value2 = -1
			data.power = 0
			data.dispose_fetch_jinghua = -1
		end
		table.insert(self.slot_list, data)
	end
	self:SetHaveAttrList()
	self:ResetBagList()
end

function RuneData:GetSlotList()
	return self.slot_list
end

--判断是否有重复属性(dis_attr_type_list为不考虑的属性列表)
function RuneData:IsRepeat(data, dis_attr_type_list)
	local is_repeat = false
	if not data or not next(data) then
		return is_repeat
	end
	dis_attr_type_list = dis_attr_type_list or {}

	local attr_type1 = data.attr_type1
	local attr_type2 = data.attr_type2
	if dis_attr_type_list[attr_type1] then
		attr_type1 = ""
	end
	if dis_attr_type_list[attr_type2] then
		attr_type2 = ""
	end
	if self.have_attr_list[attr_type1] or self.have_attr_list[attr_type2] then
		is_repeat = true
	end
	return is_repeat
end

function RuneData:GetSlotDataByIndex(index)			-- 1 开始
	return self.slot_list[index] or {}
end

--获取该格子是否锁定
function RuneData:GetIsLockByIndex(index)			-- 1 开始
	local flag = self.rune_slot_open_flag_list[32-(index-1)] or 0
	return flag == 0
end

--获取槽开启的层级
function RuneData:GetSlotOpenLayerByIndex(index)			-- 1 开始
	local layer = 0
	for k, v in ipairs(self:GetRuneSystemCfg().rune_slot_open) do
		if v.open_rune_slot == index-1 then
			layer = v.need_pass_layer
			break
		end
	end
	return layer
end

--通过物品ID获取所需材料
function RuneData:GetMaterialByItemId(item_id)
	item_id = item_id or 0
	local tbl = {}
	for k,v in pairs(self:GetRuneSystemCfg().rune_compose) do
		if v.get_rune_id == item_id then
			tbl = v
			break
		end
	end
	return tbl
end

--通过类型获得合成显示配置
function RuneData:GetComposeShowByType(index)
	index = index or 0
	local tbl = {}
	for k,v in pairs(self:GetRuneSystemCfg().compose_show) do
		if v.type == index then
			tbl = v
			break
		end
	end
	return tbl
end

--获得合成显示配置
function RuneData:GetComposeShow()
	return self:GetRuneSystemCfg().compose_show
end

--获得合成红点
function RuneData:GetComposeReminder()
	local flag = false
	local rune_compose = self:GetRuneSystemCfg().rune_compose
	if self.pass_layer < self:GetRuneSystemCfg().other[1].rune_compose_need_layer then
		return flag
	end
	local data = {}
	for i = 1, 3 do
		if rune_compose["rune" .. i .. "_id"] then
			local item = rune_compose["rune" .. i .. "_id"]
			if data[item] == nil then
				data[item] = self.num_list[rune_compose["rune" .. i .. "_id"]]
			end
		end
		self["NeedNum" .. i] = 1
		self["HasNum" .. i] = 0
		if data[rune_compose["rune" .. i .. "_id"]] then
			if data[rune_compose["rune" .. i .. "_id"]] >= self["NeedNum" .. i] then
				self["HasNum" .. i] = self["NeedNum" .. i]
				data[rune_compose["rune" .. i .. "_id"]] = data[rune_compose["rune" .. i .. "_id"]] - 1
				data[rune_compose["rune" .. i .. "_id"]] = data[rune_compose["rune" .. i .. "_id"]] < 0 and 0 or data[rune_compose["rune" .. i .. "_id"]]
			end
		end
	end

	local has_num1 = self.HasNum1 or 0
	local has_num2 = self.HasNum2 or 0
	local has_num3 = self.HasNum3 or 0
	if has_num1 > 0 and has_num2 > 0 and has_num3 > 0 then
		flag = true
	end

	return flag
end

-- 对符文数量进行排序整理
function RuneData:CollatingNum()
	self.num_list = {}
	for k, v in ipairs(self.bag_list) do
		if nil == self.num_list[v.item_id] then
			self.num_list[v.item_id] = 1
		else
			self.num_list[v.item_id] = self.num_list[v.item_id] + 1
		end
	end
end

--记录符文宝箱最后使用item_id
function RuneData:SetBaoXiangId(item_id)
	self.baoxiang_id = item_id
end

function RuneData:GetBaoXiangId()
	return self.baoxiang_id
end

function RuneData:CalcAttr(attr_info, attr_type, add_attributes)
	if attr_info[attr_type] then
		attr_info[attr_type] = attr_info[attr_type] + add_attributes
	end
end

function RuneData:GetBagHaveRuneGift()
	for i = 23400, 23417 do
		if ItemData.Instance:GetItemNumInBagById(i) > 0 then
			return true
		end
	end
	return false
end

function RuneData:SetAwakenList(list)
	self.awaken_list = list
end

function RuneData:SetAwakenSeq(awaken_seq)
	self.awaken_seq = awaken_seq
end

function RuneData:GetAwakenSeq()
	return self.awaken_seq
end

function RuneData:SetIsNeedRecalc(is_need_recalc)
	self.is_need_recalc = is_need_recalc
end

function RuneData:GetIsNeedRecalc()
	return self.is_need_recalc
end

function RuneData:GetAwakenAttrInfoByIndex(index)
	--local awaken_attr_info = nil
	if nil == self.awaken_list then
		return nil
	end
	-- for k, v in ipairs(self.awaken_list) do
	-- 	if k == index then
	-- 		awaken_attr_info = v
	-- 		break
	-- 	end
	-- end
	if self.awaken_list[index] then
		return self.awaken_list[index]
	end
	return nil
end

function RuneData:SetCurrentSelect(index)
	index = index or 0
	if index == 0 then
		index = 1 
	end
	self.current_select = index 
end

function RuneData:GetCurrentSelect()
	return self.current_select or 1
end

function RuneData:SetRuneZhulingInfo(protocol)
	self.zhuling_info.zhuling_slot_bless = protocol.zhuling_slot_bless
	self.zhuling_info.run_zhuling_list = protocol.run_zhuling_list
end

function RuneData:SetRuneZhulingSlotBless(zhuling_slot_bless)
	self.zhuling_info.zhuling_slot_bless = zhuling_slot_bless
end

function RuneData:GetRuneZhulingInfo()
	return self.zhuling_info
end

function RuneData:GetRuneZhulingSlotCfg()
	return self:GetRuneSystemCfg().fuwen_zhuling_slot
end

function RuneData:GetRuneZhulingGradeCfg(index, grade)
	local fuwen_zhuling_grade_cfg = self:GetFuWenZhuLingGrageCfg()
	if fuwen_zhuling_grade_cfg[index] and fuwen_zhuling_grade_cfg[index][grade] then
		return fuwen_zhuling_grade_cfg[index][grade]
	end
end

function RuneData:GetCurOpenLevelSeq()
	local level_list = {}
	for i = 0, 7 do
		local cfg = self:GetRuneZhulingGradeCfg(i, 0)
		level_list[i] = cfg.open_level
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(level_list) do
		local lock_state = RuneData.Instance:GetIsLockByIndex(k + 1)
		if main_role_vo.level < v or lock_state then
			return k + 1
		end 
	end

	return 0
end

-- 八卦-合成-八卦令红点
function RuneData:IsRuneTokenRedPoint(get_rune_id)
	local flag = false
	local item_tab = self:GetMaterialByItemId(get_rune_id)
	if not next(item_tab) then return flag	end

	local num = self:GetBagNumByItemId(item_tab.rune1_id)
	if num and num >= 3 then
		flag = true
	end
	return flag
end

-- 八卦-合成-橙红 红点
function RuneData:IsDoubleRedPoint(i)
	local flag = false
	local compose_show = self:GetComposeShow()
	if not next(compose_show) then return flag end
	for k, v in pairs(compose_show) do
		local is_show = self:IsRuneTokenRedPoint(v.item_id)
		if is_show and v.sub_type == i then
			flag = true
			break
		end
	end
	return flag
end

--八卦-合成标签红点
function RuneData:IsComPoseRedPoint()
	local flag = false
	for i = 1, 2 do
		local is_red = self:IsDoubleRedPoint(i)
		if is_red then
			flag = true
			break
		end
	end
	return flag
end