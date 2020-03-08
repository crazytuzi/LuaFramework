local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonProtection = import(".CommonProtection")
local NoProtecttion = Lplus.Extend(CommonProtection, CUR_CLASS_NAME)
local def = NoProtecttion.define
def.override().TakeProtection = function(self)
  warn("no protection")
end
return NoProtecttion.Commit()
