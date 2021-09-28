----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[121101] = {id = 121101, name = '神地合成兽', icon = 2034, iconID = 1, modelID = 1239, skinID = -1, boss = 2, level = 114, hpOrg = 258534614, atkNOrg = 100908.0, defNOrg = 21370.0, atrOrg = 3958.0, ctrOrg = 2412.0, acrNOrg = 2133.0, touOrg = 1024.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22473.0, atkWOrg = 0.0, defWOrg = 16631.0, attacks = { 1001611, 1001612 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = {  }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[121102] = {id = 121102, name = '神地喽啰', icon = 2024, iconID = 1, modelID = 1180, skinID = -1, boss = 2, level = 114, hpOrg = 258534614, atkNOrg = 100908.0, defNOrg = 21370.0, atrOrg = 3958.0, ctrOrg = 2412.0, acrNOrg = 2133.0, touOrg = 1024.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22473.0, atkWOrg = 0.0, defWOrg = 16631.0, attacks = { 1000511, 1000512 }, skills = { 1000513, 1000514, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = {  }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[121103] = {id = 121103, name = '神地渗透者', icon = 2183, iconID = 1, modelID = 356, skinID = -1, boss = 2, level = 114, hpOrg = 258534614, atkNOrg = 100908.0, defNOrg = 21370.0, atrOrg = 3958.0, ctrOrg = 2412.0, acrNOrg = 2133.0, touOrg = 1024.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22473.0, atkWOrg = 0.0, defWOrg = 16631.0, attacks = { 1001671, 1001672 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = {  }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[121111] = {id = 121111, name = '神地影卫', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 2, level = 115, hpOrg = 983235528, atkNOrg = 156686.0, defNOrg = 21572.0, atrOrg = 3983.0, ctrOrg = 2431.0, acrNOrg = 2143.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22606.0, atkWOrg = 0.0, defWOrg = 17034.0, attacks = { 1000571, 1000572 }, skills = { 1000573, 1000574, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0,1,0,0,2, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 2, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30075, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[121112] = {id = 121112, name = '神地刺客统领', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 2, level = 115, hpOrg = 983235528, atkNOrg = 156686.0, defNOrg = 21572.0, atrOrg = 3983.0, ctrOrg = 2431.0, acrNOrg = 2143.0, touOrg = 1027.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22606.0, atkWOrg = 0.0, defWOrg = 17034.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 4, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = { 23, }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30075, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},
	[121121] = {id = 121121, name = '紫檀', icon = 1015, iconID = 1, modelID = 2016, skinID = -1, boss = 2, level = 116, hpOrg = 1611745185, atkNOrg = 274727.0, defNOrg = 21776.0, atrOrg = 4009.0, ctrOrg = 2451.0, acrNOrg = 2151.0, touOrg = 1031.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 22739.0, atkWOrg = 0.0, defWOrg = 17154.0, attacks = { 1000881, 1000882 }, skills = { 1000883, 1000847, 1000896, 1000886, }, slevel = { 4, 1, 4, 4, }, attkLst = { 0,1,0,0,3,0,0,4, -1, }, speed = 430, radius = 75, checkRange = 50000, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 0, speed = 350 }, traceDist = 9000, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30075, showNameInWorld = 0, hasOutline = 1, outlineColor = '00FF0000', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0, deadEffect = 0, firstBornTip = 0},

};
function get_db_table()
	return monster;
end
