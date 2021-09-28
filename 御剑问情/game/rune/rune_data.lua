RuneData = RuneData or BaseClass()
--百分比属性表
RuneData.PercentList = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
	[5] = true,
	[6] = false,
	[7] = false,
	[8] = false,
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[13] = true,
}

--防具索引列表
RuneData.FJIndexList = {
	GameEnum.EQUIP_INDEX_TOUKUI,
	GameEnum.EQUIP_INDEX_YIFU,
	GameEnum.EQUIP_INDEX_KUZI,
	GameEnum.EQUIP_INDEX_XIEZI,
	GameEnum.EQUIP_INDEX_HUSHOU,
	GameEnum.EQUIP_INDEX_XIANGLIAN,
	GameEnum.EQUIP_INDEX_WUQI,
	GameEnum.EQUIP_INDEX_JIEZHI,
	GameEnum.EQUIP_INDEX_YAODAI,
	GameEnum.EQUIP_INDEX_JIEZHI_2,
}

function RuneData:__init()
	if RuneData.Instance then
		print_error("[RuneData] Attemp to create a singleton twice !")
	end
	RuneData.Instance = self
	self.cfg_is_init = false

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
	self.rune_jilian_slot_open_list = {}
	self.free_xunbao_times = 0
	self.is_need_recalc = 0
	self.awaken_seq = 0
	self.rune_awaken_times = 0
	self.treasure_open_num = 0

	self.slot_list = {}
	self.have_type_list = {}

	self.rune_list = {}

	self.num_list = {}

	self.baoxiang_id = 0

	self.red_point_list = {
		["Inlay"] = false,
		["Treasure"] = false,
		["Compose"] = false,
	}

	self.zhuling_info = {}

	RemindManager.Instance:Register(RemindName.RuneInlay, BindTool.Bind(self.CalcInlayRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAwake, BindTool.Bind(self.CalcAwakeRedPoint, self))
	RemindManager.Instance:Register(RemindName.SpecialRune, BindTool.Bind(self.CalcSpecialRuneRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneAnalyze, BindTool.Bind(self.CalcAnalyzeRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneTreasure, BindTool.Bind(self.CalcTreasureRedPoint, self))
	RemindManager.Instance:Register(RemindName.RuneCompose, BindTool.Bind(self.CalcComposeRedPoint, self))
    RemindManager.Instance:Register(RemindName.RuneZhuLing, BindTool.Bind(self.CalcZhuLingRedPoint, self))

	self.item_change_callback = BindTool.Bind(self.ItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	--觉醒用
	self.cell_index = 0
	--符文觉醒是否屏蔽动画
	self.is_stop_play_ani = false
end

function RuneData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RuneInlay)
	RemindManager.Instance:UnRegister(RemindName.RuneAwake)
	RemindManager.Instance:UnRegister(RemindName.SpecialRune)
	RemindManager.Instance:UnRegister(RemindName.RuneAnalyze)
	RemindManager.Instance:UnRegister(RemindName.RuneTreasure)
	RemindManager.Instance:UnRegister(RemindName.RuneCompose)
    RemindManager.Instance:UnRegister(RemindName.RuneZhuLing)
	RuneData.Instance = nil
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end
--读取配置表数据
function RuneData:InitCfg()
	if self.cfg_is_init == false then
		self.cfg_is_init = true
		local rune_system_cfg = ConfigManager.Instance:GetAutoConfig("rune_system_cfg_auto") or {}
		self.rune_slot_open_list = rune_system_cfg.rune_slot_open or {}
		self.rune_attr_cfg = ListToMapList(rune_system_cfg.rune_attr, "types", "quality")
		self.real_id_cfg = rune_system_cfg.real_id_list or {}
		self.rune_fetch_cfg = rune_system_cfg.rune_fetch or {}
		self.rune_compose = rune_system_cfg.rune_compose or {}
		self.compose_show = rune_system_cfg.compose_show or {}
		self.other_cfg = rune_system_cfg.other[1] or {}
		self.awaken_type = rune_system_cfg.awaken_type or {}
		self.awaken_limit = rune_system_cfg.awaken_limit or {}
	 	self.awaken_item = rune_system_cfg.other or {}
	 	self.awaken_cost_cfg = rune_system_cfg.awaken_cost or {}
	 	self.exchange_sort_cfg = rune_system_cfg.rune_type_sort or {}
	 	self.fuwen_zhuling_slot_cfg = rune_system_cfg.fuwen_zhuling_slot or {}
	 	self.rune_special_rune_attr = rune_system_cfg.special_rune_attr[1] or {}
	 	self.fuwen_zhuling_grade_cfg = ListToMap(rune_system_cfg.fuwen_zhuling, "index", "grade")
	 	self.jilian_rune_slot_open_cfg = ListToMap(rune_system_cfg.jilian_rune_slot_open, "open_rune_slot")
	 	self.rune_level_open_cfg = rune_system_cfg.rune_level_open					--等级上限
		self:SetRuneList()
	 end
end

function RuneData:GetCommonAwakenItemID()
	self:InitCfg()
	if self.awaken_cost_cfg then
		return self.awaken_cost_cfg[1].common_awaken_item.item_id
	end

	return 0
end

function RuneData:GetJilianRuneOpenLevel(slot)
	if self.jilian_rune_slot_open_cfg[slot] then
		return self.jilian_rune_slot_open_cfg[slot].open_level
	end
	return 0
end

--获取当前符文限制等级
function RuneData:GetRuneLevelLimitInfo(is_next)
	for i = #self.rune_level_open_cfg, 1, -1 do
		if self.rune_level_open_cfg[i].need_rune_tower_layer <= self.pass_layer then
			if is_next then
				return self.rune_level_open_cfg[i+1]
			else
				return self.rune_level_open_cfg[i]
			end
		end
	end
	return nil
end

function RuneData:GetAwakenCostInfo()
	self:InitCfg()
	return self.awaken_cost_cfg
end

function RuneData:GetAwakenTypeInfoByIndex(index)
	self:InitCfg()
	if nil == self.awaken_type then
		return
	end
	local data = nil
	for k,v in pairs(self.awaken_type) do
		if index == k then
			data = v
		end
	end
	return data
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
	self:InitCfg()
	if nil == self.awaken_limit then
		return
	end
	local data = nil
	for k,v in pairs(self.awaken_limit) do
		if v.max_level >= level and v.min_level <= level then
			data = v
			break
		end
	end
	return data
end

function RuneData:GetNextLimitLayer(level)
	self:InitCfg()
	for k,v in pairs(self.awaken_limit) do
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
	if not OpenFunData.Instance:CheckIsHide("rune") then return end
	self:InitCfg()
	if change_item_id ~= self.other_cfg.xunbao_consume_itemid then
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
	self:InitCfg()
	local attr_info = {}
	quality = quality or -1
	types = types or -1
	level = level or 0
	if nil == self.rune_attr_cfg[types] or nil == self.rune_attr_cfg[types][quality] then
		return attr_info
	end
	return self.rune_attr_cfg[types][quality][level] or {}
end

function RuneData:GetOtherCfg()
	self:InitCfg()
	return self.other_cfg
end

function RuneData:GetRuneMaxLevel()
	self:InitCfg()
	return self.other_cfg.rune_level_max or 0
end

--获取对应的物品id
function RuneData:GetRealId(quality, types)
	self:InitCfg()
	local item_id = 0
	quality = quality or -1
	types = types or -1
	for k, v in ipairs(self.real_id_cfg) do
		if quality == v.quality and types == v.type then
			item_id = v.rune_id
			break
		end
	end
	return item_id
end

--获取对应品质和类型
function RuneData:GetQualityTypeByItemId(item_id)
	self:InitCfg()
	local quality = -1
	local types = -1
	for k, v in ipairs(self.real_id_cfg) do
		if item_id == v.rune_id then
			quality = v.quality
			types = v.type
			break
		end
	end
	return quality, types
end

--获取对应名字
function RuneData:GetNameByItemId(item_id)
	self:InitCfg()
	for k, v in ipairs(self.real_id_cfg) do
		if item_id == v.rune_id then
			return v.fu_name
		end
	end
	return ""
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
	local rune_jilian_slot_open_flag = info.rune_jilian_slot_open_flag	-- 洗练开启标记
	self.rune_jilian_slot_open_list =  bit:d2b(rune_jilian_slot_open_flag)	-- 洗练开启标记
	self.is_new_player = info.is_new_player									-- 是否为新玩家
	self.best_rune_open_timestamp = info.best_rune_open_timestamp			-- 终极符文功能开启时间戳
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

function RuneData:RuneFetchCfg()
	self:InitCfg()
	return self.rune_fetch_cfg
end

--根据物品id获取需要通关的层数
function RuneData:GetPassLayerByItemId(item_id)
	self:InitCfg()
	local pass_layer = 0
	for k, v in ipairs(self.rune_fetch_cfg) do
		if item_id == v.rune_id then
			pass_layer = v.in_layer_open
			break
		end
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
	self:InitCfg()
	for k, v in ipairs(self.rune_fetch_cfg) do
		if v.pandect > 0 then
			AddTbl(v)
		end
	end

	for k, v in ipairs(self.rune_list) do
		local item_id = v.item_id
		local quality, types = self:GetQualityTypeByItemId(item_id)
		local base_data = self:GetAttrInfo(quality, types, 1)
		v.quality = base_data.quality
		v.type = base_data.types
		v.level = base_data.level
		v.attr_type_0 = base_data.attr_type_0
		v.add_attributes_0 = base_data.add_attributes_0
		v.attr_type_1 = base_data.attr_type_1
		v.add_attributes_1 = base_data.add_attributes_1
		v.power = base_data.power
		v.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
	end
	table.sort( self.rune_list, SortTools.KeyLowerSorters("in_layer_open", "type", "quality") )
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
	local pass_layer = a.pass_layer

	if a.quality > b.quality then
		order_a = order_a + 10000
	elseif a.quality < b.quality then
		order_b = order_b + 10000
	end

	-- if a.type > b.type then
	-- 	order_a = order_a - 1000
	-- elseif a.type < b.type then
	-- 	order_b = order_b - 1000
	-- end

	-- if a.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	order_a = 1
	-- elseif b.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	order_b = 1
	-- end

	if a.in_layer_open <= pass_layer then
		order_a = order_a + 1000
	end
	if b.in_layer_open <= pass_layer then
		order_b = order_b + 1000
	end

	if a.in_layer_open <= pass_layer and b.in_layer_open <= pass_layer then
		if a.open_sort < b.open_sort then
			order_a = order_a + 1000
		elseif a.open_sort > b.open_sort then
			order_b = order_b + 1000
		end
	elseif a.in_layer_open > pass_layer and b.in_layer_open > pass_layer then
		if a.close_sort < b.close_sort then
			order_a = order_a + 10
		elseif a.close_sort > b.close_sort then
			order_b = order_b + 10
		end
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

	--添加排序
	local pass_layer = self.pass_layer
	for k, v in ipairs(exchange_list) do
		v.pass_layer = pass_layer
	end
	self:AddSortCfg(exchange_list)

	table.sort( exchange_list, SortExChangeList )
	-- local time2 = UnityEngine.Time.realtimeSinceStartup * 1000
	-- print_error(time2-time1)
	return exchange_list
end

function RuneData:GetSortListByType(type)
	self:InitCfg()
	local temp_data = {}
	for k, v in ipairs(self.exchange_sort_cfg) do
		if v.rune_type == type then
			temp_data = v
			break
		end
	end
	return temp_data
end

function RuneData:AddSortCfg(data_list)
	for k, v in ipairs(data_list) do
		local sort_data = self:GetSortListByType(v.type)
		v.open_sort = sort_data.open_sort
		v.close_sort = sort_data.close_sort
	end
end

local function SortOpenList(a,b)
	local order_a = 0
	local order_b = 0

	if a.open_sort < b.open_sort then
		order_a = order_a + 100
	elseif a.open_sort > b.open_sort then
		order_b = order_b + 100
	end
	return order_a > order_b
end

local function SortCloseList(a,b)
	local order_a = 0
	local order_b = 0

	if a.close_sort < b.close_sort then
		order_a = order_a + 100
	elseif a.close_sort > b.close_sort then
		order_b = order_b + 100
	end
	return order_a > order_b
end

function RuneData:GetTreasureShowList()
	self:InitCfg()
	local pass_layer = self:GetPassLayer()
	self.list_data = self:GetRuneListByLayer(pass_layer)
	local list_can_show = {}
	for k,v in pairs(self.rune_fetch_cfg) do
		 if v.preview == 1 then
		 	table.insert(list_can_show, v)
		 end
	end

	local open_list = {}
    local close_list = {}
    local flag = 0
	for k,v in pairs(list_can_show) do
		for i,j in pairs(self.list_data) do
			if v.rune_id == j.item_id then
				flag = 1
				break
			end
		end
		if flag == 1 then
			-- table.insert(open_list, v)
			table.insert(open_list,
			{
			one_weight = v.one_weight,
			ten_weight = v.ten_weight,
			rune_id = v.rune_id,
			power = v.power,
			convert_consume_rune_suipian = v.convert_consume_rune_suipian,
			preview = v.preview,
			})
		else
			--table.insert(close_list, v)
			table.insert(close_list,
			{
			one_weight = v.one_weight,
			ten_weight = v.ten_weight,
			rune_id = v.rune_id,
			power = v.power,
			convert_consume_rune_suipian = v.convert_consume_rune_suipian,
			preview = v.preview,
			})
		end
		flag = 0
	end

	self.treasure_open_num = #open_list

	--排序
	for k,v in ipairs(open_list) do
		local item_id = v.rune_id
		local quality, types = self:GetQualityTypeByItemId(item_id)
		v.type = types
	end
	for k, v in ipairs(close_list) do
		local quality, types = self:GetQualityTypeByItemId(v.rune_id)
		v.type = types
	end
	self:AddSortCfg(open_list)
	self:AddSortCfg(close_list)
	table.sort(open_list, SortOpenList)
	table.sort(close_list, SortCloseList)

	for k,v in pairs(close_list) do
		table.insert(open_list, v)
	end

	return open_list
end

function RuneData:GetTreasureOpenNum()
	return self.treasure_open_num
end

--改变镶嵌红点
function RuneData:CalcInlayRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end
	self:InitCfg()		--读取配置
	local flag = 0
	-- local time1 = UnityEngine.Time.realtimeSinceStartup * 1000
	--先判断是否存在可升级的
	local rune_level_limit_info = self:GetRuneLevelLimitInfo() or {}
	local rune_level_limit = rune_level_limit_info.rune_level or 0
	for i = 1, #self.rune_slot_open_list do
		local slot_data = self.slot_list[i]
		if slot_data then
			--判断是否有可升级的格子
			if slot_data.quality >= GameEnum.RUNE_COLOR_WHITE then
				local uplevel_need_jinghua = slot_data.uplevel_need_jinghua
				local now_level = slot_data.level
				if now_level < rune_level_limit and now_level < self:GetRuneMaxLevel() and uplevel_need_jinghua > 0 and self.rune_jinghua >= uplevel_need_jinghua then
					flag = 1
					break
				end
			end
		end
	end

	--再判断是否存在可替换的符文
	if flag == 0 then
		for k, v in ipairs(self.bag_list) do
			if flag == 1 then
				break
			end
			if v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				for i = 1, #self.rune_slot_open_list do
					local slot_data = self.slot_list[i]
					if slot_data then
						if slot_data.type == v.type and slot_data.quality < v.quality then
							flag = 1
							break
						end
					end
				end
			end
		end
	end

	if flag == 0 then
		--再判断是否存在可镶嵌的符文
		for k, v in ipairs(self.bag_list) do
			if flag == 1 then
				break
			end
			if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				for i = 1, #self.rune_slot_open_list do
					local slot_data = self.slot_list[i]
					local is_lock = self.rune_slot_open_flag_list[32-(i-1)] == 0
					if slot_data and not is_lock then
						--判断是否存在未镶嵌的格子
						if slot_data.quality and slot_data.quality < GameEnum.RUNE_COLOR_WHITE then
							flag = 1
							break
						end
					end
				end
			end
		end
	end

	return flag
	-- local time2 = UnityEngine.Time.realtimeSinceStartup * 1000
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
			break
		end
	end
	return flag
end

--改变寻宝红点
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
	self:InitCfg()
	if flag == 0 then
		local need_item_id = self.other_cfg.xunbao_consume_itemid
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		local min_need_num = self.other_cfg.xunbao_one_consume_num
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
	local flag = self:GetComposeReminder() and 1 or 0
	return flag
end

--改变祭炼红点
function RuneData:CalcZhuLingRedPoint()
	if not OpenFunData.Instance:CheckIsHide("rune") then
		return 0
	end

	--钥匙数量大于1
	local cfg = RuneData.Instance:GetOtherCfg()
	local my_item_1_count = ItemData.Instance:GetItemNumInBagById(cfg.jilian_consume_itemid)
	if my_item_1_count > 0 then
		return 1
	end

	local run_zhuling_list = self.zhuling_info.run_zhuling_list
	if run_zhuling_list == nil then
		return 0
	end

	for k, v in ipairs(self.slot_list) do
		--有镶嵌符文才进行判断
		if v.quality >= GameEnum.RUNE_COLOR_WHITE then
			local zhuling_info = run_zhuling_list[k]
			--获取当前部位的注灵信息
			local zhuling_cfg = self:GetRuneZhulingGradeCfg(k-1, zhuling_info.grade)

			--只有能够升一级祭炼等级才提示红点
			if nil ~= zhuling_cfg and zhuling_info.zhuling_bless + self.zhuling_info.zhuling_slot_bless >= zhuling_cfg.need_bless then
				return 1
			end
		end
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
		if quality >= GameEnum.RUNE_COLOR_WHITE then
			data.index = v.index
			data.quality = quality
			data.type = types
			data.level = v.level
			data.is_repeat = false
			local slot_data = self:GetAttrInfo(data.quality, data.type, data.level)
			if self:IsRepeat(slot_data) then
				data.is_repeat = true
			end
			data.attr_type_0 = slot_data.attr_type_0
			data.add_attributes_0 = slot_data.add_attributes_0
			data.attr_type_1 = slot_data.attr_type_1
			data.add_attributes_1 = slot_data.add_attributes_1
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
		if quality < GameEnum.RUNE_COLOR_WHITE then
			--减少物品
			for k1, v1 in ipairs(self.bag_list) do
				if v1.index == v.index then
					table.remove(self.bag_list, k1)
					break
				end
			end
		elseif quality >= GameEnum.RUNE_COLOR_WHITE then
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
			data.attr_type_0 = slot_data.attr_type_0
			data.add_attributes_0 = slot_data.add_attributes_0
			data.attr_type_1 = slot_data.attr_type_1
			data.add_attributes_1 = slot_data.add_attributes_1
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

--根据item_id获取背包符文index(默认是找到的第一个)
function RuneData:GetBagIndexByItemId(item_id)
	local index = -1
	for k, v in ipairs(self.bag_list) do
		if v.item_id == item_id then
			index = v.index
			break
		end
	end
	return index
end

function RuneData:GetBagList()
	return self.bag_list
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
function RuneData:SetTreasureList(protocol)
	self.treasure_list = protocol.item_list

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

	self:InitCfg()
	--添加虚拟水晶物品
	if self.old_magic_crystal == self.magic_crystal then
		--数量没变化不处理
		return
	end
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	mojing_data.num = self.magic_crystal - self.old_magic_crystal
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
	self:InitCfg()
	local mojing_data = {}
	mojing_data.item_id = ResPath.CurrencyToIconId.magic_crystal
	mojing_data.num = self.magic_crystal - self.old_magic_crystal
	mojing_data.is_bind = 1
	table.insert(self.baoxiang_list, mojing_data)
end

--设置已有类型列表
function RuneData:SetHavaTypeList()
	self.have_type_list = {}
	for k, v in ipairs(self.slot_list) do
		local slot_data = self:GetAttrInfo(v.quality, v.type, v.level)
		if next(slot_data) then
			if slot_data.types and not self.have_type_list[slot_data.types] then
				self.have_type_list[slot_data.types] = 1
			end
		end
	end
end

--刷新背包物品参数(是否有重复的属性, slot_index存在的话直接剔除相关属性)
function RuneData:ResetBagList(slot_index)
	local dis_type_list = {}
	if slot_index then
		local slot_data = self:GetSlotDataByIndex(slot_index)
		if next(slot_data) and slot_data.type then
			dis_type_list[slot_data.type] = true
		end
	end
	for k, v in ipairs(self.bag_list) do
		if self:IsRepeat(v, dis_type_list) then
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
		if v.quality >= GameEnum.RUNE_COLOR_WHITE then
			local base_data = self:GetAttrInfo(v.quality, v.type, v.level)
			data.quality = base_data.quality
			data.type = base_data.types
			data.level = base_data.level
			data.uplevel_need_jinghua = base_data.uplevel_need_jinghua
			data.attr_type_0 = base_data.attr_type_0
			data.add_attributes_0 = base_data.add_attributes_0
			data.attr_type_1 = base_data.attr_type_1
			data.add_attributes_1 = base_data.add_attributes_1
			data.power = base_data.power
			data.dispose_fetch_jinghua = base_data.dispose_fetch_jinghua
		else
			data.quality = v.quality
			data.type = v.type
			data.level = v.level
			data.uplevel_need_jinghua = -1
			data.attr_type_0 = -1
			data.add_attributes_0 = -1
			data.attr_type_1 = -1
			data.add_attributes_1 = -1
			data.power = 0
			data.dispose_fetch_jinghua = -1
		end
		table.insert(self.slot_list, data)
	end
	if not OpenFunData.Instance:CheckIsHide("rune") then return end
	self:SetHavaTypeList()
	self:ResetBagList()
end

function RuneData:GetSlotList()
	return self.slot_list or {}
end

--获取已解锁的符文槽数量
function RuneData:GetUnLockSlotCount()
	local count = 0
	for k, v in ipairs(self.slot_list) do
		if not self:GetIsLockByIndex(k) then
			count = count + 1
		end
	end

	return count
end

--判断是否有重复类型(dis__type_list为不考虑的类型列表)
function RuneData:IsRepeat(data, dis_type_list)
	local is_repeat = false
	if not data or not next(data) then
		return is_repeat
	end
	dis_type_list = dis_type_list or {}
	if not self.have_type_list or not next(self.have_type_list) then
		self:SetHavaTypeList()
	end
	local types = data.types or data.type
	if types and self.have_type_list and self.have_type_list[types] and dis_type_list[types] ~= true then
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

--获取该格子是否锁定
function RuneData:GetIsOpenJilianByIndex(index)			-- 1 开始
	local flag = self.rune_jilian_slot_open_list[32-(index-1)] or 0
	return flag == 0
end

--获取槽开启的层级
function RuneData:GetSlotOpenLayerByIndex(index)			-- 1 开始
	self:InitCfg()
	local layer = 0
	for k, v in ipairs(self.rune_slot_open_list) do
		if v.open_rune_slot == index-1 then
			layer = v.need_pass_layer
			break
		end
	end
	return layer
end

--通过物品ID获取所需材料
function RuneData:GetMaterialByItemId(item_id)
	self:InitCfg()
	item_id = item_id or 0
	local tbl = {}
	for k,v in pairs(self.rune_compose) do
		if v.get_rune_id == item_id then
			tbl = v
			break
		end
	end
	return tbl
end

--通过类型获得合成显示配置
function RuneData:GetComposeShowByType(index)
	self:InitCfg()
	index = index or 0
	local tbl = {}
	for k,v in pairs(self.compose_show) do
		if v.type == index then
			tbl = v
			break
		end
	end
	return tbl
end

--获得合成显示配置
function RuneData:GetComposeShow()
	self:InitCfg()
	return self.compose_show
end

--获得合成红点
function RuneData:GetComposeReminder()
	self:InitCfg()
	local flag = false
	if self.pass_layer < self.other_cfg.rune_compose_need_layer then
		return flag
	end
	self:InitCfg()
	local magic_crystal_num = self:GetMagicCrystal() or 0
	for k,v in ipairs(self.rune_compose) do
		if v.magic_crystal_num <= magic_crystal_num then
			local has_num1 = self.num_list[v.rune1_id] or 0
			local has_num2 = self.num_list[v.rune2_id] or 0
			if has_num1 > 0 and has_num2 > 0 then
				flag = true
				break
			end
		end
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

-- 每个符文的总属性
function RuneData:CalcAttr(attr_info, attr_type, add_attributes)
	if attr_type == "armor_hp" or attr_type == "armor_shanbi" or attr_type == "armor_fangyu" or attr_type == "armor_jianren" or attr_type == "weapon_gongji" then
		for _, v in ipairs(RuneData.FJIndexList) do
			local equip_data = EquipData.Instance:GetGridData(v) or {}
			local item_id = equip_data.item_id or 0
			if item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				if nil ~= item_cfg then
					if attr_type == "weapon_gongji" then
						local gongji = item_cfg.attack or 0
						gongji = gongji * (add_attributes/10000)
						attr_info["gongji"] = attr_info["gongji"] + gongji
					elseif attr_type == "armor_hp" then
						local hp = item_cfg.hp or 0
						hp = hp * (add_attributes/10000)
						attr_info["maxhp"] = attr_info["maxhp"] + hp
					elseif attr_type == "armor_shanbi" then
						local shanbi = item_cfg.shanbi or 0
						shanbi = shanbi * (add_attributes/10000)
						attr_info["shanbi"] = attr_info["shanbi"] + shanbi
					elseif attr_type == "armor_fangyu" then
						local fangyu = item_cfg.fangyu or 0
						fangyu = fangyu * (add_attributes/10000)
						attr_info["fangyu"] = attr_info["fangyu"] + fangyu
					elseif attr_type == "armor_jianren" then
						local jianren = item_cfg.jianren or 0
						jianren = jianren * (add_attributes/10000)
						attr_info["jianren"] = attr_info["jianren"] + jianren
					end
				end
			end
		end
	else
		if attr_info[attr_type] then
			attr_info[attr_type] = attr_info[attr_type] + add_attributes
		end
	end
end

function RuneData:GetBagHaveRuneGift()
	local num = 0
	for i = 23400, 23417 do
		if nil ~= ItemData.Instance:GetItemNumInBagById(i) and ItemData.Instance:GetItemNumInBagById(i) > 0 then
			-- return ItemData.Instance:GetItemNumInBagById(i)
			num = num + 1
		end
	end
	return num
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
	local awaken_attr_info = nil
	if nil == self.awaken_list then
		return awaken_attr_info
	end
	for k, v in ipairs(self.awaken_list) do
		if k == index then
			awaken_attr_info = v
			break
		end
	end

	return awaken_attr_info
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
	self:InitCfg()
	return self.fuwen_zhuling_slot_cfg
end

function RuneData:GetRuneZhulingGradeCfg(index, grade)
	self:InitCfg()
	if self.fuwen_zhuling_grade_cfg[index] and self.fuwen_zhuling_grade_cfg[index][grade] then
		return self.fuwen_zhuling_grade_cfg[index][grade]
	end
end

function RuneData:GetAddPerAwakePower(attr_type, add_attributes, add_per)
	local add_per_power = 0
	local attr_info = CommonStruct.AttributeNoUnderline()
	if attr_type == "armor_hp" or attr_type == "armor_shanbi" or attr_type == "armor_fangyu" or attr_type == "armor_jianren" or attr_type == "weapon_gongji" then
		for _, v in ipairs(RuneData.FJIndexList) do
			local equip_data = EquipData.Instance:GetGridData(v) or {}
			local item_id = equip_data.item_id or 0
			if item_id > 0 then
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				if nil ~= item_cfg then
					if attr_type == "weapon_gongji" then
						local gongji = item_cfg.attack or 0
						gongji = gongji * (add_attributes/10000) * (add_per/10000)
						attr_info["gongji"] = attr_info["gongji"] + gongji
					elseif attr_type == "armor_hp" then
						local hp = item_cfg.hp or 0
						hp = hp * (add_attributes/10000) * (add_per/10000)
						attr_info["maxhp"] = attr_info["maxhp"] + hp
					elseif attr_type == "armor_shanbi" then
						local shanbi = item_cfg.shanbi or 0
						shanbi = shanbi * (add_attributes/10000) * (add_per/10000)
						attr_info["shanbi"] = attr_info["shanbi"] + shanbi
					elseif attr_type == "armor_fangyu" then
						local fangyu = item_cfg.fangyu or 0
						fangyu = fangyu * (add_attributes/10000) * (add_per/10000)
						attr_info["fangyu"] = attr_info["fangyu"] + fangyu
					elseif attr_type == "armor_jianren" then
						local jianren = item_cfg.jianren or 0
						jianren = jianren * (add_attributes/10000) * (add_per/10000)
						attr_info["jianren"] = attr_info["jianren"] + jianren
					end
				end
			end
		end
	else
		if attr_info[attr_type] then
			local add_per_attr = add_attributes * (add_per/10000)
			attr_info[attr_type] = attr_info[attr_type] + add_per_attr
		end
	end

	add_per_power = CommonDataManager.GetCapabilityCalculation(attr_info)

	return add_per_power
end

--计算觉醒增加的战斗力
function RuneData:CalcAwakePowerByIndex(index)
	local power = 0

	local awake_attr_info = self:GetAwakenAttrInfoByIndex(index) or {}

	local slot_info = self.slot_list[index]
	local attr_type_1 = Language.Rune.AttrType[slot_info.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[slot_info.attr_type_1]

	--先计算基础属性的战斗力加成
	power = power + CommonDataManager.GetCapabilityCalculation(awake_attr_info)

	--属性增幅
	if awake_attr_info.add_per and awake_attr_info.add_per > 0 then
		if attr_type_1 then
			power = power + self:GetAddPerAwakePower(attr_type_1, slot_info.add_attributes_0, awake_attr_info.add_per)
		end
		if attr_type_2 then
			power = power + self:GetAddPerAwakePower(attr_type_2, slot_info.add_attributes_1, awake_attr_info.add_per)
		end
	end

	return power
end

--获取符文战力（加上觉醒战力）
function RuneData:GetRunePowerByIndex(index)
	local power = 0

	local slot_data = self.slot_list[index]

	local attr_type_1 = Language.Rune.AttrType[slot_data.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[slot_data.attr_type_1]
	local awake_attr_info = self:GetAwakenAttrInfoByIndex(index) or {}

	local attr_info = CommonStruct.AttributeNoUnderline()
	if attr_type_1 then
		self:CalcAttr(attr_info, attr_type_1, slot_data.add_attributes_0, awake_attr_info)
	end
	if attr_type_2 then
		self:CalcAttr(attr_info, attr_type_2, slot_data.add_attributes_1, awake_attr_info)
	end

	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	power = power + capability + self:CalcAwakePowerByIndex(index)

	return power
end

--获取符文总战力（加上觉醒战力）
function RuneData:GetRuneTotalPower()
	local total_capability = 0
	for k, _ in ipairs(self.slot_list) do
		total_capability = total_capability + self:GetRunePowerByIndex(k)
	end

	return total_capability
end

function RuneData:GetAwakenPropCount()
	return ItemData.Instance:GetItemNumInBagById(self:GetCommonAwakenItemID()) or 0
end

function RuneData:GetAwakenGoldByCostByTimes(times)
	for k,v in pairs(self.awaken_cost_cfg) do
		if v.max_times >= times and v.min_times <= times then
			return v.gold_cost or 0
		end
	end
end

function RuneData:GetAwakenGoldCost(flag)
	if not flag then
		return self:GetAwakenGoldByCostByTimes(self.rune_awaken_times)
	else
		local awaken_times = self.rune_awaken_times
		local total_cost = 0
		for i = 1, 10 do
			total_cost = total_cost + self:GetAwakenGoldByCostByTimes(awaken_times)
			awaken_times = awaken_times + 1
		end
		return total_cost
	end
end

function RuneData:CheckAttrIsFull(cell_index)
	local awaken_limit = self:GetAwakenLimitByLevel(self.pass_layer)
	local awaken_attr = self:GetAwakenAttrInfoByIndex(cell_index)
	if nil == awaken_limit or nil == awaken_attr then
		return false
	end

	if awaken_attr.maxhp ~= awaken_limit.maxhp_limit then
		return false
	end
	if awaken_attr.gongji ~= awaken_limit.gongji_limit then
		return false
	end
	if awaken_attr.fangyu ~= awaken_limit.fangyu_limit then
		return false
	end
	local effect_amp = awaken_attr.add_per * 0.01
	if effect_amp ~= (awaken_limit.addper_limit * 0.01) then
		return false
	end
	return true
end

function RuneData:GetSpecialRuneCfg()
	self:InitCfg()
	return self.rune_special_rune_attr or {}
end

function RuneData:SetSpecialRuneInfo(protocol)
	self.best_rune_is_activated = protocol.best_rune_is_activated or 0
	self.best_rune_can_activated = protocol.best_rune_can_activated or 0
	self.best_rune_activate_card_is_got = protocol.best_rune_activate_card_is_got or 0

	self.rune_small_target_is_activated = protocol.rune_small_target_is_activated or 0				-- 符文小目标是否已经激活称号卡
	self.rune_small_target_can_activated = protocol.rune_small_target_can_activated or 0			-- 符文小目标是否可以领取称号卡
	self.rune_small_target_title_card_is_got = protocol.rune_small_target_title_card_is_got or 0	-- 符文小目标称号卡是否已领取
end

-- 终极符文卡是否已激活
function RuneData:GetSpecialRuneIsActivate()
	return self.best_rune_is_activated or 0
end

-- 终极符文卡是否可免费领取
function RuneData:GetSpecialRuneCanActived()
	return self.best_rune_can_activated or 0
end

-- 终极符文卡是否已经领取
function RuneData:GetSpecialRuneCardIsGot()
	if self.best_rune_activate_card_is_got == 1 or self:GetSpecialRuneIsInBag() == 1 or self:GetSpecialRuneIsActivate() == 1 then
		return 1
	else
		return 0
	end
end

-- 符文小目标是否已激活
function RuneData:GetSmallTargetIsActivated()
	return self.rune_small_target_is_activated or 0
end

-- 符文小目标是否可获取
function RuneData:GetSmallTargetCanActivated()
	return self.rune_small_target_can_activated or 0
end

-- 符文小目标是否已获取
function RuneData:GetSmallTargetCardIsGot()
	return self.rune_small_target_title_card_is_got == 1 or self:GetSmallTargetTitleIsInBag() or self:GetSpecialRuneIsActivate() == 1
end

function RuneData:GetRuneOpenTime()
	return self.is_new_player or 0, self.best_rune_open_timestamp or 0
end

function RuneData:GetSmallTargetTitleIsInBag()
	local target_title_cfg = self:GetTargetTitleAllCfg()
	if target_title_cfg == nil then
		return false
	end
	local bag_index = ItemData.Instance:GetItemIndex(target_title_cfg.small_target_reward_item)
	return bag_index ~= -1
end

-- 镶嵌符文基础战力（不加上觉醒及升级战力）
function RuneData:GetSingleRuneTotalPower(quality, type)
	local base_slot_data = self:GetAttrInfo(quality, type, 1)
	if next(base_slot_data) == nil then
		return 0
	end

	local attr_info = CommonStruct.AttributeNoUnderline()

	local attr_type_1 = Language.Rune.AttrType[base_slot_data.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[base_slot_data.attr_type_1]

	if attr_type_1 then
		self:CalcAttr(attr_info, attr_type_1, base_slot_data.add_attributes_0)
	end
	if attr_type_2 then
		self:CalcAttr(attr_info, attr_type_2, base_slot_data.add_attributes_1)
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_info)
	return power
end

-- 超级符文战力（超级符文属性加成战力加镶嵌符文属性加成战力）
function RuneData:GetSpecialRunePower()
	local special_attr_cfg = self:GetSpecialRuneCfg()
	if next(special_attr_cfg) == nil then
		return 0
	end
	local attr_percent = special_attr_cfg.attr_percent

	-- 镶嵌符文基础战力
	local total_inlay_rune_base_power = 0
	for k,v in pairs(self.slot_list) do
		if v.level and v.level > 0 then
			total_inlay_rune_base_power = total_inlay_rune_base_power + self:GetSingleRuneTotalPower(v.quality, v.type)
		end
	end

	total_inlay_rune_base_power = total_inlay_rune_base_power * attr_percent / 10000

	-- 特殊符文战力
	local special_rune_power = 0

	local attr_type_1 = Language.Rune.AttrType[1]	-- 攻击
	local attr_type_2 = Language.Rune.AttrType[2]	-- 生命
	local attr_type_3 = Language.Rune.AttrType[8]	-- 防御

	local attr_info = CommonStruct.AttributeNoUnderline()
	if attr_type_1 then
		self:CalcAttr(attr_info, attr_type_1, special_attr_cfg.add_attributes_0, attr_percent)
	end
	if attr_type_2 then
		self:CalcAttr(attr_info, attr_type_2, special_attr_cfg.add_attributes_1, attr_percent)
	end
	if attr_type_3 then
		self:CalcAttr(attr_info, attr_type_3, special_attr_cfg.add_attributes_2, attr_percent)
	end
	special_rune_power = CommonDataManager.GetCapabilityCalculation(attr_info)
	special_rune_power = special_rune_power * (1 + attr_percent / 10000)

	-- 总战力
	local add_capability = total_inlay_rune_base_power + special_rune_power
	add_capability = math.ceil(add_capability)

	return add_capability
end

-- 特殊符文免费活动时间
function RuneData:GetSpecialRuneRemainFreeTime()
	local other_cfg = self:GetOtherCfg()
	if other_cfg == nil and next(other_cfg) == nil then 
		return 0
	end
	local is_new_player, open_time = self:GetRuneOpenTime()
	if is_new_player == 1 then
		local duration_time = other_cfg.continue_time * 3600
		local now_time = TimeCtrl.Instance:GetServerTime()
		return open_time + duration_time - now_time
	end
	return 0
end

-- 判断超级符文是否在背包
function RuneData:GetSpecialRuneIsInBag()
	local other_cfg = self:GetOtherCfg()
	if next(other_cfg) == nil then
		return 1
	end

	local item_id = other_cfg.best_rune_item or 0
	local index = ItemData.Instance:GetItemIndex(item_id)
	if index < 0 then
		return 0
	end

	return 1
end

-- 特殊符文红点
function RuneData:CalcSpecialRuneRedPoint()
	
	-- 小目标可领取时显示红点
	if self:GetSmallTargetCanActivated() == 1 and self:GetSmallTargetCardIsGot() == false then
		return 1
	end

	local is_can_get = self:GetSpecialRuneCanActived()
	local is_got = self:GetSpecialRuneCardIsGot()
	local is_active = self:GetSpecialRuneIsActivate()

	if is_active == 1 then
		return 0
	end

	if is_can_get == 1 and is_got ~= 1 then
		return 1
	end

	if is_got == 1 and self:GetSpecialRuneIsInBag() == 1 then
		return 1
	end

	return 0
end

-- 设置小目标称号的信息
function RuneData:SetTargetTitleAllCfg()
	local other_cfg = self:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end

	local temp_list = {}
	temp_list.small_target_reward_item = other_cfg.small_target_reward_item
	temp_list.small_target_buy_reward_item_cost = other_cfg.small_target_buy_reward_item_cost or 0
	local title_cfg = ItemData.Instance:GetItemConfig(other_cfg.small_target_reward_item)
	if title_cfg == nil then
		return 0
	end
	temp_list.title_id = title_cfg.param1 or 0
	temp_list.power = title_cfg.power or 0
	temp_list.time_stamp = self:GetSpecialRuneRemainFreeTime()

	self.target_title_all_cfg = temp_list
end

-- 获取小目标称号的信息（配置表）
function RuneData:GetTargetTitleAllCfg()
	if self.target_title_all_cfg == nil then
		self:SetTargetTitleAllCfg()
	end

	return self.target_title_all_cfg
end