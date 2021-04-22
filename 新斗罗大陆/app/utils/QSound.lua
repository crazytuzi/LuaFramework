--
-- Author: wkwang
-- Date: 2014-12-13 16:03:06
--
local QSound = class("QSound")
local QStaticDatabase = import("..controllers.QStaticDatabase")
	
function QSound:ctor(options)
	self:reloadSoundConfig()
	self.tutorialSoundHandle = nil -- 用于保存引导妹妹的语音，这样可以防止重叠
end

function QSound:reloadSoundConfig()
	self._soundConfig = QStaticDatabase:sharedDatabase():getSound()
end

function QSound:playSound(soundId, isloop)
    if app:getSystemSetting():getSoundState() ~= "on" then
		return
	end
	self.tutorialSoundHandle = audio.playSound(self:getSoundURLById(soundId), isloop == true, self:getSoundVolume(soundId))
    return self.tutorialSoundHandle
end

function QSound:stopSound(handle)
	if handle then
		audio.stopSound(handle)
		self.tutorialSoundHandle = nil
	end
end

function QSound:preloadSound(soundId)
	audio.preloadSound(self:getSoundURLById(soundId))
end

function QSound:playMusic(soundId)
	local total_volume = (app:getSystemSetting():getMusicState() == "on" and global.music_volume or 0)
	audio.setMusicVolume(total_volume)
    return audio.playMusic(self:getSoundURLById(soundId))
end

function QSound:stopMusic()
	audio.stopMusic()
end

function QSound:pauseMusic()
	audio.pauseMusic()
end

function QSound:resumeMusic()
	audio.resumeMusic()
end

function QSound:raiseMusicVolume(volume)
	local total_volume = (app:getSystemSetting():getMusicState() == "on" and global.sound_volume or 0)
	audio.setMusicVolume(total_volume)
end

function QSound:getSoundURLById(soundId)
	if soundId == nil then
		printError("soundId is nil")
		return nil
	end
	if self._soundConfig == nil then
		printError("QSound._soundConfig not exist")
		return nil
	end

	if self._soundConfig[soundId] == nil then
		-- assert(false, string.format("soundId: %s not in soundConfig !", soundId))
        printError(string.format("soundId: %s not in soundConfig !", soundId))
        return nil
	end
	local soundurl = self._soundConfig[soundId].sound .. ".mp3"
	return soundurl
end

function QSound:getSoundVolume(soundId)
    if soundId == nil or self._soundConfig == nil then
        printError("QSound._soundConfig not exist")
        return 1
    end
    if self._soundConfig[soundId] == nil then
        assert(false, string.format("soundId: %s not in soundConfig !", soundId))
    end
    return self._soundConfig[soundId].volume or 1
end

return QSound