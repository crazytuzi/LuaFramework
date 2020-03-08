local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local ArenaRankListData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = ArenaRankListData.define
def.final("number", "=>", ArenaRankListData).New = function(type)
  local obj = ArenaRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.jingji.CJingjiChartReq").new(startpos, num))
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.no] = v
    v.step = v.step or 0
  end
  self.selfValue = p.point or 0
  self.selfRank = p.myrank or 0
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
    local phaseData = gmodule.moduleMgr:GetModule(ModuleId.IMAGEPVP):GetPhaseData(v.phase)
    local phaseName = phaseData and phaseData.phaseName or "unknown"
    local stepInfo = self:GetStepInfo(v.step)
    local displayInfo = {
      v.no,
      v.name,
      phaseName,
      v.winpoint,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
return ArenaRankListData.Commit()
