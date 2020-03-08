local SoldOutInfo = require("netio.protocol.mzm.gsp.activitypointexchange.SoldOutInfo")
local SSoldOutInfoRsp = class("SSoldOutInfoRsp")
SSoldOutInfoRsp.TYPEID = 12624906
function SSoldOutInfoRsp:ctor(activityId, activityPointExchangeMallCfgId, soldOutInfo)
  self.id = 12624906
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.soldOutInfo = soldOutInfo or SoldOutInfo.new()
end
function SSoldOutInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  self.soldOutInfo:marshal(os)
end
function SSoldOutInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.soldOutInfo = SoldOutInfo.new()
  self.soldOutInfo:unmarshal(os)
end
function SSoldOutInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SSoldOutInfoRsp
