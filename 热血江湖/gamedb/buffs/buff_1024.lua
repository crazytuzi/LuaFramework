----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102401] = {	id = 102401, iconID = 0, effectID = 0, note = '气血上限提升5%+50000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102501, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1024, buffSlotLvl = 1, buffDrugIcon = 4367, specialIcon = 0},
	[102402] = {	id = 102402, iconID = 0, effectID = 0, note = '气血上限提升6%+80000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102502, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1024, buffSlotLvl = 2, buffDrugIcon = 4367, specialIcon = 0},
	[102403] = {	id = 102403, iconID = 0, effectID = 0, note = '气血上限提升7%+100000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 700.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102503, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1024, buffSlotLvl = 3, buffDrugIcon = 4367, specialIcon = 0},
	[102404] = {	id = 102404, iconID = 0, effectID = 0, note = '气血上限提升8%+80000', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102504, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1024, buffSlotLvl = 4, buffDrugIcon = 4367, specialIcon = 0},

};
function get_db_table()
	return buff;
end
