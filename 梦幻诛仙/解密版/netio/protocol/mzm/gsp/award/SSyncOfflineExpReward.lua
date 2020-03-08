local SSyncOfflineExpReward = class("SSyncOfflineExpReward")
SSyncOfflineExpReward.TYPEID = 12583428
function SSyncOfflineExpReward:ctor(offlineMinute, rewardExp)
  self.id = 12583428
  self.offlineMinute = offlineMinute or nil
  self.rewardExp = rewardExp or nil
end
function SSyncOfflineExpReward:marshal(os)
  os:marshalInt32(self.offlineMinute)
  os:marshalInt32(self.rewardExp)
end
function SSyncOfflineExpReward:unmarshal(os)
  self.offlineMinute = os:unmarshalInt32()
  self.rewardExp = os:unmarshalInt32()
end
function SSyncOfflineExpReward:sizepolicy(size)
  return size <= 65535
end
return SSyncOfflineExpReward
