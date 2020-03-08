local Lplus = require("Lplus")
local EC = require("Types.Vector3")
local CG = require("CG.CG")
local ECSoundMan = Lplus.Class("ECSoundMan")
local def = ECSoundMan.define
def.field("userdata").m_listener = nil
def.field("userdata").m_BgMusic = nil
def.field("number").m_bgMusicTimeID = 0
def.field("userdata").m_guiInterruptSound = nil
def.field("table").m_uiPlaySounds = function()
  return {}
end
_G.SOUND_TYPES = {
  GUI = "ui",
  ENVIRONMENT = "enviroment",
  BACKGROUND = "background",
  CG = "cg",
  GUI_INTERRUPT = "uiInterrupt",
  FIGHT = "fight"
}
local s_man
local s_volume = {}
def.static("=>", ECSoundMan).Instance = function()
  if not s_man then
    s_man = ECSoundMan()
  end
  return s_man
end
def.method().Init = function(self)
  if SoundCacheMan.set_goPrefab then
    SoundCacheMan.goPrefab = Resources.Load("sound/SoundAudioSource")
  end
  if not CG.Instance().isInArtEditor then
    local go
    if SoundCacheMan.set_goPrefab and SoundCacheMan.goPrefab then
      go = Object.Instantiate(SoundCacheMan.goPrefab, "GameObject")
      go.name = "listener"
    else
      go = GameObject.GameObject("listener")
    end
    go:AddComponent("AudioListener")
    self.m_listener = go
  end
  GameUtil.SetSoundMaxCount(SOUND_TYPES.GUI, 1)
  GameUtil.SetSoundMaxCount(SOUND_TYPES.ENVIRONMENT, 5)
  GameUtil.SetSoundMaxCount(SOUND_TYPES.BACKGROUND, 1)
  GameUtil.SetSoundMaxCount(SOUND_TYPES.CG, 2)
  GameUtil.SetSoundMaxCount(SOUND_TYPES.GUI_INTERRUPT, 1)
  ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, 1)
end
def.method("userdata").AttachListenerTo = function(self, parent)
  if self.m_listener ~= nil and parent ~= nil then
    self.m_listener.parent = parent
    self.m_listener.localPosition = EC.Vector3.new(0, 0, 0)
  end
end
def.static("string", "number").SetVolume = function(soundType, v)
  local found = false
  for k, v in pairs(SOUND_TYPES) do
    if soundType == v then
      found = true
    end
  end
  if not found then
    local isFightType = string.find(soundType, "fight%d")
    if not isFightType then
      warn("param soundType is wrong")
      return
    end
  end
  s_volume[soundType] = v
  GameUtil.SetSoundVolume(soundType, v)
end
def.static("string", "=>", "number").GetVolume = function(soundType)
  local found = false
  for k, v in pairs(SOUND_TYPES) do
    if soundType == v then
      found = true
    end
  end
  if found then
    local v = s_volume[soundType]
    v = v or 1
    return v
  else
    return 100
  end
end
def.method("string", "boolean").PlayBackgroundMusic = function(self, soundName, isLoop)
  self:StopBackgroundMusic(1)
  local soundone = GameUtil.RequestSound(soundName, SOUND_TYPES.BACKGROUND, 5)
  if soundone then
    soundone:Play(0, isLoop, nil)
  end
  self.m_BgMusic = soundone
end
def.method("string", "boolean", "function").PlayBackgroundMusicWithCallback = function(self, soundName, isLoop, cb)
  self:StopBackgroundMusic(1)
  local soundone = GameUtil.RequestSound(soundName, SOUND_TYPES.BACKGROUND, 5)
  if soundone then
    soundone:Play(2, isLoop, cb)
  end
  self.m_BgMusic = soundone
end
def.method("string", "number").PlayBackgroundMusicWithDelay = function(self, soundName, delay)
  self:StopBackgroundMusic(1)
  local soundone = GameUtil.RequestSound(soundName, SOUND_TYPES.BACKGROUND, 5)
  if soundone then
    soundone:Play(2, false, function(isover)
      if isover then
        if delay > 0 then
          self.m_bgMusicTimeID = GameUtil.AddGlobalTimer(delay, true, function()
            self:PlayBackgroundMusicWithDelay(soundName, delay)
          end)
        else
          self:PlayBackgroundMusicWithDelay(soundName, delay)
        end
      end
    end)
  end
  self.m_BgMusic = soundone
end
def.method("number").StopBackgroundMusic = function(self, fadetime)
  if self.m_BgMusic and not self.m_BgMusic.isnil then
    self.m_BgMusic:Stop(fadetime)
    self.m_BgMusic = nil
  end
  if self.m_bgMusicTimeID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_bgMusicTimeID)
    self.m_bgMusicTimeID = 0
  end
end
def.method("number", "number", "table").PlayerDeathCry = function(self, prof, gender, pos)
  local SoundData = require("Data.SoundData")
  local cfg = SoundData.Instance():GetPlayerDeathCryCfg(prof, gender)
  if cfg ~= nil then
    self:Play3DSound(cfg[1], pos)
  end
end
def.method("number", "number", "table").PlayerHowl = function(self, prof, gender, pos)
  local SoundData = require("Data.SoundData")
  local cfg = SoundData.Instance():GetPlayerHowlSoundCfg(prof, gender)
  if cfg ~= nil then
    self:Play3DSound(cfg[1], pos)
  end
end
local ECObject = Lplus.ForwardDeclare("ECObject")
def.method("number", ECObject).PlayCastSkillSound = function(self, id, caster)
  local SoundData = require("Data.SoundData")
  local cfg = SoundData.Instance():GetSoundInfo(id)
  if cfg ~= nil and #cfg == 4 then
    do
      local delay = cfg[3] / 1000
      local pos = caster:GetPos()
      if delay <= 0 then
        self:Play3DSound(cfg[1], pos)
      else
        GameUtil.AddTimer(caster:GetGameObject(), delay, true, function()
          self:Play3DSound(cfg[1], pos)
        end)
      end
    end
  end
end
def.method("number", "table").Play3DSoundByID = function(self, id, pos)
  local SoundData = require("Sound.SoundData")
  local path = SoundData.Instance():GetSoundPath(id)
  if path ~= nil then
    self:Play3DSound(path, pos)
  end
end
def.method("string", "table", "=>", "userdata").Play3DSound = function(self, soundName, pos)
  return self:Play3DSoundEx(soundName, pos, SOUND_TYPES.ENVIRONMENT, 10)
end
def.method("number").Play2DSoundByID = function(self, id)
  local SoundData = require("Sound.SoundData")
  local path = SoundData.Instance():GetSoundPath(id)
  if path ~= nil then
    self:Play2DSound(path)
  end
end
def.method("string", "=>", "userdata").Play2DSound = function(self, soundName)
  return self:Play2DSoundEx(soundName, SOUND_TYPES.GUI, 10)
end
def.method("number", "=>", "userdata").Play2DInterruptSoundByID = function(self, id)
  local SoundData = require("Sound.SoundData")
  local path = SoundData.Instance():GetSoundPath(id)
  if path ~= nil then
    return self:Play2DInterruptSound(path)
  end
  return nil
end
def.method("string", "=>", "userdata").Play2DInterruptSound = function(self, soundName)
  if self.m_guiInterruptSound and not self.m_guiInterruptSound.isnil then
    self.m_guiInterruptSound:Stop(0)
    self.m_guiInterruptSound = nil
  end
  self.m_guiInterruptSound = self:Play2DSoundExWithCallback(soundName, SOUND_TYPES.GUI_INTERRUPT, 9, function(isOver)
    if isOver then
      self.m_guiInterruptSound = nil
    end
  end)
  return self.m_guiInterruptSound
end
def.method("string", "string", "number", "=>", "userdata").Play2DSoundEx = function(self, soundName, soundType, priority)
  local soundone = GameUtil.RequestSound(soundName, soundType, priority)
  if soundone then
    soundone:Play(0, false)
  end
  return soundone
end
def.method("string", "string", "number", "function", "=>", "userdata").Play2DSoundExWithCallback = function(self, soundName, soundType, priority, callback)
  local soundone = GameUtil.RequestSound(soundName, soundType, priority)
  if soundone then
    soundone:Play(0, false, callback)
  end
  return soundone
end
def.method("string", "string", "number", "table", "=>", "userdata").Play2DSoundWithExParams = function(self, soundName, soundType, priority, params)
  local soundone = GameUtil.RequestSound(soundName, soundType, priority)
  params = params or {}
  local fadeTime = params.fadeTime or 0
  local loop = params.loop or false
  local callback = params.callback or nil
  if soundone then
    soundone:Play(fadeTime, loop, callback)
  end
  return soundone
end
def.method("string", "table", "string", "number", "=>", "userdata").Play3DSoundEx = function(self, soundName, pos, soundType, priority)
  local soundone = GameUtil.RequestSound(soundName, soundType, priority)
  if soundone then
    soundone.gameObject.position = pos
    soundone:Play(0, false)
  end
  return soundone
end
def.method("number").SetUIPlaySoundVolume = function(self, volume)
  NGUITools.soundVolume = volume
end
ECSoundMan.Commit()
return ECSoundMan
