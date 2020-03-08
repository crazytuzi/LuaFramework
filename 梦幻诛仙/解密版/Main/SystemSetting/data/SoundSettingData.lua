local Lplus = require("Lplus")
local SettingData = require("Main.SystemSetting.data.SettingData")
local SoundSettingData = Lplus.Extend(SettingData, "SoundSettingData")
local def = SoundSettingData.define
def.field("number").volume = 1
def.field("boolean").mute = false
def.static("number", "number", "boolean", "=>", SoundSettingData).New = function(id, v, m)
  local instance = SoundSettingData()
  instance:Ctor(v, m)
  return instance
end
def.method("number", "number", "boolean").Ctor = function(self, id, v, m)
  self.id = id
  self.volume = v
  self.mute = m
end
def.override().Toggle = function(self)
  self.mute = not self.mute
  self:NotifyChange()
end
def.method("=>", "boolean").Enable = function(self)
  if self.mute then
    self.mute = false
    self:NotifyChange()
    return true
  else
    return false
  end
end
def.method("=>", "boolean").Disable = function(self)
  if not self.mute then
    self.mute = true
    self:NotifyChange()
    return true
  else
    return false
  end
end
def.method("number").SetVolume = function(self, v)
  if v <= 0 then
    v = 1.0E-4 or v
  end
  if v > 1 then
    v = 1 or v
  end
  if self.volume ~= v then
    self.volume = v
    self:SilenceNotifyChange()
  end
end
def.override("table").Marshal = function(self, data)
  SettingData.Marshal(self, data)
  self.volume = data.volume
  self.mute = data.mute == 1 and true or false
end
def.override("=>", "table").Unmarshal = function(self)
  local data = SettingData.Unmarshal(self)
  data.volume = self.volume
  data.mute = self.mute and 1 or 0
  return data
end
return SoundSettingData.Commit()
