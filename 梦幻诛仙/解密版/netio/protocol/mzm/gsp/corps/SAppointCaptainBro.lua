local SAppointCaptainBro = class("SAppointCaptainBro")
SAppointCaptainBro.TYPEID = 12617493
function SAppointCaptainBro:ctor(newCaptain)
  self.id = 12617493
  self.newCaptain = newCaptain or nil
end
function SAppointCaptainBro:marshal(os)
  os:marshalInt64(self.newCaptain)
end
function SAppointCaptainBro:unmarshal(os)
  self.newCaptain = os:unmarshalInt64()
end
function SAppointCaptainBro:sizepolicy(size)
  return size <= 65535
end
return SAppointCaptainBro
