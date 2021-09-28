----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[120501] = {	id = 120501, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 1, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[120502] = {	id = 120502, iconID = 347, effectID = 30110, note = '恐惧', owner = 0, loopTime = 2000, overlays = 1, overlayType = 1, affectType = 2, affectID = 22, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4556},

};
function get_db_table()
	return buff;
end
