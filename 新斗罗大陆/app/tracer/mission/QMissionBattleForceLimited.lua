
local QMissionBase = import(".QMissionBase")
local QMissionBattleForceLimited = class("QMissionBattleForceLimited", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionBattleForceLimited:ctor(minimum, maxmum, options)
	self._minimum = minimum
	if self._minimum == nil then
		self._minimum = 0
	end

	self._maxmum = maxmum
	if self._maxmum == nil then
		self._maxmum = 0xffffffff
	end

	QMissionBattleForceLimited.super.ctor(self, QMissionBase.Type_Battle_Force_Limited, options)
end

function QMissionBattleForceLimited:beginTrace()
	local heroes = app.battle:getHeroes()
	local battleForce = 0
	for _, hero in ipairs(heroes) do
		battleForce = battleForce + hero:getBattleForce()
	end

	if battleForce >= self._minimum and battleForce <= self._maxmum then
		self:setCompleted(true)
	end

end

return QMissionBattleForceLimited