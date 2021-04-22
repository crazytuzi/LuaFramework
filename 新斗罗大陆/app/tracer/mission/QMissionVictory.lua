
local QMissionBase = import(".QMissionBase")
local QMissionVictory = class("QMissionVictory", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionVictory:ctor(options)
	QMissionVictory.super.ctor(self, QMissionBase.Type_Victory, options)
end

function QMissionVictory:beginTrace()
	self._eventProxy = cc.EventProxy.new(app.battle)
	self._eventProxy:addEventListener(QBattleManager.WIN, handler(self, self._onWin))
end

function QMissionVictory:endTrace()
	if self._eventProxy then
		self._eventProxy:removeAllEventListeners()
		self._eventProxy = nil
	end
end

function QMissionVictory:_onWin()
	self:setCompleted(true)
end

return QMissionVictory