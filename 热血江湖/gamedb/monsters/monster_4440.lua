----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[444002] = {id = 444002, name = '兵器库守卫', icon = 2215, iconID = 1, modelID = 2136, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 100508.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1001752, 1001752 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444003] = {id = 444003, name = '兵器库守卫', icon = 2293, iconID = 1, modelID = 2517, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 100508.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1002181, 1002182 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 1, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444004] = {id = 444004, name = '兵器库守卫', icon = 2083, iconID = 1, modelID = 1185, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 100508.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000551, 1000552 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = {  }, spaHP = 0.75, spaOdds = 0.15, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444005] = {id = 444005, name = '兵器库守卫', icon = 2045, iconID = 1, modelID = 1248, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 100508.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000901, 1000902 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444006] = {id = 444006, name = '兵器库守卫', icon = 2218, iconID = 1, modelID = 2134, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 100508.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1001731, 1001731 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 800, radius = 75, checkRange = 800, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 150, speed = 430 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444007] = {id = 444007, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 85, hpOrg = 3000, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1009601, 1009601 }, skills = { 1009602, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444008] = {id = 444008, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 85, hpOrg = 3000, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1009601, 1009601 }, skills = { 1009603, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444009] = {id = 444009, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 85, hpOrg = 3000, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1009601, 1009601 }, skills = { 1009604, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444010] = {id = 444010, name = '机关石柱', icon = 2318, iconID = 1, modelID = 5248, skinID = -1, boss = 0, level = 85, hpOrg = 3000, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1009601, 1009601 }, skills = { 1009605, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,0,1,0,0,0,1, }, speed = 0, radius = 75, checkRange = 1500, aiNode = { 904, 916, 917, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444011] = {id = 444011, name = '神地机关护卫', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 57433.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444012] = {id = 444012, name = '神地机关护卫', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 57433.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444013] = {id = 444013, name = '神地机关护卫', icon = 2069, iconID = 1, modelID = 1279, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 57433.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1001021, 1001022 }, skills = { 1001023, 1001024, 1001025, 1001026, }, slevel = { 1, 1, 1, 1, }, attkLst = { 0,1,0,2,0,3,0,4, -1, }, speed = 500, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444014] = {id = 444014, name = '神地机关护卫', icon = 2038, iconID = 1, modelID = 1222, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 57433.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000701, 1000702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 500, radius = 75, checkRange = 1200, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444015] = {id = 444015, name = '无名侠士', icon = 2091, iconID = 1, modelID = 1220, skinID = -1, boss = 0, level = 85, hpOrg = 54781982, atkNOrg = 8892281.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000681, 1000682 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 700, radius = 75, checkRange = 2500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 700 }, traceDist = 8000, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444016] = {id = 444016, name = '无名侠士', icon = 2036, iconID = 1, modelID = 1173, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000451, 1000452 }, skills = { 1000453, 1000454, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 600, radius = 75, checkRange = 12000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 12000, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444017] = {id = 444017, name = '无名侠士', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 600, radius = 75, checkRange = 12000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 12000, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444018] = {id = 444018, name = '神地典狱长', icon = 2020, iconID = 1, modelID = 5257, skinID = -1, boss = 2, level = 85, hpOrg = 112500, atkNOrg = 424214.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1341.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 17596.0, atkWOrg = 0.0, defWOrg = 8181.0, attacks = { 1000021, 1000022 }, skills = { 1000028, 1000025, 0, 0, }, slevel = { 2, 4, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1200, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444019] = {id = 444019, name = '兵器库守卫', icon = 2022, iconID = 1, modelID = 1177, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444020] = {id = 444020, name = '兵器库守卫', icon = 2195, iconID = 1, modelID = 422, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444021] = {id = 444021, name = '兵器库守卫', icon = 2039, iconID = 1, modelID = 1200, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444022] = {id = 444022, name = '兵器库守卫', icon = 2031, iconID = 1, modelID = 1229, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444023] = {id = 444023, name = '兵器库守卫', icon = 2165, iconID = 1, modelID = 365, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 100000.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444024] = {id = 444024, name = '无名侠士', icon = 2036, iconID = 1, modelID = 1173, skinID = -1, boss = 0, level = 85, hpOrg = 1369549, atkNOrg = 177845.0, defNOrg = 20293.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000451, 1000452 }, skills = { 1000453, 1000454, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 600 }, traceDist = 800, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[444025] = {id = 444025, name = '地牢残党', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 0, level = 85, hpOrg = 684774, atkNOrg = 57433.0, defNOrg = 20293.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1000511, 1000512 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 600, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 1, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},

};
function get_db_table()
	return monster;
end
