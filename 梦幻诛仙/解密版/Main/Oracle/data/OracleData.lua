local Lplus = require("Lplus")
local OracleUtils, OracleProtocols, OracleAllocation
local OracleData = Lplus.Class("OracleData")
local def = OracleData.define
local _instance
def.static("=>", OracleData).Instance = function()
  if _instance == nil then
    _instance = OracleData()
  end
  return _instance
end
def.const("number").WAIT_INFO_DURATION = 5
def.const("number").INFO_STATE_EMPTY = 1
def.const("number").INFO_STATE_REQUESTING = 2
def.const("number").INFO_STATE_FETCHED = 3
def.field("table")._mapOccp2Oracles = nil
def.field("table")._mapId2OracleCfg = nil
def.field("table")._mapId2TalentCfg = nil
def.field("table")._mapTalentSkill2OriginSkill = nil
def.field("table")._mapItem2PointsCfg = nil
def.field("number")._oracleInfoState = 0
def.field("number")._timerID = 0
def.field("number")._totalPoints = 0
def.field("number")._extraPoints = 0
def.field("number")._curOracleId = 0
def.field("table")._mapId2OracleAlloc = nil
def.method().Init = function(self)
  OracleAllocation = require("Main.Oracle.data.OracleAllocation")
  OracleProtocols = require("Main.Oracle.OracleProtocols")
  OracleUtils = require("Main.Oracle.OracleUtils")
  self:_Reset()
end
def.method()._Reset = function(self)
  self:_SetInfoState(OracleData.INFO_STATE_EMPTY)
  self:_RemoveTimer()
  self._mapOccp2Oracles = nil
  self._mapId2OracleCfg = nil
  self._mapId2TalentCfg = nil
  self._mapTalentSkill2OriginSkill = nil
  self._mapItem2PointsCfg = nil
  self._totalPoints = 0
  self._extraPoints = 0
  self._curOracleId = 0
  self._mapId2OracleAlloc = nil
end
def.method()._RemoveTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method("=>", "boolean")._NeedRequestInfo = function(self)
  return self._oracleInfoState == OracleData.INFO_STATE_EMPTY
end
def.method("number")._SetInfoState = function(self, state)
  self._oracleInfoState = state
end
def.method("table", "table").OnEnterWorld = function(self, params, context)
  self:_UpdateTotalPoints()
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnHeroLevelUp = function(self, p1, p2)
  self:_UpdateTotalPoints()
end
def.method("number").OnSyncExtraPoint = function(self, extraPoints)
  self:_SetExtraPoints(extraPoints)
  self:_UpdateTotalPoints()
end
def.method()._LoadCfg = function(self)
  warn("[OracleData:_LoadCfg] _LoadCfg!")
  self:_LoadOracleCfg()
  self:_LoadTalentCfg()
end
def.method()._LoadOracleCfg = function(self)
  self._mapOccp2Oracles = {}
  self._mapId2OracleCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ORACLE_CGeniusSeriesCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local occupationId = DynamicRecord.GetIntValue(entry, "occupationType")
    local seriesStruct = entry:GetStructValue("seriesStruct")
    local seriesVectorSize = DynamicRecord.GetVectorSize(seriesStruct, "seriesList")
    for i = 0, seriesVectorSize - 1 do
      local oracleRecord = DynamicRecord.GetVectorValueByIdx(seriesStruct, "seriesList", i)
      local oracle = {}
      oracle.id = oracleRecord:GetIntValue("id")
      oracle.occupationId = occupationId
      oracle.defaultOpen = 0 < oracleRecord:GetIntValue("defaultOpen")
      oracle.uiName = oracleRecord:GetStringValue("uiName")
      oracle.talents = {}
      local geniusStruct = oracleRecord:GetStructValue("geniusStruct")
      local geniusVectorSize = DynamicRecord.GetVectorSize(geniusStruct, "geniusList")
      for i = 0, geniusVectorSize - 1 do
        local geniusRecord = DynamicRecord.GetVectorValueByIdx(geniusStruct, "geniusList", i)
        local geniusId = geniusRecord:GetIntValue("geniusId")
        table.insert(oracle.talents, geniusId)
      end
      if nil == self._mapOccp2Oracles[occupationId] then
        self._mapOccp2Oracles[occupationId] = {}
      end
      table.insert(self._mapOccp2Oracles[occupationId], oracle)
      self._mapId2OracleCfg[oracle.id] = oracle
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method()._LoadTalentCfg = function(self)
  self._mapId2TalentCfg = {}
  self._mapTalentSkill2OriginSkill = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ORACLE_CGeniusCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local talentCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    talentCfg.id = DynamicRecord.GetIntValue(entry, "id")
    talentCfg.oracleId = DynamicRecord.GetIntValue(entry, "geniusSeriesCfgid")
    talentCfg.layer = DynamicRecord.GetIntValue(entry, "layer")
    talentCfg.previousPoint = DynamicRecord.GetIntValue(entry, "previousPoint")
    talentCfg.sourceSkillId = DynamicRecord.GetIntValue(entry, "sourceSkillCfgid")
    talentCfg.previousTalents = {}
    local previousGeniusListStruct = entry:GetStructValue("previousGeniusListStruct")
    local previousGeniusListSize = DynamicRecord.GetVectorSize(previousGeniusListStruct, "previousGeniusList")
    if previousGeniusListSize > 0 then
      for i = 0, previousGeniusListSize - 1 do
        local previousGeniusRecord = DynamicRecord.GetVectorValueByIdx(previousGeniusListStruct, "previousGeniusList", i)
        local previousGeniusCfgid = previousGeniusRecord:GetIntValue("previousGeniusCfgid")
        local previousGeniusAddPoint = previousGeniusRecord:GetIntValue("previousGeniusAddPoint")
        if previousGeniusCfgid and previousGeniusAddPoint and previousGeniusAddPoint > 0 then
          talentCfg.previousTalents[previousGeniusCfgid] = previousGeniusAddPoint
        end
      end
    end
    talentCfg.uiName = DynamicRecord.GetStringValue(entry, "uiName")
    talentCfg.skills = {}
    local skillsStruct = entry:GetStructValue("skillsStruct")
    local skillVectorSize = DynamicRecord.GetVectorSize(skillsStruct, "skillList")
    for i = 0, skillVectorSize - 1 do
      local skillRecord = DynamicRecord.GetVectorValueByIdx(skillsStruct, "skillList", i)
      local skillId = skillRecord:GetIntValue("skillId")
      if skillId > 0 then
        table.insert(talentCfg.skills, skillId)
        if talentCfg.sourceSkillId and talentCfg.sourceSkillId > 0 then
          self._mapTalentSkill2OriginSkill[skillId] = talentCfg.sourceSkillId
        end
      end
    end
    talentCfg.maxPoints = #talentCfg.skills
    self._mapId2TalentCfg[talentCfg.id] = talentCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method()._LoadOracleItemCfg = function(self)
  warn("[OracleData:_LoadOracleItemCfg] start Load OracleItemCfg!")
  self._mapItem2PointsCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ORACLE_CGeniusItemCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local itemCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    itemCfg.id = DynamicRecord.GetIntValue(entry, "id")
    itemCfg.addGeniusPoint = DynamicRecord.GetIntValue(entry, "addGeniusPoint")
    self._mapItem2PointsCfg[itemCfg.id] = itemCfg.addGeniusPoint
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetOccpOracleMap = function(self)
  if nil == self._mapOccp2Oracles then
    self:_LoadOracleCfg()
  end
  return self._mapOccp2Oracles
end
def.method("=>", "table")._GetOracleMap = function(self)
  if nil == self._mapId2OracleCfg then
    self:_LoadOracleCfg()
  end
  return self._mapId2OracleCfg
end
def.method("=>", "table")._GetTalentMap = function(self)
  if nil == self._mapId2TalentCfg then
    self:_LoadTalentCfg()
  end
  return self._mapId2TalentCfg
end
def.method("=>", "table")._GetSkillMap = function(self)
  if nil == self._mapTalentSkill2OriginSkill then
    self:_LoadTalentCfg()
  end
  return self._mapTalentSkill2OriginSkill
end
def.method("=>", "table")._GetItem2PointsMap = function(self)
  if nil == self._mapItem2PointsCfg then
    self:_LoadOracleItemCfg()
  end
  return self._mapItem2PointsCfg
end
def.method("number", "=>", "table").GetOracleCfg = function(self, oracleId)
  return self:_GetOracleMap()[oracleId]
end
def.method("number", "=>", "number").GetOccupByOracleId = function(self, oracleId)
  local result = 0
  local oracleCfg = self:GetOracleCfg(oracleId)
  if oracleCfg then
    result = oracleCfg.occupationId
  end
  return result
end
def.method("number", "=>", "table").GetTalentCfg = function(self, talentId)
  return self:_GetTalentMap()[talentId]
end
def.method("number", "=>", "table").GetOracleTalentCfgs = function(self, oracleId)
  local result = {}
  local oracleCfg = self:GetOracleCfg(oracleId)
  if oracleCfg then
    local talentCfg
    for _, talentId in ipairs(oracleCfg.talents) do
      talentCfg = self:GetTalentCfg(talentId)
      if talentCfg then
        result[talentId] = talentCfg
      end
    end
  end
  return result
end
def.method("number", "=>", "table").GetOccpDefaultOracleCfg = function(self, occupationId)
  local result
  local occpOracleCfgs = self:_GetOccpOracleMap()[occupationId]
  if occpOracleCfgs then
    for _, oracleCfg in ipairs(occpOracleCfgs) do
      if oracleCfg.defaultOpen then
        result = oracleCfg
        break
      end
    end
    if nil == result then
      result = occpOracleCfgs[1]
    end
    if result then
    end
  else
    error("[OracleData:GetOccpDefaultOracleCfg] no oraclecfg for occupation:", occupationId)
  end
  return result
end
def.method("number", "=>", "table").GetOccpSecondOracleCfg = function(self, occupationId)
  local result
  local occpOracleCfgs = self:_GetOccpOracleMap()[occupationId]
  if occpOracleCfgs then
    for _, oracleCfg in ipairs(occpOracleCfgs) do
      if not oracleCfg.defaultOpen then
        result = oracleCfg
        break
      end
    end
    if nil == result then
      result = occpOracleCfgs[2]
    end
  end
  return result
end
def.method("number", "=>", "number").GetOriginSkillId = function(self, talentSkillId)
  return self:_GetSkillMap()[talentSkillId] or 0
end
def.method("number", "=>", "number").GetTalentSkillId = function(self, sourceSkillId)
  local talentSkillId = sourceSkillId
  if sourceSkillId > 0 then
    local curAllocation = self:GetCurrentAllocation()
    local curOracleTalentMap = self:GetOracleTalentCfgs(self._curOracleId)
    if curAllocation and curOracleTalentMap then
      for talentId, talentCfg in pairs(curOracleTalentMap) do
        if talentCfg.sourceSkillId == sourceSkillId and 0 < curAllocation:GetTalentPoints(talentId) then
          talentSkillId = curAllocation:GetTalentSkillId(talentId)
          if talentSkillId <= 0 then
            talentSkillId = sourceSkillId
          end
          warn(string.format("[OracleData:GetTalentSkillId] Get talent skillId[%d] for source SkillId[%d] of talent[%d].", talentSkillId, sourceSkillId, talentId))
          break
        end
      end
    else
      warn("[OracleData:GetTalentSkillId] OracleAllocation or OracleTalentCfgs nil for current oracle:", self._curOracleId)
    end
  end
  return talentSkillId
end
def.method("number", "=>", "number").GetItemAddPoints = function(self, itemId)
  return self:_GetItem2PointsMap()[itemId] or 0
end
def.method("number", "=>", "boolean").IsOracleItem = function(self, itemId)
  return nil ~= self:_GetItem2PointsMap()[itemId]
end
def.method("number", "table").SetAllAllocations = function(self, cur_series, series)
  self:_RemoveTimer()
  self:_SetInfoState(OracleData.INFO_STATE_FETCHED)
  self:SetCurrentOracleId(cur_series)
  if series then
    if self._mapId2OracleAlloc then
      for oracleId, oracleInfo in pairs(self._mapId2OracleAlloc) do
        if nil == series[oracleId] then
          self:SetAllocation(oracleId, nil)
        end
      end
    end
    self._mapId2OracleAlloc = {}
    for oracleId, oracleInfo in pairs(series) do
      self:SetAllocation(oracleId, oracleInfo.genius_skills)
    end
  else
    if self._mapId2OracleAlloc then
      for oracleId, oracleInfo in pairs(_mapId2OracleAlloc) do
        self:SetAllocation(oracleId, nil)
      end
    end
    self._mapId2OracleAlloc = {}
  end
  Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ALL_ORACLE_ALLOCS, nil)
end
def.method("number").SetCurrentOracleId = function(self, oracleId)
  warn("[OracleData:SetCurrentOracleId] Set CurrentOracleId:", oracleId)
  self._curOracleId = oracleId
  Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, {oracleId = oracleId})
end
def.method("number", "table").SetAllocation = function(self, oracleId, geniusSkills)
  warn("[OracleData:SetAllocation] Set Allocation for oracleId:", oracleId)
  local oracleAlloc
  if geniusSkills and _G.next(geniusSkills) then
    oracleAlloc = OracleAllocation.Create(oracleId, geniusSkills)
  end
  self._mapId2OracleAlloc[oracleId] = oracleAlloc
  Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, {oracleId = oracleId})
end
def.method("=>", "table")._GetOracleAllocs = function(self)
  if nil == self._mapId2OracleAlloc then
    if self:_NeedRequestInfo() then
      self:_RemoveTimer()
      self:_SetInfoState(OracleData.INFO_STATE_REQUESTING)
      self._timerID = GameUtil.AddGlobalTimer(OracleData.WAIT_INFO_DURATION, true, function()
        if self._oracleInfoState == OracleData.INFO_STATE_REQUESTING then
          self:_SetInfoState(OracleData.INFO_STATE_EMPTY)
        end
      end)
      OracleProtocols.SendCGetGeninusSeries()
    end
    return {}
  else
    return self._mapId2OracleAlloc
  end
end
def.method("=>", "number").GetCurrentOracleId = function(self)
  return self._curOracleId
end
def.method("=>", "table").GetCurrentAllocation = function(self)
  return self:GetAllocation(self._curOracleId)
end
def.method("number", "=>", "table").GetAllocation = function(self, oracleId)
  return self:_GetOracleAllocs()[oracleId]
end
def.method("number", "=>", "table").GetAllocCopyByOracleId = function(self, oracleId)
  local result
  if oracleId == self:GetCurrentOracleId() then
    local alloc = self:GetAllocation(oracleId)
    if alloc then
      result = alloc:Copy()
    else
      result = OracleAllocation.Create(oracleId, nil)
    end
  else
    result = OracleAllocation.Create(oracleId, nil)
  end
  return result
end
def.method("=>", "number").GetRestPoints = function(self)
  local result = self:GetTotalPoints()
  local curAllocation = self:GetCurrentAllocation()
  if curAllocation then
    result = curAllocation:GetRestPoints()
  end
  return result
end
def.method()._UpdateTotalPoints = function(self)
  local points = OracleUtils.GetHeroTotalPoint()
  if self._totalPoints ~= points then
    self._totalPoints = points
    warn("[OracleData:_UpdateTotalPoints] self._totalPoints =", self._totalPoints)
    Event.DispatchEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, nil)
  end
end
def.method("=>", "number").GetTotalPoints = function(self)
  return self._totalPoints
end
def.method("number")._SetExtraPoints = function(self, points)
  self._extraPoints = math.max(points, 0)
end
def.method("=>", "number").GetExtraPoints = function(self)
  return self._extraPoints
end
OracleData.Commit()
return OracleData
