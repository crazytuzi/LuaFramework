----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[26100] = {	id = 26100, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 199.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26101] = {	id = 26101, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 200.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26102] = {	id = 26102, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 201.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26103] = {	id = 26103, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 202.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26104] = {	id = 26104, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 203.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26105] = {	id = 26105, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 204.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26106] = {	id = 26106, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 205.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26107] = {	id = 26107, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 206.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26108] = {	id = 26108, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 207.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26109] = {	id = 26109, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 208.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26110] = {	id = 26110, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 209.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26111] = {	id = 26111, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 210.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26112] = {	id = 26112, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 211.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26113] = {	id = 26113, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 212.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26114] = {	id = 26114, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 213.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26115] = {	id = 26115, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 214.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26116] = {	id = 26116, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 215.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26117] = {	id = 26117, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 216.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26118] = {	id = 26118, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 217.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26119] = {	id = 26119, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 218.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26120] = {	id = 26120, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 219.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26121] = {	id = 26121, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 220.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26122] = {	id = 26122, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 221.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26123] = {	id = 26123, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 222.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26124] = {	id = 26124, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 223.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26125] = {	id = 26125, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 224.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26126] = {	id = 26126, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 225.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26127] = {	id = 26127, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 226.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26128] = {	id = 26128, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 227.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26129] = {	id = 26129, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 228.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26130] = {	id = 26130, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 229.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26131] = {	id = 26131, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 230.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26132] = {	id = 26132, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 231.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26133] = {	id = 26133, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 232.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26134] = {	id = 26134, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 233.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26135] = {	id = 26135, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 234.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26136] = {	id = 26136, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 235.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26137] = {	id = 26137, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 236.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26138] = {	id = 26138, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 237.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26139] = {	id = 26139, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 238.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26140] = {	id = 26140, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 239.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26141] = {	id = 26141, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 240.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26142] = {	id = 26142, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 241.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26143] = {	id = 26143, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 242.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26144] = {	id = 26144, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 243.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26145] = {	id = 26145, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 244.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26146] = {	id = 26146, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 245.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26147] = {	id = 26147, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 246.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26148] = {	id = 26148, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 247.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26149] = {	id = 26149, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 248.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[26150] = {	id = 26150, iconID = 335, effectID = 0, note = '暴击提升', owner = 1, loopTime = 10000, overlays = 1, overlayType = 1, affectType = 1, affectID = 1006, valueType = 1, affectValue = 249.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 1, resID = 0, fightspadd = 0, buffMasterID = 0, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
