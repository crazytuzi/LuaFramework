
local QSBAction = import(".QSBAction")
local QSBAnimationScale = class("QSBAnimationScale", QSBAction)

function QSBAnimationScale:_execute(dt)
	if app.battle:isPVPMode() or (self._attacker and self._attacker:isCopyHero()) then
		self:finished()
		return
	end

	if self._attacker:getType() == ACTOR_TYPES.NPC then
		self:finished()
		return
	end

	if self._options.turn_on == true then
		self._attacker:setAnimationScale(0.0, QSBAnimationScale)
	elseif not self._options.turn_on then
		self._attacker:setAnimationScale(1.0, QSBAnimationScale)
	end
	self._executed = true
	self:finished()
end

function QSBAnimationScale:_onCancel( ... )
	-- body
	if self._options.turn_on == true then
		self._attacker:setAnimationScale(1.0, QSBAnimationScale)
	end
end

function QSBAnimationScale:_onRevert( ... )
	-- body
	self:_onCancel()
end

return QSBAnimationScale