--数据列表单项改变原因
DATALIST_CHANGE_REASON = {
	UPDATE = 0, 				-- 更新
	ADD = 1,					-- 添加
	REMOVE = 2,					-- 移除
}

-- 延迟通知物品获得
local DEALY_NOTICE_TYPE = {
	[PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY] = true,
	[PUT_REASON_TYPE.PUT_REASON_LUCKYROLL] = true,
	[PUT_REASON_TYPE.PUT_REASON_LUCKYROLL_CS] = true,
	[PUT_REASON_TYPE.PUT_REASON_WABAO] = true,
	[PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD] = true,
	[PUT_REASON_TYPE.PUT_REASON_LUCKYCHESS_REWARD] = true,
	[PUT_REASON_TYPE.PUT_REASON_LUCKY_TURNTABLE_REWARD] = true,
	[PUT_REASON_TYPE.PUT_REASON_ADVENTURE_SHOP_REWARD] = true,
}

ItemData = ItemData or BaseClass()
function ItemData:__init()
	if ItemData.Instance then
		print_error("[ItemData] Attemp to create a singleton twice !")
	end

	ItemData.Instance = self

	self.equipment_list_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	self.expense_list_cfg = ConfigManager.Instance:GetAutoItemConfig("expense_auto")
	self.gift_list_cfg = ConfigManager.Instance:GetAutoItemConfig("gift_auto")
	self.other_list_cfg = ConfigManager.Instance:GetAutoItemConfig("other_auto")
	self.virtual_list_cfg = ConfigManager.Instance:GetAutoItemConfig("virtual_auto")

	self.max_knapsack_valid_num = 0					-- 开启到的最大背包数
	self.hold_knapsack_num = 0						-- 占用的背包格子数

	self.max_storage_valid_num = 0					-- 开启到的最大仓库数
	self.hold_storage_num = 0						-- 占用的仓库格子数

	self.item_data_list = {}						-- 只存背包中的数据（大多数系统都是用这个）
	self.ck_data_list = {}							-- 只存仓库中的数据

	self.item_id_num_t = {}							-- 物品个数, id为key, num为value (不区分绑定非绑)
	self.cache_item_type_list = {}					-- 类型为key，列表为value

	self.notify_data_change_callback_list = {}		--物品有更新变化时进行回调
	self.notify_datalist_change_callback_list = {} 	--物品列表有变化时回调，一般是整理时，或初始化物品列表时

	self.delay_notice_list = {}
	self.normal_reward_list = {}					--普通奖励列表(奖励显示用)
end

function ItemData:__delete()
	ItemData.Instance = nil
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

--获得物品配置
function ItemData:GetItemConfig(item_id)
	local item_cfg = nil

	item_cfg = self.equipment_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_EQUIPMENT end	-- 装备

	item_cfg = self.expense_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_EXPENSE end		-- 消耗类型

	item_cfg = self.gift_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_GIF end			-- 礼包类型

	item_cfg = self.other_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_OTHER end		-- 被动使用类型

	item_cfg = self.virtual_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_VIRTUAL end		-- 虚拟类型

	return nil, nil
end

function ItemData:GetGridData(index)
	if index < COMMON_CONSTS.MAX_BAG_COUNT then
		return self.item_data_list[index]
	else
		return self.ck_data_list[index]
	end
end

function ItemData:GetCanTradeList()
	local data_list = {}
	for k,v in pairs(self.item_data_list) do
		if v.is_bind ~= 1 then
			local data = TableCopy(v)
			data.bag_index = k
			table.insert(data_list, data)
		end
	end

	return data_list
end

function ItemData:GetMaxKnapsackValidNum()
	return self.max_knapsack_valid_num
end

function ItemData:SetMaxKnapsackValidNum(max_knapsack_valid_num)
	self.max_knapsack_valid_num = max_knapsack_valid_num
end

function ItemData:GetEmptyNum()
	return self.max_knapsack_valid_num - self.hold_knapsack_num
end

function ItemData:GetMaxStorageValidNum()
	return self.max_storage_valid_num
end

function ItemData:SetMaxStorageValidNum(max_storage_valid_num)
	self.max_storage_valid_num = max_storage_valid_num
end

function ItemData:GetStorageEmptyNum()
	return self.max_storage_valid_num - self.hold_storage_num
end

function ItemData:GetBagItemDataList()
	return self.item_data_list
end

function ItemData:SetDataList(datalist)
	self.item_data_list = {}
	self.ck_data_list = {}
	self.item_id_num_t = {}
	self.cache_item_type_list = {}
	self.delay_notice_list = {}
	self.hold_knapsack_num = 0
	self.hold_storage_num = 0

	for _, v in pairs(datalist) do
		if v.index < COMMON_CONSTS.MAX_BAG_COUNT then
			self.item_data_list[v.index] = v
			self.item_id_num_t[v.item_id] = (self.item_id_num_t[v.item_id] or 0) + v.num
			if v.num > 0 and v.item_id > 0 then
				self.hold_knapsack_num = self.hold_knapsack_num + 1
			end
		else
			self.ck_data_list[v.index] = v
			if v.num > 0 and v.item_id > 0 then
				self.hold_storage_num = self.hold_storage_num + 1
			end
		end
	end

	for k, v in pairs(self.notify_datalist_change_callback_list) do  --物品有变化，通知观察者，不带消息体
		v()
	end
end

function ItemData:ChangeDataInGrid(data)
	if data == nil then
		return
	end

	local change_reason = DATALIST_CHANGE_REASON.UPDATE
	local change_item_id = data.item_id
	local change_item_index = data.index
	local t = self:GetGridData(data.index)
	local put_reason = data.reason_type --self.change_type
	local old_num = 0
	local new_num = 0

	if t ~= nil and data.num == 0 then --delete
		old_num = t.num
		new_num = 0
		change_reason = DATALIST_CHANGE_REASON.REMOVE
		change_item_id = t.item_id

	elseif t == nil	then			   --add
		change_reason = DATALIST_CHANGE_REASON.ADD
		t = {}
	end

	if t ~= nil then
		old_num = t.num or 0
		new_num = data.num

		t.index = data.index
		t.item_id = data.item_id
		t.num = data.num
		t.is_bind = data.is_bind
		t.invalid_time = data.invalid_time
		if data.param then
			t.param = data.param
		end
		t.has_param = data.has_param
		t.gold_price = data.gold_price
	end

	if data.index < COMMON_CONSTS.MAX_BAG_COUNT then
		self.item_id_num_t[change_item_id] = (self.item_id_num_t[change_item_id] or 0) + (new_num - old_num)
	end

	if DATALIST_CHANGE_REASON.REMOVE == change_reason then
		if data.index < COMMON_CONSTS.MAX_BAG_COUNT then
			self.item_data_list[data.index] = nil
			self.hold_knapsack_num = self.hold_knapsack_num - 1

			local _, big_type = self:GetItemConfig(change_item_id)
			self:ClearCacheItemListType(big_type)
		else
			self.ck_data_list[data.index] = nil
			self.hold_storage_num = self.hold_storage_num - 1
		end

	elseif DATALIST_CHANGE_REASON.ADD == change_reason then
		if data.index < COMMON_CONSTS.MAX_BAG_COUNT then
			self.item_data_list[data.index] = t
			self.hold_knapsack_num = self.hold_knapsack_num + 1

			local _, big_type = self:GetItemConfig(change_item_id)
			self:ClearCacheItemListType(big_type)
		else
			self.ck_data_list[data.index] = t
			self.hold_storage_num = self.hold_storage_num + 1
		end
	end
	 --delay notice
	local is_delay_daily = put_reason == PUT_REASON_TYPE.PUT_REASON_DAILY_TASK_DRAW and not GuildData.Instance:GetGuildRollShowNow() and not DayCounterCtrl.Instance:GetLockOpenTaskRewardPanel()
	if change_reason ~= DATALIST_CHANGE_REASON.REMOVE
		and (DEALY_NOTICE_TYPE[put_reason] or is_delay_daily) then
		local notice_t = {}
		notice_t.change_item_id = change_item_id
		notice_t.change_item_index = change_item_index
		notice_t.change_reason = change_reason
		notice_t.put_reason = put_reason
		notice_t.old_num = old_num
		notice_t.new_num = new_num
		notice_t.notice_time_stamp = Status.NowTime + 5

		local is_had_delay = false
		for k, v in pairs(self.delay_notice_list) do
			if v.change_item_index == change_item_index then
				v.new_num = v.new_num + new_num
				is_had_delay = true
			end
		end
		if not is_had_delay then
			table.insert(self.delay_notice_list, notice_t)
		end
	else
		self:NoticeOneItemChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, false, t)
		TipsCtrl.Instance:ShowRareItemTips({item_id = change_item_id, num = new_num - old_num})
	end
end

function ItemData:ChangeParamInGrid(data)
	local t = self:GetGridData(data.index)
	if t ~= nil then
		local change_reason = DATALIST_CHANGE_REASON.UPDATE
		local change_item_id = t.item_id
		local change_item_index = data.index
		if data.param then
			t.param = TableCopy(data.param)
		end
		for k, v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
			v(change_item_id, change_item_index, change_reason, nil, t.num, t.num, true)
		end
	end
end

function ItemData:NoticeOneItemChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	for _, v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
		v(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	end
end

function ItemData:GetNotifyCallBackNum()
	local num = 0
	for _, v in pairs(self.notify_data_change_callback_list) do
		num = num + 1
	end

	for _, v in pairs(self.notify_datalist_change_callback_list) do
		num = num + 1
	end

	return num
end

function ItemData:NotifyDataChangeCallBack(callback, notify_datalist)
	if callback == nil then
		return
	end

	if notify_datalist == true then
		self.notify_datalist_change_callback_list[callback] = callback
	else
		self.notify_data_change_callback_list[callback] = callback
		local count = 0
		for k, v in pairs(self.notify_data_change_callback_list) do
			count = count + 1
		end
		if count >= 30 then
			print_log(string.format("监听物品数据的地方多达%d条，请检查！", count))
		end
	end
end

function ItemData:UnNotifyDataChangeCallBack(callback)
	if callback == nil then
		return
	end

	self.notify_data_change_callback_list[callback] = nil
	self.notify_datalist_change_callback_list[callback] = nil
end

function ItemData:HandleDelayNoticeNow(put_reason)
	for i = #self.delay_notice_list, 1, -1 do
		t = table.remove(self.delay_notice_list, i)
		if t ~= nil and (put_reason == nil or t.put_reason == put_reason) then
			self:NoticeOneItemChange(t.change_item_id, t.change_item_index, t.change_reason, t.put_reason, t.old_num, t.new_num)
			TipsCtrl.Instance:ShowRareItemTips({item_id = t.change_item_id, num = t.new_num - t.old_num})
		end
	end
end

function ItemData:GetItemNumInBagById(item_id)
	return self.item_id_num_t[item_id] or 0
end

function ItemData:ClearCacheItemListType(big_type)
	if nil ~= big_type then
		self.cache_item_type_list[big_type] = nil
	end
end

function ItemData:GetItemListByBigType(big_type)
	if nil ~= self.cache_item_type_list[big_type] then
		return self.cache_item_type_list[big_type]
	end

	local list = {}

	for _, v in pairs(self.item_data_list) do
		local _, temp_type = self:GetItemConfig(v.item_id)
		if temp_type == big_type then
			table.insert(list, v)
		end
	end

	self.cache_item_type_list[big_type] = list

	return list
end

function ItemData:GetItemName(item_id)
	local item_cfg, _ = self:GetItemConfig(item_id)
	return item_cfg and item_cfg.name or ""
end

--获得背包里的物品数量
function ItemData:GetItemNumInBagByIndex(index, item_id)
	local data = self:GetGridData(index)
	if data then
		if item_id then
			if data.item_id == item_id then
				return data.num
			end
		else
			return data.num
		end
	end
	return 0
end

--根据物品id获得在背包中的index
function ItemData:GetItemIndex(item_id)
	for k,v in pairs(self.item_data_list) do
		if v.item_id == item_id then
			return v.index
		end
	end
	return -1
end

function ItemData:GetItemIndexByIdAndBind(item_id, is_bind)
	for k,v in pairs(self.item_data_list) do
		if v.item_id == item_id and v.is_bind == is_bind then
			return v.index
		end
	end
	return -1
end

--获取礼包物品表
function ItemData:GetGiftItemList(item_id)
	local gift_cfg = ItemData.Instance:GetItemConfig(item_id)
	if gift_cfg == nil then return {} end
	local reward_list = {}
	local prof = PlayerData.Instance:GetRoleBaseProf()

	if gift_cfg.item_num == nil then
		return {}
	end

	for i=1, gift_cfg.item_num do
		if gift_cfg["item_" .. i .. "_num"] > 0 then
			local vo = {}
			vo.item_id = gift_cfg["item_" .. i .. "_id"]
			vo.num = gift_cfg["item_" .. i .. "_num"]
			vo.is_bind = gift_cfg["is_bind_" .. i]
			if gift_cfg.rand_num ~= 1 and gift_cfg.is_check_prof == 1 then
				local item_cfg = self:GetItemConfig(vo.item_id)
				if item_cfg and (item_cfg.limit_prof == 5 or item_cfg.limit_prof == prof) then
					table.insert(reward_list, vo)
				end
			else
				table.insert(reward_list, vo)
			end
		end
	end
	return reward_list
end

function ItemData:GetGifeFixedItemList(item_id)
	local gift_cfg = ItemData.Instance:GetItemConfig(item_id)
	if gift_cfg == nil then return {} end
	local reward_list = {}
	local prof = PlayerData.Instance:GetRoleBaseProf()

	if gift_cfg.certain_item == nil or next(gift_cfg.certain_item) == nil then
		return {}
	end

	for k,v in pairs(gift_cfg.certain_item) do
		if v ~= nil then
			-- local data = {}
			-- local check_data = Split(v, ":")
			-- if check_data ~= nil and next(check_data ~= nil) then
			-- 	data.item_id = check_data[1]
			-- 	data.num = check_data[2]
			-- 	data.is_bind = check_data[3]
				local item_cfg = self:GetItemConfig(v.item_id)
				if item_cfg and (item_cfg.limit_prof == 5 or item_cfg.limit_prof == prof) then
					table.insert(reward_list, v)
				end

			-- end
		end
	end

	return reward_list
end

--获取礼包物品表（区分职业，随机礼包不读）
function ItemData:GetGiftItemListByProf(gift_id)
	local gift_cfg = self:GetItemConfig(gift_id)
	local reward_list = {}
	if not gift_cfg or gift_cfg.rand_num == 1 or gift_cfg.item_num == nil then return reward_list end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	for i = 1, gift_cfg.item_num do
		local num = gift_cfg["item_" .. i .. "_num"]
		if num > 0 then
			local item_id = gift_cfg["item_" .. i .. "_id"]
			local is_bind = gift_cfg["is_bind_" .. i]
			local vo = {}
			vo.item_id = item_id
			vo.num = num
			vo.is_bind = is_bind

			local is_ignore = false
			local item_cfg, big_type = self:GetItemConfig(item_id)
			if nil ~= item_cfg and gift_cfg.is_check_prof == 1 then
				if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
					if item_cfg.limit_prof == prof or item_cfg.limit_prof == 5 then
						table.insert(reward_list, vo)
					end
					is_ignore = true
				end
			end
			if not is_ignore then
				table.insert(reward_list, vo)
			end
		end
	end
	return reward_list
end

--获得所有非绑物品
function ItemData:GetBagNoBindItemList()
	local bag_no_bind_list = {}
	for k,v in pairs(self.item_data_list) do
		if v.is_bind == 0 then
			table.insert(bag_no_bind_list, v)
		end
	end
	return bag_no_bind_list
end

--根据物品id获得物品（如果同个物品出现在多个格子只能拿到第一个）
function ItemData:GetItem(item_id)
	for k,v in pairs(self.item_data_list) do
		if v.item_id == item_id then
			return v
		end
	end

	return nil
end

--背包是否足够对应数量
function ItemData:GetItemNumIsEnough(item_id, need_num)
	return self:GetItemNumInBagById(item_id) >= need_num
end

--设置普通奖励获取列表
function ItemData:SetNormalRewardList(reward_list)
	self.normal_reward_list = reward_list
end

function ItemData:GetNormalRewardList()
	return self.normal_reward_list or {}
end

--根据物品id获得物品描述
function ItemData:GetItemDescription(item_id)
	local item_cfg, big_type = self:GetItemConfig(item_id)
	if item_cfg == nil then
		return
	end

	local str = ""
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local description = item_cfg.description
	if big_type == GameEnum.ITEM_BIGTYPE_GIF and (not description or description == "") then
		if item_cfg.need_gold and item_cfg.need_gold > 0 then
			description = string.format(Language.Tip.GlodGiftTip, item_cfg.need_gold)
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.GlodRandomGiftTip, item_cfg.need_gold, item_cfg.rand_num)
			end
		elseif item_cfg.gift_type and item_cfg.gift_type == 3 then
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.SelectGiftTip, item_cfg.rand_num)
			end
		else
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.RandomGiftTip, item_cfg.rand_num)
			end
		end

		str = description

		local fix_data = TableCopy(self:GetGifeFixedItemList(item_id))
		if fix_data ~= nil and next(fix_data) ~= nil then
			description = Language.Tip.FixedGiftTip
			for k,v in pairs(fix_data) do
				local item_cfg2 = self:GetItemConfig(v.item_id)
				if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
					local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
					if description ~= "" then
						description = description.."\n"..color_name_str.."X"..v.num
					else
						description = description..color_name_str.."X"..v.num
					end
				end
			end

			description = description .. "\n"
			description = description .. "\n" .. str
		else
			description = str
		end

		for k, v in pairs(self:GetGiftItemList(item_id)) do
			local item_cfg2 = self:GetItemConfig(v.item_id)
			if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
				local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
				if description ~= "" then
					description = description.."\n"..color_name_str.."X"..v.num
				else
					description = description..color_name_str.."X"..v.num
				end
			end
		end
	end
	return description
end

--获得给定搜索类型和阶数的红装配置
function ItemData:GetRedEquipCfgBySearchTypeAndOrder(search_type, order)
	for k,v in pairs(self.equipment_list_cfg) do
		if v.search_type == search_type and v.order == order and v.color == 5 then
			return v
		end
	end
	return nil
end

function ItemData:GetItemMaxOrder(role_lv, limit_prof, sub_type)
	local section_data_list = self:GetEquipCfg(limit_prof, sub_type)
	if not next(section_data_list) then return end

	table.sort(section_data_list, function (a, b)
		return a.limit_level < b.limit_level
	end)

	local max_order = section_data_list[1].order
	for i=1, #section_data_list do
		if role_lv >= section_data_list[i].limit_level then
			max_order = section_data_list[i].order
		else
			break
		end
	end
	return max_order
end

function ItemData:GetEquipCfg(limit_prof, sub_type)
	local section_data_list = {}
	local flag = {}
	for k,v in pairs(self.equipment_list_cfg) do
		if limit_prof == v.limit_prof and sub_type == v.sub_type and not flag[v.limit_level] then
			table.insert(section_data_list, {limit_level = v.limit_level, order = v.order})
			flag[v.limit_level] = true
		end
	end
	return section_data_list
end