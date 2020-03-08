local Lplus = require("Lplus")
local MonkeyRunMgr = Lplus.Class("MonkeyRunMgr")
local MonkeyRunOutData = require("Main.activity.MonkeyRun.data.MonkeyRunOutData")
local MonkeyRunInnerData = require("Main.activity.MonkeyRun.data.MonkeyRunInnerData")
local MonkeyRunShopData = require("Main.activity.MonkeyRun.data.MonkeyRunShopData")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = MonkeyRunMgr.define
def.field("table").activityOutData = nil
def.field("table").activityInnerData = nil
def.field(MonkeyRunShopData).shopData = nil
def.field("table").queryOutAwardDataCallbacks = nil
local instance
def.static("=>", MonkeyRunMgr).Instance = function()
  if instance == nil then
    instance = MonkeyRunMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SOuterInfoRsp", MonkeyRunMgr.OnSOuterInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SOuterDrawRsp", MonkeyRunMgr.OnSOuterDrawRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SOuterDrawError", MonkeyRunMgr.OnSOuterDrawError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SPointExchangeInfoRsp", MonkeyRunMgr.OnSPointExchangeInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SPointExchangeRsp", MonkeyRunMgr.OnSPointExchangeRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SPointExchangeError", MonkeyRunMgr.OnSPointExchangeError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SInnerInfoRsp", MonkeyRunMgr.OnSInnerInfoRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SInnerDrawRsp", MonkeyRunMgr.OnSInnerDrawRsp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiaohuikuaipao.SInnerDrawError", MonkeyRunMgr.OnSInnerDrawError)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MonkeyRunMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MonkeyRunMgr.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, MonkeyRunMgr.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MonkeyRunMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MonkeyRunMgr.OnActivityStatusChane)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, MonkeyRunMgr.OnActivityStatusChane)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MONKEYRUN_CLICK, MonkeyRunMgr.OpenActivityPanel)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, MonkeyRunMgr.OnCreditChange)
  self.queryOutAwardDataCallbacks = {}
end
def.static("table").OnSOuterInfoRsp = function(p)
  MonkeyRunMgr.Instance():SetMonkeyRunOutData(p.activityId, p.turnInfo)
  MonkeyRunMgr.Instance():ProcessGetOutAwardDataCallback()
end
def.static("table").OnSOuterDrawRsp = function(p)
  local outData = MonkeyRunMgr.Instance():GetMonkeyRunOutData(p.activityId)
  local preTicketCount = outData:GetTicketCount()
  MonkeyRunMgr.Instance():SetMonkeyRunOutData(p.activityId, p.outerInfo)
  local newTicketCount = outData:GetTicketCount()
  if #p.awardInfoList ~= #p.stepCountList then
    warn("monkey run 10 stepCount ~= awardCount")
  end
  local totalStep = 0
  local awards = {}
  for i = 1, #p.awardInfoList do
    local step = p.stepCountList[i] or 0
    totalStep = totalStep + step
    local award = {}
    award.step = step
    award.items = {}
    for itemId, itemNum in pairs(p.awardInfoList[i].itemMap) do
      local item = {}
      item.itemId = itemId
      item.itemNum = itemNum
      table.insert(award.items, item)
    end
    if #award.items == 0 then
      warn("SOuterDrawRsp protocol return empty awardItemMap")
    end
    table.insert(awards, award)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Move_Hero, {step = totalStep})
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Out_Award, awards)
  if preTicketCount < newTicketCount then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Ticket, {
      delta = newTicketCount - preTicketCount
    })
  end
end
def.static("table").OnSOuterDrawError = function(p)
  if textRes.activity.SOuterDrawError[p.errorCode] ~= nil then
    Toast(textRes.activity.SOuterDrawError[p.errorCode])
  else
    Toast(string.format(textRes.activity.SOuterDrawError[-1], p.errorCode))
  end
end
def.static("table").OnSPointExchangeInfoRsp = function(p)
  MonkeyRunMgr.Instance():SetMonkeyRunShopData(p)
  MonkeyRunMgr.Instance():ShowMonkeyRunShop()
end
def.static("table").OnSPointExchangeRsp = function(p)
  local shopData = MonkeyRunMgr.Instance():GetMonkeyRunShopData()
  if shopData ~= nil then
    shopData:SetCurrentShopPoint(p.pointCount)
    shopData:SetItemCanBuyCount(p.pointExchangeCfgId, p.available)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Shop_Change, nil)
  end
end
def.static("table").OnSPointExchangeError = function(p)
  if textRes.activity.SPointExchangeError[p.errorCode] ~= nil then
    Toast(textRes.activity.SPointExchangeError[p.errorCode])
  else
    Toast(string.format(textRes.activity.SPointExchangeError[-1], p.errorCode))
  end
end
def.static("table").OnSInnerInfoRsp = function(p)
  MonkeyRunMgr.Instance():SetMonkeyRunInnerData(p.activityId, p.innerInfo)
  local innerData = MonkeyRunMgr.Instance():GetMonkeyRunInnerData(p.activityId)
  local outData = MonkeyRunMgr.Instance():GetMonkeyRunOutData(p.activityId)
  if outData then
    outData:SetTicketCount(innerData:GetCurrentTicketCount())
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, nil)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, nil)
  end
  MonkeyRunMgr.Instance():ShowInnerAwardPanel()
end
def.static("table").OnSInnerDrawRsp = function(p)
  local innerData = MonkeyRunMgr.Instance():GetMonkeyRunInnerData(p.activityId)
  if innerData == nil then
    return
  end
  innerData:SetCurrentTicketCount(p.innerInfo.ticketCount)
  local outData = MonkeyRunMgr.Instance():GetMonkeyRunOutData(p.activityId)
  if outData then
    outData:SetTicketCount(innerData:GetCurrentTicketCount())
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Ticket_Change, nil)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, nil)
  innerData:SetAwardHitIndexes(p.innerInfo.hitIndexes)
  local awards = {}
  local award = {}
  award.step = 1
  award.items = {}
  table.insert(awards, award)
  for itemId, itemNum in pairs(p.awardInfo.itemMap or {}) do
    local item = {}
    item.itemId = itemId
    item.itemNum = itemNum
    table.insert(award.items, item)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Get_Inner_Award, {
    hitIndex = p.hitIndex,
    awards = awards
  })
end
def.static("table").OnSInnerDrawError = function(p)
  if textRes.activity.SInnerDrawError[p.errorCode] ~= nil then
    Toast(textRes.activity.SInnerDrawError[p.errorCode])
  else
    Toast(string.format(textRes.activity.SInnerDrawError[-1], p.errorCode))
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Inner_Award_Error, nil)
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_XIAO_HUI_KUAI_PAO_ACTIVITY then
    MonkeyRunMgr.Instance():CheckEntryVisible()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, nil)
  elseif params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_XIAO_HUI_KUAI_PAO_OUTER_TURN_TO_POINT_ACTIVITY then
    MonkeyRunMgr.Instance():CheckEggEntryVisible()
  end
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  MonkeyRunMgr.Instance():CheckEntryVisible()
  MonkeyRunMgr.Instance():CheckEggEntryVisible()
end
def.static("table", "table").OnEnterWorld = function(params, context)
  MonkeyRunMgr.Instance():RequireToGetEntryData()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  MonkeyRunMgr.Instance():ClearData()
end
def.static("table", "table").OnActivityStatusChane = function(params, context)
  local activityId = params[1]
  if MonkeyRunMgr.Instance():IsMonkeyRunActivity(activityId) then
    MonkeyRunMgr.Instance():CheckEntryVisible()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_OpenChange, nil)
  elseif MonkeyRunMgr.Instance():IsMonekyRunEggAwardActivity(activityId) then
    MonkeyRunMgr.Instance():CheckEggEntryVisible()
  end
end
def.static("table", "table").OpenActivityPanel = function(params, context)
  MonkeyRunMgr.Instance():RequireToShowOutAwardPanel()
  MonkeyRunMgr.Instance():MarkTodayAsShowed()
end
def.static("table", "table").OnCreditChange = function(params, context)
  MonkeyRunMgr.Instance():CheckEggEntryVisible()
end
def.method().CheckEntryVisible = function(self)
  if not _G.IsEnteredWorld() then
    return
  end
  if MonkeyRunMgr.Instance():IsActivityOpened() then
    self:ShowEntry(true)
  else
    self:ShowEntry(false)
  end
end
def.method("=>", "boolean").IsActivityOpened = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_XIAO_HUI_KUAI_PAO_ACTIVITY) then
    return false
  end
  local curActivityId = self:GetCurrentActivityId()
  if curActivityId == 0 then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckAnctivityOpenAndToast = function(self)
  if not self:IsActivityOpened() then
    Toast(textRes.activity[820])
    return false
  end
  return true
end
def.method("boolean").ShowEntry = function(self, isShow)
  local MonkeyRunEntry = require("Main.activity.MonkeyRun.ui.MonkeyRunEntry")
  if isShow then
    MonkeyRunEntry.Instance():ShowEntry()
  else
    MonkeyRunEntry.Instance():HideEntry()
  end
end
def.method("=>", "number").GetCurrentActivityId = function(self)
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityIds = MonkeyRunUtils.GetAllActivityIds()
  if #activityIds == 0 then
    warn("there is no monkey run activity in cfg")
    return 0
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  for i = 1, #activityIds do
    local isOpen = ActivityInterface.Instance():isActivityOpend2(activityIds[i])
    if isOpen then
      return activityIds[i]
    end
  end
  return 0
end
def.method("number", "=>", "boolean").IsMonkeyRunActivity = function(self, activityId)
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityIds = MonkeyRunUtils.GetAllActivityIds()
  if #activityIds == 0 then
    return false
  end
  for i = 1, #activityIds do
    if activityId == activityIds[i] then
      return true
    end
  end
  return false
end
def.method("number", "table").SetMonkeyRunOutData = function(self, activityId, data)
  if self.activityOutData == nil then
    self.activityOutData = {}
  end
  if self.activityOutData[activityId] == nil then
    self.activityOutData[activityId] = MonkeyRunOutData()
  end
  self.activityOutData[activityId]:RawSet(data)
end
def.method("number", "=>", "table").GetMonkeyRunOutData = function(self, activityId)
  local data
  if self.activityOutData ~= nil and self.activityOutData[activityId] ~= nil then
    data = self.activityOutData[activityId]
  end
  return data
end
def.method("=>", "table").GetCurActivityMonkeyRunOutData = function(self)
  local activityId = self:GetCurrentActivityId()
  return self:GetMonkeyRunOutData(activityId)
end
def.method("table").SetMonkeyRunShopData = function(self, p)
  if self.shopData == nil then
    self.shopData = MonkeyRunShopData()
  end
  self.shopData:RawSet(p)
end
def.method("=>", "table").GetMonkeyRunShopData = function(self)
  if self.shopData == nil then
    warn("monkey run shop data is nil, maybe you open it in wrong way")
  end
  return self.shopData
end
def.method("number", "table").SetMonkeyRunInnerData = function(self, activityId, data)
  if self.activityInnerData == nil then
    self.activityInnerData = {}
  end
  if self.activityInnerData[activityId] == nil then
    self.activityInnerData[activityId] = MonkeyRunInnerData()
  end
  self.activityInnerData[activityId]:RawSet(data)
end
def.method("number", "=>", "table").GetMonkeyRunInnerData = function(self, activityId)
  if self.activityInnerData == nil then
    return nil
  end
  return self.activityInnerData[activityId]
end
def.method("=>", "table").GetCurActivityMonkeyRunInnerData = function(self)
  local activityId = self:GetCurrentActivityId()
  return self:GetMonkeyRunInnerData(activityId)
end
def.method("number", "=>", "boolean").IsAllMonkeyRunInnerAwardHit = function(self, activityId)
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(activityId)
  if activityCfg == nil then
    return false
  end
  local lotteryViewCfgId = activityCfg.lotteryViewCfgId
  local ItemUtils = require("Main.Item.ItemUtils")
  local lotterCfg = ItemUtils.GetLotteryViewRandomCfg(lotteryViewCfgId)
  if lotterCfg == nil then
    warn("lottery cfg not found :" .. lotteryViewCfgId)
    return false
  end
  local innerData = self:GetMonkeyRunInnerData(activityId)
  if innerData == nil then
    return false
  end
  local isAllHit = true
  for i = 1, #lotterCfg.itemIds do
    if not innerData:IsAwardIndexHited(i) then
      isAllHit = false
      break
    end
  end
  return isAllHit
end
def.method().ClearData = function(self)
  self.activityOutData = nil
  self.shopData = nil
  self.activityInnerData = nil
  self.queryOutAwardDataCallbacks = {}
end
local OPERATION_ENTRY = 1
local OPERATION_PANEL = 2
def.method("number", "function").SetGetOutAwardDataCallback = function(self, operate, callback)
  if self.queryOutAwardDataCallbacks == nil then
    self.queryOutAwardDataCallbacks = {}
  end
  self.queryOutAwardDataCallbacks[operate] = callback
end
def.method().ProcessGetOutAwardDataCallback = function(self)
  if self.queryOutAwardDataCallbacks == nil then
    return
  end
  for op, cb in pairs(self.queryOutAwardDataCallbacks) do
    _G.SafeCallback(cb)
  end
  self.queryOutAwardDataCallbacks = {}
end
def.method().RequireToGetEntryData = function(self)
  if not self:IsActivityOpened() then
    return
  end
  local curActivityId = self:GetCurrentActivityId()
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.COuterInfoReq").new(curActivityId)
  gmodule.network.sendProtocol(req)
  self:SetGetOutAwardDataCallback(OPERATION_ENTRY, function()
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, nil)
  end)
end
def.method().RequireToShowOutAwardPanel = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local curActivityId = self:GetCurrentActivityId()
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.COuterInfoReq").new(curActivityId)
  gmodule.network.sendProtocol(req)
  self:SetGetOutAwardDataCallback(OPERATION_PANEL, function()
    if not _G.IsEnteredWorld() then
      return
    end
    self:ShowOutAwardPanel()
  end)
end
def.method().ShowOutAwardPanel = function(self)
  local MonkeyRunOuterAwardPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunOuterAwardPanel")
  MonkeyRunOuterAwardPanel.Instance():ShowPanel()
end
def.method("number", "boolean", "number").DrawOutAward = function(self, count, useYuanbao, needYuanbao)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local curActivityId = self:GetCurrentActivityId()
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  if Int64.lt(yuanBaoNum, needYuanbao) then
    _G.GotoBuyYuanbao()
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.COuterDrawReq").new(curActivityId, count, useYuanbao and 1 or 0, yuanBaoNum, Int64.new(needYuanbao))
  gmodule.network.sendProtocol(req)
end
def.method().GetOutAward = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.COuterDrawAwardFinishReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().QueryToShowExchangeShop = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.CPointExchangeInfoReq").new()
  gmodule.network.sendProtocol(req)
end
def.method().ShowMonkeyRunShop = function(self)
  local MonkeyRunShopPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunShopPanel")
  MonkeyRunShopPanel.Instance():ShowPanel()
end
def.method("number", "number").BuyMonkeyRunShopItem = function(self, itemCfgId, count)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.CPointExchangeReq").new(itemCfgId, count)
  gmodule.network.sendProtocol(req)
end
def.method().QueryToShowInnerAwardPanel = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local curActivityId = self:GetCurrentActivityId()
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.CInnerInfoReq").new(curActivityId)
  gmodule.network.sendProtocol(req)
end
def.method().ShowInnerAwardPanel = function(self)
  local MonkeyRunInnerAwardPanel = require("Main.activity.MonkeyRun.ui.MonkeyRunInnerAwardPanel")
  MonkeyRunInnerAwardPanel.Instance():ShowPanel()
end
def.method().DrawInnerAward = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local curActivityId = self:GetCurrentActivityId()
  local innerData = self:GetMonkeyRunInnerData(curActivityId)
  if innerData == nil then
    return
  end
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityCfg = MonkeyRunUtils.GetMonkeyRunActivityCfgById(curActivityId)
  if activityCfg == nil then
    return
  end
  if innerData:GetCurrentTicketCount() < activityCfg.ticketCount then
    Toast(textRes.activity[829])
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.CInnerDrawReq").new(curActivityId)
  gmodule.network.sendProtocol(req)
end
def.method().GetInnerAward = function(self)
  if not self:CheckAnctivityOpenAndToast() then
    return
  end
  local req = require("netio.protocol.mzm.gsp.xiaohuikuaipao.CInnerDrawAwardFinishReq").new()
  gmodule.network.sendProtocol(req)
end
def.method("=>", "boolean").HasMonkeyRunNotify = function(self)
  if not self:IsActivityOpened() then
    return false
  end
  local outData = self:GetCurActivityMonkeyRunOutData()
  if outData ~= nil and outData:GetTicketCount() > 0 then
    return true
  end
  return not self:HasTodayShow()
end
def.method("=>", "number").GetDateKey = function(self)
  local serverTime = _G.GetServerTime()
  local key = tonumber(os.date("%Y%m%d", serverTime))
  return key
end
local keyPrefix = "MonkeyRunDate_"
def.method("=>", "string").GetStorageKey = function(self, dateKey)
  local dateKey = self:GetDateKey()
  return keyPrefix .. tostring(dateKey)
end
def.method("=>", "boolean").HasTodayShow = function(self)
  local storageKey = self:GetStorageKey()
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return true
  end
  return false
end
def.method().MarkTodayAsShowed = function(self)
  local storageKey = self:GetStorageKey()
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_MonkeyRun_Notify_Change, nil)
end
def.method("=>", "number").GetCurrentEggAwardActivityId = function(self)
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityIds = MonkeyRunUtils.GetAllMonkeyRunEggAwardActivityIds()
  if #activityIds == 0 then
    warn("there is no monkey run egg activity in cfg")
    return 0
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  for i = 1, #activityIds do
    local isOpen = ActivityInterface.Instance():isActivityOpend2(activityIds[i])
    if isOpen then
      return activityIds[i]
    end
  end
  return 0
end
def.method("number", "=>", "boolean").IsMonekyRunEggAwardActivity = function(self, activityId)
  local MonkeyRunUtils = require("Main.activity.MonkeyRun.MonkeyRunUtils")
  local activityCfg = MonkeyRunUtils.GetMonkeyRunEggAwardActivityCfg(activityId)
  return activityCfg ~= nil
end
def.method("=>", "boolean").IsEggAwardActivityOpened = function(self)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_XIAO_HUI_KUAI_PAO_OUTER_TURN_TO_POINT_ACTIVITY) then
    return false
  end
  local curActivityId = self:GetCurrentEggAwardActivityId()
  if curActivityId == 0 then
    return false
  end
  local ItemModule = require("Main.Item.ItemModule")
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  local eggJifen = ItemModule.Instance():GetCredits(TokenType.XIAO_HUI_KUAI_PAO_COMPENSATE_POINT) or Int64.new(0)
  if not Int64.gt(eggJifen, 0) then
    return false
  end
  return true
end
def.method("=>", "boolean").CheckEggAwardActivityOpenAndToast = function(self)
  if not self:IsEggAwardActivityOpened() then
    Toast(textRes.activity[820])
    return false
  end
  return true
end
def.method().OpenMonkeyRunEggAwardActivity = function(self)
  if not self:CheckEggAwardActivityOpenAndToast() then
    return
  end
  local activityId = self:GetCurrentEggAwardActivityId()
  gmodule.moduleMgr:GetModule(ModuleId.TOKEN_MALL):OpenTokenMallByActivityId(activityId)
end
def.method("boolean").ShowEggAwardEntry = function(self, isShow)
  local MonkeyRunEggEntry = require("Main.activity.MonkeyRun.ui.MonkeyRunEggEntry")
  if isShow then
    MonkeyRunEggEntry.Instance():ShowEntry()
  else
    MonkeyRunEggEntry.Instance():HideEntry()
  end
end
def.method().CheckEggEntryVisible = function(self)
  if not _G.IsEnteredWorld() then
    return
  end
  if MonkeyRunMgr.Instance():IsEggAwardActivityOpened() then
    self:ShowEggAwardEntry(true)
  else
    self:ShowEggAwardEntry(false)
  end
end
return MonkeyRunMgr.Commit()
