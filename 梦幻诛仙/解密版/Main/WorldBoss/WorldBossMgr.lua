local Lplus = require("Lplus")
local WorldBossUtility = require("Main.WorldBoss.WorldBossUtility")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local WorldBossMgr = Lplus.Class("WorldBossMgr")
local def = WorldBossMgr.define
def.const("number").ACTIVITYID = WorldBossUtility.GetConstByName("ACTIVITYID")
def.const("number").DAMAGE_PARAM = WorldBossUtility.GetConstByName("DAMAGE_PARAM")
def.const("number").AWARD_TIP_ID = WorldBossUtility.GetConstByName("AWARD_TIP_ID")
def.const("number").MAX_BUY_COUNT = WorldBossUtility.GetConstByName("MAX_BUY_COUNT")
def.const("number").FIGHT_END_REWARDID = WorldBossUtility.GetConstByName("FIGHT_END_REWARDID")
def.const("number").YUANBAO_PRICE_ADD_NUM = WorldBossUtility.GetConstByName("YUANBAO_PRICE_ADD_NUM")
def.const("number").FIRST_BUY_YUANBAO_PRICE = WorldBossUtility.GetConstByName("FIRST_BUY_YUANBAO_PRICE")
def.const("number").DAY_OFFER_CHALLENGE_COUNT = WorldBossUtility.GetConstByName("DAY_OFFER_CHALLENGE_COUNT")
def.const("number").BUY_COUNT = 1
def.field("number").occupationId = 0
def.field("number").score = 0
def.field("number").rank = 0
def.field("number").totalbuycount = 0
def.field("number").leftCount = 0
def.field("number").curBossId = 0
def.field("number").nextBossId = 0
def.field("number").startTime = 0
def.field("number").endTime = 0
def.field("number").nextStartTime = 0
def.field("table").rankList = nil
def.field("table").occupationList = nil
local instance
def.static("=>", WorldBossMgr).Instance = function()
  if instance == nil then
    instance = WorldBossMgr()
  end
  return instance
end
def.method().Init = function(self)
  local openedOccupationIds = _G.GetAllRealOpenedOccupations()
  self.occupationList = {}
  for key, value in pairs(openedOccupationIds) do
    local occupationCfg = _G.GetOccupationCfg(value, GenderEnum.MALE)
    if occupationCfg then
      occupationCfg.occupationId = value
      table.insert(self.occupationList, occupationCfg)
    end
  end
end
def.method().ClearUp = function(self)
  self.occupationId = 0
  self.score = 0
  self.rank = 0
  self.totalbuycount = 0
  self.leftCount = 0
  self.curBossId = 0
  self.nextBossId = 0
  self.startTime = 0
  self.endTime = 0
  self.nextStartTime = 0
  self.rankList = nil
end
def.method("table").SyncAllData = function(self, p)
  self:SetScoreRank(p.ocp, p.damagePoint, p.rank)
  self:SetChallengeCounts(p.totalbuycount, p.challengeCount)
  self:SetBossIDs(p.monsterid, p.nextmonsterid)
  self:SetActivityTime(Int64.ToNumber(p.startTime), Int64.ToNumber(p.endTime), Int64.ToNumber(p.nextStartTime))
end
def.method("table").SyncRankList = function(self, ranklist)
  if not ranklist then
    return
  end
  self.rankList = {}
  local rankCount = #ranklist
  for i = 1, rankCount do
    local rankItem = {}
    rankItem.rank = ranklist[i].rank
    rankItem.name = ranklist[i].name
    rankItem.occupationId = ranklist[i].occupationId
    rankItem.damagepoint = ranklist[i].damagepoint
    table.insert(self.rankList, rankItem)
  end
end
def.method("=>", "table").GetRankList = function(self)
  return self.rankList
end
def.method("number", "number", "number").SetScoreRank = function(self, occupationId, score, rank)
  warn("[WorldBossMgr:SetScoreRank] set occupationid, rank, score:", occupationId, rank, score)
  self.occupationId = occupationId
  self.score = score
  self.rank = rank
end
def.method("number", "number").SetChallengeCounts = function(self, totalbuy, left)
  self.totalbuycount = totalbuy
  self.leftCount = left
end
def.method("number", "number").SetBossIDs = function(self, curbossid, nextbossid)
  self.curBossId = curbossid
  self.nextBossId = nextbossid
end
def.method("number", "number", "number").SetActivityTime = function(self, starttime, endtime, nexttime)
  self.startTime = starttime
  self.endTime = endtime
  self.nextStartTime = nexttime
end
def.method("number").SetChallengeCountLeft = function(self, count)
  self.leftCount = count
end
def.method("=>", "number").GetPreRankOccupationId = function(self)
  return self.occupationId
end
def.method("=>", "table").GetScoreRank = function(self)
  return {
    occupationId = self.occupationId,
    score = self.score,
    rank = self.rank
  }
end
def.method("=>", "number").GetChallengeCountLeft = function(self)
  return self.leftCount
end
def.method("=>", "number").GetTotalBuyCount = function(self)
  return self.totalbuycount
end
def.method("boolean", "=>", "number").GetBossID = function(self, isthisweek)
  if isthisweek then
    return self.curBossId
  end
  return self.nextBossId
end
def.method("=>", "number").GetStartTime = function(self)
  return self.startTime
end
def.method("=>", "number").GetEndTime = function(self)
  return self.endTime
end
def.method("=>", "number").GetNextStartTime = function(self)
  return self.nextStartTime
end
def.method("=>", "number").GetCost = function(self)
  return WorldBossMgr.FIRST_BUY_YUANBAO_PRICE + WorldBossMgr.YUANBAO_PRICE_ADD_NUM * (self.totalbuycount + 1)
end
def.method("=>", "table").GetAwardList = function(self)
  local rawData = WorldBossUtility.GetAllRankAwards()
  if not rawData then
    return nil
  end
  local count = #rawData
  local awardList = {}
  for i = 1, count do
    local data = rawData[i]
    local award = {}
    if data.maxRank == data.minRank then
      award.rankRange = data.maxRank
    else
      award.rankRange = string.format("%d ~ %d", data.minRank, data.maxRank)
    end
    award.desc = data.desc
    table.insert(awardList, award)
  end
  return awardList
end
def.method("=>", "string").GetWorldBossTip = function(self)
  local tip = require("Main.Common.TipsHelper").GetHoverTip(WorldBossMgr.AWARD_TIP_ID)
  return tip
end
def.method("=>", "table").GetOccupationList = function(self)
  return self.occupationList
end
def.method("number", "=>", "table").GetOccupationCfgByIndex = function(self, index)
  return self.occupationList[index]
end
def.method("number", "=>", "number").GetOccupationIdByIndex = function(self, index)
  local occupCfg = self.occupationList[index]
  return occupCfg and occupCfg.occupationId or -1
end
def.method("number", "=>", "string").GetOccupationNameByIndex = function(self, index)
  return self.occupationList[index] and self.occupationList[index].occupationName or ""
end
def.method("=>", "number").GetDefaultOccupationIndex = function(self)
  local result = 1
  for i = 1, #self.occupationList do
    if self.occupationList[i].occupationId == GetHeroProp().occupation then
      result = i
      break
    end
  end
  return result
end
def.method("number", "=>", "table").GetRankListByOccupationIndex = function(self, occupationIndex)
  local occupationRankList = {}
  local occupationCfg = self:GetOccupationCfgByIndex(occupationIndex)
  if occupationCfg then
    for key, value in ipairs(self.rankList) do
      if value and value.occupationId == occupationCfg.occupationId then
        table.insert(occupationRankList, value)
      else
      end
    end
  else
    warn(string.format("[WorldBossMgr:GetRankListByOccupationIndex] occupationCfg nil at index [%d]!", occupationIndex))
  end
  table.sort(occupationRankList, function(a, b)
    return a.rank <= b.rank
  end)
  return occupationRankList
end
return WorldBossMgr.Commit()
