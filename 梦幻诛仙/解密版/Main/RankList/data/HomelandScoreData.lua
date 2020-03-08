local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local HomelandScoreData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = HomelandScoreData.define
def.final("number", "=>", HomelandScoreData).New = function(type)
  local obj = HomelandScoreData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("=>", "boolean").IsOpen = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsFeatureOpen()
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.homeland.CHomeChartReq").new(startpos, num))
end
def.override("table").UnmarshalProtocol = function(self, p)
  if self.list == nil then
    self.list = {}
  end
  for _, v in pairs(p.rankList) do
    self.list[v.rank] = v
  end
  self.selfValue = p.point
  self.selfRank = p.myrank
  self:Callback()
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  local listNum = #self.list
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local createrName = _G.GetStringFromOcts(v.name)
    local partnerName = _G.GetStringFromOcts(v.partnerName) or textRes.RankList[9]
    local stepInfo = self:GetStepInfo(v.step)
    local displayInfo = {
      v.rank,
      createrName,
      partnerName,
      v.point,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
HomelandScoreData.Commit()
return HomelandScoreData
