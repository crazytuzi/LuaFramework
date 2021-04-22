
local QMissionBase = import(".QMissionBase")
local QMissionVictoryTimeLimited = class("QMissionVictoryTimeLimited", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionVictoryTimeLimited:ctor(minimum, maxmum, options)
	self._minimum = minimum
	if self._minimum == nil then
		self._minimum = 0
	end

	self._maxmum = maxmum
	if self._maxmum == nil then
		self._maxmum = app.battle:getDungeonDuration()
	end

	QMissionVictoryTimeLimited.super.ctor(self, QMissionBase.Type_Victory_Time_Limited, options)
end

function QMissionVictoryTimeLimited:beginTrace()
	self._eventProxy = cc.EventProxy.new(app.battle)
	self._eventProxy:addEventListener(QBattleManager.WIN, handler(self, self._onWin))
end

function QMissionVictoryTimeLimited:endTrace()
	if self._eventProxy then
		self._eventProxy:removeAllEventListeners()
		self._eventProxy = nil
	end
end

function QMissionVictoryTimeLimited:_onWin()
	local timeLeft = app.battle:getTimeLeft()
	local fullTime = app.battle:getDungeonDuration()
	local timePssed = fullTime - timeLeft
	if timePssed >= self._minimum and timePssed <= self._maxmum then
		self:setCompleted(true)
	end
end

return QMissionVictoryTimeLimited