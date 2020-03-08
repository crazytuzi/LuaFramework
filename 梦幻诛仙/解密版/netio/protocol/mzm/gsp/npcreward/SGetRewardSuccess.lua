local SGetRewardSuccess = class("SGetRewardSuccess")
SGetRewardSuccess.TYPEID = 12615939
function SGetRewardSuccess:ctor(activity_cfgid)
  self.id = 12615939
  self.activity_cfgid = activity_cfgid or nil
end
function SGetRewardSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function SGetRewardSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function SGetRewardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRewardSuccess
