local MODULE_NAME = (...)
local Lplus = require("Lplus")
local RoomMgrBase = import(".RoomMgrBase")
local ServantRoomMgr = Lplus.Extend(RoomMgrBase, MODULE_NAME)
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local def = ServantRoomMgr.define
def.field("table").m_ownedServants = nil
def.field("number").m_workingServantID = 0
local instance
def.static("=>", ServantRoomMgr).Instance = function(self)
  if instance == nil then
    instance = ServantRoomMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.m_name = textRes.Homeland.RoomNames.ServantRoom
  self.m_ownedServants = {}
  self.m_level = 3
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SMaidRoomLevelUpRes", ServantRoomMgr.OnMaidRoomLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SInviteMaidRes", ServantRoomMgr.OnSInviteMaidRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SChangeMaidRes", ServantRoomMgr.OnSChangeMaidRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.homeland.SMaidRenameRes", ServantRoomMgr.OnSMaidRenameRes)
end
def.override("=>", "table").GetUpgradeNeeds = function(self)
  local nextLevel = self:GetRoomNextLevel()
  local roomCfg = HomelandUtils.GetServantRoomCfg(nextLevel)
  local needs = {currencyType = 0, currencyNum = 0}
  if roomCfg then
    needs.currencyType = roomCfg.costMoneyType
    needs.currencyNum = roomCfg.costMoneyNum
  end
  return needs
end
def.override("=>", "number").GetDeductCleannessNums = function(self)
  local level = self:GetRoomLevel()
  local roomCfg = HomelandUtils.GetServantRoomCfg(level)
  return roomCfg.dayCutCleanliness
end
def.override("=>", "boolean").OnUpgradeRoom = function(self)
  local p = require("netio.protocol.mzm.gsp.homeland.CMaidRoomLevelUpReq").new()
  gmodule.network.sendProtocol(p)
  return true
end
def.override("table").SyncRoomInfo = function(self, p)
  self:SetRoomLevel(p.maidRoomLevel)
  self.m_ownedServants = {}
  self.m_workingServantID = 0
  for k, v in pairs(p.hasMaids) do
    self.m_ownedServants[v.maidId] = {
      uuid = k,
      name = v.name
    }
    if p.currentMaidUuid == k then
      self.m_workingServantID = v.maidId
    end
  end
end
def.override("=>", "boolean").IsReachMaxLevel = function(self)
  local houseLevel = require("Main.Homeland.HouseMgr").Instance():GetMyHouse():GetLevel()
  local houseCfg = HomelandUtils.GetHouseCfg(houseLevel)
  local maxMaidRoomLevel = houseCfg.maxMaidRoomLevel
  return maxMaidRoomLevel <= self.m_level
end
def.method("number", "=>", "table").GetServantInfo = function(self, servantID)
  local info
  if self.m_ownedServants[servantID] then
    info = {}
    info.id = servantID
    info.name = _G.GetStringFromOcts(self.m_ownedServants[servantID].name)
    info.uuid = self.m_ownedServants[servantID].uuid
  end
  return info
end
def.method("userdata", "=>", "table").GetServantInfoByUUID = function(self, uuid)
  if self.m_ownedServants == nil then
    return nil
  end
  local info
  for k, v in pairs(self.m_ownedServants) do
    if v.uuid == uuid then
      info = {}
      info.id = k
      info.name = _G.GetStringFromOcts(v.name)
      info.uuid = v.uuid
      break
    end
  end
  return info
end
def.method("number", "=>", "boolean").HasServantHired = function(self, servantID)
  return self:GetServantInfo(servantID) ~= nil
end
def.method("number", "=>", "boolean").IsServantWorking = function(self, servantID)
  return servantID == self.m_workingServantID
end
def.method("=>", "number").GetWorkingServantID = function(self)
  return self.m_workingServantID
end
def.method("=>", "string").GetWorkingServantName = function(self)
  local servantInfo = self:GetServantInfo(self.m_workingServantID)
  return servantInfo and servantInfo.name or "ICEY"
end
def.method("=>", "table").GetPreviewServantList = function(self)
  local previewList = {}
  local startLevel = _G.constant.CHomelandCfgConsts.INIT_MAIDROOM_LEVEL
  local endLevel = self:GetRoomLevel()
  local servantIDMap = {}
  for level = startLevel, endLevel do
    local roomCfg = HomelandUtils.GetServantRoomCfg(level)
    for i, v in ipairs(roomCfg.maidIds) do
      if servantIDMap[v] == nil then
        local info = {}
        info.servantID = v
        info.roomLevel = level
        local servantInfo = self:GetServantInfo(v)
        if servantInfo then
          info.servantName = servantInfo.name
        end
        servantIDMap[v] = v
        previewList[#previewList + 1] = info
      end
    end
  end
  return previewList
end
def.method("number").HireServant = function(self, servantID)
  local p = require("netio.protocol.mzm.gsp.homeland.CInviteMaidReq").new(servantID)
  gmodule.network.sendProtocol(p)
end
def.method("number").ChangeServant = function(self, servantID)
  print("ChangeServant", servantID)
  local servantInfo = self:GetServantInfo(servantID)
  local servantUUID = servantInfo.uuid
  local p = require("netio.protocol.mzm.gsp.homeland.CChangeMaidReq").new(servantUUID)
  gmodule.network.sendProtocol(p)
end
def.method("number", "string").RenameServant = function(self, servantID, name)
  local servantInfo = self:GetServantInfo(servantID)
  local servantUUID = servantInfo.uuid
  local Octets = require("netio.Octets")
  local p = require("netio.protocol.mzm.gsp.homeland.CMaidRenameReq").new(servantUUID, Octets.rawFromString(name))
  gmodule.network.sendProtocol(p)
end
def.static("table").OnMaidRoomLevelUpRes = function(p)
  print("OnMaidRoomLevelUpRes p.maidRoomLevel", p.maidRoomLevel)
  instance.m_level = p.maidRoomLevel
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_ServantRoom_Info, nil)
  local text = string.format(textRes.Homeland[28], instance.m_name, instance.m_level)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.SendOut(text)
end
def.static("table").OnSInviteMaidRes = function(p)
  local servantName = _G.GetStringFromOcts(p.maidInfo.name)
  print("OnSInviteMaidRes p.maidId, servantName", p.maidInfo.maidId, servantName)
  instance.m_ownedServants = instance.m_ownedServants or {}
  instance.m_ownedServants[p.maidInfo.maidId] = {
    name = p.maidInfo.name,
    uuid = p.maidUuid
  }
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Hire_Servant_Success, {
    servantID = p.maidId
  })
  if servantName then
    Toast(string.format(textRes.Homeland[21], servantName))
  end
end
def.static("table").OnSChangeMaidRes = function(p)
  local servantInfo = instance:GetServantInfoByUUID(p.maidUuid)
  if servantInfo == nil then
    warn(string.format("OnSChangeMaidRes: Servant not found for uuid=%s", p.maidUuid))
    return
  end
  print("OnSChangeMaidRes p.maidId", servantInfo.id)
  instance.m_workingServantID = servantInfo.id
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Change_Servant_Success, {
    servantID = servantInfo.id
  })
  Event.DispatchEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.Sync_ServantRoom_Info, nil)
  local servantName = servantInfo.name
  if servantName then
    Toast(string.format(textRes.Homeland[22], servantName))
  end
end
def.static("table").OnSMaidRenameRes = function(p)
  local servantInfo = instance:GetServantInfoByUUID(p.maidUuid)
  if servantInfo == nil then
    warn(string.format("OnSMaidRenameRes: Servant not found for uuid=%s", p.maidUuid))
    return
  end
  local servantName = _G.GetStringFromOcts(p.name)
  print("OnSMaidRenameRes p.maidId, p.name", servantInfo.id, servantName)
  instance.m_ownedServants[servantInfo.id].name = p.name
  Toast(textRes.Homeland[44])
end
return ServantRoomMgr.Commit()
