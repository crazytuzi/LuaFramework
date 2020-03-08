local Lplus = require("Lplus")
local WatchGameMgr = Lplus.Class("WatchGameMgr")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local RoundRobinRoundStage = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinRoundStage")
local CrossBattleSelectionMgr = require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr")
local ServerListMgr = require("Main.Login.ServerListMgr")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local def = WatchGameMgr.define
local instance
def.field("number").roundRobinIdx = 0
def.field("function").roundRobinCallback = nil
def.field("number").selectionIdx = 0
def.field("number").selectionZoneId = 0
def.field("function").selectionFightInfoCallback = nil
def.field("number").finalIdx = 0
def.field("function").finalFightInfoCallback = nil
def.static("=>", WatchGameMgr).Instance = function()
  if instance == nil then
    instance = WatchGameMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.Cross_Battle_Round_Robin_Info_Success, WatchGameMgr.OnRoundInfoChange)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Receive_Selection_Fight_Info, WatchGameMgr.OnSelectionFightInfo)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleFinal.Receive_Final_Fight_Info, WatchGameMgr.OnFinalFightInfo)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Receive_Own_Server_Selection_Fight_Info, WatchGameMgr.OnOwnServerSelectionFightInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.method().Reset = function(self)
  self.roundRobinIdx = 0
  self.roundRobinCallback = nil
  self.selectionIdx = 0
  self.selectionZoneId = 0
  self.selectionFightInfoCallback = nil
  self.finalIdx = 0
  self.finalFightInfoCallback = nil
end
def.static("table", "table").OnRoundInfoChange = function(p1, p2)
  if instance then
    instance:callBackRoundRobinFightInfo()
  end
end
def.static("table", "table").OnSelectionFightInfo = function(p1, p2)
  if instance then
    instance:callbackSelectionFightInfo(p1)
  end
end
def.static("table", "table").OnOwnServerSelectionFightInfo = function(p1, p2)
  if instance then
    instance:callbackOwnServerSelectionFightInfo(p1)
  end
end
def.static("table", "table").OnFinalFightInfo = function(p1, p2)
  if instance then
    instance:callbackFinalFightInfo(p1)
  end
end
def.method("userdata", "string", "number", "number", "=>", "table").newFightInfo = function(self, corpsId, name, badgeId, zoneId)
  local serverName = ""
  if zoneId > 0 then
    local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneId)
    serverName = serverCfg and serverCfg.name or "unknown_" .. zoneId
  end
  local corpsInfo = {}
  corpsInfo.corpsId = corpsId
  corpsInfo.name = name
  corpsInfo.badgeId = badgeId
  corpsInfo.serverName = serverName
  return corpsInfo
end
def.method().callBackRoundRobinFightInfo = function(self)
  if self.roundRobinIdx > 0 and self.roundRobinCallback then
    local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(self.roundRobinIdx)
    if fightInfos then
      local infos = {}
      warn("-----------callBackRoundRobinFightInfo:", fightInfos.stage)
      for i, v in ipairs(fightInfos.fightInfos) do
        local t = {}
        t.state = v.state
        local corpsA = v.corps_a_brief_info
        t.corps1 = self:newFightInfo(corpsA.corpsId, GetStringFromOcts(corpsA.name), corpsA.corpsBadgeId, 0)
        local corpsB = v.corps_b_brief_info
        t.corps2 = self:newFightInfo(corpsB.corpsId, GetStringFromOcts(corpsB.name), corpsB.corpsBadgeId, 0)
        table.insert(infos, t)
      end
      self.roundRobinCallback(infos)
      self.roundRobinIdx = 0
      self.roundRobinCallback = nil
    end
  end
  return
end
def.method("number", "function").getRoundRobinLiveFightInfo = function(self, idx, callback)
  self.roundRobinIdx = idx
  self.roundRobinCallback = callback
  local fightInfos = CrossBattleInterface.Instance():getRoundRobinFightInfo(idx)
  if fightInfos then
    self:callBackRoundRobinFightInfo()
  else
    local p = require("netio.protocol.mzm.gsp.crossbattle.CGetRoundRobinRoundInfoInCrossBattleReq").new(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, idx)
    gmodule.network.sendProtocol(p)
    warn("--------watchGameMgr CGetRoundRobinRoundInfoInCrossBattleReq:", idx)
  end
end
def.method("number", "number", "function").getSelectionFightInfo = function(self, idx, zoneId, callback)
  self.selectionIdx = idx
  self.selectionZoneId = zoneId
  self.selectionFightInfoCallback = callback
  CrossBattleSelectionMgr.Instance():QueryZoneSelectionFightInfo(zoneId, idx)
end
def.method("table").callbackSelectionFightInfo = function(self, fightInfo)
  warn("---------callBackRoundRobinFightInfo:", self.selectionFightInfoCallback, fightInfo.stage, self.selectionIdx, fightInfo.zoneId, self.selectionZoneId)
  if self.selectionFightInfoCallback then
    local idx = fightInfo.stage
    local zoneId = fightInfo.zoneId
    if idx == self.selectionIdx and zoneId == self.selectionZoneId then
      local fightInfoList = {}
      for i, v in ipairs(fightInfo.fightInfo) do
        local t = {}
        t.state1 = v:GetCorpsAState()
        t.state2 = v:GetCorpsBState()
        t.fightRecordId = v:GetFightRecordId()
        local cropsId1 = v:GetCorpsAId()
        local cropsInfo1 = fightInfo.corpsMap[cropsId1:tostring()]
        local cropsId2 = v:GetCorpsBId()
        local cropsInfo2 = fightInfo.corpsMap[cropsId2:tostring()]
        if cropsInfo1 then
          t.corps1 = self:newFightInfo(cropsId1, cropsInfo1:GetCorpsName(), cropsInfo1:GetCorpsIcon(), cropsInfo1:GetZoneId())
        end
        if cropsInfo2 then
          t.corps2 = self:newFightInfo(cropsId2, cropsInfo2:GetCorpsName(), cropsInfo2:GetCorpsIcon(), cropsInfo2:GetZoneId())
        end
        table.insert(fightInfoList, t)
      end
      self.selectionFightInfoCallback(fightInfoList)
      self.selectionIdx = 0
      self.selectionZoneId = 0
      self.selectionFightInfoCallback = nil
    end
  end
end
def.method("number", "function").getOwnServerSelectionFightInfo = function(self, selectionIdx, callback)
  self.selectionIdx = selectionIdx
  self.selectionFightInfoCallback = callback
  CrossBattleSelectionMgr.Instance():QueryOwnServerSelectionFightInfo(selectionIdx)
end
def.method("table").callbackOwnServerSelectionFightInfo = function(self, fightInfo)
  warn("---------callbackOwnServerSelectionFightInfo:", self.selectionFightInfoCallback, fightInfo.stage, self.selectionIdx, fightInfo.zoneId)
  if self.selectionFightInfoCallback then
    local idx = fightInfo.stage
    if idx == self.selectionIdx then
      local fightInfoList = {}
      for i, v in ipairs(fightInfo.fightInfo) do
        local t = {}
        t.state1 = v:GetCorpsAState()
        t.state2 = v:GetCorpsBState()
        t.fightRecordId = v:GetFightRecordId()
        local cropsId1 = v:GetCorpsAId()
        local cropsInfo1 = fightInfo.corpsMap[cropsId1:tostring()]
        local cropsId2 = v:GetCorpsBId()
        local cropsInfo2 = fightInfo.corpsMap[cropsId2:tostring()]
        if cropsInfo1 and cropsInfo2 then
          t.corps1 = self:newFightInfo(cropsId1, cropsInfo1:GetCorpsName(), cropsInfo1:GetCorpsIcon(), cropsInfo1:GetZoneId())
          t.corps2 = self:newFightInfo(cropsId2, cropsInfo2:GetCorpsName(), cropsInfo2:GetCorpsIcon(), cropsInfo2:GetZoneId())
          table.insert(fightInfoList, t)
        end
      end
      self.selectionFightInfoCallback(fightInfoList)
      self.selectionIdx = 0
      self.selectionFightInfoCallback = nil
    end
  end
end
def.method("number", "function").getFinalFightInfo = function(self, finalIdx, callback)
  self.finalIdx = finalIdx
  self.finalFightInfoCallback = callback
  CrossBattleFinalMgr.Instance():QueryZoneFinalFightInfo(1, finalIdx)
  warn("---------getFinalFightInfo:", finalIdx)
end
def.method("table").callbackFinalFightInfo = function(self, finalInfo)
  warn("------callbackFinalFightInfo:", self.finalFightInfoCallback, self.finalIdx, finalInfo.stage)
  if self.finalFightInfoCallback and self.finalIdx == finalInfo.stage then
    local fightInfoList = {}
    for i, v in ipairs(finalInfo.fightInfo) do
      local t = {}
      t.state1 = v:GetCorpsAState()
      t.state2 = v:GetCorpsBState()
      t.fightRecordId = v:GetFightRecordId()
      local cropsId1 = v:GetCorpsAId()
      local cropsInfo1 = finalInfo.corpsMap[cropsId1:tostring()]
      local cropsId2 = v:GetCorpsBId()
      local cropsInfo2 = finalInfo.corpsMap[cropsId2:tostring()]
      if cropsInfo1 then
        t.corps1 = self:newFightInfo(cropsId1, cropsInfo1:GetCorpsName(), cropsInfo1:GetCorpsIcon(), cropsInfo1:GetZoneId())
      end
      if cropsInfo2 then
        t.corps2 = self:newFightInfo(cropsId2, cropsInfo2:GetCorpsName(), cropsInfo2:GetCorpsIcon(), cropsInfo2:GetZoneId())
      end
      table.insert(fightInfoList, t)
    end
    self.finalFightInfoCallback(fightInfoList)
  end
end
return WatchGameMgr.Commit()
