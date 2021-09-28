----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[170000] = {id = 170000, name = '小精灵', icon = 2323, iconID = 1, modelID = 2856, skinID = -1, boss = 9, level = 95, hpOrg = 1.0, atkNOrg = 1.0, defNOrg = 1.0, atrOrg = 1.0, ctrOrg = 0.0, acrNOrg = 0.0, touOrg = 0.0, atkAOrg = 0.0, atkCOrg = 0.0, defCOrg = 0.0, atkWOrg = 0.0, defWOrg = 0.0, attacks = { 0, 0 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = {  }, speed = 450, radius = 75, checkRange = 1300, aiNode = { 0, }, trait = 0, race = 6, guard = { tick = { 5000, 10000 }, radius = 200, speed = 200 }, traceDist = 0, statusList = {  }, spaHP = 0.5, spaOdds = 0.05, birtheffect = 0, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 0.0, sPopText = 0, dPopProp = 0.0, dPopText = 0, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {0, }, selectEffectId = 0, removeEffect = 0, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
