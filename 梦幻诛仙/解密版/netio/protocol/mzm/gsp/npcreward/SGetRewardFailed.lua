local SGetRewardFailed = class("SGetRewardFailed")
SGetRewardFailed.TYPEID = 12615937
SGetRewardFailed.ERROR_SYSTEM = -1
SGetRewardFailed.ERROR_USERID = -2
SGetRewardFailed.ERROR_CFG = -3
SGetRewardFailed.ERROR_BAG_FULL = -4
SGetRewardFailed.ERROR_MAX_NUM = -5
SGetRewardFailed.ERROR_CAN_NOT_JOIN_ACTIVITY = -6
SGetRewardFailed.ERROR_GOLD_TO_MAX = -7
function SGetRewardFailed:ctor(activity_cfgid, retcode)
  self.id = 12615937
  self.activity_cfgid = activity_cfgid or nil
  self.retcode = retcode or nil
end
function SGetRewardFailed:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.retcode)
end
function SGetRewardFailed:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetRewardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetRewardFailed
