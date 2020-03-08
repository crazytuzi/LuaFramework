local Lplus = require("Lplus")
local GangRaceUtils = Lplus.Class("GangRaceUtils")
local instance
local def = GangRaceUtils.define
def.static("=>", GangRaceUtils).Instance = function()
  if nil == instance then
    instance = GangRaceUtils()
  end
  return instance
end
GangRaceUtils.Commit()
return GangRaceUtils
