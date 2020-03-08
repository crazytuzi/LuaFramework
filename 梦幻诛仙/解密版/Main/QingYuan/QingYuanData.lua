local Lplus = require("Lplus")
local QingYuanData = Lplus.Class("QingYuanData")
local def = QingYuanData.define
local instance
def.field("table").currentQingYuanRoleIdList = nil
def.field("table").currentQingYuanRoleList = nil
def.static("=>", QingYuanData).Instance = function()
  if instance == nil then
    instance = QingYuanData()
    instance.currentQingYuanRoleIdList = {}
    instance.currentQingYuanRoleList = {}
  end
  return instance
end
def.method("table").SetCurrentQingYuanRoleIdList = function(self, roles)
  self.currentQingYuanRoleIdList = roles or {}
end
def.method("userdata").AddQingYuanRoleId = function(self, roleId)
  if self.currentQingYuanRoleIdList ~= nil then
    table.insert(self.currentQingYuanRoleIdList, roleId)
  end
end
def.method("userdata").RemoveQingYuanRoleId = function(self, delRoleId)
  if self.currentQingYuanRoleIdList ~= nil then
    for idx, roleId in ipairs(self.currentQingYuanRoleIdList) do
      if roleId == delRoleId then
        table.remove(self.currentQingYuanRoleIdList, idx)
        return
      end
    end
  end
end
def.method("userdata", "=>", "boolean").HasQingYuanRole = function(self, otherId)
  if self.currentQingYuanRoleIdList ~= nil then
    for idx, roleId in ipairs(self.currentQingYuanRoleIdList) do
      if roleId == otherId then
        return true
      end
    end
  end
  return false
end
def.method("=>", "table").GetCurrentQingYuanRoleIdList = function(self)
  return self.currentQingYuanRoleIdList
end
def.method("=>", "number").GetCurrentQingYuanCount = function(self)
  if self.currentQingYuanRoleIdList ~= nil then
    return #self.currentQingYuanRoleIdList
  end
  return 0
end
def.method("table").SetCurrentQingYuanRoleList = function(self, roles)
  self.currentQingYuanRoleList = roles or {}
end
def.method("=>", "table").GetCurrentQingYuanRoleList = function(self)
  return self.currentQingYuanRoleList
end
def.method("userdata").DeleteQingYuanRoleInfo = function(self, delRoleId)
  self:RemoveQingYuanRoleId(delRoleId)
end
QingYuanData.Commit()
return QingYuanData
