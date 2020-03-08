local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = import(".RankListData")
local KeJuRankListData = Lplus.Extend(RankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local KejuUtils = require("Main.Keju.KejuUtils")
local def = KeJuRankListData.define
def.field("boolean").isExpire = true
def.field("number").activityId = 0
def.final("number", "=>", KeJuRankListData).New = function(type)
  local obj = KeJuRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.method().Ctor = function(self)
  self.requsetList = {}
  self.activityId = KejuUtils.GetKejuCfg().acticityId
  RankListModule.Instance():MapActivity2RankList(self.activityId, self)
end
def.override("=>", "boolean").IsExpire = function(self)
  return self.isExpire
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  self:C2S_GetRankList()
end
def.method().SetExpire = function(self)
  self.isExpire = true
end
def.method().C2S_GetRankList = function(self)
  local p = require("netio.protocol.mzm.gsp.question.CGetKeJuRankReq").new()
  gmodule.network.sendProtocol(p)
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = p.rankList
  self.isExpire = false
  self:Callback()
end
def.override("number", "number", "=>", "table").GetListViewData = function(self, from, to)
  local list = self.list
  local getAppellation = function(rankLevel)
    if rankLevel <= 3 then
      return textRes.Keju.Rank[rankLevel]
    else
      return textRes.Keju[40]
    end
  end
  local getTimeStr = function(seconds)
    return string.format(textRes.RankList[8], seconds)
  end
  local stepInfo = {isNew = false, step = 0}
  local displayInfoList = {}
  local listNum = #list
  for i = from, to do
    local v = list[i]
    if v == nil then
      break
    end
    local appellation = getAppellation(i)
    local timeStr = getTimeStr(v.useTime)
    local displayInfo = {
      i,
      v.roleName,
      appellation,
      timeStr,
      stepInfo
    }
    table.insert(displayInfoList, displayInfo)
  end
  return displayInfoList
end
def.override("=>", "number").GetSelfRank = function(self)
  local heroProp = _G.GetHeroProp()
  if heroProp == nil or self.list == nil then
    return 0
  end
  local heroId = heroProp.id
  for i, v in ipairs(self.list) do
    if Int64.eq(v.roleId, heroId) then
      return i
    end
  end
  return 0
end
def.override("=>", "dynamic").GetSelfValue = function(self)
  return self:GetKeJuUseTime(self.list)
end
def.method("table", "=>", "string").GetKeJuUseTime = function(self, list)
  local useTimeStr = textRes.RankList[9]
  if list == nil then
    return useTimeStr
  end
  local useTime = 0
  local heroProp = _G.GetHeroProp()
  local heroId = heroProp.id
  for i, v in ipairs(list) do
    if Int64.eq(v.roleId, heroId) then
      useTime = v.useTime
      break
    end
  end
  if useTime > 0 then
    useTimeStr = string.format(textRes.RankList[8], useTime)
  end
  return useTimeStr
end
return KeJuRankListData.Commit()
