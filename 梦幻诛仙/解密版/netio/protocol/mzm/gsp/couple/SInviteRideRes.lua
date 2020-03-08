local SInviteRideRes = class("SInviteRideRes")
SInviteRideRes.TYPEID = 12600577
SInviteRideRes.SUCCESS = 0
SInviteRideRes.IN_ACTIVITY = 1
SInviteRideRes.IN_TEAM = 2
SInviteRideRes.IN_COUPLE_RIDE = 3
SInviteRideRes.LEVEL_NOT_ENOUGH = 4
SInviteRideRes.IN_MODEL_CHANGE = 5
SInviteRideRes.OTHER_IN_MODEL_CHANGE = 5
function SInviteRideRes:ctor(ret)
  self.id = 12600577
  self.ret = ret or nil
end
function SInviteRideRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SInviteRideRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SInviteRideRes:sizepolicy(size)
  return size <= 65535
end
return SInviteRideRes
