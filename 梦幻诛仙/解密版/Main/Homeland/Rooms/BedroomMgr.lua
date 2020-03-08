local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = import(".RoomMgrBase")
local BedroomMgr = Lplus.Extend(RoomMgrBase, MODULE_NAME)
local PetMgr = require("Main.Pet.mgr.PetMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = BedroomMgr.define
def.field("number").m_recoverEnergyTimes = 0
def.field("number").m_recoverNutritionTimes = 0
local instance
def.static("=>", BedroomMgr).Instance = function(self)
  if instance == nil then
    instance = BedroomMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_name = textRes.Homeland.RoomNames.Bedroom
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SBedRoomLevelUpRes", BedroomMgr.OnBedroomLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SAddVigorRes", BedroomMgr.OnSAddVigorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SAddSatiationRes", BedroomMgr.OnSAddSatiationRes)
end
def.override("=>", "table").GetUpgradeNeeds = function(self)
  local nextLevel = self:GetRoomNextLevel()
  local roomCfg = HomelandUtils.GetBedroomCfg(nextLevel)
  local needs = {currencyType = 0, currencyNum = 0}
  if roomCfg then
    needs.currencyType = roomCfg.costMoneyType
    needs.currencyNum = roomCfg.costMoneyNum
  end
  return needs
end
def.override("=>", "number").GetDeductCleannessNums = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetBedroomCfg(level)
  return roomCfg.dayCutCleanliness
end
def.override().OnDailyRest = function(self)
  self.m_recoverEnergyTimes = 0
  self.m_recoverNutritionTimes = 0
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, nil)
end
def.override("=>", "boolean").OnUpgradeRoom = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CBedRoomLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.override("table").SyncRoomInfo = function(self, p)
  self:SetRoomLevel(p.bedRoomLevel)
  self.m_recoverEnergyTimes = p.dayRestoreVigorCount
  self.m_recoverNutritionTimes = p.dayRestoreSatiationCount
end
def.override("=>", "boolean").IsReachMaxLevel = function(self)
  local houseLevel = require("Main.Homeland.HouseMgr").Instance():GetMyHouse():GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local maxBedRoomLevel = houseCfg.maxBedRoomLevel
  return maxBedRoomLevel <= self.m_level
end
def.method("=>", "boolean").Recovery = function(self)
  local remainTimes = self:GetRemainRecoveryTimes()
  if remainTimes == 0 then
    Toast(textRes.Homeland[16])
    return false
  end
  if 0 < self:GetRemainRecoveryEnergyTimes() then
    local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
    if HeroPropMgr.Instance():IsEnergyStorageFull() then
      Toast(textRes.Hero[62])
    else
      print("Recovery Energy")
      local p = require("netio.protocol.mzm.gsp.homeland.CAddVigorReq").new()
      gmodule.network.sendProtocol(p)
    end
  end
  if 0 < self:GetRemainRecoveryNutritionTimes() then
    local NutritionMgr = require("Main.Buff.NutritionMgr")
    if 0 < NutritionMgr.Instance():GetCanSupplementNutrition() then
      print("Recovery Nutrition")
      local p = require("netio.protocol.mzm.gsp.homeland.CAddSatiationReq").new()
      gmodule.network.sendProtocol(p)
    else
      Toast(textRes.Buff[11])
    end
  end
  return true
end
def.method("=>", "number").GetRemainRecoveryTimes = function(self)
  local limit = self:GetTodayRecoveryEffectLimit()
  local remainEnergy = self:GetRemainRecoveryEnergyTimes()
  local remainNutrition = self:GetRemainRecoveryNutritionTimes()
  return math.max(remainEnergy, remainNutrition)
end
def.method("=>", "number").GetRemainRecoveryEnergyTimes = function(self)
  local limit = self:GetTodayRecoveryEffectLimit()
  local remainTimes = math.max(0, limit.energy - self.m_recoverEnergyTimes)
  return remainTimes
end
def.method("=>", "number").GetRemainRecoveryNutritionTimes = function(self)
  local limit = self:GetTodayRecoveryEffectLimit()
  local remainTimes = math.max(0, limit.nutrition - self.m_recoverNutritionTimes)
  return remainTimes
end
def.method("=>", "table").GetRecoveryEffectPerTimes = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetBedroomCfg(level)
  local effect = {
    energy = roomCfg.addVigorNum,
    nutrition = roomCfg.addSatiationNum
  }
  return effect
end
def.method("=>", "table").GetTodayRecoveryEffectLimit = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetBedroomCfg(level)
  local cleannessCfg = self:GetHouseCleannessCfg()
  local dayRestoreVigorCount = roomCfg.dayRestoreVigorCount - cleannessCfg.decVigorUseCount
  local dayRestoreSatiationCount = roomCfg.dayRestoreSatiationCount - cleannessCfg.decSatiationUseCount
  local effect = {energy = dayRestoreVigorCount, nutrition = dayRestoreSatiationCount}
  return effect
end
def.static("table").OnBedroomLevelUpRes = function(p)
  print("OnKitchenLevelUpRes p.bedRoomLevel", p.bedRoomLevel)
  instance:SetRoomLevel(p.bedRoomLevel)
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, nil)
  local text = string.format(textRes.Homeland[28], instance.m_name, instance.m_level)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
def.static("table").OnSAddVigorRes = function(p)
  print("OnSAddVigorRes p.addVigorNum, p.dayRestoreVigorCount", p.addVigorNum, p.dayRestoreVigorCount)
  instance.m_recoverEnergyTimes = p.dayRestoreVigorCount
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, nil)
  local remainTimes = instance:GetRemainRecoveryEnergyTimes()
  local text = string.format(textRes.Homeland[29], p.addVigorNum, remainTimes)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
def.static("table").OnSAddSatiationRes = function(p)
  print("OnSAddSatiationRes p.addSatiationNum, p.dayRestoreSatiationCount", p.addSatiationNum, p.dayRestoreSatiationCount)
  instance.m_recoverNutritionTimes = p.dayRestoreSatiationCount
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Bedroom_Info, nil)
  local remainTimes = instance:GetRemainRecoveryNutritionTimes()
  local text = string.format(textRes.Homeland[30], p.addSatiationNum, remainTimes)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
return BedroomMgr.Commit()
