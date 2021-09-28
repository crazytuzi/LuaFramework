----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102301] = {	id = 102301, iconID = 0, effectID = 0, note = '受伤害降低3%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 1, buffDrugIcon = 4369, specialIcon = 0},
	[102302] = {	id = 102302, iconID = 0, effectID = 0, note = '受伤害降低5%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 2, buffDrugIcon = 4369, specialIcon = 0},
	[102303] = {	id = 102303, iconID = 0, effectID = 0, note = '受伤害降低8%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 3, buffDrugIcon = 4369, specialIcon = 0},
	[102304] = {	id = 102304, iconID = 0, effectID = 0, note = '受伤害降低6%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 4, buffDrugIcon = 4369, specialIcon = 0},
	[102305] = {	id = 102305, iconID = 0, effectID = 0, note = '受伤害降低20%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 4, buffDrugIcon = 4369, specialIcon = 0},
	[102306] = {	id = 102306, iconID = 0, effectID = 0, note = '受伤害降低8%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1023, buffSlotLvl = 4, buffDrugIcon = 4369, specialIcon = 0},

};
function get_db_table()
	return buff;
end
