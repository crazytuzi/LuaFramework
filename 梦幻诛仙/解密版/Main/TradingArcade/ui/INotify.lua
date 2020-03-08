local MODULE_NAME = (...)
local Lplus = require("Lplus")
local INotify = Lplus.Interface(MODULE_NAME)
local def = INotify.define
def.virtual("=>", "boolean").HasNotify = function(self)
end
return INotify.Commit()
