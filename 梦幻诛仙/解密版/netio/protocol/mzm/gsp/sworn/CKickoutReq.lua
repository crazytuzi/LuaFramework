local CKickoutReq = class("CKickoutReq")
CKickoutReq.TYPEID = 12597789
function CKickoutReq:ctor(kickoutid)
  self.id = 12597789
  self.kickoutid = kickoutid or nil
end
function CKickoutReq:marshal(os)
  os:marshalInt64(self.kickoutid)
end
function CKickoutReq:unmarshal(os)
  self.kickoutid = os:unmarshalInt64()
end
function CKickoutReq:sizepolicy(size)
  return size <= 65535
end
return CKickoutReq
