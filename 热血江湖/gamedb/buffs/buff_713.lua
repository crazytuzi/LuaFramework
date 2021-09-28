----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[71301] = {	id = 71301, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 180000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16001, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71302] = {	id = 71302, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 180000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 8500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16002, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71303] = {	id = 71303, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 180000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16003, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71304] = {	id = 71304, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 180000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16004, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71305] = {	id = 71305, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 120000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16005, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71306] = {	id = 71306, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 120000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16006, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71307] = {	id = 71307, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 120000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -15000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16007, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71308] = {	id = 71308, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 120000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -20000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71311] = {	id = 71311, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16011, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71312] = {	id = 71312, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 8500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16012, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71313] = {	id = 71313, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16013, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71314] = {	id = 71314, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 7500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16014, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71315] = {	id = 71315, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16015, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71316] = {	id = 71316, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 6500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16016, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71317] = {	id = 71317, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 5500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16017, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71318] = {	id = 71318, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 4500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16018, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71319] = {	id = 71319, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 3500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16019, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71320] = {	id = 71320, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16020, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71321] = {	id = 71321, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16021, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71322] = {	id = 71322, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16022, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71323] = {	id = 71323, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -3500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16023, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71324] = {	id = 71324, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -5500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16024, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71325] = {	id = 71325, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -7500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16025, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71326] = {	id = 71326, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -9500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16026, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71327] = {	id = 71327, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -11500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16027, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71328] = {	id = 71328, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -13500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16028, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71329] = {	id = 71329, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 60000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -15500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { 16029, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71330] = {	id = 71330, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 600000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -17500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 6, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71331] = {	id = 71331, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 120000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71332] = {	id = 71332, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 30000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71333] = {	id = 71333, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 30000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[71334] = {	id = 71334, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 8000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 9000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 16101, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[71335] = {	id = 71335, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 8000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 16102, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[71336] = {	id = 71336, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 8000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
