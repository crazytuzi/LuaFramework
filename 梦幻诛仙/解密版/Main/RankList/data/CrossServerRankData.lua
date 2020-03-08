local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local CrossServerRankData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local PetUtility = require("Main.Pet.PetUtility")
local def = CrossServerRankData.define
def.final("number", "=>", CrossServerRankData).New = function(type)
  local obj = CrossServerRankData()
  obj.type = type
  obj.colCount = 5
  obj:Ctor()
  return obj
end
def.override("=>", "boolean").IsOpen = function(self)
  local phase_cfgs = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgs()
  for _, v in pairs(phase_cfgs) do
    if v.localChartType == self.type or v.remoteChartType == self.type then
      return not v.hide
    end
  end
  return false
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderRankReq").new(self.type, from, to))
end
def.override("table").UnmarshalProtocol = function(self, p)
  if self.list == nil then
    self.list = {}
  end
  for _, v in pairs(p.rankDatas) do
    self.list[v.rank] = v
  end
  self:Callback()
end
def.method("table").UnmarshalSelfRankProtocol = function(self, p)
  self.selfRank = p.rank
  self.selfValue = p.score
end
local stepInfo = {isNew = false, step = 0}
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  local listNum = #self.list
  local function DuanWeiHandler(uipart, context)
    if uipart == nil or context == nil then
      return
    end
    local cur_phase_cfg = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetPhaseCfgByChartType(self.type)
    local rank_cfg = cur_phase_cfg and cur_phase_cfg.ranks[context]
    local phase_name = rank_cfg and rank_cfg.name or tostring(context)
    uipart:GetComponent("UILabel"):set_text(phase_name)
  end
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local roleName = v.roleName
    local ChartType = require("consts.mzm.gsp.chart.confbean.ChartType")
    if self.type == ChartType.LADDER_REMOTE_60_TO_99 or self.type == ChartType.LADDER_REMOTE_100_TO_119 or self.type == ChartType.LADDER_REMOTE_120_TO_MAX then
      local serverInfo = _G.GetRoleServerInfo(v.roleid)
      if serverInfo then
        roleName = string.format("%s-%s", roleName, serverInfo.name)
      end
    end
    local occupationName = _G.GetOccupationName(v.occupation)
    local displayInfo = {
      v.rank,
      roleName,
      occupationName,
      v.score,
      stepInfo,
      {
        context = v.stage,
        handler = DuanWeiHandler
      }
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("function").OnReqSelfRankInfo = function(self, callback)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderSelfRankReq").new(self.type))
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self.selfValue
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
def.override("=>", "table").GetExtraInfo = function(self)
  local str = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetSeasonDateString()
  if str == "" then
    return nil
  end
  return {
    title = textRes.RankList.ExtraTitle[1],
    content = str
  }
end
CrossServerRankData.Commit()
return CrossServerRankData
