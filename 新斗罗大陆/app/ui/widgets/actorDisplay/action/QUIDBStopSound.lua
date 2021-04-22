--[[
    Class name QUIDBStopSound
    Create by julian 
--]]
local QUIDBAction = import(".QUIDBAction")
local QUIDBStopSound = class("QUIDBStopSound", QUIDBAction)

function QUIDBStopSound:_execute(dt)
	local soundId = self._options.sound_id

	if soundId == nil then
		self:finished()
		return 
	end

	self._director:stopSoundEffectById(soundId)

	self:finished()
end

return QUIDBStopSound