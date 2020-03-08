local MallInfo = require("netio.protocol.mzm.gsp.activitypointexchange.MallInfo")
local SManualRefreshRsp = class("SManualRefreshRsp")
SManualRefreshRsp.TYPEID = 12624905
function SManualRefreshRsp:ctor(activityId, activityPointExchangeMallCfgId, mallInfo)
  self.id = 12624905
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.mallInfo = mallInfo or MallInfo.new()
end
function SManualRefreshRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  self.mallInfo:marshal(os)
end
function SManualRefreshRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.mallInfo = MallInfo.new()
  self.mallInfo:unmarshal(os)
end
function SManualRefreshRsp:sizepolicy(size)
  return size <= 65535
end
return SManualRefreshRsp
