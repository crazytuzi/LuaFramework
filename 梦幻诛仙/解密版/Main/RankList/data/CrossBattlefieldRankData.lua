local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local CrossBattlefieldRankData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local CrossBattlefieldModule = require("Main.CrossBattlefield.CrossBattlefieldModule")
local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
local def = CrossBattlefieldRankData.define
def.final("number", "=>", CrossBattlefieldRankData).New = function(type)
  local obj = CrossBattlefieldRankData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crossfield.CGetCrossFieldRankReq").new(self.type, startpos, num))
end
def.override("table").UnmarshalProtocol = function(self, p)
  if self.list == nil then
    self.list = {}
  end
  for _, v in pairs(p.rank_list) do
    self.list[v.rank] = v
  end
  self:Callback()
end
def.method("table").UnmarshalSelfRankProtocol = function(self, p)
  self.selfRank = p.rank
  Event.DispatchEvent(ModuleId.CROSS_BATTLEFIELD, gmodule.notifyId.CrossBattlefield.SELF_RANK_UPDATE, {
    rankType = self.type,
    rank = self.selfRank
  })
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local displayInfoList = {}
  local stepInfo = {isNew = false, step = 0}
  for i = from, to do
    local v = self.list[i]
    if v == nil then
      break
    end
    local roleName = _G.GetStringFromOcts(v.name)
    if self.type == require("consts.mzm.gsp.chart.confbean.ChartType").SINGLE_CROSS_FIELD_ROMOTE then
      local serverInfo = _G.GetRoleServerInfo(v.roleid)
      if serverInfo then
        roleName = string.format("%s-%s", roleName, serverInfo.name)
      end
    end
    local occupationName = _G.GetOccupationName(v.occupation)
    local duanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(v.star_num)
    local displayInfo = {
      v.rank,
      roleName,
      occupationName,
      duanweiInfo.fullName,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("function").OnReqSelfRankInfo = function(self, callback)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crossfield.CGetRoleCrossFieldRankReq").new(self.type))
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  local starNum = seasonMgr:GetStarNum()
  local duanweiInfo = CrossBattlefieldModule.Instance():GetDuanweiInfoByStarNum(starNum)
  return duanweiInfo.fullName
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
def.override("=>", "boolean").IsOpen = function(self)
  return gmodule.moduleMgr:GetModule(ModuleId.CROSS_BATTLEFIELD):IsFeatureOpen()
end
def.override("=>", "table").GetExtraInfo = function(self)
  local CrossBattlefieldUtils = require("Main.CrossBattlefield.CrossBattlefieldUtils")
  local CrossBattlefieldSeasonMgr = require("Main.CrossBattlefield.CrossBattlefieldSeasonMgr")
  local seasonMgr = CrossBattlefieldSeasonMgr.Instance()
  local season = seasonMgr:GetSeason()
  local curSeasonCfg = CrossBattlefieldUtils.GetCrossBattlefieldSeasonCfg(season)
  local nextSeason = season + 1
  local nextSeasonCfg = CrossBattlefieldUtils.GetCrossBattlefieldSeasonCfg(nextSeason)
  if curSeasonCfg and nextSeasonCfg then
    local title = textRes.RankList.ExtraTitle[2]
    local content = string.format("    %d.%d.%d ~ %d.%d.%d", curSeasonCfg.year, curSeasonCfg.month, curSeasonCfg.day, nextSeasonCfg.year, nextSeasonCfg.month, nextSeasonCfg.day)
    return {title = title, content = content}
  else
    return nil
  end
end
CrossBattlefieldRankData.Commit()
return CrossBattlefieldRankData
