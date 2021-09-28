----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[65601] = {id = 65601, name = '亲传弟子司马明', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 2, level = 107, hpOrg = 3884575.0, atkNOrg = 419563.0, defNOrg = 39394.0, atrOrg = 3362.0, ctrOrg = 2234.0, acrNOrg = 1731.0, touOrg = 909.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 27316.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300106, dPopProp = 1.0, dPopText = 300206, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<玄阴甲护体>', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 1, ArmorValue = 2944984, ArmorAbsorbRatio = 8000, ArmorGainRatio 	= 10000, ArmorAbsorbProb = 10000, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65602] = {id = 65602, name = '亲传弟子司马亮', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 2, level = 107, hpOrg = 3884575.0, atkNOrg = 419563.0, defNOrg = 39394.0, atrOrg = 3362.0, ctrOrg = 2234.0, acrNOrg = 1731.0, touOrg = 909.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 27316.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,2,0,0,0,0,1,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300101, dPopProp = 1.0, dPopText = 300201, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<烈阳甲护体>', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 2, ArmorValue = 2944984, ArmorAbsorbRatio = 8000, ArmorGainRatio 	= 10000, ArmorAbsorbProb = 10000, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65611] = {id = 65611, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 108, hpOrg = 991470.0, atkNOrg = 112161.0, defNOrg = 39920.0, atrOrg = 3595.0, ctrOrg = 2254.0, acrNOrg = 1722.0, touOrg = 924.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 13774.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65612] = {id = 65612, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 108, hpOrg = 991470.0, atkNOrg = 112161.0, defNOrg = 39920.0, atrOrg = 3595.0, ctrOrg = 2254.0, acrNOrg = 1722.0, touOrg = 924.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 13774.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65621] = {id = 65621, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 109, hpOrg = 1013204.0, atkNOrg = 113325.0, defNOrg = 40425.0, atrOrg = 3622.0, ctrOrg = 2282.0, acrNOrg = 1742.0, touOrg = 940.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14127.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65622] = {id = 65622, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 109, hpOrg = 1013204.0, atkNOrg = 113325.0, defNOrg = 40425.0, atrOrg = 3622.0, ctrOrg = 2282.0, acrNOrg = 1742.0, touOrg = 940.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14127.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65631] = {id = 65631, name = '药门巡逻兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 110, hpOrg = 1039935.0, atkNOrg = 113963.0, defNOrg = 40806.0, atrOrg = 3647.0, ctrOrg = 2302.0, acrNOrg = 1748.0, touOrg = 944.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14480.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65632] = {id = 65632, name = '药门守护兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 110, hpOrg = 1039935.0, atkNOrg = 113963.0, defNOrg = 40806.0, atrOrg = 3647.0, ctrOrg = 2302.0, acrNOrg = 1748.0, touOrg = 944.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14480.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65633] = {id = 65633, name = '药仙捣药役', icon = 2158, iconID = 1, modelID = 386, skinID = -1, boss = 0, level = 110, hpOrg = 1039935.0, atkNOrg = 113963.0, defNOrg = 40806.0, atrOrg = 3647.0, ctrOrg = 2302.0, acrNOrg = 1748.0, touOrg = 944.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14480.0, attacks = { 1001421, 1001422 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65634] = {id = 65634, name = '药门护院兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 110, hpOrg = 1039935.0, atkNOrg = 113963.0, defNOrg = 40806.0, atrOrg = 3647.0, ctrOrg = 2302.0, acrNOrg = 1748.0, touOrg = 944.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14480.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65641] = {id = 65641, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 111, hpOrg = 1055716.0, atkNOrg = 115527.0, defNOrg = 41435.0, atrOrg = 3671.0, ctrOrg = 2342.0, acrNOrg = 1783.0, touOrg = 975.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14600.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65642] = {id = 65642, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 111, hpOrg = 1055716.0, atkNOrg = 115527.0, defNOrg = 41435.0, atrOrg = 3671.0, ctrOrg = 2342.0, acrNOrg = 1783.0, touOrg = 975.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 14600.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65651] = {id = 65651, name = '亲传弟子何华', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 2, level = 112, hpOrg = 4452981.0, atkNOrg = 676683.0, defNOrg = 41825.0, atrOrg = 3696.0, ctrOrg = 2362.0, acrNOrg = 1881.0, touOrg = 1003.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 29930.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300106, dPopProp = 1.0, dPopText = 300206, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<玄阴甲护体>', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 1, ArmorValue = 3388137, ArmorAbsorbRatio = 8000, ArmorGainRatio 	= 10000, ArmorAbsorbProb = 10000, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65652] = {id = 65652, name = '亲传弟子何夜', icon = 2052, iconID = 1, modelID = 1234, skinID = -1, boss = 2, level = 112, hpOrg = 4452981.0, atkNOrg = 676683.0, defNOrg = 41825.0, atrOrg = 3696.0, ctrOrg = 2362.0, acrNOrg = 1881.0, touOrg = 1003.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 29930.0, attacks = { 1000791, 1000792 }, skills = { 1000793, 1000794, 0, 0, }, slevel = { 2, 2, 0, 0, }, attkLst = { 0,0,2,0,0,0,0,1,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300101, dPopProp = 1.0, dPopText = 300201, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '<烈阳甲护体>', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 2, ArmorValue = 3388137, ArmorAbsorbRatio = 8000, ArmorGainRatio 	= 10000, ArmorAbsorbProb = 10000, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65661] = {id = 65661, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 113, hpOrg = 1140975.0, atkNOrg = 174158.0, defNOrg = 42220.0, atrOrg = 3508.0, ctrOrg = 2382.0, acrNOrg = 1863.0, touOrg = 1007.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15084.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65662] = {id = 65662, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 113, hpOrg = 1140975.0, atkNOrg = 174158.0, defNOrg = 42220.0, atrOrg = 3508.0, ctrOrg = 2382.0, acrNOrg = 1863.0, touOrg = 1007.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15084.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65671] = {id = 65671, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 114, hpOrg = 1171382.0, atkNOrg = 176871.0, defNOrg = 42740.0, atrOrg = 3532.0, ctrOrg = 2412.0, acrNOrg = 1883.0, touOrg = 1024.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15453.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65672] = {id = 65672, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 114, hpOrg = 1171382.0, atkNOrg = 176871.0, defNOrg = 42740.0, atrOrg = 3532.0, ctrOrg = 2412.0, acrNOrg = 1883.0, touOrg = 1024.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15453.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65681] = {id = 65681, name = '药门巡逻兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 115, hpOrg = 1208597.0, atkNOrg = 179096.0, defNOrg = 43144.0, atrOrg = 3555.0, ctrOrg = 2431.0, acrNOrg = 1891.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15840.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65682] = {id = 65682, name = '药门守护兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 115, hpOrg = 1208597.0, atkNOrg = 179096.0, defNOrg = 43144.0, atrOrg = 3555.0, ctrOrg = 2431.0, acrNOrg = 1891.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15840.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65683] = {id = 65683, name = '药仙捣药役', icon = 2158, iconID = 1, modelID = 386, skinID = -1, boss = 0, level = 115, hpOrg = 1208597.0, atkNOrg = 179096.0, defNOrg = 43144.0, atrOrg = 3555.0, ctrOrg = 2431.0, acrNOrg = 1891.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15840.0, attacks = { 1001421, 1001422 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65684] = {id = 65684, name = '药门护院兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 115, hpOrg = 1208597.0, atkNOrg = 179096.0, defNOrg = 43144.0, atrOrg = 3555.0, ctrOrg = 2431.0, acrNOrg = 1891.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15840.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65691] = {id = 65691, name = '药门看门兽', icon = 2142, iconID = 1, modelID = 406, skinID = -1, boss = 0, level = 116, hpOrg = 1245624.0, atkNOrg = 180891.0, defNOrg = 43553.0, atrOrg = 3579.0, ctrOrg = 2451.0, acrNOrg = 1897.0, touOrg = 1031.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15965.0, attacks = { 1001391, 1001392 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[65692] = {id = 65692, name = '药门警戒兽', icon = 2170, iconID = 1, modelID = 372, skinID = -1, boss = 0, level = 116, hpOrg = 1245624.0, atkNOrg = 180891.0, defNOrg = 43553.0, atrOrg = 3579.0, ctrOrg = 2451.0, acrNOrg = 1897.0, touOrg = 1031.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 999999.0, atkWOrg = 0.0, defWOrg = 15965.0, attacks = { 1001401, 1001402 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 2500, withinATK = 2500, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
