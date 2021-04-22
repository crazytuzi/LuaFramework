
local QSBAction = import(".QSBAction")
local QSBSuicide = class("QSBSuicide", QSBAction)

function QSBSuicide:_execute(dt)
	local actor = self._attacker
	local no_dead_skill_or_animation = true
	if self._options.use_dead_skill then
		no_dead_skill_or_animation = false
	end
	app.battle:performWithDelay(function() actor:suicide(no_dead_skill_or_animation) end, 0)

	self:finished()
end

return QSBSuicide