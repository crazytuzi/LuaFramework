local Lplus = require("Lplus")
local LuckyStarMgr = Lplus.Class("LuckyStarMgr")
local LuckyStarData = require("Main.LuckyStar.data.LuckyStarData")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local LuckyStarUtils = require("Main.LuckyStar.LuckyStarUtils")
local def = LuckyStarMgr.define
local instance
def.const("string").LUCKYSTAR_TIME_KEY = "Lucky_Star_Time"
def.static("=>", LuckyStarMgr).Instance = function()
  if instance == nil then
    instance = LuckyStarMgr()
  end
  return instance
end
def.method("table").SyncLuckyStarInfo = function(self, p)
  local luckyStarData = LuckyStarData.Instance()
  luckyStarData:SetLuckyStarActivityId(p.activity_cfg_id)
  luckyStarData:SetLuckyStarAwardInfo(p.award_info)
end
def.method().ClearData = function(self)
  local luckyStarData = LuckyStarData.Instance()
  luckyStarData:ClearData()
end
def.method("=>", "table").GetLuckyStarAwards = function(self)
  local luckyStarData = LuckyStarData.Instance()
  return luckyStarData:GetLuckyStarAwardInfo()
end
def.method("=>", "number").GetLuckyStarActivityId = function(self)
  local luckyStarData = LuckyStarData.Instance()
  return luckyStarData:GetLuckyStarActivityId()
end
def.method("number", "number", "number").SetLuckyStarBuyTimes = function(self, activityId, cfgId, buyTimes)
  local luckyStarData = LuckyStarData.Instance()
  if luckyStarData:GetLuckyStarActivityId() == activityId then
    luckyStarData:SetLuckyStarBuyTimes(cfgId, buyTimes)
  end
end
def.method("number", "=>", "number").GetLuckyStarAwardIndex = function(self, cfgId)
  local luckyStarData = LuckyStarData.Instance()
  return luckyStarData:GetLuckyStarAwardIndex(cfgId)
end
def.method().DrawLuckyStar = function(self)
  local activityId = self:GetLuckyStarActivityId()
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if activityInterface:isActivityOpend(activityId) then
    local key = LuckyStarMgr.LUCKYSTAR_TIME_KEY
    local openTime, activeTimeList, closeTime = activityInterface:getActivityStatusChangeTime(activityId)
    local nowActivityTime = openTime .. "_" .. closeTime
    LuaPlayerPrefs.SetRoleString(key, nowActivityTime)
    Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.DRAW_LUCKYSTAR, nil)
  end
end
def.method("=>", "boolean").HasDrawLuckyStar = function(self)
  local key = LuckyStarMgr.LUCKYSTAR_TIME_KEY
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return false
  end
  local activityId = self:GetLuckyStarActivityId()
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if activityInterface:isActivityOpend(activityId) then
    local key = LuckyStarMgr.LUCKYSTAR_TIME_KEY
    local openTime, activeTimeList, closeTime = activityInterface:getActivityStatusChangeTime(activityId)
    local nowActivityTime = openTime .. "_" .. closeTime
    if nowActivityTime == LuaPlayerPrefs.GetRoleString(key) then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasBuyAllLuckyStar = function(self)
  local awards = self:GetLuckyStarAwards()
  if awards == nil or #awards == 0 then
    return true
  end
  for i = 1, #awards do
    local luckyStar = LuckyStarUtils.GetLuckyStarAwardInfoById(awards[i].lucky_star_gift_cfg_id)
    if luckyStar ~= nil and awards[i].has_buy_times < luckyStar.buy_top_limit then
      return false
    end
  end
  return true
end
def.method("number", "number", "userdata").BuyLuckyStar = function(self, awardId, buyNum, currencyValue)
  local luckyStarData = LuckyStarData.Instance()
  local req = require("netio.protocol.mzm.gsp.luckystar.CBuyLuckyStarReq").new(luckyStarData:GetLuckyStarActivityId(), awardId, currencyValue, buyNum)
  gmodule.network.sendProtocol(req)
end
LuckyStarMgr.Commit()
return LuckyStarMgr
