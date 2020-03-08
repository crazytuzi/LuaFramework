local audio = {}
local sharedEngine = SimpleAudioEngine:sharedEngine()
function audio.getMusicVolume()
  local volume = sharedEngine:getBackgroundMusicVolume()
  if DEBUG > 1 then
    printInfo("audio.getMusicVolume() - volume: %0.1f", volume)
  end
  return volume
end
function audio.setMusicVolume(volume)
  volume = checknumber(volume)
  if DEBUG > 1 then
    printInfo("audio.setMusicVolume() - volume: %0.1f", volume)
  end
  sharedEngine:setBackgroundMusicVolume(volume)
end
function audio.getSoundsVolume()
  local volume = sharedEngine:getEffectsVolume()
  if DEBUG > 1 then
    printInfo("audio.getSoundsVolume() - volume: %0.1f", volume)
  end
  return volume
end
function audio.setSoundsVolume(volume)
  volume = checknumber(volume)
  if DEBUG > 1 then
    printInfo("audio.setSoundsVolume() - volume: %0.1f", volume)
  end
  sharedEngine:setEffectsVolume(volume)
end
function audio.preloadMusic(filename)
  if not filename then
    printError("audio.preloadMusic() - invalid filename")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.preloadMusic() - filename: %s", tostring(filename))
  end
  sharedEngine:preloadBackgroundMusic(filename)
end
function audio.playMusic(filename, isLoop)
  if not filename then
    printError("audio.playMusic() - invalid filename")
    return
  end
  if type(isLoop) ~= "boolean" then
    isLoop = true
  end
  audio.stopMusic()
  if DEBUG > 1 then
    printInfo("audio.playMusic() - filename: %s, isLoop: %s", tostring(filename), tostring(isLoop))
  end
  sharedEngine:playBackgroundMusic(filename, isLoop)
end
function audio.stopMusic(isReleaseData)
  isReleaseData = checkbool(isReleaseData)
  if DEBUG > 1 then
    printInfo("audio.stopMusic() - isReleaseData: %s", tostring(isReleaseData))
  end
  sharedEngine:stopBackgroundMusic(isReleaseData)
end
function audio.pauseMusic()
  if DEBUG > 1 then
    printInfo("audio.pauseMusic()")
  end
  sharedEngine:pauseBackgroundMusic()
end
function audio.resumeMusic()
  if DEBUG > 1 then
    printInfo("audio.resumeMusic()")
  end
  sharedEngine:resumeBackgroundMusic()
end
function audio.rewindMusic()
  if DEBUG > 1 then
    printInfo("audio.rewindMusic()")
  end
  ending:rewindBackgroundMusic()
end
function audio.willPlayMusic()
  local ret = sharedEngine:willPlayBackgroundMusic()
  if DEBUG > 1 then
    printInfo("audio.willPlayMusic() - ret: %s", tostring(ret))
  end
  return ret
end
function audio.isMusicPlaying()
  local ret = sharedEngine:isBackgroundMusicPlaying()
  if DEBUG > 1 then
    printInfo("audio.isMusicPlaying() - ret: %s", tostring(ret))
  end
  return ret
end
function audio.playSound(filename, isLoop)
  if not filename then
    printError("audio.playSound() - invalid filename")
    return
  end
  if type(isLoop) ~= "boolean" then
    isLoop = false
  end
  if DEBUG > 1 then
    printInfo("audio.playSound() - filename: %s, isLoop: %s", tostring(filename), tostring(isLoop))
  end
  return sharedEngine:playEffect(filename, isLoop)
end
function audio.pauseSound(handle)
  if not handle then
    printError("audio.pauseSound() - invalid handle")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.pauseSound() - handle: %s", tostring(handle))
  end
  sharedEngine:pauseEffect(handle)
end
function audio.pauseAllSounds()
  if DEBUG > 1 then
    printInfo("audio.pauseAllSounds()")
  end
  sharedEngine:pauseAllEffects()
end
function audio.resumeSound(handle)
  if not handle then
    printError("audio.resumeSound() - invalid handle")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.resumeSound() - handle: %s", tostring(handle))
  end
  sharedEngine:resumeEffect(handle)
end
function audio.resumeAllSounds()
  if DEBUG > 1 then
    printInfo("audio.resumeAllSounds()")
  end
  sharedEngine:resumeAllEffects()
end
function audio.stopSound(handle)
  if not handle then
    printError("audio.stopSound() - invalid handle")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.stopSound() - handle: %s", tostring(handle))
  end
  sharedEngine:stopEffect(handle)
end
function audio.stopAllSounds()
  if DEBUG > 1 then
    printInfo("audio.stopAllSounds()")
  end
  sharedEngine:stopAllEffects()
end
function audio.preloadSound(filename)
  if not filename then
    printError("audio.preloadSound() - invalid filename")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.preloadSound() - filename: %s", tostring(filename))
  end
  sharedEngine:preloadEffect(filename)
end
function audio.unloadSound(filename)
  if not filename then
    printError("audio.unloadSound() - invalid filename")
    return
  end
  if DEBUG > 1 then
    printInfo("audio.unloadSound() - filename: %s", tostring(filename))
  end
  sharedEngine:unloadEffect(filename)
end
return audio
