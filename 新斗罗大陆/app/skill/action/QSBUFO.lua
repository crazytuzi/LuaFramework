--[[
    Class name QSBUFO
    Create by mousecute
--]]

local QSBAction = import(".QSBAction")
local QSBUFO = class("QSBUFO", QSBAction)

local QUFO = import("...models.QUFO")

function QSBUFO:_execute(dt)
	local effectId = self._options.effect_id
	local actor = self._attacker
	local target = self._target
	local ufo = QUFO.new({attacker = actor, attackee = target, speed = self._options.speed, effectId = self._options.effect_id, hitEffectId = self._options.hit_effect_id})
	app.battle:addUFO(ufo)

	self:finished()
end

return QSBUFO