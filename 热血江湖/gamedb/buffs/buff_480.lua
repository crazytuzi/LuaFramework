----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[48001] = {	id = 48001, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5001, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48002] = {	id = 48002, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5002, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48003] = {	id = 48003, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5003, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48004] = {	id = 48004, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5004, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48005] = {	id = 48005, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5005, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48006] = {	id = 48006, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5006, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48007] = {	id = 48007, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5007, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48008] = {	id = 48008, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5008, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48009] = {	id = 48009, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5009, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[48010] = {	id = 48010, iconID = 10439, effectID = 30122, note = '反击', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 5010, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
