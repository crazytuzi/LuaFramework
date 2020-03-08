local Lplus = require("Lplus")
local TeamRoleOperateBase = Lplus.Class("TeamRoleOperateBase")
local def = TeamRoleOperateBase.define
def.field("table").tag = nil
def.virtual("table", "table", "=>", "boolean").CanDisplay = function(self, roleInfo, teamInfo)
  return false
end
def.virtual("=>", "string").GetOperationName = function(self)
  return "NULL"
end
def.virtual("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  if _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo, self.tag)
end
def.virtual("table", "table", "=>", "boolean").Operate = function(self, roleInfo, teamInfo)
  print("This operation is not implemented!")
  return true
end
return TeamRoleOperateBase.Commit()
