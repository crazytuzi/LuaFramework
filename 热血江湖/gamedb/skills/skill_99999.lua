----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[9999999] = {id = 9999999, name = '自创武功模板', icon = 1, desc = '自创武功模板', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '01attack01', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 800, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 100, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 1000, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
