local InnerInfo = require("netio.protocol.mzm.gsp.xiaohuikuaipao.InnerInfo")
local SInnerInfoRsp = class("SInnerInfoRsp")
SInnerInfoRsp.TYPEID = 12622858
function SInnerInfoRsp:ctor(activityId, innerInfo)
  self.id = 12622858
  self.activityId = activityId or nil
  self.innerInfo = innerInfo or InnerInfo.new()
end
function SInnerInfoRsp:marshal(os)
  os:marshalInt32(self.activityId)
  self.innerInfo:marshal(os)
end
function SInnerInfoRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.innerInfo = InnerInfo.new()
  self.innerInfo:unmarshal(os)
end
function SInnerInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SInnerInfoRsp
