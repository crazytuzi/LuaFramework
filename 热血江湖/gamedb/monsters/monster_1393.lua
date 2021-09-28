----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[139321] = {id = 139321, name = '巨灵攻城临时暂未使用', icon = 2312, iconID = 1, modelID = 2579, skinID = -1, boss = 10, level = 105, hpOrg = 1190341040.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139322] = {id = 139322, name = '巨灵攻城临时暂未使用', icon = 2309, iconID = 1, modelID = 2580, skinID = -1, boss = 10, level = 105, hpOrg = 1190341041.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139323] = {id = 139323, name = '巨灵攻城临时暂未使用', icon = 2310, iconID = 1, modelID = 2581, skinID = -1, boss = 10, level = 105, hpOrg = 1190341042.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139324] = {id = 139324, name = '巨灵攻城临时暂未使用', icon = 2311, iconID = 1, modelID = 2582, skinID = -1, boss = 10, level = 105, hpOrg = 1190341043.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139325] = {id = 139325, name = '巨灵攻城临时暂未使用', icon = 2312, iconID = 1, modelID = 2579, skinID = -1, boss = 10, level = 105, hpOrg = 1190341044.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139326] = {id = 139326, name = '巨灵攻城临时暂未使用', icon = 2309, iconID = 1, modelID = 2580, skinID = -1, boss = 10, level = 105, hpOrg = 1190341045.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[139327] = {id = 139327, name = '巨灵攻城临时暂未使用', icon = 2310, iconID = 1, modelID = 2581, skinID = -1, boss = 10, level = 105, hpOrg = 1190341046.0, atkNOrg = 299227.0, defNOrg = 111748.0, atrOrg = 2246.0, ctrOrg = 3573.0, acrNOrg = 1756.0, touOrg = 666.0, atkAOrg = 36000.0, atkCOrg = 0.0, defCOrg = 32267.0, atkWOrg = 0.0, defWOrg = 24531.0, attacks = { 1002131, 1002132 }, skills = { 1002133, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = { 0,0,1,0,0,0, }, speed = 0, radius = 75, checkRange = 6000, aiNode = { 0, }, trait = 1, race = 8, guard = { tick = { 5000, 10000 }, radius = 400, speed = 0 }, traceDist = 3000, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 8000, withinATK = 8000, elementATK = 0, monsterType = 0, deadLoopTime = 5000, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
