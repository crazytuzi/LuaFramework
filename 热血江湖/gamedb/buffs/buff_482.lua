----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[48201] = {	id = 48201, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -212.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48202] = {	id = 48202, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -226.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48203] = {	id = 48203, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -240.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48204] = {	id = 48204, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -254.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48205] = {	id = 48205, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -268.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48206] = {	id = 48206, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -282.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48207] = {	id = 48207, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -296.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48208] = {	id = 48208, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -310.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48209] = {	id = 48209, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -324.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48210] = {	id = 48210, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 1, affectValue = -338.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
