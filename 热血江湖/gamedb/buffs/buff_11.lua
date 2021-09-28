----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[1100] = {	id = 1100, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5338.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1101] = {	id = 1101, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5475.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1102] = {	id = 1102, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5612.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1103] = {	id = 1103, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5749.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1104] = {	id = 1104, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -5886.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1105] = {	id = 1105, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6023.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1106] = {	id = 1106, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6160.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1107] = {	id = 1107, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6297.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1108] = {	id = 1108, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6434.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1109] = {	id = 1109, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6571.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1110] = {	id = 1110, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6708.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1111] = {	id = 1111, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6845.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1112] = {	id = 1112, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -6982.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1113] = {	id = 1113, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7119.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1114] = {	id = 1114, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7256.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1115] = {	id = 1115, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7393.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1116] = {	id = 1116, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7530.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1117] = {	id = 1117, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7667.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1118] = {	id = 1118, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7804.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1119] = {	id = 1119, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -7941.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1120] = {	id = 1120, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8078.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1121] = {	id = 1121, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8215.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1122] = {	id = 1122, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8352.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1123] = {	id = 1123, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8489.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1124] = {	id = 1124, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8626.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1125] = {	id = 1125, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8763.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1126] = {	id = 1126, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -8900.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1127] = {	id = 1127, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9037.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1128] = {	id = 1128, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9174.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1129] = {	id = 1129, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9311.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1130] = {	id = 1130, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9448.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1131] = {	id = 1131, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9585.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1132] = {	id = 1132, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9722.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1133] = {	id = 1133, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9859.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1134] = {	id = 1134, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -9996.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1135] = {	id = 1135, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10133.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1136] = {	id = 1136, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10270.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1137] = {	id = 1137, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10407.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1138] = {	id = 1138, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10544.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1139] = {	id = 1139, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10681.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1140] = {	id = 1140, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10818.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1141] = {	id = 1141, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -10955.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1142] = {	id = 1142, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11092.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1143] = {	id = 1143, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11229.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1144] = {	id = 1144, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11366.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1145] = {	id = 1145, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11503.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1146] = {	id = 1146, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11640.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1147] = {	id = 1147, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11777.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1148] = {	id = 1148, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -11914.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1149] = {	id = 1149, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -12051.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[1150] = {	id = 1150, iconID = 360, effectID = 30113, note = '中毒', owner = 0, loopTime = 6200, overlays = 3, overlayType = 1, affectType = 1, affectID = 1037, valueType = 1, affectValue = -12188.0, realmAddon = 0.05, affectTick = 1000, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1034, fightspadd = 0, buffMasterID = 1079, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
