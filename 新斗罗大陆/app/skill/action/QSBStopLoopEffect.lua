--[[
    Class name QSBStopLoopEffect
    Create by julian 
--]]


local QSBAction = import(".QSBAction")
local QSBStopLoopEffect = class("QSBStopLoopEffect", QSBAction)

local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QSBStopLoopEffect:_execute(dt)
	local actor = self._attacker
	local effectID = self._options.effect_id or self._skill:getAttackEffectID()

	if not IsServerSide then
		if actor ~= nil and effectID ~= nil then
			actor:stopSkillEffect(effectID)
			self._director:setIsPlayLoopEffect(nil)
		end
	end

	self:finished()
end

return QSBStopLoopEffect