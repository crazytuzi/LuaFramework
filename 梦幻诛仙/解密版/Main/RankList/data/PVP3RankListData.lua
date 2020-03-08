local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = import(".RankListData")
local PVP3RankListData = Lplus.Extend(RankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = PVP3RankListData.define
def.final("number", "=>", PVP3RankListData).New = function(type)
  local obj = PVP3RankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.method().Ctor = function(self)
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CSelfRankReq").new())
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CChartReq").new(0))
end
def.override("=>", "boolean").IsExpire = function(self)
  return true
end
def.override("number").ReqTopNUnitInfo = function(self, number)
  if self.list == nil then
    warn("ranklist not init type = " .. self.type)
    return
  end
  local roleIdList = {}
  for i = 1, number do
    if self.list[i] then
      local roleId = self.list[i].roleid
      table.insert(roleIdList, roleId)
    end
  end
  local Top3Mgr = require("Main.RankList.Top3Mgr")
  Top3Mgr.Instance():ReqRoleModelList(self.type, roleIdList)
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  local listNum = #self.list
  local stepInfo = {isNew = false, step = 0}
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local displayInfo = {
      i,
      v.name,
      _G.GetOccupationName(v.menpai),
      v.score
    }
    table.insert(displayInfo, stepInfo)
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = p.data_list
  self:Callback()
end
def.override("=>", "number").GetSelfRank = function(self)
  local PKData = require("Main.PK.data.PKData")
  local rank = PKData.Instance().rank
  return rank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  local score = require("Main.PK.data.PKData").Instance().points
  if score < 0 then
    score = 0
  end
  return tostring(score)
end
def.override("number").ShowUnitInfo = function(self, index)
  if self.list[index] and self.list[index].roleid then
    local roleId = self.list[index].roleid
    local RankUnitInfoMgr = require("Main.RankList.RankUnitInfoMgr")
    RankUnitInfoMgr.Instance():ShowRoleInfo(roleId)
  end
end
return PVP3RankListData.Commit()
