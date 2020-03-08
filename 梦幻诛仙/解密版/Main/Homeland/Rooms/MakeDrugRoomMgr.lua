local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = import(".RoomMgrBase")
local MakeDrugRoomMgr = Lplus.Extend(RoomMgrBase, MODULE_NAME)
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = MakeDrugRoomMgr.define
local instance
def.static("=>", MakeDrugRoomMgr).Instance = function(self)
  if instance == nil then
    instance = MakeDrugRoomMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_name = textRes.Homeland.RoomNames.MakeDrugRoom
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SDrugRoomLevelUpRes", MakeDrugRoomMgr.OnDrugRoomLevelUpRes)
end
def.override("=>", "table").GetUpgradeNeeds = function(self)
  local nextLevel = self:GetRoomNextLevel()
  local roomCfg = HomelandUtils.GetMakeDrugRoomCfg(nextLevel)
  local needs = {currencyType = 0, currencyNum = 0}
  if roomCfg then
    needs.currencyType = roomCfg.costMoneyType
    needs.currencyNum = roomCfg.costMoneyNum
  end
  return needs
end
def.override("=>", "number").GetDeductCleannessNums = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetMakeDrugRoomCfg(level)
  return roomCfg.dayCutCleanliness
end
def.override("=>", "boolean").OnUpgradeRoom = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CDrugRoomLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.override("table").SyncRoomInfo = function(self, p)
  self:SetRoomLevel(p.drugRoomLevel)
end
def.override("=>", "boolean").IsReachMaxLevel = function(self)
  local houseLevel = require("Main.Homeland.HouseMgr").Instance():GetMyHouse():GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local maxDrugRoomLevel = houseCfg.maxDrugRoomLevel
  return maxDrugRoomLevel <= self.m_level
end
def.method("=>", "boolean").OpenMakeDrugPanel = function(self)
  local Operation = require("Main.Item.Operations.OperationYaoCai")
  Operation():Operate(0, 0, nil, nil)
  return true
end
def.method("=>", "number").GetDoubleRate = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetMakeDrugRoomCfg(level)
  return roomCfg.doubleRate
end
def.method("=>", "table").GetEnergyInfo = function(self)
  local energyInfo = {cur = 0, max = 0}
  local prop = HeroPropMgr.Instance():GetHeroProp()
  energyInfo.cur = prop.energy
  energyInfo.max = prop:GetMaxEnergy()
  return energyInfo
end
def.static("table").OnDrugRoomLevelUpRes = function(p)
  print("OnDrugRoomLevelUpRes p.drugRoomLevel", p.drugRoomLevel)
  instance.m_level = p.drugRoomLevel
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_MakeDrugRoom_Info, nil)
  local text = string.format(textRes.Homeland[28], instance.m_name, instance.m_level)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
return MakeDrugRoomMgr.Commit()
