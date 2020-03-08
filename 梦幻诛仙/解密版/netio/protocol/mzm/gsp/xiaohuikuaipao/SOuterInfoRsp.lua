local OuterInfo = require("netio.protocol.mzm.gsp.xiaohuikuaipao.OuterInfo")
local SOuterInfoRsp = class("SOuterInfoRsp")
SOuterInfoRsp.TYPEID = 12622854
function SOuterInfoRsp:ctor(activityId, turnInfo)
  self.id = 12622854
  self.activityId = activityId or nil
  self.turnInfo = turnInfo or OuterInfo.new()
end
function SOuterInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  self.turnInfo:marshal(os)
end
function SOuterInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.turnInfo = OuterInfo.new()
  self.turnInfo:unmarshal(os)
end
function SOuterInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SOuterInfoRsp
