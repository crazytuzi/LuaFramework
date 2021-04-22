
local QSBAction = import(".QSBAction")
local QSBBulletTimeArena = class("QSBBulletTimeArena", QSBAction)

local QBattleManager = import("...controllers.QBattleManager")

function QSBBulletTimeArena:_execute(dt)
	if not app.battle:isInArena() or (self._attacker and self._attacker:isCopyHero()) then
		self:finished()
		return
	end

	if self._options.turn_on == true and not self._director:isInBulletTime() then
		app.battle:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_ON, actor = self._attacker})
		self._director:setIsInBulletTime(true)
	elseif not self._options.turn_on and self._director:isInBulletTime() then
		app.battle:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_OFF, actor = self._attacker})
		self._director:setIsInBulletTime(false)
	end
	self._executed = true
	self:finished()
end

function QSBBulletTimeArena:_onCancel()
	self:_onRevert()
end

function QSBBulletTimeArena:_onRevert()
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
		app.battle:dispatchEvent({name = QBattleManager.EVENT_BULLET_TIME_TURN_OFF, actor = self._attacker})
		self._director:setIsInBulletTime(false)
	end
end

return QSBBulletTimeArena