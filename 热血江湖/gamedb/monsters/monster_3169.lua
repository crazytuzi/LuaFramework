----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[316901] = {id = 316901, name = '捕鱼少女', icon = 2008, iconID = 1, modelID = 134, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 296.0, defNOrg = 231.0, atrOrg = 271.0, ctrOrg = 133.0, acrNOrg = 160.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 23.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[316902] = {id = 316902, name = '捕鱼大叔', icon = 2009, iconID = 1, modelID = 126, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 296.0, defNOrg = 231.0, atrOrg = 271.0, ctrOrg = 133.0, acrNOrg = 160.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 23.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[316903] = {id = 316903, name = '落难的美女', icon = 2013, iconID = 1, modelID = 2005, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 296.0, defNOrg = 231.0, atrOrg = 271.0, ctrOrg = 133.0, acrNOrg = 160.0, touOrg = 0.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 23.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3000, statusList = {  }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[316904] = {id = 316904, name = '海匪头目', icon = 2156, iconID = 1, modelID = 420, skinID = -1, boss = 0, level = 60, hpOrg = 99999999.0, atkNOrg = 99999.0, defNOrg = 99999.0, atrOrg = 99999.0, ctrOrg = 9999.0, acrNOrg = 9999.0, touOrg = 9999.0, atkAOrg = 9999.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[316905] = {id = 316905, name = '诡异的神秘人', icon = 2038, iconID = 1, modelID = 1179, skinID = -1, boss = 0, level = 60, hpOrg = 99999999.0, atkNOrg = 99999.0, defNOrg = 99999.0, atrOrg = 99999.0, ctrOrg = 9999.0, acrNOrg = 9999.0, touOrg = 9999.0, atkAOrg = 9999.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 1, 0, 0, 0, }, attkLst = {  }, speed = 430, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 0, guard = { tick = { 5000, 10000 }, radius = 300, speed = 300 }, traceDist = 1500, statusList = {  }, spaHP = 1.0, spaOdds = 0.5, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
