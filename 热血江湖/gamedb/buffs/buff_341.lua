----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[34101] = {	id = 34101, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34102] = {	id = 34102, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -700.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34103] = {	id = 34103, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34104] = {	id = 34104, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -900.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34105] = {	id = 34105, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34106] = {	id = 34106, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34107] = {	id = 34107, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34108] = {	id = 34108, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34109] = {	id = 34109, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[34110] = {	id = 34110, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 2, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
