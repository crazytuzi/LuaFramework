--[[
    Class name QSBDisableAnimationControlMove
    Create by mousecute 
--]]
local QSBAction = import(".QSBAction")
local QSBDisableAnimationControlMove = class("QSBDisableAnimationControlMove", QSBAction)

function QSBDisableAnimationControlMove:_execute(dt)
	self._attacker:disableAnimationControlMove()

	self:finished()
end

return QSBDisableAnimationControlMove