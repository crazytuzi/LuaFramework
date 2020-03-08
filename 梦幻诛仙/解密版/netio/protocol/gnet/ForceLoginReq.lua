local ForceLoginReq = class("ForceLoginReq")
ForceLoginReq.TYPEID = 104
function ForceLoginReq:ctor(userid, localsid, reserved)
  self.id = 104
  self.userid = userid or nil
  self.localsid = localsid or nil
  self.reserved = reserved or nil
end
function ForceLoginReq:marshal(os)
  os:marshalOctets(self.userid)
  os:marshalInt32(self.localsid)
  os:marshalInt32(self.reserved)
end
function ForceLoginReq:unmarshal(os)
  self.userid = os:unmarshalOctets()
  self.localsid = os:unmarshalInt32()
  self.reserved = os:unmarshalInt32()
end
function ForceLoginReq:sizepolicy(size)
  return size <= 65535
end
return ForceLoginReq
