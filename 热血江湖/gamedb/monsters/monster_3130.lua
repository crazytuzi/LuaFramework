----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[313001] = {id = 313001, name = '“取血刀”金拙', icon = 2188, iconID = 1, modelID = 4833, skinID = -1, boss = 2, level = 72, hpOrg = 14513888.0, atkNOrg = 92877.0, defNOrg = 5436.0, atrOrg = 2547.0, ctrOrg = 1235.0, acrNOrg = 1022.0, touOrg = 387.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9618.0, atkWOrg = 0.0, defWOrg = 4432.0, attacks = { 1001631, 1001632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 830065, dPopProp = 1.0, dPopText = 830066, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[313002] = {id = 313002, name = '“夺宝”柳毅公', icon = 2059, iconID = 1, modelID = 4834, skinID = -1, boss = 2, level = 72, hpOrg = 14513888.0, atkNOrg = 92877.0, defNOrg = 5436.0, atrOrg = 2547.0, ctrOrg = 1235.0, acrNOrg = 1022.0, touOrg = 387.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9618.0, atkWOrg = 0.0, defWOrg = 4432.0, attacks = { 1001701, 1001702 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 650, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 830067, dPopProp = 1.0, dPopText = 830068, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 1, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[313003] = {id = 313003, name = '“诡计多端”齐岳', icon = 2240, iconID = 1, modelID = 4835, skinID = -1, boss = 2, level = 72, hpOrg = 14513888.0, atkNOrg = 92877.0, defNOrg = 5436.0, atrOrg = 2547.0, ctrOrg = 1235.0, acrNOrg = 1022.0, touOrg = 387.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9618.0, atkWOrg = 0.0, defWOrg = 4432.0, attacks = { 1002011, 1002012 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 830069, dPopProp = 1.0, dPopText = 830070, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[313004] = {id = 313004, name = '“仇鬼”夏景明', icon = 2234, iconID = 1, modelID = 4836, skinID = -1, boss = 2, level = 72, hpOrg = 14513888.0, atkNOrg = 92877.0, defNOrg = 5436.0, atrOrg = 2547.0, ctrOrg = 1235.0, acrNOrg = 1022.0, touOrg = 387.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9618.0, atkWOrg = 0.0, defWOrg = 4432.0, attacks = { 1001941, 1001941 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 830071, dPopProp = 1.0, dPopText = 830072, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},
	[313005] = {id = 313005, name = '沙匪大当家', icon = 2349, iconID = 1, modelID = 4038, skinID = -1, boss = 2, level = 72, hpOrg = 14513888.0, atkNOrg = 92877.0, defNOrg = 5436.0, atrOrg = 2547.0, ctrOrg = 1235.0, acrNOrg = 1022.0, touOrg = 387.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 9618.0, atkWOrg = 0.0, defWOrg = 4432.0, attacks = { 1002605, 1002606 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 450, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 6, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 2, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
