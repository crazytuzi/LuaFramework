--[[
    Class name QSBReleaseBuff
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBReleaseBuff = class("QSBReleaseBuff", QSBAction)

function QSBReleaseBuff:_execute(dt)
	self._director:releaseBuff(self:getOptions().buff_id)

	self:finished()
end

return QSBReleaseBuff