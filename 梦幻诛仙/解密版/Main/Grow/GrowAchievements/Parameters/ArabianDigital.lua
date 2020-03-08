local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Parameter = import(".Parameter")
local ArabianDigital = Lplus.Extend(Parameter, CUR_CLASS_NAME)
local def = ArabianDigital.define
def.override("number", "=>", "string").ToString = function(self, value)
  return tostring(value)
end
return ArabianDigital.Commit()
