local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local RedGiftMessageValidator = Lplus.Extend(NameFilter, "RedGiftMessageValidator")
local def = RedGiftMessageValidator.define
local instance
def.static("=>", RedGiftMessageValidator).Instance = function()
  if instance == nil then
    instance = RedGiftMessageValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
  self.ruler.MinCharacterNum = 0
  self.ruler.MaxCharacterNum = constant.ChatGiftConsts.strLimitNum
end
def.override("number", "=>", "boolean").IsInCharacterSection = function(self, charCode)
  return true
end
def.method("string", "=>", "string").GetWordMessageShow = function(self, enteredName)
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
    if num >= 7 then
      index = i
      break
    end
  end
  local realUnicode = string.sub(words, 1, index)
  local realName = GameUtil.UnicodeToUtf8(realUnicode)
  realName = realName .. "..."
  return realName
end
return RedGiftMessageValidator.Commit()
