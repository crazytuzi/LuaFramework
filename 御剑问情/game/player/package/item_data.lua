--数据列表单项改变原因
DATALIST_CHANGE_REASON = {
	UPDATE = 0, 				-- 更新
	ADD = 1,					-- 添加
	REMOVE = 2,					-- 移除
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
	self.grid_extend_times_by_item = 0				-- 手动开启的格子数目
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

	self.gem_list = {}								-- 宝石列表
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
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_EQUIPMENT end

	item_cfg = self.expense_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_EXPENSE end

	item_cfg = self.gift_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_GIF end

	item_cfg = self.other_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_OTHER end

	item_cfg = self.virtual_list_cfg[item_id]
	if nil ~= item_cfg then return item_cfg, GameEnum.ITEM_BIGTYPE_VIRTUAL end

	return nil, nil
end

function ItemData:GetItemMaxOrder(role_lv)
	local check_cfg = ConfigManager.Instance:GetAutoConfig("equipment_strategy_auto").equipment
	local role_lv = role_lv or 1
	for k,v in pairs(check_cfg) do
		if role_lv < v.role_level then
			return v.order
		end
	end
	return 0
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

function ItemData:GetGridData(index)
	if index < COMMON_CONSTS.MAX_BAG_COUNT then
		return self.item_data_list[index]
	else
		return self.ck_data_list[index]
	end
end

function ItemData:GetMaxKnapsackValidNum()
	return self.max_knapsack_valid_num
end

function ItemData:GridExtendTimesByItem()
	return self.grid_extend_times_by_item
end
function ItemData:SetMaxKnapsackValidNum(max_knapsack_valid_num)
	self.max_knapsack_valid_num = max_knapsack_valid_num
end

function ItemData:SetGridExtendTimesByItem(grid_extend_times_by_item)
	self.grid_extend_times_by_item = grid_extend_times_by_item
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

	self.gem_list = {}
	for k,v in pairs(self.item_data_list) do
		self:ChangeGemList(v.item_id, v.index, v)
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
			self:ChangeGemList(change_item_id, data.index, nil)
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
			self:ChangeGemList(data.item_id, data.index, t)
			self.hold_knapsack_num = self.hold_knapsack_num + 1

			local _, big_type = self:GetItemConfig(change_item_id)
			self:ClearCacheItemListType(big_type)
		else
			self.ck_data_list[data.index] = t
			self.hold_storage_num = self.hold_storage_num + 1
		end
	end

	 --delay notice
	if change_reason ~= DATALIST_CHANGE_REASON.REMOVE
		and (put_reason == PUT_REASON_TYPE.PUT_REASON_LUCKYROLL or put_reason == PUT_REASON_TYPE.PUT_REASON_LUCKYROLL_CS
		 or put_reason == PUT_REASON_TYPE.PUT_REASON_ZODIAC_GGL_REWARD or put_reason == PUT_REASON_TYPE.PUT_REASON_WABAO
		 or put_reason == PUT_REASON_TYPE.PUT_REASON_MOVE_CHESS or put_reason == PUT_REASON_TYPE.PUT_REASON_RA_LEVEL_LOTTERY
		 or put_reason == PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD
		 or put_reason == PUT_REASON_TYPE.PUT_REASON_ONLINE_REWARD
		 or put_reason == PUT_REASON_TYPE.PUT_REASON_YUANBAO_ZHUANPAN)then
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
	end
end

function ItemData:ChangeParamInGrid(data, isLast)
	local t = self:GetGridData(data.index)
	if t ~= nil then
		local change_reason = DATALIST_CHANGE_REASON.UPDATE
		local change_item_id = t.item_id
		local change_item_index = data.index
		if data.param then
			t.param = TableCopy(data.param)
		end
		for k, v in pairs(self.notify_data_change_callback_list) do  --物品有变化，通知观察者，带消息体
			v(change_item_id, change_item_index, change_reason, nil, t.num, t.num, true , isLast)
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

--获取礼包物品表
function ItemData:GetGiftItemList(item_id)
	local gift_cfg, big_type = self:GetItemConfig(item_id)
	if gift_cfg == nil or big_type ~= GameEnum.ITEM_BIGTYPE_GIF then return {} end
	local reward_list = {}
	local prof = PlayerData.Instance:GetRoleBaseProf()

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

--获取礼包物品表（区分职业，随机礼包不读）
function ItemData:GetGiftItemListByProf(gift_id)
	local gift_cfg = self:GetItemConfig(gift_id)
	local reward_list = {}
	if not gift_cfg or gift_cfg.rand_num == 1 then return reward_list end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	if gift_cfg.item_num then
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

function ItemData:ChangeGemList(item_id, index, data)
	local gem_cfg = ForgeData.Instance:GetGemCfg(item_id)
	if nil ~= gem_cfg then
		local cfg = self:GetItemConfig(item_id)
		if index < COMMON_CONSTS.MAX_BAG_COUNT then
			local stone_type = gem_cfg.stone_type
			if nil == self.gem_list[stone_type] then
				self.gem_list[stone_type] = {}
			end
			if nil ~= data then
				data.cfg = cfg
			end
			self.gem_list[stone_type][index] = data
		end
	end
end

function ItemData:GetGemsInBag(gem_type)
	return self.gem_list[gem_type]
end
--获得给定搜索类型和阶数的红装配置
function ItemData:GetRedEquipCfgBySearchTypeAndOrder(search_type,order)
	for k,v in pairs(self.equipment_list_cfg) do
		if v.search_type == search_type and v.order == order and v.color == 5 then
			return v;
		end
	end
	return nil
end

--------------------------------
--展示物品接口
--------------------------------

--获取展示物品战力
function ItemData.GetFightPower(item_id, item_id2)
	local fight_power = 0
	local cfg = {}
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return 0
	end
	fight_power = item_cfg.power
	local display_role = item_cfg.is_display_role
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION then
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				cfg = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
			cfg = MultiMountData.Instance:GetMountCfgByItemId(item_id) or {}
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					cfg = FootData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == item_id then
				cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(v.active_image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		local is_huanhua = false
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				is_huanhua = true
				break
			end
		end
		if not is_huanhua then
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						cfg = GoddessData.Instance:GetXianNvLevelCfg(v.id, 1) or {}
						fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
						break
					end
				end
			end
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetZhiBaoHuanHua()) do
			if v.stuff_id == item_id then
				cfg = ZhiBaoData.Instance:GetHuanHuaLevelCfg(v.huanhua_type, false, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	end
	return fight_power
end

--设置展示物品模型
function ItemData.ChangeModel(model, item_id, item_id2)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	if model then
		local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
		model.display:SetRotation(Vector3(0, 0, 0))
		if display_role ~= DISPLAY_TYPE.FOOTPRINT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		model:SetRoleResid(main_role:GetRoleResId())
		model:SetWingResid(res_id)
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetFootResid(res_id)
			model.display:SetRotation(Vector3(0, -90, 0))
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.MULTI_MOUNT then
		cfg = MultiMountData.Instance:GetMountCfgByItemId(item_id) or {}
		local mount_grade_cfg = MultiMountData.Instance:GetMountInfoCfgByIndex(cfg.mount_id or 1)
		bundle, asset = ResPath.GetMountModel(mount_grade_cfg.res_id)
		res_id = mount_grade_cfg.res_id
		model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..game_vo.prof..game_vo.sex]
				else
					weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
			end

		end
		if res_id == 0 then
			res_id = main_role:GetRoleResId()
		end
		if weapon_res_id == 0 then
			weapon_res_id = main_role:GetWeaponResId()
			weapon2_res_id = main_role:GetWeapon2ResId()
		end

		model:SetRoleResid(res_id)
		model:SetWeaponResid(weapon_res_id)
		if weapon2_res_id then
			model:SetWeapon2Resid(weapon2_res_id)
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.weapon_res_id = v.res_id
				ItemData.SetModel(model, info)
				return res_id
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.wing_res_id = v.res_id
				ItemData.SetModel(model, info)
				return res_id
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
				ItemData.SetModel(model, info, DISPLAY_TYPE.XIAN_NV)
				return res_id
			end
			res_id = xiannv_resid
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == item_id then
				bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
				res_id = v.image_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.TOU_SHI then
		local cfg_info = TouShiData.Instance:GetSpecialImageCfgInfoByItemId(item_id)
		if cfg_info then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.prof = main_vo.prof
			info.sex = main_vo.sex
			info.appearance = {}
			info.appearance.fashion_body = main_vo.appearance.fashion_body
			info.appearance.toushi_used_imageid = cfg_info.image_id + 1000				--特殊形象加1000
			model:ResetRotation()
			model:SetModelResInfo(info, true, true, true, true, true, true)
			return
		end

	elseif display_role == DISPLAY_TYPE.YAO_SHI then
		local cfg_info = WaistData.Instance:GetSpecialImageCfgInfoByItemId(item_id)
		if cfg_info then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.prof = main_vo.prof
			info.sex = main_vo.sex
			info.appearance = {}
			info.appearance.fashion_body = main_vo.appearance.fashion_body
			info.appearance.yaoshi_used_imageid = cfg_info.image_id + 1000				--特殊形象加1000
			model:ResetRotation()
			model:SetModelResInfo(info, true, true, true, true, true, true)
			return
		end

	elseif display_role == DISPLAY_TYPE.MIAN_SHI then
		local cfg_info = MaskData.Instance:GetSpecialImageCfgInfoByItemId(item_id)
		if cfg_info then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.prof = main_vo.prof
			info.sex = main_vo.sex
			info.appearance = {}
			info.appearance.fashion_body = main_vo.appearance.fashion_body
			info.appearance.mask_used_imageid = cfg_info.image_id + 1000				--特殊形象加1000
			model:ResetRotation()
			model:SetModelResInfo(info, true, true, true, true, true, true)
			return
		end

	elseif display_role == DISPLAY_TYPE.QIN_LIN_BI then
		local cfg_info = QilinBiData.Instance:GetSpecialImageCfgInfoByItemId(item_id)
		if cfg_info then
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			bundle, asset = ResPath.GetQilinBiModel(cfg_info["res_id" .. main_vo.sex .. "_h"], main_vo.sex)
			model:ResetRotation()
		end
	end

	if bundle and asset and model then
		model:SetMainAsset(bundle, asset)
		if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT and display_role ~= DISPLAY_TYPE.QIN_LIN_BI then
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
	end
	return res_id
end

function ItemData.SetModel(model, info, display_type)
	model:ResetRotation()
	model:SetGoddessModelResInfo(info)
	model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
end

local SPEC_MODEL_NAME = {
	[7053001] = "normal_mount_1",
	[7058001] = "normal_mount_2",
	[7113001] = "normal_fight_mount_1",
	[7114001] = "normal_fight_mount_2",
	[7111001] = "normal_fight_mount_3",
	[7115001] = "normal_fight_mount_4",
	[7116001] = "normal_fight_mount_5",
	[7117001] = "normal_fight_mount_6",
	[13005] = "normal_zhibao2",
	[13016] = "normal_zhibao3",
	[13017] = "normal_zhibao4",
}

local MODEL_NAME = {
		[DISPLAY_TYPE.MOUNT] = "normal_mount_panel",
		[DISPLAY_TYPE.WING] = "normal_fashion_panel",
		[DISPLAY_TYPE.FOOTPRINT] = "normal_foot_panel",
		[DISPLAY_TYPE.FASHION] = "normal_fashion_panel",
		[DISPLAY_TYPE.HALO] = "normal_fashion_panel",
		[DISPLAY_TYPE.SPIRIT] = "normal_spirit_panel",
		[DISPLAY_TYPE.FIGHT_MOUNT] = "normal_fight_mount_panel",
		[DISPLAY_TYPE.SHENGONG] = "normal_xian_nv_panel",
		[DISPLAY_TYPE.SHENYI] = "normal_xian_nv_panel",
		[DISPLAY_TYPE.XIAN_NV] = "normal_xian_nv_panel",
		[DISPLAY_TYPE.ZHIBAO] = "normal_zhibao_panel",
	}

--display w 1000 h 800 scale 0.56
function ItemData.SetModelName(model, display_type, res_id)
	if res_id and SPEC_MODEL_NAME[res_id] then
		model:SetPanelName(SPEC_MODEL_NAME[res_id])
	else
		model:SetPanelName(MODEL_NAME[display_type] or MODEL_NAME[DISPLAY_TYPE.FASHION])
	end
end

--获取临时的有星级数量的物品数据
local temp_xianpin_list = {
	{58},
	{58, 59},
	{58, 59, 60},
}
function ItemData:GetTempItemDataByStar(item_id, star)
	local data = {item_id = item_id}
	if star > 0 then
		data.param = {}
		data.param.xianpin_type_list = temp_xianpin_list[star]
	end

	return data
end