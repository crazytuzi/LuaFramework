MoldingSoulData = MoldingSoulData or BaseClass()



MoldingSoulData.EQUIP_SOUL_INFO = "equip_soul_info"
MoldingSoulData.SOUL_UP_GRADE = "soul_up_grade"
MoldingSoulData.SOUL_UP_DEFEATED = "soul_up_defeated"
MoldingSoulData.SOUL_1KEY_UP_SUCCED = "soul_1key_up_succed"

MOLDING_SOUL_CFG = {
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot1"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot2"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot3"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot4"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot5"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot6"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot7"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot8"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot9"),
	require("scripts/config/server/config/item/MoldingSoul/MoldingSoulSlot10"),
}

MOLDING_SOUL_CONSUME = {
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume1"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume2"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume3"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume4"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume5"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume6"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume7"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume8"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume9"),
	require("scripts/config/server/config/item/MoldingSoulConsume/MoldingSoulConsume10"),
}

function MoldingSoulData:__init()
	if MoldingSoulData.Instance then
		ErrorLog("[MoldingSoulData] Attemp to create a singleton twice !")
	end
	MoldingSoulData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.equip_soul_info = {}

	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetCanMoldingSoulNum, self), RemindName.EquipMoldingSoul)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function MoldingSoulData:__delete()
	MoldingSoulData.Instance = nil
end

-- 接收铸魂数据
function MoldingSoulData:SetEquipSoulInfo(data)
	for i = 1, #data do 
		self.equip_soul_info[i] = data[i]
	end
	self:DispatchEvent(MoldingSoulData.EQUIP_SOUL_INFO)
	GlobalEventSystem:Fire(OtherEventType.MOLDINGSOUL_INFO_CHANGE)
end

function MoldingSoulData:SetEquipSoulOneKeyInfo(data)
	for k,v in pairs(data) do
		self.equip_soul_info[k] = v
	end
	self:DispatchEvent(MoldingSoulData.EQUIP_SOUL_INFO)
	GlobalEventSystem:Fire(OtherEventType.MOLDINGSOUL_INFO_CHANGE)
	GlobalEventSystem:Fire(MoldingSoulData.SOUL_1KEY_UP_SUCCED)
end

function MoldingSoulData:GetEqSoulLevel(slot)
	return self.equip_soul_info[slot] or 0
end

function MoldingSoulData:ChangeEqSoulLevel(slot, new_level)
	local old_level = MoldingSoulData.Instance:GetEqSoulLevel(slot)
	if old_level < new_level then
		self.equip_soul_info[slot] = new_level
		self:DispatchEvent(MoldingSoulData.SOUL_UP_GRADE)
		GlobalEventSystem:Fire(OtherEventType.MOLDINGSOUL_INFO_CHANGE, slot)
	else
		self:DispatchEvent(MoldingSoulData.SOUL_UP_DEFEATED)
	end
end

function MoldingSoulData:GetEqSoulShowData()
	local data_list = {}
	for i = 1, 10 do
		local data = {equip = nil, soul_level = 0, }
		data.soul_level = self.equip_soul_info[i]
		table.insert(data_list, data)
	end

	return data_list
end

function MoldingSoulData:GetEqSoulLevelByEquipIndex(slot)
	local real_slot = slot + 1
	return self:GetEqSoulLevel(real_slot)
end

function MoldingSoulData.GetMoldingSoulAttrCfg(slot, level, prof)
	slot = slot or 1
	if level > MoldingSoulCfg.maxLevel then return nil end
	prof = (nil == prof or 0 == prof) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or prof
	if 0 == level then 
		local cfg = TableCopy(MOLDING_SOUL_CFG[slot][1][1][prof])
		for i,v in ipairs(cfg) do
			v.value = 0
		end
		return cfg
	end
	return MOLDING_SOUL_CFG[slot][1][level][prof]
end

function MoldingSoulData.GetMoldingSoulConsume(slot, level)
	return MOLDING_SOUL_CONSUME[slot] and MOLDING_SOUL_CONSUME[slot][1][level] and MOLDING_SOUL_CONSUME[slot][1][level][1]
end

function MoldingSoulData:IsSoulStone(item_id)
	if self.equip_soul_info and next(self.equip_soul_info) then 
		local slot = self:GetSoulCurSlot()
		local level = self.equip_soul_info[slot] + 1
		local consume_data = self.GetMoldingSoulConsume(slot,level)
		if consume_data and consume_data.id == item_id then 
			return true
		end
	end
	return false
end

function MoldingSoulData:GetCanMoldingSoulNum()
	local slot = self:GetSoulCurSlot()
	if self:CanEqSoul(slot, self.equip_soul_info[slot] or 0) then
		return 1
	end
	return 0
end

function MoldingSoulData:CanEqSoul(slot, level)
	local consume_cfg = MoldingSoulData.GetMoldingSoulConsume(slot, level + 1)
	if consume_cfg then
		local have = BagData.Instance:GetItemNumInBagById(consume_cfg.id)
		self.soul_item = consume_cfg.id
		if have >= consume_cfg.count then
			return true
		end
	end
	return false
end

function MoldingSoulData:GetAllMsStrengthLevel()
	local level = 0
	for k, v in pairs(self.equip_soul_info) do
		level = level + v
	end
	return level
end

function MoldingSoulData:GetSoulAttr(slot, level)
	local attr_data = {}
	local slot_data = {}
	for k,v in pairs(self.equip_soul_info) do
		if slot == k then 
			slot_data = self.GetMoldingSoulAttrCfg(k, level)
		else 
			slot_data = self.GetMoldingSoulAttrCfg(k, v)
		end
		if nil == slot_data then return nil end
		attr_data = CommonDataManager.AddAttr(slot_data, attr_data)
	end
	return attr_data
end

function MoldingSoulData:GetSoulCurSlot()
	local cur_slot = 1
	if self.equip_soul_info and next(self.equip_soul_info) then 
		local cur_level = self.equip_soul_info[cur_slot] 
		for k,v in pairs(self.equip_soul_info) do
			if v < cur_level then 
				cur_slot = k
				break
			end
		end
	end
	return cur_slot
end

function MoldingSoulData.GetLimitSoulLevel(level, circle_lv)
	for i = #MoldingSoulCfg.AttrStratum, 1, - 1 do
		local v = MoldingSoulCfg.AttrStratum[i]
		if v and level >= v.level and circle_lv >= v.circle then
			return v.maxSoulLv
		end
	end
end


function MoldingSoulData.GetMoldingSoulDesc(level)
	local t = {
		-- {cc.c3b(0x26, 0x6a, 0xa8), Language.Equipment.MoldingSoulTitle[1], cc.c4b(0x26, 0x6a, 0xa8, 0xff)},
		-- {cc.c3b(0xc7, 0x28, 0xba), Language.Equipment.MoldingSoulTitle[2], cc.c4b(0xc7, 0x28, 0xba, 0xff)},
		-- {cc.c3b(0xd0, 0x2c, 0x26), Language.Equipment.MoldingSoulTitle[3], cc.c4b(0xd0, 0x2c, 0x26, 0xff)},
		{COLOR3B.PURPLE, Language.Equipment.MoldingSoulTitle[1], cc.c4b(0, 0, 0, 255)},
		{COLOR3B.ORANGE, Language.Equipment.MoldingSoulTitle[2], cc.c4b(0, 0, 0, 255)},
		{COLOR3B.RED, Language.Equipment.MoldingSoulTitle[3], cc.c4b(0, 0, 0, 255)},
	}
	if level <= 0 then return t[1] end
	return t[math.ceil(level / 12)]
end

function MoldingSoulData:OnBagItemChange(vo)
	local consume_id = self:GetSoulConsume()
	if vo.GetChangeDataList then
		for i,v in ipairs(vo:GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST or (v.data and v.data.item_id == consume_id) then
				-- RemindManager.Instance:DoRemindDelayTime(RemindName.EquipMoldingSoul)
				break
			end
		end
	end
end

function MoldingSoulData:GetSoulConsume()
	if nil == self.soul_item then
		self.soul_item = 3480
	end
	return self.soul_item
end