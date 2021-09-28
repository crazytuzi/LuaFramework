----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[102601] = {	id = 102601, iconID = 0, effectID = 0, note = '全抗性提升5%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102701, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 1, buffDrugIcon = 4370, specialIcon = 0},
	[102602] = {	id = 102602, iconID = 0, effectID = 0, note = '全抗性提升8%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102702, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 2, buffDrugIcon = 4370, specialIcon = 0},
	[102603] = {	id = 102603, iconID = 0, effectID = 0, note = '全抗性提升10%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102703, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 3, buffDrugIcon = 4370, specialIcon = 0},
	[102604] = {	id = 102604, iconID = 0, effectID = 0, note = '全抗性提升8%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102704, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 4, buffDrugIcon = 4370, specialIcon = 0},
	[102605] = {	id = 102605, iconID = 0, effectID = 0, note = '全抗性提升20%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102705, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 3, buffDrugIcon = 4370, specialIcon = 0},
	[102606] = {	id = 102606, iconID = 0, effectID = 0, note = '全抗性提升10%', owner = 1, loopTime = 3600000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1032, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 102706, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1026, buffSlotLvl = 3, buffDrugIcon = 4370, specialIcon = 0},

};
function get_db_table()
	return buff;
end
