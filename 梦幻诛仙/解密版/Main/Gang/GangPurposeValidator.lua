local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local GangPurposeValidator = Lplus.Extend(NameFilter, "GangPurposeValidator")
local def = GangPurposeValidator.define
local instance
def.static("=>", GangPurposeValidator).Instance = function()
  if instance == nil then
    instance = GangPurposeValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
end
def.method("=>", "number", "number").GetCharacterNum = function(self)
  return self.ruler.MinCharacterNum, self.ruler.MaxCharacterNum
end
def.override("number", "=>", "boolean").IsInCharacterSection = function(self, charCode)
  return true
end
def.override("string", "=>", "boolean", "number", "number").IsValid = function(self, enteredName)
  local isValid, wrong, wordNum = NameFilter.IsValid(self, enteredName)
  local bNumber = true
  local unicodeName = GameUtil.Utf8ToUnicode(enteredName)
  if isValid then
    for i = 1, #unicodeName, 2 do
      local char = string.sub(unicodeName, i, i + 1)
      if self.isLittleEndian then
        char = string.sub(char, 2, 2) .. string.sub(char, 1, 1)
      end
      local charCodeStr = string.format("%02X%02X", string.byte(char, 1, -1))
      local charCode = tonumber("0x" .. charCodeStr)
      if charCode < self.ruler.CharacterCodeSection[4].min or charCode > self.ruler.CharacterCodeSection[4].max then
        bNumber = false
      end
    end
    return true, wrong, wordNum
  else
    return false, wrong, wordNum
  end
end
return GangPurposeValidator.Commit()
