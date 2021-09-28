----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[72100] = {	id = 72100, iconID = 343, effectID = 30107, note = '定身', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 9, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4554},
	[72101] = {	id = 72101, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = -500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
