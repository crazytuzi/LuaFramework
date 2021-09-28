----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[48501] = {	id = 48501, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -212.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48502] = {	id = 48502, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -226.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48503] = {	id = 48503, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -240.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48504] = {	id = 48504, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -254.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48505] = {	id = 48505, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -268.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48506] = {	id = 48506, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -282.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48507] = {	id = 48507, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -296.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48508] = {	id = 48508, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -310.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48509] = {	id = 48509, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -324.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48510] = {	id = 48510, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -338.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
