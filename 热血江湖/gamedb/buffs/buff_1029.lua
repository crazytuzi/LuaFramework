----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102901] = {	id = 102901, iconID = 0, effectID = 0, note = '攻击增加500', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1029, buffSlotLvl = 1, buffDrugIcon = 4373, specialIcon = 0},
	[102902] = {	id = 102902, iconID = 0, effectID = 0, note = '攻击增加1000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1029, buffSlotLvl = 2, buffDrugIcon = 4373, specialIcon = 0},
	[102903] = {	id = 102903, iconID = 0, effectID = 0, note = '攻击增加1500', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1029, buffSlotLvl = 3, buffDrugIcon = 4373, specialIcon = 0},
	[102904] = {	id = 102904, iconID = 0, effectID = 0, note = '攻击增加2000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1029, buffSlotLvl = 4, buffDrugIcon = 4373, specialIcon = 0},

};
function get_db_table()
	return buff;
end
