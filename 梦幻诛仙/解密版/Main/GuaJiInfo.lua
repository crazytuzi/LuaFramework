local Lplus = require("Lplus")
local GuaJiInfo = Lplus.Class("GuaJiInfo")
local def = GuaJiInfo.define
def.field("number").ChatCount = 0
def.field("table").GotItems = BLANK_TABLE_INIT
def.final("=>", GuaJiInfo).new = function()
  local obj = GuaJiInfo()
  return obj
end
GuaJiInfo.Commit()
return GuaJiInfo
