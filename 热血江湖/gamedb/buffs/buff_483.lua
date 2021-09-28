----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[48301] = {	id = 48301, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -212.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48302] = {	id = 48302, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -226.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48303] = {	id = 48303, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -240.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48304] = {	id = 48304, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -254.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48305] = {	id = 48305, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -268.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48306] = {	id = 48306, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -282.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48307] = {	id = 48307, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -296.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48308] = {	id = 48308, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -310.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48309] = {	id = 48309, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -324.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48310] = {	id = 48310, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -338.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
