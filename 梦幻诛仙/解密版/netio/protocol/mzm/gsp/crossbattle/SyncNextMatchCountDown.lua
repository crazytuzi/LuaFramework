local SyncNextMatchCountDown = class("SyncNextMatchCountDown")
SyncNextMatchCountDown.TYPEID = 12617078
function SyncNextMatchCountDown:ctor(countdown)
  self.id = 12617078
  self.countdown = countdown or nil
end
function SyncNextMatchCountDown:marshal(os)
  os:marshalInt32(self.countdown)
end
function SyncNextMatchCountDown:unmarshal(os)
  self.countdown = os:unmarshalInt32()
end
function SyncNextMatchCountDown:sizepolicy(size)
  return size <= 65535
end
return SyncNextMatchCountDown
