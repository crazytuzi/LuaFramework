local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local CorpsNameValidator = Lplus.Extend(NameFilter, "CorpsNameValidator")
local def = CorpsNameValidator.define
local instance
def.static("=>", CorpsNameValidator).Instance = function()
  if instance == nil then
    instance = CorpsNameValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
  self.ruler.MinCharacterNum = constant.CorpsConsts.CORPS_NAME_MIN_LENGTH * 0.5
  self.ruler.MaxCharacterNum = constant.CorpsConsts.CORPS_NAME_MAX_LENGTH
end
return CorpsNameValidator.Commit()
