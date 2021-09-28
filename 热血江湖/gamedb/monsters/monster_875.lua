----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[87501] = {id = 87501, name = '流浪伐木工', icon = 2032, iconID = 1, modelID = 1262, skinID = -1, boss = 0, level = 77, hpOrg = 9937938.0, atkNOrg = 118321.0, defNOrg = 14362.0, atrOrg = 1728.0, ctrOrg = 1565.0, acrNOrg = 1006.0, touOrg = 451.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 7793.0, atkWOrg = 0.0, defWOrg = 4291.0, attacks = { 1000941, 1000942 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87502] = {id = 87502, name = '流浪少女', icon = 2196, iconID = 1, modelID = 377, skinID = -1, boss = 0, level = 78, hpOrg = 12685366.0, atkNOrg = 120878.0, defNOrg = 14684.0, atrOrg = 1761.0, ctrOrg = 1599.0, acrNOrg = 1013.0, touOrg = 454.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 8421.0, atkWOrg = 0.0, defWOrg = 4412.0, attacks = { 1001281, 1001282 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87503] = {id = 87503, name = '凶恶路霸', icon = 2164, iconID = 1, modelID = 364, skinID = -1, boss = 0, level = 79, hpOrg = 15769716.0, atkNOrg = 126281.0, defNOrg = 16053.0, atrOrg = 1778.0, ctrOrg = 1629.0, acrNOrg = 1044.0, touOrg = 482.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9167.0, atkWOrg = 0.0, defWOrg = 4534.0, attacks = { 1001561, 1001562 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87504] = {id = 87504, name = '凶恶地痞头领', icon = 2045, iconID = 1, modelID = 1249, skinID = -1, boss = 1, level = 80, hpOrg = 180747360.0, atkNOrg = 158040.0, defNOrg = 16380.0, atrOrg = 1799.0, ctrOrg = 1722.0, acrNOrg = 1121.0, touOrg = 503.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 11059.0, atkWOrg = 0.0, defWOrg = 5051.0, attacks = { 1000901, 1000902 }, skills = { 1000903, 1000904, 0, 0, }, slevel = { 1, 1, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 4, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '85ff7F00', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87505] = {id = 87505, name = '凶恶地痞', icon = 2144, iconID = 1, modelID = 344, skinID = -1, boss = 0, level = 81, hpOrg = 17468394.0, atkNOrg = 129115.0, defNOrg = 16626.0, atrOrg = 1820.0, ctrOrg = 1671.0, acrNOrg = 1105.0, touOrg = 507.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9263.0, atkWOrg = 0.0, defWOrg = 4791.0, attacks = { 1001481, 1001482 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87506] = {id = 87506, name = '流浪武士', icon = 2216, iconID = 1, modelID = 2138, skinID = -1, boss = 0, level = 82, hpOrg = 21360327.0, atkNOrg = 133369.0, defNOrg = 17767.0, atrOrg = 1842.0, ctrOrg = 1693.0, acrNOrg = 1113.0, touOrg = 511.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9311.0, atkWOrg = 0.0, defWOrg = 4925.0, attacks = { 1001771, 1001772 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87507] = {id = 87507, name = '凶恶劫匪头目', icon = 2195, iconID = 1, modelID = 457, skinID = -1, boss = 1, level = 83, hpOrg = 288955861.0, atkNOrg = 166854.0, defNOrg = 18112.0, atrOrg = 1863.0, ctrOrg = 1789.0, acrNOrg = 1168.0, touOrg = 523.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 12182.0, atkWOrg = 0.0, defWOrg = 5321.0, attacks = { 1001661, 1001662 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 2, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '85ff7F00', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87508] = {id = 87508, name = '流浪剑客', icon = 2188, iconID = 1, modelID = 452, skinID = -1, boss = 0, level = 84, hpOrg = 22197597.0, atkNOrg = 136814.0, defNOrg = 18435.0, atrOrg = 1884.0, ctrOrg = 1740.0, acrNOrg = 1146.0, touOrg = 535.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10136.0, atkWOrg = 0.0, defWOrg = 5118.0, attacks = { 1001631, 1001632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87509] = {id = 87509, name = '流浪猎手', icon = 2219, iconID = 1, modelID = 2139, skinID = -1, boss = 0, level = 85, hpOrg = 24651892.0, atkNOrg = 143584.0, defNOrg = 20293.0, atrOrg = 1969.0, ctrOrg = 1813.0, acrNOrg = 1194.0, touOrg = 566.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10935.0, atkWOrg = 0.0, defWOrg = 6167.0, attacks = { 1001781, 1001782 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[87510] = {id = 87510, name = '夜袭刺客', icon = 2088, iconID = 1, modelID = 1198, skinID = -1, boss = 2, level = 86, hpOrg = 264021466.0, atkNOrg = 145080.0, defNOrg = 20570.0, atrOrg = 1991.0, ctrOrg = 1835.0, acrNOrg = 1229.0, touOrg = 581.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 10997.0, atkWOrg = 0.0, defWOrg = 6876.0, attacks = { 1000571, 1000572 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 600, radius = 75, checkRange = 500, aiNode = { 0, }, trait = 0, race = 4, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 1250, statusList = { 23, }, spaHP = 0.75, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 1, outlineColor = '85ff7F00', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
