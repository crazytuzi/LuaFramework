local Lplus = require("Lplus")
local ShituRoleList = Lplus.Class("ShituRoleList")
local def = ShituRoleList.define
def.field("table").nowList = nil
def.field("table").chushiList = nil
def.field("table").chushiRoleIdMap = nil
def.field("number").actualTotalRoleCount = 0
def.static("=>", ShituRoleList).new = function()
  local data = ShituRoleList()
  data.nowList = {}
  data.chushiList = {}
  data.chushiRoleIdMap = {}
  return data
end
def.method("table").SetNowList = function(self, list)
  self.nowList = list
end
def.method("table").AddRoleToNowList = function(self, role)
  table.insert(self.nowList, role)
end
def.method("userdata", "=>", "table").GetNowRoleById = function(self, roleId)
  local roles = self.nowList
  if roles == nil then
    return nil
  end
  for i = 1, #roles do
    if roles[i].roleId == roleId then
      return roles[i]
    end
  end
  return nil
end
def.method("userdata").RemoveRoleFromNowList = function(self, roleId)
  local roles = self.nowList
  if roles == nil then
    return
  end
  for i = 1, #roles do
    if roles[i].roleId == roleId then
      table.remove(roles, i)
      return
    end
  end
end
def.method("table").AddRoleListToChushiList = function(self, roleList)
  for idx, role in pairs(roleList) do
    if self.chushiRoleIdMap[role.roleName] == nil then
      self.chushiRoleIdMap[role.roleName] = role.roleName
      table.insert(self.chushiList, role)
    end
  end
end
def.method("=>", "table").GetNowRoleList = function(self)
  return self.nowList
end
def.method("=>", "number").GetNowListCount = function(self)
  return #self.nowList
end
def.method("=>", "number").GetChushiListCount = function(self)
  return #self.chushiList
end
def.method("=>", "number").GetTotalCachedRoleCount = function(self)
  return #self.nowList + #self.chushiList
end
def.method("number", "=>", "table").GetRoleByIdx = function(self, idx)
  local nowCount = self:GetNowListCount()
  if idx <= nowCount then
    return self.nowList[idx]
  else
    return self.chushiList[idx - nowCount]
  end
end
def.method("number").SetActualTotalRoleCount = function(self, cnt)
  self.actualTotalRoleCount = cnt
end
def.method("=>", "number").GetActualTotalRoleCount = function(self)
  return self.actualTotalRoleCount
end
def.method("=>", "boolean").IsCachedAllRoleData = function(self)
  return self:GetTotalCachedRoleCount() < self:GetActualTotalRoleCount()
end
def.method().ClearNowList = function(self)
  self.nowList = {}
end
def.method().ClearChushiList = function(self)
  self.chushiList = {}
  self.chushiRoleIdMap = {}
end
def.method().ClearData = function(self)
  self:ClearNowList()
  self:ClearChushiList()
  self.actualTotalRoleCount = 0
end
ShituRoleList.Commit()
return ShituRoleList
