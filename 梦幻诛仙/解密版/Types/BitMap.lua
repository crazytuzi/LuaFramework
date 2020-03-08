local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local BitMap = Lplus.Class(CUR_CLASS_NAME)
local def = BitMap.define
local BIT_LEN_PER_UNIT = 32
def.field("table").bitList = nil
def.field("boolean").defaultZero = true
local __tostring = function(obj)
  local defaultBit = obj.defaultZero and 0 or 1
  local str = "DefaultBit: " .. defaultBit .. "\n"
  str = str .. "{"
  for i, bitUnit in ipairs(obj.bitList) do
    str = str .. "[" .. i .. "]=" .. string.format("0x%X ", bitUnit)
  end
  str = str .. "}"
  return str
end
def.static("number", "=>", BitMap).New = function(defaultBit)
  local obj = BitMap()
  obj:_Ctor(defaultBit)
  return obj
end
def.method("number")._Ctor = function(self, defaultBit)
  self.defaultZero = defaultBit == 0
  self.bitList = {
    [1] = self:_GetDefaultUnitValue()
  }
  local mt = getmetatable(self)
  mt.__tostring = __tostring
end
def.method("number", "number").SetBit = function(self, pos, value)
  local index = math.floor(pos / BIT_LEN_PER_UNIT) + 1
  local offset = pos % BIT_LEN_PER_UNIT
  local bitUnit = self:GetBitUnit(index)
  local newMaskUnit = self:_SetBitOnUnit(bitUnit, offset, value)
  self:SetBitUnit(index, newMaskUnit)
end
def.method("number", "=>", "number").GetBitUnit = function(self, index)
  self:CheckAndExpandList(index)
  return self.bitList[index]
end
def.method("number", "number").SetBitUnit = function(self, index, value)
  self:CheckAndExpandList(index)
  self.bitList[index] = value
end
def.method(BitMap, "=>", BitMap).AND = function(self, bitmap)
  local maxLen = self:_AdjustToEqualSize(self, bitmap)
  local rs = BitMap.New(0)
  for i = 1, maxLen do
    local val = bit.band(self.bitList[i], bitmap.bitList[i])
    rs:SetBitUnit(i, val)
  end
  return rs
end
def.method(BitMap, "=>", BitMap).OR = function(self, bitmap)
  local maxLen = self:_AdjustToEqualSize(self, bitmap)
  local rs = BitMap.New(0)
  for i = 1, maxLen do
    local val = bit.bor(self.bitList[i], bitmap.bitList[i])
    rs:SetBitUnit(i, val)
  end
  return rs
end
def.method(BitMap, "=>", BitMap).XOR = function(self, bitmap)
  local maxLen = self:_AdjustToEqualSize(self, bitmap)
  local rs = BitMap.New(0)
  for i = 1, maxLen do
    local val = bit.bxor(self.bitList[i], bitmap.bitList[i])
    rs:SetBitUnit(i, val)
  end
  return rs
end
def.method("=>", "boolean").IsZero = function(self)
  for i, bitUnit in ipairs(self.bitList) do
    if bitUnit ~= 0 then
      return false
    end
  end
  return true
end
def.method(BitMap, BitMap, "=>", "number")._AdjustToEqualSize = function(self, bml, bmr)
  local maxLen = math.max(#bml.bitList, #bmr.bitList)
  bml:CheckAndExpandList(maxLen)
  bmr:CheckAndExpandList(maxLen)
  return maxLen
end
def.method("=>", "number")._GetDefaultUnitValue = function(self)
  if self.defaultZero then
    return 0
  else
    return bit.bnot(0)
  end
end
def.method("number", "number", "number", "=>", "number")._SetBitOnUnit = function(self, unit, offset, value)
  local val = bit.lshift(1, offset)
  if value == 0 then
    val = bit.bnot(val)
    return bit.band(unit, val)
  else
    return bit.bor(unit, val)
  end
end
def.method("number").CheckAndExpandList = function(self, newNum)
  local maskUnitNum = #self.bitList
  for i = maskUnitNum + 1, newNum do
    self.bitList[i] = self:_GetDefaultUnitValue()
  end
end
return BitMap.Commit()
