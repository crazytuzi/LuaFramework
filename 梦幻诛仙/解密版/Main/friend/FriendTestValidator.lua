local Lplus = require("Lplus")
local NameFilter = require("Common.NameFilter")
local FriendTestValidator = Lplus.Extend(NameFilter, "FriendTestValidator")
local def = FriendTestValidator.define
local instance
def.static("=>", FriendTestValidator).Instance = function()
  if instance == nil then
    instance = FriendTestValidator()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  NameFilter.Init(self)
  self.ruler.MinCharacterNum = 0
  self.ruler.MaxCharacterNum = 10
end
def.override("number", "=>", "boolean").IsInCharacterSection = function(self, charCode)
  return true
end
return FriendTestValidator.Commit()
