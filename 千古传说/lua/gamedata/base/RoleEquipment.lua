
--[[
******游戏数据弟子装备管理类*******

	-- by Stephen.tao
	-- 2013/11/27

	-- by david.dai
	-- 2014/06/26
]]

local RoleEquipment = class("RoleEquipment",TFArray)

function RoleEquipment:ctor()
	self.super.ctor(self)
	self.map = {}
end


--[[--
	更换装备
	@param equipment: 装备
	@return 更换是否成功
]]	
function RoleEquipment:AddEquipment(equipment)
	if equipment.type == nil  or equipment.type ~= EnumGameObjectType.Equipment then
		return  false
	end

	--如果此装备已装备在其他人身上，先卸下
	if equipment.equip ~= nil and equipment.equip ~= 0 then
		local role = CardRoleManager:getRoleById(equipment.equip)
		if role then 
			role:getEquipment():DelEquipmentBygmid(equipment.gmId)
		end
	end

	--是否已有此类型，有就卸下
	if self.map[equipment.equipType] then
		self.DelEquipmentBytype(self,equipment.equipType)
	end

	self.super.push(self, equipment)
	self.map[equipment.equipType] = equipment
end

--[[--
	返回指定装备类型的装备
	@param type: 装备类型
	@return 指定Key值的元素
]]	
function RoleEquipment:GetEquipByType(type)
	return self.map[type]
end

--[[--
	卸下指定类型的装备
	@param type: 装备类型
	@return 成功失败
]]	
function RoleEquipment:DelEquipmentBytype(type)
	local equip = self:GetEquipByType(type)
	if  equip  then
		equip.equip   = 0
		self.super.removeObject(self,equip)
		self.map[type] = nil
		return true
	end
	return false
end
--[[--
	卸下指定gmid的装备
	@param gmid: 装备gmId
	@return 成功失败
]]	
function RoleEquipment:DelEquipmentBygmid(gmid)
	local equip = EquipmentManager:getEquipByGmid(gmid)
	if  equip  then
		equip.equip   = 0
		self.super.removeObject(self,equip)
		self.map[equip.equipType] = nil
		return true
	end
	return false
end
--[[--
	卸下指定的装备
	@param equip: 装备
	@return 成功失败
]]	
function RoleEquipment:DelEquipment(equip)
	--local equip = EquipmentManager:getEquipByGmid(gmid)
	if  equip  then
		equip.equip   = 0
		self.super.removeObject(self,equip)
		self.map[equip.equipType] = nil
		return true
	end
	return false
end

--[[--
	已数组方式返回所有装备，为空的装备位直接忽略，只存放不为空的装备位中的装备
	@return 返回TFArray类型的所有装备列表
]]
function RoleEquipment:allAsArray()
	local result = TFArray:new()
	for i = EnumGameEquipmentType.Weapon,EnumGameEquipmentType.Shoe do
		if self.map[i] then
			result:pushBack(self.map[i])
		end
	end
	return result
end

return RoleEquipment