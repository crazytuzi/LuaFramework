local Lplus = require("Lplus")
local ECUniqueId = Lplus.Class("ECUniqueId")
local def = ECUniqueId.define
local _UniqueId = 1
def.static("=>", "number").GetAndIncUniqueId = function()
  local r = _UniqueId
  _UniqueId = _UniqueId + 1
  return r
end
ECUniqueId.Commit()
return ECUniqueId
