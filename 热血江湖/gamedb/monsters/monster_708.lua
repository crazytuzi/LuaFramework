----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[70801] = {id = 70801, name = '马迁徽1', icon = 2134, iconID = 1, modelID = 401, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2109.0, defNOrg = 1219.0, atrOrg = 918.0, ctrOrg = 673.0, acrNOrg = 381.0, touOrg = 162.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 788.0, atkWOrg = 0.0, defWOrg = 1238.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70802] = {id = 70802, name = '半金川', icon = 2082, iconID = 1, modelID = 1179, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2761.0, defNOrg = 1540.0, atrOrg = 1130.0, ctrOrg = 855.0, acrNOrg = 431.0, touOrg = 201.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1053.0, atkWOrg = 0.0, defWOrg = 1702.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70804] = {id = 70804, name = '刘世华1', icon = 1013, iconID = 1, modelID = 2017, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2109.0, defNOrg = 1219.0, atrOrg = 918.0, ctrOrg = 673.0, acrNOrg = 381.0, touOrg = 162.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 788.0, atkWOrg = 0.0, defWOrg = 1238.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70805] = {id = 70805, name = '刺客团长魏之痕1', icon = 2040, iconID = 1, modelID = 1199, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 3501.0, defNOrg = 1876.0, atrOrg = 1367.0, ctrOrg = 1061.0, acrNOrg = 476.0, touOrg = 236.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1497.0, atkWOrg = 0.0, defWOrg = 2269.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70806] = {id = 70806, name = '雷天虎', icon = 2080, iconID = 1, modelID = 1176, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 3501.0, defNOrg = 1876.0, atrOrg = 1367.0, ctrOrg = 1061.0, acrNOrg = 476.0, touOrg = 236.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1497.0, atkWOrg = 0.0, defWOrg = 2269.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70807] = {id = 70807, name = '赵开颜', icon = 2002, iconID = 1, modelID = 85, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 3501.0, defNOrg = 1876.0, atrOrg = 1367.0, ctrOrg = 1061.0, acrNOrg = 476.0, touOrg = 236.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1497.0, atkWOrg = 0.0, defWOrg = 2269.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70808] = {id = 70808, name = '刘世华2', icon = 1013, iconID = 1, modelID = 2017, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2109.0, defNOrg = 1219.0, atrOrg = 918.0, ctrOrg = 673.0, acrNOrg = 381.0, touOrg = 162.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 788.0, atkWOrg = 0.0, defWOrg = 1238.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70809] = {id = 70809, name = '刘世华3', icon = 1013, iconID = 1, modelID = 2017, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2109.0, defNOrg = 1219.0, atrOrg = 918.0, ctrOrg = 673.0, acrNOrg = 381.0, touOrg = 162.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 788.0, atkWOrg = 0.0, defWOrg = 1238.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70810] = {id = 70810, name = '马迁徽2', icon = 2134, iconID = 1, modelID = 401, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 2109.0, defNOrg = 1219.0, atrOrg = 918.0, ctrOrg = 673.0, acrNOrg = 381.0, touOrg = 162.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 788.0, atkWOrg = 0.0, defWOrg = 1238.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70811] = {id = 70811, name = '刺客团长魏之痕2', icon = 2040, iconID = 1, modelID = 1199, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 3501.0, defNOrg = 1876.0, atrOrg = 1367.0, ctrOrg = 1061.0, acrNOrg = 476.0, touOrg = 236.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1497.0, atkWOrg = 0.0, defWOrg = 2269.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70812] = {id = 70812, name = '神女', icon = 2229, iconID = 1, modelID = 318, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 781.0, defNOrg = 536.0, atrOrg = 465.0, ctrOrg = 291.0, acrNOrg = 256.0, touOrg = 68.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 176.0, atkWOrg = 0.0, defWOrg = 356.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70813] = {id = 70813, name = '陈天源', icon = 2038, iconID = 1, modelID = 1232, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 120.0, defNOrg = 110.0, atrOrg = 200.0, ctrOrg = 21.0, acrNOrg = 111.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70814] = {id = 70814, name = '李士轩', icon = 2038, iconID = 1, modelID = 1232, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 120.0, defNOrg = 110.0, atrOrg = 200.0, ctrOrg = 21.0, acrNOrg = 111.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[70815] = {id = 70815, name = '熙若', icon = 2078, iconID = 1, modelID = 169, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 591.0, defNOrg = 417.0, atrOrg = 389.0, ctrOrg = 228.0, acrNOrg = 222.0, touOrg = 43.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 119.0, atkWOrg = 0.0, defWOrg = 198.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
