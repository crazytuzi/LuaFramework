----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local monster = 
{
	[316111] = {id = 316111, name = '木灵', icon = 2188, iconID = 1, modelID = 4833, skinID = -1, boss = 2, level = 102, hpOrg = 72268434.0, atkNOrg = 438642.0, defNOrg = 16719.0, atrOrg = 3632.0, ctrOrg = 2110.0, acrNOrg = 1779.0, touOrg = 811.0, atkAOrg = 15000.0, atkCOrg = 0.0, defCOrg = 20900.0, atkWOrg = 0.0, defWOrg = 13532.0, attacks = { 1001631, 1001632 }, skills = { 0, 0, 0, 0, }, slevel = { 0, 0, 0, 0, }, attkLst = { 0,0, -1, }, speed = 430, radius = 75, checkRange = 1500, aiNode = { 0, }, trait = 1, race = 3, guard = { tick = { 5000, 10000 }, radius = 320, speed = 350 }, traceDist = 3500, statusList = { 6,23, }, spaHP = 0.5, spaOdds = 0.1, birtheffect = 30173, showNameInWorld = 0, hasOutline = 0, outlineColor = '0.0', camp = 0, sPopProp = 1.0, sPopText = 830065, dPopProp = 1.0, dPopText = 830066, changePercent = -1.0, changeAnisId = -1, newMonsterId = -1, typeDesc = '', effectId = {30744, }, selectEffectId = 30745, removeEffect = 1, damageHpRatio = { 0, }, isRecordDamage = 0, ArmorType = 0, ArmorValue = 0, ArmorAbsorbRatio = 0, ArmorGainRatio 	= 0, ArmorAbsorbProb = 0, outATK = 0, withinATK = 0, elementATK = 0, monsterType = 0, windDamageOrg = 0.0, windDefenceOrg = 0.0, fireDamageOrg = 0.0, fireDefenceOrg	 = 0.0, soilDamageOrg = 0.0, soilDefenceOrg = 0.0, woodDamageOrg = 0.0, woodDefenceOrg = 0.0, steedFightDamageOrg = 0.0, steedFightDefendOrg = 0.0, internalForcesOrg = 0.0, dexOrg = 0.0, isDetectionBlock = 0},

};
function get_db_table()
	return monster;
end
