local Lplus = require("Lplus")
local LuckyStarData = Lplus.Class("LuckyStarData")
local LuckyStarUtils = require("Main.LuckyStar.LuckyStarUtils")
local def = LuckyStarData.define
local instance
def.field("number").activityId = 0
def.field("table").awardInfo = nil
def.static("=>", LuckyStarData).Instance = function()
  if instance == nil then
    instance = LuckyStarData()
    instance.awardInfo = {}
  end
  return instance
end
def.method("number").SetLuckyStarActivityId = function(self, activityId)
  self.activityId = activityId
end
def.method("=>", "number").GetLuckyStarActivityId = function(self)
  return self.activityId
end
def.method("table").SetLuckyStarAwardInfo = function(self, awardInfo)
  self.awardInfo = awardInfo or {}
  table.sort(self.awardInfo, function(a, b)
    local luckyStarA = LuckyStarUtils.GetLuckyStarAwardInfoById(a.lucky_star_gift_cfg_id)
    local luckyStarB = LuckyStarUtils.GetLuckyStarAwardInfoById(b.lucky_star_gift_cfg_id)
    if luckyStarA == nil then
      return false
    end
    if luckyStarB == nil then
      return true
    end
    if luckyStarA.sale_rate == luckyStarB.sale_rate then
      return a.lucky_star_gift_cfg_id < b.lucky_star_gift_cfg_id
    else
      return luckyStarA.sale_rate < luckyStarB.sale_rate
    end
  end)
end
def.method("=>", "table").GetLuckyStarAwardInfo = function(self)
  return self.awardInfo or {}
end
def.method("number", "number").SetLuckyStarBuyTimes = function(self, cfgId, buyTimes)
  local awards = self:GetLuckyStarAwardInfo()
  for i = 1, #awards do
    if awards[i].lucky_star_gift_cfg_id == cfgId then
      awards[i].has_buy_times = buyTimes
    end
  end
end
def.method("number", "=>", "number").GetLuckyStarAwardIndex = function(self, cfgId)
  local awards = self:GetLuckyStarAwardInfo()
  for i = 1, #awards do
    if awards[i].lucky_star_gift_cfg_id == cfgId then
      return i
    end
  end
  return 0
end
def.method().ClearData = function(self)
  self.activityId = 0
  self.awardInfo = {}
end
LuckyStarData.Commit()
return LuckyStarData
