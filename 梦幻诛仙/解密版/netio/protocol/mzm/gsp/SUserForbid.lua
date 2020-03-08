local SUserForbid = class("SUserForbid")
SUserForbid.TYPEID = 12590090
function SUserForbid:ctor(expire_time, reason)
  self.id = 12590090
  self.expire_time = expire_time or nil
  self.reason = reason or nil
end
function SUserForbid:marshal(os)
  os:marshalInt64(self.expire_time)
  os:marshalString(self.reason)
end
function SUserForbid:unmarshal(os)
  self.expire_time = os:unmarshalInt64()
  self.reason = os:unmarshalString()
end
function SUserForbid:sizepolicy(size)
  return size <= 1024
end
return SUserForbid
