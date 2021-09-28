----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[140201] = {	id = 140201, iconID = 10886, effectID = 0, note = '护手装备属性降低5%', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10201, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1402, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[140202] = {	id = 140202, iconID = 10886, effectID = 0, note = '护手装备属性降低10%', owner = 0, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10202, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1402, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[140203] = {	id = 140203, iconID = 10886, effectID = 0, note = '护手装备属性降低15%', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10203, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1402, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[140204] = {	id = 140204, iconID = 10886, effectID = 0, note = '护手装备属性降低20%', owner = 0, loopTime = 3500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10204, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1402, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[140205] = {	id = 140205, iconID = 10886, effectID = 0, note = '护手装备属性降低30%', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10205, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1402, buffSlotLvl = 5, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
