local GUILD_CHAT_LEVEL = 300 -- 公会取出装备，聊天界面发出信息最大等级
local CHECK_PACK_LEVEL = 29

PackageData = PackageData or BaseClass()
function PackageData:__init()
	if PackageData.Instance then
		print_error("[PackageData] Attemp to create a singleton twice !")
	end

	PackageData.Instance = self

	self.recycle_data_list = {}
	self.open_cell_cost = nil
	self.warehouse_open_cell_cost = nil
	self.colddown_info_list = {}

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	RemindManager.Instance:Register(RemindName.PlayerPackage, BindTool.Bind(self.GetPlayerPackageRemind, self))
end

function PackageData:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	RemindManager.Instance:UnRegister(RemindName.PlayerPackage)

	PackageData.Instance = nil
end

function PackageData:ItemDataChangeCallback(item_id, index, change_reason, put_reason, old_num, new_num, param_change, old_data)
	if change_reason ~= DATALIST_CHANGE_REASON.REMOVE then
		local data = ItemData.Instance:GetGridData(index)
		self:NoticeEffectOnGetItem(data, old_num, put_reason)
	end

	--self:CheckAutoBreakHandler(item_id, index, change_reason, put_reason, old_num, new_num)
	self:CheckTakeOutFromGuildStoreHandler(item_id, index, change_reason, put_reason, old_num, new_num, old_data)
end

function PackageData:EmptyRecycleList()
	self.recycle_data_list = {}
end

function PackageData:SetRecycleItemDataList(is_add, data_list, color)
	if is_add then
		for k,v in pairs(data_list) do
			table.insert(self.recycle_data_list, v)
		end
	else
		for i = #self.recycle_data_list ,1 ,-1 do
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(self.recycle_data_list[i].item_id)
			if item_cfg then
				if color == 2 then
					if item_cfg.color <= 2 then
						table.remove( self.recycle_data_list, i )
					end
				else
					if item_cfg.color == color then
						table.remove( self.recycle_data_list, i )
					end
				end
			end
		end
	end
end

function PackageData:GetRecycleItemDataList()
	return self.recycle_data_list
end

--获取可回收的装备列表
function PackageData:GetRecycleDataList()
	local data_list = {}
	local equip_type_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)

	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	for k , v in pairs(equip_type_list) do
		local is_add = true
		local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
		for k1,v1 in pairs(self.recycle_data_list) do
			if v1.index == v.index and v1.item_id == v.item_id then
				is_add = false
			end
		end
		if item_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and item_cfg.recycltype == 6 and is_add then
			if (item_cfg.limit_prof ~= gamevo.prof and item_cfg.limit_prof ~= 5) then
				table.insert(data_list, v)
			else
				local zhuanshen_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
				local zs_dess_equip_list = ZhuanShengData.Instance:GetDressEquipList()
				if zhuanshen_index > - 1 then
					local fight_power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(v)
					local dress_fight_power = ZhuanShengData.Instance:GetZhuangShengEquipFightPower(zs_dess_equip_list[zhuanshen_index])
					if fight_power <= dress_fight_power then
						table.insert(data_list, v)
					end
				else
					if EquipData.Instance:GetEquipLegendFightPowerByData(v) <= gamevo.capability then
						table.insert(data_list, v)
					end
				end
			end
		end
	end
	return data_list
end

--获取蓝装以下的装备列表
function PackageData:GetBlueAndUnderDataList()
	local blue_data_list = {}
	local data_list = self:GetRecycleDataList()
	for k , v in pairs(data_list) do
		if v ~= nil then
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
			if nil ~= item_cfg and item_cfg.color <= 2 then
				table.insert(blue_data_list,v)
			end
		end
	end
	return blue_data_list
end

--根据颜色获取装备列表
function PackageData:GetEquipDataListByColor(color)
	local purple_data_list = {}
	local num = 1
	local data_list = self:GetRecycleDataList()
	for k , v in pairs(data_list) do
		if v ~= nil then
			local item_cfg, item_type = ItemData.Instance:GetItemConfig(v.item_id)
			if nil ~= item_cfg and item_cfg.color == color then
				table.insert(purple_data_list,v)
			end
		end
	end
	return purple_data_list
end

function PackageData:AddItemToRecycleList(data)
	table.insert(self.recycle_data_list, data)
end

function PackageData:RemoveRecycData(data)
	if not data then return end
	for k, v in pairs(self.recycle_data_list) do
		if data.index == v.index then
			table.remove(self.recycle_data_list, k)
			break
		end
	end
end

function PackageData:GetWarehouseGridData(index)
	local data = ItemData.Instance:GetGridData(index + COMMON_CONSTS.MAX_BAG_COUNT)
	if data then
		return TableCopy(data)
	end

	return nil
end

function PackageData:GetCellData(client_cell_index , toggle_type)
	if toggle_type == GameEnum.TOGGLE_INFO.MATERIAL_TOGGLE then
		local list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_OTHER)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.EQUIP_TOGGLE then
		local list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EQUIPMENT)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.CONSUME_TOGGLE then
		local list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)
		return list and list[client_cell_index + 1] or nil

	elseif toggle_type == GameEnum.TOGGLE_INFO.ALL_TOGGLE then
		return ItemData.Instance:GetGridData(client_cell_index)
	end

	return nil
end

function PackageData:GetPlayerPackageRemind()
	return self:IsShowBagRedPoint() and 1 or 0
end

function PackageData:IsShowBagRedPoint()
	local num1 = MojieData.Instance:GetShiPinRemind(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
	local num2 = MojieData.Instance:GetShiPinRemind(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
	local num3 = MojieData.Instance:GetMojieRemind()
	local num4 = MojieData.Instance:GetGouYuRemind()
	local num5 = DeitySuitData.Instance:GetShenEquipRemind()
	local sum = num1 + num2 + num3 + num4 + num5
	return sum > 0
end

-- 背包扩展
function PackageData:GetCellOpenNeedCount(index)
	if self.open_cell_cost == nil then   --开格子配置直接写在这
		self.open_cell_cost = {
			{min_extend_index = 0, need_item_count = 1},
			{min_extend_index = 60, need_item_count = 1},
			{min_extend_index = 70, need_item_count = 2},
			{min_extend_index = 75, need_item_count = 3},
			{min_extend_index = 80, need_item_count = 4},
			{min_extend_index = 85, need_item_count = 6},
			{min_extend_index = 90, need_item_count = 8},
			{min_extend_index = 95, need_item_count = 10},
			{min_extend_index = 100, need_item_count = 15},
			-- {min_extend_index = 125, need_item_count = 15},
		}
	end

	local len = #self.open_cell_cost
	for i=len, 1, -1 do
		if index >= self.open_cell_cost[i].min_extend_index then
			return self.open_cell_cost[i].need_item_count
		end
	end
	return 0
end

--获取物品可以开启多少背包格子
function PackageData:GetCanOpenHowManySlot(storage_type, num)
	local now_index = 0
	local max_gird_num = 0

	if storage_type == GameEnum.STORAGER_TYPE_BAG then
		now_index = ItemData.Instance:GetMaxKnapsackValidNum()
		max_gird_num = GameEnum.ROLE_BAG_SLOT_NUM
	elseif storage_type == GameEnum.STORAGER_TYPE_STORAGER then

		now_index = ItemData.Instance:GetMaxStorageValidNum()
		max_gird_num = GameEnum.STORAGER_SLOT_NUM
	end

	if now_index == max_gird_num then
		return -1, 0, 0
	end

	local need_number = 0
	local can_open_num = 0
	local old_need_num = 0
	for try_index = now_index, max_gird_num - 1 do
		local open_one_need = self:GetCellOpenNeedCount(try_index)
		if storage_type == GameEnum.STORAGER_TYPE_STORAGER then
			open_one_need = self:GetWareHouseCellOpenNeedCount(try_index)
		end
		old_need_num = need_number
		need_number = need_number + open_one_need
		can_open_num = can_open_num + 1

		if need_number > num then
			return can_open_num - 1, need_number, old_need_num
		end
	end

	return can_open_num, need_number, old_need_num
end

function PackageData:GetWareHouseCellOpenNeedCount(index)
	if self.warehouse_open_cell_cost == nil then   --开格子配置直接写在这
		self.warehouse_open_cell_cost = {
			{min_extend_index = 0, need_item_count = 1},
			{min_extend_index = 15, need_item_count = 1},
			{min_extend_index = 25, need_item_count = 2},
			{min_extend_index = 30, need_item_count = 3},
			{min_extend_index = 35, need_item_count = 4},
			{min_extend_index = 40, need_item_count = 6},
			{min_extend_index = 45, need_item_count = 8},
			{min_extend_index = 50, need_item_count = 10},
			{min_extend_index = 55, need_item_count = 15},
		}
	end

	local len = #self.warehouse_open_cell_cost
	for i=len, 1, -1 do
		if index >= self.warehouse_open_cell_cost[i].min_extend_index then
			return self.warehouse_open_cell_cost[i].need_item_count
		end
	end
	return 0
end

function PackageData:GetOpenCellNeedItemNum(item_id, need_index)
	local num = 0
	local knapsack_id = ShopData.Instance:GetShopOtherByStr("bag_open_item") or 0
	if item_id == knapsack_id then
		for i = ItemData.Instance:GetMaxKnapsackValidNum(), need_index do
			num =  num + self:GetCellOpenNeedCount(i)
		end
	else

		for i = ItemData.Instance:GetMaxStorageValidNum(), need_index do
			num =  num + self:GetWareHouseCellOpenNeedCount(i)
		end
	end
	return num
end

-- 获取背包整理时快速的使用物品，默认获取背包的
function PackageData:GetQuickUseItem(data_list)
	local item_list = {}
	local data_list = data_list or ItemData.Instance:GetBagItemDataList()
	for k, v in pairs(data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and item_cfg.choose_use and 1 == item_cfg.choose_use then
			table.insert(item_list, v)
		end
	end
	return item_list
end

-- 检查背包是否有更好装备
function PackageData:CheckBagBatterEquip()

	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if CHECK_PACK_LEVEL < gamevo.level then
		local data_list = ItemData.Instance:GetBagItemDataList()
		for k, v in pairs(data_list) do
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)

			if item_cfg
				and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT
				and (gamevo.prof == item_cfg.limit_prof or item_cfg.limit_prof == 5)
				and item_cfg.limit_level <= gamevo.level
				and EquipData.Instance:CheckIsAutoEquip(v.item_id, v.index) then
				return v.item_id, v.index
			end
		end
	end
	return 0, 0
end

function PackageData:AutoRecyclEquip()
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	if CHECK_PACK_LEVEL >= gamevo.level then
		return
	end
	local auto_pick_equip = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP)
	if not auto_pick_equip then
		return
	end
	-- local auto_blue = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE) and 2 or -1
	-- local auto_purple = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE) and 3 or -1
	-- local auto_orange = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE) and 4 or -1
	-- local auto_red = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED) and 5 or -1
	-- if auto_blue < 0 and auto_purple < 0 and auto_orange < 0 and auto_red < 0 then
	-- 	return
	-- end

	local item_cfg, big_type = nil, nil
	local data_list = ItemData.Instance:GetBagItemDataList()

	for k, v in pairs(data_list) do
		item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if k < COMMON_CONSTS.MAX_BAG_COUNT and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT
			and EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type) >= 0
			and (item_cfg.color <= auto_blue or item_cfg.color == auto_purple or item_cfg.color == auto_orange or item_cfg.color == auto_red) then

				if (item_cfg and (gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5)) then
					PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
				else
					if gamevo.capability >= EquipData.Instance:GetEquipLegendFightPowerByData(v) then
						PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
					end
				end
		end
	end
end

function PackageData:SetColddownInfo(colddown_id, end_time)
	self.colddown_info_list[colddown_id] = end_time
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_COLDDOWN_CHANGE, colddown_id, end_time)
end

function PackageData:GetColddownEndTime(colddown_id)
	return self.colddown_info_list[colddown_id] or 0
end

function PackageData:NoticeEffectOnGetItem(data, old_num, put_reason)
	if data == nil or nil == old_num or nil == put_reason then return end

	if data.num > old_num and put_reason ~= PUT_REASON_TYPE.PUT_REASON_INVALID and put_reason ~= PUT_REASON_TYPE.PUT_REASON_NO_NOTICE then
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg ~= nil then
			local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
			local str = string.format(Language.SysRemind.AddItem, item_name, data.num - old_num)
			local is_mask_animation = true	--PetData.Instance:GetIsMask()
			if put_reason == PUT_REASON_TYPE.PUT_REASON_LITTLE_PET_CHOUJIANG_ONE and not is_mask_animation then
				self:DeyToShowFloatingLabel(str)
			else
				TipsCtrl.Instance:ShowFloatingLabel(str)
			end
			-- PackageCtrl.Instance:PlayAnimationOnGetItem(data.item_id)
		end
	end
end

-- 从公会仓库取出装备后，在公会聊天那里发句话
function PackageData:CheckTakeOutFromGuildStoreHandler(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, data)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_GUILD_STORE and nil ~= data then
		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		if gamevo.level >= GUILD_CHAT_LEVEL then
			return
		end

		local xianpin_type_list = data.param.xianpin_type_list

		local type_1 = xianpin_type_list[1] or 0
		local type_2 = xianpin_type_list[2] or 0
		local type_3 = xianpin_type_list[3] or 0

		local cur_data_power = EquipData.Instance:GetEquipLegendFightPowerByData(data, false, true)
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
		local equip_data = EquipData.Instance:GetGridData(equip_index)
		local equip_data_power = 0
		local content = string.format(Language.Guild.TakeOutFromGuildStore, gamevo.role_id, gamevo.name, change_item_id, change_item_id, type_1, type_2, type_3)

		if nil ~= equip_data and nil ~= equip_data.item_id and equip_data.item_id > 0 then
			equip_data_power = EquipData.Instance:GetEquipLegendFightPowerByData(equip_data, false, true)
		end
		if cur_data_power > equip_data_power then
			content = content..string.format(Language.Guild.FightPowerUp, (cur_data_power - equip_data_power))
		end

		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content)
	end
end

function PackageData:CheckAutoBreakHandler(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num)
	-- local auto_pick_equip = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_EQUIP)
	-- local auto_blue = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_BLUE) and 2 or -1
	-- local auto_purple = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_PURPLE) and 3 or -1
	-- local auto_orange = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_ORANGE) and 4 or -1
	-- local auto_red = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_RECYCLE_RED) and 5 or -1

	if auto_pick_equip and new_num > old_num then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(change_item_id)
		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		local bag_data = ItemData.Instance:GetGridData(change_item_index)

		if PUT_REASON_TYPE.PUT_REASON_PICK == put_reason and item_cfg
			and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and (item_cfg.color <= auto_blue
				or item_cfg.color == auto_purple or item_cfg.color == auto_orange or item_cfg.color == auto_red)	-- 自动回收先判断装备品质
				and not EquipData.IsJLType(item_cfg.sub_type) then
				if EquipData.Instance:GetEquipLegendFightPowerByData(bag_data) <= gamevo.capability
					or (item_cfg.limit_prof ~= gamevo.prof and item_cfg.limit_prof ~= 5)  then							-- 自动回收战力低及不符合品质的其他职业装备

					PackageCtrl.Instance:SendDiscardItem(change_item_index, new_num - old_num, change_item_id, new_num,  1)
				end
		end
	end
end

function PackageData:DeyToShowFloatingLabel(str)
	local timer_cal = 2
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0 then
			TipsCtrl.Instance:ShowFloatingLabel(str)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		end
	end, 0)
end