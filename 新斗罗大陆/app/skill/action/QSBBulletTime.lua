
local QSBAction = import(".QSBAction")
local QSBBulletTime = class("QSBBulletTime", QSBAction)

local QBattleManager = import("...controllers.QBattleManager")

function QSBBulletTime:_execute(dt)
	-- if app.battle:isPVPMode() then
	-- 	self:finished()
	-- 	return
	-- end

	if (self._attacker:getType() == ACTOR_TYPES.NPC and not app.battle:isPVPMode()) or
		app.battle:isInArena() or self._attacker:isCopyHero() then
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

return QSBBulletTime