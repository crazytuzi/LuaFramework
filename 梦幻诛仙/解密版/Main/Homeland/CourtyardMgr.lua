local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CourtyardMgr = Lplus.Class(MODULE_NAME)
local Courtyard = require("Main.Homeland.Courtyard")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local FeatureOpenListModule = Lplus.ForwardDeclare("FeatureOpenListModule")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = CourtyardMgr.define
local instance
def.static("=>", CourtyardMgr).Instance = function(self)
  if instance == nil then
    instance = CourtyardMgr()
  end
  return instance
end
def.field(Courtyard).m_courtyard = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SCourtYardLevelUpRes", CourtyardMgr.OnSCourtYardLevelUpRes)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, CourtyardMgr.OnNewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CourtyardMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CourtyardMgr.OnFunctionOpenInit)
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  local feature = FeatureOpenListModule.Instance()
  local isOpen = feature:CheckFeatureOpen(Feature.TYPE_COURT_YARD_LEVEL_UP_AND_DISPLAY)
  return isOpen
end
def.method("=>", Courtyard).GetMyCourtyard = function(self)
  if self.m_courtyard == nil then
    self.m_courtyard = Courtyard()
  end
  return self.m_courtyard
end
def.method("number", "=>", "table").GetCourtyardLevelInfo = function(self, courtyardLevel)
  local courtyardLevel = math.max(1, courtyardLevel)
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(courtyardLevel)
  local info = {
    name = courtyardCfg.showName,
    icon = courtyardCfg.picId,
    maxBeauty = courtyardCfg.maxBeauty,
    maxCleanness = courtyardCfg.maxCleanness
  }
  return info
end
def.method("number", "=>", "table").GetCourtyardLevelUpNeeds = function(self, targetLevel)
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(targetLevel)
  local needs = {}
  local currency = {
    currencyType = courtyardCfg.costMoneyType,
    number = Int64.new(courtyardCfg.costMoneyNum)
  }
  local item = {
    itemId = courtyardCfg.costItemId,
    number = courtyardCfg.costItemNum
  }
  needs.currency = currency
  needs.item = item
  return needs
end
def.method("=>", "boolean").UpgradeMyCourtyard = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CCourtYardLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.method("=>", "boolean").CleanMyCourtyard = function(self)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.ShareOwner) then
    return false
  end
  if self:IsCleanTimesUseOut() then
    Toast(textRes.Homeland.SCommonResultRes[9])
    return false
  end
  local courtyard = instance:GetMyCourtyard()
  if courtyard:IsCleannessReachMax() then
    Toast(textRes.Homeland.SCommonResultRes[10])
    return false
  end
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local courtyardLevel = courtyard:GetLevel()
  local courtyardCfg = HomelandUtils.GetCourtyardCfg(courtyardLevel)
  local addCleanness = courtyardCfg.cleanAddCleanness
  local cleanness = courtyard:GetCleanness()
  local maxCleanness = courtyard:GetMaxCleanness()
  local actualAddCleanness = math.min(maxCleanness - cleanness, addCleanness)
  local cleanMoneyNum = courtyardCfg.cleanCostPerCleanness
  local cleanMoneyType = courtyardCfg.cleanCostMoneyType
  local actualCostMoneyNum = cleanMoneyNum * actualAddCleanness
  local moneyData = CurrencyFactory.Create(cleanMoneyType)
  local title = textRes.Homeland[105]
  local desc = string.format(textRes.Homeland[106], actualCostMoneyNum, moneyData:GetName(), actualAddCleanness)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      local haveNum = moneyData:GetHaveNum()
      if haveNum:lt(actualCostMoneyNum) then
        moneyData:AcquireWithQuery()
        return
      end
      self:CCleanHomeReq()
    end
  end, nil)
  return true
end
def.method().CCleanHomeReq = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CCleanHomeReq").new(HomelandModule.Area.Courtyard)
  gmodule.network.sendProtocol(p)
end
def.method("table").SyncCourtyardInfo = function(self, p)
  local courtyard = self:GetMyCourtyard()
  courtyard:SetLevel(p.courtyard_level)
  courtyard:SetCleanness(p.courtyard_cleanliness)
  courtyard:SetDayCleanCount(p.courtyard_day_clean_count)
  courtyard:SetBeauty(p.courtyard_beautiful_value)
end
def.method("=>", "boolean").IsCleanTimesUseOut = function(self)
  local courtyard = self:GetMyCourtyard()
  local courtyardCfg = courtyard:GetCurLevelCourtyardCfg()
  local dayCleanCount = courtyard:GetDayCleanCount()
  return dayCleanCount >= courtyardCfg.cleanTimesPerDay
end
def.method("=>", "boolean").CanCourtyardBeCleand = function(self)
  if not self:IsFeatureOpen() then
    return false
  end
  if not HomelandModule.Instance():HaveHome() then
    return false
  end
  local courtyard = self:GetMyCourtyard()
  if courtyard:IsCleannessReachMax() then
    return false
  end
  if self:IsCleanTimesUseOut() then
    return false
  end
  return true
end
def.static("string", "=>", "boolean").ValidEnteredName = function(name)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(name)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Login[25])
    end
    return false
  end
end
def.static("table").OnSCourtYardLevelUpRes = function(p)
  print("OnSCourtYardLevelUpRes p.court_yard_level", p.court_yard_level)
  local courtyard = instance:GetMyCourtyard()
  courtyard:SetLevel(p.court_yard_level)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardLevelUp, {
    level = p.court_yard_level
  })
  local levelInfo = instance:GetCourtyardLevelInfo(p.court_yard_level)
  local courtyardName = levelInfo.name
  local effectId = _G.constant.CHomelandCfgConsts.court_yard_level_up_effect_id or 0
  local effectCfg = _G.GetEffectRes(effectId)
  if effectCfg then
    local resPath = effectCfg.path
    require("Fx.GUIFxMan").Instance():Play(resPath, "Courtyard_LevelUp_Success", 0, 0, -1, false)
  end
end
def.static("table").OnSCleanCourtyardRes = function(p)
  print("OnSCleanCourtyardRes p.addCleanliness, p.dayCleanCount", p.addCleanliness, p.dayCleanCount)
  local courtyard = instance:GetMyCourtyard()
  local cleanliness = courtyard:GetCleanness() + p.addCleanliness
  CourtyardMgr.SynCleanliness(cleanliness, p.dayCleanCount)
  local text = string.format(textRes.Homeland[93], p.addCleanliness)
  Toast(text)
end
def.static("table").OnSSynCleanlinessRes = function(p)
  print("OnSSynCleanlinessRes p.cleanliness, p.dayCleanCount", p.cleanliness, p.dayCleanCount)
  CourtyardMgr.SynCleanliness(p.cleanliness, p.dayCleanCount)
end
def.static("number", "number").SynCleanliness = function(cleanliness, dayCleanCount)
  local courtyard = instance:GetMyCourtyard()
  courtyard:SetCleanness(cleanliness)
  courtyard:SetDayCleanCount(dayCleanCount)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, nil)
end
def.static("table", "table").OnNewDay = function()
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
    return
  end
  local self = instance
  local courtyard = self:GetMyCourtyard()
  courtyard:SetDayCleanCount(0)
  local courtyardCfg = courtyard:GetCurLevelCourtyardCfg()
  local deductcleanness = courtyardCfg.dayCutCleanness
  local cleanness = courtyard:GetCleanness()
  courtyard:SetCleanness(cleanness - deductcleanness)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyCourtyardCleannessChange, nil)
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardFeatureChange, nil)
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  local myFeature = Feature.TYPE_COURT_YARD_LEVEL_UP_AND_DISPLAY
  if myFeature ~= params.feature then
    return
  end
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.CourtyardFeatureChange, nil)
end
return CourtyardMgr.Commit()
