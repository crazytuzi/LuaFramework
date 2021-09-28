----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[88101] = {id = 88101, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 30, hpOrg = 15898.0, atkNOrg = 1003.0, defNOrg = 534.0, atrOrg = 361.0, ctrOrg = 230.0, acrNOrg = 239.0, touOrg = 23.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 27.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88102] = {id = 88102, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 40, hpOrg = 29133.0, atkNOrg = 1964.0, defNOrg = 941.0, atrOrg = 499.0, ctrOrg = 355.0, acrNOrg = 319.0, touOrg = 67.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 58.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88103] = {id = 88103, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 50, hpOrg = 52663.0, atkNOrg = 4456.0, defNOrg = 1798.0, atrOrg = 703.0, ctrOrg = 543.0, acrNOrg = 416.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 435.0, atkWOrg = 0.0, defWOrg = 117.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88104] = {id = 88104, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 60, hpOrg = 96053.0, atkNOrg = 12589.0, defNOrg = 3739.0, atrOrg = 935.0, ctrOrg = 771.0, acrNOrg = 579.0, touOrg = 212.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1339.0, atkWOrg = 0.0, defWOrg = 380.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88105] = {id = 88105, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 70, hpOrg = 157982.0, atkNOrg = 23071.0, defNOrg = 6379.0, atrOrg = 1391.0, ctrOrg = 1208.0, acrNOrg = 746.0, touOrg = 317.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3115.0, atkWOrg = 0.0, defWOrg = 697.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88106] = {id = 88106, name = '碑文劫掠者', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 80, hpOrg = 281214.0, atkNOrg = 38101.0, defNOrg = 11388.0, atrOrg = 1602.0, ctrOrg = 1433.0, acrNOrg = 917.0, touOrg = 405.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 7397.0, atkWOrg = 0.0, defWOrg = 3143.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88151] = {id = 88151, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 30, hpOrg = 75370.0, atkNOrg = 1165.0, defNOrg = 534.0, atrOrg = 361.0, ctrOrg = 239.0, acrNOrg = 249.0, touOrg = 23.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 29.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88152] = {id = 88152, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 40, hpOrg = 132334.0, atkNOrg = 2312.0, defNOrg = 941.0, atrOrg = 499.0, ctrOrg = 368.0, acrNOrg = 333.0, touOrg = 67.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 63.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88153] = {id = 88153, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 50, hpOrg = 230404.0, atkNOrg = 5335.0, defNOrg = 1798.0, atrOrg = 703.0, ctrOrg = 561.0, acrNOrg = 435.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 428.0, atkWOrg = 0.0, defWOrg = 128.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88154] = {id = 88154, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 60, hpOrg = 406486.0, atkNOrg = 15295.0, defNOrg = 3739.0, atrOrg = 935.0, ctrOrg = 794.0, acrNOrg = 603.0, touOrg = 212.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 1325.0, atkWOrg = 0.0, defWOrg = 424.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88155] = {id = 88155, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 70, hpOrg = 649009.0, atkNOrg = 28139.0, defNOrg = 6379.0, atrOrg = 1391.0, ctrOrg = 1238.0, acrNOrg = 775.0, touOrg = 317.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3099.0, atkWOrg = 0.0, defWOrg = 787.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[88156] = {id = 88156, name = '碑文大盗', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 1, level = 80, hpOrg = 1124856.0, atkNOrg = 46277.0, defNOrg = 11388.0, atrOrg = 1602.0, ctrOrg = 1469.0, acrNOrg = 953.0, touOrg = 405.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 7397.0, atkWOrg = 0.0, defWOrg = 3592.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 5, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<太玄碑文活动怪>', effectId = {30766, }, selectEffectId = 30767, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
