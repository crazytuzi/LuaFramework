local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = Lplus.Class(CUR_CLASS_NAME)
local def = OperationBase.define
def.field("table").context = nil
def.virtual("table", "=>", "boolean").CanDispaly = function(self, context)
  return false
end
def.virtual("=>", "string").GetOperationName = function(self)
  return "NULL"
end
def.method("=>", "boolean").OP = function(self)
  return self:Operate(self.context)
end
def.virtual("table", "=>", "boolean").Operate = function(self, context)
  print("This operation is not implemented!")
  return true
end
OperationBase.Commit()
return OperationBase
