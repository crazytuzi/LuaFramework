--------------------------------------------------------
-- 守护神装Data
--------------------------------------------------------

GuardEquipData = GuardEquipData or BaseClass(BaseData)

GuardEquipData.GUARD_EQUIP_CHANGE = "guard_equip_change"
GuardEquipData.GUARD_SHOP_DATA_CHANGE = "guard_shop_data_change"

function GuardEquipData:__init()
	if GuardEquipData.Instance then
		ErrorLog("[GuardEquipData]:Attempt to create singleton twice!")
	end
	GuardEquipData.Instance = self

	self.all_guard_equip = {} 		-- 已穿带的所有守护神装
	self.guard_equip_bag_list = {}	-- 背包中的守护神装列表

	self.remind_index_list = nil	-- 提醒索引列表

	self.guard_shop_data = {}		-- 守护商店数据
	self.guard_shop_show_list = {}	-- 守护神装商店显示列表

	self.guard_shop_left_time = 0
	self.guard_shop_now_time = 0

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.BetterGuardEquip)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetShopRemindIndex), RemindName.GuardShopCanExchange)
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	VipData.Instance:AddEventListener(VipData.VIP_INFO_EVENT, BindTool.Bind(self.OnVipInfoEvent, self))
end

function GuardEquipData:__delete()
	GuardEquipData.Instance = nil
end

----------设置----------

-- 接收穿上/替换守护神装结果
function GuardEquipData:SetWearGuardEquipResult(protocol)
	local server_slot = protocol.slot or -1
	self.all_guard_equip[server_slot] = protocol.equip

	local slot_type, slot = self.GetShowTypeAndSlot(server_slot)
	local show_list = self:GetGuardEquipShowList()
	local show_slot_list = show_list[slot_type] or {}
	show_slot_list[slot] = protocol.equip

	self:DispatchEvent(GuardEquipData.GUARD_EQUIP_CHANGE, slot_type, slot, protocol.equip)
end

-- 接收所有守护神装信息
function GuardEquipData:SetAllGuardEquipInfo(protocol)
	self.all_guard_equip = protocol.all_guard_equip or {}
end


-- 获取所有守护神装信息
function GuardEquipData:GetAllGuardEquipInfo()
	return self.all_guard_equip or {}
end

-- 获取所有守护神装显示列表
function GuardEquipData:GetGuardEquipShowList()
	if nil == self.show_list then
		local list = {}
		local cfg = GuardGodEquipConfig or {}
		local max_slot = cfg.max_slot or 7
		local max_slot_type = cfg.openviplvs and #cfg.openviplvs or 4
		for slot_type = 1, max_slot_type do
			list[slot_type] = {}
			for slot = 1, max_slot do
				local server_slot = self.GetServerSlot(slot_type, slot)
				list[slot_type][slot] = self.all_guard_equip[server_slot] or {}
			end
		end
		self.show_list = list
	end

	return self.show_list
end

-- 获取已开放的守护神装显示列表 从0开始
function GuardEquipData:GetOpenShowList()
	local list = {}
	local cfg = GuardGodEquipConfig or {}
	local openviplvs = cfg.openviplvs or {}
	local vip_lv = VipData.Instance:GetVipLevel()
	local show_list = self:GetGuardEquipShowList()
	for i,v in ipairs(openviplvs) do
		if v.viplv and vip_lv >= v.viplv then
			local slot_type = v.type and (v.type + 1) or 0
			list[slot_type - 1] = show_list[slot_type] -- slot_type 为 0 时,实际为nil
		end
	end

	return list
end

-- 获取身上的守护神装的阶数
function GuardEquipData:GetBodyGuardEquipPhase(slot_type, slot)
	local server_slot = self.GetServerSlot(slot_type, slot)
	local equip = self.all_guard_equip[server_slot]
	local phase = equip and equip.quality or 0 -- 未装备时,显示0

	return phase
end

function GuardEquipData.GetServerSlot(slot_type, slot)
	local cfg = GuardGodEquipConfig or {}
	local max_slot = cfg.max_slot or 7
	local server_slot = (slot_type - 1) * max_slot + slot - 1 -- 服务端的槽位

	return server_slot
end

function GuardEquipData.GetShowTypeAndSlot(server_slot)
	local cfg = GuardGodEquipConfig or {}
	local max_slot = cfg.max_slot or 7
	local slot_type = (server_slot - (server_slot % max_slot)) / max_slot + 1
	local slot = server_slot % max_slot + 1

	return slot_type, slot
end

function GuardEquipData.GetEquipSlot(item_cfg)
	local server_slot = item_cfg and item_cfg.stype
	return server_slot
end

----------------------------------------
-- 守护商店
----------------------------------------

-- 设置守护神装商店数据
GuardEquipData.guarg_shop_is_open = false
function GuardEquipData:SetGuardShopData(protocol)
	local shop_type = protocol.shop_type or 0
	self.guard_shop_data[shop_type] = protocol.item_list or {}
	self.guard_shop_show_list[shop_type] = nil -- 清空商店显示列表
	self.guard_shop_left_time = protocol.left_time
	self.guard_shop_now_time = protocol.now_time

	GuardEquipData.guarg_shop_is_open = GuardEquipData.guarg_shop_is_open or #protocol.item_list > 0
	self:DispatchEvent(GuardEquipData.GUARD_SHOP_DATA_CHANGE, shop_type)
end

-- 获取守护神装商店数据
function GuardEquipData:GetGuardShopData(shop_type)
	return self.guard_shop_data[shop_type] or {}
end

-- 获取守护神装商店配置
local guard_shop_cfg = {} -- 守护神装商店配置
function GuardEquipData.GetGuardShopCfg(shop_type)
	if nil == guard_shop_cfg[shop_type] then
		guard_shop_cfg[shop_type] = ConfigManager.Instance:GetServerConfig("store/GuardGodEquipGoods/goods_" .. shop_type)[1]
	end
	return guard_shop_cfg[shop_type] or {}
end

-- 获取守护神装商店显示列表
-- 守护神装商店的 shop_type == 守护神装的 slot_type
function GuardEquipData:GetGuardShopShowList(shop_type)
	if nil == self.guard_shop_show_list[shop_type] then
		local data = self.guard_shop_data[shop_type] or {}
		local cfg = GuardEquipData.Instance.GetGuardShopCfg(shop_type)

		local remind_index_list = GuardEquipData.Instance:GetRemindIndexList()
		local remind_list = remind_index_list[shop_type] or {}
		local list = {}
		for i,v in ipairs(data) do
			local index = v.cfg_index or 0
			list[i] = {}
			list[i].cfg = cfg[index] or {}
			list[i].shop_type = shop_type
			list[i].cfg_index = v.cfg_index or 0
			list[i].buy_count = v.buy_count
			list[i].shop_index = v.shop_index

			local awards = cfg[index] and cfg[index].awards
			local item_data = awards[1]
			local item_cfg = ItemData.Instance:GetItemConfig(item_data.id)
			local slot_type, slot = GuardEquipData.GetShowTypeAndSlot(item_cfg.stype)

			-- remind_list[slot] 是物品ID,同槽位ID越,大品质越好.
			if remind_list[slot] then
				list[i].is_better = item_cfg.item_id > remind_list[slot]
			else
				local old_quality =  GuardEquipData.Instance:GetBodyGuardEquipPhase(slot_type, slot)
				list[i].is_better = item_cfg.quality > old_quality
			end
		end

		self.guard_shop_show_list[shop_type] = list
	end

	return self.guard_shop_show_list[shop_type] or {}
end

function GuardEquipData:GetMyRefreLeftTime()
	local now_left_time = self.guard_shop_left_time - (Status.NowTime - self.guard_shop_now_time)
	return math.max(now_left_time, 0)
end

--------------------

-- 初始化背包中的守护神装列表
function GuardEquipData:InitMaxSlotQuality()
	local list = {}
	local item_type = ItemData.ItemType.itGuardEquip
	local bag_item_list = BagData.Instance:GetBagItemDataListByType(item_type)
	for i,v in pairs(bag_item_list) do
		local item_id = v.item_id or 0
		list[item_id] = v.quality
	end
	self.guard_equip_bag_list = list
	self.remind_index_list = nil
	self.guard_shop_show_list = {} -- 清空商店显示列表缓存
end

-- 获取背包中的守护神装列表
function GuardEquipData:GetGuardEquipBagList()
	return self.guard_equip_bag_list or {}
end

-- 获取守护神装提醒列表 从0开始
function GuardEquipData:GetRemindIndexList()
	if nil == self.remind_index_list then
		local list = {}
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local all_guard_equip = GuardEquipData.Instance:GetAllGuardEquipInfo()
		local bag_list = GuardEquipData.Instance:GetGuardEquipBagList()
		for item_id, quality in pairs(bag_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local limit_level, zhuan = ItemData.GetItemLevel(item_id)
			if role_lv >= limit_level then
				local guard_equip = all_guard_equip[item_cfg.stype] or {}
				local old_quality = guard_equip.quality or 0 -- 该槽位未穿带时 quality 为0
				if quality > old_quality then
					local slot_type, slot = GuardEquipData.GetShowTypeAndSlot(item_cfg.stype)
					list[slot_type] = list[slot_type] or {}
					if list[slot_type][slot] then
						list[slot_type][slot] = list[slot_type][slot] > item_id and list[slot_type][slot] or item_id
					else
						list[slot_type][slot] = item_id
					end
				end
			end
		end
		self.remind_index_list = list
	end

	return self.remind_index_list
end

function GuardEquipData:OnVipInfoEvent()
	RemindManager.Instance:DoRemindDelayTime(RemindName.BetterGuardEquip)
end

function GuardEquipData:OnBagItemChange(event)
	for i,v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			self:InitMaxSlotQuality()
		end
	end
	event.CheckAllItemDataByFunc(function (vo)
		local item_type = vo.data.type
		local item_id = vo.data.item_id or 0
		if item_type == ItemData.ItemType.itGuardEquip then
			local need_flush = false
			if vo.change_type == ITEM_CHANGE_TYPE.ADD then
				local quality = vo.data.quality
				if nil == self.guard_equip_bag_list[item_id] then
					self.guard_equip_bag_list[item_id] = quality
					need_flush = true
				end
			elseif vo.change_type == ITEM_CHANGE_TYPE.DEL then
				local num = BagData.Instance:GetItemNumInBagById(item_id)
				if num == 0 then
					self.guard_equip_bag_list[item_id] = nil
				end
				need_flush = true
			end
					
			if need_flush == true then
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				local slot_type, slot = GuardEquipData.GetShowTypeAndSlot(item_cfg.stype)
				self.guard_shop_show_list[slot_type] = nil -- 清空商店显示列表缓存
				self.remind_index_list = nil -- 清空提醒列表缓存
			end
		end

		local cfg = GuardGodEquipShopConfig or {}
		local show_id = cfg.show_id or 0
		if show_id == item_id then
			RemindManager.Instance:DoRemindDelayTime(RemindName.GuardShopCanExchange)
		end
	end)

	if nil == self.remind_index_list then
		RemindManager.Instance:DoRemindDelayTime(RemindName.GuardShopCanExchange)
		RemindManager.Instance:DoRemindDelayTime(RemindName.BetterGuardEquip)
	end
end

-- 获取守护神装红点提醒
function GuardEquipData.GetRemindIndex()
	local index = 0
	local cfg = GuardGodEquipConfig or {}
	local openviplvs = cfg.openviplvs or {}

	local openLevel = cfg.openLevel or 0
	local opencircle = cfg.opencircle or 0
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if role_level < openLevel or role_circle < opencircle then return end

	local max_slot = cfg.max_slot or 0
	local vip_lv = VipData.Instance:GetVipLevel()
	local remind_list = GuardEquipData.Instance:GetRemindIndexList()
	for slot_type, v in ipairs(openviplvs) do
		if v.viplv and vip_lv >= v.viplv then
			if remind_list[slot_type] then
				index = 1
				break
			end 
		end
	end

	return index
end

function GuardEquipData.GetShopRemindIndex()
	local index = 0
	local cfg = GuardGodEquipShopConfig or {}
	local cond_id = ViewDef.GuardEquip.v_open_cond or ""
	local is_open = GameCondMgr.Instance:GetValue(cond_id)
	if GuardEquipData.guarg_shop_is_open and is_open then
		local item_id = cfg.show_id or 0
		local remind_num = cfg.remind_num or 1
		local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
		if bag_num >= remind_num then
			index = 1
		end
	end

	return index
end