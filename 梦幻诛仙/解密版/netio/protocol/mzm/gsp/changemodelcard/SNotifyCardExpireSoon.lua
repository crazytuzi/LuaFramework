local SNotifyCardExpireSoon = class("SNotifyCardExpireSoon")
SNotifyCardExpireSoon.TYPEID = 12624420
SNotifyCardExpireSoon.EXPIRE_BY_TIME = 1
SNotifyCardExpireSoon.EXPIRE_BY_PVP_COUNT = 2
function SNotifyCardExpireSoon:ctor(notify_type)
  self.id = 12624420
  self.notify_type = notify_type or nil
end
function SNotifyCardExpireSoon:marshal(os)
  os:marshalInt32(self.notify_type)
end
function SNotifyCardExpireSoon:unmarshal(os)
  self.notify_type = os:unmarshalInt32()
end
function SNotifyCardExpireSoon:sizepolicy(size)
  return size <= 65535
end
return SNotifyCardExpireSoon
