local CBlessCoupleReq = class("CBlessCoupleReq")
CBlessCoupleReq.TYPEID = 12604937
function CBlessCoupleReq:ctor(roleid, content)
  self.id = 12604937
  self.roleid = roleid or nil
  self.content = content or nil
end
function CBlessCoupleReq:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.content)
end
function CBlessCoupleReq:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.content = os:unmarshalOctets()
end
function CBlessCoupleReq:sizepolicy(size)
  return size <= 65535
end
return CBlessCoupleReq
