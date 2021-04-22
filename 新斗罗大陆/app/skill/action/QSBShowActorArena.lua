
local QSBAction = import(".QSBAction")
local QSBShowActorArena = class("QSBShowActorArena", QSBAction)

function QSBShowActorArena:_execute(dt)
	if not app.battle:isInArena() or (self._attacker and self._attacker:isCopyHero())then
		self:finished()
		return
	end

	local actor = nil
	if self._options.is_attacker == true then
		actor = self._attacker
	else
		actor = self._target
	end

	if self._options.turn_on == true then
		if not IsServerSide then
			app.scene:visibleBackgroundLayer(true, actor, self._options.time, nil, self._attacker:getSuperSkillID() ~= nil)
		end
		app.battle:visibleBackgroundLayer(true, actor)
		self._director:setVisibleSceneBlackLayer(true, actor)
	else
		if not IsServerSide then
			app.scene:visibleBackgroundLayer(false, actor, self._options.time)
		end
		self._director:setVisibleSceneBlackLayer(false)
		app.battle:visibleBackgroundLayer(false, actor)
	end

	if not IsServerSide then
		local scale
		if self._options.turn_on == true then
			scale = 1.2
		else
			scale = 1.0
		end
		self._director:scaleActor(scale, 0.01)
	end
	
	self._executed = true
	self:finished()
end

function QSBShowActorArena:_onCancel()
	self:_onRevert()
end

function QSBShowActorArena:_onRevert()
	if not self._executed then
		return
	end

	self._executed = nil
	local actor = nil
	if self._options.is_attacker == true then
		actor = self._attacker
	else
		actor = self._target
	end
	if self._options.turn_on == true then
		if not IsServerSide then
			app.scene:visibleBackgroundLayer(false, actor, 0)
		end
		self._director:setVisibleSceneBlackLayer(false)
		app.battle:visibleBackgroundLayer(false, actor)
	end
end

return QSBShowActorArena