local Lplus = require("Lplus")
local PresentUtility = require("Main.Present.PresentUtility")
local PresentData = Lplus.Class("PresentData")
local def = PresentData.define
local instance
def.field("table").itemMap = nil
def.field("table").mallMap = nil
def.static("=>", PresentData).Instance = function()
  if nil == instance then
    instance = PresentData()
  end
  return instance
end
def.method().SetAllNull = function(self)
  self.itemMap = nil
  self.mallMap = nil
end
def.method("table").SyncItemMap = function(self, map)
  self.itemMap = {}
  for k, v in pairs(map) do
    self.itemMap[k:tostring()] = v
  end
end
def.method("table").SyncMallMap = function(self, map)
  self.mallMap = {}
  for k, v in pairs(map) do
    self.mallMap[k:tostring()] = v
  end
end
def.method("userdata", "number").SetItem = function(self, roleId, count)
  self.itemMap[roleId:tostring()] = count
end
def.method("userdata", "userdata").SetMall = function(self, roleId, count)
  self.mallMap[roleId:tostring()] = count
end
def.method("userdata", "=>", "number", "userdata").GetItemMallByRoleId = function(self, roleId)
  local itemCount = 0
  local mallCount = Int64.new(0)
  if self.itemMap[roleId:tostring()] ~= nil then
    itemCount = self.itemMap[roleId:tostring()]
  end
  if self.mallMap[roleId:tostring()] ~= nil then
    mallCount = self.mallMap[roleId:tostring()]
  end
  return itemCount, mallCount
end
return PresentData.Commit()
