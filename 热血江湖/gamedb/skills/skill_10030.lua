----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[1003001] = {id = 1003001, name = '浴火劫', icon = 9717, desc = '原初之火，可燃万物。驭灵必须使用的特殊技能之一，附带火属性效果，可对夜萝洲妖灵造成少量伤害。\n单独使用时可对妖灵造成的伤害非常有限，需配合其他驭灵技能使用。', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '99zc_shan02_3', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 5, arg1 = 600, arg2 = 150, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1003002] = {id = 1003002, name = '木神舞', icon = 9716, desc = '木之本源，可驭邪灵。驭灵必须使用的特殊技能之一，附带木属性效果，可对夜萝洲妖灵造成少量伤害。\n单独使用时可对妖灵造成的伤害非常有限，需配合其他驭灵技能使用。', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '99zc_ju01_2', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 6, arg1 = 800, arg2 = 150, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1003003] = {id = 1003003, name = '瀑水咒', icon = 9718, desc = '急水之势，可畏众生。驭灵必须使用的特殊技能之一，附带水属性效果，可对夜萝洲妖灵造成少量伤害。\n单独使用时可对妖灵造成的伤害非常有限，需配合其他驭灵技能使用。', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '99zc_yuan01_3', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 450, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = 1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
