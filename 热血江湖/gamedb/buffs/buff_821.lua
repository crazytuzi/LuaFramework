----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[82100] = {	id = 82100, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[82101] = {	id = 82101, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 101, buffDrugIcon = 0, specialIcon = 0},
	[82102] = {	id = 82102, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 102, buffDrugIcon = 0, specialIcon = 0},
	[82103] = {	id = 82103, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 103, buffDrugIcon = 0, specialIcon = 0},
	[82104] = {	id = 82104, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 104, buffDrugIcon = 0, specialIcon = 0},
	[82105] = {	id = 82105, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 105, buffDrugIcon = 0, specialIcon = 0},
	[82106] = {	id = 82106, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 106, buffDrugIcon = 0, specialIcon = 0},
	[82107] = {	id = 82107, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 107, buffDrugIcon = 0, specialIcon = 0},
	[82108] = {	id = 82108, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 108, buffDrugIcon = 0, specialIcon = 0},
	[82109] = {	id = 82109, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 109, buffDrugIcon = 0, specialIcon = 0},
	[82110] = {	id = 82110, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82111] = {	id = 82111, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82112] = {	id = 82112, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82113] = {	id = 82113, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82114] = {	id = 82114, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82115] = {	id = 82115, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82116] = {	id = 82116, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82117] = {	id = 82117, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82118] = {	id = 82118, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82119] = {	id = 82119, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82120] = {	id = 82120, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82121] = {	id = 82121, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82122] = {	id = 82122, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82123] = {	id = 82123, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82124] = {	id = 82124, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82125] = {	id = 82125, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82126] = {	id = 82126, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82127] = {	id = 82127, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82128] = {	id = 82128, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82129] = {	id = 82129, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82130] = {	id = 82130, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82131] = {	id = 82131, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82132] = {	id = 82132, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82133] = {	id = 82133, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82134] = {	id = 82134, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82135] = {	id = 82135, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82136] = {	id = 82136, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82137] = {	id = 82137, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82138] = {	id = 82138, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82139] = {	id = 82139, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82140] = {	id = 82140, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82141] = {	id = 82141, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82142] = {	id = 82142, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82143] = {	id = 82143, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82144] = {	id = 82144, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82145] = {	id = 82145, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82146] = {	id = 82146, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82147] = {	id = 82147, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82148] = {	id = 82148, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82149] = {	id = 82149, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},
	[82150] = {	id = 82150, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1077, valueType = 1, affectValue = 1300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 82, buffSlotLvl = 110, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
