local Lplus = require("Lplus")
local SettingData = require("Main.SystemSetting.data.SettingData")
local ToggleSettingData = Lplus.Extend(SettingData, "ToggleSettingData")
local def = ToggleSettingData.define
def.field("boolean").isEnabled = false
def.field("number").group = 0
local groupMembersMap = {}
def.static("number", "boolean", "=>", ToggleSettingData).New = function(id, isEnabled)
  local instance = ToggleSettingData()
  instance:Ctor(id, isEnabled)
  return instance
end
def.method("number", "boolean").Ctor = function(self, id, isEnabled)
  self.id = id
  self.isEnabled = isEnabled
end
def.override().Toggle = function(self)
  self.isEnabled = not self.isEnabled
  if self.isEnabled and self.group ~= 0 then
    self:DisableGroupMembers()
  end
  self:NotifyChange()
end
def.method("=>", "boolean").Enable = function(self)
  if not self.isEnabled then
    self.isEnabled = true
    if self.group ~= 0 then
      self:DisableGroupMembers()
    end
    self:NotifyChange()
    return true
  else
    return false
  end
end
def.method("=>", "boolean").Disable = function(self)
  if self.isEnabled then
    self.isEnabled = false
    self:NotifyChange()
    return true
  else
    return false
  end
end
def.method().SilenceDisable = function(self)
  self.isEnabled = false
  self:SilenceNotifyChange()
end
def.override("table").Marshal = function(self, data)
  SettingData.Marshal(self, data)
  self.isEnabled = data.isEnabled == 1 and true or false
end
def.override("=>", "table").Unmarshal = function(self)
  local data = SettingData.Unmarshal(self)
  data.isEnabled = self.isEnabled and 1 or 0
  return data
end
def.method("number").SetGroup = function(self, group)
  local lastGroup = self.group
  if lastGroup == group then
    return
  end
  local function removeFromGroup(group, data)
    if group == 0 then
      return
    end
    local members = groupMembersMap[group]
    if members == nil then
      return
    end
    members[data.id] = nil
    if next(members) == nil then
      groupMembersMap[group] = nil
    end
  end
  local function addToGroup(group, data)
    if group == 0 then
      return
    end
    local members = groupMembersMap[group] or {}
    members[data.id] = data
    groupMembersMap[group] = members
  end
  removeFromGroup(lastGroup, self)
  addToGroup(group, self)
  self.group = group
end
def.method().DisableGroupMembers = function(self)
  local members = groupMembersMap[self.group]
  if members == nil then
    return
  end
  for k, v in pairs(members) do
    if k ~= self.id and v.isEnabled then
      v:SilenceDisable()
    end
  end
end
return ToggleSettingData.Commit()
