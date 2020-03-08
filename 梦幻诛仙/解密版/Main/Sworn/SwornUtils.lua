local Lplus = require("Lplus")
local SwornData = require("Main.Sworn.data.SwornData")
local SwornUtils = Lplus.Class("SwornUtils")
local def = SwornUtils.define
def.static("=>", "boolean").IsSworn = function()
  return SwornData.Instance():GetSwornID() ~= nil
end
SwornUtils.Commit()
return SwornUtils
