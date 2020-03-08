local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = import(".RoomMgrBase")
local KitchenMgr = Lplus.Extend(RoomMgrBase, MODULE_NAME)
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = KitchenMgr.define
local instance
def.static("=>", KitchenMgr).Instance = function(self)
  if instance == nil then
    instance = KitchenMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_name = textRes.Homeland.RoomNames.Kitchen
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SKitchenLevelUpRes", KitchenMgr.OnKitchenLevelUpRes)
end
def.override("=>", "table").GetUpgradeNeeds = function(self)
  local nextLevel = self:GetRoomNextLevel()
  local roomCfg = HomelandUtils.GetKitchenCfg(nextLevel)
  local needs = {currencyType = 0, currencyNum = 0}
  if roomCfg then
    needs.currencyType = roomCfg.costMoneyType
    needs.currencyNum = roomCfg.costMoneyNum
  end
  return needs
end
def.override("=>", "number").GetDeductCleannessNums = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetKitchenCfg(level)
  return roomCfg.dayCutCleanliness
end
def.override("=>", "boolean").OnUpgradeRoom = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CKitchenLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.override("table").SyncRoomInfo = function(self, p)
  self:SetRoomLevel(p.kitchenLevel)
end
def.override("=>", "boolean").IsReachMaxLevel = function(self)
  local houseLevel = require("Main.Homeland.HouseMgr").Instance():GetMyHouse():GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local maxKitchenLevel = houseCfg.maxKitchenLevel
  return maxKitchenLevel <= self.m_level
end
def.method("=>", "boolean").OpenCookingPanel = function(self)
  local Operation = require("Main.Grow.Operations.LocateCookingSkill")
  Operation():Operate(nil)
  return true
end
def.method("=>", "number").GetDoubleRate = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetKitchenCfg(level)
  return roomCfg.doubleRate
end
def.method("=>", "table").GetEnergyInfo = function(self)
  local energyInfo = {cur = 0, max = 0}
  local prop = HeroPropMgr.Instance():GetHeroProp()
  energyInfo.cur = prop.energy
  energyInfo.max = prop:GetMaxEnergy()
  return energyInfo
end
def.static("table").OnKitchenLevelUpRes = function(p)
  print("OnKitchenLevelUpRes p.kitchenLevel", p.kitchenLevel)
  instance.m_level = p.kitchenLevel
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_Kitchen_Info, nil)
  local text = string.format(textRes.Homeland[28], instance.m_name, instance.m_level)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
return KitchenMgr.Commit()
