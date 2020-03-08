local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local CommonRankListData = import(".CommonRankListData")
local CrossBattBetData = Lplus.Extend(CommonRankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = CrossBattBetData.define
def.field("userdata").selfProfit = nil
def.final("number", "=>", CrossBattBetData).New = function(type)
  local obj = CrossBattBetData()
  obj.type = type
  obj.colCount = 3
  obj.top3Index = 3
  obj:Ctor()
  return obj
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  local startpos, num = from, to - from + 1
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crossbattle.CGetCrossBattleBetRankReq").new(self.type, constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID, startpos, num))
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
  self.selfProfit = p.profit
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
    local serverInfo = _G.GetRoleServerInfo(v.roleid)
    if serverInfo then
      roleName = string.format("%s-%s", roleName, serverInfo.name)
    end
    local displayInfo = {
      v.rank,
      roleName,
      v.profit,
      nil,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("function").OnReqSelfRankInfo = function(self, callback)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.crossbattle.CGetRoleCrossBattleBetRankReq").new(self.type, constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID))
end
def.override("=>", "number").GetSelfRank = function(self)
  return self.selfRank
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  local num = 0
  if self.selfProfit then
    num = self.selfProfit:ToNumber()
    if num > 0 then
      return string.format("[%s]%s[-]", textRes.RankList.BetRankColor[1], num)
    elseif num < 0 then
      return string.format("[%s]%s[-]", textRes.RankList.BetRankColor[2], num)
    end
  end
  return num
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
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CROSS_BATTLE_BET_RANK) then
    return false
  end
  return true
end
CrossBattBetData.Commit()
return CrossBattBetData
