local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local ChangeMenpaiMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local def = ChangeMenpaiMemoUnit.define
def.field("number").m_menpai = 0
def.field("number").m_oldMenpai = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_menpai = self.m_intParams[GrowthSubType.ADULT_CHANGE_OCCUPATION_NOW] or 0
  self.m_oldMenpai = self.m_intParams[GrowthSubType.ADULT_CHANGE_OCCUPATION_ORIGINAL] or 0
end
def.override("=>", "string").GetFormattedText = function(self)
  if self.m_menpai <= 0 or 0 >= self.m_oldMenpai then
    return "error menpai\239\188\154" .. self.m_menpai
  end
  return string.format(textRes.Children[3068], textRes.Occupation[self.m_oldMenpai], textRes.Occupation[self.m_menpai])
end
return ChangeMenpaiMemoUnit.Commit()
