local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CorpsMatchNode = require("Main.CrossBattle.History.data.CorpsMatchNode")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local MatchData = Lplus.Class(CUR_CLASS_NAME)
local def = MatchData.define
def.field("number")._season = 0
def.field("table")._corpsMap = nil
def.field("table")._fightStageMap = nil
def.field("table")._matchNodes = nil
def.field("boolean")._b16Version = false
def.const("table").StageEnum16 = {
  ELIM16_8 = 1,
  ELIM8_4 = 2,
  SEMI = 3,
  BRONZE = 4,
  FINAL = 5
}
def.const("table").StageEnum32 = {
  ELIM32_16 = 1,
  ELIM16_8 = 2,
  ELIM8_4 = 3,
  SEMI = 4,
  BRONZE = 5,
  FINAL = 6
}
def.final("number", "table", "table", "=>", MatchData).New = function(season, corpsMap, fightStageMap)
  local matchData = MatchData()
  matchData._season = season
  matchData._corpsMap = {}
  if corpsMap then
    for _, corpsInfo in pairs(corpsMap) do
      local key = Int64.tostring(corpsInfo.corps_id)
      matchData._corpsMap[key] = corpsInfo
    end
  end
  matchData._fightStageMap = fightStageMap
  matchData:ConstructMatchNodes()
  return matchData
end
def.method().Release = function(self)
  self._season = 0
  self._corpsMap = nil
  self._fightStageMap = nil
  self._matchNodes = nil
  self._b16Version = false
end
def.method().ConstructMatchNodes = function(self)
  if nil == self._fightStageMap then
    warn("[ERROR][MatchData:ConstructMatchNodes] self._fightStageMap nil.")
    return
  end
  self:UpdateVersion()
  local startStage = MatchData.GetStartStage(self._b16Version)
  local endStage = MatchData.GetFinalStage(self._b16Version)
  for stage = startStage, endStage do
    local matchCount = MatchData.GetStageMatchCount(stage, self._b16Version)
    for matchIdx = 1, matchCount do
      local promoteCorpsNode = self:AddMatchNode(stage, matchIdx)
      local matchList = self:GetMatchList(stage, matchIdx)
      local corpsAId, corpsBId, bCorpsAWin, bCorpsBWin = MatchData.GetMatchResults(matchList)
      local corpsAInfo = self:GetCorpsInfo(corpsAId)
      local corpsBInfo = self:GetCorpsInfo(corpsBId)
      if bCorpsAWin then
        promoteCorpsNode:SetCorpsInfo(corpsAInfo)
      elseif bCorpsBWin then
        promoteCorpsNode:SetCorpsInfo(corpsBInfo)
      end
      promoteCorpsNode:SetMatchList(matchList)
      if stage == MatchData.GetStartStage(self._b16Version) then
        local corpsANode = self:AddMatchNode(MatchData.GetLeafStage(self._b16Version), matchIdx * 2 - 1)
        corpsANode:SetCorpsInfo(corpsAInfo)
        local corpsBNode = self:AddMatchNode(MatchData.GetLeafStage(self._b16Version), matchIdx * 2)
        corpsBNode:SetCorpsInfo(corpsBInfo)
      elseif stage == MatchData.GetBronzeStage(self._b16Version) then
        local corpsANode = self:AddMatchNode(MatchData.GetSemiLoserStage(self._b16Version), 1)
        corpsANode:SetCorpsInfo(corpsAInfo)
        local corpsBNode = self:AddMatchNode(MatchData.GetSemiLoserStage(self._b16Version), 2)
        corpsBNode:SetCorpsInfo(corpsBInfo)
      end
    end
  end
end
def.method("number", "number", "=>", CorpsMatchNode).AddMatchNode = function(self, stage, idx)
  if nil == self._matchNodes then
    self._matchNodes = {}
  end
  local key = CorpsMatchNode.GetKey(stage, idx)
  local result = self._matchNodes[key]
  if nil == result then
    result = CorpsMatchNode.New(stage, idx)
    self._matchNodes[key] = result
  end
  return result
end
def.method("number", "number", "=>", "table").GetMatchList = function(self, stage, idx)
  local matchList = {}
  for round = 1, CrossBattleFinalMgr.STAGE_BATTLE_COUNT do
    local fightMapIdx = (stage - 1) * CrossBattleFinalMgr.STAGE_BATTLE_COUNT + round
    local stageRoundFightInfo = self._fightStageMap[fightMapIdx]
    if stageRoundFightInfo then
      local matchInfo = stageRoundFightInfo.fight_info_list and stageRoundFightInfo.fight_info_list[idx]
      if matchInfo then
        table.insert(matchList, matchInfo)
      else
        warn("[ERROR][MatchData:GetMatchList] matchInfo nil for fightMapIdx & idx:", fightMapIdx, idx)
      end
    else
      warn("[ERROR][MatchData:GetMatchList] stageRoundFightInfo nil for fightMapIdx:", fightMapIdx)
    end
  end
  return matchList
end
def.static("table", "=>", "userdata", "userdata", "boolean", "boolean").GetMatchResults = function(matchList)
  local corpsAId, corpsBId
  local bCorpsAWin = false
  local bCorpsBWin = false
  if matchList and #matchList > 0 then
    local corpsAWinCount = 0
    local corpsBWinCount = 0
    for i = 1, #matchList do
      local matchInfo = matchList[i]
      if nil == corpsAId then
        corpsAId = matchInfo.corps_a_id
      end
      if nil == corpsBId then
        corpsBId = matchInfo.corps_b_id
      end
      local bAWin, bBWin = CorpsMatchNode.GetSingleMatchResult(matchInfo.cal_fight_result)
      if bAWin then
        corpsAWinCount = corpsAWinCount + 1
      elseif bBWin then
        corpsBWinCount = corpsBWinCount + 1
      end
    end
    if corpsAWinCount > corpsBWinCount then
      bCorpsAWin = true
      bCorpsBWin = false
    elseif corpsAWinCount < corpsBWinCount then
      bCorpsAWin = false
      bCorpsBWin = true
    end
  end
  return corpsAId, corpsBId, bCorpsAWin, bCorpsBWin
end
def.method().UpdateVersion = function(self)
  if self._fightStageMap then
    local dayCount = 0
    for _, info in pairs(self._fightStageMap) do
      dayCount = dayCount + 1
    end
    self._b16Version = dayCount <= MatchData.StageEnum16.FINAL * CrossBattleFinalMgr.STAGE_BATTLE_COUNT
  else
    self._b16Version = false
  end
end
def.method("=>", "boolean").Is16Version = function(self)
  return self._b16Version
end
def.method("=>", "number").GetSeason = function(self)
  return self._season
end
def.method("string", "=>", CorpsMatchNode).GetMatchNodeByKey = function(self, key)
  local result
  if self._matchNodes and key then
    result = self._matchNodes[key]
  end
  return result
end
def.method("number", "number", "=>", CorpsMatchNode).GetMatchNode = function(self, stage, idx)
  local key = CorpsMatchNode.GetKey(stage, idx)
  return self:GetMatchNodeByKey(key)
end
def.method("userdata", "=>", "table").GetCorpsInfo = function(self, corpsId)
  local result
  if corpsId and self._corpsMap then
    result = self._corpsMap[Int64.tostring(corpsId)]
  end
  return result
end
def.static("number", "boolean", "=>", "number").GetStageMatchCount = function(stage, b16Version)
  local pow = 0
  if stage == MatchData.GetSemiLoserStage(b16Version) then
    pow = 1
  else
    local finalStage = MatchData.GetFinalStage(b16Version)
    pow = math.max(0, finalStage - stage - 1)
  end
  return math.pow(2, pow)
end
def.static("boolean", "=>", "number").GetStartStage = function(b16Version)
  if b16Version then
    return MatchData.StageEnum16.ELIM16_8
  else
    return MatchData.StageEnum32.ELIM32_16
  end
end
def.static("boolean", "=>", "number").GetFinalStage = function(b16Version)
  if b16Version then
    return MatchData.StageEnum16.FINAL
  else
    return MatchData.StageEnum32.FINAL
  end
end
def.static("boolean", "=>", "number").GetLeafStage = function(b16Version)
  return MatchData.GetStartStage(b16Version) - 1
end
def.static("boolean", "=>", "number").GetSemiLoserStage = function(b16Version)
  return MatchData.GetFinalStage(b16Version) + 1
end
def.static("boolean", "=>", "number").GetBronzeStage = function(b16Version)
  return MatchData.GetFinalStage(b16Version) - 1
end
return MatchData.Commit()
