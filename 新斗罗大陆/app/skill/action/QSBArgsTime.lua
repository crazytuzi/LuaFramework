--[[
    Class name QSBArgsTime
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBArgsTime = class("QSBArgsTime", QSBNode)

function QSBArgsTime:_execute(dt)
	local time = self:getOptions().time
	if type(time) == "table" then
		time = math.sampler2(time[1], time[2], 0, 999999, app.random(0, 999999))
	end
    self:finished({time = time})
end

return QSBArgsTime