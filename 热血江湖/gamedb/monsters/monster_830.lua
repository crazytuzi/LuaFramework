----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[83010] = {id = 83010, name = '野蛮山贼', icon = 2159, iconID = 1, modelID = 345, skinID = -1, boss = 0, level = 30, hpOrg = 56528.0, atkNOrg = 803.0, defNOrg = 534.0, atrOrg = 361.0, ctrOrg = 239.0, acrNOrg = 249.0, touOrg = 23.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 28.0, attacks = { 1001291, 1001292 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83011] = {id = 83011, name = '西域番僧', icon = 2168, iconID = 1, modelID = 413, skinID = -1, boss = 0, level = 31, hpOrg = 60052.0, atkNOrg = 851.0, defNOrg = 560.0, atrOrg = 372.0, ctrOrg = 249.0, acrNOrg = 256.0, touOrg = 27.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 28.0, attacks = { 1001231, 1001232 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83012] = {id = 83012, name = '巨熊', icon = 2184, iconID = 1, modelID = 388, skinID = -1, boss = 0, level = 32, hpOrg = 63365.0, atkNOrg = 893.0, defNOrg = 581.0, atrOrg = 382.0, ctrOrg = 259.0, acrNOrg = 264.0, touOrg = 30.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 28.0, attacks = { 1001241, 1001242 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83013] = {id = 83013, name = '大灰狼', icon = 2154, iconID = 1, modelID = 371, skinID = -1, boss = 0, level = 33, hpOrg = 66986.0, atkNOrg = 943.0, defNOrg = 608.0, atrOrg = 394.0, ctrOrg = 269.0, acrNOrg = 271.0, touOrg = 34.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 28.0, attacks = { 1001191, 1001192 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83014] = {id = 83014, name = '山贼大头目', icon = 2171, iconID = 1, modelID = 415, skinID = -1, boss = 1, level = 34, hpOrg = 140921.0, atkNOrg = 1162.0, defNOrg = 631.0, atrOrg = 404.0, ctrOrg = 302.0, acrNOrg = 289.0, touOrg = 37.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 30.0, attacks = { 1001301, 1001302 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83015] = {id = 83015, name = '陈尚必', icon = 1002, iconID = 1, modelID = 2072, skinID = -1, boss = 2, level = 35, hpOrg = 1665476.0, atkNOrg = 1417.0, defNOrg = 664.0, atrOrg = 416.0, ctrOrg = 325.0, acrNOrg = 393.0, touOrg = 41.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 41.0, attacks = { 1000011, 1000012 }, skills = { 1000013, 1000017, 1000018, 1000016, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83020] = {id = 83020, name = '野蛮山贼', icon = 2159, iconID = 1, modelID = 345, skinID = -1, boss = 0, level = 49, hpOrg = 160279.0, atkNOrg = 3398.0, defNOrg = 1703.0, atrOrg = 665.0, ctrOrg = 525.0, acrNOrg = 419.0, touOrg = 117.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 372.0, atkWOrg = 0.0, defWOrg = 82.0, attacks = { 1001291, 1001292 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83021] = {id = 83021, name = '西域番僧', icon = 2168, iconID = 1, modelID = 413, skinID = -1, boss = 0, level = 50, hpOrg = 172803.0, atkNOrg = 3700.0, defNOrg = 1798.0, atrOrg = 703.0, ctrOrg = 561.0, acrNOrg = 435.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 435.0, atkWOrg = 0.0, defWOrg = 123.0, attacks = { 1001231, 1001232 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83022] = {id = 83022, name = '巨熊', icon = 2184, iconID = 1, modelID = 388, skinID = -1, boss = 0, level = 51, hpOrg = 189553.0, atkNOrg = 4033.0, defNOrg = 1904.0, atrOrg = 727.0, ctrOrg = 585.0, acrNOrg = 445.0, touOrg = 134.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 498.0, atkWOrg = 0.0, defWOrg = 123.0, attacks = { 1001241, 1001242 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83023] = {id = 83023, name = '大灰狼', icon = 2154, iconID = 1, modelID = 371, skinID = -1, boss = 0, level = 52, hpOrg = 194448.0, atkNOrg = 4477.0, defNOrg = 2138.0, atrOrg = 751.0, ctrOrg = 608.0, acrNOrg = 455.0, touOrg = 139.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 711.0, atkWOrg = 0.0, defWOrg = 150.0, attacks = { 1001191, 1001192 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83024] = {id = 83024, name = '山贼大头目', icon = 2171, iconID = 1, modelID = 415, skinID = -1, boss = 1, level = 53, hpOrg = 435991.0, atkNOrg = 5974.0, defNOrg = 2237.0, atrOrg = 781.0, ctrOrg = 677.0, acrNOrg = 502.0, touOrg = 143.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1188.0, atkWOrg = 0.0, defWOrg = 185.0, attacks = { 1001301, 1001302 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83025] = {id = 83025, name = '陈尚必', icon = 1002, iconID = 1, modelID = 2072, skinID = -1, boss = 2, level = 55, hpOrg = 5194475.0, atkNOrg = 8674.0, defNOrg = 2686.0, atrOrg = 844.0, ctrOrg = 762.0, acrNOrg = 641.0, touOrg = 170.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1646.0, atkWOrg = 0.0, defWOrg = 438.0, attacks = { 1000011, 1000012 }, skills = { 1000013, 1000017, 1000018, 1000016, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83030] = {id = 83030, name = '野蛮山贼', icon = 2159, iconID = 1, modelID = 345, skinID = -1, boss = 0, level = 65, hpOrg = 366907.0, atkNOrg = 13948.0, defNOrg = 4568.0, atrOrg = 1026.0, ctrOrg = 890.0, acrNOrg = 670.0, touOrg = 246.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 2290.0, atkWOrg = 0.0, defWOrg = 491.0, attacks = { 1001291, 1001292 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83031] = {id = 83031, name = '西域番僧', icon = 2168, iconID = 1, modelID = 413, skinID = -1, boss = 0, level = 67, hpOrg = 450192.0, atkNOrg = 15979.0, defNOrg = 5162.0, atrOrg = 1234.0, ctrOrg = 1074.0, acrNOrg = 711.0, touOrg = 267.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 2300.0, atkWOrg = 0.0, defWOrg = 637.0, attacks = { 1001231, 1001232 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83032] = {id = 83032, name = '巨熊', icon = 2184, iconID = 1, modelID = 388, skinID = -1, boss = 0, level = 69, hpOrg = 483007.0, atkNOrg = 17909.0, defNOrg = 5881.0, atrOrg = 1287.0, ctrOrg = 1134.0, acrNOrg = 745.0, touOrg = 292.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 2639.0, atkWOrg = 0.0, defWOrg = 690.0, attacks = { 1001241, 1001242 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83033] = {id = 83033, name = '大灰狼', icon = 2154, iconID = 1, modelID = 371, skinID = -1, boss = 0, level = 70, hpOrg = 486756.0, atkNOrg = 19638.0, defNOrg = 6379.0, atrOrg = 1391.0, ctrOrg = 1238.0, acrNOrg = 775.0, touOrg = 317.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3115.0, atkWOrg = 0.0, defWOrg = 742.0, attacks = { 1001191, 1001192 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83034] = {id = 83034, name = '山贼大头目', icon = 2171, iconID = 1, modelID = 415, skinID = -1, boss = 1, level = 71, hpOrg = 1016124.0, atkNOrg = 25580.0, defNOrg = 7054.0, atrOrg = 1409.0, ctrOrg = 1316.0, acrNOrg = 829.0, touOrg = 326.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3671.0, atkWOrg = 0.0, defWOrg = 845.0, attacks = { 1001301, 1001302 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83035] = {id = 83035, name = '陈尚必', icon = 1002, iconID = 1, modelID = 2072, skinID = -1, boss = 2, level = 73, hpOrg = 13378534.0, atkNOrg = 32814.0, defNOrg = 7539.0, atrOrg = 1455.0, ctrOrg = 1398.0, acrNOrg = 956.0, touOrg = 338.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 5597.0, atkWOrg = 0.0, defWOrg = 1149.0, attacks = { 1000011, 1000012 }, skills = { 1000013, 1000017, 1000018, 1000016, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83040] = {id = 83040, name = '野蛮山贼', icon = 2159, iconID = 1, modelID = 345, skinID = -1, boss = 0, level = 85, hpOrg = 1025387.0, atkNOrg = 40153.0, defNOrg = 14131.0, atrOrg = 1755.0, ctrOrg = 1632.0, acrNOrg = 1026.0, touOrg = 447.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 8189.0, atkWOrg = 0.0, defWOrg = 4447.0, attacks = { 1001291, 1001292 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83041] = {id = 83041, name = '西域番僧', icon = 2168, iconID = 1, modelID = 413, skinID = -1, boss = 0, level = 85, hpOrg = 1025387.0, atkNOrg = 40153.0, defNOrg = 14131.0, atrOrg = 1755.0, ctrOrg = 1632.0, acrNOrg = 1026.0, touOrg = 447.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 8189.0, atkWOrg = 0.0, defWOrg = 4447.0, attacks = { 1001231, 1001232 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83042] = {id = 83042, name = '巨熊', icon = 2184, iconID = 1, modelID = 388, skinID = -1, boss = 0, level = 86, hpOrg = 1087467.0, atkNOrg = 54961.0, defNOrg = 15174.0, atrOrg = 1771.0, ctrOrg = 1651.0, acrNOrg = 1054.0, touOrg = 457.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 8238.0, atkWOrg = 0.0, defWOrg = 4890.0, attacks = { 1001241, 1001242 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83043] = {id = 83043, name = '大灰狼', icon = 2154, iconID = 1, modelID = 371, skinID = -1, boss = 0, level = 86, hpOrg = 1087467.0, atkNOrg = 54961.0, defNOrg = 15174.0, atrOrg = 1771.0, ctrOrg = 1651.0, acrNOrg = 1054.0, touOrg = 457.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 8238.0, atkWOrg = 0.0, defWOrg = 4890.0, attacks = { 1001191, 1001192 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83044] = {id = 83044, name = '山贼大头目', icon = 2171, iconID = 1, modelID = 415, skinID = -1, boss = 1, level = 88, hpOrg = 2300289.0, atkNOrg = 71262.0, defNOrg = 15963.0, atrOrg = 1804.0, ctrOrg = 1774.0, acrNOrg = 1121.0, touOrg = 476.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 11043.0, atkWOrg = 0.0, defWOrg = 5458.0, attacks = { 1001301, 1001302 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[83045] = {id = 83045, name = '陈尚必', icon = 1002, iconID = 1, modelID = 2072, skinID = -1, boss = 2, level = 89, hpOrg = 26216382.0, atkNOrg = 87610.0, defNOrg = 17129.0, atrOrg = 1825.0, ctrOrg = 1848.0, acrNOrg = 1263.0, touOrg = 492.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 14703.0, atkWOrg = 0.0, defWOrg = 6812.0, attacks = { 1000011, 1000012 }, skills = { 1000013, 1000017, 1000018, 1000016, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3, -1, }, speed = 430, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 50000, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
