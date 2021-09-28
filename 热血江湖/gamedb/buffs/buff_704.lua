----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[70401] = {	id = 70401, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1800.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70402] = {	id = 70402, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 2100.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70403] = {	id = 70403, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 2400.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70404] = {	id = 70404, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 2700.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70405] = {	id = 70405, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70406] = {	id = 70406, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 3300.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70407] = {	id = 70407, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 3600.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70408] = {	id = 70408, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 3900.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70409] = {	id = 70409, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 4200.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70410] = {	id = 70410, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 4500.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
