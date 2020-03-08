local Lplus = require("Lplus")
local SettingData = require("Main.SystemSetting.data.SettingData")
local NumSettingData = Lplus.Extend(SettingData, "NumSettingData")
local def = NumSettingData.define
def.field("number").num = 0
def.field("function").checkFunc = nil
def.static("number", "boolean", "function", "=>", NumSettingData).New = function(id, num, func)
  local instance = NumSettingData()
  instance:Ctor(id, num, func)
  return instance
end
def.method("number", "number", "function").Ctor = function(self, id, num, func)
  self.id = id
  self.num = num
  self.checkFunc = func
end
def.method("number").SetNum = function(self, num)
  self.num = num
  self:NotifyChange()
end
def.method("number", "=>", "boolean").Check = function(self, num)
  if self.checkFunc then
    return self.checkFunc(num) and true or false
  else
    return true
  end
end
def.override("table").Marshal = function(self, data)
  SettingData.Marshal(self, data)
  self.num = data.num or 0
end
def.override("=>", "table").Unmarshal = function(self)
  local data = SettingData.Unmarshal(self)
  data.num = self.num or 0
  return data
end
return NumSettingData.Commit()
