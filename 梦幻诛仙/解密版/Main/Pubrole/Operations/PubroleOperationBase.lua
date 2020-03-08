local Lplus = require("Lplus")
local PubroleOperationBase = Lplus.Class("PubroleOperationBase")
local def = PubroleOperationBase.define
def.field("table").tag = nil
def.virtual("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  return false
end
def.virtual("=>", "string").GetOperationName = function(self)
  return "NULL"
end
def.virtual("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  if _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo)
end
def.virtual("table", "=>", "boolean").Operate = function(self, roleInfo)
  print("This operation is not implemented!")
  return true
end
PubroleOperationBase.Commit()
return PubroleOperationBase
