----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[76201] = {id = 76201, name = '邪派侦察兵', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 3, level = 50, hpOrg = 250976.0, atkNOrg = 3283.0, defNOrg = 1798.0, atrOrg = 703.0, ctrOrg = 524.0, acrNOrg = 428.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 556.0, atkWOrg = 0.0, defWOrg = 158.0, attacks = { 1000591, 1000592 }, skills = { 1000593, 1000594, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 800, radius = 75, checkRange = 2000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 600, speed = 550 }, traceDist = 2000, statusList = { 23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76202] = {id = 76202, name = '邪派斥候', icon = 2039, iconID = 1, modelID = 3504, skinID = -1, boss = 3, level = 52, hpOrg = 666217.0, atkNOrg = 3960.0, defNOrg = 2138.0, atrOrg = 751.0, ctrOrg = 569.0, acrNOrg = 446.0, touOrg = 139.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 904.0, atkWOrg = 0.0, defWOrg = 193.0, attacks = { 1000591, 1000592 }, skills = { 1000593, 1000594, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 800, radius = 75, checkRange = 2000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 600, speed = 550 }, traceDist = 2000, statusList = { 23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76203] = {id = 76203, name = '邪派大将军', icon = 2022, iconID = 1, modelID = 3505, skinID = -1, boss = 3, level = 54, hpOrg = 4532377.0, atkNOrg = 6860.0, defNOrg = 2805.0, atrOrg = 805.0, ctrOrg = 618.0, acrNOrg = 481.0, touOrg = 148.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1341.0, atkWOrg = 0.0, defWOrg = 268.0, attacks = { 1000441, 1000442 }, skills = { 1000443, 1000444, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 850, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 600, speed = 550 }, traceDist = 2500, statusList = { 23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76204] = {id = 76204, name = '邪派精英韩玮', icon = 2087, iconID = 1, modelID = 3506, skinID = -1, boss = 3, level = 56, hpOrg = 2292850.0, atkNOrg = 8374.0, defNOrg = 3589.0, atrOrg = 858.0, ctrOrg = 669.0, acrNOrg = 515.0, touOrg = 175.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1341.0, atkWOrg = 0.0, defWOrg = 406.0, attacks = { 1000671, 1000672 }, skills = { 1000673, 1000674, 0, 0, }, slevel = { 1, 1, 0, 1, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 850, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 600, speed = 550 }, traceDist = 2800, statusList = { 23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76250] = {id = 76250, name = '邪派小型雕像', icon = 2198, iconID = 1, modelID = 991, skinID = -1, boss = 4, level = 50, hpOrg = 1673175.0, atkNOrg = 250.0, defNOrg = 1798.0, atrOrg = 703.0, ctrOrg = 524.0, acrNOrg = 428.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 556.0, atkWOrg = 0.0, defWOrg = 158.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = {  }, speed = 0, radius = 75, checkRange = 2000, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 1800, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76251] = {id = 76251, name = '邪派大型雕像', icon = 2198, iconID = 1, modelID = 990, skinID = -1, boss = 5, level = 53, hpOrg = 5900000.0, atkNOrg = 265.0, defNOrg = 2237.0, atrOrg = 781.0, ctrOrg = 597.0, acrNOrg = 472.0, touOrg = 143.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1341.0, atkWOrg = 0.0, defWOrg = 225.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = {  }, speed = 0, radius = 75, checkRange = 2000, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 1800, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[76252] = {id = 76252, name = '邪派基地', icon = 2200, iconID = 1, modelID = 993, skinID = -1, boss = 6, level = 57, hpOrg = 15018985.0, atkNOrg = 5944.0, defNOrg = 4660.0, atrOrg = 876.0, ctrOrg = 689.0, acrNOrg = 526.0, touOrg = 999999.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1675.0, atkWOrg = 0.0, defWOrg = 407.0, attacks = { 1000281, 1000281 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 0, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 5, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 1800, statusList = { 6,23, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
