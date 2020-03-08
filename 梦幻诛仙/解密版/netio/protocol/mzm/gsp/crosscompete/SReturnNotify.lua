local SReturnNotify = class("SReturnNotify")
SReturnNotify.TYPEID = 12616743
SReturnNotify.REASON_ACTIVE = 0
SReturnNotify.REASON_LACK_ACTION_POINT = 1
SReturnNotify.REASON_MAP_ROLE_DESTROY = 2
SReturnNotify.REASON_LOSE = 3
SReturnNotify.REASON_TREASURE = 4
SReturnNotify.REASON_FORCE_END = 5
SReturnNotify.REASON_WINNER_ACTIVE = 6
function SReturnNotify:ctor(reason)
  self.id = 12616743
  self.reason = reason or nil
end
function SReturnNotify:marshal(os)
  os:marshalInt32(self.reason)
end
function SReturnNotify:unmarshal(os)
  self.reason = os:unmarshalInt32()
end
function SReturnNotify:sizepolicy(size)
  return size <= 65535
end
return SReturnNotify
