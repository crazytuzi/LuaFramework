local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Parameter = import(".Parameter")
local Empty = Lplus.Extend(Parameter, CUR_CLASS_NAME)
local def = Empty.define
def.override("number", "=>", "string").ToString = function(self, value)
  return ""
end
return Empty.Commit()
