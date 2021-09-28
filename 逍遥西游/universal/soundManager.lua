soundManager = {}
SOUND_PATH_EQUIP_UPGRADE_F = "xiyou/sound/equip_upgrade_f.wav"
SOUND_PATH_EQUIP_UPGRADE_S = "xiyou/sound/equip_upgrade_s.wav"
SOUND_PATH_USEDRUG = "xiyou/sound/war_usedrug.wav"
local curBackgourdMusic = ""
local soundControlDict = {}
gamereset.registerResetFunc(function()
  soundManager.ClearAllMusic()
end)
local enableMusic = true
local enableSound = true
local disableSoundTemp = false
local isPlayingVideo = false
local musicVolume, soundsVolume
function soundManager.Init(musicFlag, soundFlag)
  enableMusic = musicFlag
  enableSound = soundFlag
  if not enableMusic then
    audio.stopMusic(true)
  end
  if not enableSound then
    audio.stopAllSounds()
  end
  soundManager.__background = false
end
function soundManager.OnEnterBackroundFlush()
  print("--->>暂停所有音乐音效")
  soundManager.__background = true
  soundManager.pauseMusicAndSound()
end
function soundManager.OnEnterForeroundFlush()
  print("--->>恢复所有音乐音效")
  soundManager.__background = false
  soundManager.resumeMusicAndSound()
end
function soundManager.EnabledMusic()
  if enableMusic then
    return
  end
  if soundManager.__background == true then
    return
  end
  enableMusic = true
  if musicVolume ~= nil and musicVolume > 0 then
    audio.setMusicVolume(musicVolume)
    musicVolume = nil
  end
  if curBackgourdMusic ~= "" then
    audio.playMusic(curBackgourdMusic, true)
  end
end
function soundManager.DisabledMusic()
  if not enableMusic then
    return
  end
  enableMusic = false
  musicVolume = audio.getMusicVolume()
  audio.setMusicVolume(0)
  audio.stopMusic(true)
end
function soundManager.EnabledSound()
  if enableSound then
    return
  end
  if soundManager.__background == true then
    return
  end
  enableSound = true
  if soundsVolume ~= nil then
    audio.setSoundsVolume(soundsVolume)
    soundsVolume = nil
  end
end
function soundManager.DisabledSound()
  if not enableSound then
    return
  end
  enableSound = false
  soundsVolume = audio.getSoundsVolume()
  audio.setSoundsVolume(0)
  audio.stopAllSounds()
end
function soundManager.DisabledSoundTemp()
  if not enableSound then
    return
  end
  disableSoundTemp = true
  soundsVolume = audio.getSoundsVolume()
  audio.setSoundsVolume(0)
  audio.stopAllSounds()
end
function soundManager.resumeSoundTemp()
  if not enableSound then
    return
  end
  if soundManager.__background == true then
    return
  end
  disableSoundTemp = false
  if soundsVolume ~= nil then
    audio.setSoundsVolume(soundsVolume)
    soundsVolume = nil
  end
end
function soundManager.setIsPlayingVideo(isPlaying)
  isPlayingVideo = isPlaying
  if isPlayingVideo then
    musicVolume = audio.getMusicVolume()
    soundManager.pauseMusic()
  else
    if soundManager.__background == true then
      return
    end
    audio.resumeMusic()
    if musicVolume ~= nil and musicVolume > 0 then
      audio.setMusicVolume(musicVolume)
      musicVolume = nil
    end
    if curBackgourdMusic ~= "" then
      audio.playMusic(curBackgourdMusic, true)
    end
  end
end
function soundManager.setSoundsVolume(soundsVolume)
  audio.setSoundsVolume(soundsVolume)
end
function soundManager.setMusicVolume(musicVolume)
  audio.setMusicVolume(musicVolume)
end
function soundManager.ClearAllMusic()
  curBackgourdMusic = ""
  soundControlDict = {}
  audio.stopMusic(true)
end
function soundManager.ClearAllSound()
  audio.stopAllSounds()
end
function soundManager.preloadMusic(musicPath)
  if not enableMusic then
    return
  end
  if soundManager.__background == true then
    return
  end
  return audio.preloadMusic(musicPath)
end
function soundManager.playMusic(musicPath, isRepeat)
  if isPlayingVideo then
    return
  end
  if not enableMusic then
    return
  end
  if soundManager.__background == true then
    return
  end
  if isRepeat == nil then
    isRepeat = true
  end
  return audio.playMusic(musicPath, isRepeat)
end
function soundManager.playBackgroundMusic(musicPath)
  if curBackgourdMusic == musicPath then
    return
  end
  if soundManager.__background == true then
    return
  end
  curBackgourdMusic = musicPath
  if isPlayingVideo then
    return
  end
  return soundManager.playMusic(musicPath, true)
end
function soundManager.playSceneMusic(mapId)
  if soundManager.__background == true then
    return
  end
  if g_WarScene then
    return
  end
  if mapId == nil then
    mapId = g_MapMgr:getCurMapId()
  end
  if mapId ~= nil then
    local musicPath = data_getSceneMusicPath(mapId)
    if g_HunyinMgr and mapId == MapId_Changan and g_HunyinMgr:IsInXunYouTime() then
      musicPath = "scene_marry.mp3"
    end
    if musicPath and musicPath ~= "0" then
      musicPath = string.format("xiyou/sound/%s", musicPath)
      if g_WarScene ~= nil then
        return
      end
      soundManager.playBackgroundMusic(musicPath)
    end
  end
end
function soundManager.playBattleMusic_PVE()
  soundManager.playBackgroundMusic("xiyou/sound/battle_pve.mp3")
end
function soundManager.playBattleMusic_PVP()
  soundManager.playBackgroundMusic("xiyou/sound/battle_pvp.mp3")
end
function soundManager.playLoginMusic()
  soundManager.playBackgroundMusic("xiyou/sound/login.mp3")
end
function soundManager.pauseMusicAndSound()
  if enableMusic then
    audio.pauseMusic()
  end
  if enableSound then
    audio.pauseAllSounds()
  end
end
function soundManager.pauseMusic()
  if enableMusic then
    audio.pauseMusic()
  end
end
function soundManager.resumeMusicAndSound()
  if soundManager.__background == true then
    return
  end
  if soundManager.__background == true then
    return
  end
  if enableMusic and isPlayingVideo == false then
    audio.resumeMusic()
  else
    audio.setMusicVolume(0)
    audio.stopMusic(true)
  end
  if enableSound then
    audio.resumeAllSounds()
  else
    audio.stopAllSounds()
  end
end
function soundManager.preloadTheMusic(musicPath)
  audio.preloadMusic(musicPath)
end
function soundManager.preloadTheSound(soundPath)
  audio.preloadSound(soundPath)
end
function soundManager.playSound(soundPath, isRepeat)
  if not enableSound then
    return
  end
  if disableSoundTemp then
    return
  end
  if soundManager.__background == true then
    return
  end
  if isRepeat == nil then
    isRepeat = false
  end
  local t = soundControlDict[soundPath] or 0
  local currTime = cc.net.SocketTCP.getTime()
  if currTime - t < 0.1 then
    return
  end
  soundControlDict[soundPath] = currTime
  return audio.playSound(soundPath, isRepeat)
end
function soundManager.playWarSound(soundPath)
  if not enableSound then
    return
  end
  if disableSoundTemp then
    return
  end
  scheduler.performWithDelayGlobal(function()
    if not enableSound then
      return
    end
    if disableSoundTemp then
      return
    end
    soundPath = string.format("xiyou/sound/%s", soundPath)
    soundManager.playSound(soundPath, false)
  end, 0.06)
end
function soundManager.playShapeDlgSound(shapeID)
  if not enableSound then
    return
  end
  if disableSoundTemp then
    return
  end
  local soundPath = data_getBodyDlgSoundPath(shapeID)
  if soundPath ~= nil then
    scheduler.performWithDelayGlobal(function()
      if not enableSound then
        return
      end
      if disableSoundTemp then
        return
      end
      soundManager.playSound(soundPath, false)
    end, 0.4)
  end
end
