local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local SocialSpacePopular = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local SocialSpaceProtocol = require("Main.SocialSpace.SocialSpaceProtocol")
local def = SocialSpacePopular.define
def.final("number", "=>", SocialSpacePopular).New = function(type)
  local obj = SocialSpacePopular()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("=>", "boolean").IsOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if not IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE) then
    return false
  end
  if not IsFeatureOpen(Feature.TYPE_FRIENDS_CIRCLE_CHART) then
    return false
  end
  return true
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  SocialSpaceProtocol.CWeekPopularityChartReq(from, to)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rank_list) do
    self.list[v.rank] = v
  end
  self.selfRank = p.my_rank or 0
  self.selfValue = p.current_week_popularity_value or 0
  self:Callback()
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local list = self.list
  local displayInfoList = {}
  local listNum = #list
  for i = from, to do
    local v = list[i]
    if v == nil then
      break
    end
    local stepInfo = self:GetStepInfo(v.step)
    local occupationName = _G.GetOccupationName(v.occupation_id)
    local roleName = _G.GetStringFromOcts(v.name)
    local displayInfo = {
      v.rank,
      roleName,
      occupationName,
      tostring(v.popularity_value),
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
return SocialSpacePopular.Commit()
