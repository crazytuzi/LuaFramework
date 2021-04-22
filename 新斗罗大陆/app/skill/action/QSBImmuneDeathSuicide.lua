
local QSBAction = import(".QSBAction")
local QSBImmuneDeathSuicide = class("QSBImmuneDeathSuicide", QSBAction)

function QSBImmuneDeathSuicide:_execute(dt)
	local actor = self._attacker
	local no_dead_skill_or_animation = true
	if self._options.use_dead_skill then
		no_dead_skill_or_animation = false
	end
	app.battle:performWithDelay(function() 
			local attacker = actor:getLastTriggerImmuneDeathAttacker()
			if attacker and attacker:hasRage() then
	            attacker:changeRage(actor._rageInfo.bekill_rage * attacker._rageInfo.kill_coefficient, nil, true)
	            if app.battle:isPVPMode() then
	                attacker:changeRage(attacker:getActorPropValue("pvp_kill_rage"))
	            end
			end
			actor:suicide(no_dead_skill_or_animation) 
		end, 0)
	self:finished()
end

return QSBImmuneDeathSuicide