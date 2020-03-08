local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Parameter = import(".Parameter")
local ChineseNumber = Lplus.Extend(Parameter, CUR_CLASS_NAME)
local def = ChineseNumber.define
def.override("number", "=>", "string").ToString = function(self, value)
  local MathHelper = require("Common.MathHelper")
  if value < 100 then
    return MathHelper.Arabic2Chinese(value)
  else
    return "Too large to convert to chinese number, value muset below 100."
  end
end
return ChineseNumber.Commit()
