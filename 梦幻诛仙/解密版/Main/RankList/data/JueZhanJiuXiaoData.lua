local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local JueZhanJiuXiaoData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = JueZhanJiuXiaoData.define
def.final("number", "=>", JueZhanJiuXiaoData).New = function(type)
  local obj = JueZhanJiuXiaoData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local p = require("netio.protocol.mzm.gsp.jiuxiao.CJiuXiaoRankReq").new(self.type, from, to)
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankDatas) do
    self.list[v.rank] = v
    v.step = 0
  end
  self:Callback()
end
def.override("function").OnReqSelfRankInfo = function(self, callback)
  local p = require("netio.protocol.mzm.gsp.jiuxiao.CJiuXiaoSelfRankReq").new(self.type)
  gmodule.network.sendProtocol(p)
end
def.method("table").UnmarshalSelfRankProtocol = function(self, p)
  self.selfRank = p.rank
  self.selfValue = self:GetUseTimeDisplayStr(p.layer, p.time)
end
def.override("number").ReqTopNUnitInfo = function(self, number)
  if self.list == nil then
    warn("ranklist not init type = " .. self.type)
    return
  end
  local roleIdList = {}
  for i = 1, number do
    if self.list[i] and self.list[i].roleid then
      local roleId = self.list[i].roleid
      table.insert(roleIdList, roleId)
    end
  end
  local Top3Mgr = require("Main.RankList.Top3Mgr")
  Top3Mgr.Instance():ReqRoleModelList(self.type, roleIdList)
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
    local occupationName = _G.GetOccupationName(v.occupation)
    local layerName = string.format(textRes.RankList[100], v.layer)
    local useTimeStr = self:GetUseTimeDisplayStr(v.layer, v.time)
    local displayInfo = {
      v.rank,
      v.roleName,
      layerName,
      useTimeStr,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.method("number", "number", "=>", "string").GetUseTimeDisplayStr = function(self, layer, seconds)
  local JZJXMgr = require("Main.activity.JueZhanJiuXiao.JZJXMgr")
  local toplayer = JZJXMgr.TOP_LAYER
  if layer < toplayer then
    return textRes.RankList[102]
  end
  local s = seconds % 60
  local m = math.floor(seconds / 60)
  return string.format(textRes.RankList[101], m, s)
end
def.override("=>", "number").GetSelfRank = function(self)
  warn("selfRank", self.selfRank)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  warn("selfValue", self.selfValue)
  return self.selfValue
end
return JueZhanJiuXiaoData.Commit()
