----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[70501] = {	id = 70501, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 3000, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70502] = {	id = 70502, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 3400, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70503] = {	id = 70503, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 3800, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70504] = {	id = 70504, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 4200, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70505] = {	id = 70505, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 4600, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70506] = {	id = 70506, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70507] = {	id = 70507, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 5400, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70508] = {	id = 70508, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 5800, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70509] = {	id = 70509, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 6200, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70510] = {	id = 70510, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 6600, overlays = 1, overlayType = 1, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
