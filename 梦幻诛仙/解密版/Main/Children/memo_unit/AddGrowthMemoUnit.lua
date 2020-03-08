local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local AddGrowthMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local def = AddGrowthMemoUnit.define
def.field("number").m_growth = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_growth = self.m_intParams[GrowthSubType.ADULT_ADD_GROWTH_CHANGE] or 0
end
def.override("=>", "string").GetFormattedText = function(self)
  if self.m_growth <= 0 then
    return "error growth\239\188\154" .. self.m_growth
  end
  return string.format(textRes.Children[3070], self.m_growth / 10000)
end
return AddGrowthMemoUnit.Commit()
