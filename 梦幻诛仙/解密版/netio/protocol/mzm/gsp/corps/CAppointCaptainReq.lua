local CAppointCaptainReq = class("CAppointCaptainReq")
CAppointCaptainReq.TYPEID = 12617494
function CAppointCaptainReq:ctor(newCaptain)
  self.id = 12617494
  self.newCaptain = newCaptain or nil
end
function CAppointCaptainReq:marshal(os)
  os:marshalInt64(self.newCaptain)
end
function CAppointCaptainReq:unmarshal(os)
  self.newCaptain = os:unmarshalInt64()
end
function CAppointCaptainReq:sizepolicy(size)
  return size <= 65535
end
return CAppointCaptainReq
