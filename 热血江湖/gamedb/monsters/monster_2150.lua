----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[215001] = {id = 215001, name = '沙匪二当家', icon = 2348, iconID = 1, modelID = 4037, skinID = -1, boss = 1, level = 85, hpOrg = 80989683.0, atkNOrg = 127264.0, defNOrg = 30439.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1341.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 17596.0, atkWOrg = 0.0, defWOrg = 8181.0, attacks = { 1002603, 1002604 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0,0,0,0,0, -1, }, speed = 450, radius = 75, checkRange = 5000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = { 6,23, }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 30745, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[215002] = {id = 215002, name = '沙匪兵', icon = 2165, iconID = 1, modelID = 4039, skinID = -1, boss = 0, level = 85, hpOrg = 6327318.0, atkNOrg = 106707.0, defNOrg = 30439.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000631, 1000632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.4, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[215003] = {id = 215003, name = '巨木', icon = 2354, iconID = 1, modelID = 4045, skinID = -1, boss = 1, level = 85, hpOrg = 19800.0, atkNOrg = 100.0, defNOrg = 100.0, atrOrg = 100.0, ctrOrg = 100.0, acrNOrg = 100.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 1001521, 1001522 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = {  }, speed = 0, radius = 75, checkRange = 1250, aiNode = { 0, }, trait = 0, race = 6, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 1250, statusList = { 6,23, }, spaHP = 0.01, spaOdds = 0.001, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[215004] = {id = 215004, name = '沙匪兵', icon = 2165, iconID = 1, modelID = 4039, skinID = -1, boss = 0, level = 85, hpOrg = 6327318.0, atkNOrg = 106707.0, defNOrg = 30439.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000631, 1000632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.4, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[215005] = {id = 215005, name = '沙匪兵', icon = 2165, iconID = 1, modelID = 4039, skinID = -1, boss = 0, level = 85, hpOrg = 6327318.0, atkNOrg = 106707.0, defNOrg = 30439.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1233.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 13265.0, atkWOrg = 0.0, defWOrg = 6596.0, attacks = { 1000631, 1000632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 3000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.4, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[215006] = {id = 215006, name = '沙匪大当家', icon = 2349, iconID = 1, modelID = 4038, skinID = -1, boss = 1, level = 85, hpOrg = 121484524.0, atkNOrg = 127264.0, defNOrg = 30439.0, atrOrg = 1969.0, ctrOrg = 1657.0, acrNOrg = 1341.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 17596.0, atkWOrg = 0.0, defWOrg = 8181.0, attacks = { 1002605, 1002606 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0,0,0,0,0, -1, }, speed = 450, radius = 75, checkRange = 5000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = { 6,23, }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 30745, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
