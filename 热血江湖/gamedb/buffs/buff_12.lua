----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[1201] = {	id = 1201, iconID = 344, effectID = 30116, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1202] = {	id = 1202, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1203] = {	id = 1203, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1204] = {	id = 1204, iconID = 333, effectID = 0, note = '命中提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1004, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1205] = {	id = 1205, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1206] = {	id = 1206, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1207] = {	id = 1207, iconID = 339, effectID = 0, note = '韧性提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1208] = {	id = 1208, iconID = 6258, effectID = 0, note = '伤害增加', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1209] = {	id = 1209, iconID = 6256, effectID = 0, note = '受伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1210] = {	id = 1210, iconID = 5559, effectID = 0, note = '全属性降低50%', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1105, valueType = 1, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1211] = {	id = 1211, iconID = 6208, effectID = 0, note = '禁止回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 2, affectID = 46, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1212] = {	id = 1212, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1213] = {	id = 1213, iconID = 344, effectID = 30116, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1500.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1214] = {	id = 1214, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1215] = {	id = 1215, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1216] = {	id = 1216, iconID = 333, effectID = 0, note = '命中提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1004, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1217] = {	id = 1217, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1218] = {	id = 1218, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1219] = {	id = 1219, iconID = 339, effectID = 0, note = '韧性提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1220] = {	id = 1220, iconID = 6258, effectID = 0, note = '伤害增加', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1221] = {	id = 1221, iconID = 6256, effectID = 0, note = '受伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1222] = {	id = 1222, iconID = 344, effectID = 30116, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = 5000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1223] = {	id = 1223, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1224] = {	id = 1224, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1225] = {	id = 1225, iconID = 333, effectID = 0, note = '命中提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1004, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1226] = {	id = 1226, iconID = 337, effectID = 0, note = '躲闪提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1227] = {	id = 1227, iconID = 335, effectID = 0, note = '暴击提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1228] = {	id = 1228, iconID = 339, effectID = 0, note = '韧性提升', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1229] = {	id = 1229, iconID = 6258, effectID = 0, note = '伤害增加', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1230] = {	id = 1230, iconID = 6256, effectID = 0, note = '受伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1231] = {	id = 1231, iconID = 348, effectID = 0, note = '流血', owner = 0, loopTime = 5200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -150.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1232] = {	id = 1232, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 4000, overlays = 10, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1233] = {	id = 1233, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 4000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1234] = {	id = 1234, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 8000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1235] = {	id = 1235, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1236] = {	id = 1236, iconID = 355, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1237] = {	id = 1237, iconID = 340, effectID = 30112, note = '嘲讽', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 13, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1122, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4552},
	[1238] = {	id = 1238, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[1239] = {	id = 1239, iconID = 343, effectID = 30107, note = '定身', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 9, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4554},
	[1240] = {	id = 1240, iconID = 353, effectID = 0, note = '先灵之殇', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1045, valueType = 1, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 4010, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1241] = {	id = 1241, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 3000, overlays = 4, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[1242] = {	id = 1242, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1243] = {	id = 1243, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 140.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1244] = {	id = 1244, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 180.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1245] = {	id = 1245, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 220.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1246] = {	id = 1246, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 260.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1247] = {	id = 1247, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1248] = {	id = 1248, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 340.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1249] = {	id = 1249, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 380.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1250] = {	id = 1250, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 420.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1251] = {	id = 1251, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1252] = {	id = 1252, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[1253] = {	id = 1253, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[1254] = {	id = 1254, iconID = 361, effectID = 30115, note = '灼烧', owner = 0, loopTime = 5200, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -200.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1255] = {	id = 1255, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[1256] = {	id = 1256, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1257] = {	id = 1257, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 550.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1258] = {	id = 1258, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 600.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1259] = {	id = 1259, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 650.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1260] = {	id = 1260, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 700.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1261] = {	id = 1261, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 750.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1262] = {	id = 1262, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 800.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1263] = {	id = 1263, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 850.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1264] = {	id = 1264, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 900.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1265] = {	id = 1265, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1266] = {	id = 1266, iconID = 0, effectID = 0, note = '无敌', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1267] = {	id = 1267, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1268] = {	id = 1268, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1269] = {	id = 1269, iconID = 354, effectID = 0, note = '韧性降低', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1007, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1270] = {	id = 1270, iconID = 350, effectID = 0, note = '内力降低', owner = 0, loopTime = 2000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1046, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1271] = {	id = 1271, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[1272] = {	id = 1272, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[1273] = {	id = 1273, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1274] = {	id = 1274, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = -500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1275] = {	id = 1275, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[1276] = {	id = 1276, iconID = 355, effectID = 0, note = '忽视伤害', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 2, affectID = 50, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1277] = {	id = 1277, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1278] = {	id = 1278, iconID = 348, effectID = 0, note = '流血', owner = 0, loopTime = 5200, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -200.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1279] = {	id = 1279, iconID = 10434, effectID = 31002, note = '护盾', owner = 0, loopTime = 8000, overlays = 1, overlayType = 2, affectType = 2, affectID = 28, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1280] = {	id = 1280, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1281] = {	id = 1281, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 150, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1282] = {	id = 1282, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[1283] = {	id = 1283, iconID = 343, effectID = 30107, note = '定身', owner = 0, loopTime = 4000, overlays = 1, overlayType = 2, affectType = 2, affectID = 9, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4554},
	[1284] = {	id = 1284, iconID = 0, effectID = 0, note = '加快冷却', owner = 0, loopTime = 1000, overlays = 1, overlayType = 1, affectType = 2, affectID = 33, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1285] = {	id = 1285, iconID = 360, effectID = 0, note = '苗毒', owner = 0, loopTime = 10500, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -100.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { 1289, }, removeOnZero = 0, trigger = { 902, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1286] = {	id = 1286, iconID = 0, effectID = 0, note = '巫月', owner = 0, loopTime = 5500, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 903, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1287] = {	id = 1287, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 10000, overlays = 1, overlayType = 2, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1288] = {	id = 1288, iconID = 360, effectID = 0, note = '苗毒', owner = 0, loopTime = 10500, overlays = 1, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -100.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1289] = {	id = 1289, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 10500, overlays = 1, overlayType = 2, affectType = 1, affectID = 1157, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1290] = {	id = 1290, iconID = 358, effectID = 0, note = '造成伤害提升200%', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1043, valueType = 1, affectValue = 20000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1896, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1291] = {	id = 1291, iconID = 358, effectID = 0, note = '造成伤害提升400%', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1043, valueType = 1, affectValue = 40000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1897, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1292] = {	id = 1292, iconID = 358, effectID = 0, note = '造成伤害提升300%', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1043, valueType = 1, affectValue = 30000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1898, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1293] = {	id = 1293, iconID = 3312, effectID = 0, note = '武运千秋', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1899, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1294] = {	id = 1294, iconID = 3312, effectID = 0, note = '武运千秋', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1005, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1899, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[1295] = {	id = 1295, iconID = 3312, effectID = 0, note = '武运千秋', owner = 1, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, isShowAbove = 1, buffDescID = 1899, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
