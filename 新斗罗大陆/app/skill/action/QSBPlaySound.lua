--[[
    Class name QSBPlaySound
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBPlaySound = class("QSBPlaySound", QSBAction)

local QSoundEffect
if not IsServerSide then
	QSoundEffect = import("...utils.QSoundEffect")
end

function QSBPlaySound:_execute(dt)
	local soundId = self._options.sound_id or self._skill:getSound()
	local isLoop =  self._options.is_loop or false
	local sound_delay = self._options.sound_delay

	if soundId == nil then
		self:finished()
		return 
	end

	if not IsServerSide then
		local soundEffect = QSoundEffect.new(soundId, {isInBattle = true, effectDelay =  sound_delay or self._skill:getSoundDelay()})
		soundEffect:play(isLoop)
		self._director:addSoundEffect(soundEffect)
	end

	self:finished()
end

function QSBPlaySound:_onRevert()
	local soundId = self._options.sound_id or self._skill:getSound()
	if not IsServerSide then
		self._director:stopSoundEffectById(soundId)
	end
end

return QSBPlaySound