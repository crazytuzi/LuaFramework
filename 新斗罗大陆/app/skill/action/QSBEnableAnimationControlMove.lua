--[[
    Class name QSBEnableAnimationControlMove
    Create by mousecute 
--]]
local QSBAction = import(".QSBAction")
local QSBEnableAnimationControlMove = class("QSBEnableAnimationControlMove", QSBAction)

function QSBEnableAnimationControlMove:_execute(dt)
	self._attacker:enableAnimationControlMove()

	self:finished()
end

function QSBEnableAnimationControlMove:_onRevert()
	self._attacker:disableAnimationControlMove()
end

function QSBEnableAnimationControlMove:_onCancel()
	self._attacker:disableAnimationControlMove()
end

return QSBEnableAnimationControlMove