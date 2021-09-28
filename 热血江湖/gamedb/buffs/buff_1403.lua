----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[140301] = {	id = 140301, iconID = 10884, effectID = 0, note = '胸甲装备属性降低5%', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10301, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1403, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[140302] = {	id = 140302, iconID = 10884, effectID = 0, note = '胸甲装备属性降低10%', owner = 0, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10302, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1403, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[140303] = {	id = 140303, iconID = 10884, effectID = 0, note = '胸甲装备属性降低15%', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10303, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1403, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[140304] = {	id = 140304, iconID = 10884, effectID = 0, note = '胸甲装备属性降低20%', owner = 0, loopTime = 3500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10304, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1403, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[140305] = {	id = 140305, iconID = 10884, effectID = 0, note = '胸甲装备属性降低30%', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10305, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1403, buffSlotLvl = 5, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
