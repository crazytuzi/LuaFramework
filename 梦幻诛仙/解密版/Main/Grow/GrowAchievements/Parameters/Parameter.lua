local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Parameter = Lplus.Class(CUR_CLASS_NAME)
local def = Parameter.define
def.field("number").type = 0
def.virtual("number").Init = function(self, parameterType)
  self.type = parameterType
end
def.virtual("number", "=>", "string").ToString = function(self, value)
  warn("not handled parameter, type = ", self.type)
  return tostring(value)
end
return Parameter.Commit()
