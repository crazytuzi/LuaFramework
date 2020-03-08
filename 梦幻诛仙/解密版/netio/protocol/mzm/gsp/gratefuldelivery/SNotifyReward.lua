local SNotifyReward = class("SNotifyReward")
SNotifyReward.TYPEID = 12615690
function SNotifyReward:ctor(count, activity_id)
  self.id = 12615690
  self.count = count or nil
  self.activity_id = activity_id or nil
end
function SNotifyReward:marshal(os)
  os:marshalInt32(self.count)
  os:marshalInt32(self.activity_id)
end
function SNotifyReward:unmarshal(os)
  self.count = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function SNotifyReward:sizepolicy(size)
  return size <= 65535
end
return SNotifyReward
