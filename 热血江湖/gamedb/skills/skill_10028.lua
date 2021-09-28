----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local skill = 
{
	[1002801] = {id = 1002801, name = '技能1', icon = 1, desc = 'boss-瓦砾-技能1', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '02attack02', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 1200, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002802] = {id = 1002802, name = '技能2', icon = 1, desc = 'boss-瓦砾-技能2', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 4000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 2000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 2000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '01attack01', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = { castInfo = { castTick = 285, castTickCount = 6, eventID = 1, type = 1, duration = 0, changetarget = 0,  },  }, specialVFX = { 151, 152,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 1200, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002803] = {id = 1002803, name = '技能3', icon = 1, desc = 'boss-瓦砾-技能3', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 3000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 2000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = '03attack03', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 149, 150,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 1200, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002804] = {id = 1002804, name = '普通攻击', icon = 1, desc = '神机藏海-箭塔-普通攻击', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 400, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002805] = {id = 1002805, name = '水晶普攻-难度1', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002806] = {id = 1002806, name = '水晶触发', icon = 1, desc = '势力战-水晶-触发-气血低于X%施放高伤害', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = { 1002807,  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002807] = {id = 1002807, name = '水晶触发', icon = 1, desc = '势力战-水晶-触发-气血低于X%无敌X秒', type = 2, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 200, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 200, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 1, arg1 = 0, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002808] = {id = 1002808, name = '水晶普攻-难度2', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002809] = {id = 1002809, name = '水晶普攻-难度3', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002810] = {id = 1002810, name = '水晶普攻-难度4', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002811] = {id = 1002811, name = '水晶普攻-难度5', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002812] = {id = 1002812, name = '水晶普攻-难度6', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},
	[1002813] = {id = 1002813, name = '水晶普攻-难度7', icon = 1, desc = '势力战-水晶-普攻（新版）', type = 1, auraCamp = 1, studyMaxLvl = 1, maxLvl = 1, parentID = 0, parentLvl = 0, duration = 1000, spell = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, charge = { time = 0, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, attack = { time = 1000, breakByDamage = 0, breakByCtrl = 1, breakByMove = 0 }, action = 'stand', isFlySkill = 0, flySpeed = 0, canAccSpeed = 0, specialArgs = {  }, specialVFX = { 0,  }, canAttack = 0, forceBreak = 1, warnEffectID = 0, warnTime = 0, scope = { type = 3, arg1 = 2000, arg2 = 0, arg3 = 0, arg4 = 0 }, maxDistance = 150, maxTargets = -1, stateDesc = { '无', '无', '无', '无', '无', '',  }, soundCond = 5000, soundID = 1, useorder = 0, addsp = 0, coolWhenSpell = 1, childs = {  }, sequences = {  }, linkrealmSkill = 0, showname = 0, common_desc = '', isRunNow = 0, verse = '', summonedId = 0, mutexSkillID = 0, isHeirloomSpirit = 0},

};
function get_db_table()
	return skill;
end
