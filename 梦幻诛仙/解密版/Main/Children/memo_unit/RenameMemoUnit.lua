local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local RenameMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local BabyPropertyEnum = require("consts.mzm.gsp.children.confbean.BabyPropertyEnum")
local def = RenameMemoUnit.define
def.field("string").oldName = ""
def.field("string").newName = ""
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  local oldNameOctets = self.m_octetsParams[GrowthSubType.OLD_NAME]
  if oldNameOctets then
    self.oldName = _G.GetStringFromOcts(oldNameOctets) or self.oldName
  end
  local newNameOctets = self.m_octetsParams[GrowthSubType.NEW_NAME]
  if newNameOctets then
    self.newName = _G.GetStringFromOcts(newNameOctets) or self.newName
  end
end
def.override("=>", "string").GetFormattedText = function(self)
  local text = string.format(textRes.Children[4210], self.newName)
  return text
end
return RenameMemoUnit.Commit()
