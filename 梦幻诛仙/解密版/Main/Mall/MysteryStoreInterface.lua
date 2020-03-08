local Lplus = require("Lplus")
local MysteryStoreInterface = Lplus.Class("MysteryStoreInterface")
local PageEnum = require("consts.mzm.gsp.mall.confbean.PageEnum")
local ServerModule = require("Main.Server.ServerModule")
local MysteryStoreUtil = require("Main.Mall.MysteryStoreUtil")
local MallUtility = require("Main.Mall.MallUtility")
local def = MysteryStoreInterface.define
def.const("number").PAGE_NUM = PageEnum.PAGE_2
def.static("=>", "boolean").ExistMall2Open = function()
  local mallInfos = MallUtility.GetMallListByPageType(MysteryStoreInterface.PAGE_NUM)
  local roleLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  for i = 1, #mallInfos do
    local mallCfg = MysteryStoreUtil.GetConstCfgByShopType(mallInfos[i].mallType)
    if roleLv >= mallCfg.minLevel then
      return true
    end
  end
  return false
end
def.static("=>", "number").GetMinCfgLv = function()
  local minLevel = 9999
  local mallInfos = MallUtility.GetMallListByPageType(MysteryStoreInterface.PAGE_NUM)
  for i = 1, #mallInfos do
    local mallCfg = MysteryStoreUtil.GetConstCfgByShopType(mallInfos[i].mallType)
    if minLevel > mallCfg.minLevel then
      minLevel = mallCfg.minLevel
    end
  end
  return minLevel
end
def.static("=>", "boolean").CanShowMysteryStore = function()
  local MallModule = require("Main.Mall.MallModule")
  local bFeatureOpen = MallModule.IsMysteryStoreFeatureOpen()
  if not bFeatureOpen then
    return false
  end
  if not MysteryStoreInterface.ExistMall2Open() then
    return false
  end
  return true
end
def.static("=>", "number").GetServerLevel = function()
  local serverLv = ServerModule.Instance():GetServerLevelInfo().level
  return serverLv
end
return MysteryStoreInterface.Commit()
