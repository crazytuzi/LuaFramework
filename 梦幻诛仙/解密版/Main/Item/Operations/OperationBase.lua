local Lplus = require("Lplus")
local OperationBase = Lplus.Class("OperationBase")
local def = OperationBase.define
def.field("function").UserOperation = nil
def.virtual("number", "table", "table", "=>", "boolean").CanDispaly = function(self)
  return false
end
def.virtual("=>", "string").GetOperationName = function(self)
  return "NULL"
end
def.virtual("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  print("This operation is not implemented!")
  return true
end
def.virtual("number", "number", "userdata", "table", "=>", "boolean").OperateAll = function(self, bagId, itemKey, m_panel, context)
  return false
end
def.method("=>", "boolean").CannotUseInFight = function(self)
  if PlayerIsInFight() then
    Toast(textRes.Item[100] .. self:GetOperationName())
    return true
  else
    return false
  end
end
OperationBase.Commit()
return OperationBase
