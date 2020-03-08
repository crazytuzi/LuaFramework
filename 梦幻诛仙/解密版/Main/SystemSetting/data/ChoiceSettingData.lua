local Lplus = require("Lplus")
local SettingData = require("Main.SystemSetting.data.SettingData")
local ToggleSettingData = require("Main.SystemSetting.data.ToggleSettingData")
local ChoiceSettingData = Lplus.Extend(SettingData, "ChoiceSettingData")
local def = ChoiceSettingData.define
def.field("table").choices = nil
def.static("number", "table", "=>", ChoiceSettingData).New = function(id, choices)
  local instance = ChoiceSettingData()
  instance:Ctor(id, choices)
  return instance
end
def.method("number", "table").Ctor = function(self, id, choices)
  self.id = id
  self.choices = choices or {}
end
def.method("number").EnableChoice = function(self, index)
  if self:CheckChoice() == false then
    return
  end
  local choice = self.choices[index]
  local isTakeEffect = choice:Enable()
  if isTakeEffect then
    self:NotifyChange()
  end
end
def.method("number").DisableChoice = function(self, index)
  if self:CheckChoice() == false then
    return
  end
  local choice = self.choices[index]
  local isTakeEffect = choice:Disable()
  if isTakeEffect then
    self:NotifyChange()
  end
end
def.method("=>", "boolean").CheckChoice = function(self, index)
  local choice = self.choices[index]
  if choice == nil then
    warn("choice not exist for index = ", index)
    return false
  end
  return true
end
def.override("table").Marshal = function(self, data)
  SettingData.Marshal(self, data)
  self.choices = {}
  for i, v in ipairs(data.choices) do
    local choice = ToggleSettingData()
    choice:Marshal(v)
    self.choices[i] = choice
  end
end
def.override("=>", "table").Unmarshal = function(self)
  local data = SettingData.Unmarshal(self)
  data.choices = {}
  for i, choice in ipairs(self.choices) do
    data.choices[i] = choice:Unmarshal()
  end
  return data
end
return ChoiceSettingData.Commit()
