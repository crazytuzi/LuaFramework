----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[60101] = {	id = 60101, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 4000, overlays = 2, overlayType = 4, affectType = 1, affectID = 2, valueType = 1, affectValue = -265.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 2, buffDrugIcon = 0, specialIcon = 0},
	[60102] = {	id = 60102, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60103] = {	id = 60103, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 8000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60104] = {	id = 60104, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 3000, overlays = 1, overlayType = 4, affectType = 1, affectID = 2, valueType = 1, affectValue = -265.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60105] = {	id = 60105, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 4000, overlays = 1, overlayType = 4, affectType = 1, affectID = 2, valueType = 1, affectValue = -265.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60106] = {	id = 60106, iconID = 355, effectID = 0, note = '无敌', owner = 1, loopTime = 5000, overlays = 1, overlayType = 4, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60107] = {	id = 60107, iconID = 346, effectID = 30217, note = '加速', owner = 1, loopTime = 5000, overlays = 1, overlayType = 4, affectType = 1, affectID = 2, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60108] = {	id = 60108, iconID = 346, effectID = 30217, note = '加速', owner = 1, loopTime = 5000, overlays = 1, overlayType = 4, affectType = 1, affectID = 2, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60109] = {	id = 60109, iconID = 346, effectID = 30217, note = '加速', owner = 1, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 2, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[60110] = {	id = 60110, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 5000, overlays = 1, overlayType = 4, affectType = 2, affectID = 20, valueType = 2, affectValue = -1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[60111] = {	id = 60111, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 5000, overlays = 1, overlayType = 4, affectType = 2, affectID = 23, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
