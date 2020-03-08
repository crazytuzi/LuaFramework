local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local HulaRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = HulaRankListData.define
def.final("number", "=>", HulaRankListData).New = function(type)
  local obj = HulaRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("=>", "boolean").IsOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local featureType = Feature.TYPE_HULA
  if featureType == nil then
    return false
  end
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(featureType)
  return isOpen
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  local p = require("netio.protocol.mzm.gsp.hula.CHulaChartReq").new(startpos, num)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.rank] = v
  end
  self.selfValue = p.point
  self.selfRank = p.myrank
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
    local name = _G.GetStringFromOcts(v.name)
    local displayInfo = {
      v.rank,
      name,
      occupationName,
      tostring(v.point),
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self.selfValue
end
return HulaRankListData.Commit()
