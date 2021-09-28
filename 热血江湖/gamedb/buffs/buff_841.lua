----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[84100] = {	id = 84100, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 15124.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84101] = {	id = 84101, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 15732.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84102] = {	id = 84102, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 16204.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84103] = {	id = 84103, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 16552.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84104] = {	id = 84104, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 17300.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84105] = {	id = 84105, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 17696.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84106] = {	id = 84106, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 18016.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84107] = {	id = 84107, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 18736.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84108] = {	id = 84108, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 19184.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84109] = {	id = 84109, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 19588.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84110] = {	id = 84110, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 20412.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84111] = {	id = 84111, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 20804.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84112] = {	id = 84112, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 21224.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84113] = {	id = 84113, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 22120.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84114] = {	id = 84114, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 22500.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84115] = {	id = 84115, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 22944.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84116] = {	id = 84116, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 23924.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84117] = {	id = 84117, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 24364.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84118] = {	id = 84118, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 25072.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84119] = {	id = 84119, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 25572.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84120] = {	id = 84120, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 26068.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84121] = {	id = 84121, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 26504.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84122] = {	id = 84122, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 26944.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84123] = {	id = 84123, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 27432.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84124] = {	id = 84124, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 27888.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84125] = {	id = 84125, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 28348.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84126] = {	id = 84126, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 28820.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84127] = {	id = 84127, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 29296.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84128] = {	id = 84128, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 29780.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84129] = {	id = 84129, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 30408.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84130] = {	id = 84130, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 30908.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84131] = {	id = 84131, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 31412.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84132] = {	id = 84132, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 31924.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84133] = {	id = 84133, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 32444.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84134] = {	id = 84134, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 32972.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84135] = {	id = 84135, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 33552.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84136] = {	id = 84136, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 34096.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84137] = {	id = 84137, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 34648.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84138] = {	id = 84138, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 35208.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84139] = {	id = 84139, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 35772.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84140] = {	id = 84140, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 36344.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84141] = {	id = 84141, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 36972.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84142] = {	id = 84142, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 37564.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84143] = {	id = 84143, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 38160.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84144] = {	id = 84144, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 38764.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84145] = {	id = 84145, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 39380.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84146] = {	id = 84146, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 40000.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84147] = {	id = 84147, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 40680.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84148] = {	id = 84148, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 41316.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84149] = {	id = 84149, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 41964.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[84150] = {	id = 84150, iconID = 344, effectID = 0, note = '治疗增强', owner = 1, loopTime = 8000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1041, valueType = 1, affectValue = 42624.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
