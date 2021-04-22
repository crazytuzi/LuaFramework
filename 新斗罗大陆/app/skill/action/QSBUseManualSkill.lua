local QSBAction = import(".QSBAction")
local QSBUseManualSkill = class("QSBUseManualSkill", QSBAction)

function QSBUseManualSkill:_execute(dt)
	if self._director._is_triggered then
		self:finished()
		return
	end 
	
	local skill = self._skill
	local actor = self._attacker

	if skill:isNeedComboPoints() then
		actor:consumeComboPoints()
	end

	if skill:isNeedRage() or actor:isSupportHero() then
        actor:consumeRage()
    end

    actor:triggerPassiveSkill(skill.TRIGGER_CONDITION_USE_MANUAL_SKILL, self._target) -- 即将使用手动技能
    if actor:isHero() and not actor:isSupportHero() then
	    for i,enemy in ipairs(app.battle:getMyEnemies(actor)) do
	        enemy:triggerPassiveSkill(skill.TRIGGER_CONDITION_ENEMY_HERO_USE_SKILL, actor)
	    end
	end

	self:finished()
end

return QSBUseManualSkill