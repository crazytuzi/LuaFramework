----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[74001] = {	id = 74001, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1500, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4558},
	[74002] = {	id = 74002, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 2, affectValue = -5000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[74003] = {	id = 74003, iconID = 355, effectID = 0, note = '无敌', owner = 0, loopTime = 30000, overlays = 1, overlayType = 1, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[74004] = {	id = 74004, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 7500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[74005] = {	id = 74005, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 74006, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[74006] = {	id = 74006, iconID = 344, effectID = 30116, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 300.0, realmAddon = 0.0, affectTick = 1200, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
