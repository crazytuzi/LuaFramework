----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[95300] = {id = 95300, name = '吞风魔人', icon = 2178, iconID = 1, modelID = 370, skinID = -1, boss = 0, level = 107, hpOrg = 7943028.0, atkNOrg = 81449.0, defNOrg = 59091.0, atrOrg = 2538.0, ctrOrg = 2276.0, acrNOrg = 1607.0, touOrg = 909.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 11257.0, atkWOrg = 0.0, defWOrg = 8640.0, attacks = { 1001601, 1001602 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1250, aiNode = { 0, }, trait = 0, race = 3, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 1250, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 1, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 4000, withinATK = 4000, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
