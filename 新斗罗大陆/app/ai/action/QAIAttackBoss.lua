
local QAIAction = import("..base.QAIAction")
local QAIAttackBoss = class("QAIAttackBoss", QAIAction)

function QAIAttackBoss:ctor( options )
    QAIAttackBoss.super.ctor(self, options)
    self:setDesc("优先攻击boss")
end

function QAIAttackBoss:_execute( args )
	local actor = args.actor
    if app.battle:isPVPMode() or app.battle._monsters == nil or actor == nil or actor:isHealth() then return false end
    if actor:getTarget() then
        local target = actor:getTarget()
        if target:isBoss() or target:isEliteBoss() then
            return false
        end
    end
    local boss = nil
    local elite_boss = nil
    for _, monsterInfo in ipairs(app.battle._monsters) do
    	if monsterInfo.created and monsterInfo.npc and monsterInfo.npc:isDead() == false then
	        if monsterInfo.is_boss == true then
	        	boss = monsterInfo.npc
	        	break
	        elseif monsterInfo.is_elite_boss == true then
	        	elite_boss = monsterInfo.npc
	        end
	    end
    end

    local target = boss or elite_boss
    if target then
    	actor:setTarget(target)
    	return true
    end

    return false
end

return QAIAttackBoss