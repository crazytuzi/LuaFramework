TreasureData = TreasureData or BaseClass()

TREASURE_ROW = 8 --格子列数
TREASURE_COLUMN = 4 --行数
TREASURE_ALL_ROW = 80 --背包总列数

TREASURE_SHOW_ROW = 5 --格子列数
TREASURE_SHOW_COLUMN = 2 --行数
TREASURE_SHOW_ALL_ROW = 25 --背包总列数
TREASURE_EXCHANGE_CONVER_TYPE = 3  --寻宝兑换类型
TREASURE_EXCHANGE_PRICE_TYPE = 5   --价格类型

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
	self.split_current_chest_item_info = {}
	self.current_chest_count = 0
	self.open_days = 0
	self.remain_time = 0
	self.is_shield = false
	self.chest_shop_mode = -1
	self.show_cfg = self:GetShowAllItem()
	-- GlobalEventSystem:Bind(BagFlushEventType.BAG_FLUSH_CONTENT, BindTool.Bind1(self.GetXunBaoRedPoint, self))

	RemindManager.Instance:Register(RemindName.XunBaoTreasure, BindTool.Bind(self.GetRemindXunBao, self))
	RemindManager.Instance:Register(RemindName.XunBaoExchange, BindTool.Bind(self.GetRemindDuiHuan, self))
	RemindManager.Instance:Register(RemindName.XunBaoWarehouse, BindTool.Bind(self.GetRemindWareHouse, self))
end

function TreasureData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XunBaoTreasure)
	RemindManager.Instance:UnRegister(RemindName.XunBaoExchange)
	RemindManager.Instance:UnRegister(RemindName.XunBaoWarehouse)
	
	TreasureData.Instance = nil
end

function TreasureData:ClearData()
	self.current_chest_item_info = {}
	self.split_current_chest_item_info = {}
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
	self.split_current_chest_item_info = {}
	for i, v in ipairs(self.current_chest_item_info) do
		if v.num > 1 then
			for i = 1, v.num do
				local tab = {}
				tab.item_id = v.item_id
				tab.num = 1
				table.insert(self.split_current_chest_item_info, tab)
			end
		else
			table.insert(self.split_current_chest_item_info, v)
		end
	end
end

function TreasureData:GetChestShopItemInfo()
	return self.current_chest_item_info
end
--获取拆分后的寻宝物品表
function TreasureData:GetSplitChestShopItemInfo()
	return self.split_current_chest_item_info
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
	--return self.chest_shop_next_free_time_1

	-- 屏蔽掉免费抽
	return 9999999999
end

function TreasureData:GetChestJlFreeTime()
	--return self.chest_shop_jl_next_free_time_1

	-- 屏蔽掉免费抽
	return 9999999999
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
		if v.conver_type == conver_type then
			if v.price_type == price_type then
				if v.show_limit == job or v.show_limit == 5 then
					item_id_list[#item_id_list + 1] = v.item_id
				end
			end
		end
	end
	return item_id_list
end


function TreasureData:GetItemListByJobAndIndex(conver_type, price_type,job,index)
	local all_item_cfg = self:GetAllExchangeCfg()
	local item_id_list = {}
	for k,v in pairs(all_item_cfg) do
		if v.conver_type == conver_type then
			if v.price_type == price_type then
				if v.show_limit == job or v.show_limit == 5 then
					item_id_list[#item_id_list + 1] = v.item_id
				end
			end
		end
	end
	local job_id_list = {}
	if index == 1 then
		for i=1,4 do
			if item_id_list[i] ~= nil then
				job_id_list[#job_id_list + 1] = item_id_list[i]
			else
				job_id_list[#job_id_list + 1] = 0
			end
		end
		return job_id_list
	end
	for i=1,4 do
		if item_id_list[(index - 1)*4 + i] == nil then
			item_id_list[(index - 1)*4 + i] = 0
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*4 + i]
	end
	return job_id_list
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

function TreasureData:GetRemindDuiHuan()
	if not OpenFunData.Instance:CheckIsHide("treasure_exchange") then
		return 0
	end
	if ClickOnceRemindList[RemindName.XunBaoExchange] and ClickOnceRemindList[RemindName.XunBaoExchange] == 0 then
		return 0
	end
	return self:GetDuiHuanRedPoint() and 1 or 0
end

function TreasureData:GetXunBaoWareRedPoint()
	if not OpenFunData.Instance:CheckIsHide("treasure_warehouse") then
		return false
	end
	local ware_red_point = false
	if ItemData.Instance:GetEmptyNum() > 0 then
		if self:GetChestCount() > 0 then
			ware_red_point = true
		end
	end
	return ware_red_point
end

function TreasureData:GetXunBaoRedPoint()
	-- local can_chest_time = self:GetChestFreeTime()
	-- if can_chest_time - TimeCtrl.Instance:GetServerTime() < 0 then
	-- 	xun_bao_red_point = true
	-- else
	-- 	self:CalToSetRedPoint()
	-- end
	-- equip_use_itemid
	if not OpenFunData.Instance:CheckIsHide("treasure_choujiang") then
		return false
	end
	local other_cfg = self:GetOtherCfg()
	local item_id = other_cfg.equip_use_itemid
	local own_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local xun_bao_red_point = own_num >= 1
	return xun_bao_red_point
end

function TreasureData:GetDuiHuanRedPoint()
	local other_cfg = self:GetOtherCfg()
	local num = ItemData.Instance:GetItemNumInBagById(other_cfg.score_item_id)
	local item_info = ExchangeData.Instance:GetExchangeCfgByType(3)
	table.sort(item_info, SortTools.KeyLowerSorter("price"))
	local duihuan_red_point = num >= item_info[1].price and true or false
	return duihuan_red_point
end

function TreasureData:CalToSetRedPoint()
	if self.timer_quest == nil then
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
			local can_chest_time = self:GetChestFreeTime()
			self.remain_time = can_chest_time - TimeCtrl.Instance:GetServerTime()
			if self.remain_time < 0 then
				GlobalTimerQuest:CancelQuest(self.timer_quest)
				self.remain_time = 0
				main_treasure_red_point = true
				local treasure_view = TreasureCtrl.Instance:GetView()
				if treasure_view.is_open then
					treasure_view:SetRedPoint(true)
				end
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

--根据职业获得单个配置
function TreasureData:GetSingleCfgByProf(prof)
	local data = {}
	local cfg = self:GetXunBaoZhenXiCfg()
	for f,v in pairs(cfg) do
		if v.prof == prof then
			data = v
		end
	end
	return data
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
		list_2[#list_2 + 1] = data
	end
	return list_2
end

function TreasureData:GetShowCfg()
	return self.show_cfg
end

function TreasureData:GetModelCfg()
	local cfg = {}
	cfg.position = Vector3(0, -0.25, 0)
	cfg.rotation = Vector3(0, 0, 0)
	cfg.scale = Vector3(1.1, 1.1, 1.1)
	return cfg
end