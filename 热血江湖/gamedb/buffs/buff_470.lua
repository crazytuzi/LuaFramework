----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[47001] = {	id = 47001, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47002] = {	id = 47002, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47003] = {	id = 47003, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -1400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47004] = {	id = 47004, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -1600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47005] = {	id = 47005, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -1800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47006] = {	id = 47006, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47007] = {	id = 47007, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47008] = {	id = 47008, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47009] = {	id = 47009, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[47010] = {	id = 47010, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
