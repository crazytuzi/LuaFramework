local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local ExperienceMasterListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = ExperienceMasterListData.define
def.final("number", "=>", ExperienceMasterListData).New = function(type)
  local obj = ExperienceMasterListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local p = require("netio.protocol.mzm.gsp.shitu.CMasterChartReq").new(from, to)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.rank] = v
  end
  self.selfValue = p.apprenticeSize
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
    local displayInfo = {
      v.rank,
      v.name,
      occupationName,
      v.apprenticeSize,
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
return ExperienceMasterListData.Commit()
