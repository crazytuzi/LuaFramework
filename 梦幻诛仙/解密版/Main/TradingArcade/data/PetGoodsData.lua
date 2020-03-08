local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GoodsData = import(".GoodsData")
local PetGoodsData = Lplus.Extend(GoodsData, MODULE_NAME)
local PetUtility = require("Main.Pet.PetUtility")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local def = PetGoodsData.define
def.field("number").petCfgId = 0
def.field("table").petInfo = nil
def.field("number").petLevel = 0
def.override("=>", "string").GetName = function(self)
  local petCfg = PetUtility.Instance():GetPetCfg(self.petCfgId)
  if petCfg == nil then
    return ""
  end
  return petCfg.templateName
end
def.override("=>", "table").GetIcon = function(self)
  local petCfg = PetUtility.Instance():GetPetCfg(self.petCfgId)
  local icon = {iconId = 0, bgSprite = ""}
  if petCfg.templateId == 0 then
    return icon
  end
  local modelCfg = PubroleInterface.GetModelCfg(petCfg.modelId)
  if modelCfg == nil then
    return icon
  end
  icon.iconId = modelCfg.headerIconId
  icon.rdText = string.format(textRes.Common[3], self.petLevel)
  local petCfg = PetUtility.Instance():GetPetCfg(self.petCfgId)
  local color = 0
  if petCfg.type < PetType.BIANYI then
    color = 0
  elseif petCfg.type < PetType.SHENSHOU then
    color = 4
  else
    color = 5
  end
  icon.bgSprite = string.format("Cell_%02d", color)
  return icon
end
def.override("table").MarshalMarketBean = function(self, bean)
  self.num = 1
  GoodsData.MarshalMarketBean(self, bean)
  self.petCfgId = bean.petCfgId
  self.petLevel = bean.petLevel
end
def.override("=>", "number").GetGainMoney = function(self)
  if self.num == 0 or self:IsInState(GoodsData.State.STATE_SELLED) then
    return self.price
  else
    return 0
  end
end
def.override("=>", "table").GetSellPriceBoundCfg = function(self)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  local marketItemCfg = TradingArcadeUtils.GetMarketPetCfg(self.petCfgId)
  return {
    min = marketItemCfg.minprice,
    max = marketItemCfg.maxprice
  }
end
def.override("=>", "number").GetRefId = function(self)
  return self.petCfgId
end
return PetGoodsData.Commit()
