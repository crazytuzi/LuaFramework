----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[60201] = {	id = 60201, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 6000000, overlays = 1, overlayType = 2, affectType = 2, affectID = 26, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60202] = {	id = 60202, iconID = 355, effectID = 0, note = '', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60203] = {	id = 60203, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 1, overlayType = 1, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60204] = {	id = 60204, iconID = 347, effectID = 30110, note = '恐惧', owner = 0, loopTime = 3000, overlays = 1, overlayType = 1, affectType = 2, affectID = 22, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4556},
	[60205] = {	id = 60205, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 8200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60206] = {	id = 60206, iconID = 0, effectID = 0, note = '百分比掉血', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -2000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60207] = {	id = 60207, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
