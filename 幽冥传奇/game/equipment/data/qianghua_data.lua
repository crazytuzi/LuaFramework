QianghuaData = QianghuaData or BaseClass()

STRENGTH_CFG = {
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot0StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot1StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot2StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot3StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot4StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot5StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot6StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot7StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot8StrongAttrsCfg"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongAttrs/EquipSlot9StrongAttrsCfg"),
}

STRENGTH_CONSUME = {
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume0"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume1"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume2"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume3"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume4"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume5"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume6"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume7"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume8"),
	require("scripts/config/server/config/equipSynthesis/EquipSlotStrongConsume/StrongConsume9"),
}

MAX_STRENGTHEN_SLOT = #(STRENGTH_CONSUME or {})
MAX_STRENGTHEN_LEVEL = #(STRENGTH_CONSUME and STRENGTH_CONSUME[1] and STRENGTH_CONSUME[1][1] or {})
EQUIP_STRENGTHEN_INFO = {slot = 0, strengthen_level = 0}
QianghuaData.FLUSH_STRENGTHEN_ATTR = "flush_strengthen_attr"
QianghuaData.STRENGTHEN_CHANGE = "strengthen_change"
QianghuaData.STOP_STRENGTHEN = "stop_strengthen"

QianghuaData.max_level = 15
QianghuaData.max_phase = 6

-- 一键镶嵌和升级的顺序
QianghuaData.Order = {0, 1, 4, 6, 8, 2, 3, 5, 7, 9}

-- 衣服和头盔的顺序 与人物装备槽位相同
STRENGTH_INDEX = {
	Weapon = 0,					--武器
	Dress = 1,					--衣服
	Helmet = 2,					--头盔
	Necklace = 3,				--项链
	Bracelet = 4,				--手镯
	BraceletR = 5,				--手镯
	Ring = 6,					--戒指
	RingR = 7,					--戒指
	Girdle = 8,					--腰带
	Shoes = 9,					--鞋子
}

function QianghuaData:__init()
	if QianghuaData.Instance then
		ErrorLog("[QianghuaData] Attemp to create a singleton twice !")
	end
	QianghuaData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.strengthen_list = {}
	self.consume_item_list = {}
	
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanStrengthNum, self), RemindName.EquipStrengthen)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function QianghuaData:__delete()
	QianghuaData.Instance = self
    self.strengthen_list = {}
end

function QianghuaData:SetStrengthList(strengthen_list)
	self.strengthen_list = strengthen_list

	self:DispatchEvent(QianghuaData.FLUSH_STRENGTHEN_ATTR)
	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE)
end

function QianghuaData:SetOneKeyStrengthList(strengthen_list)
	for k,v in pairs(strengthen_list) do
		self.strengthen_list[k] = v
	end
	self:DispatchEvent(QianghuaData.FLUSH_STRENGTHEN_ATTR)
	GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE)
	GlobalEventSystem:Fire(OtherEventType.STRENGTH_1KEY_SUCC)
end

function QianghuaData:GetStrengthList()
	return self.strengthen_list
end

function QianghuaData:GetStrengthCurIndex()
	local cur_index = 0
	if self.strengthen_list and next(self.strengthen_list) then 
		local slot = self.strengthen_list[0]
		for k,v in pairs(self.strengthen_list) do
			if v.strengthen_level < slot.strengthen_level then 
				cur_index = k
				break
			end
		end
	end
	return cur_index
end


function QianghuaData:GetOneStrengthList(slot)
	return self.strengthen_list[slot] or EQUIP_STRENGTHEN_INFO
end


function QianghuaData:GetOneStrengthLvByEquipIndex(slot)
	local strengthen_info = self.strengthen_list[slot]
	if strengthen_info then
		return strengthen_info.strengthen_level
	else
		return nil
	end
end

function QianghuaData:StrengthenChange(protocol)
	local real_index = protocol.data.slot
	local old_data = QianghuaData.Instance:GetOneStrengthList(real_index)
	if protocol.result == 0 or old_data.strengthen_level >= protocol.data.strengthen_level then
		self:DispatchEvent(QianghuaData.STOP_STRENGTHEN)
	else
		self.strengthen_list[protocol.data.slot] = protocol.data
		GlobalEventSystem:Fire(OtherEventType.STRENGTH_INFO_CHANGE, protocol.data.slot)
		self:DispatchEvent(QianghuaData.STRENGTHEN_CHANGE, protocol.data.slot)
	end
end

function QianghuaData.GetStrengthenAttrCfg(slot, level, prof)
	if slot < 0 or slot > MAX_STRENGTHEN_SLOT - 1 then
		return nil
	end
	local prof = (prof and 0 ~= prof) and prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if 0 == level then
		local cfg = TableCopy(STRENGTH_CFG[slot + 1][1][prof][1])
		for i,v in ipairs(cfg) do
			v.value = 0
		end
		return cfg
	end
	return STRENGTH_CFG[slot + 1][1][prof][level]
end

function QianghuaData:GetStrengthenConsume(slot, level)
	return STRENGTH_CONSUME[slot + 1][1][level]
end

function QianghuaData.IsStrengthEquip(index)
	return QianghuaData.GetStrengthIndex(index) >= 0
end

function QianghuaData:GetStrengthenAttr(slot, level)
	local attr_data = {}
	local slot_attr_data = {}
	local strengthen_info = nil
	for i = 0, MAX_STRENGTHEN_SLOT - 1 do
		strengthen_info = self:GetOneStrengthList(i)
		if i == slot then 
			slot_attr_data = self.GetStrengthenAttrCfg(i, level) 
		else
			slot_attr_data = self.GetStrengthenAttrCfg(i, strengthen_info.strengthen_level) 
		end
		if nil == slot_attr_data then return nil end
		attr_data = CommonDataManager.AddAttr(slot_attr_data, attr_data)
	end
	return attr_data
end

function QianghuaData:GetAllStrengthLevel()
	local n = 0
	for k, v in pairs(self.strengthen_list) do
		n = n + v.strengthen_level
	end
	return n
end

function QianghuaData:GetAllStrengthLevelIgnoreEquip()
	local n = 0
	for k, v in pairs(self.strengthen_list) do
		n = n + v.strengthen_level
	end
	return n
end

function QianghuaData:GetMaxStrengthLevel()
	if nil == self.max_strength_lv or 0 == self.max_strength_lv then
		self.max_strength_lv = #STRENGTH_CONSUME[1][1]
	end
	return self.max_strength_lv
end

function QianghuaData.FormatStrengthStar(star_level)
	if nil == star_level then return end
	local grade = math.floor(star_level / 12)
	local star = star_level % 12
	if grade > 0 and star == 0 then
		grade = grade - 1
		star = 12
	end
	return grade, star
end

--获得装备左右
function QianghuaData:GetBetterStrengthHandPos(item_type)
	if item_type == ItemData.ItemType.itBracelet or item_type == ItemData.ItemType.itRing then
		local index = EquipData.Instance:GetEquipIndexByType(item_type, 0)
		local strength_vo = self:GetOneStrengthList(index)
		local index2 = EquipData.Instance:GetEquipIndexByType(item_type, 1)
		local strength_vo2 = self:GetOneStrengthList(index2)
		return strength_vo.strengthen_level < strength_vo2.strengthen_level and 1 or 0
	end
	return 0
end

-- 获取可以强化的数量
function QianghuaData:GetCanStrengthNum()
	local num = 0
	for i = 0, MAX_STRENGTHEN_SLOT - 1 do
		local strengthen_info = self:GetOneStrengthList(i)
		if not strengthen_info then break end
		local consume_cfg = self:GetStrengthenConsume(i, strengthen_info.strengthen_level and (strengthen_info.strengthen_level + 1))
		if consume_cfg and consume_cfg[1] then
			local stuff_id, stuff_count = consume_cfg[1].id, consume_cfg[1].count
			self.consume_item = stuff_id
			local has_count = BagData.Instance:GetItemNumInBagById(stuff_id)

			local consume_type, consume_count = consume_cfg[2].type, consume_cfg[2].count
			local has_count_2 = RoleData.Instance:GetMainMoneyByType(consume_type)

			local bool = has_count >= stuff_count and has_count_2 >= consume_count
			if bool then 
				num = num + 1 
				break
			end
		end
	end
	return num
end

function QianghuaData.GetStrengthIndex(index)
	if index == EquipData.EquipIndex.Weapon then
		return STRENGTH_INDEX.Weapon
	elseif index == EquipData.EquipIndex.Dress then
		return STRENGTH_INDEX.Dress
	elseif index == EquipData.EquipIndex.Helmet then
		return STRENGTH_INDEX.Helmet
	elseif index == EquipData.EquipIndex.Necklace then
		return STRENGTH_INDEX.Necklace
	elseif index == EquipData.EquipIndex.Bracelet then
		return STRENGTH_INDEX.Bracelet
	elseif index == EquipData.EquipIndex.BraceletR then
		return STRENGTH_INDEX.BraceletR
	elseif index == EquipData.EquipIndex.Ring then
		return STRENGTH_INDEX.Ring
	elseif index == EquipData.EquipIndex.Girdle then
		return STRENGTH_INDEX.Girdle
	elseif index == EquipData.EquipIndex.Shoes then
		return STRENGTH_INDEX.Shoes
	elseif index == EquipData.EquipIndex.RingR then
		return STRENGTH_INDEX.RingR
	end
	return - 1
end

--判断哪一个是可强化的
function QianghuaData:IsCanStrength()
	local data = {}
	for i = 0, MAX_STRENGTHEN_SLOT - 1 do
		local strengthen_info = QianghuaData.Instance:GetOneStrengthList(i)
		if not strengthen_info then break end
		local consume_cfg = QianghuaData:GetStrengthenConsume(i, strengthen_info.strengthen_level and(strengthen_info.strengthen_level + 1))
		if consume_cfg and consume_cfg[1] then
			local stuff_id, stuff_count = consume_cfg[1].id, consume_cfg[1].count
			self.consume_item_list[stuff_id] = 1
			local has_count = BagData.Instance:GetItemNumInBagById(stuff_id)
			if has_count and has_count >= stuff_count and strengthen_info.strengthen_level < self:GetMaxStrengthLevel() then
				data[i] = 1
			end
		end
	end
	return data
end

function QianghuaData:OnBagItemChange(event)
	local consume_item_list = self:GetStrengthConsume()
	event.CheckAllItemDataByFunc(function (vo)
		local item_id = vo and vo.data and vo.data.item_id or 0
		if vo.change_type == ITEM_CHANGE_TYPE.LIST or consume_item_list[item_id] then
			RemindManager.Instance:DoRemindDelayTime(RemindName.EquipStrengthen)
		end
	end)
end

-- 为更好的性能,只监听固定的物品id
function QianghuaData:GetStrengthConsume()
	if nil == next(self.consume_item_list) then
		self.consume_item_list = {[351] = 1, [442] = 1, [443] = 1}
	end

	return self.consume_item_list
end

function QianghuaData.GetQinghuaLvShowIndex(lv)
	local max_level = QianghuaData.max_level
	local index, count
	count = (lv == 0) and 0 or ((lv % max_level) == 0 and max_level or lv % max_level)
	index = (lv - count) / max_level + 1

	return index, count
end


function QianghuaData:StarSuitIndex()
	local all_strength_level = self:GetAllStrengthLevel()
	local cfg = SlotPlusCfg or {}
	local index = 0
	for i, v in ipairs(cfg) do
		if all_strength_level >= v.level then
			index = i
		end
	end

	return index
end

function QianghuaData.GetStarSuitAttr(index)
	local cur_cfg = SlotPlusCfg and SlotPlusCfg[index] or {}
	local attr = cur_cfg.attrs or {}
	local count = cur_cfg.level or 0

	return attr, count
end