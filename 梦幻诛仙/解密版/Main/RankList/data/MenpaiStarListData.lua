local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local MenpaiStarListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = MenpaiStarListData.define
def.final("number", "=>", MenpaiStarListData).New = function(type)
  local obj = MenpaiStarListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("=>", "boolean").IsOpen = function(self)
  local isOpen = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR)
  return isOpen
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  if self.list == nil then
    self:AddRequest(callback)
    local p = require("netio.protocol.mzm.gsp.menpaistar.CGetMenPaiStars").new()
    gmodule.network.sendProtocol(p)
  else
    self:AddRequest(callback)
    self:Callback()
  end
end
def.override("table").UnmarshalProtocol = function(self, p)
  local realOpenOccpations = GetAllRealOpenedOccupations()
  self.list = {}
  for i, v in pairs(p.champions) do
    if realOpenOccpations[v.occupationid] then
      table.insert(self.list, v)
    end
  end
  self.selfValue = 0
  self.selfRank = 0
  self:Callback()
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local list = self.list
  local displayInfoList = {}
  for i = from, to do
    local v = list[i]
    if v == nil then
      break
    end
    local stepInfo = self:GetStepInfo(0)
    local occupationName = string.format(textRes.MenpaiStar[50], _G.GetOccupationName(v.occupationid))
    local name = textRes.MenpaiStar[41]
    local rank = 0
    local point = ""
    if v.roleid > Int64.new(0) then
      occupationName = string.format(textRes.MenpaiStar[51], _G.GetOccupationName(v.occupationid))
      name = string.format(textRes.MenpaiStar[51], _G.GetStringFromOcts(v.role_name))
      rank = 1
      point = string.format(textRes.MenpaiStar[51], tostring(v.point))
    end
    local displayInfo = {
      rank,
      name,
      occupationName,
      point,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "boolean").IsShowMyRank = function(self)
  return false
end
def.override("=>", "number").GetSelfRank = function(self)
  return -1
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return ""
end
return MenpaiStarListData.Commit()
