local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SoundModule = Lplus.Extend(ModuleBase, "SoundModule")
local SystemSettingModule = Lplus.ForwardDeclare("SystemSettingModule")
local ECSoundMan = Lplus.ForwardDeclare("ECSoundMan")
local MathHelper = require("Common.MathHelper")
local def = SoundModule.define
def.field("number").m_globalVolume = 1
local instance
def.static("=>", SoundModule).Instance = function()
  if instance == nil then
    instance = SoundModule()
    instance.m_moduleId = ModuleId.SOUND
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, SoundModule.OnSettingChanged)
end
def.override().LateInit = function(self)
  self:InitSoundSettings()
end
def.method().InitSoundSettings = function(self)
  self:UpdateBGMusicSetting()
  self:UpdateEffectSoundSetting()
end
def.static("table", "table").OnSettingChanged = function(params)
  local id = params[1]
  if id == SystemSettingModule.SystemSetting.BGMusic then
    instance:UpdateBGMusicSetting()
  elseif id == SystemSettingModule.SystemSetting.EffectSound then
    instance:UpdateEffectSoundSetting()
  end
end
def.method("number").SetGlobalVolume = function(self, volume)
  self.m_globalVolume = MathHelper.Clamp(volume, 0, 1)
  self:UpdateBGMusicSetting()
  self:UpdateEffectSoundSetting()
end
def.method().UpdateBGMusicSetting = function(self)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.BGMusic)
  local volume
  if setting.mute then
    volume = 0
  else
    volume = setting.volume
  end
  volume = volume * self.m_globalVolume
  ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, volume)
  ECSoundMan.SetVolume(SOUND_TYPES.CG, volume)
end
def.method().UpdateEffectSoundSetting = function(self)
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.EffectSound)
  local volume
  if setting.mute then
    volume = 0
  else
    volume = setting.volume
  end
  volume = volume * self.m_globalVolume
  ECSoundMan.Instance():SetUIPlaySoundVolume(volume)
  ECSoundMan.SetVolume(SOUND_TYPES.GUI, volume)
  ECSoundMan.SetVolume(SOUND_TYPES.GUI_INTERRUPT, volume)
  self:SetFightEffectSoundVolume(volume)
end
def.method("number").SetFightEffectSoundVolume = function(self, volume)
  local FightMgr = require("Main.Fight.FightMgr")
  local min = FightMgr.FightSoundTypeId_Min
  local max = FightMgr.FightSoundTypeId_Max
  for i = min, max do
    local soundType = SOUND_TYPES.FIGHT .. i
    ECSoundMan.SetVolume(soundType, volume)
  end
end
return SoundModule.Commit()
