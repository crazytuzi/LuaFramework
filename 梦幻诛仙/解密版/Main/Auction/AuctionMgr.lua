local Lplus = require("Lplus")
local AuctionData = require("Main.Auction.data.AuctionData")
local AuctionProtocols = require("Main.Auction.AuctionProtocols")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local AuctionModule = require("Main.Auction.AuctionModule")
local AuctionMgr = Lplus.Class("AuctionMgr")
local def = AuctionMgr.define
local instance
def.static("=>", AuctionMgr).Instance = function()
  if instance == nil then
    instance = AuctionMgr()
  end
  return instance
end
def.field("boolean")._bWaiting = false
def.field("number")._confirmAuctionId = 0
def.field("number")._confirmRoundIdx = 0
local UPDATE_INTERVAL = 1
def.field("number")._timerID = 0
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, AuctionMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AuctionMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AuctionMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AuctionMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, AuctionMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_ROUND_CHANGE, AuctionMgr.OnAuctionRoundChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, AuctionMgr.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, AuctionMgr.OnDoActivity)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUCTION_CLICK, AuctionMgr.OnMainUIAuctionClick)
end
def.static("table", "table").OnFeatureOpenInit = function(param, context)
  AuctionMgr.UpdateActivityIDIPState()
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_AUCTION then
    AuctionMgr.UpdateActivityIDIPState()
    AuctionMgr.TryShowAuctionConfirm(true)
    AuctionMgr.TryUpdateReddot(true, true)
    AuctionMgr.TryUpdateEntrance(true, true)
    if not IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AUCTION) then
      local AuctionBidPanel = require("Main.Auction.ui.AuctionBidPanel")
      if AuctionBidPanel.Instance():IsShow() then
        AuctionBidPanel.Instance():DestroyPanel()
      end
      local AuctionBidderListPanel = require("Main.Auction.ui.AuctionBidderListPanel")
      if AuctionBidderListPanel.Instance():IsShow() then
        AuctionBidderListPanel.Instance():DestroyPanel()
      end
    end
  end
end
def.static().UpdateActivityIDIPState = function()
  local bOpen = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AUCTION)
  local auctionCfgs = AuctionData.Instance():GetAuctionActivityCfgs()
  if auctionCfgs then
    for activityId, auctionCfg in pairs(auctionCfgs) do
      if bOpen then
        ActivityInterface.Instance():removeCustomCloseActivity(activityId)
      else
        ActivityInterface.Instance():addCustomCloseActivity(activityId)
      end
    end
    AuctionData.Instance():UpdateCurrentAuction()
  end
  if false == bOpen then
    AuctionData.Instance():ClearAuctionItemInfo()
  end
end
def.static("table", "table").OnEnterWorld = function(param, context)
  local self = AuctionMgr.Instance()
  AuctionData.Instance():OnEnterWorld()
  self._timerID = GameUtil.AddGlobalTimer(UPDATE_INTERVAL, false, function()
    self:_Update()
  end)
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  local self = AuctionMgr.Instance()
  self:_ClearTimer()
  self._bWaiting = false
  AuctionModule.Instance():SetReddot(false, false)
  AuctionModule.Instance():SetShowEntrance(false, false)
  AuctionData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnNewDay = function(param, context)
  AuctionData.Instance():OnNewDay(param, context)
end
def.static("table", "table").OnAuctionRoundChange = function(param, context)
  AuctionMgr.TryShowAuctionConfirm(true)
  AuctionMgr.TryUpdateReddot(true, true)
  AuctionMgr.TryUpdateEntrance(true, true)
end
def.static("table", "table").OnHeroLevelUp = function(param, context)
  local minOpenLevel = AuctionData.Instance():GetMinOpenLevel()
  if minOpenLevel <= param.level and minOpenLevel > param.lastLevel then
    AuctionMgr.TryShowAuctionConfirm(true)
    AuctionMgr.TryUpdateReddot(true, true)
    AuctionMgr.TryUpdateEntrance(true, true)
  end
end
def.static("string").OnAuctionLinkClicked = function(auctionLink)
  if auctionLink and string.sub(auctionLink, 1, 8) == "auction_" then
    warn("[AuctionMgr:OnAuctionLinkClicked] auctionLink:", auctionLink)
    local strs = string.split(string.sub(auctionLink, 9, -1), "_")
    if strs[1] and strs[2] and strs[3] then
      local activityId = tonumber(strs[1])
      local round = tonumber(strs[2])
      local auctionItemId = tonumber(strs[3])
      local itemInfo = AuctionData.Instance():GetItemInfo(activityId, round, auctionItemId)
      if itemInfo and itemInfo:GetCountDown() > 0 then
        require("Main.Auction.ui.AuctionBidPanel").ShowPanel(itemInfo)
        return
      else
        warn("[AuctionMgr:OnAuctionLinkClicked] itemInfo nil for auctionLink:", auctionLink)
      end
    end
    require("Main.Auction.AuctionInterface").OpenAuctionPanel()
  end
end
def.static("table", "table").OnDoActivity = function(param, context)
  local activityId = param and param[1]
  local curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
  if activityId > 0 and activityId == curAuctionId then
    require("Main.Auction.AuctionInterface").OpenAuctionPanel()
  end
end
def.static("table").OnSGetAuctionInfoRsp = function(p)
  local self = AuctionMgr.Instance()
  if self._bWaiting then
    local curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
    local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
    if p.activityId == curAuctionId and p.turnIndex == curRoundIdx then
      self._bWaiting = false
      AuctionMgr.TryShowAuctionConfirm(false)
      AuctionMgr.TryUpdateReddot(false, true)
      AuctionMgr.TryUpdateEntrance(false, true)
    end
  end
end
def.static("table", "table").OnMainUIAuctionClick = function(p, c)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not AuctionModule.Instance():IsOpen(true) then
    return
  end
  AuctionModule.Instance():SetReddot(false, false)
  require("Main.Auction.AuctionInterface").OpenAuctionPanel()
end
def.static("boolean").TryShowAuctionConfirm = function(bReq)
  local self = AuctionMgr.Instance()
  if not AuctionModule.Instance():IsOpen(false) or not AuctionData.Instance():IsInCurRoundCfgInterval() then
    return
  end
  local curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  local itemMap = AuctionData.Instance():GetRoundItems(curAuctionId, curRoundIdx)
  if itemMap then
    local bShow = false
    for cfgId, info in pairs(itemMap) do
      if info and info:GetCountDown() > 0 then
        bShow = true
        break
      end
    end
    if bShow then
      require("Main.Auction.ui.AuctionEntrancePanel").Instance():ShowDlg(curAuctionId)
    end
  elseif bReq and false == self._bWaiting then
    self._bWaiting = true
    AuctionProtocols.SendCGetAuctionInfoReq(curAuctionId, curRoundIdx)
  end
end
def.static("boolean", "boolean").TryUpdateReddot = function(bReq, bForce)
  local self = AuctionMgr.Instance()
  local curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  if not AuctionModule.Instance():IsOpen(false) or curAuctionId <= 0 or curRoundIdx <= 0 or not AuctionData.Instance():IsInCurRoundCfgInterval() then
    AuctionModule.Instance():SetReddot(false, bForce)
  else
    local itemMap = AuctionData.Instance():GetRoundItems(curAuctionId, curRoundIdx)
    if itemMap then
      local bShow = false
      for cfgId, info in pairs(itemMap) do
        if info and 0 < info:GetCountDown() then
          bShow = true
          break
        end
      end
      AuctionModule.Instance():SetReddot(bShow, bForce)
    elseif bReq and false == self._bWaiting then
      self._bWaiting = true
      AuctionProtocols.SendCGetAuctionInfoReq(curAuctionId, curRoundIdx)
    end
  end
end
def.method()._Update = function(self)
  if AuctionModule.Instance():GetReddot() then
    AuctionMgr.TryUpdateReddot(false, false)
  end
  if AuctionModule.Instance():NeedShowEntrance() then
    AuctionMgr.TryUpdateEntrance(false, false)
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.static("boolean", "boolean").TryUpdateEntrance = function(bReq, bForce)
  if not AuctionModule.Instance():IsOpen(false) then
    AuctionModule.Instance():SetShowEntrance(false, bForce)
    return
  end
  local self = AuctionMgr.Instance()
  local curAuctionId = AuctionData.Instance():GetCurrentAuctionId()
  local curRoundIdx = AuctionData.Instance():GetCurrentAuctionRoundIdx()
  if curAuctionId <= 0 or curRoundIdx <= 0 then
    AuctionModule.Instance():SetShowEntrance(false, bForce)
  elseif 1 == curRoundIdx then
    AuctionModule.Instance():SetShowEntrance(true, bForce)
  else
    local bShow = false
    local itemMap = AuctionData.Instance():GetRoundItems(curAuctionId, curRoundIdx)
    if itemMap then
      for cfgId, info in pairs(itemMap) do
        if info and 0 < info:GetCountDown() then
          bShow = true
          break
        end
      end
    elseif bReq and false == self._bWaiting then
      self._bWaiting = true
      AuctionProtocols.SendCGetAuctionInfoReq(curAuctionId, curRoundIdx)
    end
    AuctionModule.Instance():SetShowEntrance(bShow, bForce)
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
AuctionMgr.Commit()
return AuctionMgr
