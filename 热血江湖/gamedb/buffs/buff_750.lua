----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[75001] = {	id = 75001, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 3000, overlays = 5, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[75002] = {	id = 75002, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 4000, overlays = 5, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[75003] = {	id = 75003, iconID = 359, effectID = 30105, note = '眩晕', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 2, affectID = 7, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4558},
	[75004] = {	id = 75004, iconID = 348, effectID = 0, note = '流血', owner = 0, loopTime = 5200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -300.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75005] = {	id = 75005, iconID = 348, effectID = 0, note = '流血', owner = 0, loopTime = 6200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -400.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75006] = {	id = 75006, iconID = 348, effectID = 0, note = '流血', owner = 0, loopTime = 7200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75007] = {	id = 75007, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[75008] = {	id = 75008, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 6000, overlays = 5, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[75009] = {	id = 75009, iconID = 345, effectID = 30108, note = '减速', owner = 0, loopTime = 7000, overlays = 5, overlayType = 2, affectType = 1, affectID = 2, valueType = 1, affectValue = -300.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { 2, }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4555},
	[75010] = {	id = 75010, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 3000, overlays = 5, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[75011] = {	id = 75011, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 4000, overlays = 5, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[75012] = {	id = 75012, iconID = 341, effectID = 30111, note = '沉默', owner = 0, loopTime = 5000, overlays = 5, overlayType = 2, affectType = 2, affectID = 10, valueType = 1, affectValue = 1.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1032, fightspadd = 0, buffMasterID = 1077, prolongCount = 3, buffDrugIcon = 0, specialIcon = 4553},
	[75013] = {	id = 75013, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75014] = {	id = 75014, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -4000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75015] = {	id = 75015, iconID = 350, effectID = 0, note = '攻击降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1002, valueType = 2, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75016] = {	id = 75016, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = -3000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75017] = {	id = 75017, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = -4000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75018] = {	id = 75018, iconID = 362, effectID = 0, note = '防御降低', owner = 0, loopTime = 10000, overlays = 5, overlayType = 1, affectType = 1, affectID = 1003, valueType = 2, affectValue = -5000.0, realmAddon = 0.0, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75019] = {	id = 75019, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 5200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -300.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75020] = {	id = 75020, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -400.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75021] = {	id = 75021, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 7200, overlays = 5, overlayType = 2, affectType = 1, affectID = 1001, valueType = 2, affectValue = -500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75022] = {	id = 75022, iconID = 0, effectID = 30116, note = '', owner = 1, loopTime = 3200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75023] = {	id = 75023, iconID = 0, effectID = 30116, note = '', owner = 1, loopTime = 5200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[75024] = {	id = 75024, iconID = 0, effectID = 30116, note = '', owner = 1, loopTime = 7200, overlays = 1, overlayType = 1, affectType = 1, affectID = 1001, valueType = 2, affectValue = 500.0, realmAddon = 0.0, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 0, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
