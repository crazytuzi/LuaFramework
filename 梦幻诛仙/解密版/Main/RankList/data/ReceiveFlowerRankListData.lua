local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local RecieveFlowerRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = RecieveFlowerRankListData.define
def.final("number", "=>", RecieveFlowerRankListData).New = function(type)
  local obj = RecieveFlowerRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  local p = require("netio.protocol.mzm.gsp.item.CGetReceiveFlowerPointRankReq").new(startpos, num)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.no] = v
  end
  self.selfValue = p.mypoint
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
      v.no,
      v.name,
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
return RecieveFlowerRankListData.Commit()
