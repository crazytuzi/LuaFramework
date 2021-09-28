----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[39001] = {	id = 39001, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 720.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39002] = {	id = 39002, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 840.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39003] = {	id = 39003, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 960.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39004] = {	id = 39004, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1080.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39005] = {	id = 39005, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39006] = {	id = 39006, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1320.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39007] = {	id = 39007, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1440.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39008] = {	id = 39008, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1560.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39009] = {	id = 39009, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1680.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[39010] = {	id = 39010, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
