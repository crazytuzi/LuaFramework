local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = Lplus.Class(MODULE_NAME)
local def = BaseMemoUnit.define
def.const("string").SYMBOL_DELIMITER = textRes.Children[4200]
def.const("string").SYMBOL_INCREMENT = textRes.Children[4201]
def.const("string").SYMBOL_DECREMENT = textRes.Children[4202]
def.field("number").m_type = 0
def.field("userdata").m_occurtime = nil
def.field("table").m_intParams = nil
def.field("table").m_octetsParams = nil
def.virtual("number", "userdata", "table").Init = function(self, type, occurtime, params)
  self.m_type = type
  self.m_occurtime = occurtime
  if params then
    self.m_intParams = params.int_parameter_map
    self.m_octetsParams = params.string_parameter_map
  end
  self.m_intParams = self.m_intParams or {}
  self.m_octetsParams = self.m_octetsParams or {}
end
def.virtual("=>", "string").GetFormattedText = function(self)
  return ""
end
def.method("=>", "number").GetType = function(self)
  return self.m_type
end
def.method("=>", "userdata").GetOccurTime = function(self)
  return self.m_occurtime
end
return BaseMemoUnit.Commit()
