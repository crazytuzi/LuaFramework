local SSynRoleBreakEggInfo = class("SSynRoleBreakEggInfo")
SSynRoleBreakEggInfo.TYPEID = 12623364
function SSynRoleBreakEggInfo:ctor(activity_id, reward_times)
  self.id = 12623364
  self.activity_id = activity_id or nil
  self.reward_times = reward_times or nil
end
function SSynRoleBreakEggInfo:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.reward_times)
end
function SSynRoleBreakEggInfo:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.reward_times = os:unmarshalInt32()
end
function SSynRoleBreakEggInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleBreakEggInfo
