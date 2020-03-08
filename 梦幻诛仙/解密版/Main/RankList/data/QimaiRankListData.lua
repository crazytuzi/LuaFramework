local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local QimaiRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = QimaiRankListData.define
def.final("number", "=>", QimaiRankListData).New = function(type)
  local obj = QimaiRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from - 1, to - from
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CQMHWSelfRankReq").new())
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.qmhw.CQMHWRankReq").new(startpos, to))
end
def.override("table").UnmarshalProtocol = function(self, p)
  if self.list == nil then
    self.list = {}
  end
  for _, v in pairs(p.rankDatas) do
    self.list[v.rank + 1] = v
  end
  self:Callback()
end
local stepInfo = {isNew = false, step = 0}
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  local listNum = #self.list
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local occupationName = _G.GetOccupationName(v.occupation)
    local displayInfo = {
      v.rank + 1,
      v.roleName,
      occupationName,
      v.score,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "number").GetSelfRank = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU).myrank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU).score
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
QimaiRankListData.Commit()
return QimaiRankListData
