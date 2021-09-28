----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[22100] = {	id = 22100, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2384.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22101] = {	id = 22101, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2419.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22102] = {	id = 22102, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2454.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22103] = {	id = 22103, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2488.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22104] = {	id = 22104, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2524.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22105] = {	id = 22105, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2559.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22106] = {	id = 22106, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2595.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22107] = {	id = 22107, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2630.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22108] = {	id = 22108, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2666.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22109] = {	id = 22109, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2703.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22110] = {	id = 22110, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2739.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22111] = {	id = 22111, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2776.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22112] = {	id = 22112, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2813.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22113] = {	id = 22113, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2850.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22114] = {	id = 22114, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2887.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22115] = {	id = 22115, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2925.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22116] = {	id = 22116, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 2963.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22117] = {	id = 22117, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3001.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22118] = {	id = 22118, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3039.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22119] = {	id = 22119, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3078.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22120] = {	id = 22120, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3116.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22121] = {	id = 22121, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3155.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22122] = {	id = 22122, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3195.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22123] = {	id = 22123, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3234.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22124] = {	id = 22124, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3274.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22125] = {	id = 22125, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3313.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22126] = {	id = 22126, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3354.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22127] = {	id = 22127, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3394.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22128] = {	id = 22128, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3434.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22129] = {	id = 22129, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3475.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22130] = {	id = 22130, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3516.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22131] = {	id = 22131, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3557.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22132] = {	id = 22132, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3599.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22133] = {	id = 22133, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3640.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22134] = {	id = 22134, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3682.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22135] = {	id = 22135, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3724.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22136] = {	id = 22136, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3767.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22137] = {	id = 22137, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3809.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22138] = {	id = 22138, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3852.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22139] = {	id = 22139, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3895.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22140] = {	id = 22140, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3938.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22141] = {	id = 22141, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 3982.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22142] = {	id = 22142, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4026.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22143] = {	id = 22143, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4069.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22144] = {	id = 22144, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4114.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22145] = {	id = 22145, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4158.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22146] = {	id = 22146, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4203.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22147] = {	id = 22147, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4247.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22148] = {	id = 22148, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4292.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22149] = {	id = 22149, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4338.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[22150] = {	id = 22150, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 4383.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
