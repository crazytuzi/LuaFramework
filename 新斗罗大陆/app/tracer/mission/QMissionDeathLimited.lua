
local QMissionBase = import(".QMissionBase")
local QMissionDeathLimited = class("QMissionDeathLimited", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionDeathLimited:ctor(minimum, maxmum, options)
	self._minimum = minimum
	if self._minimum == nil then
		self._minimum = 0
	end

	self._maxmum = maxmum
	if self._maxmum == nil then
		self._maxmum = 4
	end

	QMissionDeathLimited.super.ctor(self, QMissionBase.Type_Death_limited, options)
end

function QMissionDeathLimited:beginTrace()
	self._eventProxy = cc.EventProxy.new(app.battle)
	self._eventProxy:addEventListener(QBattleManager.WIN, handler(self, self._onCheck))
	-- self._eventProxy:addEventListener(QBattleManager.HERO_CLEANUP, handler(self, self._onCheck))
	
	--self:_onCheck() -- @qinyuanji - http://jira.joybest.com.cn/browse/WOW-454
end

function QMissionDeathLimited:endTrace()
	if self._eventProxy then
		self._eventProxy:removeAllEventListeners()
		self._eventProxy = nil
	end
end

function QMissionDeathLimited:_onCheck()
	local heroes = app.battle:getDeadHeroes()
	local deathCount = #heroes
	if deathCount >= self._minimum and deathCount <= self._maxmum then
		self:setCompleted(true)
	else
		self:setCompleted(false)
	end
end

return QMissionDeathLimited