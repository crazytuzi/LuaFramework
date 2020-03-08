local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ConstellationsMgr = Lplus.Class(MODULE_NAME)
local def = ConstellationsMgr.define
local instance
def.static("=>", ConstellationsMgr).Instance = function()
  if instance == nil then
    instance = ConstellationsMgr()
  end
  return instance
end
def.method().Init = function(self)
end
return ConstellationsMgr.Commit()
