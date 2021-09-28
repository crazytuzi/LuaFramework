----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[1009301] = {id = 1009301, name = '乾坤魔印', icon = 9714, desc = '使用强大的咒印，震击当前区域，可驱散妖灵周身的瘴气，使其现身。\n妖灵通常会隐于暗处，不为人所见。而妖灵隐藏的区域会显现出地藏像，附着妖灵的地藏像则会围绕着鬼火。', type = 2, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 2000, spell = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'dj_zuzhou', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 1, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1009302] = {id = 1009302, name = '天眼术', icon = 9715, desc = '强大的通灵之术，可感知妖灵的存在。\n学习后，小地图上将会标记出可驭灵的坐标地点。', type = 2, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 2000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 2000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'dj_zuzhou', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 1, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
