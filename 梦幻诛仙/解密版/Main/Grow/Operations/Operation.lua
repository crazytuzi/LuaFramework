local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = Lplus.Class(CUR_CLASS_NAME)
local def = Operation.define
def.field("number").type = 0
def.virtual("number").Init = function(self, operationType)
  self.type = operationType
end
def.virtual("table", "=>", "boolean").Operate = function(self, params)
  warn("Operation not implement, type = ", self.type)
  return false
end
return Operation.Commit()
