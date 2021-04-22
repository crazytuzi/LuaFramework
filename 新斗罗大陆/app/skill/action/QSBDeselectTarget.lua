--[[
    Class name QSBDeselectTarget
    Create by mousecute 
--]]
local QSBAction = import(".QSBAction")
local QSBDeselectTarget = class("QSBDeselectTarget", QSBAction)

function QSBDeselectTarget:_execute(dt)
	if self._executed then
		return
	end
	self._executed = true

	local actor = self._attacker
	actor:setTarget(self._target)

	self:finished()
end

return QSBDeselectTarget