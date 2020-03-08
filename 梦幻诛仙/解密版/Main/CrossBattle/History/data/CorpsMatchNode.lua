local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
local CalFightResult = require("netio.protocol.mzm.gsp.crossbattle.CalFightResult")
local CorpsMatchNode = Lplus.Class(CUR_CLASS_NAME)
local def = CorpsMatchNode.define
def.field("number")._stage = -1
def.field("number")._idx = -1
def.field("table")._corpsInfo = nil
def.field("table")._matchList = nil
def.final("number", "number", "=>", CorpsMatchNode).New = function(stage, idx)
  local node = CorpsMatchNode()
  node._stage = stage
  node._idx = idx
  node._corpsInfo = nil
  node._matchList = nil
  return node
end
def.method().Release = function(self)
  self._stage = 0
  self._idx = 0
  self._corpsInfo = nil
  self._matchList = nil
end
def.static("number", "number", "=>", "string").GetKey = function(stage, idx)
  return stage .. "_" .. idx
end
def.method("=>", "number").GetStage = function(self)
  return self._stage
end
def.method("=>", "number").GetIdx = function(self)
  return self._idx
end
def.method("=>", "userdata").GetCorpsId = function(self)
  return self._corpsInfo and self._corpsInfo.corps_id or nil
end
def.method("=>", "string").GetCorpsName = function(self)
  return self._corpsInfo and _G.GetStringFromOcts(self._corpsInfo.corps_name) or ""
end
def.method("=>", "userdata").GetServerId = function(self)
  return self._corpsInfo and self._corpsInfo.zone_id or nil
end
def.method("=>", "string").GetServerName = function(self)
  local HistoryUtils = require("Main.CrossBattle.History.HistoryUtils")
  return HistoryUtils.GetServerName(self:GetServerId())
end
def.method("table").SetCorpsInfo = function(self, corpsInfo)
  self._corpsInfo = corpsInfo
end
def.method("=>", "table").GetCorpsInfo = function(self)
  return self._corpsInfo
end
def.method("table").SetMatchList = function(self, matchList)
  self._matchList = matchList
end
def.method("=>", "table").GetMatchList = function(self)
  return self._matchList
end
def.method("number", "=>", "table").GetMatchByIdx = function(self, idx)
  return self._matchList and self._matchList[idx]
end
def.method("=>", "number").GetRealMatchCount = function(self)
  local matchCount = 0
  local winCount = 0
  local corpsId = self:GetCorpsId()
  if corpsId and self._matchList and 0 < #self._matchList then
    for i = 1, #self._matchList do
      matchCount = matchCount + 1
      local matchInfo = self._matchList[i]
      local bAWin, bBWin = CorpsMatchNode.GetSingleMatchResult(matchInfo.cal_fight_result)
      if bAWin and Int64.eq(corpsId, matchInfo.corps_a_id) then
        winCount = winCount + 1
      elseif bBWin and Int64.eq(corpsId, matchInfo.corps_b_id) then
        winCount = winCount + 1
      end
      if winCount >= math.ceil(CrossBattleFinalMgr.STAGE_BATTLE_COUNT / 2) then
        break
      end
    end
  end
  return matchCount
end
def.static("number", "=>", "boolean", "boolean").GetSingleMatchResult = function(fightResult)
  local bCorpsAWin = false
  local bCorpsBWin = false
  if fightResult == CalFightResult.A_FIGHT_WIN or fightResult == CalFightResult.A_ABSTAIN_WIN or fightResult == CalFightResult.A_BYE_WIN then
    bCorpsAWin = true
  elseif fightResult == CalFightResult.A_FIGHT_LOSE or fightResult == CalFightResult.A_ABSTAIN_LOSE or fightResult == CalFightResult.B_BYE_WIN then
    bCorpsBWin = true
  end
  return bCorpsAWin, bCorpsBWin
end
return CorpsMatchNode.Commit()
