local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local HuanYueDongFuData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = HuanYueDongFuData.define
def.final("number", "=>", HuanYueDongFuData).New = function(type)
  local obj = HuanYueDongFuData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  local p = require("netio.protocol.mzm.gsp.paraselene.CParaseleneChartReq").new(startpos, num)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.rank] = v
    v.step = 0
  end
  self.selfRank = p.myrank or 0
  self.selfValue = self:GetUseTimeDisplayStr(p.seconds or 0)
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
    local occupationName = _G.GetOccupationName(v.occupationId)
    local useTimeStr = self:GetUseTimeDisplayStr(v.seconds)
    local displayInfo = {
      v.rank,
      v.name,
      occupationName,
      useTimeStr,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.method("number", "=>", "string").GetUseTimeDisplayStr = function(self, seconds)
  if seconds <= 0 then
    return string.format(textRes.RankList[102], m, s)
  else
    local s = seconds % 60
    local m = math.floor(seconds / 60)
    return string.format(textRes.RankList[101], m, s)
  end
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self.selfValue
end
return HuanYueDongFuData.Commit()
