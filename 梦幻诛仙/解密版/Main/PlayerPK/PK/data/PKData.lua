local MODULE_NAME = (...)
local Lplus = require("Lplus")
local PKData = Lplus.Class(MODULE_NAME)
local def = PKData.define
def.field("number")._expireTime = 0
def.field("table")._itemTips = nil
def.field("table")._item = nil
def.field("userdata")._roleId = nil
def.field("userdata").activeRoleId = nil
def.field("userdata").passiveRoleId = nil
def.method("number").SetExpireTime = function(self, time)
  self._expireTime = time
end
def.method("=>", "number").GetExpireTime = function(self)
  return self._expireTime
end
def.method("table").SetItemTips = function(self, itemTips)
  self._itemTips = itemTips
end
def.method("=>", "table").GetItemTips = function(self)
  return self._itemTips
end
def.method("table").SetItem = function(self, item)
  self._item = item
end
def.method("table").GetItem = function(self)
  return self._item
end
def.method("userdata").SetRoleId = function(self, roleId)
  self._roleId = roleId
end
def.method("=>", "userdata").GetRoleId = function(self)
  return self._roleId
end
return PKData.Commit()
