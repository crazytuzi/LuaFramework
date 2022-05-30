local GameAudio = {}

function GameAudio.init(...)
	GameAudio.saved = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.HAS_SAVE)
	if not GAME_SETTING.ENABLE_DUB then
		GAME_SETTING.ENABLE_DUB = "enable_dub"
	end
	if GameAudio.saved == false then
		CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.HAS_SAVE, true)
		CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_SFX, true)
		CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_MUSIC, true)
		CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_DUB, true)
		CCUserDefault:sharedUserDefault():flush()
	end
	GameAudio.soundOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_MUSIC)
	GameAudio.sfxOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_SFX)
	if TargetPlatForm ~= PLATFORMS.VN then
		GameAudio.dubOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_DUB, true)
	else
		GameAudio.dubOn = false
	end
	GameAudio.curMusicName = ""
	GameAudio.curMusicIsLoop = false
end

function GameAudio.setSoundEnable(enable)
	CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_MUSIC, enable)
	CCUserDefault:sharedUserDefault():flush()
	GameAudio.soundOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_MUSIC)
end

function GameAudio.setSfxEnable(enable)
	CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_SFX, enable)
	CCUserDefault:sharedUserDefault():flush()
	GameAudio.sfxOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_SFX)
end

function GameAudio.setDubEnable(enable)
	if TargetPlatForm ~= PLATFORMS.VN then
		CCUserDefault:sharedUserDefault():setBoolForKey(GAME_SETTING.ENABLE_DUB, enable)
		CCUserDefault:sharedUserDefault():flush()
		GameAudio.dubOn = CCUserDefault:sharedUserDefault():getBoolForKey(GAME_SETTING.ENABLE_DUB)
	else
		GameAudio.dubOn = false
	end
end

function GameAudio.preloadMusic(filename)
	audio.preloadMusic(filename)
end
local HIT_SOUND = true

function GameAudio.playMusic(filename, isLoop)
	dump(filename)
	if GameAudio.soundOn == true and HIT_SOUND and (GameAudio.curMusicName ~= filename or GameAudio.curMusicIsLoop ~= isLoop) then
		GameAudio.curMusicName = filename
		GameAudio.curMusicIsLoop = isLoop
		audio.stopMusic(true)
		local loop = isLoop or false
		audio.playMusic(filename, loop)
	end
end

function GameAudio.stopMusic(isReleaseData)
	if audio.isMusicPlaying() and HIT_SOUND then
		GameAudio.curMusicName = ""
		audio.stopMusic(isReleaseData)
	end
end

function GameAudio.playSound(filename, isLoop)
	if GameAudio.sfxOn == true and HIT_SOUND then
		local loop = isLoop or false
		return audio.playSound(filename, loop)
	end
end

function GameAudio.palyHeroDub(filename, isLoop)
	if GameAudio.dubOn == true and HIT_SOUND then
		local loop = isLoop or false
		return audio.playSound(filename, loop)
	end
end

-- ²¥·Å±³¾°Òô
function GameAudio.playMainmenuMusic(isLoop)
	local curTime = tonumber(os.date("%H", os.time()))
	local soundName = GAME_SOUND.title_day
	-- Ò¹Íí±³¾°ÏÔÊ¾
	if curTime > 18 or curTime < 6 then
		soundName = GAME_SOUND.title_night
	end
	GameAudio.playMusic(soundName, isLoop)
end

return GameAudio