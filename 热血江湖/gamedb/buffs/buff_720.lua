----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[72068] = {	id = 72068, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 5500, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[72069] = {	id = 72069, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 6000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[72070] = {	id = 72070, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 7000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[72093] = {	id = 72093, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72094] = {	id = 72094, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72095] = {	id = 72095, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72096] = {	id = 72096, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 9000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72097] = {	id = 72097, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72000] = {	id = 72000, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -1800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72001] = {	id = 72001, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72002] = {	id = 72002, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -2200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72003] = {	id = 72003, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -2400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72004] = {	id = 72004, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -2600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72071] = {	id = 72071, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -2800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72072] = {	id = 72072, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72073] = {	id = 72073, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -3200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72074] = {	id = 72074, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -3400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72075] = {	id = 72075, iconID = 0, effectID = 0, note = '治疗衰减', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = -3600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72005] = {	id = 72005, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 900.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72006] = {	id = 72006, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72007] = {	id = 72007, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72008] = {	id = 72008, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72009] = {	id = 72009, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72076] = {	id = 72076, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72077] = {	id = 72077, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72078] = {	id = 72078, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72079] = {	id = 72079, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1700.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72080] = {	id = 72080, iconID = 0, effectID = 0, note = '治疗增强', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 1800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72010] = {	id = 72010, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -110.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72011] = {	id = 72011, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -120.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72012] = {	id = 72012, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -130.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72013] = {	id = 72013, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -140.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72014] = {	id = 72014, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -150.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72081] = {	id = 72081, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -160.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72082] = {	id = 72082, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -170.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[72015] = {	id = 72015, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72016] = {	id = 72016, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 5500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72017] = {	id = 72017, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72018] = {	id = 72018, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 6500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72019] = {	id = 72019, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72083] = {	id = 72083, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72084] = {	id = 72084, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72085] = {	id = 72085, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72086] = {	id = 72086, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 7800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72087] = {	id = 72087, iconID = 337, effectID = 0, note = '躲闪提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72020] = {	id = 72020, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72021] = {	id = 72021, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 5500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72022] = {	id = 72022, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72023] = {	id = 72023, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 6500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72024] = {	id = 72024, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72088] = {	id = 72088, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 7200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72089] = {	id = 72089, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 7400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72090] = {	id = 72090, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 7600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72091] = {	id = 72091, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 7800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72092] = {	id = 72092, iconID = 339, effectID = 0, note = '韧性提升', owner = 1, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72025] = {	id = 72025, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 300, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72026] = {	id = 72026, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 400, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72027] = {	id = 72027, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 500, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72028] = {	id = 72028, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 600, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72029] = {	id = 72029, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 700, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72030] = {	id = 72030, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 800, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72031] = {	id = 72031, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 900, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72032] = {	id = 72032, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1000, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72033] = {	id = 72033, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1100, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72034] = {	id = 72034, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1200, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72058] = {	id = 72058, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1400, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72059] = {	id = 72059, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1600, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72060] = {	id = 72060, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 1800, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72061] = {	id = 72061, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72062] = {	id = 72062, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2200, overlays = 2, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[72035] = {	id = 72035, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72036] = {	id = 72036, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72037] = {	id = 72037, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72038] = {	id = 72038, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72039] = {	id = 72039, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -3500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72040] = {	id = 72040, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -4000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72041] = {	id = 72041, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -4500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72042] = {	id = 72042, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72043] = {	id = 72043, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -5500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72044] = {	id = 72044, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72063] = {	id = 72063, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -6250.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72064] = {	id = 72064, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -6500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72065] = {	id = 72065, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -6750.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72066] = {	id = 72066, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -7000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72067] = {	id = 72067, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = -7250.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72045] = {	id = 72045, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72046] = {	id = 72046, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72047] = {	id = 72047, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72048] = {	id = 72048, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72049] = {	id = 72049, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72050] = {	id = 72050, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72051] = {	id = 72051, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 3500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72052] = {	id = 72052, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 4000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72053] = {	id = 72053, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 4500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72054] = {	id = 72054, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[72056] = {	id = 72056, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 7000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[72057] = {	id = 72057, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},

};
function get_db_table()
	return buff;
end
