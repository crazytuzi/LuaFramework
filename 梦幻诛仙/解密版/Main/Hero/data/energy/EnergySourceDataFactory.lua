local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local EnergySourceDataFactory = Lplus.Class(CUR_CLASS_NAME)
local EnergySourceData = require("Main.Hero.data.energy.EnergySourceData")
local VigorAwardType = require("consts.mzm.gsp.vigor.confbean.VigorAwardType")
local VigorParamType = require("consts.mzm.gsp.vigor.confbean.VigorParamType")
local def = EnergySourceDataFactory.define
local CreateAndInit = function(class, cfg)
  local obj = class()
  obj:Init(cfg)
  return obj
end
def.static("table", "=>", EnergySourceData).Create = function(cfg)
  local class
  if cfg.awardType == VigorAwardType.BAOTU then
    class = import(".WaBaoEnergySourceData", CUR_CLASS_NAME)
  elseif cfg.paramType == VigorParamType.HUODONG then
    class = import(".ActivityEnergySourceData", CUR_CLASS_NAME)
  else
    class = EnergySourceData
  end
  return CreateAndInit(class, cfg)
end
return EnergySourceDataFactory.Commit()
