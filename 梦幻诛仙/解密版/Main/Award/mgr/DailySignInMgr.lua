local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local DailySignInMgr = Lplus.Extend(AwardMgrBase, "DailySignInMgr")
local def = DailySignInMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CResult = {
  SUCCESS = 0,
  NOT_SIGN_IN = 1,
  NOT_FIRST_REDRESS_DAY = 2,
  NOT_IN_REDRESS_DAYS_RANGE = 3
}
def.const("table").CResult = CResult
def.field("table").signInStates = nil
def.field("table").awardNoticeList = nil
local instance
def.static("=>", DailySignInMgr).Instance = function()
  if instance == nil then
    instance = DailySignInMgr()
  end
  return instance
end
def.method().Init = function(self)
  self.awardNoticeList = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, DailySignInMgr.NewDay)
end
def.method().Reset = function(self)
  self.signInStates = nil
  self.awardNoticeList = {}
end
def.override("=>", "boolean").IsOpen = function(self)
  if self.signInStates == nil then
    return false
  end
  return true
end
def.method("table").SyncDailySignInState = function(self, data)
  self.signInStates = {}
  self.signInStates.lastSignDate = data.signday
  self.signInStates.signedDays = data.signcount
  self.signInStates.canRedressTimes = data.fillincount
  self.signInStates.isTodaySigned = data.issignedtoday == 1
  self.signInStates.date = {}
  self.signInStates.date.year = math.floor(data.currentdate / 10000)
  self.signInStates.date.month = math.floor(data.currentdate / 100) % 100
  self.signInStates.date.day = data.currentdate % 100
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, nil)
  self:Check2NoticeAward(data.item2num)
end
def.method("number", "number", "=>", "table").GetWholeMonthAwardList = function(self, year, month)
  local days = _G.GetDaysOfMonth(year, month)
  local dateBase = year * 10000 + month * 100
  local cfgs = AwardUtils.GetWholeMonthDailySignInAwardCfgs(dateBase)
  local awardList = {}
  for i = 1, days do
    local date = dateBase + i
    local cfg = cfgs[date]
    local awardData = {itemId = 0, num = 0}
    if cfg then
      awardData.itemId = cfg.itemId
      awardData.num = cfg.itemCount
    end
    table.insert(awardList, awardData)
  end
  return awardList
end
def.method("=>", "table").GetSignInStates = function(self)
  return self.signInStates
end
def.method("number", "=>", "boolean").IsSigned = function(self, index)
  if index <= self.signInStates.signedDays then
    return true
  else
    return false
  end
end
def.method("number", "=>", "boolean").CanSigne = function(self, index)
  if self.signInStates.isTodaySigned then
    return false
  end
  if index ~= self.signInStates.signedDays + 1 then
    return false
  end
  return true
end
def.method("number", "=>", "boolean").CanRedress = function(self, index)
  local postphone = 1
  if not self.signInStates.isTodaySigned then
    postphone = 2
  end
  local downBound = self.signInStates.signedDays + postphone
  local time = self.signInStates.date
  local minUpBound
  if time.day > downBound + self.signInStates.canRedressTimes - 1 then
    minUpBound = downBound + self.signInStates.canRedressTimes - 1
  else
    minUpBound = time.day
  end
  if index >= downBound and index <= minUpBound then
    return true
  else
    return false
  end
end
def.method("number", "=>", "number").SignInOrRedress = function(self, day)
  if self:CanSigne(day) then
    print("signin")
    self:SignIn(day)
  elseif self:CanRedress(day) then
    if not self.signInStates.isTodaySigned then
      return CResult.NOT_SIGN_IN
    end
    if not self:IsFirstRedressDay(day) then
      return CResult.NOT_FIRST_REDRESS_DAY
    end
    print("redress")
    self:Redress(day)
  else
    return CResult.NOT_IN_REDRESS_DAYS_RANGE
  end
  return CResult.SUCCESS
end
def.method("number", "=>", "boolean").IsFirstRedressDay = function(self, day)
  local postphone = 1
  if not self.signInStates.isTodaySigned then
    postphone = 2
  end
  local firstRedressDay = self.signInStates.signedDays + postphone
  return day == firstRedressDay
end
def.method("=>", "boolean").IsHaveOmitDays = function(self)
  local time = self.signInStates.date
  local postphone = 0
  if not self.signInStates.isTodaySigned then
    postphone = 1
  end
  if time.day > self.signInStates.signedDays + postphone then
    return true
  end
  return false
end
def.method("=>", "boolean").IsHaveCanRedressDays = function(self)
  if self:IsHaveOmitDays() and self.signInStates.canRedressTimes > 0 then
    return true
  end
  return false
end
def.method("=>", "boolean").IsHaveCanDrawAward = function(self)
  local signInStates = self:GetSignInStates()
  if signInStates == nil then
    return false
  end
  local rs = not signInStates.isTodaySigned or self:IsHaveCanRedressDays()
  return rs
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:IsHaveCanDrawAward()
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.method("number").SignIn = function(self, day)
  local currentdate = self.signInStates.date
  local date = currentdate.year * 10000 + currentdate.month * 100 + day
  self:C2S_SignInReq(date)
end
def.method("number").Redress = function(self, day)
  local currentdate = self.signInStates.date
  local date = currentdate.year * 10000 + currentdate.month * 100 + day
  self:C2S_ReplenishSignInReq(date)
end
def.method("number", "table").RegisterAwardNotice = function(self, day, award)
end
def.method("table").Check2NoticeAward = function(self, item2num)
  AwardUtils.Check2NoticeAward(item2num)
end
def.static("table", "table").NewDay = function()
  local self = instance
  if self.signInStates == nil then
    return
  end
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local curTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(curTime)
  local date = self.signInStates.date
  if date.year == t.year and date.month == t.month and date.day == t.day then
  else
    self.signInStates.date = {}
    self.signInStates.date.year = t.year
    self.signInStates.date.month = t.month
    self.signInStates.date.day = t.day
    self.signInStates.isTodaySigned = false
  end
  GameUtil.AddGlobalTimer(2, true, function(...)
    if gmodule.moduleMgr:GetModule(ModuleId.LOGIN).isEnteredWorld then
      gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckNotifyMessageCount()
      gmodule.moduleMgr:GetModule(ModuleId.AWARD):CheckToShowAwardPanel()
    end
  end)
end
def.method("number").C2S_SignInReq = function(self, date)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  local p = require("netio.protocol.mzm.gsp.signaward.CSignInReq").new(date, moneyData:GetHaveNum(), 0)
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[%d]", "netio.protocol.mzm.gsp.signaward.CSignInReq", date))
end
def.method("number").C2S_ReplenishSignInReq = function(self, date)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  local p = require("netio.protocol.mzm.gsp.signaward.CReplenishSignInReq").new(date, moneyData:GetHaveNum(), 0)
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[%d]", "netio.protocol.mzm.gsp.signaward.CReplenishSignInReq", date))
end
return DailySignInMgr.Commit()
