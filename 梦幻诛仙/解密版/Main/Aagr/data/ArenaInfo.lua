local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local ArenaInfo = Lplus.Class(CUR_CLASS_NAME)
local def = ArenaInfo.define
def.field("number").startTime = 0
def.field("number").endTime = 0
def.field("number").circleIdx = 0
def.field("number").nextCircleTime = 0
def.field("table").roleId2NameMap = nil
def.field("table").playerInfoMap = nil
def.field("table").activityCfg = nil
def.field("table").circleCfg = nil
def.field("table").playerRankList = nil
def.final("number", "number", "number", "number", "table", "table", "=>", ArenaInfo).New = function(startTime, endTime, circleIdx, nextCircleTime, roleId2NameMap, playerInfoMap)
  local AagrData = require("Main.Aagr.data.AagrData")
  local activityCfg = AagrData.Instance():GetCurActivityCfg()
  local circleCfg = AagrData.Instance():GetCurCircleCfg()
  if nil == activityCfg or nil == circleCfg then
    warn("[ERROR][ArenaInfo:New] create fail! activityCfg or circleCfg nil:", activityCfg, circleCfg)
    return nil
  end
  local arenaInfo = ArenaInfo()
  arenaInfo.activityCfg = activityCfg
  arenaInfo.circleCfg = circleCfg
  arenaInfo:Update(startTime, endTime, circleIdx, nextCircleTime, roleId2NameMap, playerInfoMap)
  return arenaInfo
end
def.method("number", "number", "number", "number", "table", "table").Update = function(self, startTime, endTime, circleIdx, nextCircleTime, roleId2NameMap, playerInfoMap)
  warn("[ArenaInfo:Update] startTime, endTime, circleIdx, nextCircleTime:", os.date("%c", startTime), os.date("%c", endTime), circleIdx, os.date("%c", nextCircleTime))
  self.startTime = startTime
  self.endTime = endTime
  self:SyncCircle(circleIdx)
  self.nextCircleTime = nextCircleTime
  self.roleId2NameMap = {}
  if roleId2NameMap then
    for roleId, roleName in pairs(roleId2NameMap) do
      local roleKey = Int64.tostring(roleId)
      self.roleId2NameMap[roleKey] = _G.GetStringFromOcts(roleName)
    end
  end
  self:SyncPlayerInfos(playerInfoMap)
end
def.method("table").SyncPlayerInfos = function(self, playerInfoMap)
  self.playerInfoMap = {}
  self.playerRankList = {}
  if playerInfoMap then
    for roleId, info in pairs(playerInfoMap) do
      local roleKey = Int64.tostring(roleId)
      info.roleId = roleId
      self.playerInfoMap[roleKey] = info
      table.insert(self.playerRankList, info)
    end
  end
  if #self.playerRankList > 0 then
    table.sort(self.playerRankList, function(a, b)
      if nil == a then
        return true
      elseif nil == b then
        return false
      elseif a.score ~= b.score then
        return a.score > b.score
      elseif a.update_time ~= b.update_time then
        return a.update_time > b.update_time
      else
        return Int64.lt(a.roleId, b.roleId)
      end
    end)
  end
  Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_PLAYER_CHANGE, nil)
end
def.method("userdata", "=>", "table").GetPlayerInfo = function(self, roleId)
  local result
  if roleId and self.playerInfoMap then
    local roleKey = Int64.tostring(roleId)
    result = self.playerInfoMap[roleKey]
  end
  return result
end
def.method("number").SyncCircle = function(self, circleIdx)
  warn("[ArenaInfo:SyncCircle] preCircle, curCircle:", self.circleIdx, circleIdx)
  self.circleIdx = circleIdx
  Event.DispatchEvent(ModuleId.AAGR, gmodule.notifyId.Aagr.AAGR_ARENA_CIRCLE_CHANGE, {circleIdx = circleIdx})
end
def.method("userdata", "=>", "number").GetPlayerLifeCount = function(self, roleId)
  local count = 0
  local playerInfo = roleId and self:GetPlayerInfo(roleId)
  if playerInfo then
    count = self.activityCfg.playerLifeNumber - playerInfo.death
  end
  return count
end
def.method("=>", "number").GetRoundRemainTime = function(self)
  return math.max(self.endTime - _G.GetServerTime(), 0)
end
def.method("=>", "number").GetShrinkRemainTime = function(self)
  local nextShrinkTime = self:GetNextShrinkTime()
  return math.max(nextShrinkTime - _G.GetServerTime(), 0)
end
def.method("=>", "number").GetNextShrinkTime = function(self)
  if self.circleIdx >= #self.circleCfg.levelCfgs then
    return 0
  else
    local nextShrinkTime = self.startTime
    for idx, levelCfg in ipairs(self.circleCfg.levelCfgs) do
      nextShrinkTime = nextShrinkTime + levelCfg.circleReduceSeconds
      if idx > self.circleIdx then
        break
      end
    end
    return nextShrinkTime
  end
end
def.method("=>", "table").GetPlayerRankList = function(self)
  return self.playerRankList
end
def.method("userdata", "=>", "string").GetPlayerName = function(self, roleId)
  if roleId then
    local roleKey = Int64.tostring(roleId)
    local roleName = self.roleId2NameMap[roleKey]
    return roleName or ""
  else
    return ""
  end
end
def.method("userdata", "=>", "number").GetPlayerScore = function(self, roleId)
  local score = 0
  local playerInfo = self:GetPlayerInfo(roleId)
  if playerInfo then
    score = playerInfo.score
  end
  return score
end
def.method("=>", "number").GetAlivePlayerCount = function(self)
  local result = 0
  if self.playerInfoMap then
    for _, info in pairs(self.playerInfoMap) do
      if info.death < self.activityCfg.playerLifeNumber then
        result = result + 1
      end
    end
  end
  return result
end
def.method("=>", "table").GetRoleId2NameMap = function(self)
  return self.roleId2NameMap
end
return ArenaInfo.Commit()
