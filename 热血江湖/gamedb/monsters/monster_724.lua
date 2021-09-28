----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[72401] = {id = 72401, name = '神工', icon = 2067, iconID = 1, modelID = 282, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 99999.0, defNOrg = 9999999.0, atrOrg = 9999999.0, ctrOrg = 85.0, acrNOrg = 118.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[72402] = {id = 72402, name = '怪丐', icon = 2106, iconID = 1, modelID = 257, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 99999.0, defNOrg = 9999999.0, atrOrg = 9999999.0, ctrOrg = 516.0, acrNOrg = 335.0, touOrg = 127.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 496.0, atkWOrg = 0.0, defWOrg = 866.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[72403] = {id = 72403, name = '刀帝', icon = 2118, iconID = 1, modelID = 261, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 99999.0, defNOrg = 9999999.0, atrOrg = 9999999.0, ctrOrg = 394.0, acrNOrg = 294.0, touOrg = 96.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 339.0, atkWOrg = 0.0, defWOrg = 575.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[72404] = {id = 72404, name = '剑皇', icon = 2121, iconID = 1, modelID = 259, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 99999.0, defNOrg = 9999999.0, atrOrg = 9999999.0, ctrOrg = 9999.0, acrNOrg = 9999.0, touOrg = 9999.0, atkAOrg = 9999.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[72405] = {id = 72405, name = '药仙', icon = 2109, iconID = 1, modelID = 218, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 99999.0, defNOrg = 9999999.0, atrOrg = 9999999.0, ctrOrg = 228.0, acrNOrg = 222.0, touOrg = 43.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 119.0, atkWOrg = 0.0, defWOrg = 198.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
