local Lplus = require("Lplus")
local bit = require("bit")
local band = bit.band
local UInt64 = Lplus.Class("UInt64")
local def = UInt64.define
def.field("number").high = 0
def.field("number").low = 0
def.final("number", "number", "=>", UInt64).new = function(high, low)
  local obj = UInt64()
  obj.high, obj.low = high, low
  return obj
end
def.method("number", "number").clone = function(self)
  return UInt64.new(self.high, self.low)
end
def.method("number", "number").assign = function(self, high, low)
  self.high, self.low = high, low
end
def.method("=>", "boolean").isZero = function(self)
  return self.high == 0 and self.low == 0
end
def.method(UInt64, "=>", "boolean").equals = function(self, right)
  return self.high == right.high and self.low == right.low
end
def.method(UInt64, "=>", UInt64).band = function(self, right)
  return UInt64.new(band(self.high, right.high), band(self.low, right.low))
end
def.method(UInt64, "=>", "boolean").hasFlag = function(self, flag)
  return band(self.high, flag.high) == flag.high and band(self.low, flag.low) == flag.low
end
UInt64.Commit()
return UInt64
