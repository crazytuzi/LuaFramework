local MODULE_NAME = (...)
local Lplus = require("Lplus")
local VersionKeyPolicy = Lplus.Class(MODULE_NAME)
local def = VersionKeyPolicy.define
def.virtual("=>", "number").GetResourceVersionKey = function(self)
end
return VersionKeyPolicy.Commit()
