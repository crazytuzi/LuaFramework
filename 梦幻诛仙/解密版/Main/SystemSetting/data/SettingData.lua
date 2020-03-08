local Lplus = require("Lplus")
local SettingData = Lplus.Class("SettingData")
local def = SettingData.define
def.field("number").id = 0
def.field("number").type = 0
def.method().NotifyChange = function(self)
  if self.id > 0 then
    Event.DispatchEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, {
      self.id
    })
  end
end
def.method().SilenceNotifyChange = function(self)
  if self.id > 0 then
    Event.DispatchEvent(ModuleId.SYSTEM_SETTING, gmodule.notifyId.SystemSetting.SETTING_CHANGED, {
      self.id,
      silence = true
    })
  end
end
def.virtual().Toggle = function(self)
end
def.virtual("table").Marshal = function(self, data)
  self.id = data.id
  self.type = data.type
end
def.virtual("=>", "table").Unmarshal = function(self)
  local data = {}
  data.id = self.id
  data.type = self.type
  return data
end
return SettingData.Commit()
