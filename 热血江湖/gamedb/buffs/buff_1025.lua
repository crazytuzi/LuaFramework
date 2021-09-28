----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102501] = {	id = 102501, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 1, affectValue = 50000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1025, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[102502] = {	id = 102502, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 1, affectValue = 80000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1025, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[102503] = {	id = 102503, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 1, affectValue = 100000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1025, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[102504] = {	id = 102504, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 1, affectValue = 80000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1025, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
