----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102701] = {	id = 102701, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102801, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[102702] = {	id = 102702, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102802, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[102703] = {	id = 102703, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102803, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[102704] = {	id = 102704, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102804, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[102705] = {	id = 102705, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102805, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[102706] = {	id = 102706, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1033, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102806, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1027, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
