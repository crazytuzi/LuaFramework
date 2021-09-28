----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[60001] = {	id = 60001, iconID = 355, effectID = 30120, note = '受伤害降低', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[60002] = {	id = 60002, iconID = 0, effectID = 30094, note = '', owner = 1, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[60003] = {	id = 60003, iconID = 345, effectID = 30412, note = '无敌', owner = 1, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
