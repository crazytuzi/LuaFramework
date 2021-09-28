----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[99999] = {id = 99999, name = '空', icon = 2058, iconID = 1, modelID = 433, skinID = -1, boss = 0, level = 99, hpOrg = 9999999.0, atkNOrg = 100.0, defNOrg = 100.0, atrOrg = 100.0, ctrOrg = 100.0, acrNOrg = 100.0, touOrg = 100.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 1002053, 1002053 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 0, radius = 75, checkRange = 1400, aiNode = { 0, }, trait = 1, race = 1, guard = { tick = { 5000, 10000 }, radius = 0, speed = 0 }, traceDist = 1400, statusList = { 6,23,38, }, spaHP = 0.0, spaOdds = 0.0, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30901, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
