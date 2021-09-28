TreasureData = TreasureData or BaseClass()

TREASURE_ROW = 8 --格子列数
TREASURE_COLUMN = 4 --行数
TREASURE_ALL_ROW = 80 --背包总列数

TREASURE_SHOW_ROW = 5 --格子列数
TREASURE_SHOW_COLUMN = 2 --行数
TREASURE_SHOW_ALL_ROW = 25 --背包总列数
TREASURE_EXCHANGE_CONVER_TYPE = 3  --寻宝兑换类型
TREASURE_EXCHANGE_PRICE_TYPE = 5   --价格类型
RARE_EXCHANGE_TYPE = 9 --珍宝兑换类型
RARE_EXCHANGE_PRICE_TYPE = 5 	--珍宝兑换价格类型

function TreasureData:__init()
	if TreasureData.Instance then
		print_error("[TreasureData] Attemp to create a singleton twice !")
	end
	TreasureData.Instance = self
	self.turn_id_list = {}
	self.fixed_id_list = {}
	self.treasure_score = 0
	self.chest_item_info = {}
	self.chest_item_info_index = {}
	self.chest_shop_next_free_time_1 = -1
	self.chest_shop_jl_next_free_time_1 = -1
	self.count = -1
	self.current_chest_item_info = {}
	self.current_chest_count = 0
	self.open_days = 0
	self.remain_time = 0
	self.is_shield = false
	self.chest_shop_mode = -1
	self.is_show_limit_time = false
	self.show_cfg = self:GetShowAllItem()
	self.sort_info = {}
	-- GlobalEventSystem:Bind(BagFlushEventType.BAG_FLUSH_CONTENT, BindTool.Bind1(self.GetXunBaoRedPoint, self))

	RemindManager.Instance:Register(RemindName.XunBaoTreasure, BindTool.Bind(self.GetRemindXunBao, self))
	RemindManager.Instance:Register(RemindName.XunBaoWarehouse, BindTool.Bind(self.GetRemindWareHouse, self))
	RemindManager.Instance:Register(RemindName.RedEquipExchange, BindTool.Bind(self.CalcEquipExchangeRemind, self))
end

function TreasureData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XunBaoTreasure)
	RemindManager.Instance:UnRegister(RemindName.XunBaoWarehouse)
	RemindManager.Instance:UnRegister(RemindName.RedEquipExchange)

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	TreasureData.Instance = nil
end

function TreasureData:ClearData()
	self.current_chest_item_info = {}
end

function TreasureData:GetTreasureScore()
	return self.treasure_score
end

function TreasureData:GetIsShield()
	return self.is_shield
end

function TreasureData:SetIsShield(is_shield)
	self.is_shield = is_shield
end

function TreasureData:SetTreasureScore(treasure_score)
	self.treasure_score = treasure_score
end

function TreasureData:OnSelfChestShopItemList(protocol)
	self.chest_item_info = protocol.chest_item_info
	self.count = protocol.count
	self.chest_item_info_index = protocol.chest_item_info_index
end

function TreasureData:OnChestShopItemListPerBuy(protocol)
	self.current_chest_item_info = protocol.chest_item_info
	self.current_chest_count = protocol.count
	self:SortChestShopItemInfo(protocol.chest_item_info)
end

function TreasureData:SortChestShopItemInfo(info)
	self.sort_info = TableCopy(info)
	function sortfun(a, b)
		return a.sh_order > b.sh_order
	end

	table.sort(self.sort_info, sortfun)
end

function TreasureData:GetChestShopItemInfo()
	return self.sort_info
end

function TreasureData:GetCurrentChestCount()
	return self.current_chest_count
end

function TreasureData:SetOpenDays(open_days)
	self.open_days = open_days
end

function TreasureData:OnChestShopFreeInfo(protocol)
	self.chest_shop_next_free_time_1 = protocol.chest_shop_next_free_time_1
	self.chest_shop_jl_next_free_time_1 = protocol.chest_shop_jl_next_free_time_1
end

function TreasureData:GetChestFreeTime()
	return self.chest_shop_next_free_time_1
end

function TreasureData:GetChestJlFreeTime()
	return self.chest_shop_jl_next_free_time_1
end

function TreasureData:GetChestItemInfo()
	return self.chest_item_info
end

function TreasureData:GetChestItemInfoIndex()
	return self.chest_item_info_index
end

function TreasureData:GetCurrentChestItemInfo()
	local new_list = {}
	for k,v in pairs(self.current_chest_item_info) do
		new_list[#new_list + 1] = v
	end
	return new_list
end

function TreasureData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

function TreasureData:GetChestShopMode()
	return self.chest_shop_mode
end

function TreasureData:GetChestCount()
	return self.count
end

function TreasureData:SortList(is_first)
	if is_first == false then
		local new_list = {}
		new_list[1] = self.turn_id_list[#self.turn_id_list]
		for i=1,11 do
			new_list[#new_list + 1] = self.turn_id_list[i]
		end
		self.turn_id_list = {}
		self.turn_id_list = new_list
	end
	return self.turn_id_list
end

function TreasureData:GetTurnIdList()
	return self.turn_id_list
end


--获取需要加载的配置
function TreasureData:GetShowItemCfg(xunbao_type)
	local opengame_day = self:GetUseOpenGameDay(xunbao_type)
	local rare_item_list = ConfigManager.Instance:GetAutoConfig("chestshop_auto").rare_item_list
	local new_type_item_list = {}
	for k,v in pairs(rare_item_list) do
		if v.xunbao_type == xunbao_type and v.opengame_day == opengame_day then
			new_type_item_list[#new_type_item_list + 1] = v
		end
	end
	return new_type_item_list
end

--获得转动加载的配置
function TreasureData:GetTrunItemList(xunbao_type)
	local opengame_day = self:GetUseOpenGameDay(xunbao_type)
	for k,v in pairs(self:GetShowItemCfg(1)) do
		if v.display_index > 5 and v.opengame_day == opengame_day and v.xunbao_type == xunbao_type then
			self.turn_id_list[#self.turn_id_list + 1] =  v.rare_item_id
		end
	end
end

--获得固定加载的配置
function TreasureData:GetFixedItemList(xunbao_type)
	local opengame_day = self:GetUseOpenGameDay(xunbao_type)
	for k,v in pairs(self:GetShowItemCfg(1)) do
		if v.display_index <= 5 and v.opengame_day == opengame_day then
			self.fixed_id_list[#self.fixed_id_list + 1] =  v.rare_item_id
		end
	end
	return self.fixed_id_list
end

--获取物品被动消耗类配置
function TreasureData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

--获取所有兑换配置
function TreasureData:GetAllExchangeCfg()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

--获取单个兑换配置
function TreasureData:GetExchangeCfg(item_id)
	local item_list = self:GetAllExchangeCfg()
	for k,v in pairs(item_list) do
		if v.item_id == item_id then
			return v
		end
	end
end

function TreasureData:GetItemIdListByJobAndType(conver_type,price_type,job)
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type and v.price_type == price_type and (v.show_limit == job or v.show_limit == 5) then
			local cfg = {v.item_id, v.is_jueban}
			item_id_list[#item_id_list + 1] = cfg
		end
	end

	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	if not is_activity_open then
		for i = #item_id_list, 1, -1 do
			local list = item_id_list[i]
			if list[2] == 1 then
				table.remove(item_id_list, i)
			end
		end
	end
	return item_id_list
end

--获取珍宝兑换商品
function TreasureData:GetRareChangeList()
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == RARE_EXCHANGE_TYPE then
			if v.price_type == RARE_EXCHANGE_PRICE_TYPE then
				local cfg = {v.item_id, v.is_jueban}
				item_id_list[#item_id_list + 1] = cfg
			end
		end
	end
	return item_id_list
end

function TreasureData:GetItemListByJobAndIndex(conver_type, price_type,job,index)
	local all_item_id = self:GetItemListByJob(conver_type, price_type,job)

	local job_id_list = {}
	for i = 1, 8 do
		job_id_list[#job_id_list + 1] = all_item_id[(index - 1)*8 + i] or {0, 0}
	end
	return job_id_list
end

function TreasureData:GetItemListByJob(conver_type, price_type,job)
	local item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type,job)

	--如果有珍宝兑换
	local all_item_id = {}
	if self:IsFlashChange() then
		local rare_list = self:GetRareChangeList()
		for k, v in pairs(rare_list) do
			table.insert(all_item_id, v)
		end
		for k, v in pairs(item_id_list) do
			table.insert(all_item_id, v)
		end
	else
		all_item_id = item_id_list
	end

	return all_item_id
end

--通过索引获得展示寻宝格子对应的编号
function TreasureData:GetGridIndexById(item_id)
	for k,v in pairs(self.chest_item_info) do
		if v.item_id == item_id then
			return v.server_grid_index
		end
	end
	return -1
end

--通过索引获得展示寻宝格子对应的编号集合
function TreasureData:GetShowCellIndexList(cell_index)
	local cell_index_list = {}
	local x = math.floor(cell_index/TREASURE_SHOW_ROW)
	if x > 0 and x * TREASURE_SHOW_ROW ~= cell_index then
		cell_index = cell_index + TREASURE_SHOW_ROW * (TREASURE_SHOW_COLUMN - 1) * x
	elseif x > 1 and x * TREASURE_SHOW_ROW == cell_index then
		cell_index = cell_index + TREASURE_SHOW_ROW * (TREASURE_SHOW_COLUMN - 1) * (x - 1)
	end
	for i=1,2 do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + TREASURE_SHOW_ROW * (i - 1)
		end
	end
	return cell_index_list
end

--获取寻宝价格
function TreasureData:GetTreasurePrice(chest_shop_mode)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("chestshop_auto").other[1]
	local price = 0
	if chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_1 then
		price = other_cfg.gold_1
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_10 then
		price = other_cfg.gold_10
	elseif chest_shop_mode == CHEST_SHOP_MODE.CHEST_SHOP_MODE_50 then
		price = other_cfg.gold_30
	end
	return price
end

function TreasureData:GetOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("chestshop_auto").other[1]
end

function TreasureData:GetTreasureLimitLevel()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

--使用开服天数
function TreasureData:GetUseOpenGameDay(xunbao_type)
	local rare_item_list = ConfigManager.Instance:GetAutoConfig("chestshop_auto").rare_item_list
	local opengame_day_cfg_list = {}
	for k,v in pairs(rare_item_list) do
		if v.xunbao_type == xunbao_type then
			opengame_day_cfg_list[#opengame_day_cfg_list + 1] = v.opengame_day
		end
	end
	local list_2 = {}
	for k,v in pairs(opengame_day_cfg_list) do
		if #list_2 == 0 then
			list_2[#list_2 + 1] = v
		else
			local is_ok = true
			for m,n in pairs(list_2) do
				if n == v then
					is_ok = false
				end
			end
			if is_ok then
				list_2[#list_2 + 1] = v
			end
		end
	end
	function sortfun(a, b)
		return a < b
	end
	table.sort(list_2, sortfun)
	local use_open_day = 1
	if #list_2 == 1 then
		use_open_day = list_2[1]
	end
	if list_2[#list_2] <= self.open_days then
		use_open_day = list_2[#list_2]
	end
	for k,v in pairs(list_2) do
		if v > self.open_days then
			use_open_day = list_2[k - 1]
		end
	end
	return use_open_day
end

function TreasureData:GetRemindXunBao()
	return self:GetXunBaoRedPoint() and 1 or 0
end

function TreasureData:GetRemindWareHouse()
	return self:GetXunBaoWareRedPoint() and 1 or 0
end

function TreasureData:GetXunBaoWareRedPoint()
	local ware_red_point = false
	if ItemData.Instance:GetEmptyNum() > 0 then
		if self:GetChestCount() > 0 then
			ware_red_point = true
		end
	end
	return ware_red_point
end

function TreasureData:GetXunBaoRedPoint()

	local cfg = self:GetOtherCfg()
	local item_1 = cfg.equip_use_itemid
	local item_2 = cfg.equip_10_use_itemid
	local item_3 = cfg.equip_30_use_itemid
	local item_data = ItemData.Instance
	local my_item_1_count = item_data:GetItemNumInBagById(item_1)
	local my_item_2_count = item_data:GetItemNumInBagById(item_2)
	local my_item_3_count = item_data:GetItemNumInBagById(item_3)

	local xun_bao_red_point = false
	local can_chest_time = self:GetChestFreeTime()
	if can_chest_time - TimeCtrl.Instance:GetServerTime() < 0 then
		xun_bao_red_point = true
	else
		self:CalToSetRedPoint()
	end

	if my_item_3_count > 0 or my_item_2_count > 0 or my_item_1_count > 0 then
		xun_bao_red_point = true
	end

	return xun_bao_red_point
end

function TreasureData:CalToSetRedPoint()
	if self.timer_quest == nil then
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
			local can_chest_time = self:GetChestFreeTime()
			self.remain_time = can_chest_time - TimeCtrl.Instance:GetServerTime()
			if self.remain_time < 0 then
				GlobalTimerQuest:CancelQuest(self.timer_quest)
				self.remain_time = 0
				self.timer_quest = nil
				RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
			end
		end, 0)
	end
end

--获取珍稀物品配置
function TreasureData:GetXunBaoZhenXiCfg()
	return ConfigManager.Instance:GetAutoConfig("chestshop_auto").rare_show
end

--获取单个珍稀物品配置
function TreasureData:GetSingleXunBaoZhenXiCfg(id)
	local rare_show = self:GetXunBaoZhenXiCfg()
	for k,v in pairs(rare_show) do
		if v.rare_item_id == id then
			return v
		end
	end
end

function TreasureData:GetShowAllItem(xunbao_type)
	xunbao_type = xunbao_type or 1
	local list = self:GetShowItemCfg(xunbao_type)
	local list_2 = {}
	for k,v in pairs(list) do
		local data = {}
		data.item_id = v.rare_item_id
		data.is_jueban = v.is_jueban
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg and item_cfg.color == 6 and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			data.param = EquipData.GetPinkEquipParam()
		end
		list_2[#list_2 + 1] = data
	end
	return list_2
end

function TreasureData:GetShowCfg()
	return self.show_cfg
end

function TreasureData:GetModelCfg()
	local cfg = {}
	cfg.position = Vector3(0, 0.5, -2)
	cfg.rotation = Vector3(0, 0, 0)
	cfg.scale = Vector3(3.9, 3.9, 3.9)
	return cfg
end

-- 是否有限时兑换
function TreasureData:IsFlashChange()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	return rareChange_time > 0
end

-- 得到是否显示限时的信息
function TreasureData:SetIsShowLimitTimeInfo(number)
	if number ~= nil and number ~= 0 then
		self.is_show_limit_time = true
	else
		self.is_show_limit_time = false
	end
end

function TreasureData:GetIsShowLimitTimeInfo()
	local all_item_id = self:GetItemListByJob()
	for k, v in pairs(all_item_id) do
		if 1 == v[2] then
			return true
		end
	end

	return false
end

function TreasureData:SetEquipItemConvertInfo(convert_count_list)
	self.equip_convert_count_list = convert_count_list
end

function TreasureData:UpDateEquipItemConvertInfo(seq, convert_count)
	if nil == self.equip_convert_count_list then
		return
	end

	self.equip_convert_count_list[seq] = convert_count
end

function TreasureData:GetEquipConverCount(seq)
	if nil == self.equip_convert_count_list then
		return 0
	end

	return self.equip_convert_count_list[seq] or 0
end

--计算红装兑换的红点
function TreasureData:CalcEquipExchangeRemind()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	local order_list = ExchangeData.Instance:GetOrderListByLevel(main_vo.level)
	for _, v in ipairs(order_list) do
		local exchange_list = ExchangeData.Instance:GetExchangeEquipCfgListByOrder(EXCHANGE_CONVER_TYPE.SCORE_TO_ITEM_TYPE_RED_EQUIP,
																				EXCHANGE_PRICE_TYPE.SCORE_TO_ITEM_PRICE_TYPE_ITEM_STUFF,
																				main_vo.prof,
																				v)

		for _, j in ipairs(exchange_list) do
			local conver_count = TreasureData.Instance:GetEquipConverCount(j.seq)
			if conver_count < j.limit_convert_count then
				--有兑换次数
				local is_enough = ItemData.Instance:GetItemNumIsEnough(j.need_stuff_id, j.need_stuff_count)
				if is_enough then
					--材料足够
					return 1
				end
			end
		end
	end

	return 0
end