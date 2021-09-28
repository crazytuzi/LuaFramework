----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[15100] = {	id = 15100, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 398.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15101] = {	id = 15101, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 400.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15102] = {	id = 15102, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 402.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15103] = {	id = 15103, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 404.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15104] = {	id = 15104, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 406.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15105] = {	id = 15105, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 408.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15106] = {	id = 15106, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 410.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15107] = {	id = 15107, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 412.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15108] = {	id = 15108, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 414.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15109] = {	id = 15109, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 416.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15110] = {	id = 15110, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 418.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15111] = {	id = 15111, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 420.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15112] = {	id = 15112, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 422.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15113] = {	id = 15113, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 424.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15114] = {	id = 15114, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 426.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15115] = {	id = 15115, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 428.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15116] = {	id = 15116, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 430.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15117] = {	id = 15117, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 432.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15118] = {	id = 15118, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 434.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15119] = {	id = 15119, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 436.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15120] = {	id = 15120, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 438.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15121] = {	id = 15121, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 440.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15122] = {	id = 15122, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 442.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15123] = {	id = 15123, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 444.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15124] = {	id = 15124, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 446.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15125] = {	id = 15125, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 448.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15126] = {	id = 15126, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 450.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15127] = {	id = 15127, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 452.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15128] = {	id = 15128, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 454.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15129] = {	id = 15129, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 456.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15130] = {	id = 15130, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 458.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15131] = {	id = 15131, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 460.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15132] = {	id = 15132, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 462.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15133] = {	id = 15133, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 464.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15134] = {	id = 15134, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 466.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15135] = {	id = 15135, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 468.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15136] = {	id = 15136, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 470.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15137] = {	id = 15137, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 472.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15138] = {	id = 15138, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 474.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15139] = {	id = 15139, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 476.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15140] = {	id = 15140, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 478.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15141] = {	id = 15141, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 480.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15142] = {	id = 15142, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 482.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15143] = {	id = 15143, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 484.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15144] = {	id = 15144, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 486.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15145] = {	id = 15145, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 488.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15146] = {	id = 15146, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 490.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15147] = {	id = 15147, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 492.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15148] = {	id = 15148, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 494.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15149] = {	id = 15149, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 496.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[15150] = {	id = 15150, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 498.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
