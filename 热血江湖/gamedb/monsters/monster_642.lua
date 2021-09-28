----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[64201] = {id = 64201, name = '传功长老史青龙', icon = 2029, iconID = 1, modelID = 1235, skinID = -1, boss = 2, level = 67, hpOrg = 1216144.0, atkNOrg = 62012.0, defNOrg = 7381.0, atrOrg = 1379.0, ctrOrg = 1597.0, acrNOrg = 795.0, touOrg = 324.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 11218.0, atkWOrg = 0.0, defWOrg = 5188.0, attacks = { 1000801, 1000802 }, skills = { 1000803, 1000804, 0, 0, }, slevel = { 1, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300104, dPopProp = 1.0, dPopText = 300204, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64211] = {id = 64211, name = '丐帮二袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 68, hpOrg = 326528.0, atkNOrg = 19772.0, defNOrg = 8166.0, atrOrg = 1396.0, ctrOrg = 1615.0, acrNOrg = 766.0, touOrg = 331.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 5656.0, atkWOrg = 0.0, defWOrg = 2688.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64212] = {id = 64212, name = '丐帮三袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 68, hpOrg = 326528.0, atkNOrg = 19772.0, defNOrg = 8166.0, atrOrg = 1396.0, ctrOrg = 1615.0, acrNOrg = 766.0, touOrg = 331.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 5656.0, atkWOrg = 0.0, defWOrg = 2688.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64221] = {id = 64221, name = '丐帮二袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 69, hpOrg = 349861.0, atkNOrg = 21375.0, defNOrg = 8991.0, atrOrg = 1422.0, ctrOrg = 1646.0, acrNOrg = 788.0, touOrg = 338.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 6333.0, atkWOrg = 0.0, defWOrg = 2782.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64222] = {id = 64222, name = '丐帮三袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 69, hpOrg = 349861.0, atkNOrg = 21375.0, defNOrg = 8991.0, atrOrg = 1422.0, ctrOrg = 1646.0, acrNOrg = 788.0, touOrg = 338.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 6333.0, atkWOrg = 0.0, defWOrg = 2782.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64231] = {id = 64231, name = '丐帮六袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 70, hpOrg = 349565.0, atkNOrg = 22724.0, defNOrg = 9613.0, atrOrg = 1477.0, ctrOrg = 1696.0, acrNOrg = 833.0, touOrg = 367.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7722.0, atkWOrg = 0.0, defWOrg = 3534.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64232] = {id = 64232, name = '丐帮七袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 70, hpOrg = 349565.0, atkNOrg = 22724.0, defNOrg = 9613.0, atrOrg = 1477.0, ctrOrg = 1696.0, acrNOrg = 833.0, touOrg = 367.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7722.0, atkWOrg = 0.0, defWOrg = 3534.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64233] = {id = 64233, name = '南坛护法', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 70, hpOrg = 349565.0, atkNOrg = 22724.0, defNOrg = 9613.0, atrOrg = 1477.0, ctrOrg = 1696.0, acrNOrg = 833.0, touOrg = 367.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7722.0, atkWOrg = 0.0, defWOrg = 3534.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64234] = {id = 64234, name = '中坛护法', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 70, hpOrg = 349565.0, atkNOrg = 22724.0, defNOrg = 9613.0, atrOrg = 1477.0, ctrOrg = 1696.0, acrNOrg = 833.0, touOrg = 367.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7722.0, atkWOrg = 0.0, defWOrg = 3534.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64241] = {id = 64241, name = '丐帮二袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 71, hpOrg = 379729.0, atkNOrg = 23543.0, defNOrg = 9951.0, atrOrg = 1494.0, ctrOrg = 1720.0, acrNOrg = 847.0, touOrg = 379.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7788.0, atkWOrg = 0.0, defWOrg = 3646.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64242] = {id = 64242, name = '丐帮三袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 71, hpOrg = 379729.0, atkNOrg = 23543.0, defNOrg = 9951.0, atrOrg = 1494.0, ctrOrg = 1720.0, acrNOrg = 847.0, touOrg = 379.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 7788.0, atkWOrg = 0.0, defWOrg = 3646.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64251] = {id = 64251, name = '传功长老鲁大脚', icon = 1011, iconID = 1, modelID = 2007, skinID = -1, boss = 2, level = 72, hpOrg = 1605166.0, atkNOrg = 84673.0, defNOrg = 10872.0, atrOrg = 1521.0, ctrOrg = 1748.0, acrNOrg = 896.0, touOrg = 387.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 17162.0, atkWOrg = 0.0, defWOrg = 7910.0, attacks = { 1001101, 1001102 }, skills = { 1001103, 1001104, 0, 0, }, slevel = { 1, 2, 0, 0, }, attkLst = { 0,0,1,0,0,0,0,2,0, -1, }, speed = 810, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 300104, dPopProp = 1.0, dPopText = 300204, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64261] = {id = 64261, name = '丐帮二袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 73, hpOrg = 422312.0, atkNOrg = 25482.0, defNOrg = 11212.0, atrOrg = 1538.0, ctrOrg = 1766.0, acrNOrg = 881.0, touOrg = 396.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 8652.0, atkWOrg = 0.0, defWOrg = 4070.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64262] = {id = 64262, name = '丐帮三袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 73, hpOrg = 422312.0, atkNOrg = 25482.0, defNOrg = 11212.0, atrOrg = 1538.0, ctrOrg = 1766.0, acrNOrg = 881.0, touOrg = 396.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 8652.0, atkWOrg = 0.0, defWOrg = 4070.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64271] = {id = 64271, name = '丐帮三袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 74, hpOrg = 427632.0, atkNOrg = 26122.0, defNOrg = 11614.0, atrOrg = 1617.0, ctrOrg = 1851.0, acrNOrg = 898.0, touOrg = 411.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 9526.0, atkWOrg = 0.0, defWOrg = 4194.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64272] = {id = 64272, name = '丐帮四袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 74, hpOrg = 427632.0, atkNOrg = 26122.0, defNOrg = 11614.0, atrOrg = 1617.0, ctrOrg = 1851.0, acrNOrg = 898.0, touOrg = 411.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 9526.0, atkWOrg = 0.0, defWOrg = 4194.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64281] = {id = 64281, name = '丐帮六袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 75, hpOrg = 458398.0, atkNOrg = 43406.0, defNOrg = 12879.0, atrOrg = 1694.0, ctrOrg = 1923.0, acrNOrg = 937.0, touOrg = 432.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 10970.0, atkWOrg = 0.0, defWOrg = 4866.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64282] = {id = 64282, name = '丐帮七袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 75, hpOrg = 458398.0, atkNOrg = 43406.0, defNOrg = 12879.0, atrOrg = 1694.0, ctrOrg = 1923.0, acrNOrg = 937.0, touOrg = 432.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 10970.0, atkWOrg = 0.0, defWOrg = 4866.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64283] = {id = 64283, name = '南坛护法', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 75, hpOrg = 458398.0, atkNOrg = 43406.0, defNOrg = 12879.0, atrOrg = 1694.0, ctrOrg = 1923.0, acrNOrg = 937.0, touOrg = 432.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 10970.0, atkWOrg = 0.0, defWOrg = 4866.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64284] = {id = 64284, name = '中坛护法', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 75, hpOrg = 458398.0, atkNOrg = 43406.0, defNOrg = 12879.0, atrOrg = 1694.0, ctrOrg = 1923.0, acrNOrg = 937.0, touOrg = 432.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 10970.0, atkWOrg = 0.0, defWOrg = 4866.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64291] = {id = 64291, name = '丐帮三袋弟子', icon = 2193, iconID = 1, modelID = 378, skinID = -1, boss = 0, level = 76, hpOrg = 495966.0, atkNOrg = 44264.0, defNOrg = 13253.0, atrOrg = 1711.0, ctrOrg = 1940.0, acrNOrg = 949.0, touOrg = 441.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 11060.0, atkWOrg = 0.0, defWOrg = 5008.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[64292] = {id = 64292, name = '丐帮四袋弟子', icon = 2179, iconID = 1, modelID = 382, skinID = -1, boss = 0, level = 76, hpOrg = 495966.0, atkNOrg = 44264.0, defNOrg = 13253.0, atrOrg = 1711.0, ctrOrg = 1940.0, acrNOrg = 949.0, touOrg = 441.0, atkAOrg = 18000.0, atkCOrg = 0.0, defCOrg = 11060.0, atkWOrg = 0.0, defWOrg = 5008.0, attacks = { 1001451, 1001452 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
