BossIntegralData = BossIntegralData or BaseClass()

CREST_SLOT_CFG_LIST = {
	require("scripts/config/server/config/bossArms/bossArmsAttr/warriorArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/marsArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/kingArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/monarchArms"),
}

BossIntegralData.GET_CREST_INFO = "get_crest_info"
BossIntegralData.CREST_UP_LEVEL = "crest_up_level"

function BossIntegralData:__init()
	if BossIntegralData.Instance then
		ErrorLog("[BossIntegralData]:Attempt to create singleton twice!")
	end
	BossIntegralData.Instance = self
	self.property_list = nil
	self.property_attr = nil
	self.crest_info = {}

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.CanUpCrestLevel, self), RemindName.IntegerBoss, true)
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function BossIntegralData:__delete()
	BossIntegralData.Instance = nil
end

function BossIntegralData:SetPropertyList()
	self.property_list = {}
	for i,v in ipairs(self.crest_info) do
		local data = {}
		data.slot = i
		data.level = v
		local count = bossArmsUpgradeCfg.consumes[i] [v + 1]
		data.next_level = count and count[1].count or 0
		table.insert(self.property_list, data)
	end
end

function BossIntegralData:GetPropertyList()
	if nil == self.property_list then 
		self:SetPropertyList()
	end
	return self.property_list
end

function BossIntegralData:GetPropertyAttr()
	local attr_data = {}
	for k,v in pairs(self.crest_info) do
		attr_data = CommonDataManager.AddAttr(attr_data, self:GetPropertyAttrBySlot(k))
	end
	return attr_data
end

function BossIntegralData:GetPropertyAttrBySlot(slot)
	local attr_data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if CREST_SLOT_CFG_LIST[slot] and CREST_SLOT_CFG_LIST[slot][1].attr and CREST_SLOT_CFG_LIST[slot][1].attr[self.crest_info[slot]] then 
		local attr_list = {}
		for k,v in pairs(CREST_SLOT_CFG_LIST[slot][1].attr[self.crest_info[slot]]) do
			if v.job == prof then 
				table.insert(attr_list, v)
			end
		end
		attr_data = CommonDataManager.AddAttr(attr_data, attr_list)
	end
	if nil == attr_data[1] then 
		local attr_list = TableCopy(CREST_SLOT_CFG_LIST[slot][1].attr[1])
		for k,v in pairs(attr_list) do
			if v.job == prof then 
				v.value = 0
				table.insert(attr_data, v)
			end
		end
	end
	return attr_data
end

function BossIntegralData:CanUpCrestLevel()
	local boss_integral = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ENERGY)
	for k,v in pairs(self:GetPropertyList()) do
		if boss_integral >= v.next_level then 
			return 1
		end
	end
	return 0
end

function BossIntegralData:SetCrestInfo(protocol)
	self.crest_info = protocol.crest_info
	self:SetPropertyList()
	RemindManager.Instance:DoRemind(RemindName.IntegerBoss)
	self:DispatchEvent(BossIntegralData.GET_CREST_INFO)
end

function BossIntegralData:SetCrestSlotLevel(protocol)
	if self.crest_info[protocol.crest_slot] < protocol.slot_level then 
		self.crest_info[protocol.crest_slot] = protocol.slot_level
		self:SetPropertyList()
		RemindManager.Instance:DoRemind(RemindName.IntegerBoss)
		self:DispatchEvent(BossIntegralData.CREST_UP_LEVEL, protocol.crest_slot)
	end
end