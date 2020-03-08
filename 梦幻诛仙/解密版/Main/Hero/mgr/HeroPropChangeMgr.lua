local Lplus = require("Lplus")
local HeroPropChangeMgr = Lplus.Class("HeroPropChangeMgr")
local def = HeroPropChangeMgr.define
local instance
local HeroProp = require("Main.Hero.data.HeroProp")
local HeroSecondProp = require("Main.Hero.data.HeroSecondProp")
local HeroExtraProp = require("Main.Hero.data.HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
def.static("=>", HeroPropChangeMgr).Instance = function()
  if instance == nil then
    instance = HeroPropChangeMgr()
  end
  return instance
end
def.method("table").OnHeroSecondPropChanged = function(self, filteredProp)
  require("Main.Common.OutFightDo").Instance():Do(function()
    local tipIns = require("Main.Hero.ui.HeroPropChangeTip").Instance()
    for i, v in ipairs(filteredProp.increasedProp) do
      tipIns:ShowTip(v)
    end
    for i, v in ipairs(filteredProp.decreasedProp) do
      tipIns:ShowTip(v)
    end
  end, nil)
end
HeroPropChangeMgr.Commit()
return HeroPropChangeMgr
