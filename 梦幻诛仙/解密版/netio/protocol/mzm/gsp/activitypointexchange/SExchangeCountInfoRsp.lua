local ExchangeCountInfo = require("netio.protocol.mzm.gsp.activitypointexchange.ExchangeCountInfo")
local SExchangeCountInfoRsp = class("SExchangeCountInfoRsp")
SExchangeCountInfoRsp.TYPEID = 12624902
function SExchangeCountInfoRsp:ctor(activityId, activityPointExchangeMallCfgId, exchangeCountInfo)
  self.id = 12624902
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.exchangeCountInfo = exchangeCountInfo or ExchangeCountInfo.new()
end
function SExchangeCountInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  self.exchangeCountInfo:marshal(os)
end
function SExchangeCountInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.exchangeCountInfo = ExchangeCountInfo.new()
  self.exchangeCountInfo:unmarshal(os)
end
function SExchangeCountInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SExchangeCountInfoRsp
