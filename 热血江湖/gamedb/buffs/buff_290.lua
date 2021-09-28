----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[29001] = {	id = 29001, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -125.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29002] = {	id = 29002, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -161.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29003] = {	id = 29003, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -197.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29004] = {	id = 29004, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -233.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29005] = {	id = 29005, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -269.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29006] = {	id = 29006, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -305.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29007] = {	id = 29007, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -341.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29008] = {	id = 29008, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -377.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29009] = {	id = 29009, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -413.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29010] = {	id = 29010, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -449.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29011] = {	id = 29011, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -485.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29012] = {	id = 29012, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -521.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29013] = {	id = 29013, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -557.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29014] = {	id = 29014, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -593.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29015] = {	id = 29015, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -629.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29016] = {	id = 29016, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -665.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29017] = {	id = 29017, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -701.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29018] = {	id = 29018, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -737.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29019] = {	id = 29019, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -773.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[29020] = {	id = 29020, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = -824.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
