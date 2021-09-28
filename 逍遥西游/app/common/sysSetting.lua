local initMusicAndSound = function()
  local music = getConfigByName("music")
  local sound = getConfigByName("sound")
  soundManager.Init(music ~= "0", sound ~= "0")
end
function sysIsMusicOn()
  return getConfigByName("music") ~= "0"
end
function sysIsSoundOn()
  return getConfigByName("sound") ~= "0"
end
function saveMusicAndSound(music, sound)
  if music then
    setConfigData("music", "1", false)
  else
    setConfigData("music", "0", false)
  end
  if sound then
    setConfigData("sound", "1", true)
  else
    setConfigData("sound", "0", true)
  end
end
initMusicAndSound()
