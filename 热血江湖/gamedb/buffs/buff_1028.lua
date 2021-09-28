----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102801] = {	id = 102801, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[102802] = {	id = 102802, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[102803] = {	id = 102803, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[102804] = {	id = 102804, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[102805] = {	id = 102805, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[102806] = {	id = 102806, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1034, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1028, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
