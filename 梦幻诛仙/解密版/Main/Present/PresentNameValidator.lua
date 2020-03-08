local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local PresentNameValidator = Lplus.Extend(NameFilter, "PresentNameValidator")
local def = PresentNameValidator.define
local instance
def.static("=>", PresentNameValidator).Instance = function()
  if instance == nil then
    instance = PresentNameValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
  self.ruler.MinCharacterNum = 0
  self.ruler.MaxCharacterNum = 20
end
def.override("number", "=>", "boolean").IsInCharacterSection = function(self, charCode)
  return true
end
return PresentNameValidator.Commit()
