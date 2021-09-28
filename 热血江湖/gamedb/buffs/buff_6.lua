----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[600] = {	id = 600, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2800, overlays = 1, overlayType = 1, affectType = 2, affectID = 34, valueType = 1, affectValue = 100.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[601] = {	id = 601, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 1000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 2, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[602] = {	id = 602, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 100, overlays = 1, overlayType = 1, affectType = 2, affectID = 37, valueType = 1, affectValue = -2.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[603] = {	id = 603, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 5000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[604] = {	id = 604, iconID = 0, effectID = 0, note = '致手绝命', owner = 0, loopTime = 4000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1057, valueType = 1, affectValue = 10000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[605] = {	id = 605, iconID = 346, effectID = 30217, note = '加速', owner = 1, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 2, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[606] = {	id = 606, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 1500, overlays = 1, overlayType = 1, affectType = 2, affectID = 38, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[607] = {	id = 607, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -10.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[608] = {	id = 608, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[609] = {	id = 609, iconID = 342, effectID = 30109, note = '睡眠', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 8, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4557},
	[610] = {	id = 610, iconID = 346, effectID = 30217, note = '加速', owner = 0, loopTime = 1000, overlays = 1, overlayType = 1, affectType = 1, affectID = 2, valueType = 1, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[611] = {	id = 611, iconID = 343, effectID = 30107, note = '定身', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 9, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4554},
	[612] = {	id = 612, iconID = 343, effectID = 30107, note = '定身', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 9, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4554},
	[613] = {	id = 613, iconID = 351, effectID = 0, note = '暴击降低', owner = 0, loopTime = -1, overlays = 5, overlayType = 1, affectType = 1, affectID = 1006, valueType = 2, affectValue = -2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[614] = {	id = 614, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[615] = {	id = 615, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 3, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[616] = {	id = 616, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 618, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4555},
	[617] = {	id = 617, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 8000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 619, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4555},
	[618] = {	id = 618, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 2, affectID = 25, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 620, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[619] = {	id = 619, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 2, affectID = 25, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 621, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[620] = {	id = 620, iconID = 357, effectID = 0, note = '伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = -800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 622, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[621] = {	id = 621, iconID = 357, effectID = 0, note = '伤害降低', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 623, }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[622] = {	id = 622, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[623] = {	id = 623, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = -1, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[624] = {	id = 624, iconID = 358, effectID = 0, note = '伤害增加', owner = 0, loopTime = 1200000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[625] = {	id = 625, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 1200000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[626] = {	id = 626, iconID = 357, effectID = 0, note = '伤害降低', owner = 0, loopTime = 100000, overlays = 2, overlayType = 2, affectType = 1, affectID = 1043, valueType = 1, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[627] = {	id = 627, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 100000, overlays = 2, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[628] = {	id = 628, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 2, valueType = 1, affectValue = -6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[629] = {	id = 629, iconID = 344, effectID = 30116, note = '持续回血', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 1500, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[630] = {	id = 630, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = -1, overlays = 1, overlayType = 1, affectType = 2, affectID = 25, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[632] = {	id = 632, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 100, overlays = 1, overlayType = 1, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[633] = {	id = 633, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 20000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[634] = {	id = 634, iconID = 336, effectID = 0, note = '防御提升', owner = 0, loopTime = 20000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1003, valueType = 2, affectValue = 2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[635] = {	id = 635, iconID = 0, effectID = 0, note = '反弹负面', owner = 0, loopTime = 4000, overlays = 5, overlayType = 2, affectType = 2, affectID = 27, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[636] = {	id = 636, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 15000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = 450.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[637] = {	id = 637, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 100000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[638] = {	id = 638, iconID = 351, effectID = 0, note = '外攻伤害加深', owner = 0, loopTime = -1, overlays = 5, overlayType = 1, affectType = 1, affectID = 1094, valueType = 1, affectValue = -2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[639] = {	id = 639, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 6000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[640] = {	id = 640, iconID = 0, effectID = 0, note = '怒气增加', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = 25.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[641] = {	id = 641, iconID = 0, effectID = 0, note = '怒气增加', owner = 1, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1040, valueType = 1, affectValue = 50.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[642] = {	id = 642, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 4000, overlays = 1, overlayType = 1, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[643] = {	id = 643, iconID = 357, effectID = 0, note = '伤害降低', owner = 0, loopTime = 5000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1043, valueType = 1, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[644] = {	id = 644, iconID = 362, effectID = 0, note = '神兵防御降低', owner = 0, loopTime = 5000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1016, valueType = 2, affectValue = -2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[645] = {	id = 645, iconID = 0, effectID = 30918, note = '', owner = 1, loopTime = 20000, overlays = 1, overlayType = 1, affectType = 2, affectID = 21, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[646] = {	id = 646, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 300000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 100000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[647] = {	id = 647, iconID = 363, effectID = 0, note = '免疫负面', owner = 0, loopTime = 6000, overlays = 2, overlayType = 2, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 500, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[648] = {	id = 648, iconID = 363, effectID = 0, note = '免疫负面', owner = 0, loopTime = 6000, overlays = 2, overlayType = 2, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 500, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[649] = {	id = 649, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 3, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 400, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[650] = {	id = 650, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[651] = {	id = 651, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[652] = {	id = 652, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -900.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[653] = {	id = 653, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[654] = {	id = 654, iconID = 352, effectID = 0, note = '躲闪降低', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1005, valueType = 2, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[655] = {	id = 655, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 6000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[656] = {	id = 656, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 6000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[657] = {	id = 657, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 6000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 900.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[658] = {	id = 658, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 6000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[659] = {	id = 659, iconID = 334, effectID = 0, note = '攻击提升', owner = 0, loopTime = 6000, overlays = 3, overlayType = 2, affectType = 1, affectID = 1002, valueType = 2, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[660] = {	id = 660, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 543, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[661] = {	id = 661, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1002, valueType = 1, affectValue = 0.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { 544, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[662] = {	id = 662, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 5000, overlays = 2, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[663] = {	id = 663, iconID = 340, effectID = 30112, note = '嘲讽', owner = 0, loopTime = 3000, overlays = 1, overlayType = 1, affectType = 2, affectID = 13, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1122, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4552},
	[664] = {	id = 664, iconID = 0, effectID = 30116, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[665] = {	id = 665, iconID = 0, effectID = 30116, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[666] = {	id = 666, iconID = 340, effectID = 30112, note = '嘲讽', owner = 0, loopTime = 2000, overlays = 1, overlayType = 1, affectType = 2, affectID = 13, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1122, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4552},
	[667] = {	id = 667, iconID = 333, effectID = 0, note = '命中提升', owner = 1, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 1004, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[668] = {	id = 668, iconID = 6208, effectID = 0, note = '禁止回血', owner = 0, loopTime = 10000, overlays = 1, overlayType = 2, affectType = 2, affectID = 46, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[669] = {	id = 669, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4555},
	[670] = {	id = 670, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 4558},
	[671] = {	id = 671, iconID = 340, effectID = 30112, note = '嘲讽', owner = 0, loopTime = 4000, overlays = 1, overlayType = 1, affectType = 2, affectID = 13, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 3, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1122, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4552},
	[672] = {	id = 672, iconID = 355, effectID = 30121, note = '受伤害降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[673] = {	id = 673, iconID = 0, effectID = 0, note = '反弹负面', owner = 0, loopTime = 6000, overlays = 1, overlayType = 1, affectType = 2, affectID = 27, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[674] = {	id = 674, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2500, overlays = 1, overlayType = 1, affectType = 2, affectID = 27, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[675] = {	id = 675, iconID = 0, effectID = 0, note = '', owner = 1, loopTime = 2500, overlays = 1, overlayType = 1, affectType = 1, affectID = 1044, valueType = 1, affectValue = 6000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[676] = {	id = 676, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 2500, overlays = 2, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[677] = {	id = 677, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[678] = {	id = 678, iconID = 0, effectID = 0, note = '治疗增强', owner = 1, loopTime = 6000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1045, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[679] = {	id = 679, iconID = 0, effectID = 0, note = '坚盾壁垒', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1115, valueType = 1, affectValue = 1000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffSlot = 67, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[680] = {	id = 680, iconID = 0, effectID = 0, note = '坚盾壁垒', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1115, valueType = 1, affectValue = 1500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffSlot = 67, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[681] = {	id = 681, iconID = 0, effectID = 0, note = '坚盾壁垒', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1115, valueType = 1, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffSlot = 67, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[682] = {	id = 682, iconID = 0, effectID = 0, note = '坚盾壁垒', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1115, valueType = 1, affectValue = 2500.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffSlot = 67, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[683] = {	id = 683, iconID = 0, effectID = 0, note = '坚盾壁垒', owner = 0, loopTime = 3000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1115, valueType = 1, affectValue = 3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffSlot = 67, buffSlotLvl = 1, buffDrugIcon = 0, specialIcon = 0},
	[684] = {	id = 684, iconID = 345, effectID = 30942, note = '减速', owner = 0, loopTime = 8000, overlays = 2, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { 560, }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[685] = {	id = 685, iconID = 345, effectID = 30944, note = '减速', owner = 0, loopTime = 6000, overlays = 2, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { 561, }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[686] = {	id = 686, iconID = 356, effectID = 0, note = '受伤害增加', owner = 0, loopTime = 4000, overlays = 2, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = -4000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[687] = {	id = 687, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2000, overlays = 1, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[688] = {	id = 688, iconID = 0, effectID = 0, note = '', owner = 0, loopTime = 150, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = -1000.0, realmAddon = 0.0, affectTick = 100, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 0, buffDrugIcon = 0, specialIcon = 0},
	[689] = {	id = 689, iconID = 363, effectID = 0, note = '免疫负面', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[690] = {	id = 690, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 4000, overlays = 3, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 712, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[691] = {	id = 691, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 2500, overlays = 1, overlayType = 1, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 500, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[692] = {	id = 692, iconID = 347, effectID = 30110, note = '恐惧', owner = 0, loopTime = 3500, overlays = 1, overlayType = 1, affectType = 2, affectID = 22, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 139, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 800, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4556},
	[693] = {	id = 693, iconID = 363, effectID = 30948, note = '免疫负面', owner = 0, loopTime = 6000, overlays = 1, overlayType = 2, affectType = 2, affectID = 6, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[694] = {	id = 694, iconID = 0, effectID = 0, note = '受伤害降低', owner = 0, loopTime = 6000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1044, valueType = 1, affectValue = 5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[695] = {	id = 695, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 400.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 700, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[696] = {	id = 696, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 800.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 701, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[697] = {	id = 697, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 1200.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 702, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[698] = {	id = 698, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 1600.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 703, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[699] = {	id = 699, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 5000, overlays = 1, overlayType = 2, affectType = 1, affectID = 1006, valueType = 2, affectValue = 2000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 704, }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
