local SEnablePKSuccess = class("SEnablePKSuccess")
SEnablePKSuccess.TYPEID = 12619783
function SEnablePKSuccess:ctor(expire_time)
  self.id = 12619783
  self.expire_time = expire_time or nil
end
function SEnablePKSuccess:marshal(os)
  os:marshalInt32(self.expire_time)
end
function SEnablePKSuccess:unmarshal(os)
  self.expire_time = os:unmarshalInt32()
end
function SEnablePKSuccess:sizepolicy(size)
  return size <= 65535
end
return SEnablePKSuccess
