----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[61601] = {id = 61601, name = '抢亲强盗', icon = 2083, iconID = 1, modelID = 1185, skinID = -1, boss = 7, level = 30, hpOrg = 50875.0, atkNOrg = 984.0, defNOrg = 534.0, atrOrg = 361.0, ctrOrg = 220.0, acrNOrg = 239.0, touOrg = 23.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 27.0, attacks = { 1000551, 1000552 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0,0,0,0,0,0,0, -1, }, speed = 450, radius = 75, checkRange = 5000, aiNode = { 0, }, trait = 0, race = 4, guard = { tick = { 5000, 10000 }, radius = 400, speed = 350 }, traceDist = 4500, statusList = {  }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
