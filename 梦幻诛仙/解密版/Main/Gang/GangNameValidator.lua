local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local GangNameValidator = Lplus.Extend(NameFilter, "GangNameValidator")
local def = GangNameValidator.define
local instance
def.static("=>", GangNameValidator).Instance = function()
  if instance == nil then
    instance = GangNameValidator()
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
    if bNumber then
      return false, NameFilter.InvalidReason.AllNumber, wordNum
    else
      return true, wrong, wordNum
    end
  else
    return false, wrong, wordNum
  end
end
return GangNameValidator.Commit()
