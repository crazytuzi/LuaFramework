----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[70801] = {	id = 70801, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14001, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70802] = {	id = 70802, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14002, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70803] = {	id = 70803, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14003, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70804] = {	id = 70804, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14004, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70805] = {	id = 70805, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14005, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70806] = {	id = 70806, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14006, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70807] = {	id = 70807, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14007, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70808] = {	id = 70808, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14008, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70809] = {	id = 70809, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14009, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70810] = {	id = 70810, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14010, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70811] = {	id = 70811, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14011, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70812] = {	id = 70812, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14012, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70813] = {	id = 70813, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14013, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70814] = {	id = 70814, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14014, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70815] = {	id = 70815, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14015, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70816] = {	id = 70816, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14016, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70817] = {	id = 70817, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14017, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70818] = {	id = 70818, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14018, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70819] = {	id = 70819, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14019, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70820] = {	id = 70820, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 14020, }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
