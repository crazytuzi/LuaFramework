local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local AddPropMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local def = AddPropMemoUnit.define
def.field("number").m_propKey = 0
def.field("number").m_propValue = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_propKey = self.m_intParams[GrowthSubType.ADULT_ADD_APT_TYPE] or 0
  self.m_propValue = self.m_intParams[GrowthSubType.ADULT_ADD_APT_CHANGE] or 0
end
def.override("=>", "string").GetFormattedText = function(self)
  if self.m_propKey <= 0 then
    return "error menpai\239\188\154" .. self.m_propKey
  end
  return string.format(textRes.Children[3069], textRes.Children.PropertyName[self.m_propKey], self.m_propValue)
end
return AddPropMemoUnit.Commit()
