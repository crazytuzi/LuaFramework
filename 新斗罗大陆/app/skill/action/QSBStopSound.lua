--[[
    Class name QSBStopSound
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBStopSound = class("QSBStopSound", QSBAction)

function QSBStopSound:_execute(dt)
	local soundId = self._options.sound_id

	if soundId == nil then
		self:finished()
		return 
	end

	if not IsServerSide then
		self._director:stopSoundEffectById(soundId)
	end

	self:finished()
end

return QSBStopSound