local MODULE_NAME = (...)
local Lplus = require("Lplus")
local HouseMgr = Lplus.Class(MODULE_NAME)
local House = require("Main.Homeland.House")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = HouseMgr.define
def.const("table").PayMethod = {
  None = -1,
  Currency = 0,
  Deed = 1
}
local instance
def.static("=>", HouseMgr).Instance = function(self)
  if instance == nil then
    instance = HouseMgr()
  end
  return instance
end
def.field(House).m_house = nil
def.field("table").m_rooms = nil
def.method().Init = function(self)
  self.m_house = House()
  self.m_house:SetLevel(1)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SHomeLevelUpRes", HouseMgr.OnSHomeLevelUpRes)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, HouseMgr.OnNewDay)
  self.m_rooms = {
    require("Main.Homeland.Rooms.BedroomMgr").Instance(),
    require("Main.Homeland.Rooms.KitchenMgr").Instance(),
    require("Main.Homeland.Rooms.MakeDrugRoomMgr").Instance(),
    require("Main.Homeland.Rooms.PetRoomMgr").Instance(),
    require("Main.Homeland.Rooms.ServantRoomMgr").Instance()
  }
end
def.method("=>", House).GetMyHouse = function(self)
  return self.m_house
end
def.method("number", "=>", "table").GetHouseLevelInfo = function(self, houseLevel)
  local houseLevel = math.max(1, houseLevel)
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local info = {
    name = houseCfg.showName,
    icon = houseCfg.picId,
    maxGeomancy = houseCfg.maxFengShui
  }
  return info
end
def.method("number", "=>", "table").GetHouseLevelUpNeeds = function(self, targetLevel)
  local houseCfg = HomelandUtils.GetHouseCfg(targetLevel)
  local needs = {}
  local currency = {
    currencyType = houseCfg.costMoneyType,
    number = Int64.new(houseCfg.costMoneyNum)
  }
  local item = {
    itemId = houseCfg.costItemId,
    number = houseCfg.costItemNum
  }
  needs.currency = currency
  needs.item = item
  return needs
end
def.method("=>", "table").GetBuildHouseNeeds = function(self)
  local initLevel = INIT_HOMELAND_LEVEL or 1
  return self:GetHouseLevelUpNeeds(initLevel)
end
def.method("number", "=>", "boolean").UpgradeMyHouse = function(self, payMethod)
  local p = require("netio.protocol.mzm.gsp.homeland.CHomeLevelUpReq").new(payMethod)
  gmodule.network.sendProtocol(p)
  return true
end
def.method("=>", "boolean").CleanMyHouse = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CCleanHomeReq").new(HomelandModule.Area.House)
  gmodule.network.sendProtocol(p)
  return true
end
def.method("table").SyncHouseInfo = function(self, p)
  self.m_house:SetLevel(p.homeLevel)
  self.m_house:SetCleanness(p.cleanliness)
  self.m_house:SetGeomancy(p.fengShuiValue)
  self.m_house:SetDayCleanCount(p.dayCleanCount)
  for i, room in ipairs(self.m_rooms) do
    room:SyncRoomInfo(p)
  end
end
def.static("number").BuildHomeService = function(npcID)
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:IsFeatureOpen() then
    Toast(textRes.Homeland[51])
    return
  end
  if homelandModule:HaveHome() then
    Toast(textRes.Homeland[50])
    return
  end
  require("Main.Homeland.ui.BuildHomelandPanel").ShowPanel()
end
def.static("=>", "boolean").IsCleanTimesUseOut = function()
  local servantRoomMgr = require("Main.Homeland.Rooms.ServantRoomMgr").Instance()
  local roomLevel = servantRoomMgr:GetRoomLevel()
  local roomCfg = HomelandUtils.GetServantRoomCfg(roomLevel)
  if roomCfg == nil then
    return true
  end
  local instance = HouseMgr.Instance()
  local dayCleanCount = instance.m_house:GetDayCleanCount()
  print("IsCleanTimesUseOut", dayCleanCount, roomCfg.dayCleanCount)
  return dayCleanCount >= roomCfg.dayCleanCount
end
def.static("number").CleanHouseService = function(npcID)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.ShareOwner) then
    return
  end
  if HouseMgr.IsCleanTimesUseOut() then
    Toast(textRes.Homeland.SCommonResultRes[9])
    return
  end
  local house = instance:GetMyHouse()
  if house:IsCleannessReachMax() then
    Toast(textRes.Homeland.SCommonResultRes[10])
    return
  end
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local servantRoomMgr = require("Main.Homeland.Rooms.ServantRoomMgr").Instance()
  local servantID = servantRoomMgr:GetWorkingServantID()
  local servantCfg = HomelandUtils.GetServantCfg(servantID)
  local cleanMoneyType = servantCfg.cleanMoneyType
  local cleanMoneyNum = servantCfg.cleanMoneyNum
  local servantName = servantRoomMgr:GetWorkingServantName()
  local moneyData = CurrencyFactory.Create(cleanMoneyType)
  local addCleanliness = servantCfg.addCleanliness
  local cleanness = house:GetCleanness()
  local maxCleanness = house:GetMaxCleanness()
  local actualAddCleanness = math.min(maxCleanness - cleanness, addCleanliness)
  local actualCostMoneyNum = cleanMoneyNum * actualAddCleanness
  local title = ""
  local desc = string.format(textRes.Homeland[40], actualCostMoneyNum, moneyData:GetName(), servantName, actualAddCleanness)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(title, desc, function(s)
    if s == 1 then
      local haveNum = moneyData:GetHaveNum()
      if haveNum:lt(actualCostMoneyNum) then
        moneyData:AcquireWithQuery()
        return
      end
      instance:CleanMyHouse()
    end
  end, nil)
end
def.static("number").HouseManagerService = function(npcID)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.ShareOwner) then
    return
  end
  require("Main.Homeland.ui.RoomManagerPanel").Instance():ShowPanel()
end
def.static("number").HouseUpgradeService = function(npcID)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.Owner) then
    return
  end
  require("Main.Homeland.ui.HouseUpgradePanel").ShowPanel()
end
def.static("number").ReturnHomeService = function(npcID)
  local homelandModule = gmodule.moduleMgr:GetModule(ModuleId.HOMELAND)
  if not homelandModule:IsFeatureOpen() then
    Toast(textRes.Homeland[52])
    return
  end
  if not homelandModule:HaveHome() then
    HouseMgr.BuildHomeService(npcID)
    return
  end
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):ReturnHome()
end
def.static("number").RenameServantService = function(npcID)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.ShareOwner) then
    return
  end
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Homeland[42], true, function(name)
    local keepPanel = true
    local isValid = HouseMgr.ValidEnteredName(name)
    if not isValid then
      return keepPanel
    end
    if SensitiveWordsFilter.ContainsSensitiveWord(name) then
      Toast(textRes.Homeland[43])
      return keepPanel
    else
      local servantRoomMgr = require("Main.Homeland.Rooms.ServantRoomMgr").Instance()
      local servantID = servantRoomMgr:GetWorkingServantID()
      servantRoomMgr:RenameServant(servantID, name)
    end
  end, nil)
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
def.static("number").ViewHouseStateService = function(npcID)
  if not HomelandModule.Instance():CheckAuthority(HomelandModule.VisitType.ShareOwner) then
    return
  end
  local contents = {}
  local content = {}
  content.npcid = npcID
  local houseLevel = instance.m_house:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local fengShuiValue = instance.m_house:GetGeomancy()
  local cleanliness = instance.m_house:GetCleanness()
  local maxFengShui = houseCfg.maxFengShui
  local maxCleanliness = houseCfg.maxCleanliness
  local fengShuiCfg = HomelandUtils.GetHouseFengShuiCfg(fengShuiValue)
  local cleanlinessCfg = HomelandUtils.GetHouseCleanlinessCfg(cleanliness)
  content.txt = string.format(textRes.Homeland[39], fengShuiValue, maxFengShui, fengShuiCfg.showName, cleanliness, maxCleanliness, cleanlinessCfg.showName)
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, nil)
end
def.static("table").OnSHomeLevelUpRes = function(p)
  print("OnSHomeLevelUpRes p.homeLevel", p.homeLevel)
  instance.m_house:SetLevel(p.homeLevel)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.House_LevelUp_Success, {
    level = p.homeLevel
  })
  local levelInfo = instance:GetHouseLevelInfo(p.homeLevel)
  local houseName = levelInfo.name
  local text = string.format(textRes.Homeland[32], houseName)
  Toast(text)
  local effectId = _G.constant.CHomelandCfgConsts.HOME_LEVEl_UP_EFFECT_ID or 0
  local effectCfg = _G.GetEffectRes(effectId)
  if effectCfg then
    local resPath = effectCfg.path
    require("Fx.GUIFxMan").Instance():Play(resPath, "House_LevelUp_Success", 0, 0, -1, false)
  end
end
def.static("table").OnSCleanHomeRes = function(p)
  print("OnSCleanHomeRes p.addCleanliness, p.dayCleanCount", p.addCleanliness, p.dayCleanCount)
  local cleanliness = instance.m_house:GetCleanness() + p.addCleanliness
  HouseMgr.SynCleanliness(cleanliness, p.dayCleanCount)
  local text = string.format(textRes.Homeland[31], p.addCleanliness)
  Toast(text)
end
def.static("table").OnSSynCleanlinessRes = function(p)
  print("OnSSynCleanlinessRes p.cleanliness, p.dayCleanCount", p.cleanliness, p.dayCleanCount)
  HouseMgr.SynCleanliness(p.cleanliness, p.dayCleanCount)
end
def.static("number", "number").SynCleanliness = function(cleanliness, dayCleanCount)
  instance.m_house:SetCleanness(cleanliness)
  instance.m_house:SetDayCleanCount(dayCleanCount)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeCleannessChange, nil)
end
def.static("table", "table").OnNewDay = function()
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):HaveHome() then
    return
  end
  local self = instance
  local house = self.m_house
  house:SetDayCleanCount(0)
  local deductcleanliness = 0
  local houseLevel = house:GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  deductcleanliness = deductcleanliness + houseCfg.dayCutCleanliness
  for i, v in ipairs(self.m_rooms) do
    deductcleanliness = deductcleanliness + v:GetDeductCleannessNums()
    v:DailyReset()
  end
  local cleanness = house:GetCleanness()
  house:SetCleanness(cleanness - deductcleanliness)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.MyHomeCleannessChange, nil)
end
return HouseMgr.Commit()
