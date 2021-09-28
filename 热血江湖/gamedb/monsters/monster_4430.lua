----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[443002] = {id = 443002, name = '兵器库守卫', icon = 2215, iconID = 1, modelID = 2136, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 18957.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1001752, 1001752 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443003] = {id = 443003, name = '兵器库守卫', icon = 2293, iconID = 1, modelID = 2517, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 18957.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1002181, 1002182 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 1, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443004] = {id = 443004, name = '兵器库守卫', icon = 2083, iconID = 1, modelID = 1185, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 18957.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000551, 1000552 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = {  }, spaHP = 0.75, spaOdds = 0.15, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443005] = {id = 443005, name = '兵器库守卫', icon = 2045, iconID = 1, modelID = 1248, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 18957.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000901, 1000902 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443006] = {id = 443006, name = '兵器库守卫', icon = 2218, iconID = 1, modelID = 2134, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 18957.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1001731, 1001731 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443007] = {id = 443007, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 65, hpOrg = 3000, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1009601, 1009601 }, skills = { 1009602, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443008] = {id = 443008, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 65, hpOrg = 3000, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1009601, 1009601 }, skills = { 1009603, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443009] = {id = 443009, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 65, hpOrg = 3000, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1009601, 1009601 }, skills = { 1009604, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443010] = {id = 443010, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 65, hpOrg = 3000, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1009601, 1009601 }, skills = { 1009605, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443011] = {id = 443011, name = '神地机关护卫', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 10832.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443012] = {id = 443012, name = '神地机关护卫', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 10832.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443013] = {id = 443013, name = '神地机关护卫', icon = 2069, iconID = 1, modelID = 1279, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 10832.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1001021, 1001022 }, skills = { 1001023, 1001024, 1001025, 1001026, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3,0,4, -1, }, speed = 500, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443014] = {id = 443014, name = '神地机关护卫', icon = 2038, iconID = 1, modelID = 1222, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 10832.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000701, 1000702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443015] = {id = 443015, name = '无名侠士', icon = 2091, iconID = 1, modelID = 1220, skinID = -1, boss = 0, level = 65, hpOrg = 16800975, atkNOrg = 1000003.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1000681, 1000682 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 700, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 700 }, traceDist = 8000, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443016] = {id = 443016, name = '无名侠士', icon = 2036, iconID = 1, modelID = 1173, skinID = -1, boss = 0, level = 65, hpOrg = 112006, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 1215.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1000451, 1000452 }, skills = { 1000453, 1000454, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 600, radius = 75, checkRange = 12000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 12000, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443017] = {id = 443017, name = '无名侠士', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 0, level = 65, hpOrg = 112006, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 1215.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 600, radius = 75, checkRange = 12000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 12000, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443018] = {id = 443018, name = '神地典狱长', icon = 2020, iconID = 1, modelID = 5257, skinID = -1, boss = 2, level = 65, hpOrg = 112500, atkNOrg = 67295.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 891.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 5574.0, atkWOrg = 0.0, defWOrg = 2613.0, attacks = { 1000021, 1000022 }, skills = { 1000028, 1000025, 0, 0, }, slevel = { 2, 4, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1200, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443019] = {id = 443019, name = '兵器库守卫', icon = 2022, iconID = 1, modelID = 1177, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443020] = {id = 443020, name = '兵器库守卫', icon = 2195, iconID = 1, modelID = 422, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443021] = {id = 443021, name = '兵器库守卫', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443022] = {id = 443022, name = '兵器库守卫', icon = 2031, iconID = 1, modelID = 1229, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443023] = {id = 443023, name = '兵器库守卫', icon = 2165, iconID = 1, modelID = 365, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 100000.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443024] = {id = 443024, name = '无名侠士', icon = 2036, iconID = 1, modelID = 1173, skinID = -1, boss = 0, level = 65, hpOrg = 560032, atkNOrg = 33333.0, defNOrg = 6171.0, atrOrg = 1215.0, ctrOrg = 957.0, acrNOrg = 786.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 4111.0, atkWOrg = 0.0, defWOrg = 2038.0, attacks = { 1000451, 1000452 }, skills = { 1000453, 1000454, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 800, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[443025] = {id = 443025, name = '地牢残党', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 65, hpOrg = 280016, atkNOrg = 10832.0, defNOrg = 6171.0, atrOrg = 1215.0, ctrOrg = 957.0, acrNOrg = 759.0, touOrg = 312.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 3546.0, atkWOrg = 0.0, defWOrg = 1927.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 600, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},

};
function get_db_table()
	return monster;
end
