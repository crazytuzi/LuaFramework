local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AwardModule = Lplus.Extend(ModuleBase, "AwardModule")
local AwardUIMgr = require("Main.Award.AwardUIMgr")
local EnterWorldAlertMgr = require("Main.Common.EnterWorldAlertMgr")
local def = AwardModule.define
def.field("number").notifyMessageCount = -1
def.field("boolean").hasShowed = false
def.field("table").offlineAward = nil
local instance
def.static("=>", AwardModule).Instance = function()
  if instance == nil then
    instance = AwardModule()
    instance.m_moduleId = ModuleId.AWARD
  end
  return instance
end
def.override().Init = function(self)
  AwardUIMgr.Instance():Init()
  EnterWorldAlertMgr.Instance():RegisterEx(EnterWorldAlertMgr.CustomOrder.AwardPanel, AwardModule.OnEnterWorldAlert, self, {reconnectAlert = true})
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AwardModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, function()
    self:SyncHeroLevel()
  end)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, function()
    self:SyncHeroLevel()
  end)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, AwardModule.OnAchievementGoaInfoChagnge)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, AwardModule.OnStartWorkChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, AwardModule.OnStartWorkChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, AwardModule.OnStartWorkChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, AwardModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, AwardModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.ALLOWPUSH_RED_CHANGE, AwardModule.OnAllowPushRedChange)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, AwardModule.OnBackExpInfoChange)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, AwardModule.OnMondayFreeInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSignAwardErrorInfo", AwardModule.OnSSignAwardErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSignInRes", AwardModule.OnSSignInRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SLoginAwardRes", AwardModule.OnSLoginAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SLevelAwardRes", AwardModule.OnSLevelAwardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSyncOfflineExpReward", AwardModule.onSSyncOfflineExpReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSynOnlineTimeRes", AwardModule.OnSSynOnlineTimeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SSynAwardedRes", AwardModule.OnSSynAwardedRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SGetAwardbeforeSignRes", AwardModule.OnSGetAwardbeforeSignRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.signaward.SynAwardBeforeSignRes", AwardModule.OnSynAwardBeforeSignRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncLevelGrowthFundActivityInfo", AwardModule.OnSSyncLevelGrowthFundActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetLevelGrowthFundActivityAwardSuccess", AwardModule.OnSGetLevelGrowthFundActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetLevelGrowthFundActivityAwardFailed", AwardModule.OnSGetLevelGrowthFundActivityAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncMonthCardActivityInfo", AwardModule.OnSSyncMonthCardActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetMonthCardActivityAwardSuccess", AwardModule.OnSGetMonthCardActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetMonthCardActivityAwardFailed", AwardModule.OnSGetMonthCardActivityAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SAwardNormalResult", AwardModule.OnSAwardNormalResult)
  require("Main.Award.mgr.GiftMgr").Instance():Init()
  require("Main.Award.mgr.StorageExpMgr").Instance():Init()
  require("Main.Award.mgr.FlipCardAwardMgr").Instance():Init()
  require("Main.Award.mgr.FirstRechargeMgr").Instance():Init()
  require("Main.Award.mgr.LoginAlertMgr").Instance():Init()
  require("Main.Award.mgr.GiftAwardMgr").Instance():Init()
  require("Main.Award.mgr.LotteryAwardMgr").Instance():Init()
  require("Main.Award.mgr.RechargeLeijiMgr").Instance():Init()
  require("Main.Award.mgr.HeroReturnMgr").Instance():Init()
  require("Main.Award.mgr.DailyGiftMgr").Instance():Init()
  require("Main.Award.mgr.DailySignInMgr").Instance():Init()
  require("Main.Award.mgr.BackExpMgr").Instance():Init()
  require("Main.Award.mgr.WechatInviteAwardMgr").Instance():Init()
  require("Main.Award.mgr.NewDailySignInMgr").Instance():Init()
  require("Main.Award.mgr.ExchangeYuanBaoMgr").Instance():Init()
  require("Main.Award.mgr.LunhuiTreasureMgr").Instance():Init()
  require("Main.Award.mgr.MondayFreeMgr").Instance():Init()
  require("Main.Award.mgr.ActivityRetrieveMgr").Instance():Init()
end
def.method("=>", "number").GetNotifyMessageCount = function(self)
  local count = 0
  count = count + require("Main.Award.mgr.DailySignInMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.AccumulativeLoginMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.LevelUpAwardMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.OnlineAwardMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.FirstRechargeMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.MonthCardMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.GrowFundMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.RechargeLeijiMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.DailyGiftMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.HeroReturnMgr").Instance():GetNotifyMessageCount()
  local startWork = require("Main.CustomActivity.CustomActivityInterface").Instance():IsStartWorkHasThing() and 1 or 0
  count = count + startWork
  local allowPush = require("Main.CustomActivity.CustomActivityInterface").Instance():IsAllowPushRed() and 1 or 0
  count = count + allowPush
  count = count + require("Main.Award.mgr.BackExpMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Vote.mgr.FeatureVoteMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.WechatInviteAwardMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.NewDailySignInMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.MondayFreeMgr").Instance():GetNotifyMessageCount()
  count = count + require("Main.Award.mgr.ActivityRetrieveMgr").Instance():GetNotifyMessageCount()
  return count
end
def.method().CheckNotifyMessageCount = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
    return
  end
  local count = self:GetNotifyMessageCount()
  if count ~= self.notifyMessageCount then
    self.notifyMessageCount = count
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NOTIFY_MESSAGE_COUNT_UPDATE, {count})
  end
end
def.method().UpdateNotifyMessages = function(self)
  self:CheckNotifyMessageCount()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_TAB_NOTIFY_UPDATE, nil)
end
def.override().OnReset = function(self)
  self.notifyMessageCount = -1
  self.hasShowed = false
  self.offlineAward = nil
end
def.method().SyncHeroLevel = function(self)
  local LevelUpAwardMgr = require("Main.Award.mgr.LevelUpAwardMgr")
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  LevelUpAwardMgr.Instance():SyncHeroLevel(heroLevel)
  instance:CheckNotifyMessageCount()
end
def.method("table").UpdateStartWork = function(self, params)
end
def.static("table", "table").OnEnterWorld = function(params)
  local enterType = params and params.enterType or 0
  local LoginModule = Lplus.ForwardDeclare("LoginModule")
  if enterType == LoginModule.EnterWorldType.NORMAL then
    AwardUIMgr.Instance():ShowOfflineAward(instance.offlineAward)
  end
end
def.method().OnEnterWorldAlert = function(self)
  self:CheckToShowAwardPanel()
end
def.method().CheckToShowAwardPanel = function(self)
  local DailySignInMgr = require("Main.Award.mgr.DailySignInMgr")
  local signInStates = DailySignInMgr.Instance():GetSignInStates()
  if signInStates == nil then
    EnterWorldAlertMgr.Instance():Next()
    return
  end
  local isSignedToday = signInStates.isTodaySigned
  local isAwardUnlock = self:IsAwardUnlock()
  if not isSignedToday and isAwardUnlock then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.OPEN_AWARD_PANEL_REQ, nil)
    self.hasShowed = true
  else
    EnterWorldAlertMgr.Instance():Next()
  end
end
def.method("=>", "boolean").IsAwardUnlock = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  local FuncType = require("consts.mzm.gsp.guide.confbean.FunType")
  local GuideModule = Lplus.ForwardDeclare("GuideModule")
  if _G.guide_open and GuideModule.Instance():CheckFunction(FuncType.AWARD) then
    return true
  else
    return false
  end
end
def.static("table").OnSSignAwardErrorInfo = function(data)
  print("OnSSignAwardErrorInfo", data.resCode)
  local text = textRes.Award.SSignAwardErrorInfo[data.resCode]
  if text then
    Toast(text)
  end
end
def.static("table", "table").OnStartWorkChange = function(p1, p2)
  instance:CheckNotifyMessageCount()
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  instance:CheckNotifyMessageCount()
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  if p1.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PUSH_AWARD then
    instance:CheckNotifyMessageCount()
  end
end
def.static("table", "table").OnAllowPushRedChange = function()
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSSignInRes = function(data)
  print("OnSSignInRes")
  require("Main.Award.mgr.DailySignInMgr").Instance():SyncDailySignInState(data)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSLoginAwardRes = function(data)
  print("OnSLoginAwardRes")
  require("Main.Award.mgr.AccumulativeLoginMgr").Instance():SyncLoginAward(data)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSLevelAwardRes = function(data)
  print("OnSLevelAwardRes")
  require("Main.Award.mgr.LevelUpAwardMgr").Instance():SyncLevelUpAward(data)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSSynOnlineTimeRes = function(data)
  print("OnSSynOnlineTimeRes")
  require("Main.Award.mgr.OnlineAwardMgr").Instance():SyncOnlineTime(data)
end
def.static("table").OnSSynAwardedRes = function(data)
  print("OnSSynAwardedRes")
  require("Main.Award.mgr.OnlineAwardMgr").Instance():SyncOnlineAward(data)
  instance:CheckNotifyMessageCount()
end
def.static("table").onSSyncOfflineExpReward = function(p)
  instance.offlineAward = {
    offlineMinute = p.offlineMinute,
    rewardExp = p.rewardExp
  }
end
def.static("table").OnSSyncLevelGrowthFundActivityInfo = function(p)
  local growFundMgr = require("Main.Award.mgr.GrowFundMgr").Instance()
  growFundMgr:SyncGrowFund(p)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSGetLevelGrowthFundActivityAwardSuccess = function(p)
  local growFundMgr = require("Main.Award.mgr.GrowFundMgr").Instance()
  growFundMgr:updateGrowFund(p)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSGetLevelGrowthFundActivityAwardFailed = function(p)
  if p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetLevelGrowthFundActivityAwardFailed").ERROR_NOT_PURCHASE_FUND then
    Toast(textRes.Award[54])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetLevelGrowthFundActivityAwardFailed").ERROR_LEVEL_NOT_MEET then
    Toast(textRes.Award[55])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetLevelGrowthFundActivityAwardFailed").ERROR_ALREADY_GET_AWARD then
    Toast(textRes.Award[56])
  end
end
def.static("table").OnSGetAwardbeforeSignRes = function(p)
  local mgr = require("Main.Award.mgr.FresherSignInMgr").Instance()
  mgr:updateFresherSignInInfo(p)
end
def.static("table").OnSynAwardBeforeSignRes = function(p)
  local mgr = require("Main.Award.mgr.FresherSignInMgr").Instance()
  mgr:SetFresherSignInInfo(p)
end
def.static("table").OnSSyncMonthCardActivityInfo = function(p)
  local mgr = require("Main.Award.mgr.MonthCardMgr").Instance()
  mgr:setMonthCardInfo(p)
end
def.static("table").OnSGetMonthCardActivityAwardSuccess = function(p)
  local mgr = require("Main.Award.mgr.MonthCardMgr").Instance()
  mgr:updateMonthCardInfo(p)
  instance:CheckNotifyMessageCount()
end
def.static("table").OnSGetMonthCardActivityAwardFailed = function(p)
  if p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetMonthCardActivityAwardFailed").ERROR_NOT_PURCHASE then
    Toast(textRes.Award[66])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetMonthCardActivityAwardFailed").ERROR_REMAIN_DAYS then
    Toast(textRes.Award[67])
  elseif p.retcode == require("netio.protocol.mzm.gsp.qingfu.SGetMonthCardActivityAwardFailed").ERROR_ALREADY_GET_AWARD then
    Toast(textRes.Award[68])
  end
end
def.static("table").OnSAwardNormalResult = function(p)
  if p.result == p.BAG_FULL_CANNOT_AWARD then
    local bagId = p.args[1]
    local bagName = bagId and textRes.Item[bagId] or textRes.Item[require("Main.Item.ItemModule").BAG]
    Toast(string.format(textRes.Item[13002], bagName))
    return
  end
  local formatStr = textRes.Award.SAwardNormalResult[p.result]
  if formatStr == nil then
    warn("SAwardNormalResult not handle ", p.result)
    return
  end
  local text = string.format(formatStr, unpack(p.args))
  Toast(text)
end
def.static("table", "table").OnAchievementGoaInfoChagnge = function(p1, p2)
  if p1[1] == constant.CCarnivalConsts.carnivalActivityId then
    instance:CheckNotifyMessageCount()
  end
end
def.static("table", "table").OnBackExpInfoChange = function(p1, p2)
  instance:CheckNotifyMessageCount()
end
def.static("table", "table").OnMondayFreeInfoChange = function(p1, p2)
  instance:CheckNotifyMessageCount()
end
return AwardModule.Commit()
