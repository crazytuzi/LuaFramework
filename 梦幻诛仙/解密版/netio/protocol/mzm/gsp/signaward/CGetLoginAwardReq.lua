local CGetLoginAwardReq = class("CGetLoginAwardReq")
CGetLoginAwardReq.TYPEID = 12593415
function CGetLoginAwardReq:ctor(daycount)
  self.id = 12593415
  self.daycount = daycount or nil
end
function CGetLoginAwardReq:marshal(os)
  os:marshalInt32(self.daycount)
end
function CGetLoginAwardReq:unmarshal(os)
  self.daycount = os:unmarshalInt32()
end
function CGetLoginAwardReq:sizepolicy(size)
  return size <= 65535
end
return CGetLoginAwardReq
