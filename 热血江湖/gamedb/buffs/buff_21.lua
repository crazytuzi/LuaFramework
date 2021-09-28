----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local buff = 
{
	[2100] = {	id = 2100, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -398.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2101] = {	id = 2101, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -400.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2102] = {	id = 2102, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -402.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2103] = {	id = 2103, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -404.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2104] = {	id = 2104, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -406.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2105] = {	id = 2105, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -408.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2106] = {	id = 2106, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -410.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2107] = {	id = 2107, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -412.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2108] = {	id = 2108, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -414.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2109] = {	id = 2109, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -416.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2110] = {	id = 2110, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -418.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2111] = {	id = 2111, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -420.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2112] = {	id = 2112, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -422.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2113] = {	id = 2113, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -424.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2114] = {	id = 2114, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -426.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2115] = {	id = 2115, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -428.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2116] = {	id = 2116, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -430.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2117] = {	id = 2117, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -432.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2118] = {	id = 2118, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -434.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2119] = {	id = 2119, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -436.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2120] = {	id = 2120, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -438.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2121] = {	id = 2121, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -440.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2122] = {	id = 2122, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -442.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2123] = {	id = 2123, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -444.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2124] = {	id = 2124, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -446.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2125] = {	id = 2125, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -448.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2126] = {	id = 2126, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -450.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2127] = {	id = 2127, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -452.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2128] = {	id = 2128, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -454.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2129] = {	id = 2129, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -456.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2130] = {	id = 2130, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -458.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2131] = {	id = 2131, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -460.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2132] = {	id = 2132, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -462.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2133] = {	id = 2133, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -464.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2134] = {	id = 2134, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -466.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2135] = {	id = 2135, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -468.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2136] = {	id = 2136, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -470.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2137] = {	id = 2137, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -472.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2138] = {	id = 2138, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -474.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2139] = {	id = 2139, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -476.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2140] = {	id = 2140, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -478.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2141] = {	id = 2141, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -480.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2142] = {	id = 2142, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -482.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2143] = {	id = 2143, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -484.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2144] = {	id = 2144, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -486.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2145] = {	id = 2145, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -488.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2146] = {	id = 2146, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -490.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2147] = {	id = 2147, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -492.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2148] = {	id = 2148, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -494.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2149] = {	id = 2149, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -496.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},
	[2150] = {	id = 2150, iconID = 349, effectID = 0, note = '命中降低', owner = 0, loopTime = 7000, overlays = 3, overlayType = 1, affectType = 1, affectID = 1004, valueType = 1, affectValue = -498.0, realmAddon = 0.05, affectTick = -1, vfxIds = { }, childs = { }, removeOnZero = 0, trigger = { }, type = 2, resID = 1033, fightspadd = 0, buffMasterID = 1078, prolongCount = 3, buffDrugIcon = 0, specialIcon = 0},

};
function get_db_table()
	return buff;
end
