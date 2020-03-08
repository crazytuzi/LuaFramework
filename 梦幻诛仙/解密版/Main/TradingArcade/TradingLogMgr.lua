local MODULE_NAME = (...)
local Lplus = require("Lplus")
local TradingLogMgr = Lplus.Class
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local PetUtility = require("Main.Pet.PetUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local def = TradingLogMgr.define
local instance
def.static("=>", TradingLogMgr).Instance = function()
  if instance == nil then
    instance = TradingLogMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
return TradingLogMgr.Commit()
