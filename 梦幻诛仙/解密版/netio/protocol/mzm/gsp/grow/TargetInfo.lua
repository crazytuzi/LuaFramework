local OctetsStream = require("netio.OctetsStream")
local AwardInfoBean = require("netio.protocol.mzm.gsp.award.AwardInfoBean")
local TargetInfo = class("TargetInfo")
function TargetInfo:ctor(targetId, targetState, targetParam, targetAwardBean)
  self.targetId = targetId or nil
  self.targetState = targetState or nil
  self.targetParam = targetParam or nil
  self.targetAwardBean = targetAwardBean or AwardInfoBean.new()
end
function TargetInfo:marshal(os)
  os:marshalInt32(self.targetId)
  os:marshalInt32(self.targetState)
  os:marshalInt32(self.targetParam)
  self.targetAwardBean:marshal(os)
end
function TargetInfo:unmarshal(os)
  self.targetId = os:unmarshalInt32()
  self.targetState = os:unmarshalInt32()
  self.targetParam = os:unmarshalInt32()
  self.targetAwardBean = AwardInfoBean.new()
  self.targetAwardBean:unmarshal(os)
end
return TargetInfo
