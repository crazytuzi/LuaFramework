local QSBAction = import(".QSBAction")local QSBAttackByBuffNum = class("QSBAttackByBuffNum", QSBAction)local QSkill = import("...models.QSkill")--[==[	根据对方指定buff层数来使用指定次数的某个技能	注意:这里释放的技能会无视技能cd 否则这个脚本毫无意义	触发的那个技能将会作为一个触发型技能来进行攻击	参数:	buff_id 用来判断层数的buffid 这个必填	base_num 基础攻击次数 默认是0	min_num 攻击的最少次数 默认是0	num_pre_stack_count 多少层就增加一次次数 默认是1	trigger_skill_id 要触发的技能的id 这个必填	skill_level 技能等级 不填写就跟随这个脚本的技能等级	target_type 目标类型 现在有"target"、"enemy" 填写enemy的话就是全部敌人 默认是target--]==]local TYPE_TARGET = "target"local TYPE_ENEMY = "enemy"local TYPE_SELF = "self"local TYPE_TEAMMATE = "teammate"local TYPE_ACTOR_TARGET = "actor_target"function QSBAttackByBuffNum:_execute(dt)	if self._skill:getRangeType() == QSkill.SINGLE then		self:triggerSingle()	else		self:triggerMultiple()	end	self:finished()endfunction QSBAttackByBuffNum:triggerSingle()	local attakcer = self._attacker	local buff_id = self._options.buff_id --用来判断层数的buffid 这个必填	local attackBaseNum = self._options.base_num or 0 --基础攻击次数 默认是0	local attackMinNum = self._options.min_num or 0 --攻击的最少次数 默认是0	local attackNumPreStackCount = self._options.num_pre_stack_count or 1 --多少层就增加一次次数 默认是1	local skillId = self._options.trigger_skill_id  --要触发的技能的id 这个必填	local skillLevel = self._options.skill_level or self._skill:getSkillLevel() --技能等级 不填写就跟随这个脚本的技能等级	local target_type = self._options.target_type or "target"	local attackMaxNum = self._options.attackMaxNum or 99	local targets = nil	local need_target = true	if nil == buff_id then		assert(false,"buff_id is nil!")		self:finished()		return	end	if nil == skillId then		assert(false,"trigger_skill_id is nil!")		self:finished()		return	end	if target_type == TYPE_ENEMY then		targets = app.battle:getMyEnemies(attakcer)		need_target = false	elseif target_type == TYPE_SELF then		targets = {attakcer}		need_target = false	elseif target_type == TYPE_TEAMMATE then		targets = app.battle:getMyTeammates(attakcer)		need_target = false	elseif target_type == TYPE_TARGET then		targets = {self._target}		need_target = true	elseif target_type == TYPE_ACTOR_TARGET then		targets = {self._attacker:getTarget()}		need_target = true	end	if nil == targets or #targets == 0 then		self:finished()		return	end	local count = 0	for k,attackee in pairs(targets) do		for k,v in pairs(attackee:getBuffs()) do			if v:getId() == buff_id and not v:isImmuned() then				count = count + 1			end		end	end	local attackNum = math.floor(count / attackNumPreStackCount) + attackBaseNum	attackNum = math.clamp(attackNum, attackMinNum, attackMaxNum)	for i = 1,attackNum,1 do		self:attackTarget(attakcer,need_target and targets[1] or nil,skillId,skillLevel)	endendfunction QSBAttackByBuffNum:triggerMultiple()	local attakcer = self._attacker	local buff_id = self._options.buff_id --用来判断层数的buffid 这个必填	local attackBaseNum = self._options.base_num or 0 --基础攻击次数 默认是0	local attackMinNum = self._options.min_num or 0 --攻击的最少次数 默认是0	local attackNumPreStackCount = self._options.num_pre_stack_count or 1 --多少层就增加一次次数 默认是1	local skillId = self._options.trigger_skill_id  --要触发的技能的id 这个必填	local skillLevel = self._options.skill_level or self._skill:getSkillLevel() --技能等级 不填写就跟随这个脚本的技能等级	local targets = nil	if nil == buff_id then		assert(false,"buff_id is nil!")		self:finished()		return	end	if nil == skillId then		assert(false,"trigger_skill_id is nil!")		self:finished()		return	end	targets = self._attacker:getMultipleTargetWithSkill(self._skill, self._target, self._director:getTargetPosition())	if nil == targets or #targets == 0 then		self:finished()		return	end	for k,attackee in pairs(targets) do		local count = 0		for k,v in pairs(attackee:getBuffs()) do			if v:getId() == buff_id and not v:isImmuned() then				count = count + 1			end		end		local attackNum = math.floor(count / attackNumPreStackCount) + attackBaseNum		if attackNum < attackMinNum then			attackNum = attackMinNum		end		for i = 1,attackNum,1 do			self:attackTarget(attakcer, attackee, skillId, skillLevel)		end	endendfunction QSBAttackByBuffNum:attackTarget(attakcer,attackee,skillId,level)	local triggerSkill = attakcer._skills[skillId]	if triggerSkill == nil then        triggerSkill = QSkill.new(skillId, {}, attakcer, level or 1)        triggerSkill:setIsTriggeredSkill(true)        attakcer._skills[skillId] = triggerSkill    end    --这里技能攻击就不考虑cd了    local qsbdirector = attakcer:triggerAttack(triggerSkill, attackee)endreturn QSBAttackByBuffNum