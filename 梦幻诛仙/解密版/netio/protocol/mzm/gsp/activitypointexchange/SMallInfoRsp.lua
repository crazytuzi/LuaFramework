local MallInfo = require("netio.protocol.mzm.gsp.activitypointexchange.MallInfo")
local SMallInfoRsp = class("SMallInfoRsp")
SMallInfoRsp.TYPEID = 12624900
function SMallInfoRsp:ctor(activityId, activityPointExchangeMallCfgId, mallInfo)
  self.id = 12624900
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.mallInfo = mallInfo or MallInfo.new()
end
function SMallInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  self.mallInfo:marshal(os)
end
function SMallInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.mallInfo = MallInfo.new()
  self.mallInfo:unmarshal(os)
end
function SMallInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SMallInfoRsp
