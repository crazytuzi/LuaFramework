----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[219006] = {id = 219006, name = '漠海争花占坑', icon = 2040, iconID = 1, modelID = 1199, skinID = -1, boss = 0, level = 42, hpOrg = 91548.0, atkNOrg = 1967.0, defNOrg = 1066.0, atrOrg = 533.0, ctrOrg = 371.0, acrNOrg = 350.0, touOrg = 77.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 95.0, attacks = { 1000581, 1000582 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0,0,0,0,0, -1, }, speed = 450, radius = 75, checkRange = 5000, aiNode = { 0, }, trait = 1, race = 5, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 1.0, spaOdds = 0.3, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
