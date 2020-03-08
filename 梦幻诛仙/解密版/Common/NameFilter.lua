local Lplus = require("Lplus")
local NameFilter = Lplus.Class("NameFilter")
local def = NameFilter.define
local instance
local Ruler = {
  MinCharacterNum = 2,
  MaxCharacterNum = 6,
  CharacterCodeSection = {
    {min = 19968, max = 40869},
    {min = 97, max = 122},
    {min = 65, max = 90},
    {min = 48, max = 57}
  },
  CharacterSet = {}
}
def.const("table").InvalidReason = {
  OK = 0,
  TooShort = 1,
  TooLong = 2,
  NotInSection = 3,
  AllNumber = 4
}
def.field("table").ruler = nil
def.field("boolean").isLittleEndian = true
def.virtual().Init = function(self)
  local NameData = require("Main.Login.data.NameData")
  NameData.LoadData()
  Ruler.CharacterSet = NameData.data.mark
  NameData.ClearData()
  self.ruler = Ruler
  self.isLittleEndian = true
end
def.method("number", "number").SetCharacterNum = function(self, min, max)
  self.ruler.MinCharacterNum = min
  self.ruler.MaxCharacterNum = max
end
def.virtual("number", "=>", "boolean").IsInCharacterSection = function(self, charCode)
  for i, v in ipairs(self.ruler.CharacterCodeSection) do
    if charCode >= v.min and charCode <= v.max then
      return true
    end
  end
  return false
end
def.method("number", "=>", "boolean").IsAscii = function(self, charCode)
  if charCode >= 1 and charCode <= 127 then
    return true
  end
  return false
end
def.method("string", "=>", "boolean").IsInCharacterSet = function(self, char)
  for i, v in ipairs(self.ruler.CharacterSet) do
    if char == v then
      return true
    end
  end
  return false
end
def.virtual("string", "=>", "boolean", "number", "number").IsValid = function(self, enteredName)
  local unicodeName = GameUtil.Utf8ToUnicode(enteredName)
  local wordNum = self:GetWordNum(unicodeName)
  local isValid, reason
  if wordNum < self.ruler.MinCharacterNum then
    return false, NameFilter.InvalidReason.TooShort, wordNum
  elseif wordNum > self.ruler.MaxCharacterNum then
    return false, NameFilter.InvalidReason.TooLong, wordNum
  end
  for i = 1, #unicodeName, 2 do
    local char = string.sub(unicodeName, i, i + 1)
    if self.isLittleEndian then
      char = string.sub(char, 2, 2) .. string.sub(char, 1, 1)
    end
    local charCodeStr = string.format("%02X%02X", string.byte(char, 1, -1))
    local charCode = tonumber("0x" .. charCodeStr)
    if not self:IsInCharacterSection(charCode) then
      local unichar = string.sub(unicodeName, i, i + 1)
      local utf8Char = GameUtil.UnicodeToUtf8(unichar)
      print(string.format("charCode %X invalid", charCode))
      if not self:IsInCharacterSet(utf8Char) then
        return false, NameFilter.InvalidReason.NotInSection, wordNum
      end
    end
  end
  return true, NameFilter.InvalidReason.OK, wordNum
end
def.method("string", "=>", "number").GetWordNum = function(self, words)
  local num = 0
  for i = 1, #words, 2 do
    local char = string.sub(words, i, i + 1)
    if self.isLittleEndian then
      char = string.sub(char, 2, 2) .. string.sub(char, 1, 1)
    end
    local charCodeStr = string.format("%02X%02X", string.byte(char, 1, -1))
    local charCode = tonumber("0x" .. charCodeStr)
    if self:IsAscii(charCode) then
      num = num + 0.5
    else
      num = num + 1
    end
  end
  return num
end
def.method("string", "=>", "string").GetWordMaxVal = function(self, enteredName)
  local unicodeName = GameUtil.Utf8ToUnicode(enteredName)
  local words = unicodeName
  local num = 0
  local index = 1
  for i = 1, #words, 2 do
    local char = string.sub(words, i, i + 1)
    if self.isLittleEndian then
      char = string.sub(char, 2, 2) .. string.sub(char, 1, 1)
    end
    local charCodeStr = string.format("%02X%02X", string.byte(char, 1, -1))
    local charCode = tonumber("0x" .. charCodeStr)
    if self:IsAscii(charCode) then
      num = num + 0.5
    else
      num = num + 1
    end
    if num > self.ruler.MaxCharacterNum then
      index = i
      break
    end
  end
  local realUnicode = string.sub(words, 1, index)
  local realName = GameUtil.UnicodeToUtf8(realUnicode)
  return realName
end
def.method("=>", "table").GetRuler = function(self)
  return self.ruler
end
return NameFilter.Commit()
