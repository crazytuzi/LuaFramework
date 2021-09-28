----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[17100] = {	id = 17100, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1008, valueType = 1, affectValue = -31608.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
