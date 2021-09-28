----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[1009101] = {id = 1009101, name = '医生大招1', icon = 8966, desc = '医生大招1', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '16guxuepingzhang', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 500, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 1, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1009102] = {id = 1009102, name = '医生大招2', icon = 8966, desc = '医生大招2', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1500, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1500, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '12beisuqingfeng', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 800, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 1, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
