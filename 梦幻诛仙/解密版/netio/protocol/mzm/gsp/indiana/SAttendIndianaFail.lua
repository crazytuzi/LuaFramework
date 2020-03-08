local SAttendIndianaFail = class("SAttendIndianaFail")
SAttendIndianaFail.TYPEID = 12628997
function SAttendIndianaFail:ctor(res)
  self.id = 12628997
  self.res = res or nil
end
function SAttendIndianaFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendIndianaFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendIndianaFail:sizepolicy(size)
  return size <= 65535
end
return SAttendIndianaFail
