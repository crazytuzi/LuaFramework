----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[70701] = {	id = 70701, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21301, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70702] = {	id = 70702, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21302, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70703] = {	id = 70703, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21303, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70704] = {	id = 70704, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21304, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70705] = {	id = 70705, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21305, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70706] = {	id = 70706, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21306, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70707] = {	id = 70707, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21307, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70708] = {	id = 70708, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21308, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70709] = {	id = 70709, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21309, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70710] = {	id = 70710, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 2500, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 21310, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[70751] = {	id = 70751, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -90.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70752] = {	id = 70752, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -120.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70753] = {	id = 70753, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -150.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70754] = {	id = 70754, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -180.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70755] = {	id = 70755, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -210.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70756] = {	id = 70756, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -240.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70757] = {	id = 70757, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -270.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70758] = {	id = 70758, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -300.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70759] = {	id = 70759, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -330.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[70760] = {	id = 70760, iconID = 0, effectID = 0, note = '怒气减少', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = -360.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
