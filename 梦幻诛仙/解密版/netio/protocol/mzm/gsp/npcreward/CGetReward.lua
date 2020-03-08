local CGetReward = class("CGetReward")
CGetReward.TYPEID = 12615938
function CGetReward:ctor(activity_cfgid)
  self.id = 12615938
  self.activity_cfgid = activity_cfgid or nil
end
function CGetReward:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function CGetReward:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function CGetReward:sizepolicy(size)
  return size <= 65535
end
return CGetReward
