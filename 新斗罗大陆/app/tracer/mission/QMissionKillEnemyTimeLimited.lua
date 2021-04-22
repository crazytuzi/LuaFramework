
local QMissionBase = import(".QMissionBase")
local QMissionKillEnemyTimeLimited = class("QMissionKillEnemyTimeLimited", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionKillEnemyTimeLimited:ctor(actorId, timeLimited, options)
	self._actorId = actorId
	self._timeLimited = timeLimited
	if self._timeLimited == nil then
		self._timeLimited = app.battle:getDungeonDuration()
	end

	QMissionKillEnemyTimeLimited.super.ctor(self, QMissionBase.Type_Kill_Enemy_Time_Limited, options)
end

function QMissionKillEnemyTimeLimited:beginTrace()
	self._eventProxy = cc.EventProxy.new(app.battle)
	self._eventProxy:addEventListener(QBattleManager.NPC_CLEANUP, handler(self, self._onNpcCleanUp))
end

function QMissionKillEnemyTimeLimited:endTrace()
	if self._eventProxy then
		self._eventProxy:removeAllEventListeners()
		self._eventProxy = nil
	end
end

function QMissionKillEnemyTimeLimited:_onNpcCleanUp(event)
	if self._actorId == nil then
		return
	end

	local enemy = event.npc
	if enemy ~= nil then
		if enemy:getActorID() == self._actorId then
			local timeLeft = app.battle:getTimeLeft()
			local fullTime = app.battle:getDungeonDuration()
			local timePssed = fullTime - timeLeft
			if timePssed < self._timeLimited then
				self:setCompleted(true)
			end
		end
	end
end

return QMissionKillEnemyTimeLimited