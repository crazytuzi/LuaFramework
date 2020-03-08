local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local NameValidator = Lplus.Extend(NameFilter, "NameValidator")
local def = NameValidator.define
local instance
def.static("=>", NameValidator).Instance = function()
  if instance == nil then
    instance = NameValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
  self.ruler.MinCharacterNum = 2
  self.ruler.MaxCharacterNum = 6
end
return NameValidator.Commit()
