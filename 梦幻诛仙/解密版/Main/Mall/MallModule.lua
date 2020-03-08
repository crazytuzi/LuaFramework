local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local MallModule = Lplus.Extend(ModuleBase, "MallModule")
local def = MallModule.define
local MallPanel = require("Main.Mall.ui.MallPanel")
local MallData = require("Main.Mall.data.MallData")
local MallType = require("consts.mzm.gsp.mall.confbean.MallType")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local MallUtility = require("Main.Mall.MallUtility")
local instance
def.field("boolean").bWaitToShow = false
def.field("number").waitToShowState = 0
def.field("number").waitToShowItemId = 0
def.field("number").waitToShowMalltype = 0
def.static("=>", MallModule).Instance = function()
  if instance == nil then
    instance = MallModule()
    instance.m_moduleId = ModuleId.MALL
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SHOP_CLICK, MallModule.OnMallPanelIconClick)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE_WITH_REQUIREMENT, MallModule.OnNPCServiceByTask)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SAllMallItemNum", MallModule.OnSAllMallItemNum)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SItemNumChangeInfo", MallModule.OnSItemNumChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SBuyItemErrorInfo", MallModule.OnSBuyItemErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SBuyItemRes", MallModule.OnSBuyItemRes)
  local PromotionNode = require("Main.Mall.ui.PromotionNode")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mysteryshop.SMysteryGoodsChangeInfo", PromotionNode.OnSMysteryGoodsChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mysteryshop.SMysteryShopErrorInfo", PromotionNode.OnSMysteryShopErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mysteryshop.SResMysteryShopInfo", PromotionNode.OnSResMysteryShopInfo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, PromotionNode.OnActReset)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MallModule.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MallModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, MallModule.OnHeroLvUp)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MallModule.OnNewDay)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self.bWaitToShow = false
  self.waitToShowState = 0
  self.waitToShowItemId = 0
  self.waitToShowMalltype = 0
  MallData.Instance():SetAllNull()
end
def.static("table", "table").OnMallPanelIconClick = function()
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  CommercePitchModule.Instance().showByTask = false
  MallModule.RequireToShowMallPanel(MallPanel.StateConst.Commerce, 0, MallType.PRECIOUS_MALL)
end
def.static("table", "table").OnNPCServiceByTask = function(params, tbl)
  if _G.IsCrossingServer() then
    return
  end
  local serviceID = params[1]
  local itemId = params[3]
  local NeedCount = params[4]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if serviceID == NPCServiceConst.OpenTreasureMall then
    MallModule.RequireToShowMallPanel(MallPanel.StateConst.Treasure, itemId, MallType.PRECIOUS_MALL)
  end
end
def.static("number", "number", "number").RequireToShowMallPanel = function(state, itemId, malltype)
  local list = MallData.Instance():GetAllMallItemsList()
  local btnNumCfg = require("Main.Mall.MallUtility").GetTypeOneBtnNumByCfg()
  local btnNumList = MallData.Instance():GetTypeOneBtnNumByItemList()
  if btnNumCfg == btnNumList then
    MallPanel.Instance():ShowPanel(state, itemId, malltype)
  else
    MallModule.Instance().bWaitToShow = true
    local p = require("netio.protocol.mzm.gsp.mall.CReqAllMallItemNum").new()
    gmodule.network.sendProtocol(p)
    MallModule.Instance().waitToShowState = state
    MallModule.Instance().waitToShowItemId = itemId
    MallModule.Instance().waitToShowMalltype = malltype
  end
end
def.static("table").OnSAllMallItemNum = function(p)
  MallData.Instance():SyncAllMallItemsList(p.mallItemList)
  if MallModule.Instance().bWaitToShow and 0 ~= MallModule.Instance().waitToShowState then
    MallPanel.Instance():ShowPanel(MallModule.Instance().waitToShowState, MallModule.Instance().waitToShowItemId, MallModule.Instance().waitToShowMalltype)
    MallModule.Instance().bWaitToShow = false
    MallModule.Instance().waitToShowState = 0
    MallModule.Instance().waitToShowItemId = 0
    MallModule.Instance().waitToShowMalltype = 0
  else
    Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateItems, nil)
  end
end
def.static("table").OnSItemNumChangeInfo = function(p)
  MallData.Instance():SetItemLeft(p.malltype, p.itemid, p.count)
  Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.LimitItemNumChanged, nil)
end
def.static("table").OnSBuyItemErrorInfo = function(p)
  if textRes.Mall.ErrorInfo[p.errorCode] ~= nil then
    Toast(textRes.Mall.ErrorInfo[p.errorCode])
  end
end
def.static("table").OnSBuyItemRes = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.itemid)
  local key = string.format("%d_%d", p.itemid, p.malltype)
  local price = require("Main.Mall.MallUtility").GetItemPrice(key)
  local namenum = string.format("%sx%d", itemBase.name, p.buynum)
  local money = price * p.buynum
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonMsg(PersonalHelper.Type.ColorText, textRes.Common[44], "ffffff", PersonalHelper.Type.ColorText, namenum, "ffff00", PersonalHelper.Type.ColorText, textRes.Common.comma .. textRes.Common[45], "ffffff", PersonalHelper.Type.Yuanbao, money)
  Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.SucceedBuyItem, nil)
end
def.static("table", "table").OnFeatureInit = function(p, context)
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p.feature == Feature.TYPE_MYSTERYS_SHOP then
    local MysteryStoreInterface = require("Main.Mall.MysteryStoreInterface")
    local mallPanel = MallPanel.Instance()
    local iMinLv = MysteryStoreInterface.GetMinCfgLv()
    local PromotionNode = require("Main.Mall.ui.PromotionNode")
    local roleLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
    if roleLv == iMinLv then
      PromotionNode.SetActiveRedPt(true)
    end
    if mallPanel:IsShow() then
      mallPanel:UpdateTabs()
    end
  elseif p.feature == Feature.TYPE_DAILY_LIMIT_MALL then
    Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, nil)
  end
end
def.static("table", "table").OnServeLvChange = function(p, context)
  if MallModule.IsMysteryStoreFeatureOpen() then
    local uiMysteryStore = require("Main.Mall.ui.PromotionNode").Instance()
    if uiMysteryStore._uiGOs ~= nil then
      uiMysteryStore:RepullGoodsList()
    end
  end
end
def.static("table", "table").OnHeroLvUp = function(p, context)
  if MallModule.IsMysteryStoreFeatureOpen() then
    local uiMysteryStore = require("Main.Mall.ui.PromotionNode").Instance()
    if uiMysteryStore._uiGOs ~= nil then
      uiMysteryStore:FillLeftTabs()
    else
      MallModule.OnFeatureOpenChange({
        feature = Feature.TYPE_MYSTERYS_SHOP
      }, nil)
    end
  else
  end
end
def.static("=>", "boolean").IsMysteryStoreFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MYSTERYS_SHOP)
  return bFeatureOpen
end
def.static("table", "table").OnNewDay = function(p1, p2)
  local mallItemsList = MallData.Instance():GetAllMallItemsList()
  for k, v in pairs(mallItemsList) do
    if v.malltype == MallType.DAILY_LIMIT_MALL then
      for itemId, count in pairs(v.itemid2count) do
        local key = string.format("%d_%d", itemId, MallType.DAILY_LIMIT_MALL)
        local maxNum = MallUtility.GetItemMaxBuyNum(key)
        v.itemid2count[itemId] = maxNum
      end
      Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.LimitItemNumChanged, nil)
      break
    end
  end
  Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, nil)
end
return MallModule.Commit()
