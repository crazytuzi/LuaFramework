----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[70601] = {	id = 70601, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -100.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70602] = {	id = 70602, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -150.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70603] = {	id = 70603, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -200.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70604] = {	id = 70604, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -250.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70605] = {	id = 70605, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -300.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70606] = {	id = 70606, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -350.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70607] = {	id = 70607, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -400.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70608] = {	id = 70608, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -450.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70609] = {	id = 70609, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -500.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70610] = {	id = 70610, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -550.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
