local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local ChildrenRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local RankListUtils = require("Main.RankList.RankListUtils")
local SelfRankMgr = require("Main.RankList.SelfRankMgr")
local def = ChildrenRankListData.define
def.final("number", "=>", ChildrenRankListData).New = function(type)
  local obj = ChildrenRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local p = require("netio.protocol.mzm.gsp.children.CChildrenChartReq").new(from, to)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rank_list) do
    self.list[v.rank] = v
  end
  self.selfRank = p.my_rank or 0
  self.selfValue = p.my_rating or 0
  self:Callback()
end
def.override("number").ReqTopNUnitInfo = function(self, number)
  if self.list == nil then
    warn("ranklist not init type = " .. self.type)
    return
  end
  local idList = {}
  for i = 1, number do
    if self.list[i] then
      table.insert(idList, self.list[i].child_id)
    end
  end
  local Top3Mgr = require("Main.RankList.Top3Mgr")
  Top3Mgr.Instance():ReqChildrenModelList(self.type, idList)
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
    local displayInfo = {
      v.rank,
      _G.GetStringFromOcts(v.child_name),
      _G.GetStringFromOcts(v.role_name),
      tostring(v.rating),
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
def.override("number").ShowUnitInfo = function(self, index)
  local rankData = self.list[index]
  local RankUnitInfoMgr = require("Main.RankList.RankUnitInfoMgr")
  RankUnitInfoMgr.Instance():ShowChildInfo(rankData.child_id)
end
def.override("=>", "boolean").IsOpen = function(self)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isRankOpen = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_CHILDREN_RATING_RANK)
  return isRankOpen
end
return ChildrenRankListData.Commit()
