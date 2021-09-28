----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[140401] = {	id = 140401, iconID = 10888, effectID = 0, note = '鞋子装备属性降低5%', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10401, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1404, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[140402] = {	id = 140402, iconID = 10888, effectID = 0, note = '鞋子装备属性降低10%', owner = 0, loopTime = 2500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10402, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1404, buffSlotLvl = 2, buffDrugIcon = 0, specialIcon = 0},
	[140403] = {	id = 140403, iconID = 10888, effectID = 0, note = '鞋子装备属性降低15%', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10403, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1404, buffSlotLvl = 3, buffDrugIcon = 0, specialIcon = 0},
	[140404] = {	id = 140404, iconID = 10888, effectID = 0, note = '鞋子装备属性降低20%', owner = 0, loopTime = 3500, overlays = 1, overlayType = 2, affectType = 4, affectID = 10404, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1404, buffSlotLvl = 4, buffDrugIcon = 0, specialIcon = 0},
	[140405] = {	id = 140405, iconID = 10888, effectID = 0, note = '鞋子装备属性降低30%', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 4, affectID = 10405, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1404, buffSlotLvl = 5, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
