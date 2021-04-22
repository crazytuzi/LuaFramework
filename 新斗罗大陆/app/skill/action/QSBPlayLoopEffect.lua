--[[
    Class name QSBPlayLoopEffect
    Create by julian 
--]]
local QSBPlayEffect = import(".QSBPlayEffect")
local QSBPlayLoopEffect = class("QSBPlayLoopEffect", QSBPlayEffect)

local QActor = import("...models.QActor")

function QSBPlayLoopEffect:_execute(dt)
	local actor = self._attacker
	local effectID = self._options.effect_id or self._skill:getAttackEffectID()

	if IsServerSide then
		self:finished()
		return
	end

	if actor == nil or effectID == nil then
		self:finished()
		return 
	end

	actor:playSkillEffect(effectID, nil, {isLoop = true, attacker = actor, attackee = self._target, followActorAnimation = self._options.follow_actor_animation, followActorPosition = self._options.follow_actor_position})
	self._director:setIsPlayLoopEffect(effectID)

	self:finished()
end

return QSBPlayLoopEffect