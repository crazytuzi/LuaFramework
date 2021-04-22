
local QBaseTracer = import("..QBaseTracer")
local QMissionBase = class("QMissionBase", QBaseTracer)

local QNotificationCenter = import("...controllers.QNotificationCenter")

QMissionBase.Type_Battle_Force_Limited = "战斗力限制"
QMissionBase.Type_Death_limited = "死亡人数限制"
QMissionBase.Type_Hero_Selected = "上阵魂师限制"
QMissionBase.Type_Kill_Enemy_Time_Limited = "击杀时间限制"
QMissionBase.Type_Victory = "关卡胜利"
QMissionBase.Type_Victory_Time_Limited = "关卡时间限制"

QMissionBase.COMPLETE_STATE_CHANGE = "QMISSIONBASE_COMPLETE_STATE_CHANGE"

function QMissionBase:ctor(type, options)
	QMissionBase.super.ctor(self, type, options)

	self._description = options.description
	self._isComplete = false
end

function QMissionBase:isCompleted()
	return self._isComplete
end

function QMissionBase:getDescription()
	return self._description or ""
end

function QMissionBase:setCompleted(isComplete)
	if self._isComplete ~= isComplete then
		self._isComplete = isComplete
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMissionBase.COMPLETE_STATE_CHANGE, mission = self})
	end
end

return QMissionBase