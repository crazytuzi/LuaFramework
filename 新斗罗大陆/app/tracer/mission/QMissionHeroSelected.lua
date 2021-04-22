
local QMissionBase = import(".QMissionBase")
local QMissionHeroSelected = class("QMissionHeroSelected", QMissionBase)

local QBattleManager = import("...controllers.QBattleManager")

function QMissionHeroSelected:ctor(heroIds, options)
	self._heroIds = heroIds
	if self._heroIds == nil then
		self._heroIds = {}
	end
	QMissionHeroSelected.super.ctor(self, QMissionBase.Type_Hero_Selected, options)
end

function QMissionHeroSelected:beginTrace()
	if #self._heroIds == 0 then
		return
	end

	local heroes = app.battle:getHeroes()
	local isAllHeroSelected = true
	for _, id in ipairs(self._heroIds) do

		local selectHero = nil

		for _, hero in ipairs(heroes) do
			local heroId = hero:getActorID()
			if id == heroId then
				selectHero = hero
				break
			end 
		end

		if selectHero == nil then
			isAllHeroSelected = false
			break
		end
	end
	
	if isAllHeroSelected == true then
		self:setCompleted(true)
	end

end

return QMissionHeroSelected