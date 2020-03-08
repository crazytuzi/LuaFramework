local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECSoundMan = require("Sound.ECSoundMan")
local CGEventSound = Lplus.Class("CGEventSound")
local def = CGEventSound.define
local s_inst
def.static("=>", CGEventSound).Instance = function()
  if not s_inst then
    s_inst = CGEventSound()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local soundRes = dataTable.sound
  if dataTable.soundId > 0 then
    local SoundData = require("Sound.SoundData")
    local data = SoundData.Instance():GetSoundPath(dataTable.soundId)
    if data then
      soundRes = data
    end
  end
  GameUtil.SetSoundMaxCount(SOUND_TYPES.CG, 10)
  local soundType = dataTable.soundType
  if soundRes ~= "" then
    if soundType == 0 then
      ECSoundMan.Instance():Play2DSoundEx(soundRes, SOUND_TYPES.CG, 1)
      print("play sound2d:", soundRes)
    elseif soundType == 1 then
      ECSoundMan.Instance():Play3DSoundEx(soundRes, eventObj.gameObject.position, SOUND_TYPES.CG, 1)
    elseif soundType == 2 then
      ECSoundMan.Instance():PlayBackgroundMusic(soundRes, true)
      gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(dataTable.soundVolume)
    end
  end
  if not dramaTable.playCGSound then
    dramaTable.playCGSound = true
    local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
    local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.BGMusic)
    local volume
    if setting.mute then
      volume = 0
    else
      volume = setting.volume
    end
    ECSoundMan.SetVolume(SOUND_TYPES.CG, volume)
  end
  if dataTable.soundId == 0 and soundRes == "" and not dramaTable.pauseAllSound then
    dramaTable.pauseAllSound = true
    dataTable.guiOldSoundVolume = ECSoundMan.GetVolume(SOUND_TYPES.GUI)
    dataTable.envOldSoundVolume = ECSoundMan.GetVolume(SOUND_TYPES.ENVIRONMENT)
    dataTable.bgOldSoundVolume = ECSoundMan.GetVolume(SOUND_TYPES.BACKGROUND)
    ECSoundMan.SetVolume(SOUND_TYPES.GUI, 0)
    ECSoundMan.SetVolume(SOUND_TYPES.ENVIRONMENT, 0)
    if soundType == 2 then
      ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, 0)
    end
  end
  eventObj:Finish()
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  if dramaTable.pauseAllSound and dataTable.guiOldSoundVolume then
    ECSoundMan.SetVolume(SOUND_TYPES.GUI, dataTable.guiOldSoundVolume)
    ECSoundMan.SetVolume(SOUND_TYPES.ENVIRONMENT, dataTable.envOldSoundVolume)
    ECSoundMan.SetVolume(SOUND_TYPES.BACKGROUND, dataTable.bgOldSoundVolume)
    dramaTable.pauseAllSound = nil
  end
  if dramaTable.playCGSound then
    dramaTable.playCGSound = nil
    ECSoundMan.SetVolume(SOUND_TYPES.CG, 0)
  end
  gmodule.moduleMgr:GetModule(ModuleId.SOUND):SetGlobalVolume(1)
  dataTable.isFinished = true
end
CGEventSound.Commit()
CG.RegEvent("CGLuaEventSound", CGEventSound.Instance())
return CGEventSound
