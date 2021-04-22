local QAIAction = import("..base.QAIAction")
local QAIUnionDragonSpecialSkill= class("QAIUnionDragonSpecialSkill", QAIAction)
local QSkill = import("...models.QSkill")
function QAIUnionDragonSpecialSkill:ctor( options )
    QAIUnionDragonSpecialSkill.super.ctor(self, options)
    self:setDesc("宗门武魂上专属技")
end

function QAIUnionDragonSpecialSkill:_execute( args )
    local actor = args.actor
    local dragonId = app.battle:getUnionDragonWarBossId()
	local skillId = db:getUnionDragonConfigById(dragonId).special_skill
	if actor._skills[skillId] == nil then
		local skill = QSkill.new(skillId, {}, actor, 1)
		actor._skills[skillId] = skill
	end
	actor:attack(actor._skills[skillId])
    return true
end

return QAIUnionDragonSpecialSkill