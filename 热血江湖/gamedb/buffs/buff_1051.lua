----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[105100] = {	id = 105100, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3700.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105101] = {	id = 105101, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3734.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105102] = {	id = 105102, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3769.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105103] = {	id = 105103, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3803.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105104] = {	id = 105104, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3837.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105105] = {	id = 105105, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3872.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105106] = {	id = 105106, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3906.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105107] = {	id = 105107, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3940.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105108] = {	id = 105108, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -3975.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105109] = {	id = 105109, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4009.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105110] = {	id = 105110, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4043.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105111] = {	id = 105111, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4078.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105112] = {	id = 105112, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4112.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105113] = {	id = 105113, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4146.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105114] = {	id = 105114, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4181.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105115] = {	id = 105115, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4215.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105116] = {	id = 105116, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4249.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105117] = {	id = 105117, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4284.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105118] = {	id = 105118, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4318.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105119] = {	id = 105119, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4353.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105120] = {	id = 105120, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4387.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105121] = {	id = 105121, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4421.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105122] = {	id = 105122, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4456.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105123] = {	id = 105123, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4490.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105124] = {	id = 105124, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4524.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105125] = {	id = 105125, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4559.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105126] = {	id = 105126, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4593.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105127] = {	id = 105127, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4627.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105128] = {	id = 105128, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4662.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105129] = {	id = 105129, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4696.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105130] = {	id = 105130, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4730.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105131] = {	id = 105131, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4765.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105132] = {	id = 105132, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4799.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105133] = {	id = 105133, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4833.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105134] = {	id = 105134, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4868.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105135] = {	id = 105135, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4902.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105136] = {	id = 105136, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4936.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105137] = {	id = 105137, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -4971.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105138] = {	id = 105138, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5005.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105139] = {	id = 105139, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5039.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105140] = {	id = 105140, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5074.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105141] = {	id = 105141, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5108.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105142] = {	id = 105142, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5142.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105143] = {	id = 105143, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5177.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105144] = {	id = 105144, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5211.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105145] = {	id = 105145, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5245.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105146] = {	id = 105146, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5280.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105147] = {	id = 105147, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5314.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105148] = {	id = 105148, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5348.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105149] = {	id = 105149, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5383.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},
	[105150] = {	id = 105150, iconID = 356, effectID = 0, note = '受内攻加深', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1095, valueType = 1, affectValue = -5417.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffSlot = 1050, buffSlotLvl = 100, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
