local SClearShiTuActiveRewardInfo = class("SClearShiTuActiveRewardInfo")
SClearShiTuActiveRewardInfo.TYPEID = 12601663
function SClearShiTuActiveRewardInfo:ctor()
  self.id = 12601663
end
function SClearShiTuActiveRewardInfo:marshal(os)
end
function SClearShiTuActiveRewardInfo:unmarshal(os)
end
function SClearShiTuActiveRewardInfo:sizepolicy(size)
  return size <= 65535
end
return SClearShiTuActiveRewardInfo
