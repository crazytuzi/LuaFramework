AffinageData = AffinageData or BaseClass()

AFFINAGE_CFG = {
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot1"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot2"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot3"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot4"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot5"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot6"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot7"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot8"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot9"),
	require("scripts/config/server/config/item/EquipSlotRefineAttr/RefineSlot10"),
}

AFFINAGE_CONSUME = {
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume0"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume1"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume2"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume3"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume4"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume5"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume6"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume7"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume8"),
	require("scripts/config/server/config/item/EquipSlotRefineCfg/EquipSlotRefineConsume9"),
}

AffinageData.EQUIP_AFFINAGE_INFO = "equip_affinage_info"
AffinageData.AFFINAGE_LV_CHANGE = "affinage_lv_change"
AffinageData.AFFINAGE_UP_DEFEATED = "affinage_up_defeated"
AffinageData.AFFINAGE_UP_SUCCED = "affinage_up_succed"

MAX_JILIAN_LEVEL = #(AFFINAGE_CONSUME and AFFINAGE_CONSUME[1] and AFFINAGE_CONSUME[1][1] or {})
function AffinageData:__init()
	if AffinageData.Instance then
		ErrorLog("[AffinageData] Attemp to create a singleton twice !")
	end
	AffinageData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.affinage_level_list = {}
	self.affinage_item_list = {}
	
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanAffinage, self), RemindName.EquipAffinage)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	self:SetAffinageCellDataList()
end

function AffinageData:__delete()
	AffinageData.Instance = self
    self.affinage_level_list = {}
end

function AffinageData:GetAffinageCellDataList()
	if self.affinage_data_list == nil then
		self:SetAffinageCellDataList()
	end
	return self.affinage_data_list
end

function AffinageData:GetAffinageCurrentIndex()
	local cur_index = 1
	-- if self.affinage_data_list and next(self.affinage_data_list) then 
	-- 	local slot = self.affinage_data_list[1]
	-- 	for k,v in pairs(self.affinage_data_list) do
	-- 		if v.affinage_lv < slot.affinage_lv then 
	-- 			cur_index = k
	-- 			break
	-- 		end
	-- 	end
	-- end
	return cur_index
end

function AffinageData:SetAffinageCellDataList()
    self.affinage_data_list = {}
    for k,v in pairs(EquipmentData.Equip) do
        local data = {}
		data.level = 0
        data.circle_lv = 0
        data.slot = v.equip_slot
		local equip_data = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
		if equip_data then
			local level, circle_lv = ItemData.GetItemLevel(equip_data.item_id)
			if circle_lv >= 3 then
			end
			data.equip_data = equip_data
			data.level = level
			data.circle_lv = circle_lv
		end
		data.affinage_lv = self:GetAffinageLevelBySlot(v.equip_slot + 1)
		table.insert(self.affinage_data_list, data)
	end
end

function AffinageData:GetAffinageLevelList()
	return self.affinage_level_list
end

function AffinageData:SetAffinageLevelList(level_list)
	for slot, level in pairs(level_list) do
		-- local real_slot = EquipmentData.Equip[k + 1].equip_slot + 1
		-- local real_slot = slot + 1
		self.affinage_level_list[slot] = level
		for index, v in ipairs(self.affinage_data_list or {}) do
			if v.slot == slot then
				v.affinage_lv = level
				break
			end
		end
	end
	self:DispatchEvent(AffinageData.EQUIP_AFFINAGE_INFO)
	GlobalEventSystem:Fire(OtherEventType.APOTHEOSIS_INFO_CHANGE)

	RemindManager.Instance:DoRemindDelayTime(RemindName.EquipAffinage)
end

function AffinageData:ChangeAffinageLevel(slot, level)
	-- local slot = EquipmentData.Equip[slot].equip_slot + 1
	-- local real_slot = slot + 1
	local old_level = self:GetAffinageLevelBySlot(slot)
	if old_level < level then
		self.affinage_level_list[slot] = level
		for index, v in ipairs(self.affinage_data_list) do
			if v.slot == slot then
				v.affinage_lv = level
			end
		end
		self:DispatchEvent(AffinageData.AFFINAGE_LV_CHANGE)
		GlobalEventSystem:Fire(OtherEventType.APOTHEOSIS_INFO_CHANGE, slot - 1)
	else
		self:DispatchEvent(AffinageData.AFFINAGE_UP_DEFEATED)
	end

	RemindManager.Instance:DoRemindDelayTime(RemindName.EquipAffinage)
end


function AffinageData:GetAffinageLevelBySlot(slot)
	return self.affinage_level_list[slot] or 0
end

function AffinageData.GetGodLevelName(level)
	return ""
end

-- 获得该等级、转生等级装备可获得的最大封神等级
function AffinageData.GetLimitAffinageLevel(level, circle_lv)
	return 0
end

function AffinageData.GetAffinageConsumeCfg(slot, level)
	local slot_consume = AFFINAGE_CONSUME[slot + 1] [1]
	return slot_consume and slot_consume[level] and slot_consume[level] [1]
end

function AffinageData.GetAffinageAttrCfg(slot, level, prof)
	prof = (nil == prof or 0 == prof) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or prof
	local cfg = AFFINAGE_CFG[slot + 1] [1]
	if 0 == level then
		local attr_cfg = TableCopy(cfg[prof] [1])
		for i,v in ipairs(attr_cfg) do
			v.value = 0
		end
		return attr_cfg
	end
	return cfg and cfg[prof] and cfg[prof] [level]
end

function AffinageData.GetApotheosisOpenLv()
	return 0
end

function AffinageData:GetAffinageAttr(slot, level)
	local attr_data = {}
	local slot_data = {}
	for k,v in pairs(self.affinage_level_list) do
		if slot == k then 
			slot_data = self.GetAffinageAttrCfg(k, level)
		else 
			slot_data = self.GetAffinageAttrCfg(k, v)
		end
		if nil == slot_data then return nil end
		attr_data = CommonDataManager.AddAttr(slot_data, attr_data)
	end
	return attr_data
end

function AffinageData:GetCanAffinage()
	local num = 0
	if ViewManager.Instance:CanOpen(ViewDef.Equipment.Refine) then
		for slot = EquipData.EquipSlot.itWeaponPos, EquipData.EquipSlot.itBaseEquipMaxPos do
			local consume_cfg = AffinageData.GetAffinageConsumeCfg(slot, self:GetAffinageLevelBySlot(slot) + 1)
			if consume_cfg ~= nil then
				local have = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
				self.affinage_item_list[consume_cfg.id] = 1
				if have >= consume_cfg.count then
					num = 1
					break
				end
			end
		end
	end
	return num
end

function AffinageData:OnBagItemChange(event)
	local affinage_item_list = self:GetAffinageConsume()
	event.CheckAllItemDataByFunc(function (vo)
		local item_id = vo and vo.data and vo.data.item_id or 0
		if vo.change_type == ITEM_CHANGE_TYPE.LIST or affinage_item_list[item_id] then
			RemindManager.Instance:DoRemindDelayTime(RemindName.EquipAffinage)
		end
	end)
end

function AffinageData:GetAffinageConsume()
	if nil == next(self.affinage_item_list) then 
		self.affinage_item_list = {[2514] = 1, [2937] = 1, [2938] = 1}
	end

	return self.affinage_item_list
end


function AffinageData:GetSuitLevel( ... )
	local all_jinglian_level = self:GetAllAffinageLevel()
	local cfg = RefinePlusCfg or {}
	local index = 0
	for i, v in ipairs(cfg) do
		if all_jinglian_level >= v.RefineLv then
			index = i
		end
	end

	return index
end


function AffinageData:GetAllAffinageLevel( ... )
	local level = 0
	for k, v in pairs(self.affinage_data_list or {}) do
		level = v.affinage_lv + level
	end
	return level
end

function AffinageData.GetStarSuitAttr(index)
	local cur_cfg = RefinePlusCfg and RefinePlusCfg[index] or {}
	local attr = cur_cfg.attrs or {}
	local count = cur_cfg.RefineLv or 0

	return attr, count
end