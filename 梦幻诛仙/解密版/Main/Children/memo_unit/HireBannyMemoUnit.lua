local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local HireBannyMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local def = HireBannyMemoUnit.define
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
end
def.override("=>", "string").GetFormattedText = function(self)
  local strTbl = {}
  table.insert(strTbl, textRes.Children[1055])
  return table.concat(strTbl)
end
return HireBannyMemoUnit.Commit()
