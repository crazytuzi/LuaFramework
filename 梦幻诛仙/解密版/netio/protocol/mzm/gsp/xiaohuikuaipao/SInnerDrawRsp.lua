local InnerInfo = require("netio.protocol.mzm.gsp.xiaohuikuaipao.InnerInfo")
local AwardInfo = require("netio.protocol.mzm.gsp.xiaohuikuaipao.AwardInfo")
local SInnerDrawRsp = class("SInnerDrawRsp")
SInnerDrawRsp.TYPEID = 12622853
function SInnerDrawRsp:ctor(activityId, innerInfo, awardInfo, hitIndex)
  self.id = 12622853
  self.activityId = activityId or nil
  self.innerInfo = innerInfo or InnerInfo.new()
  self.awardInfo = awardInfo or AwardInfo.new()
  self.hitIndex = hitIndex or nil
end
function SInnerDrawRsp:marshal(os)
  os:marshalInt32(self.activityId)
  self.innerInfo:marshal(os)
  self.awardInfo:marshal(os)
  os:marshalInt32(self.hitIndex)
end
function SInnerDrawRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.innerInfo = InnerInfo.new()
  self.innerInfo:unmarshal(os)
  self.awardInfo = AwardInfo.new()
  self.awardInfo:unmarshal(os)
  self.hitIndex = os:unmarshalInt32()
end
function SInnerDrawRsp:sizepolicy(size)
  return size <= 65535
end
return SInnerDrawRsp
