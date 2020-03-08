local Lplus = require("Lplus")
local HallInfo = require("Main.Aagr.data.HallInfo")
local ArenaInfo = require("Main.Aagr.data.ArenaInfo")
local AagrData = Lplus.Class("AagrData")
local def = AagrData.define
local _instance
def.static("=>", AagrData).Instance = function()
  if _instance == nil then
    _instance = AagrData()
  end
  return _instance
end
def.field("table")._activityCfg = nil
def.field("table")._ballCfg = nil
def.field("table")._mapEntityCfg = nil
def.field("table")._circleCfg = nil
def.field("number")._curActivityId = 0
def.field("table")._hallInfo = nil
def.field("table")._arenaInfo = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._activityCfg = nil
  self._ballCfg = nil
  self._mapEntityCfg = nil
  self._circleCfg = nil
  self._curActivityId = 0
  self._hallInfo = nil
  self._arenaInfo = nil
end
def.method()._LoadActivityCfg = function(self)
  warn("[AagrData:_LoadActivityCfg] start Load ActivityCfg!")
  self._activityCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AAGR_ActivityCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local activityCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    activityCfg.activityId = DynamicRecord.GetIntValue(entry, "activityId")
    activityCfg.activityNpcId = DynamicRecord.GetIntValue(entry, "activityNpcId")
    activityCfg.activityServiceId = DynamicRecord.GetIntValue(entry, "activityServiceId")
    activityCfg.prepareNpcId = DynamicRecord.GetIntValue(entry, "prepareNpcId")
    activityCfg.prepareServiceId = DynamicRecord.GetIntValue(entry, "prepareServiceId")
    activityCfg.prepareMapId = DynamicRecord.GetIntValue(entry, "prepareMapId")
    activityCfg.gameMapId = DynamicRecord.GetIntValue(entry, "gameMapId")
    activityCfg.circleCfgId = DynamicRecord.GetIntValue(entry, "circleCfgId")
    activityCfg.playerCollisionSfxId = DynamicRecord.GetIntValue(entry, "playerCollisionSfxId")
    activityCfg.playerLevelUpSfxId = DynamicRecord.GetIntValue(entry, "playerLevelUpSfxId")
    activityCfg.playerLevelDownSfxId = DynamicRecord.GetIntValue(entry, "playerLevelDownSfxId")
    activityCfg.playerBerserkSfxId = DynamicRecord.GetIntValue(entry, "playerBerserkSfxId")
    activityCfg.playerDeathSfxId = DynamicRecord.GetIntValue(entry, "playerDeathSfxId")
    activityCfg.levelCfgId = DynamicRecord.GetIntValue(entry, "levelCfgId")
    activityCfg.alertContentFromHigherLevel = DynamicRecord.GetStringValue(entry, "alertContentFromHigherLevel")
    activityCfg.alertContentFromLowerLevel = DynamicRecord.GetStringValue(entry, "alertContentFromLowerLevel")
    activityCfg.alertDisappearSeconds = DynamicRecord.GetIntValue(entry, "alertDisappearSeconds")
    activityCfg.playerLifeNumber = DynamicRecord.GetIntValue(entry, "playerLifeNumber")
    activityCfg.gamePrepareSeconds = DynamicRecord.GetIntValue(entry, "gamePrepareSeconds")
    activityCfg.gameSeconds = DynamicRecord.GetIntValue(entry, "gameSeconds")
    activityCfg.maxLevelResetSeconds = DynamicRecord.GetIntValue(entry, "maxLevelResetSeconds")
    activityCfg.gameEndForceLeaveSeconds = DynamicRecord.GetIntValue(entry, "gameEndForceLeaveSeconds")
    activityCfg.gamePrepareSfxId = DynamicRecord.GetIntValue(entry, "gamePrepareSfxId")
    activityCfg.protectedNameColorId = DynamicRecord.GetIntValue(entry, "protectedNameColorId")
    activityCfg.notProtectedStateNameColorId = DynamicRecord.GetIntValue(entry, "notProtectedStateNameColorId")
    self._activityCfg[activityCfg.activityId] = activityCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table").GetActivityCfgs = function(self)
  if nil == self._activityCfg then
    self:_LoadActivityCfg()
  end
  return self._activityCfg
end
def.method("number", "=>", "table").GetActivityCfg = function(self, id)
  return self:GetActivityCfgs()[id]
end
def.method()._LoadBallCfg = function(self)
  warn("[AagrData:_LoadBallCfg] start Load BallCfg!")
  self._ballCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AAGR_BallCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local ballCfg = {}
    ballCfg.id = DynamicRecord.GetIntValue(entry, "id")
    ballCfg.levelCfgs = {}
    local levelsStruct = entry:GetStructValue("levelsStruct")
    local levelCount = levelsStruct:GetVectorSize("levels")
    for j = 1, levelCount do
      local record = levelsStruct:GetVectorValueByIdx("levels", j - 1)
      local levelCfg = {}
      levelCfg.level = j
      levelCfg.modelId = record:GetIntValue("modelId")
      levelCfg.modelRatio = record:GetIntValue("modelRatio")
      levelCfg.requiredGene = record:GetIntValue("requiredGene")
      ballCfg.levelCfgs[levelCfg.level] = levelCfg
    end
    self._ballCfg[ballCfg.id] = ballCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetBallCfgs = function(self)
  if nil == self._ballCfg then
    self:_LoadBallCfg()
  end
  return self._ballCfg
end
def.method("number", "=>", "table").GetBallCfg = function(self, id)
  local cfgs = self:_GetBallCfgs()
  return cfgs and cfgs[id] or nil
end
def.method()._LoadMapEntityCfg = function(self)
  warn("[AagrData:_LoadMapEntityCfg] start Load MapEntityCfg!")
  self._mapEntityCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AAGR_MapEntityCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local mapEntityCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    mapEntityCfg.id = DynamicRecord.GetIntValue(entry, "id")
    mapEntityCfg.name = DynamicRecord.GetStringValue(entry, "name")
    mapEntityCfg.type = DynamicRecord.GetIntValue(entry, "type")
    mapEntityCfg.modelId = DynamicRecord.GetIntValue(entry, "modelId")
    mapEntityCfg.groundSfxId = DynamicRecord.GetIntValue(entry, "groundSfxId")
    mapEntityCfg.groundSfxSeconds = DynamicRecord.GetIntValue(entry, "groundSfxSeconds")
    mapEntityCfg.playerSfxId = DynamicRecord.GetIntValue(entry, "playerSfxId")
    mapEntityCfg.arg = DynamicRecord.GetIntValue(entry, "arg")
    self._mapEntityCfg[mapEntityCfg.id] = mapEntityCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetMapEntityCfgs = function(self)
  if nil == self._mapEntityCfg then
    self:_LoadMapEntityCfg()
  end
  return self._mapEntityCfg
end
def.method("number", "=>", "table").GetMapEntityCfgByType = function(self, type)
  local mapEntityCfgs = self:_GetMapEntityCfgs()
  local result
  if mapEntityCfgs then
    for _, cfg in pairs(mapEntityCfgs) do
      if cfg.type == type then
        result = cfg
        break
      end
    end
  end
  return result
end
def.method("number", "=>", "table").GetMapEntityCfg = function(self, id)
  local cfgs = self:_GetMapEntityCfgs()
  return cfgs and cfgs[id] or nil
end
def.method()._LoadCircleCfg = function(self)
  warn("[AagrData:_LoadCircleCfg] start Load CircleCfg!")
  self._circleCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_AAGR_CircleCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local circleCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    circleCfg.id = DynamicRecord.GetIntValue(entry, "id")
    circleCfg.circleModelId = DynamicRecord.GetIntValue(entry, "circleModelId")
    circleCfg.circleModelRawRadius = DynamicRecord.GetIntValue(entry, "circleModelRawRadius")
    circleCfg.circleModelR = DynamicRecord.GetIntValue(entry, "circleModelR")
    circleCfg.circleModelG = DynamicRecord.GetIntValue(entry, "circleModelG")
    circleCfg.circleModelB = DynamicRecord.GetIntValue(entry, "circleModelB")
    circleCfg.circleModelA = DynamicRecord.GetIntValue(entry, "circleModelA")
    circleCfg.initRadius = DynamicRecord.GetIntValue(entry, "initRadius")
    circleCfg.circleCenterX = DynamicRecord.GetIntValue(entry, "circleCenterX")
    circleCfg.circleCenterY = DynamicRecord.GetIntValue(entry, "circleCenterY")
    circleCfg.levelCfgs = {}
    local circlesStruct = entry:GetStructValue("circlesStruct")
    local itemCount = circlesStruct:GetVectorSize("circles")
    for j = 1, itemCount do
      local record = circlesStruct:GetVectorValueByIdx("circles", j - 1)
      local levelCfg = {}
      levelCfg.level = j
      levelCfg.circleRadius = record:GetIntValue("circleRadius")
      levelCfg.circleReduceSeconds = record:GetIntValue("circleReduceSeconds")
      table.insert(circleCfg.levelCfgs, levelCfg)
    end
    self._circleCfg[circleCfg.id] = circleCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetCircleCfgs = function(self)
  if nil == self._circleCfg then
    self:_LoadCircleCfg()
  end
  return self._circleCfg
end
def.method("number", "=>", "table").GetCircleCfg = function(self, cfgId)
  return self:_GetCircleCfgs()[cfgId]
end
def.method("=>", "table").GetCurCircleCfg = function(self)
  local activityCfg = self:GetCurActivityCfg()
  local circleCfg = activityCfg and self:GetCircleCfg(activityCfg.circleCfgId)
  return circleCfg
end
def.method("=>", "number").GetCurActivityId = function(self)
  return self._curActivityId
end
def.method("=>", "table").GetCurActivityCfg = function(self)
  return self:GetActivityCfg(self._curActivityId)
end
def.method("=>", "number").GetEntranceNPCId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.activityNpcId
  return result or 0
end
def.method("=>", "number").GetEntranceServiceId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.activityServiceId
  return result or 0
end
def.method("=>", "number").GetHallNPCId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.prepareNpcId
  return result or 0
end
def.method("=>", "number").GetHallServiceId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.prepareServiceId
  return result or 0
end
def.method("=>", "number").GetHallMapId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.prepareMapId
  return result or 0
end
def.method("=>", "number").GetArenaMapId = function(self)
  local aagrCfg = self:GetActivityCfg(self._curActivityId)
  local result = aagrCfg and aagrCfg.gameMapId
  return result or 0
end
def.method("=>", "boolean").IsInHall = function(self)
  local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local hallMapId = self:GetHallMapId()
  return hallMapId > 0 and curMapId == hallMapId
end
def.method("=>", "boolean").IsInArena = function(self)
  local curMapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local arenaMapId = self:GetArenaMapId()
  return arenaMapId > 0 and curMapId == arenaMapId
end
def.method("table").SyncHallInfo = function(self, info)
  if nil == info then
    self._hallInfo = nil
  elseif self._hallInfo then
    self._hallInfo:Update(info.round, info.role_number, info.is_preparing ~= 0, info.stage_end_time)
  else
    self._hallInfo = HallInfo.New(info.round, info.role_number, info.is_preparing ~= 0, info.stage_end_time)
  end
  Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_HALL_INFO_CHANGE, nil)
end
def.method("=>", "table").GetHallInfo = function(self)
  return self._hallInfo
end
def.method("table").SyncArenaInfo = function(self, info)
  if nil == info then
    self._arenaInfo = nil
  elseif self._arenaInfo then
    self._arenaInfo:Update(info.start_time, info.stop_time, info.circle_reduce_count, info.next_circle_reduce_time, info.player_names, info.player_score_infos)
  else
    self._arenaInfo = ArenaInfo.New(info.start_time, info.stop_time, info.circle_reduce_count, info.next_circle_reduce_time, info.player_names, info.player_score_infos)
  end
  Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_INFO_CHANGE, nil)
end
def.method("=>", "table").GetArenaInfo = function(self)
  return self._arenaInfo
end
def.method("table").SyncArenaPlayerInfos = function(self, info)
  if info then
    if self._arenaInfo then
      self._arenaInfo:SyncPlayerInfos(info)
    else
      warn("[ERROR][AagrData:SyncArenaPlayerInfos] self._arenaInfo nil.")
    end
  end
end
def.method("number").SyncCircle = function(self, circleIdx)
  if self._arenaInfo then
    self._arenaInfo:SyncCircle(circleIdx)
  else
    warn("[ERROR][AagrData:SyncCircle] self._arenaInfo nil.")
  end
end
def.method("=>", "boolean").IsHeroAlive = function(self)
  if self._arenaInfo then
    return self._arenaInfo:GetPlayerLifeCount(_G.GetMyRoleID()) > 0
  else
    return true
  end
end
def.method("userdata", "=>", "number").GetPlayerScore = function(self, roleId)
  if self._arenaInfo then
    return self._arenaInfo:GetPlayerScore(roleId)
  else
    return 0
  end
end
def.method("userdata", "=>", "string").GetPlayerName = function(self, roleId)
  if self._arenaInfo then
    return self._arenaInfo:GetPlayerName(roleId)
  else
    return ""
  end
end
def.method("=>", "number").GetWaitLeaveDuration = function(self)
  local activityCfg = self:GetCurActivityCfg()
  return activityCfg and activityCfg.gameEndForceLeaveSeconds or 0
end
def.method("=>", "number").GetAlivePlayerCount = function(self)
  local activityCfg = self:GetCurActivityCfg()
  return self._arenaInfo and self._arenaInfo:GetAlivePlayerCount() or 0
end
def.method("=>", "number").GetMaxBallLevel = function(self)
  local activityCfg = self:GetCurActivityCfg()
  local ballCfg = activityCfg and self:GetBallCfg(activityCfg.levelCfgId)
  if ballCfg and ballCfg.levelCfgs then
    return #ballCfg.levelCfgs
  else
    warn("[ERROR][AagrData:GetMaxBallLevel] return 0! self._curActivityId, activityCfg, ballCfg:", self._curActivityId, activityCfg, ballCfg)
    return 0
  end
end
def.method("number", "=>", "table").GetBallLevelCfg = function(self, ballLevel)
  local activityCfg = self:GetCurActivityCfg()
  local ballCfg = activityCfg and self:GetBallCfg(activityCfg.levelCfgId)
  return ballCfg and ballCfg.levelCfgs[ballLevel]
end
def.method("=>", "number").GetBallMaxDuration = function(self)
  local activityCfg = self:GetCurActivityCfg()
  return activityCfg and activityCfg.maxLevelResetSeconds or 0
end
def.method("=>", "number").GetBallMaxLife = function(self)
  local activityCfg = self:GetCurActivityCfg()
  return activityCfg and activityCfg.playerLifeNumber or 0
end
def.method("table", "table").OnEnterWorld = function(self, p1, p2)
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnNewDay = function(self, param, context)
  self:UpdateCurrentActivity(true)
end
def.method("boolean").OnFunctionOpenChange = function(self, bOpen)
  if not bOpen then
    self:_Reset()
  end
end
def.method("boolean").UpdateCurrentActivity = function(self, bCheckIDIP)
  local oldActivityId = self._curActivityId
  self._curActivityId = self:_GetCurrentActivityId(bCheckIDIP)
  warn("[AagrData:UpdateCurrentActivity] self._curActivityId:", self._curActivityId)
  if oldActivityId ~= self._curActivityId then
    Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ACTIVITY_CHANGE, {
      activityId = self._curActivityId
    })
  end
end
def.method("boolean", "=>", "number")._GetCurrentActivityId = function(self, bCheckIDIP)
  if bCheckIDIP then
    local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BALL_BATTLE) then
      return 0
    end
  end
  local result = 0
  local activityCfgs = self:GetActivityCfgs()
  if activityCfgs then
    local AagrUtils = require("Main.Aagr.AagrUtils")
    for activityId, aagrCfg in pairs(activityCfgs) do
      if AagrUtils.IsActivityOpen(activityId) then
        result = activityId
        break
      end
    end
  end
  return result
end
AagrData.Commit()
return AagrData
