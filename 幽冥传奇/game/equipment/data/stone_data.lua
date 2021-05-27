StoneData = StoneData or BaseClass()

MAX_STONE_LEVEL = #(EquipInlayCfg or {1}) / 6
STONE_LEVEL_LIMIT = 60
-- StoneData.EQUIP_INSERT_INFO = "equip_insert_info"
StoneData.STONE_INSERT_CHANGE = "stone_insert_change" -- 宝石镶嵌改变
StoneData.STONE_INSERT_SUCCESS = "stone_insert_success" -- 宝石镶嵌成功

-- 一键镶嵌和升级的顺序
-- 以下定义的顺序为 1武器-2衣服-5左手镯-7左戒指-9腰带-3头盔-4项链-6右手镯-8右戒指-10鞋子
StoneData.Order = {1, 2, 5, 7, 9, 3, 4, 6, 8, 10}

function StoneData:__init()
	if StoneData.Instance then
		ErrorLog("[StoneData] Attemp to create a singleton twice !")
	end
	StoneData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.equip_inset_info = {}
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanEquipInsetStone, self), RemindName.EquipInlayStone)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_STONE_DATA_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_COIN, BindTool.Bind(self.OnGoldChange, self))

	self.stone_bag_list = {}
	self.stone_can_upgrade_list = {}
	self.bag_need_flush = true -- 背包列表是否需要刷新
	self.best_need_flush = true -- 最好的宝石列表是否需要刷新
	self.upgrade_need_flush = true -- 可升级列表是否需要刷新

	self.need_max_money = 0 -- 合成消耗的最大元宝数

	self.equip_inlay_cfg = {}
	for i,v in pairs(EquipInlayCfg or {}) do
		self.equip_inlay_cfg[v] = i
	end
end

function StoneData:__delete()
	StoneData.Instance = nil
end

function StoneData:IsStone(item_id)
	return self.equip_inlay_cfg[item_id] ~= nil
end

function StoneData:GetStoneSlot(item_id)
	local index = self.equip_inlay_cfg[item_id]
	local slot = math.ceil(index / MAX_STONE_LEVEL)
	return slot
end

function StoneData.GetStoneSlotLimitList()
	return EquipInlayUnlockCondition.circles
end

function StoneData.GetStoneItemID(stone_index)
	return EquipInlayCfg[stone_index]
end

function StoneData:SetEquipInsetInfo(info_list)
	self.equip_inset_info = info_list
	self:SetEquipDataList()
	RemindManager.Instance:DoRemindDelayTime(RemindName.EquipInlayStone)
	GlobalEventSystem:Fire(OtherEventType.STONE_INLAY_INFO_CHANGE)
end

function StoneData:GetEquipInsetInfo()
	return self.equip_inset_info
end

function StoneData:ChangeEquipInsetInfo(equip_slot, stone_slot, stone_index, is_blind)
	self.equip_inset_info[equip_slot][stone_slot].stone_index = stone_index
	if is_blind then
		self.equip_inset_info[equip_slot][stone_slot].stone_is_blind = is_blind
	end

	if 0 ~= stone_index and nil ~= is_blind then
		self:DispatchEvent(StoneData.STONE_INSERT_SUCCESS, equip_slot)
	end
	
	self.upgrade_need_flush = true
	self:DispatchEvent(StoneData.STONE_INSERT_CHANGE)
	GlobalEventSystem:Fire(OtherEventType.STONE_INLAY_INFO_CHANGE, equip_slot - 1)
end

function StoneData:GetEquipDataList()
	if self.equip_data_list == nil then
		self:SetEquipDataList()
	end

	return self.equip_data_list
end

-- 设置装备信息列表
function StoneData:SetEquipDataList()
	self.equip_data_list = {}
	local equip_inset_info = self:GetEquipInsetInfo()
	for k, v in pairs(equip_inset_info) do
		local equip = EquipData.Instance:GetEquipDataBySolt(k + EquipData.EquipIndex.Weapon - 2)
		table.insert(self.equip_data_list, {equip_index = k + EquipData.EquipIndex.Weapon - 2, equip = equip, inset_stones = v})
	end
end

function StoneData:GetAllStoneNum()
	local attr_data = {}
	for k,v in pairs(self.equip_inset_info) do
		for k1,v1 in pairs(v) do
			if v1.stone_index > 0 then
				local item_id = StoneData.GetStoneItemID(v1.stone_index)
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				local cur_attrs = item_cfg and item_cfg.staitcAttrs
				attr_data = CommonDataManager.AddAttr(attr_data, cur_attrs)
			end
		end
	end
	return CommonDataManager.GetAttrSetScore(attr_data)
end

-- 设置当前选择的装备槽位 用于Tips升级
function StoneData:SetSelectEquipSlot(equip_slot)
	self.select_equip_slot = equip_slot
end

-- 获取当前选择的装备槽位
function StoneData:GetSelectEquipSlot()
	return self.select_equip_slot
end

function StoneData.IsStoneEquip(item_type)
	return item_type == ItemData.ItemType.itWeapon or
	item_type == ItemData.ItemType.itDress or
	item_type == ItemData.ItemType.itHelmet or
	item_type == ItemData.ItemType.itNecklace or
	item_type == ItemData.ItemType.itBracelet or
	item_type == ItemData.ItemType.itRing or
	item_type == ItemData.ItemType.itGirdle or
	item_type == ItemData.ItemType.itShoes
end

function StoneData:OnBagItemChange(vo)
	if vo.change_type == ITEM_CHANGE_TYPE.LIST or (vo.data and StoneData.Instance:IsStone(vo.data.item_id)) then
		self:SetBagStoneList(vo)
		RemindManager.Instance:DoRemindDelayTime(RemindName.EquipInlayStone)
		GlobalEventSystem:Fire(OtherEventType.BAG_STONE_CHANGED)
	end
end

function StoneData:OnChangeOneEquip(data)
	local list = self:GetEquipDataList()
	if data.slot >=0 and data.slot < #list then
		equip = EquipData.Instance:GetEquipDataBySolt(data.slot)
		if list[data.slot + 1] then
			list[data.slot + 1].equip = equip
		end
	end
end

function StoneData:OnGoldChange(param)
	if param.old_value < self.need_max_money or param.value < self.need_max_money then
		self.upgrade_need_flush = true
	end
end

function StoneData:GetBagStoneCfgList()
	if self.bag_need_flush then
		self.stone_bag_list = {}
		local stone_bag_list = self.GetStoneBagList()
		for k, v in pairs(stone_bag_list) do
			self.stone_bag_list[#self.stone_bag_list +1] = v
		end
		table.sort(self.stone_bag_list, function(a, b)
			if a.stone_slot ~= b.stone_slot then
				return a.stone_slot < b.stone_slot
			else
			 	return a.stone_lv > b.stone_lv
			end
		end)
		self.bag_need_flush = false
	end

	return self.stone_bag_list
end

function StoneData:GetStoneBagList()
	local item_type = ItemData.ItemType.itItemDiamond
	local list = BagData.Instance:GetBagItemDataListByType(item_type)

	return list
end

function StoneData:SetBagStoneList(vo)
	if vo.change_type == ITEM_CHANGE_TYPE.LIST then
		self.stone_bag_list = {}
		for k, v in pairs(StoneData.Instance:GetStoneBagList()) do
			local level, slot = self:GetStoneLevelAndSlot(v.item_id)
			if level then
				v.stone_lv = level
				v.stone_slot = slot
			end
		end
	elseif vo.change_type == ITEM_CHANGE_TYPE.ADD then
		local data = vo.data
		if data then
			local level, slot = self:GetStoneLevelAndSlot(data.item_id)
			if level then
				data.stone_lv = level
				data.stone_slot = slot
			end
		end
	end
	self.bag_need_flush = true
	self.best_need_flush = true
	self.upgrade_need_flush = true
end

function StoneData:GetStoneLevelAndSlot(item_id)
	local index = self.equip_inlay_cfg and self.equip_inlay_cfg[item_id] or nil
	if index then
		return StoneData.FormatStoneLevelAndSlot(index)
	end
end

function StoneData.GetStoneUpgradeConsumes(stone_lv, stone_slot)
	local cfg = StoneUpgradeCfg or {}
	local consumes = StoneUpgradeCfg[stone_slot] and StoneUpgradeCfg[stone_slot][stone_lv]
	
	return consumes or {}
end

function StoneData.FormatStoneLevel(level)
	if level > 0 then
		return level % MAX_STONE_LEVEL and MAX_STONE_LEVEL or level % MAX_STONE_LEVEL
	else
		return 0
	end
end

function StoneData.FormatStoneLevelAndSlot(level)
	local lv, slot = 0, 0
	if level > 0 then
		lv = level % MAX_STONE_LEVEL
		lv = lv == 0 and MAX_STONE_LEVEL or lv
		slot = (level - lv) / MAX_STONE_LEVEL + 1
	end

	return lv, slot
end

function StoneData:GetBestStoneList()
	if self.best_need_flush then
		local list = {}
		local stone_bag_list = self.GetStoneBagList()
		for k,v in pairs(stone_bag_list) do
			local stone_lv = v.stone_lv 
			local slot = v.stone_slot
			if list[slot] then
				local old_level = list[slot].stone_lv
				if old_level < stone_lv then
					list[slot] = v
				end
			else
				list[slot] = v
			end
		end
		self.best_stone_list = list
		self.best_need_flush = false
	end

	return self.best_stone_list
end

-- 获取宝石可升级列表
function StoneData:GetStoneCanUpgradeList()
	if self.upgrade_need_flush then
		self.need_max_money = 0
		local list = {}
		local equip_inset_info = self:GetEquipInsetInfo()
		for equip_slot, inset_info_list in pairs(equip_inset_info) do
			for slot_index, inset_info in ipairs(inset_info_list) do
				local stone_index = inset_info.stone_index
				local item_id = StoneData.GetStoneItemID(stone_index)
				local level, slot = self:GetStoneLevelAndSlot(item_id)
				if level and level > 0 then
					local cfg = StoneData.GetStoneUpgradeConsumes(level, slot)
					local consumes = cfg.consumes or {}
					local can_upgrade = nil ~= next(consumes)
					for i, consume in ipairs(consumes) do
						local _type = consume.type or 0
						local item_id = consume.id or 0
						local have_consume_count = BagData.GetConsumesCount(item_id, _type)
						local cfg_consume_count = consume.count or 0
						if have_consume_count < cfg_consume_count then
							can_upgrade = false
							break
						end
					end

					if can_upgrade then
						list[equip_slot] = list[equip_slot] or {}
						list[equip_slot][slot_index] = consumes
					end
					local need_money = consumes and consumes[2] and consumes[2].count or 0
					self.need_max_money = math.max(need_money, self.need_max_money)
				end
			end
		end

		self.stone_can_upgrade_list = list
		self.upgrade_need_flush = false
	end

	return self.stone_can_upgrade_list
end

function StoneData:CanEquipInsetStone()
	if self:InsetStoneRemindNum() then
		return 1
	else
		return 0
	end
end

function StoneData.GetMaxStonePlusLevel()
	return StonePlusCfg and #StonePlusCfg or 10
end

function StoneData:InsetStoneRemindNum()
	local num = 0
	local limit_list = self:GetStoneSlotLimitList()
	local equip_data_list = self:GetEquipDataList()
	local best_stone_list = self:GetBestStoneList()
	local can_upgrade_list = self:GetStoneCanUpgradeList()
	for equip_slot, v in pairs(self.equip_inset_info) do
		local equip_data = equip_data_list[equip_slot]
		local equip_id = equip_data.equip and equip_data.equip.item_id
		if equip_id then -- 未穿戴装备时,跳过
			local level, zhuan = ItemData.GetItemLevel(equip_id)
			for stone_slot, stone_info in pairs(v) do
				if zhuan >= limit_list[stone_slot] then -- 判断该槽位是否开放
					local cur_level = self.FormatStoneLevelAndSlot(stone_info.stone_index)
					local best_level = best_stone_list[stone_slot] and best_stone_list[stone_slot].stone_lv or 0
					if cur_level < best_level then
						num = num + 1
						break
					end

					local upgrade_consumes = can_upgrade_list[equip_slot] and can_upgrade_list[equip_slot][stone_slot]
					if upgrade_consumes ~= nil then
						num = num + 1
						break
					end
				end
			end
		end
	end
	
	return num ~= 0
end

-- 一键合成宝石 用于 锻造-镶嵌-宝石背包-宝石tips
function StoneData:OneKeyComposeStone(item_id)
	local level, slot = self:GetStoneLevelAndSlot(item_id)

	local cfg = ItemSynthesisConfig[2] and  ItemSynthesisConfig[2].list or {}
	local cur_config = cfg[slot] and cfg[slot].itemList or {}
	local cur_data = cur_config[level] or {}

	local consume = cur_data.consume and cur_data.consume[1] or {id = 0, count = 1}
	if consume.id == item_id then
		local bag_num = BagData.Instance:GetItemNumInBagById(consume.id)
		if  bag_num < consume.count then
			-- 合成失败，宝石数量不足
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.StoneSlotTip4)
		else
			local compose_num = math.floor(bag_num / consume.count)
			BagCtrl.SendComposeItem(2, slot, level, 1, compose_num)
		end
	else
		if level == MAX_STONE_LEVEL then
			-- 合成失败，宝石已是最高级
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.StoneSlotTip5)
		else
			-- 合成失败，当前宝石不可合成
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.StoneSlotTip6)
		end
	end
end
