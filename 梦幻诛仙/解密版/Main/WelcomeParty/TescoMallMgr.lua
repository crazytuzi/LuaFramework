local Lplus = require("Lplus")
local TescoMallMgr = Lplus.Class("TescoMallMgr")
local def = TescoMallMgr.define
local instance
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local WelcomePartyUtils = require("Main.WelcomeParty.WelcomePartyUtils")
local const = constant.LeGouShangChengConsts
local Cls = TescoMallMgr
def.field("table")._bougthGoods = nil
def.field("boolean")._bTabTescoMallClicked = false
def.field("table")._bSaleOut = nil
def.static("=>", TescoMallMgr).Instance = function()
  if instance == nil then
    instance = TescoMallMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, Cls.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, Cls.OnCrossDay)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, Cls.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.QueryBuyInfoRes, Cls.OnQueryBuyInfoRes)
end
def.static("=>", "boolean").IsShowRedDot = function()
  if Cls.IsAllGoodsSaleOut() then
    return false
  end
  return not instance._bTabTescoMallClicked
end
def.static("boolean").SetShowRedDot = function(bShow)
  instance._bTabTescoMallClicked = not bShow
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.TescoMall
  })
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_LE_GOU_SHANG_CHENG)
  return bOpen
end
def.static("=>", "boolean").IsExpired = function()
  local opendDay = require("Main.Server.ServerModule").Instance():GetServerOpenDays()
  if opendDay > const.dayCount then
    return true
  end
  return false
end
def.static("=>", "boolean").IsLvEnough = function()
  return _G.GetHeroProp().level >= const.roleMinLevel
end
def.static().SelfNodeOpenChg = function()
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.NODE_OPEN_CHANGE, {
    nodeId = NodeId.TescoMall
  })
end
def.static().SelfNotiftChg = function()
  local NodeId = require("Main.WelcomeParty.ui.UIWelcomePartyBasic").NodeId
  Event.DispatchEvent(ModuleId.WELCOME_PARTY, gmodule.notifyId.WelcomeParty.TAB_NOTIFY_STATE_CHG, {
    nodeId = NodeId.TescoMall
  })
end
def.static("=>", "table").GetBougthGoods = function()
  if instance._bougthGoods == nil then
    instance._bougthGoods = {}
  end
  return instance._bougthGoods
end
def.static("=>", "boolean").IsAllGoodsSaleOut = function()
  if instance._bSaleOut == nil then
    instance._bSaleOut = {}
    local cfg2BuyCount = instance._bougthGoods or {}
    local goodsList = WelcomePartyUtils.LoadAllGoodsCfg()
    for i = 1, #goodsList do
      local goodsInfo = goodsList[i]
      local iHasBuyNum = cfg2BuyCount[goodsInfo.id] or 0
      if iHasBuyNum < goodsInfo.buyLimit then
        instance._bSaleOut[1] = false
        return false
      end
    end
    instance._bSaleOut[1] = true
  end
  return instance._bSaleOut[1]
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  instance._bTabTescoMallClicked = false
  instance._bougthGoods = {}
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  if p.feature == Feature.TYPE_LE_GOU_SHANG_CHENG then
    Cls.SelfNodeOpenChg()
  end
end
def.static("table", "table").OnCrossDay = function(p, c)
  Cls.SelfNodeOpenChg()
end
def.static("table", "table").OnHeroLvUp = function(p, c)
  if _G.GetHeroProp().level >= const.roleMinLevel then
    Cls.SelfNodeOpenChg()
  end
end
def.static("table", "table").OnQueryBuyInfoRes = function(p, c)
  instance._bougthGoods = p
end
return TescoMallMgr.Commit()
