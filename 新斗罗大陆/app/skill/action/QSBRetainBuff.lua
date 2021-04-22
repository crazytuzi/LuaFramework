--[[
    Class name QSBRetainBuff
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBRetainBuff = class("QSBRetainBuff", QSBAction)

function QSBRetainBuff:_execute(dt)
	self._director:retainBuff(self:getOptions().buff_id)

	self:finished()
end

return QSBRetainBuff