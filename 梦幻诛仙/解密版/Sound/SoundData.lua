local Lplus = require("Lplus")
local SoundData = Lplus.Class("SoundData")
local def = SoundData.define
local instance
def.static("=>", SoundData).Instance = function()
  if instance == nil then
    instance = SoundData()
  end
  return instance
end
def.method("number", "=>", "dynamic").GetSoundPath = function(self, soundId)
  if soundId == 0 then
    return nil
  end
  local record = DynamicData.GetRecord(CFG_PATH.DATA_AUDIO_CFG, soundId)
  if record == nil then
    warn("GetSoundPath(" .. soundId .. ") return nil")
    return nil
  end
  local path = DynamicRecord.GetStringValue(record, "musicFilePath")
  if path == nil or path == "" then
    return nil
  end
  return path .. ".u3dext"
end
return SoundData.Commit()
