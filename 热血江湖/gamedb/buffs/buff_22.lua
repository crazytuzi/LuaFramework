----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[2203] = {	id = 2203, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 180000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[2204] = {	id = 2204, iconID = 335, effectID = 0, note = '暴击伤害提升', owner = 1, loopTime = 180000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1008, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[2207] = {	id = 2207, iconID = 1183, effectID = 0, note = '加快冷却', owner = 1, loopTime = 180000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 899, }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[2206] = {	id = 2206, iconID = 0, effectID = 0, note = '加快冷却', owner = 1, loopTime = 100, overlays = 1, overlayType = 2, affectType = 2, affectID = 33, valueType = 1, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[2205] = {	id = 2205, iconID = 334, effectID = 0, note = '神兵伤害提升', owner = 1, loopTime = 180000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1109, valueType = 1, affectValue = 40000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[2208] = {	id = 2208, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1118, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
