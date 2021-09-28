----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[140601] = {	id = 140601, iconID = 10880, effectID = 0, note = '戒指装备属性降低5%', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10601, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1406, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[140602] = {	id = 140602, iconID = 10880, effectID = 0, note = '戒指装备属性降低10%', owner = 0, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10602, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1406, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[140603] = {	id = 140603, iconID = 10880, effectID = 0, note = '戒指装备属性降低15%', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10603, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1406, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[140604] = {	id = 140604, iconID = 10880, effectID = 0, note = '戒指装备属性降低20%', owner = 0, loopTime = 3500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10604, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1406, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[140605] = {	id = 140605, iconID = 10880, effectID = 0, note = '戒指装备属性降低30%', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10605, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1406, buffSlotLvl = 5, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
