----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[100001] = {	id = 100001, iconID = 10424, effectID = 0, note = '震腑', owner = 0, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 2, affectID = 45, valueType = 1, affectValue = 50.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
