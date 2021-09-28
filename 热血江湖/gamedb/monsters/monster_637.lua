----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[63701] = {id = 63701, name = '刀帝二弟子邹明', icon = 1015, iconID = 1, modelID = 2016, skinID = -1, boss = 2, level = 117, hpOrg = 12847125.0, atkNOrg = 768689.0, defNOrg = 98925.0, atrOrg = 2738.0, ctrOrg = 2470.0, acrNOrg = 1927.0, touOrg = 1034.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 42614.0, atkWOrg = 0.0, defWOrg = 32721.0, attacks = { 1000881, 1000882 }, skills = { 1000883, 1000885, 0, 0, }, slevel = { 1, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300103, dPopProp = 1.0, dPopText = 300203, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63711] = {id = 63711, name = '刀帝门人', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 118, hpOrg = 3728017.0, atkNOrg = 199205.0, defNOrg = 110965.0, atrOrg = 2757.0, ctrOrg = 2490.0, acrNOrg = 1973.0, touOrg = 1061.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21450.0, atkWOrg = 0.0, defWOrg = 18047.0, attacks = { 1000591, 1000592 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63712] = {id = 63712, name = '刀帝追随者', icon = 2087, iconID = 1, modelID = 1219, skinID = -1, boss = 0, level = 118, hpOrg = 3728017.0, atkNOrg = 199205.0, defNOrg = 110965.0, atrOrg = 2757.0, ctrOrg = 2490.0, acrNOrg = 1973.0, touOrg = 1061.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21450.0, atkWOrg = 0.0, defWOrg = 18047.0, attacks = { 1000671, 1000672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63721] = {id = 63721, name = '刀帝门人', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 119, hpOrg = 3821813.0, atkNOrg = 202245.0, defNOrg = 112325.0, atrOrg = 2777.0, ctrOrg = 2520.0, acrNOrg = 1993.0, touOrg = 1078.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21592.0, atkWOrg = 0.0, defWOrg = 18501.0, attacks = { 1000591, 1000592 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63722] = {id = 63722, name = '刀帝追随者', icon = 2087, iconID = 1, modelID = 1219, skinID = -1, boss = 0, level = 119, hpOrg = 3821813.0, atkNOrg = 202245.0, defNOrg = 112325.0, atrOrg = 2777.0, ctrOrg = 2520.0, acrNOrg = 1993.0, touOrg = 1078.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21592.0, atkWOrg = 0.0, defWOrg = 18501.0, attacks = { 1000671, 1000672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63731] = {id = 63731, name = '刀帝卫道士', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 120, hpOrg = 3967012.0, atkNOrg = 204484.0, defNOrg = 113395.0, atrOrg = 2805.0, ctrOrg = 2547.0, acrNOrg = 2086.0, touOrg = 1116.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21736.0, atkWOrg = 0.0, defWOrg = 18963.0, attacks = { 1000591, 1000592 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63732] = {id = 63732, name = '刀帝外门弟子', icon = 2087, iconID = 1, modelID = 1219, skinID = -1, boss = 0, level = 120, hpOrg = 3967012.0, atkNOrg = 204484.0, defNOrg = 113395.0, atrOrg = 2805.0, ctrOrg = 2547.0, acrNOrg = 2086.0, touOrg = 1116.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21736.0, atkWOrg = 0.0, defWOrg = 18963.0, attacks = { 1000671, 1000672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63733] = {id = 63733, name = '刀帝崇信者', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 120, hpOrg = 3967012.0, atkNOrg = 204484.0, defNOrg = 113395.0, atrOrg = 2805.0, ctrOrg = 2547.0, acrNOrg = 2086.0, touOrg = 1116.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21736.0, atkWOrg = 0.0, defWOrg = 18963.0, attacks = { 1000591, 1000592 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63734] = {id = 63734, name = '刀帝内门弟子', icon = 2087, iconID = 1, modelID = 1219, skinID = -1, boss = 0, level = 120, hpOrg = 3967012.0, atkNOrg = 204484.0, defNOrg = 113395.0, atrOrg = 2805.0, ctrOrg = 2547.0, acrNOrg = 2086.0, touOrg = 1116.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 21736.0, atkWOrg = 0.0, defWOrg = 18963.0, attacks = { 1000671, 1000672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63741] = {id = 63741, name = '刀帝门人', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 121, hpOrg = 4083384.0, atkNOrg = 207173.0, defNOrg = 114480.0, atrOrg = 2569.0, ctrOrg = 2311.0, acrNOrg = 2096.0, touOrg = 1122.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 7387.0, atkWOrg = 0.0, defWOrg = 19110.0, attacks = { 1000591, 1000592 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63742] = {id = 63742, name = '刀帝追随者', icon = 2087, iconID = 1, modelID = 1219, skinID = -1, boss = 0, level = 121, hpOrg = 4083384.0, atkNOrg = 207173.0, defNOrg = 114480.0, atrOrg = 2569.0, ctrOrg = 2311.0, acrNOrg = 2096.0, touOrg = 1122.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 7387.0, atkWOrg = 0.0, defWOrg = 19110.0, attacks = { 1000671, 1000672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[63751] = {id = 63751, name = '刀帝大弟子欧阳烈', icon = 1015, iconID = 1, modelID = 2016, skinID = -1, boss = 2, level = 122, hpOrg = 16819212.0, atkNOrg = 830975.0, defNOrg = 115575.0, atrOrg = 2598.0, ctrOrg = 2339.0, acrNOrg = 2127.0, touOrg = 1128.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 14964.0, atkWOrg = 0.0, defWOrg = 38514.0, attacks = { 1000881, 1000882 }, skills = { 1000883, 1000885, 0, 0, }, slevel = { 1, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300103, dPopProp = 1.0, dPopText = 300203, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
