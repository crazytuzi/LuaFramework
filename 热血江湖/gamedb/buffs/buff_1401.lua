----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[140101] = {	id = 140101, iconID = 10882, effectID = 0, note = '武器装备属性降低5%', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10101, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1401, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[140102] = {	id = 140102, iconID = 10882, effectID = 0, note = '武器装备属性降低10%', owner = 0, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10102, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1401, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[140103] = {	id = 140103, iconID = 10882, effectID = 0, note = '武器装备属性降低15%', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10103, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1401, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[140104] = {	id = 140104, iconID = 10882, effectID = 0, note = '武器装备属性降低20%', owner = 0, loopTime = 3500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10104, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1401, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[140105] = {	id = 140105, iconID = 10882, effectID = 0, note = '武器装备属性降低30%', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10105, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1401, buffSlotLvl = 5, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
