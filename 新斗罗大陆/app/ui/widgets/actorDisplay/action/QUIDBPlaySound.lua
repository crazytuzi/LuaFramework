--[[
    Class name QUIDBPlaySound
    Create by julian 
--]]
local QUIDBAction = import(".QUIDBAction")
local QUIDBPlaySound = class("QUIDBPlaySound", QUIDBAction)

local QSoundEffect = import(".....utils.QSoundEffect")

function QUIDBPlaySound:_execute(dt)
	local soundId = self._options.sound_id
	local isLoop =  self._options.is_loop or false

	if soundId == nil then
		self:finished()
		return 
	end

	local soundEffect = QSoundEffect.new(soundId)
	soundEffect:play(isLoop)
	self._director:addSoundEffect(soundEffect)

	self:finished()
end

return QUIDBPlaySound