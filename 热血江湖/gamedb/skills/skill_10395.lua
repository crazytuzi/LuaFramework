----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[1039501] = {id = 1039501, name = '轻功', icon = 1, desc = '彼岸花-轻功', type = 2, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = { rushInfo = { type = 3, distance = 1100, height = 200, velocity = 2000,  },  }, specialVFX = { 4, 5,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 1, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 0, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 0, childs = {  }, sequences = { 1039502,  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 1, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1039502] = {id = 1039502, name = '轻功2', icon = 1, desc = '彼岸花-轻功-第二段', type = 2, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = { rushInfo = { type = 3, distance = 1100, height = 200, velocity = 3000,  },  }, specialVFX = { 34, 35, 37,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 1, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 0, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 0, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
