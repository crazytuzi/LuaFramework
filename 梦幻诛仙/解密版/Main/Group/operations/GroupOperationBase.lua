local Lplus = require("Lplus")
local GroupOperationBase = Lplus.Class("GroupOperationBase")
local def = GroupOperationBase.define
def.virtual("userdata", "=>", "boolean").CanOperate = function(self, groupId)
  return true
end
def.virtual("=>", "string").GetOperationName = function(self)
  return ""
end
def.virtual("=>", "boolean").Operate = function(self)
  return true
end
GroupOperationBase.Commit()
return GroupOperationBase
