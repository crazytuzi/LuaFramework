local QSBAction = import(".QSBAction")
local QSBPlayWarningZone = class("QSBPlayWarningZone", QSBAction)

function QSBPlayWarningZone:_execute(dt)
	local options = self:getOptions()
	local duration = options.duration

	if IsServerSide then
		self:finished()
		return
	end

	assert(type(duration) == "number" and duration > 0, "QSBPlayWarningZone: duration error")

	if self._isExecuting ~= true then
		local position = {}
		if self._skill:getSectorCenter() == self._skill.SELF then
			position = self._attacker:getPosition()
		else
			position = self._director:getTargetPosition()
		end

		self._effect = app.scene:displayWarningZone(options.effect_id, position, self._skill:getSectorRadius() * global.pixel_per_unit, duration, cc.c4f(1, 1, 1, 0.2), 1.0, 1.12, 360)
		self._effect:retain()
		self._isExecuting = true
		self._start_arean_time = app.battle:getDungeonDuration() - app.battle:getTimeLeft()
	else
		if app.battle:getDungeonDuration() - app.battle:getTimeLeft() - self._start_arean_time >= duration then	
			self._effect:release()
			self._effect = nil
			self:finished()
		end
	end
end

function QSBPlayWarningZone:_onCancel()
	if self._isExecuting and self._effect then
		if self._effect:getParent() then
			self._effect:removeFromParent()
		end
		self._effect:release()
		self._effect = nil
		self._isExecuting = false
	end
end

return QSBPlayWarningZone