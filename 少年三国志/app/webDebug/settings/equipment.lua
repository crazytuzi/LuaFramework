
local MergeEquipment = require("app.data.MergeEquipment")

local getStrEquipmentId = function ( )
	for k , v in pairs(G_Me.bagData:getSortedEquipmentList()) do 
		if v.level < v:getMaxStrengthLevel() then
			return v.id
		end
	end
	return 0
end

local getRefEquipmentId = function ( )
	for k , v in pairs(G_Me.bagData:getSortedEquipmentList()) do 
		if v.level < v:getMaxRefineLevel() then
			return v.id
		end
	end
	return 0
end

local equipment = {
    UpgradeEquipment = {
        {msg = {equipment_id=getStrEquipmentId()+9999999,times=1,},repeatTimes = 1, ret = 0,},
        {msg = {equipment_id=getStrEquipmentId(),times=1000,},repeatTimes = 1, ret = 0,},
        {msg = {equipment_id=getStrEquipmentId(),times=3,},repeatTimes = 1, ret = 0,},
    },
    RefiningEquipment = {
    	{msg = {equipment_id=getRefEquipmentId(),item_id=11,num=999999999999},repeatTimes = 1, ret = 0,},
        {msg = {equipment_id=getRefEquipmentId()+9999999,item_id=13,num=5},repeatTimes = 1, ret = 0,},
        {msg = {equipment_id=getRefEquipmentId(),item_id=99,num=5},repeatTimes = 1, ret = 0,},
    },
}

return equipment