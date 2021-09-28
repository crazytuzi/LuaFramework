----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[50001] = {	id = 50001, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 62.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50002] = {	id = 50002, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 115.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50003] = {	id = 50003, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 181.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50004] = {	id = 50004, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 260.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50005] = {	id = 50005, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 354.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50006] = {	id = 50006, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 464.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50007] = {	id = 50007, iconID = 344, effectID = 30116, note = '持续回血', owner = 1, loopTime = 10200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = 591.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50011] = {	id = 50011, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 34.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50012] = {	id = 50012, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 59.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50013] = {	id = 50013, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 89.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50014] = {	id = 50014, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 121.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50015] = {	id = 50015, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 158.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50016] = {	id = 50016, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 198.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50017] = {	id = 50017, iconID = 334, effectID = 0, note = '攻击提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 243.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50021] = {	id = 50021, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 11.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50022] = {	id = 50022, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 20.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50023] = {	id = 50023, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 29.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50024] = {	id = 50024, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 40.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50025] = {	id = 50025, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 52.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50026] = {	id = 50026, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 65.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50027] = {	id = 50027, iconID = 336, effectID = 0, note = '防御提升', owner = 1, loopTime = 15000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 1, affectValue = 80.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50028] = {	id = 50028, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 10000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50029] = {	id = 50029, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 10000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50030] = {	id = 50030, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 10000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50031] = {	id = 50031, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 10000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50032] = {	id = 50032, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 10000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50033] = {	id = 50033, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50034] = {	id = 50034, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50035] = {	id = 50035, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50036] = {	id = 50036, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50037] = {	id = 50037, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50038] = {	id = 50038, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50039] = {	id = 50039, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50040] = {	id = 50040, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50041] = {	id = 50041, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50042] = {	id = 50042, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50043] = {	id = 50043, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50044] = {	id = 50044, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50045] = {	id = 50045, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50046] = {	id = 50046, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50047] = {	id = 50047, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50048] = {	id = 50048, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50049] = {	id = 50049, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50050] = {	id = 50050, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50051] = {	id = 50051, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50052] = {	id = 50052, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 20000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50053] = {	id = 50053, iconID = 344, effectID = 30811, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 100.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50054] = {	id = 50054, iconID = 344, effectID = 30812, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 300.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50055] = {	id = 50055, iconID = 344, effectID = 30813, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50056] = {	id = 50056, iconID = 344, effectID = 30814, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 800.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50057] = {	id = 50057, iconID = 344, effectID = 30815, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50058] = {	id = 50058, iconID = 0, effectID = 30806, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50059] = {	id = 50059, iconID = 0, effectID = 30807, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50060] = {	id = 50060, iconID = 0, effectID = 30808, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50061] = {	id = 50061, iconID = 0, effectID = 30809, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50062] = {	id = 50062, iconID = 0, effectID = 30810, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50063] = {	id = 50063, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50064] = {	id = 50064, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50065] = {	id = 50065, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50066] = {	id = 50066, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50067] = {	id = 50067, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50068] = {	id = 50068, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50069] = {	id = 50069, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50070] = {	id = 50070, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50071] = {	id = 50071, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50072] = {	id = 50072, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50073] = {	id = 50073, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50074] = {	id = 50074, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50075] = {	id = 50075, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50076] = {	id = 50076, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50077] = {	id = 50077, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50078] = {	id = 50078, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50079] = {	id = 50079, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50080] = {	id = 50080, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50081] = {	id = 50081, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50082] = {	id = 50082, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50083] = {	id = 50083, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50084] = {	id = 50084, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50085] = {	id = 50085, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50086] = {	id = 50086, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[50087] = {	id = 50087, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 180000, overlays = 10, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
