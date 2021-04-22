--[[
    Class name QSBShakeScreen
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBShakeScreen = class("QSBShakeScreen", QSBAction)

function QSBShakeScreen:_execute(dt)
	if IsServerSide then
		self:finished()
		return
	end

	local options = self:getOptions()
	local amplitude = options.amplitude
	local duration = options.duration
	local count = options.count
	local model = options.type
	app.scene:shakeScreen(amplitude, duration, count, model)

	self:finished()
end

return QSBShakeScreen