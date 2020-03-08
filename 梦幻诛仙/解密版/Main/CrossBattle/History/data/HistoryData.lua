local Lplus = require("Lplus")
local HistoryData = Lplus.Class("HistoryData")
local def = HistoryData.define
local _instance
def.static("=>", HistoryData).Instance = function()
  if _instance == nil then
    _instance = HistoryData()
  end
  return _instance
end
def.field("table")._seasonCfg = nil
def.field("boolean")._bCurActivityOver = false
def.field("boolean")._bResultOut = false
def.field("table")._top3Caches = nil
def.field("table")._matchCaches = nil
def.field("table")._corpsCaches = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._seasonCfg = nil
  self._bCurActivityOver = false
  self._bResultOut = false
  self._top3Caches = nil
  self._matchCaches = nil
  self._corpsCaches = nil
end
def.method()._LoadSeasonCfg = function(self)
  warn("[HistoryData:_LoadSeasonCfg] start Load seasonCfg!")
  self._seasonCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CROSS_BATTLE_HISTORY_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local seasonCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    seasonCfg.season = DynamicRecord.GetIntValue(entry, "session")
    seasonCfg.activityId = DynamicRecord.GetIntValue(entry, "activity_cfg_id")
    self._seasonCfg[seasonCfg.season] = seasonCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetSeasonCfgs = function(self)
  if nil == self._seasonCfg then
    self:_LoadSeasonCfg()
  end
  return self._seasonCfg
end
def.method("number", "=>", "table").GetSeasonCfg = function(self, id)
  return self:_GetSeasonCfgs()[id]
end
def.method("=>", "number").GetCurSeasonActivityId = function(self)
  local activityId = 0
  local seasonCfg = self:GetSeasonCfg(self:GetCurSeason())
  if seasonCfg then
    activityId = seasonCfg.activityId
  else
    warn("[ERROR][HistoryData:GetCurSeasonActivityId] seasonCfg nil for season:", self:GetCurSeason())
  end
  return activityId
end
def.method("number", "=>", "table").GetSeasonActivityCfg = function(self, id)
  local activityCfg
  local seasonCfg = self:GetSeasonCfg(id)
  if seasonCfg then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    activityCfg = ActivityInterface.GetActivityCfgById(seasonCfg.activityId)
  else
    warn("[ERROR][HistoryData:GetSeasonActivityCfg] seasonCfg nil for season:", id)
  end
  return activityCfg
end
def.method("number", "number").SetSeasonActivityId = function(self, season, activityId)
  local seasonCfg = self:GetSeasonCfg(season)
  if nil == seasonCfg then
    seasonCfg = {}
    seasonCfg.season = season
  end
  seasonCfg.activityId = activityId
  self:_GetSeasonCfgs()[season] = seasonCfg
  self:UpdateCurActivityOver()
end
def.method("boolean").SetCurActivityOver = function(self, value)
  warn("[HistoryData:SetCurActivityOver] set _bCurActivityOver:", value)
  self._bCurActivityOver = value
end
def.method("boolean").SetResultOut = function(self, value)
  warn("[HistoryData:SetResultOut] set _bResultOut:", value)
  self._bResultOut = value
end
def.method("=>", "boolean").IsCurSeasonOver = function(self)
  return self._bCurActivityOver or self._bResultOut
end
def.method("number", "=>", "boolean").IsSeasonOver = function(self, season)
  local result = false
  if season > 0 and season < self:GetCurSeason() then
    result = true
  elseif season == self:GetCurSeason() then
    result = self:IsCurSeasonOver()
  else
    result = false
  end
  return result
end
def.method("=>", "number").GetCurSeason = function(self)
  local curSeason = constant.CrossBattleConsts.cross_battle_session_num
  return curSeason
end
def.method("number").SetCurSeason = function(self, season)
  constant.CrossBattleConsts.cross_battle_session_num = season
  self:UpdateCurActivityOver()
  self:SetResultOut(false)
end
def.method("number", "table").SetSeasonTop3Info = function(self, season, top3Info)
  warn("[HistoryData:SetSeasonTop3Info] Set SeasonTop3Info for season:", season)
  if self._top3Caches == nil then
    self._top3Caches = {}
  end
  if nil == self._top3Caches[season] or nil == top3Info then
    self._top3Caches[season] = top3Info
  end
end
def.method("number", "=>", "table").GetSeasonTop3Info = function(self, season)
  local result
  if self._top3Caches then
    result = self._top3Caches[season]
  end
  return result
end
def.method("number", "table").SetSeasonMatchInfo = function(self, season, matchInfo)
  warn("[HistoryData:SetSeasonMatchInfo] Set SeasonMatchInfo for season:", season)
  if self._matchCaches == nil then
    self._matchCaches = {}
  end
  if nil == self._matchCaches[season] or nil == matchInfo then
    self._matchCaches[season] = matchInfo
  end
end
def.method("number", "=>", "table").GetSeasonMatchInfo = function(self, season)
  local result
  if self._matchCaches then
    result = self._matchCaches[season]
  end
  return result
end
def.method("number", "number", "userdata", "table").SetCorpsInfo = function(self, season, rank, corpsId, corpsInfo)
  warn("[HistoryData:SetCorpsInfo] Set SetCorpsInfo for season & rank:", season, rank)
  if self._corpsCaches == nil then
    self._corpsCaches = {}
  end
  local key = self:GetCorpsKey(season, rank, corpsId)
  if nil == self._corpsCaches[key] or nil == corpsInfo then
    self._corpsCaches[key] = corpsInfo
  end
end
def.method("number", "number", "userdata", "=>", "string").GetCorpsKey = function(self, season, rank, corpsId)
  local key = season .. "_" .. rank
  if corpsId then
    key = key .. "_" .. Int64.tostring(corpsId)
  end
  return key
end
def.method("number", "number", "userdata", "=>", "table").GetCorpsInfo = function(self, season, rank, corpsId)
  local result
  if self._corpsCaches then
    local key = self:GetCorpsKey(season, rank, corpsId)
    result = self._corpsCaches[key]
  end
  return result
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
def.method("table", "table").OnEnterWorld = function(self, p1, p2)
  self:UpdateCurActivityOver()
end
def.method().UpdateCurActivityOver = function(self)
  local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
  self:SetCurActivityOver(HistoryUtils.IsCrossBattleOver())
end
HistoryData.Commit()
return HistoryData
