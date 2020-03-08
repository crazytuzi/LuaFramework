local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local RankListData = import(".RankListData")
local CommonRankListData = Lplus.Extend(RankListData, CUR_CLASS_NAME)
local RankListModule = Lplus.ForwardDeclare("RankListModule")
local def = CommonRankListData.define
def.field("userdata").expireDate = nil
def.final("number", "=>", CommonRankListData).New = function(type)
  local obj = CommonRankListData()
  obj.type = type
  obj:Ctor()
  return obj
end
def.virtual().Ctor = function(self)
  self.expireDate = Int64.new(0)
  self.requsetList = {}
end
def.override("table").UnmarshalProtocol = function(self, p)
  self.list = self.list or {}
  for i, v in pairs(p.rankList) do
    self.list[v.no] = v
  end
  self.selfRank = p.myNo or 0
  self:Callback()
end
def.override("=>", "boolean").IsExpire = function(self)
  local ServerModule = require("Main.Server.ServerModule")
  local serverTime = ServerModule.Instance():GetServerTime()
  if Int64.ge(serverTime, self.expireDate) then
    return true
  end
  return false
end
def.override("number", "number", "function").OnReqRankList = function(self, from, to, callback)
  self:AddRequest(callback)
  RankListModule.Instance():ReqRankListDelegate(self.type, from, to)
end
def.virtual("dynamic", "=>", "table").GetStepInfo = function(self, step)
  step = step or 0
  local stepInfo = {isNew = false, step = step}
  local listNum = #self.list
  if step < -listNum then
    stepInfo.isNew = true
  end
  return stepInfo
end
return CommonRankListData.Commit()
