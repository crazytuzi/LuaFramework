----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[71101] = {	id = 71101, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -240.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71102] = {	id = 71102, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -600.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71103] = {	id = 71103, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -800.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71104] = {	id = 71104, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -1100.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71105] = {	id = 71105, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -1500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71106] = {	id = 71106, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71107] = {	id = 71107, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -2700.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71108] = {	id = 71108, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -3600.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71109] = {	id = 71109, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -4500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71110] = {	id = 71110, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5400.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
