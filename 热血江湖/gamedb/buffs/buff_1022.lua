----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102201] = {	id = 102201, iconID = 0, effectID = 0, note = '每8秒回复2%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 200.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 1, buffDrugIcon = 4368, specialIcon = 0},
	[102202] = {	id = 102202, iconID = 0, effectID = 0, note = '每8秒回复4%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 400.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 2, buffDrugIcon = 4368, specialIcon = 0},
	[102203] = {	id = 102203, iconID = 0, effectID = 0, note = '每8秒回复6%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 600.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 3, buffDrugIcon = 4368, specialIcon = 0},
	[102204] = {	id = 102204, iconID = 0, effectID = 0, note = '每8秒回复8%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 800.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 4, buffDrugIcon = 4368, specialIcon = 0},
	[102205] = {	id = 102205, iconID = 0, effectID = 0, note = '每8秒回复20%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1200.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 4, buffDrugIcon = 4368, specialIcon = 0},
	[102206] = {	id = 102206, iconID = 0, effectID = 0, note = '每8秒回复6%气血', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = 8000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1022, buffSlotLvl = 4, buffDrugIcon = 4368, specialIcon = 0},

};
function get_db_table()
	return buff;
end
