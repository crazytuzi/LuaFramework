local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = import(".RoomMgrBase")
local PetRoomMgr = Lplus.Extend(RoomMgrBase, MODULE_NAME)
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = PetRoomMgr.define
def.field("number").m_trianingTimes = 0
local instance
def.static("=>", PetRoomMgr).Instance = function(self)
  if instance == nil then
    instance = PetRoomMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_name = textRes.Homeland.RoomNames.PetRoom
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SPetRoomLevelUpRes", PetRoomMgr.OnPetRoomLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.STrainPetRes", PetRoomMgr.OnSTrainPetRes)
end
def.method("=>", "table").GetPetList = function(self)
  return PetMgr.Instance():GetSortedPetList()
end
def.method("=>", "number").GetRemainTrainingTimes = function(self)
  local remainTimes = self:GetCurMaxTrainingTimes() - self.m_trianingTimes
  remainTimes = math.max(0, remainTimes)
  return remainTimes
end
def.method("=>", "number").GetCurMaxTrainingTimes = function(self)
  local roomLevel = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetPetRoomCfg(roomLevel)
  if roomCfg == nil then
    return 0
  end
  local cleannessCfg = self:GetHouseCleannessCfg()
  local reduce = cleannessCfg.decPetRoomUseCount
  return roomCfg.dayTrainCount - reduce
end
def.override("=>", "table").GetUpgradeNeeds = function(self)
  local nextLevel = self:GetRoomNextLevel()
  local roomCfg = HomelandUtils.GetPetRoomCfg(nextLevel)
  local needs = {currencyType = 0, currencyNum = 0}
  if roomCfg then
    needs.currencyType = roomCfg.costMoneyType
    needs.currencyNum = roomCfg.costMoneyNum
  end
  return needs
end
def.override("=>", "number").GetDeductCleannessNums = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetPetRoomCfg(level)
  return roomCfg.dayCutCleanliness
end
def.override().OnDailyRest = function(self)
  self.m_trianingTimes = 0
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_PetRoom_Info, nil)
end
def.override("=>", "boolean").OnUpgradeRoom = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CPetRoomLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.override("table").SyncRoomInfo = function(self, p)
  self:SetRoomLevel(p.petRoomLevel)
  self.m_trianingTimes = p.dayTtrainPetCount
end
def.override("=>", "boolean").IsReachMaxLevel = function(self)
  local houseLevel = require("Main.Homeland.HouseMgr").Instance():GetMyHouse():GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local maxPetRoomLevel = houseCfg.maxPetRoomLevel
  return maxPetRoomLevel <= self.m_level
end
def.method("userdata", "=>", "boolean").TrainPet = function(self, petId)
  local remainTimes = self:GetRemainTrainingTimes()
  if remainTimes == 0 then
    Toast(textRes.Homeland[13])
    return false
  end
  print("TrainPet", tostring(petId))
  local p = require("netio.protocol.mzm.gsp.homeland.CTrainPetReq").new(petId)
  gmodule.network.sendProtocol(p)
  return true
end
def.static("table").OnPetRoomLevelUpRes = function(p)
  print("OnPetRoomLevelUpRes p.petRoomLevel", p.petRoomLevel)
  instance.m_level = p.petRoomLevel
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_PetRoom_Info, nil)
  local text = string.format(textRes.Homeland[28], instance.m_name, instance.m_level)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
def.static("table").OnSTrainPetRes = function(p)
  print("OnSTrainPetRes p.addExpNum", p.addExpNum)
  instance.m_trianingTimes = p.dayTtrainPetCount
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_PetRoom_Info, nil)
  local remainTimes = instance:GetRemainTrainingTimes()
  local pet = PetMgr.Instance():GetPet(p.petId)
  local petName = PetUtility.GetColoredPetNameHtml(pet)
  local addExpNum = p.addExpNum
  local text = string.format(textRes.Homeland[27], petName, RESPATH.COMMONATLAS, "Img_ExpPet", addExpNum, remainTimes)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
return PetRoomMgr.Commit()
