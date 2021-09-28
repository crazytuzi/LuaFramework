----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[900201] = {id = 900201, name = '剑破长空', icon = 198, desc = '发出光剑四散开来，对周围目标造成1次伤害，并使其命中降低', type = 1, auraCamp = 1, studyMaxLvl = 70, maxLvl = 70, parentID = 0, parentLvl = 0, duration = 1500, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1500, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '05qixingfapo', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 550, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '伤害提升<c=green>5%</c>', '伤害提升<c=green>10%</c>', '伤害提升<c=green>15%</c>', '伤害提升<c=green>20%</c>', '',  }, soundCond = 5000, soundID = 1, useorder = 1120, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '造成<c=FF01A63A>[基础伤害*%s%%+%s]</c>点伤害，并使目标命中降低<c=FF01A63A>[%s]</c>，持续<c=FF01A63A>7</c>秒', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[900202] = {id = 900202, name = '万剑出击', icon = 271, desc = '对周围目标造成2次伤害，每次伤害必然命中目标', type = 1, auraCamp = 1, studyMaxLvl = 70, maxLvl = 70, parentID = 0, parentLvl = 0, duration = 1300, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1300, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '09jianfengbalu', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 400, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '伤害提升<c=green>5%</c>', '伤害提升<c=green>10%</c>', '伤害提升<c=green>15%</c>', '伤害提升<c=green>20%</c>', '',  }, soundCond = 5000, soundID = 1, useorder = 1080, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '每次造成<c=FF01A63A>[基础伤害*%s%%+%s]</c>点伤害，每次伤害<c=FF01A63A>无视躲闪，必然命中</c>', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[900203] = {id = 900203, name = '幻影追魂', icon = 288, desc = '远程造成1次伤害，有几率使目标定身(剑意可延长持续时间)', type = 1, auraCamp = 1, studyMaxLvl = 70, maxLvl = 70, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '14jiyingfengxing', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 6, arg1 = 800, arg2 = 150, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '伤害提升<c=green>5%</c>', '伤害提升<c=green>10%</c>', '伤害提升<c=green>15%</c>', '伤害提升<c=green>20%</c>', '',  }, soundCond = 5000, soundID = 1, useorder = 1030, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '造成<c=FF01A63A>[基础伤害*%s%%+%s]</c>点伤害，<c=FF01A63A>%s%%</c>几率使对方定身<c=FF01A63A>3</c>秒(每道剑意延长<c=FF01A63A>0.4</c>秒持续时间)', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[900204] = {id = 900204, name = '万剑归宗', icon = 287, desc = '造成3次伤害，并使自身全部抗性提升(剑意可延长持续时间)', type = 1, auraCamp = 1, studyMaxLvl = 70, maxLvl = 70, parentID = 0, parentLvl = 0, duration = 1300, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1300, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '13wanhuajiebian', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 5, arg1 = 400, arg2 = 150, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '伤害提升<c=green>5%</c>', '伤害提升<c=green>10%</c>', '伤害提升<c=green>15%</c>', '伤害提升<c=green>20%</c>', '',  }, soundCond = 5000, soundID = 1, useorder = 1040, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '每次造成<c=FF01A63A>[基础伤害*%s%%+%s]</c>点伤害，同时使自己的全部抗性提升<c=FF01A63A>[30%%]</c>，持续<c=FF01A63A>5</c>秒(每道剑意延长<c=FF01A63A>0.4</c>秒)', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
