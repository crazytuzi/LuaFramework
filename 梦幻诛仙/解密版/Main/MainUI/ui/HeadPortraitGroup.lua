local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local HeadPortraitGroup = Lplus.Extend(ComponentBase, "Main.MainUI.ui.HeadPortraitGroup")
local Vector = require("Types.Vector")
local def = HeadPortraitGroup.define
local instance
def.static("=>", HeadPortraitGroup).Instance = function()
  if instance == nil then
    instance = HeadPortraitGroup()
  end
  return instance
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
HeadPortraitGroup.Commit()
return HeadPortraitGroup
