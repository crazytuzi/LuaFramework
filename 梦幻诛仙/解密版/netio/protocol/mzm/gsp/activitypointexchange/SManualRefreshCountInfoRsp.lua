local ManualRefreshCountInfo = require("netio.protocol.mzm.gsp.activitypointexchange.ManualRefreshCountInfo")
local SManualRefreshCountInfoRsp = class("SManualRefreshCountInfoRsp")
SManualRefreshCountInfoRsp.TYPEID = 12624908
function SManualRefreshCountInfoRsp:ctor(activityId, activityPointExchangeMallCfgId, manualRefreshCountInfo)
  self.id = 12624908
  self.activityId = activityId or nil
  self.activityPointExchangeMallCfgId = activityPointExchangeMallCfgId or nil
  self.manualRefreshCountInfo = manualRefreshCountInfo or ManualRefreshCountInfo.new()
end
function SManualRefreshCountInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.activityPointExchangeMallCfgId)
  self.manualRefreshCountInfo:marshal(os)
end
function SManualRefreshCountInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.activityPointExchangeMallCfgId = os:unmarshalInt32()
  self.manualRefreshCountInfo = ManualRefreshCountInfo.new()
  self.manualRefreshCountInfo:unmarshal(os)
end
function SManualRefreshCountInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SManualRefreshCountInfoRsp
