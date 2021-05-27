FuwenData = FuwenData or BaseClass()
FuwenData.RUNE = 6
FuwenData.RUNE_PARTS = 8
FuwenData.ACT_ANGER_SUIT_COUNT = 8 -- 激活怒气速度加成所需数量

FuwenData.FUWEN_ITEM_CHNAGE = "fuwen_item_chnage"
FuwenData.FUWEN_ZHULING_CHANGE = "fuwen_zhuling_change"
FuwenData.FUWEN_ZHULING_STATE = "fuwen_zhuling_state"
function FuwenData:__init()
	if FuwenData.Instance then
		ErrorLog("[FuwenData] Attemp to create a singleton twice !")
	end
	FuwenData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.fuwen_list = {}
	self.zhuling_data = {}
	for i = 1, FuwenData.RUNE_PARTS do
		self.zhuling_data[i] = {level = 0, fuwen_index = i}
	end

	self.suit_plus_cfg = {}
	self.suit_plus_cfg_level = {}
	for i = 1, 99 do
		local cfg = self:GetFuwenCfg(i)
		if cfg then
			self.suit_plus_cfg[cfg.runeplus.suitId] = cfg.runeplus
			self.suit_plus_cfg_level[cfg.runeplus.level] = cfg.runeplus
		else
			break
		end
	end

	self.zhuling_slot_index = 1
	self.zhuling_total_level = 0
	self.zhuling_state = false -- 注灵是否激活
	self.suit_level_data = {}

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetBetterFuwenRemind, self), RemindName.BetterFuwen)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.FuwenCanZhulingRemind, self), RemindName.FuwenCanZhuling)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanDecomposeFuwenRemind, self), RemindName.CanDecomposeFuwen)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanExchangeFuwenRemind), RemindName.CanExchangeFuwen)
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.FuwenCircle, BindTool.Bind(self.CheckFuwenCircle, self))
end

function FuwenData:__delete()
	FuwenData.Instance = nil

	if self.delay_update_fuwen then
		GlobalTimerQuest:CancelQuest(self.delay_update_fuwen)
		self.delay_update_fuwen = nil
	end
end

function FuwenData:SetFuwenInfo(protocol)
	self.fuwen_list = protocol.fuwen_list
	for k, v in pairs(protocol.zhuling_data) do
		if self.zhuling_data[v.fuwen_index] then
			self.zhuling_data[v.fuwen_index].level = v.level
		end
	end
	self:UpdateZhulingSlotIndex()
	self:CalcFuwenSuitLevelData()

	self:DispatchEvent(FuwenData.FUWEN_ITEM_CHNAGE)
	self:DispatchEvent(FuwenData.FUWEN_ZHULING_CHANGE)

	GameCondMgr.Instance:CheckCondType(GameCondType.FuwenCircle)
end

function FuwenData:SetZhulingActState(state)
	self.zhuling_state = (state == 1)
	self:DispatchEvent(FuwenData.FUWEN_ZHULING_STATE)

	RemindManager.Instance:DoRemindDelayTime(RemindName.FuwenCanZhuling)
end

function FuwenData:ChangeFuwenlv(fuwen_index, lv)
	if self.zhuling_data[fuwen_index] then
		self.zhuling_data[fuwen_index].level = lv
		self:UpdateZhulingSlotIndex()

		self:DispatchEvent(FuwenData.FUWEN_ZHULING_CHANGE)

		RemindManager.Instance:DoRemindDelayTime(RemindName.FuwenCanZhuling)
	end
end

function FuwenData:EquipOneFuwen(protocol)
	self.fuwen_list[protocol.fuwen_index] = protocol.item
	self:CalcFuwenSuitLevelData()

	self:DispatchEvent(FuwenData.FUWEN_ITEM_CHNAGE)

	GameCondMgr.Instance:CheckCondType(GameCondType.FuwenCircle)
end
----------------------------------------------------------------------------
function FuwenData:GetZhulingActState()
	return self.zhuling_state
end

function FuwenData:UpdateZhulingSlotIndex()
	local all_level = 0
	for k, v in pairs(self.zhuling_data) do
		all_level = all_level + v.level
	end
	self.zhuling_total_level = all_level
	self.zhuling_slot_index = all_level % FuwenData.RUNE_PARTS + 1
end

function FuwenData:GetZhulingSlotIndex()
	return self.zhuling_slot_index
end

-- 是否满同一套符文
function FuwenData:IsFullEquip()
	local last_suit_id = nil
	for i = 1, FuwenData.RUNE_PARTS do
		local data = self:GetFuwenData(i)
		if nil == data then
			return false
		end
		local suit_id = self:GetFuwenSuitLevel(data.item_id)
		if nil == last_suit_id then
			last_suit_id = suit_id
		elseif last_suit_id ~= suit_id then
			return false
		end
	end
	return true
end

function FuwenData:GetFuwenData(fuwen_index)
	return self.fuwen_list[fuwen_index]
end

function FuwenData:GetFuwenZhuingData(fuwen_index)
	return self.zhuling_data[fuwen_index]
end

function FuwenData:GetFuwenZhulingCfg(fuwen_index)
	local cfg = ConfigManager.Instance:GetServerConfig("rune/RuneSlotAttr/RuneSlot" .. fuwen_index)
	return cfg and cfg[1]
end

function FuwenData:GetFuwenCfg(suit_index)
	local cfg = ConfigManager.Instance:GetServerConfig("rune/BossRuneAttr/bossrune" .. suit_index)
	return cfg and cfg[1]
end

-- 注灵消耗
function FuwenData:GetFuwenZhulingConsume()
	local level = self.zhuling_total_level
	local index = (level - level % 8) / 8 + 1
	return RuneConsumeConfig[index]
end

function FuwenData:GetFuwenAttrCfg(item_id)
	local boss_index, fuwen_index = ItemData.GetItemFuwenIndex(item_id)
	local cfg = self:GetFuwenCfg(boss_index)
	if cfg and cfg.runecfg[fuwen_index] then 
		return cfg.runecfg[fuwen_index]
	else
		return {}
	end
end

function FuwenData:GetZhulingAllAttrCfg()
	local attrs = {}
	for k, v in pairs(self.zhuling_data) do
		attrs = CommonDataManager.AddAttr(attrs, self:GetZhulingAttrCfg(v.fuwen_index, v.level))
	end
	return attrs
end

function FuwenData:GetNextZhulingAllAttrCfg()
	local attrs = {}
	for k, v in pairs(self.zhuling_data) do
		local a = self:GetZhulingAttrCfg(v.fuwen_index, (v.fuwen_index ~= self.zhuling_slot_index) and v.level or (v.level + 1))
		attrs = CommonDataManager.AddAttr(attrs, a)
	end
	return attrs
end

function FuwenData:GetZhulingAttrCfg(fuwen_index, level)
	local cfg = self:GetFuwenZhulingCfg(fuwen_index)
	if cfg and cfg[level] then
		return cfg[level]
	end
end

function FuwenData:GetZhulingLevel(fuwen_index)
	return self.zhuling_data[fuwen_index] and self.zhuling_data[fuwen_index].level or 0
end

function FuwenData:GetFuwenAllAttr()
	local attrs = {}
	for i = 1, FuwenData.RUNE_PARTS do
		local fuwen_equip = self:GetFuwenData(i)
		if fuwen_equip then
			local item_cfg = ItemData.Instance:GetItemConfig(fuwen_equip.item_id)
			attrs = CommonDataManager.AddAttr(attrs, ItemData.GetStaitcAttrs(item_cfg))
			attrs = CommonDataManager.AddAttr(attrs, self:GetZhulingAttrCfg(i, self:GetZhulingLevel(i)))
		end
	end

	for count, level in pairs(self:GetFuwenSuitLevelData()) do
		attrs = CommonDataManager.AddAttr(attrs, self:GetFuwenSuitAttrs(level, count))
	end

	return attrs
end

function FuwenData:GetFuwenSuitLevel(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local suit_id = item_cfg and item_cfg.suitId or 0
	local cfg = self.suit_plus_cfg[suit_id]
	if nil == cfg then
		return 0
	end
	return cfg.level
end

-- 预览属性
function FuwenData:GetSuitAttrsPreviewRich()
	local str = ""
	local num_limit = self:GetZhulingActState() and 999 or 23 -- 未激活前显示前4个
	for i, v in pairs(self.suit_plus_cfg) do
		if i > num_limit then
			break
		end

		if str ~= "" then
			str = str .. "\n{colorandsize;ff7f00;15;\n}"
		end
		str = str .. string.format("{colorandsize;af8e58;20;%s套装属性}", FuwenData.GetSuitName(v.level))
		for _, v1 in pairs(v.plus) do
			str = str .. "\n"
			local attrs = self:GetFuwenSuitAttrsFormat(v.level, v1.count)
			local attrs = attrs[1]
			if attrs then
				str = str .. string.format("{colorandsize;ff2828;18;%s%d件:}{colorandsize;edd9b2;18;%s}{colorandsize;1eff00;18;%s}",
					FuwenData.GetSuitName(v.level), v1.count, attrs.type_str, attrs.value_str)
			end
		end
	end
	return str
end

function FuwenData:GetFuwenSuitAttrsRich()
	local str = ""
	for count, level in pairs(self:GetFuwenSuitLevelData()) do
		if str ~= "" then
			str = str .. "\n"
		end
		local attrs = self:GetFuwenSuitAttrsFormat(level, count)
		local attrs = attrs[1]
		if attrs then
			str = str .. string.format("{colorandsize;ff2828;18;%s%d件:}{colorandsize;edd9b2;18;%s}{colorandsize;1eff00;18;%s}",
				FuwenData.GetSuitName(level), count, attrs.type_str, attrs.value_str)
		end
	end
	return str
end

local suit_names = {"60级", "80级", "2转", "4转", "6转", "7转", "8转", "9转", "10转", "11转", "12转"}
function FuwenData.GetSuitName(level)
	return suit_names[level] or level
end

local fuwen_words = {"乾", "坤", "震", "巽", "坎", "离", "艮", "兑"}
function FuwenData:GetSuitWordStateRich()
	local data = self:GetFuwenSuitLevelData()
	local max_level = 0
	local cur_count = 0
	for k, v in pairs(data) do
		if v > max_level then
			max_level = v
			cur_count = k
		end
	end
	if max_level == 0 then
		max_level = 1
		cur_count = 0
	end

	local fit_slot_table = {}
	local fit_num = 0
	for k, v in pairs(self.fuwen_list) do
		local suit_level = self:GetFuwenSuitLevel(v.item_id)
		if suit_level >= max_level then
			fit_slot_table[k] = true
			fit_num = fit_num + 1
		end
	end

	local str = string.format("{colorandsize;af8e58;22;%s齐鸣套装}{colorandsize;ff2828;22;(%d/%d)}", FuwenData.GetSuitName(max_level), fit_num, #fuwen_words)
	str = str .. "\n{colorandsize;af8e58;15;\n}"
	for k, name in pairs(fuwen_words) do
		str = str .. string.format(" {colorandsize;%s;20;%s}", fit_slot_table[k] and COLORSTR.ORANGE or "767374", name)
	end
	return str
end

function FuwenData:GetFuwenSuitAttrs(suit_level, count)
	if self.suit_plus_cfg_level[suit_level] then
		for k, v in pairs(self.suit_plus_cfg_level[suit_level].plus) do
			if v.count == count then
				return v.attrs
			end
		end
	end
	return {}
end

-- 人物怒气总值
function FuwenData:GetMaxAnger()
	local level = self:GetFuwenSuitLevelData()[FuwenData.ACT_ANGER_SUIT_COUNT] or 0
	if self:GetFuwenSuitLevelData()[FuwenData.ACT_ANGER_SUIT_COUNT] then 
		for k,v in pairs(self:GetFuwenSuitLevelData()) do
			if v and v <= level then
				level = v
			end
		end
	end
	-- local suit_level = self:GetFuwenSuitLevelData()[FuwenData.ACT_ANGER_SUIT_COUNT] or 0
	return RuneAnger.limit[level + 1].value
end

function FuwenData:GetAngerAddPoint()
	return RuneAnger.addPoint
end

function FuwenData:GetFuwenSuitAttrsFormat(suit_level, count)
	-- if count == FuwenData.ACT_ANGER_SUIT_COUNT then -- 8件套装 特殊怒气加成
	-- 	if RuneAnger.limit[suit_level + 1] then
	-- 		local cur_value = RuneAnger.limit[suit_level + 1].value
	-- 		local base_value = RuneAnger.limit[1].value
	-- 		local speed_up_rate = math.floor((base_value - cur_value) / base_value * 100)
	-- 		return {
	-- 			{
	-- 				type_str = "怒气回复速度",
	-- 				value_str = "+" .. speed_up_rate .. "%",
	-- 				type = 0,
	-- 				type_r = 0,
	-- 				value = 0,
	-- 				value_r = 0,
	-- 			}
	-- 		}
	-- 	end
	-- 	return {}
	-- end

	local attr_str = {
		type_str = "",
		value_str = "",
		type = 0,
		type_r = 0,
		value = 0,
		value_r = 0,
	}

	local cfg = self.suit_plus_cfg_level[suit_level]
	if nil ~= cfg then
		for k, v in pairs(cfg.plus) do
			if v.count == count then
				attr_str.type_str = v.desc and v.desc[1] or ""
				attr_str.value_str = v.desc and v.desc[2] or ""
			end
		end
	end
	return {attr_str}
end

-- 计算符文套装数据
--[[
{
	[3] = level,
	[5] = level,
	[8] = level,
}
--]]
function FuwenData:CalcFuwenSuitLevelData()
	local level_list = {}
	for k, v in pairs(self.fuwen_list) do
		local suit_level = self:GetFuwenSuitLevel(v.item_id)
		if suit_level > 0 then
			level_list[#level_list + 1] = suit_level
		end
	end

	local level_num_list = {}
	for k, v in pairs(level_list) do
		if nil == level_num_list[v] then
			level_num_list[v] = 0
			for _, level in pairs(level_list) do
				if level == v then
					level_num_list[v] = level_num_list[v] + 1
				end
			end
		end
	end

	local function get_Level_num(level)
		local num = 0
		for k, v in pairs(level_num_list) do
			if k >= level then
				num = num + v
			end
		end
		return num
	end

	local suit_level_data = {}
	for k, v in pairs(self.suit_plus_cfg) do
		local level_num = get_Level_num(v.level)
		for _, plus_cfg in pairs(v.plus) do
			if level_num >= plus_cfg.count then
				if nil == suit_level_data[plus_cfg.count] then
					suit_level_data[plus_cfg.count] = v.level
				elseif v.level > suit_level_data[plus_cfg.count] then
					suit_level_data[plus_cfg.count] = v.level
				end
			end
		end
	end

	for count, level in pairs(suit_level_data) do
		if nil == self.suit_level_data[count] or self.suit_level_data[count] ~= level then
			self.suit_level_data[count] = level
			if count == FuwenData.ACT_ANGER_SUIT_COUNT then
				GlobalEventSystem:Fire(ObjectEventType.MAX_ANGER_VAL_CHANGE)
			end
		end
	end
end

function FuwenData:GetFuwenSuitLevelData()
	return self.suit_level_data
end

function FuwenData.GetFuwenScore(fuwen_data)
	return ItemData.Instance:GetItemScore(ItemData.Instance:GetItemConfig(fuwen_data.item_id))
end

-- 在背包中最高分的符文
function FuwenData:GetMaxFuwenByInBag(fuwen_index)
	local max_score = 0
	local max_data = nil
	-- 背包上最高分的符文
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if ItemData.GetIsFuwen(v.item_id) then
			local _boss_index, _fuwen_index = ItemData.GetItemFuwenIndex(v.item_id)
			if fuwen_index == _fuwen_index then
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				local _score = ItemData.Instance:GetItemScore(item_cfg)
				if _score > max_score then
					-- 穿戴等级限制
					if not(EquipData.CheckHasLimit(item_cfg, ignore_level))then
						max_score = _score
						max_data = v
					end
				end
			end
		end
	end

	-- 是否比身上的好
	if self:GetIsBetterFuwen(max_data) then
		return max_data
	end
end

--检查当前装备是否比装备在身上的符文更好
function FuwenData:GetIsBetterFuwen(item_data, ignore_level)
	if item_data == nil then
		return false
	end

	local _, fuwen_index = ItemData.GetItemFuwenIndex(item_data.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)

	-- 是否是符文
	if item_cfg.type ~= ItemData.ItemType.itRune then
		return false
	end

	-- 穿戴等级限制
	if EquipData.CheckHasLimit(item_cfg, ignore_level) then
		return false
	end

	local cur_fuwen_data = self:GetFuwenData(fuwen_index)
	local cur_fuwen_score = cur_fuwen_data and FuwenData.GetFuwenScore(cur_fuwen_data) or 0

	local fuwen_score = FuwenData.GetFuwenScore(item_data)

	if cur_fuwen_score < fuwen_score then
		return true, fuwen_score
	end
	return false
end

------------------------------------------------------------------------------
-- 符文可以注灵
function FuwenData:FuwenCanZhulingRemind()
	if not self:GetZhulingActState() then
		return 0
	end

	local consume_data = self:GetFuwenZhulingConsume()
	local is_enough = false
	if nil ~= consume_data then
		local need_item_id = consume_data[1] and consume_data[1].id or 0
		local need_num = consume_data[1] and consume_data[1].count or 0
		local have_num = BagData.Instance:GetItemNumInBagById(need_item_id)
		is_enough = have_num >= need_num
	end
	return is_enough and 1 or 0
end

-- 背包中有更好的符文
function FuwenData:GetBetterFuwenRemind()
	for i = 1, FuwenData.RUNE_PARTS do
		if nil ~= FuwenData.Instance:GetMaxFuwenByInBag(i) then
			return 1
		end
	end
	return 0
end

-- 背包中可分解的符文
function FuwenData:GetCanDecomposeFuwenRemind()
	local cfg = EquipDecomposeConfig[EQUIP_DECOMPOSE_TYPES.FUWEN]
	local item_map = cfg.itemList
	for k, v in pairs(BagData.Instance:GetItemDataList()) do
		if item_map[v.item_id] then
			return 1
		end
	end

	return 0
end

-- 可以合成符文
function FuwenData.GetCanExchangeFuwenRemind()
	-- local items_cfg = ItemSynthesisConfig[3]
	-- for i = 1, 4 do
	-- 	local synthesis_cfg = items_cfg.itemList[(8 * i)]
	-- 	if nil == synthesis_cfg then break end
	-- 	local one_consume_data = ItemData.FormatItemData(synthesis_cfg.consume[1])
	-- 	local bag_num = BagData.Instance:GetItemNumInBagById(one_consume_data.item_id)
	-- 	local one_item_data = ItemData.FormatItemData(synthesis_cfg.award[1])
	-- 	-- 碎片数量满足时,判断身上是否有比当前套装低级
	-- 	if bag_num >= one_consume_data.num then
	-- 		for j = 1, 8 do
	-- 			synthesis_cfg = items_cfg.itemList[(j + (i - 1) * 8)]
	-- 			one_item_data = ItemData.FormatItemData(synthesis_cfg.award[1])
	-- 			local boor = FuwenData.Instance:GetIsBetterFuwen(one_item_data)
	-- 			if boor then
	-- 				return 1
	-- 			end
	-- 		end
	-- 	end
	-- end
	return 0
end

-- 检查全套符文转数大于 param 
function FuwenData:CheckFuwenCircle(param)
	for i = 1, FuwenData.RUNE_PARTS do
		local fuwen_equip = self:GetFuwenData(i)
		if fuwen_equip then
			local limit_level, zhuan = ItemData.GetItemLevel(fuwen_equip.item_id)
			if zhuan < param then
				return false
			end
		else
			return false
		end
	end
	return true
end
